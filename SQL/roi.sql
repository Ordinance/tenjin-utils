/* This is a query to calculate ROI per campaign
Replace the following params before you run the query
@START_DATE => refers to the start date that you want to see the data for.
@END_DATE => refers to the end date that you want to see the data for.
@BUNDLEID => bundle_id of your app
@PLATFORM => platform of your app
*/
SELECT
  ds.date
  , ds.bucket_campaign_info_id AS campaign_id
  , bci.name AS campaign_name
  , an.name AS channel
  , a.platform AS platform
  , a.name AS app_name
  , spend
  , installs
  , d3_revenue
  , d30_revenue
  , CASE WHEN spend = 0 THEN 0 ELSE (d3_revenue - spend)/spend END AS d3_roi
  , CASE WHEN spend = 0 THEN 0 ELSE (d30_revenue - spend)/spend END AS d30_roi
FROM (
  SELECT
    date
    , coalesce(c.campaign_bucket_id, c.id) AS bucket_campaign_info_id
    , SUM(spend) / 100.0 AS spend
    , SUM(installs) AS installs
  FROM daily_spend ds 
  LEFT JOIN campaigns c
  ON ds.campaign_id = c.id
  LEFT JOIN apps a
  ON c.app_id = c.id
  WHERE date >= '@START_DATE' AND date <= '@END_DATE' AND bundle_id ='@BUNDLEID' AND platform = '@PLATFORM'
  GROUP BY 1,2
) ds
LEFT JOIN (
  SELECT 
    date
    , coalesce(c.campaign_bucket_id, c.id) AS bucket_campaign_info_id
    , SUM(CASE WHEN xday <= 3 then revenue END)/100.0 AS d3_revenue
    , SUM(CASE WHEN xday <= 30 then revenue END) / 100.0 AS d30_revenue
  FROM cohort_behavior cb
  LEFT JOIN campaigns c
  ON cb.campaign_id = c.id
  LEFT JOIN apps a
  ON c.app_id = c.id
  WHERE date >= '@START_DATE' AND date <= '@END_DATE' AND bundle_id ='@BUNDLEID' AND platform = '@PLATFORM'
  GROUP BY 1,2
) cb
ON ds.date = cb.date AND ds.bucket_campaign_info_id = cb.bucket_campaign_info_id
LEFT JOIN bucket_campaign_info bci
ON ds.bucket_campaign_info_id = bci.id
LEFT JOIN ad_networks an
ON bci.ad_network_id = an.id
LEFT JOIN apps a
ON bci.app_id = a.id
