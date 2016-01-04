library(dplyr)
library(jsonlite)
library(XML)
source("APIkey.R")

# read and parse HTML file of Revolution Analytics' R user group directory
doc.html = htmlTreeParse("http://blog.revolutionanalytics.com/local-r-groups.html",
                         useInternal = TRUE)

# extract all the links to group pages on meetup.com
links <- xpathSApply(doc.html, "//a/@href") %>% 
    as.data.frame(stringsAsFactors = FALSE)
colnames(links) <- c("url")

links %>% 
    filter(grepl("http://www.meetup.com/", url))

groupName = "Berlin-R-Users-Group"

# fetch data from meetup.com via REST API
APIcall = paste0("https://api.meetup.com/", 
                 groupName, 
                 "?&sign=true&photo-host=public&key=", 
                 APIkey)
data <- fromJSON(APIcall)
