/* 
* This is the query to generate 14, 30, 60, 90days ltv multiplier against 7days ltv for each campaign.
* Once you figure out the multiplier, you can predict x-day ltv in each cohort 
* by multipling actual 7days ltv by the multiplier.
*
* Replace these variables before running the query. 
* @DATE => refers to the date that you want to get the multiplier. This has to be >= 90days before the current date
* @BUNDLEID => bundle_id for your app
*/

SELECT
  rev.bundle_id
  , rev.platform
  , c.name AS "campaign"
  , SUM(rev.rev_14d)/SUM(rev.rev_7d) :: DOUBLE PRECISION AS multiplier_14d_7d
  , SUM(rev.rev_30d)/SUM(rev.rev_7d) :: DOUBLE PRECISION AS multiplier_30d_7d
  , SUM(rev.rev_60d)/SUM(rev.rev_7d) :: DOUBLE PRECISION AS multiplier_60d_7d
  , SUM(rev.rev_90d)/SUM(rev.rev_7d) :: DOUBLE PRECISION AS multiplier_90d_7d
FROM (
  SELECT
    bundle_id
    , platform
    , source_campaign_id
    , SUM(CASE WHEN date_diff('sec', acquired_at, created_at) / 86400 <= 7
    THEN revenue END) AS rev_7d
    , SUM(CASE WHEN date_diff('sec', acquired_at, created_at) / 86400 <= 14
    THEN revenue END) AS rev_14d
    , SUM(CASE WHEN date_diff('sec', acquired_at, created_at) / 86400 <= 30
    THEN revenue END) AS rev_30d
    , SUM(CASE WHEN date_diff('sec', acquired_at, created_at) / 86400 <= 60
    THEN revenue END) AS rev_60d
    , SUM(CASE WHEN date_diff('sec', acquired_at, created_at) / 86400 <= 90
    THEN revenue END) AS rev_90d
  FROM events
  WHERE
    acquired_at::DATE <= '@DATE'
    AND bundle_id = '@BUNDLEID'
    AND event_type = 'purchase'
  GROUP BY
    bundle_id
    , platform
    , source_campaign_id
) rev
LEFT OUTER JOIN campaigns c
ON rev.source_campaign_id = c.id
LEFT OUTER JOIN ad_networks an
ON c.ad_network_id = an.id
GROUP BY 
  rev.bundle_id
  , rev.platform
  , c.name
;