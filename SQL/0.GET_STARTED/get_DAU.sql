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

/*Example: get distinct users for a date range between 1/1/2016 to 2/1/2016 - this is also known as MAU*/

SELECT COUNT(DISTINCT advertising_id)
FROM events
WHERE created_at::DATE >= '2016-01-01'
  AND created_at::DATE <= '2016-02-01'
  AND bundle_id = @BUNDLEID
  AND platform = @PLATFORM;