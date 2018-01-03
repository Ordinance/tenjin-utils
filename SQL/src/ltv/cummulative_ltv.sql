/* Construct a cummulative x-day LTV curve for users that have purchased something in the app. 
 * Replace @BUNDLEID with your app's bundle_id or pacakage name.
 */
SELECT
  a.bundle_id,
  a.xday,
  SUM(CASE
    WHEN a.xday >= b.xday THEN b.ltv
    ELSE 0
  END) / c.payers AS ltv_payers
FROM (SELECT
  bundle_id,
  date_diff('sec', acquired_at, created_at) / 86400 AS xday,
  COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS payers,
  SUM(revenue) / 100.0 AS ltv
FROM events
WHERE event_type = 'purchase'
AND bundle_id = '@BUNDLEID'
GROUP BY 1,
         2) a
LEFT OUTER JOIN (SELECT
  bundle_id,
  date_diff('sec', acquired_at, created_at) / 86400 AS xday,
  COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS payers,
  SUM(revenue) / 100.0 AS ltv
FROM events
WHERE event_type = 'purchase'
AND bundle_id = '@BUNDLEID'
GROUP BY 1,
         2) b
  ON a.bundle_id = b.bundle_id
  AND a.xday >= b.xday
LEFT OUTER JOIN (SELECT
  bundle_id,
  COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS payers
FROM events
WHERE event_type = 'purchase'
AND bundle_id = '@BUNDLEID'
GROUP BY 1) c
  ON a.bundle_id = c.bundle_id
GROUP BY a.bundle_id,
         a.xday,
         c.payers
ORDER BY 1,
2;