/*
* This query is to generate a list of advertising_ids who have made purchase before.
*/

SELECT
  d.name AS app_name
  , a.platform
  , a.country
  , a.acquired_at :: DATE AS acquired_date
  , c.name AS channel
  , a.advertising_id
  , SUM(CASE WHEN date_diff('sec', a.acquired_at, a.created_at) / 86400 <= 90
  THEN a.revenue END)/100  :: DOUBLE PRECISION AS net_90day_revenue
FROM events a
-- Adding ad_network_id for each device_id
LEFT OUTER JOIN (
  SELECT
    app_id
    , id
    , ad_network_id
  FROM campaigns
) b
ON a.app_id = b.app_id AND a.source_campaign_id = b.id
-- Adding ad-network name for each device_id
LEFT OUTER JOIN (
  SELECT
    id
    , name
  FROM ad_networks
) c
ON b.ad_network_id = c.id
-- Adding app name for each device_id
LEFT OUTER JOIN (
  SELECT
    id
    , name
  FROM apps
) d
ON a.app_id = d.id
WHERE 
  event_type = 'purchase'
GROUP BY
  d.name
  , a.platform
  , a.country
  , a.acquired_at
  , c.name
  , a.advertising_id
;