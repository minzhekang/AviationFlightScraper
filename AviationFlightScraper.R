library(rvest)
library(dplyr)
library(stringr)

location_of_country <- "Singapore" #Change this for other airports

url <-paste('https://flightplandatabase.com/search?q=',location_of_country, sep="", '&sort=distance')
#removes the spaces inbetween the text
webpage <- tryCatch({read_html(url)}, error=function(err) "Page Error")

page_number <- html_nodes(webpage,'.result-pages')
page_number_digit <- html_nodes(page_number, 'a')
page_latest_page <- html_text(page_number_digit)
page_latest_page <- tail(page_latest_page,1) %>%
  as.numeric()
#sources for the last term
page_latest_page
list_of_pages <- paste(url,sep="",'&page=', 1:page_latest_page)

########################################################################################################################
##Getting Destination##Obtains data from the 1st nth-child which is the waypoints#######################################
page_name_destination_raw <- html_nodes(webpage,'.result-link > span:nth-child(1)') %>%
  html_text()
page_name_desination <- gsub('â†’', 'to', page_name_destination_raw)


##Cycle between 3rd element in the list, however there is a random 'span' which is messing up the sequence##############
#df <- page_name_destination
#length_destination <- length(page_name_destination)
#df[seq(2,length_destination, 3)]


##Getting ID############################################################################################################
page_name_ID <- html_nodes(webpage,'.result-link') %>%
  html_attr('href')

##Cycle through each page to get each id/destination####################################################################
pages <- c("https://flightplandatabase.com/search?q=Singapore&sort=distance&page=420", "https://flightplandatabase.com/search?q=Singapore&sort=distance&page=421")
#pages <- list_of_pages

datalist = list()
datalist2 = list()

for (i in pages){
 
 i2 <- read_html(i)
  page_name_destination_raw1 <- html_nodes(i2,'.result-link > span:nth-child(1)') %>%
    html_text()
  page_name_desination1 <- gsub('→', 'to', page_name_destination_raw1)
  
  page_name_ID1 <- html_nodes(i2,'.result-link') %>%
    html_attr('href')
  
  dat <- data.frame(page_name_desination1, page_name_ID1)
  dat2 <- data.frame(page_name_ID1)
  datalist[[i]] <- dat # add it to your list
  datalist2[[i]] <- dat2
  print(i) #shows progress
}

data_of_ID = dplyr::bind_rows(datalist2) #convert into a table form and bind them
data_of_ID2 = dplyr::pull(data_of_ID, page_name_ID1) #convert into vector file
data_of_IDandDestination = dplyr::bind_rows(datalist) #bind them together
colnames(data_of_IDandDestination) <- c("Destination", "Plan ID")

#pages_ID <- c("https://flightplandatabase.com/plan/32042", "https://flightplandatabase.com/plan/55815")
data_of_URLandID <- cbind(paste("https://flightplandatabase.com",sep = "", data_of_ID2))
pages_ID <- data_of_URLandID

datalist3 = list()

#Prof Peter's Code #Modified
for (j in pages_ID){
  j2 <- read_html(j)
  body <- html_nodes(j2,'body')
  planRouteTable <- html_nodes(body,'table.plan-route-table')
  planRouteRawRows <- html_nodes(planRouteTable,"tr")
  planRouteRawRows2 <- html_nodes(planRouteRawRows,"td") %>%
    html_text()
    dat3 <- as.data.frame(split(planRouteRawRows2, 1:8))
    dat4<- mutate(dat3,  j)
    
    datalist3[[j]] <- dat4
    print(j)
  }
data_of_waypoints = dplyr::bind_rows(datalist3)
colnames(data_of_waypoints) <- c("Start","ID", "Type","Via","Altitude(ft/m)", "Position (lat/long)", "Distance (leg/total)" , "Name" , "URL")

write.csv(data_of_waypoints, file = paste(location_of_country , "Routes.csv"))
write.csv(data_of_IDandDestination, file = paste(location_of_country , "ID&Desination.csv"))

##Min Zhe