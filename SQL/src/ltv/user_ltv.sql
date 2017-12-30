/* Calculate the cohorted LTV for users up to 120-days after the install date. 
 * Use date_diff to figure out when to sum up revenue values.  
 * Filter for event_type = purchase to to limit events to payers only.
 * @BUNDLEID is the bundle_id or package name of your app that you're calculating LTV per payer for
 * acquired_at payer's acquired_at date. Grouping by acquired_at will cohort for that acquisition date of the payer.
 */

SELECT 
  acquired_at :: DATE,
  COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS "Installs",
  SUM(CASE
        WHEN date_diff('sec',acquired_at,created_at)/86400 <= 7 THEN revenue/100.0
      END)/COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS "7-day",
  SUM(CASE
        WHEN date_diff('sec',acquired_at,created_at)/86400 <= 30 THEN revenue/100.0
      END)/COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS "30-day",
  SUM(CASE
        WHEN date_diff('sec',acquired_at,created_at)/86400 <= 60 THEN revenue/100.0
      END)/COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS "60-day",
  SUM(CASE
        WHEN date_diff('sec', acquired_at, created_at)/86400 <= 90 THEN revenue/100.0
      END)/COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS "90-day",
  SUM(CASE
        WHEN date_diff('sec',acquired_at,created_at)/86400 <= 120 THEN revenue/100.0
      END)/COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS "120-day"
FROM events
WHERE bundle_id = '@BUNDLEID'
  AND acquired_at <= '2016-11-14'
GROUP BY 1
ORDER BY 1 ASC;