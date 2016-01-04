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

# extract respective group names
links %<>% 
    filter(grepl("http://www.meetup.com/", 
                 url)) %>% 
    mutate(groupName = sub("^http://www.meetup.com/([a-zA-Z0-9-]+?)(/.*|)$", 
                           "\\1", 
                           url))

# fetch data from meetup.com via REST API
data <- list()
i <- 1
for(groupName in links$groupName) {
    APIcall = paste0("https://api.meetup.com/", 
                     groupName, 
                     "?&sign=true&photo-host=public&key=", 
                     APIkey)
    json <- fromJSON(APIcall, flatten = TRUE)
    data[[i]] <- c(id = json$id, 
                   name = json$name, 
                   created = json$created, 
                   city = json$city, 
                   country = json$country, 
                   lat = json$lat, 
                   lon = json$lon, 
                   members = json$members)
    i <- i + 1
}

# build user group data frame
userGroups <- data %>% 
    unlist() %>% 
    matrix(nrow = nrow(links), 
           byrow = TRUE) %>% 
    as.data.frame(stringsAsFactors = FALSE)
colnames(userGroups) <- c("id", 
                          "name", 
                          "created", 
                          "city", 
                          "country", 
                          "lat", 
                          "lon", 
                          "members")
userGroups