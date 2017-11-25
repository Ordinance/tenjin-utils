/* Calculate the retention rate based on both relative and absolute time. Our dashboard uses relative time, 
 * but you can also get retention rate based on absolute time by this query.
 * @BUNDLEID is the bundle_id or package name of your app that you're calculating retention rate for
 * @START_DATE is the start date when you're calculating retention rate for
 * @END_DATE is the end date when you're calculating retention rate for
 */
SELECT 
  acquired_at
  , tracked_installs
  , d1_r_users / tracked_installs :: DOUBLE PRECISION AS d1_r_rr -- day 1 retention rate based on relative time
  , d3_r_users / tracked_installs :: DOUBLE PRECISION AS d3_r_rr -- day 3 retention rate based on relative time
  , d1_a_users / tracked_installs :: DOUBLE PRECISION AS d1_a_rr -- day 1 retention rate based on absolute time
  , d3_a_users / tracked_installs :: DOUBLE PRECISION AS d3_a_rr -- day 3 retention rate based on absolute time
FROM (
  SELECT 
    acquired_at :: date AS acquired_at
    , count(distinct coalesce(advertising_id, developer_device_id)) AS tracked_installs
    -- day 1 returned users based on relative time
    , count(distinct CASE WHEN date_diff('sec',acquired_at,created_at)/86400 = 1
          THEN coalesce(advertising_id, developer_device_id) END) AS d1_r_users
    -- day 3 returned users based on relative time
    , count(distinct CASE WHEN date_diff('sec',acquired_at,created_at)/86400 = 3
          THEN coalesce(advertising_id, developer_device_id) END) AS d3_r_users
    -- day 1 returned users based on absolute time
    , count(distinct CASE WHEN date_diff('day',acquired_at,created_at) = 1
          THEN coalesce(advertising_id, developer_device_id) END) AS d1_a_users
    -- day 3 returned users based on absolute time
    , count(distinct CASE WHEN date_diff('day',acquired_at,created_at) = 3
          THEN coalesce(advertising_id, developer_device_id) END) AS d3_a_users
  FROM events
  WHERE
    bundle_id = '@BUNDLEID'
    AND acquired_at >= '@START_DATE' AND acquired_at < '@END_DATE'
    AND event = 'open'
  GROUP BY 1
) sq
ORDER BY 1
