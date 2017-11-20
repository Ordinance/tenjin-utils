/* Calculate the % of tracked users for each attribution type(impression or click)
 * date range is 2017/11/9 to 2017/11/16 as an example. Feel free to change.
 * @BUNDLEID is the bundle_id or package name of your app
 * @PLATFORM is the platform of your app
 * @AD_NETWORK_NAME is the ad network that you're trying to analyze - if you're analyzing Applovin attribution you can use 'applovin'
 */
select
  case when sq2.event_type = 'impression' and datediff('sec', sq2.created_at, sq1.acquired_at) < 3600 and datediff('sec', sq2.created_at, sq1.acquired_at) > 0 then 'impression'
       else 'click'
       end as attribution_type,
  count(distinct coalesce(sq1.advertising_id, sq1.developer_device_id)) as tracked_installs
from (
  select advertising_id, developer_device_id, acquired_at, ad_network_id
  from events e
  left outer join campaigns c
  on e.source_campaign_id = c.id
  left outer join ad_networks an
  on c.ad_network_id = an.id
  where e.bundle_id = '@BUNDLEID' and e.platform = '@PLATFORM' and an.name = '@AD_NETWORK_NAME' and event = 'open'
  and acquired_at >= '2017-11-09' and acquired_at < '2017-11-16'
  group by 1,2,3,4
) sq1
left outer join (
  select ae.*
  from (
    select advertising_id, event_type, created_at, rank() over (partition by advertising_id order by event_type asc, created_at desc) as rank
    from ad_engagements ae
    left outer join campaigns c
    on ae.campaign_id = c.id
    left outer join ad_networks an
    on c.ad_network_id = an.id
    where ae.bundle_id = '@BUNDLEID' and ae.platform = '@PLATFORM' and an.name = '@AD_NETWORK_NAME' and created_at >= '2017-10-01'
  ) ae
  where ae.rank = 1
) sq2
on sq1.advertising_id = sq2.advertising_id
group by 1
