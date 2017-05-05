library(sqldf)
library(maps)
source('plotPerCounty.R')

### Entire Data ###
dat <- read.csv('../dat/annual_all_2015.csv')

### California Data ###
ca <- sqldf('
  SELECT * FROM dat
  WHERE
    `State.Name` IN("California") AND
    `Parameter.Name`="Ozone" AND
    `Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
    `Pollutant.Standard`="Ozone 8-Hour 2008"
')
dim(ca)

### Assert that California has enough observatsions ###
distinct_area <- sqldf('
  SELECT 
    `State.Code`,  `County.Code`, `Site.Num`, `Observation.Count`
  FROM ca
  GROUP BY 
    `State.Code`,  `County.Code`, `Site.Num`
')
dim(distinct_area)
stopifnot(nrow(distinct_area) > 100)

### Counts of All States ###
all_states <- sqldf('
  SELECT `State.Name`, COUNT(*) AS COUNTS
  FROM (
    SELECT `State.Name` FROM dat
    WHERE
      `Parameter.Name`="Ozone" AND
      `Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
      `Pollutant.Standard`="Ozone 8-Hour 2008"
    GROUP BY 
      `State.Code`,  `County.Code`, `Site.Num`
  )
  GROUP BY `State.Name`
')

#`State.Name` IN ("Washington","Oregon")
#`State.Name` IN ("Wyoming", "Idaho", "Montana", "Utah", "Colorado")
#`State.Name` IN ("Pennsylvania", "Ohio", "New York")
#sqldf('
#  SELECT SUM(COUNTS) FROM all_states
#  WHERE
#    `State.Name` IN ("Pennsylvania", "Ohio", "New York")
#')

### Number of Sites in CA ###
#length(unique(ca$Site.Num))

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

