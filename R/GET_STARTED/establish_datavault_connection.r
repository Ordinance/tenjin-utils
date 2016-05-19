#This script assumes that you installed the library from https://github.com/pingles/redshift-r
#PURPOSE: connect to DataVault to use R

require('redshift')

host <- "[YOUR_HOST_NAME]"
port <- "5439"
database <- "YOUR_DATABASE_NAME"
user <- "YOUR_USERNAME"
password <- "YOUR_PASSWORD"

url <- paste("jdbc:postgresql://", host, ":", port, "/", database, sep="")
conn <- redshift.connect(url, user, password)

#once you establish a connection to your DataVault you can start querying and manipulating data
advertisingids <- dbGetQuery(conn, "SELECT advertising_id FROM events LIMIT 10")
