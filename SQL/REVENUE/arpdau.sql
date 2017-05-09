/* Calculate the ARPDAU of event revenue for a specific date. 
 * @BUNDLE_ID   - the bundle ID or package name of the app
 * @PLATFORM    - the platform of the app (ios, andorid, amazon)
 * @DATE        - the date of the calculation
*/

SELECT sum(revenue)/100.0 / count(distinct(advertising_id))
FROM events
WHERE created_at::date = '@DATE'
  AND bundle_id = '@BUNDLE_ID'
  AND platform = '@PLATFORM';