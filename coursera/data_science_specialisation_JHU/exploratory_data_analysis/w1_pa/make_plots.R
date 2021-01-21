# Downloading the data
fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
temp <- tempfile(); download.file(fileURL,temp)
file.copy(from = temp, to = paste0(getwd(),"/raw_data.zip")) # download zip file as raw_data.zip
unlink(temp) # delete the temp file or use file.remove(temp)
unzip("raw_data.zip") # unzip the raw_data.zip as "household_power_consumption.txt"

# Loading the data
data <- read.table("household_power_consumption.txt", sep=";", header=TRUE, na.strings=c("NA", " ", "?"))
# Convert Date to Date class
data$Date <- format(as.Date(data$Date, "%d/%m/%Y"))
# Convert Time to Time class
#library(lubridate); data$Time <- hms(data$Time)
data$Time <- format(strptime(data$Time, "%H:%M:%S"),"%H:%M:%S")

# Subsetting data for dates dates 2007-02-01 and 2007-02-02
subdata <- subset(data, data$Date == "2007-02-01" | data$Date == "2007-02-02")
subdata$DateTime <- as.POSIXct(paste(subdata$Date, subdata$Time))
active_power <- as.numeric(subdata$Global_active_power)

# Making plots
# plot 1
png(filename = "plot1.png", width = 480, height = 480, units = "px")
par(bg=NA)
hist(subdata$Global_active_power, col="red", xlab="Global Active Power (killowatts)",
     main="Global Active Power")
dev.off()
# plot 2
png(filename = "plot2.png", width = 480, height = 480, units = "px")
par(bg=NA)
plot(subdata$DateTime, active_power, type="l", xlab="", ylab="Global Active Power (kilowatts)")
dev.off()
# plot 3
png(filename = "plot3.png", width = 480, height = 480, units = "px")
par(bg=NA)
plot(subdata$DateTime, subdata$Sub_metering_1, type = "l", xlab = "", ylab = "Energy sub metering")
lines(subdata$DateTime, subdata$Sub_metering_2, type = "l", col = "red")
lines(subdata$DateTime, subdata$Sub_metering_3, type = "l", col = "blue")
legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       lwd = 2.5, col = c("black", "red", "blue"))
dev.off()
# Or use points
png(filename = "plot3.png", width = 480, height = 480, units = "px")
par(bg=NA)
plot(subdata$DateTime, subdata$Sub_metering_1, type = "l", xlab = "", ylab = "Energy sub metering")
points(subdata$DateTime, subdata$Sub_metering_2, type = "l", col = "red")
points(subdata$DateTime, subdata$Sub_metering_3, type = "l", col = "blue")
legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       lwd = 2.5, col = c("black", "red", "blue"))
dev.off()
# plot 4
png(filename = "plot4.png", width = 480, height = 480, units = "px")
par(mfrow = c(2,2), mar = c(4,4,2,1), bg=NA)
plot(subdata$DateTime, subdata$Global_active_power, type = "l",
     xlab = "", ylab = "Global Active Power")
plot(subdata$DateTime, subdata$Voltage, type = "l", xlab = "datetime", ylab = "Voltage")
plot(subdata$DateTime, subdata$Sub_metering_1, type = "l", xlab = "", ylab = "Energy sub metering")
lines(subdata$DateTime, subdata$Sub_metering_2, type = "l", col = "red")
lines(subdata$DateTime, subdata$Sub_metering_3, type = "l", col = "blue")
legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       lwd = 2.5, col = c("black", "red", "blue"))
plot(subdata$DateTime, subdata$Global_reactive_power, type = "l", 
     xlab = "datetime", ylab = "Global_reactive_power")
dev.off()
