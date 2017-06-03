### Read CA Data ###
source("readDat.R", chdir=TRUE)

### Maps ###
s <- as.matrix(ca[c('Latitude', 'Longitude')])
counties <- as.character(unique(ca$County.Name))
state_county <- tolower(paste0('California,', counties))

### Name Variables ###
y <- ca$Arithmetic.Mean * 1000
X <- cbind(1, new_vars[, c("Longitude", "log(Elevation)")])
colnames(X) <- c("intercept", "Longitude", "Log Elevation")
set.seed(1)

pdf('../tex/img/map.pdf')
map('county', 'california')
quilt.plot(ca$Lon, ca$Lat, y, add=TRUE)
dev.off()


