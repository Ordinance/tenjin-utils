SELECT
  to_date(date, 'YYYY-MM-DD') AS date
  , 'TENJIN_CAMPAING_ID' AS campaign_id
  , 'TENJIN_CAMPAING_ID' AS campaign_name
  , d.bundle_id
  , d.store_id
  , d.platform
  , d.name AS app_name
  , SUM(spend)/100 :: DOUBLE PRECISION AS spend
  , SUM(installs) AS installs
  , SUM(clicks) AS clicks
  , SUM(impressions) AS impressions
FROM daily_spend a
LEFT OUTER JOIN campaigns b
ON a.campaign_id = b.id
LEFT OUTER JOIN ad_networks c
ON b.ad_network_id = c.id
LEFT OUTER JOIN apps d
ON b.app_id = d.id
WHERE bundle_id = 'BUNDLE_ID'
AND LOWER(c.name) = 'NETWORK'
AND platform = 'PLATFORM'
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1
