/* This is a query to calculate click to install time(secs) for each ad-network
@DATE => refers to the date that you want to see the data for.
@BUNDLEID => bundle_id of your app
@PLATFORM => platform of your app
*/
SELECT e.name as ad_network_name, datediff(sec, clicked_at, acquired_at) as diff, count(*) as count 
FROM (
  SELECT an.name, e.source_campaign_id, advertising_id, min(acquired_at) as acquired_at
  FROM events e
  LEFT JOIN campaigns c
  ON e.source_campaign_id = c.id
  LEFT JOIN ad_networks an
  ON c.ad_network_id = an.id
  WHERE e.event = 'open' AND c.ad_network_id != 0 AND created_at >= '@DATE' AND bundle_id = '@BUNDLEID' AND platform = '@PLATFORM'
  GROUP BY 1,2,3
) AS e
JOIN (
  SELECT advertising_id, campaign_id, max(created_at) as clicked_at
  FROM ad_engagements 
  WHERE event_type = 'click' AND created_at >= '@DATE' AND bundle_id = '@BUNDLEID' AND platform = '@PLATFORM'
  GROUP BY 1,2
) AS ae
ON e.source_campaign_id = ae.campaign_id AND e.advertising_id = ae.advertising_id
WHERE datediff(sec, clicked_at, acquired_at) >= 0 AND datediff(sec, clicked_at, acquired_at) <= 120
GROUP BY 1,2
