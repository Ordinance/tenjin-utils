
/*
* This query is to generate a list of advertising_ids so we can re-engage users who have purchased something before.
* You can upload the list to Facebook/send ad-network for re-engagagement campaign.
* The list includes revenue(USD in cents, after google/apple cut) and lapsed days(how many days users have been inactive)
* , so you can run the multiple campaigns by segmenting the list. (ex, revenue $>=5, lapsed days >= 7)
* Also ab_flg will dynamically "mark" the users with a flag(0 or 1) so you can measure lift of the users after the re-engagement campaign runs.
*
* Replace these variables before running the query. 
* @START_DATE => insert campaign beginning date 
* @DATE => date you want to capture for the advertising_ids
* @YOUR_BUNDLE_ID => the bundle_id of your app
*/

SELECT 
  sq.bundle_id
  , sq.platform
  , sq.advertising_id
  , sq.revenue
  , date_diff('day', sq2.last_login_date, '@START_DATE') AS lapsed_day
  , MOD(CAST(SUBSTRING(REGEXP_REPLACE(sq.advertising_id, '[^0-9]'),LEN(REGEXP_REPLACE(sq.advertising_id, '[^0-9]'))-1, 2) AS INT),2) AS ab_flg
FROM (
  SELECT
    bundle_id
    , platform
    , advertising_id
    , SUM(revenue) AS revenue
  FROM events
  WHERE
    event_type = 'purchase'
    AND bundle_id = '@BUNDLEID'
    AND acquired_at >= '@DATE'
    AND limit_ad_tracking = FALSE    
  GROUP BY
    bundle_id
    , platform
    , advertising_id
) sq
LEFT OUTER JOIN (
  SELECT
    bundle_id
    , advertising_id
    , MAX(created_at) :: DATE AS last_login_date
  FROM events
  WHERE
    event = 'open'
    AND bundle_id = '@BUNDLEID'
  GROUP BY
    bundle_id
    , advertising_id
) sq2
ON sq.bundle_id = sq2.bundle_id AND sq.advertising_id = sq2.advertising_id
;