# Tenjin utils package
This project provides out of the box templates for modeling data on any of Tenjin's hosted data warehouses. The goal is to help marketers and data scientists learn and re-use common techniques that are applicable for understanding their mobile app users.

Getting started
----
Pick from one of your favorite tools to analyze your DataVault data. Customers use tools and languages set up with Python, SQL, R, and many others. 

Using the credentials provied to you in your <a href="https://www.tenjin.io/dashboard/data_vault">Tenjin dashboard</a> you can directly use your appropriate Redshift driver/connector for your tool to use DataVault.

Each of the folders in `tenjin-utils` will be dedicated to a specific language that you can use in the tool of your choice.

Documentation and Help
----
For reference to the schema of your standard DataVault please contact support@tenjin.io or visit the <a href="http://help.tenjin.io/">Tenjin help forums</a>.

Scheme
----
![scheme](https://gist.github.com/lepfhty/a24fa79adb011c2b52ae8e79e1854f9d/raw/eea4358a93193fb677358130b30b92cecabe5a12/tenjin-schema.png)

Table description
----
* events
    * device level data that comes from Tenjin SDK or 3rd party attribution provider
* campaigns
    * campaigns that users are attributed to, or campaigns from ad-networks API
* ad_networks
    * list of ad networks
* apps
    * list of apps
* daily_spend
    * includes pre-install metrics(such as imps, clicks, installs, and spend) by campaign and date. “spend” is spend amount converted to USD, and “original_spend” is spend amount in “original_currency”
* daily_country_spend
    * Includes pre-install metrics(such as imps, clicks, installs, and spend) by date, campaign, and country. “spend” is spend amount converted to USD, and “original_spend” is spend amount in “original_currency”
    * Only for ad-networks that have spend by country. Some ad-networks don’t have spend by country breakdown. So daily_country_spend contains partial spend of daily_spend
* daily_behavior
    * Pre-aggregated view from events table. It includes non-cohort metrics(such as dau, arpdau) by date, campaign, country, and site
* cohort_behavior
    * Pre-aggregated view from events table. It includes cohort metrics(such as ltv, retained users) by date, campaign, country, and site
    *“xday” is day of life (relative to acquisition timestamp, starting with 0). So “revenue” on xday = 1 means revenue generated on day 1 after the acquisition
* publisher_apps
    * publisher campaigns that we get from ad-network API
* daily_ad_revenue
    * includes ad revenue data by publisher campaigns, date, and country
* ad_engagements
    * includes click or impression data for each device. It only has data for non-self attributing ad-networks. We don’t have data for Google or Facebook.
  
Contributing
----
To use and contribute to `tenjin-utils`, follow the steps below:
  1. Fork the `tenjin-utils` project using your Github username
  2. Make any changes to your local `tenjin-utils` project that you would like to contribute
  3. Submit a Pull Request to `tenjin/tenjin-utils` master with your changes
  4. A Tenjin admin will review your request. If it looks good, it gets merged!
  5. That's it!
