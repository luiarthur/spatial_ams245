library(rcommon)
library(sqldf)
library(maps)
source('plotPerCounty.R')

### Entire Data ###
dat <- read.csv('../dat/annual_all_2015.csv')
site <- read.csv('../dat/aqs_sites.csv')

### Counts of All States ###
all_states <- sqldf('
  SELECT `State.Name`, COUNT(*) AS Counts
  FROM (
    SELECT `State.Name` FROM dat
    WHERE
      `Parameter.Name`="Ozone" AND
      `Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
      `Pollutant.Standard`="Ozone 8-Hour 2008"
    GROUP BY 
      `State.Code`, `County.Code`, `Site.Num`, `POC`
  )
  GROUP BY `State.Name`
')

### Assert that California has > 100 observation stations ###
stopifnot(all_states[which(all_states$State == "California"), "Counts"] > 100)

### Make sure I'm doing this right ###
#`State.Name` IN ("Washington","Oregon")
#`State.Name` IN ("Pennsylvania", "Ohio", "New York")
# Matt Heiner got 112, I'm getting 115
sqldf('
  SELECT SUM(COUNTS) FROM all_states
  WHERE
    `State.Name` IN ("Wyoming", "Idaho", "Montana", "Utah", "Colorado")
')


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

### CA Site Data ###
site_ca <- sqldf('
  SELECT 
    `State.Name`,
    `County.Name`,
    `County.Code`,
    `Site.Number`,
    `Elevation`
  FROM site
  WHERE
    `State.Name`="California" AND `State.Code`="06"
')

ca_all <- sqldf('
  SELECT ca.*, site_ca.Elevation FROM ca LEFT JOIN site_ca
  WHERE 
    ca.`State.Name` = site_ca.`State.Name` AND
    ca.`County.Name` = site_ca.`County.Name` AND
    ca.`Site.Num` = site_ca.`Site.Number`
')

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
county_means <- sqldf('
  SELECT 
    `County.Name` AS cname, 
    AVG(`Arithmetic.Mean`) AS cmean, 
    COUNT(`County.Name`) AS ccount
  FROM ca 
  GROUP BY `County.Name`
')

plot.per.county(log(county_means$cmean), 'california', county_means$cname, 
                levels=7, measure='log county means', text.name=FALSE)


### Explore location vs altitude ###
hist(ca_all$Arithmetic.Mean)
hist((sqrt(ca_all$Arithmetic.Mean)))
hist(log(sqrt(ca_all$Arithmetic.Mean)))


vars <- cbind(ca_all$Lat, ca_all$Lon, ca_all$Arithmetic.Mean, ca_all$Elevation)
colnames(vars) <- c('Lat', 'Lon', 'Mean', 'Elevation')
my.pairs(vars)


