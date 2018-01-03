/* Calculate the ARPDAU of event revenue for a specific date. 
 * @BUNDLEID   - the bundle ID or package name of the app
 * @PLATFORM    - the platform of the app (ios, andorid, amazon)
 * @DATE        - the date of the calculation
*/

SELECT SUM(revenue)/100.0 / COUNT(DISTINCT coalesce(advertising_id, developer_device_id)) AS arpdau
FROM events
WHERE created_at :: DATE = '@DATE'
  AND bundle_id = '@BUNDLEID'
  AND platform = '@PLATFORM';