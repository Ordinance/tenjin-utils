/* Calculate the total IAP revenue for a date range for a specific app inclusive. 
 * @BUNDLE_ID   - the bundle ID or package name of the app
 * @PLATFORM    - the platform of the app (ios, andorid, amazon)
 * @BEGIN_DATE  - the start of the date range
 * @END_DATE    - the end of the date range
*/
SELECT sum(revenue)/100.0
FROM events
WHERE bundle_id = '@BUNDLE_ID'
  AND platform = '@PLATFORM'
  AND date_trunc('day', created_at) >= '@BEGIN_DATE'
  AND date_trunc('day', created_at) <= '@END_DATE';