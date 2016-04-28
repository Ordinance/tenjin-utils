/* This is a query on how to calculate DAU keying off of advertising_id for your individual users.
@DATE => refers to to the date that you want to see DAU for.
@BUNDLEID => bundle_id for your app
@PLATFORM => platform of your app
*/

SELECT COUNT(DISTINCT advertising_id)
FROM events
WHERE created_at::DATE = @DATE
  AND bundle_id = @BUNDLEID
  AND platform = @PLATFORM;