/*
* This funtion lets you calculate 90-day LTV by app. You can replace the 
* acquired_at::date and the values in the CASE block to calculate different x-days for your app.
* In this query we GROUP BY by bundle_id/platform to insure app uniqueness and also aggregate/SUM revenue only when the
* difference in time between the event (created_at) and the acquired install time (acquired_at) is <= 90days.
*/

SELECT bundle_id
  , platform 
  , SUM(CASE WHEN date_diff('sec', acquired_at, created_at)/86400 <= 90 THEN revenue/100.0 END) AS revenue_90_day
FROM events
WHERE acquired_at::date >= '2015-10-01'
GROUP BY bundle_id
  , platform
;