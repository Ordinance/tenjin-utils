/* This is a query to generate the list of advertising ID who has made in-app purchase before.
You can upload the list of advertising ID to Facebook/Twitter for lookalike campaigns.
The list includes acquisition channel, the date when the device installed the app
, and total revenue(USD in cents, after google/apple cut).
You can create multiple lookalike campaigns by segmenting the list with these parameters
, to see which segment performs better.
(ex. revenue < $5, revenue: $5-$10, revenue >= $10)

@DATE => refers to the date that you want to get the list for.
@BUNDLEID => bundle_id for your app
*/

SELECT
  a.bundle_id
  , a.platform
  , a.advertising_id
  , c.name AS channel
  , a.acquired_at AS acquired_date
  , a.revenue
FROM (
  SELECT
    bundle_id
    , platform
    , advertising_id
    , source_campaign_id
    , acquired_at::DATE
    , SUM(revenue) AS revenue
  FROM events
  WHERE
    acquired_at::DATE >= '@DATE'
    AND bundle_id = '@BUNDLEID'
    AND event_type = 'purchase'
    AND limit_ad_tracking = FALSE
  GROUP BY
    bundle_id
    , platform
    , advertising_id
    , source_campaign_id
    , acquired_at::DATE
  HAVING SUM(revenue) > 0
) a
LEFT OUTER JOIN campaigns b
ON a.source_campaign_id = b.id
LEFT OUTER JOIN ad_networks c
ON b.ad_network_id = c.id
;