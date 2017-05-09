/* Calculate the total IAP revenue for a date range for a specific app inclusive. 
 * @BUNDLE_ID   - the bundle ID or package name of the app
 * @PLATFORM    - the platform of the app (ios, andorid, amazon)
 * @BEGIN_DATE  - the start of the date range
 * @END_DATE    - the end of the date range
*/

SELECT sum(revenue)/100.0
FROM daily_ad_revenue
JOIN publisher_apps
  ON publisher_apps.id = daily_ad_revenue.publisher_app_id
JOIN apps
  ON apps.id = publisher_apps.app_id
WHERE apps.bundle_id = '@BUNDLE_ID'
  AND apps.platform = '@PLATFORM'
  AND daily_ad_revenue.date >= '@BEGIN_DATE'
  AND daily_ad_revenue.date <= '@END_DATE';