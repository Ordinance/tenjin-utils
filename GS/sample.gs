/* This is a sample script to pull data in 6/1-30 from Tenjin rest API in Google spreadsheet.
*  1. Replace @email and @token as your own.
*  2. Go to Tools -> Script editor in the spreadsheet, and copy the entire script below and paste.
*  3. Then you can run the script by Script -> Get Tenjin Data.
*/

function myFunction() {
  
  var email = "@email"; // email address
  var token = "@token"; // authentication token(https://www.tenjin.io/dashboard/api_documentation)
  var sheet = "Sheet1"; // sheet name you want to get data in

  var s = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheet);
  s.clearContents();
  
  var options = {
    "headers" : {"Authorization" : " Basic " + Utilities.base64Encode(email + ":" + token)}
  };

  var response = UrlFetchApp.fetch("https://reports.tenjin.io/api/v0/campaign_aggregate?start_day=2016-06-01&end_day=2016-06-30&page=1", options);

  if (response.getResponseCode() == 200) {
    
    var params = JSON.parse(response.getContentText());
    var array2 = [];
    
    var array = ["day","ad_network","app_id","store_id","bundle_id","platform","remote_campaign_id","campaign_name","tenjin_campaign_id","impressions","clicks","downloads","spend"];
    array2[0] = array;
    
    for (var i = 0 ; i < params.data.length ; i++) {
      var array = [];
      array[0] = params.data[i].day;
      array[1] = params.data[i].ad_network;
      array[2] = params.data[i].app_id;
      array[3] = params.data[i].store_id;
      array[4] = params.data[i].bundle_id;
      array[5] = params.data[i].platform;
      array[6] = params.data[i].remote_campaign_id;
      array[7] = params.data[i].campaign_name;
      array[8] = params.data[i].tenjin_campaign_id;
      array[9] = params.data[i].impressions;
      array[10] = params.data[i].clicks;
      array[11] = params.data[i].downloads;
      array[12] = params.data[i].spend;

      array2[i+1] = array;
    };
  
    var destinationRange = s.getRange(1, 1, params.data.length+1, 13);
    destinationRange.setValues(array2);
    
  }
}

function onOpen() {
   var ss = SpreadsheetApp.getActiveSpreadsheet();
   var menuEntries = [ {name: "Get Tenjin data", functionName: "myFunction"} ];
   ss.addMenu("▼Script", menuEntries);
}
