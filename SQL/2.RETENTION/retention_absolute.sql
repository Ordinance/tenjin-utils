/* Calculate the 1 day, 3 day, 7 day, 14 days, 30 days retention rate
 * retention rate is based on absolute time(see https://help.tenjin.io/t/how-is-tenjin-retention-calculated/24)
 * @BUNDLEID is the bundle_id or package name of your app that you're calculating retention rate for
 * Speciffy @START_DATE and @END_DATE with actual date that you're calculating retention rate for
 */
SELECT 
  acquired_at::date,
  count(distinct coalesce(advertising_id, developer_device_id)) AS tracked_installs,
  count(distinct CASE
        WHEN date_diff('day',acquired_at,created_at) = 1 
        THEN coalesce(advertising_id, developer_device_id) 
        end)/count(distinct coalesce(advertising_id, developer_device_id)) :: DOUBLE PRECISION AS d1_rr,
  count(distinct CASE
        WHEN date_diff('day',acquired_at,created_at) = 3 
        THEN coalesce(advertising_id, developer_device_id) 
        end)/count(distinct coalesce(advertising_id, developer_device_id)) :: DOUBLE PRECISION  AS d3_rr,
  count(distinct CASE
        WHEN date_diff('day',acquired_at,created_at) = 7 
        THEN coalesce(advertising_id, developer_device_id) 
        end)/count(distinct coalesce(advertising_id, developer_device_id)) :: DOUBLE PRECISION  AS d7_rr,
  count(distinct CASE
        WHEN date_diff('day',acquired_at,created_at) = 14 
        THEN coalesce(advertising_id, developer_device_id) 
        end)/count(distinct coalesce(advertising_id, developer_device_id)) :: DOUBLE PRECISION  AS d14_rr,
  count(distinct CASE
        WHEN date_diff('day',acquired_at,created_at) = 30 
        THEN coalesce(advertising_id, developer_device_id) 
        end)/count(distinct coalesce(advertising_id, developer_device_id)) :: DOUBLE PRECISION  AS d30_rr
FROM events
WHERE bundle_id = '@BUNDLEID'
  AND acquired_at >= '@START_DATE' AND acquired_at < '@END_DATE'
  AND event = 'open'
GROUP BY 1
ORDER BY 1 ASC;