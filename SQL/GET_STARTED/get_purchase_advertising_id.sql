/* This is a query to generate the list of advertising ID who has made in-app purchase before
@DATE => refers to the date that you want to get the list for.
@BUNDLEID => bundle_id for your app
revenue => in USD cents
*/

SELECT
	a.bundle_id
	, a.platform
	, a.advertising_id
	, c.name AS channel
	, a.acquired_at
	, a.revenue
FROM (
	SELECT
		bundle_id
		, platform
		, advertising_id
		, source_campaign_id
		, acquired_at::DATE
		, SUM(revenue) AS revenue
	FROM events
	WHERE
		acquired_at::DATE >= @DATE
		AND bundle_id = @BUNDLEID
		AND event_type = 'purchase'
	GROUP BY
		bundle_id
		, platform
		, advertising_id
		, source_campaign_id
		, acquired_at::DATE
	HAVING SUM(revenue) > 0
) a
LEFT OUTER JOIN campaigns b
ON a.source_campaign_id = b.id
LEFT OUTER JOIN ad_networks c
ON b.ad_network_id = c.id
;