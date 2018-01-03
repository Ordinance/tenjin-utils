/* This is a query to calculate day 7 ROI per campaign/country/site. Replace the following params before you run the query. 
We used the same CPI for each site in specific date and country, since currently we don't get CPI by site
@START_DATE => refers to the start date that you want to see the data for.
@END_DATE => refers to the end date that you want to see the data for.
@BUNDLEID => bundle_id of your app
@PLATFORM => platform of your app
*/
SELECT
  date, app_name, platform, network_name, bci.name AS campaign_name, site_id, country
  , CASE WHEN cpi = 0 THEN 0 ELSE (d7_rev - cpi)/cpi/1.0 END AS d7_roi
  , cpi, tracked_installs, d7_ltv, d7_rev
FROM (
  SELECT
    cb.date, a.bundle_id, a.name AS app_name, a.platform, an.name AS network_name, coalesce(c.campaign_bucket_id, c.id) AS bucket_campaign_info_id, cb.site_id, cb.country
    , CASE WHEN d.cpi = 0 OR d.cpi IS NULL THEN e.cpi ELSE d.cpi END AS cpi
    , SUM(CASE WHEN cb.xday <= 7 THEN cb.revenue ELSE 0 END)/100.0 AS d7_rev
    , SUM(CASE WHEN cb.xday = 0 THEN cb.users ELSE 0 END) AS tracked_installs
    , CASE
        WHEN SUM(CASE WHEN cb.xday = 0 THEN cb.users ELSE 0 END) > 0
        THEN SUM(CASE WHEN cb.xday <= 7 THEN cb.revenue ELSE 0 END)/100.0/SUM(CASE WHEN cb.xday = 0 THEN cb.users ELSE 0 END)
        ELSE 0 END AS d7_ltv
  FROM cohort_behavior cb
  LEFT OUTER JOIN campaigns c
  ON cb.campaign_id = c.id
  LEFT OUTER JOIN ad_networks an
  ON c.ad_network_id = an.id
  LEFT OUTER JOIN apps a
  ON c.app_id = a.id
  LEFT OUTER JOIN (
    SELECT
      date, coalesce(c.campaign_bucket_id, c.id) AS bucket_campaign_info_id, country
      , CASE WHEN SUM(installs) > 0 THEN (SUM(spend/100.0) / SUM(installs)) ELSE 0 END AS cpi
    FROM daily_country_spend ds
    LEFT OUTER JOIN campaigns c
    ON ds.campaign_id = c.id
    WHERE date >= '@START_DATE' AND date <= '@END_DATE'
    GROUP BY 1,2,3
  ) d
  ON cb.date = d.date AND coalesce(c.campaign_bucket_id, c.id) = d.bucket_campaign_info_id AND cb.country = d.country
  -- Use average CPI across countries if there is no CPI for the specific date and country
  LEFT OUTER JOIN ( 
    SELECT
      date, coalesce(c.campaign_bucket_id, c.id) AS bucket_campaign_info_id
      , CASE WHEN SUM(installs) > 0 THEN (SUM(spend/100.0) / SUM(installs)) ELSE 0 END AS cpi
    FROM daily_country_spend ds
    LEFT OUTER JOIN campaigns c
    ON ds.campaign_id = c.id
    WHERE date >= '@START_DATE' AND date <= '@END_DATE'
    GROUP BY 1,2
  ) e
  ON cb.date = e.date AND coalesce(c.campaign_bucket_id, c.id) = e.bucket_campaign_info_id
  WHERE a.bundle_id = '@BUNDLEID' AND a.platform = '@PLATFORM' AND cb.date >= '@START_DATE' AND cb.date <= '@END_DATE'
  GROUP BY 1,2,3,4,5,6,7,8,9
) sq
LEFT JOIN bucket_campaign_info bci
ON sq.bucket_campaign_info_id = bci.id
ORDER BY 1,2,3,4,5,6,7