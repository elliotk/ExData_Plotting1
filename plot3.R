#!/usr/bin/env Rscript

# Usage:
# $ Rscript plot3.R

## 0. Download data ---------------------------

# Data dir exist?
if (!file.exists("data")) {
    dir.create("data")
}

# Set File Url
file.url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"

# Set data dir
data.directory <- "./data"

# Set data file name
file.name <- "dataset.zip"

# Set path/to/data file 
data.file <- file.path(data.directory, file.name)

# Download file
download.file(file.url, destfile = data.file, method = "curl")

# Record date downloaded
date.downloaded <- date()

# Extract zip archive file
unzip(data.file, exdir = data.directory)

## 1. Read data ---------------------------

# Set path to data file
dataset.file <- file.path(data.directory, "household_power_consumption.txt")

# Set path to subset data file
subset.file <- file.path(data.directory, "subset_data.txt")

# Read dataset file and subset
f <- file(dataset.file)
open(f)
while (length(line <- readLines(f, n = 1)) > 0) {
    a <- grep('^(1|2)\\/2\\/2007', line, value = TRUE, perl = TRUE)
    if (length(a) == 1) {
        write(a, file = subset.file, append = TRUE)
    }
}
close(f)

# Read subset file
colClasses <- c(rep("character", 2), rep("numeric", 7))
my.frame <- read.table(file = subset.file, sep = ";", colClasses = colClasses)

field.names <- c("Date",
                 "Time",
                 "Global_active_power",
                 "Global_reactive_power",
                 "Voltage",
                 "Global_intensity",
                 "Sub_metering_1",
                 "Sub_metering_2",
                 "Sub_metering_3")

# Set field names
names(my.frame) <- field.names

# Set Time field
time <- paste(my.frame$Date, my.frame$Time)
my.frame$Time <- strptime(time, "%d/%m/%Y %H:%M:%S")

# Set Date Field
my.frame$Date <- as.Date(my.frame$Date, "%d/%m/%Y")

# Remove subset data file since each run will append to file 
if (file.exists("./data/subset_data.txt")) {
    file.remove("./data/subset_data.txt")
}

## 2. Plot data ---------------------------

# Figure dir exist?
if (!file.exists("figure")) {
    dir.create("figure")
}

# Set figure dir
plot.directory <- "./figure"

# Plot3
# Set plot file name
plot.name <- "plot3.png"

# Set path/to/plot file 
plot.file <- file.path(plot.directory, plot.name)

# Set device
png(file = plot.file)

# Plot
plot(my.frame$Time,
     my.frame$Sub_metering_1,
     type = "l",
     xlab = "",
     ylab = "Energy sub metering")
lines(my.frame$Time, my.frame$Sub_metering_2, type = "l", col = "red")
lines(my.frame$Time, my.frame$Sub_metering_3, type = "l", col = "blue")
legend("topright", legend = names(my.frame)[7:9], lty=c(1, 1, 1), col = c("black", "red", "blue"))

# Close device
dev.off()
