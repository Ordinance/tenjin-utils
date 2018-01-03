/* This is a query on how to calculate DAU keying off of advertising_id for your individual users.
@DATE => refers to to the date that you want to see DAU for. You can also have a range here.
@BUNDLEID => bundle_id for your app
@PLATFORM => platform of your app
*/

/*DAU for a specific day by country*/

SELECT country, COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) as DAU
FROM events
WHERE created_at :: DATE = '@DATE'
  AND bundle_id = '@BUNDLEID'
  AND platform = '@PLATFORM'
GROUP BY 1;