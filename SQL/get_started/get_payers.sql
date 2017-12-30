/*
* This is a simple script to illustrate how easy it is to get a list of advertising_ids that have purchased
* at least one thing in your app
* @BUNDLE_ID => the bundle id of your app
* @PLATFORM => the platform of your app
*/

SELECT DISTINCT advertising_id
FROM events 
WHERE event_type = 'purchase'
  AND bundle_id = '@BUNDLE_ID'
  AND platform = '@PLATFORM';