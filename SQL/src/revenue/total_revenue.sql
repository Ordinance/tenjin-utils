/* Calculate the total IAP revenue for a date range for a specific app inclusive. 
 * @BUNDLEID   - the bundle ID or package name of the app
 * @PLATFORM    - the platform of the app (ios, andorid, amazon)
 * @START_DATE  - the start of the date range
 * @END_DATE    - the end of the date range
*/
SELECT SUM(revenue)/100.0 AS revenue
FROM events
WHERE bundle_id = '@BUNDLEID'
  AND platform = '@PLATFORM'
  AND date_trunc('day', created_at) >= '@START_DATE'
  AND date_trunc('day', created_at) <= '@END_DATE';