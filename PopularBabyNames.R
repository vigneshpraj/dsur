#http://www.ssa.gov/OACT/babynames/limits.html

#http://www.ssa.gov/OACT/babynames/names.zip
#http://www.ssa.gov/OACT/babynames/state/namesbystate.zip



download.data <- function(url, filename) {
    if(!file.exists(file.path(dataDir, filename))) {
        download.file(url = paste(url, filename, sep = '/'),
                      destfile = file.path(dataDir, filename))
        unzip(file.path(dataDir, filename), exdir = dataDir)
    }
}

if (!dir.exists(dataDir)) {
    dir.create(dataDir)
}

url <- 'http://www.ssa.gov/OACT/babynames'
dataDir <- file.path('data', 'ssa.gov')

download.data(url, 'names.zip')
download.data(paste(url, 'state', sep = '/'), 'namesbystate.zip')

library(dplyr)
#library(plyr)
#yob <- ldply(flist[grep('yob.*\\.txt', flist)], read.csv, header = F)

if(!exists('yob')){
    flist <- list.files(dataDir, full.names = T)
    flist.yob <- flist[grep('yob.*\\.txt', flist)]

    yob <- NULL
    col.names <- c('name', 'sex', 'occurrence')
    colClasses <- c('character', 'factor', 'integer')
    for (f in flist.yob) {
        print(substr(f, 17, 17 + 3))
        temp <- read.csv(f[1],
                         header = F,
                         col.names = col.names,
                         colClasses = colClasses)
        temp$year <- rep(as.integer(substr(f, 17, 17 + 3)), nrow(temp))
        yob <- rbind(yob, temp)
    }
    yob$year <- as.ordered(yob$year)
}

n <- 'Margaret'; s <- 'F'; birthYear <- 1999
x <- filter(yob, grepl(paste0(n,'$'), name), sex==s) %>% select(year, occurrence)
x$year <- as.integer(as.character(x$year))
with(x, plot(year, occurrence, type='l',
             xlab='Birth Year',
             ylab=paste('No. of Babies named', n),
             main=paste0('Hello, ', n, '.')))
points(subset(x, year==birthYear), col='blue', pch=19, cex=2)
points(subset(x, occurrence==max(occurrence)), col='red', cex=2)

