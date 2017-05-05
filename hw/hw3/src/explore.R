library(sqldf)
library(maps)
source('plotPerCounty.R')

# Example:
#bla <- sqldf::read.csv.sql("../dat/tmp.csv", 
#                           sql= "select * from file where `State.Name`='UT'")

### Entire Data ###
dat <- read.csv('../dat/annual_all_2015.csv')

### California Data ###
#ca <- dat[which(dat$State.Name=='California'),]

ca <- sqldf('SELECT * from dat where `State.Name`=
            "California" || `State.Name`="Nevada"')
area <- sqldf('SELECT from dat where `State.Name`="California" OR `State.Name`="Nevada"')
distinct_area <- sqldf('SELECT DISTINCT `State.Code`, `County.Code`, `Site.Num` from dat')


### Number of Sites in CA ###
length(unique(ca$Site.Num))
length(unique(cbind(area$State.Code, area$County.Code, area$Site.Num), MARGIN=1))

### Explore  ###
hist(ca$Arithmetic.Mean)
hist(ca$X50)

### Maps ###
s <- ca[c('Latitude', 'Longitude')]
counties <- as.character(unique(ca$County.Name))
state_county <- tolower(paste0('California,', counties))

### Check all counties in data can be mapped ###
map('county', 'California', col='transparent')
for (i in 1:length(state_county)) {
  map('county', state_county[i], names=TRUE, fill=TRUE, add=TRUE,
      border='white', col=rgb(1,0,0,.5))
}
### 


### Compute Means ###
county_means <- sapply(counties, function(county) {
       idx <- which(ca$County.Name == county)
       mean(ca$Arithmetic.Mean[idx])
    })

plot.per.county(log(county_means), 'california', counties, 
                measure='log county means', text.name=FALSE)

