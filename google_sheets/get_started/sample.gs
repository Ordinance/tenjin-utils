/* This is a sample script to pull data from Tenjin rest API in Google spreadsheet
*  1) On the spredsheet, go to Tools -> Script editor, and copy the entire script below and paste.
*  2) Creaete "credential" sheet, and set your email address and API key in cell B1 and B2 and set start_date and end_date in YYYY-MM-DD format in cell B3 and B4.
*  3) Create "output" sheet. The result will be shown in this sheet.
*  4) Run the script by ▼Script -> Get Tenjin Data
*/

function myFunction() {

  var key_sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("credential");
  
  var email = key_sheet.getRange("B1").getValue(); // email address
  var token = key_sheet.getRange("B2").getValue(); // authentication token(https://www.tenjin.io/dashboard/api_documentation)
  var sheet = 'output'; // sheet name you want to get data in

  var s = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheet);
  var LastRow = s.getLastRow();
  if(LastRow >= 1) s.getRange(1,1,LastRow,11).clearContent();
  
  var options = {
    "headers" : {"Authorization" : " Basic " + Utilities.base64Encode(email + ":" + token)}
  };

  var start_day = key_sheet.getRange("B3").getValue();
  var end_day = key_sheet.getRange("B4").getValue();

  var response = UrlFetchApp.fetch("https://reports.tenjin.io/api/v0/campaign_aggregate?start_day=" + start_day + "&end_day=" + end_day + "&page=1", options);
  var total_pages = 0;

  if (response.getResponseCode() == 200) {
   
    var params = JSON.parse(response.getContentText());
    total_pages = params.total_pages;

    // Set header
    var header_array = ["day","ad_network","app_id","store_id","bundle_id","platform","campaign_name","impressions","clicks","downloads","spend"]
    var header_array2 = [];
    header_array2[0] = header_array
    var headerRange = s.getRange(1, 1, 1, 11);
    headerRange.setValues(header_array2);

    var length = 0;

    for (var i = 0 ; i < total_pages ; i++) {
      
      var response = UrlFetchApp.fetch("https://reports.tenjin.io/api/v0/campaign_aggregate?start_day=" + start_day + "&end_day=" + end_day + "&page=" + i, options);
      var params = JSON.parse(response.getContentText());
      var array2 = [];

      for (var j = 0 ; j < params.data.length ; j++) {
        
        var array = [];
        array[0] = params.data[j].day;
        array[1] = params.data[j].ad_network;
        array[2] = params.data[j].app_id;
        array[3] = params.data[j].store_id;
        array[4] = params.data[j].bundle_id;
        array[5] = params.data[j].platform;
        array[6] = params.data[j].campaign_name;
        array[7] = params.data[j].impressions;
        array[8] = params.data[j].clicks;
        array[9] = params.data[j].downloads;
        array[10] = params.data[j].spend;
        
        array2[j] = array;
      };
      var destinationRange = s.getRange(length + 2, 1, j, 11);
      destinationRange.setValues(array2);
      length = length + j;
    };
    
  }
}

function onOpen() {
   var ss = SpreadsheetApp.getActiveSpreadsheet();
   var menuEntries = [ {name: "Get Tenjin data", functionName: "myFunction"} ];
   ss.addMenu("▼Script", menuEntries);
}