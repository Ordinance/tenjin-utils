/*
* This script allows you to calculate the number of events that you sent to your database
* @START_DATE => the beginning date you want to start counting your events
* @END_DATE => the end date you want to end your counting of events
*/

SELECT COUNT(*)
FROM raw_events
WHERE created_at::DATE >= '@START_DATE'
  AND created_at::DATE < '@END_DATE';