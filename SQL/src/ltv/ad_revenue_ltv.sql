/* This is a query to calculate day 7 LTV(both IAP and ad-revenue) by campaign/country/site. Replace the following params before you run the query. 
@START_DATE => refers to the start date that you want to see the data for.
@END_DATE => refers to the end date that you want to see the data for.
@BUNDLEID => bundle_id of your app
@PLATFORM => platform of your app
*/
SELECT 
  cb.date, a.name AS app_name, a.platform, an.name AS ad_network_name, c.name AS campaign_name, cb.country, cb.site_id
, CASE 
    WHEN SUM(CASE WHEN cb.xday = 0 THEN users END) = 0 THEN 0
    ELSE SUM(CASE WHEN cb.xday <= 7 THEN cb.revenue END)/100.0/SUM(CASE WHEN cb.xday = 0 THEN users END)
    END AS d7_iap_ltv
, CASE
    WHEN SUM(CASE WHEN cb.xday = 0 THEN users END) = 0 THEN 0
    ELSE SUM(CASE WHEN cb.xday <= 7 THEN pr.revenue END)/100.0/SUM(CASE WHEN cb.xday = 0 THEN users END)
    END AS d7_pub_ltv
, SUM(CASE WHEN cb.xday = 0 THEN users END) AS tracked_installs
FROM cohort_behavior cb
LEFT OUTER JOIN (
SELECT
  s.acquired_at
  , s.xday
  , coalesce(s.campaign_id, 'N/A') AS campaign_id
  , coalesce(s.country, 'un') AS country
  , coalesce(s.site_id, 'unknown') AS site_id
  , SUM(revenue * sessions::float / nullif(app_sessions, 0)) AS revenue
FROM daily_ad_revenue r
INNER JOIN publisher_apps p
ON p.id = r.publisher_app_id
INNER JOIN (
  SELECT
    created_at :: DATE AS created_at
    , acquired_at :: DATE AS acquired_at
    , datediff('sec', acquired_at, created_at) / 86400 AS xday
    , c.id AS campaign_id
    , c.app_id
    , country
    , site_id
    , COUNT(*) AS sessions
    , SUM(COUNT(*)) over (partition by created_at::date, c.app_id) AS app_sessions
  FROM events e
  LEFT OUTER JOIN campaigns c
  ON e.source_campaign_id = c.id
  WHERE e.event = 'open' AND e.bundle_id = '@BUNDLEID' AND e.platform = '@PLATFORM'
  GROUP BY 1,2,3,4,5,6,7
) s
ON r.date = s.created_at AND p.app_id = s.app_id
WHERE r.date >= '@START_DATE' AND s.acquired_at >= '@START_DATE' AND s.acquired_at <= '@END_DATE'
GROUP BY 1,2,3,4,5
) pr
ON cb.date = pr.acquired_at AND cb.campaign_id = pr.campaign_id AND cb.site_id = pr.site_id AND cb.country = pr.country AND cb.xday = pr.xday
LEFT OUTER JOIN campaigns c
ON cb.campaign_id = c.id
LEFT OUTER JOIN ad_networks an
ON c.ad_network_id = an.id
LEFT OUTER JOIN apps a
ON c.app_id = a.id
WHERE cb.date >= '@START_DATE' AND cb.date <= '@END_DATE' AND a.bundle_id = '@BUNDLEID' AND a.platform = '@PLATFORM'
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1,2,3,4,5,6,7