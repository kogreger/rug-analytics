library(dplyr)
library(httr)
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

# extract respective group names
links %<>% 
    filter(grepl("http://www\\.meetup\\.com/", 
                 url)) %>% 
    mutate(groupName = sub("http://www\\.meetup\\.com(/[a-z]{2}/|/)([a-zA-Z0-9-]+?)(/.*|)$", 
                           "\\2", 
                           url, 
                           perl = TRUE))

# fetch data from meetup.com via REST API and build user group data frame
userGroups <- data.frame(id = integer(), 
                         name = character(), 
                         created = integer(), 
                         city = character(), 
                         country = character(), 
                         lat = numeric(), 
                         lon = numeric(), 
                         members = integer(), 
                         stringsAsFactors = FALSE)
for(groupName in links$groupName) {
    APIcall = paste0("https://api.meetup.com/", 
                     groupName, 
                     "?&sign=true&photo-host=public&key=", 
                     APIkey)
    json <- list()
    try({    # to account for dead links
        json <- fromJSON(APIcall)
        json <- json %>% 
            as.data.frame %>% 
            select(id, 
                   name, 
                   created, 
                   city, 
                   country, 
                   lat, 
                   lon, 
                   members) %>% 
            head(1)    # only one instance per group out of df'ed JSON list
        userGroups <- rbind(userGroups, json)
        })
}

# output result
plot(userGroups$members)
userGroups