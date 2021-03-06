#clean up the temperature data to prepare for GDD analysis
#all data from site A2
#20 GCMs, downscaled using RCP8.5, 2016-2099

library(lubridate)
library(plyr)
library(dplyr)

setwd('~/Growing-Degree-Days/Raw-MACA-data') #specify own filepath

evens <- seq(2,61362,2) #temps
odds <- seq(1,61362,2) #dates

#start by getting the dates
try <- read.csv('A2_tasmax_bcc-csm1-1_rcp85(K).csv',stringsAsFactors=FALSE)
dates <- as.character(try[7,1])
try <- as.data.frame(try[-c(1:8),])
allData <- data.frame(x=try[odds,1])
names(allData) <- dates

#append csv files together
files = list.files(pattern="*.csv")

for (i in files){
  someDf <- read.csv(i)
  colname <- as.character(someDf[8,1]) #get name before cutting try down
  someDf <- as.data.frame(someDf[-c(1:8),])
  newcol <- data.frame(x=someDf[evens,1])
  names(newcol) <- colname
  allData <- cbind(allData,newcol)
}

#save raw data
#all temperatures still in Kelvin
#upon import, data all saved as chr, need to change all to numeric
setwd('~/Growing-Degree-Days')
write.csv(allData, file="ALLrawTemps.MACA.RCP8.5.Kelvin.csv")

#importing again automatically converts temps to numeric
Temps <- read.csv("ALLrawTemps.MACA.Kelvin.csv") 
str(Temps)

Temps2 <- cbind(Temps[,2],Temps[,3:42]-273.15) #remove count column, convert to Celsius
names(Temps2)[1] <- "Date"

#create a new file for each GCM, name each file, place in new folder
#column for date, max temperature and min temperature in Celsius
for (i in 3:21){
  newfile <- Temps2 %>% select(1,i,i+20)
  #names(newfile) <- c("Date","maxTemp","minTemp")
  filename <- file.path('~/Growing-Degree-Days/Modified-Tmax-Tmin', paste0("tasmin", "_", names(newfile)[2], "csv"))
  write.csv(newfile,file=filename)
}

#note in some cases there may be a need to treat certain files differently due to missing data
#for example, the GCM for bcc-csm-1-1
#because 12/31/99 data is missing, we can create fake data (2 points, 1 day only)
#this way the GDD program will still run, and we can convert back to NAs later
newfile <- Temps2 %>% select(1,2,22)
newfile[30681,2] <- 20 #fake data
newfile[30681,3] <- 3 #fake data
filename <- file.path('~/Growing-Degree-Days/Modified-Tmax-Tmin', paste0("tasmin", "_", names(newfile)[2], "csv"))
write.csv(newfile,file=filename)