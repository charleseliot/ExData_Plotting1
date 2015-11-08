# Check that R has enough available memory to load the entire dataset

available.mem <- memory.limit() - memory.size()
approx.required.mem <- 2100000 * 8 * 10 / (2^20)
message(paste("available mem",sprintf("%.1f MB",available.mem)))
message(paste("required mem ~",sprintf("%.1f MB",approx.required.mem)))

if (available.mem < approx.required.mem){
    # If this ever happens, we need to take a different approach. For example,
    # the following code can be used to filter the data file in situ before
    # importing it:
    #
    #     system2("grep", 
    #             args=c("\"^1/2/2007\\|^2/2/2007\\|^Date\"","household_power_consumption.txt"),
    #             stdout="selected_data.txt")
    
    warning("NOT ENOUGH MEMORY TO LOAD DATASET!")
    stop()
}

# Read in the raw data

all_data <- read.table("household_power_consumption.txt",
                       header=TRUE,
                       sep=";",
                       stringsAsFactors = FALSE,
                       colClasses=c("character","character",replicate(7,"numeric")),
                       na.strings="?")

# Filter down to the two desired dates

y <- all_data[all_data$Date == "1/2/2007" | all_data$Date == "2/2/2007",] 

# Convert Date and Time columns to one Date column in POSIXlt format

DateTime <- paste(y$Date,y$Time)
y$Date <- strptime(DateTime, "%d/%m/%Y %H:%M:%S")

# Make graph

png(file="plot3.png", width=480, height=480)

with(y,
     {
         plot(Date,
              Sub_metering_1,
              type="n",
              xlab="",
              ylab="Energy sub metering")
         
         lines(Date, Sub_metering_1, type="l", col="black")
         lines(Date, Sub_metering_2, type="l", col="red")
         lines(Date, Sub_metering_3, type="l", col="blue")
         
         legend("topright",
                col = c("black", "red", "blue"),
                legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
                lwd = 1
         )
     }
     )

dev.off()
