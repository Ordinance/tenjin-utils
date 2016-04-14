/*
* This query is to generate a list of advertising_ids who have made purchase before.
* @DATE => date you want to capture for the advertising_ids
*/

SELECT
  d.name AS app_name
  , a.platform
  , a.country
  , a.acquired_at :: DATE AS acquired_at
  , c.name AS channel
  , a.advertising_id
  , SUM(CASE WHEN date_diff('sec', a.acquired_at, a.created_at) / 86400 <= 90
  THEN a.revenue END)/100/0.7  :: DOUBLE PRECISION AS day90_revenue
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
LEFT OUTER JOIN (
  SELECT
    id
    , name
  FROM apps
) d
ON a.app_id = d.id
WHERE
  event_type = 'purchase'
  AND acquired_at >= '@DATE'
GROUP BY
  d.name
  , a.platform
  , a.country
  , a.acquired_at
  , c.name
  , a.advertising_id
