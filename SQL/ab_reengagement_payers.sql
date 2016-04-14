/*
* This query is to generate a list of advertising_ids so we can re-engage users who have purchased something within 90-days of install.
* It will dynamically "mark" the users with a flag so you can measure lift of the users after the re-engagement campaign runs.
* Replace there variables before running the query. 
* @START_DATE => insert campaign beginning date 
* @DATE => date you want to capture for the advertising_ids
* @YOUR_BUNDLE_ID => the bundle_id of your app
*/

SELECT 
  sq.app_id
  , sq.platform
  , sq.country
  , sq.acquired_at
  , sq.advertising_id
  , sq.name AS channel
  , sq.net_90day_revenue
  , date_diff('day', '@START_DATE', sq2.last_login_date) AS lapsed_day
  , MOD(CAST(SUBSTRING(REGEXP_REPLACE(sq.advertising_id, '[^0-9]'),LEN(REGEXP_REPLACE(sq.advertising_id, '[^0-9]'))-1, 2) AS INT),2) AS ab_flg
FROM (
  SELECT
    a.app_id
    , a.platform
    , a.country
    , a.acquired_at :: DATE AS acquired_at
    , c.name
    , a.advertising_id
    , SUM(CASE WHEN date_diff('sec', a.acquired_at, a.created_at) / 86400 <= 90
    THEN a.revenue END)/100 :: DOUBLE PRECISION AS net_90day_revenue
  FROM events a
  LEFT OUTER JOIN (
    SELECT
      app_id
      , id
      , ad_network_id
    FROM campaigns
  ) b
  ON a.app_id = b.app_id AND a.source_campaign_id = b.id
  LEFT OUTER JOIN (
    SELECT
      id
      , name
    FROM ad_networks
  ) c
  ON b.ad_network_id = c.id
  WHERE
    event_type = 'purchase'
    AND bundle_id = '@YOUR_BUNDLE_ID'
    AND acquired_at >= '@DATE'
    AND limit_ad_tracking = FALSE
  GROUP BY
    a.app_id
    , a.platform
    , a.country
    , a.acquired_at
    , c.name
    , a.advertising_id
) sq
LEFT OUTER JOIN (
  SELECT
    platform
    , advertising_id
    , MAX(created_at) :: DATE AS last_login_date
  FROM events
  WHERE
    event = 'open'
    AND bundle_id = '@YOUR_BUNDLE_ID'
  GROUP BY
    platform
    , advertising_id
) sq2
ON sq.platform = sq2.platform AND sq.advertising_id = sq2.advertising_id
;