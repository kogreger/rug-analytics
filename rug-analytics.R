library(dplyr)
library(XML)

# read and parse HTML file of Revolution Analytics' R user group directory
doc.html = htmlTreeParse("http://blog.revolutionanalytics.com/local-r-groups.html",
                         useInternal = TRUE)

# extract all the links to group pages on meetup.com
links <- xpathSApply(doc.html, "//a/@href") %>% 
    as.data.frame(stringsAsFactors = FALSE)
colnames(links) <- c("url")

links %>% 
    filter(grepl("http://www.meetup.com/", url))