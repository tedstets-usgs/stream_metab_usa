library(powstreams)
library(streamMetabolizer)
library(plyr)
library(fBasics)

#Elevation files required a little clean-up ahead of importing into R.
#Following sites caused problems importing data, so they were deleted:
#02231254, 03220510, 295554095095093402, 46093912....

#Set working directory
workingDir <- "c:/Users/estets/Documents/R/workSpaces/POWELL_CENTER/stream_metab_usa/sandbox_ted/data/"

#Read elevation data
pre_elev_a <- read.table(paste0(workingDir,"ancillary_data/site_elevation_a.txt"),
      colClasses=c("NULL","character","NULL","NULL","NULL","NULL","NULL","numeric",
        "character","character","character"),sep="\t",header=TRUE,comment.char="#",fill=TRUE)

pre_elev_b <- read.table(paste0(workingDir,"ancillary_data/site_elevation_b.txt"),
      colClasses=c("NULL","character","NULL","NULL","NULL","NULL","NULL","numeric",
        "character","character","character"),sep="\t",header=TRUE,comment.char="#",fill=TRUE)

pre_elev_c <- read.table(paste0(workingDir,"ancillary_data/site_elevation_c.txt"),
      colClasses=c("NULL","character","NULL","NULL","NULL","NULL","NULL","numeric",
        "character","character","character"),sep="\t",header=TRUE,comment.char="#",fill=TRUE)

pre_elev_d <- read.table(paste0(workingDir,"ancillary_data/site_elevation_d.txt"),
      colClasses=c("NULL","character","NULL","NULL","NULL","NULL","NULL","numeric",
        "character","character","character"),sep="\t",header=TRUE,comment.char="#",fill=TRUE)

site_elev <- rbind(pre_elev_a,pre_elev_b,pre_elev_c,pre_elev_d)

#List of site IDs from Science Base for Powell Center work.
sb_sites <- read.csv(paste0(workingDir,"sb_site_names2.csv"),header=TRUE)

site_elev$site_id <- paste0("nwis_",site_elev$site_no)

diel_sites <- na.omit(merge(x=sb_sites, y=site_elev, by="site_id",row.names=FALSE))

for (i in 1:nrow(diel_sites)) {
  oneSiteName <- paste0(diel_sites$site_id[i])
  #Check if data file exists, skip if it does not
  if (file.exists(paste0(workingDir,oneSiteName,".csv")) == "TRUE"){
    oneSiteData <- read.csv(paste0(workingDir,oneSiteName,".csv"), header = TRUE)
    oneSiteData$DatePos <- as.POSIXct(oneSiteData$DateTime, tz="GMT")
    oneSiteData$DateSol <- as.Date(convert_GMT_to_solartime(oneSiteData$DatePos, 
      diel_sites$dec_long_va[i],time.type="apparent solar"))
    bp <- ((1-(2.25577e-5*diel_sites$alt_va[i]))^5.25588)*760
    oneSiteData$o2Sat <- (exp(2.00907 + 3.22014 * (log((298.15-oneSiteData$ts_wtr) / 
                  (273.15 + oneSiteData$ts_wtr))) + 4.0501 * (log((298.15 - oneSiteData$ts_wtr) /
                  (273.15 + oneSiteData$ts_wtr))) ^ 2 + 4.94457 * (log((298.15 - oneSiteData$ts_wtr)/
                  (273.15 + oneSiteData$ts_wtr))) ^ 3 - 0.256847 * (log((298.15 - oneSiteData$ts_wtr)/
                  (273.15 + oneSiteData$ts_wtr))) ^ 4 + 3.88767 * (log((298.15 - oneSiteData$ts_wtr)/
                  (273.15 + oneSiteData$ts_wtr))) ^ 5)) * 1.4276 * bp / 760
    oneSiteData$dO2 <- (1000*oneSiteData$ts_doobs/32) - (1000*oneSiteData$o2Sat/32)
    dailyO2Min <- aggregate(oneSiteData$dO2,list(as.Date(oneSiteData$DateSol)),min,na.rm=T)
    names(dailyO2Min) <- c("solDate","dO2Min")
    dailyO2Max <- aggregate(oneSiteData$dO2,list(as.Date(oneSiteData$DateSol)),max,na.rm=T)
    names(dailyO2Max) <- c("solDate","dO2Max")
    dailyQ <- aggregate(oneSiteData$ts_disch,list(as.Date(oneSiteData$DateSol)),median,na.rm=T)
    names(dailyQ) <- c("solDate","dayQ")
    dailyT <- aggregate(oneSiteData$ts_wtr,list(as.Date(oneSiteData$DateSol)),median,na.rm=T)
    names(dailyT) <- c("solDate","dayT")
    dielSaturation <- merge(x = dailyO2Max, y = dailyO2Min, by = "solDate")
    dielSaturation <- merge(x = dailyQ, y = dielSaturation, by = "solDate")
    dielSaturation <- merge(x = dailyT, y = dielSaturation, by = "solDate")
    dielSaturation$O2Range <- dielSaturation$dO2Max - dielSaturation$dO2Min
    output <- data.frame(diel_sites$site_id[i],dielSaturation)
    #plot(x=log(dielSaturation$dayQ), y=dielSaturation$O2Range)
    #plot(x=dielSaturation$dayT, y=dielSaturation$O2Range)
    write.table(output, paste0(workingDir,"diel_saturation/",diel_sites$site_id[i],"_range.csv"), sep=",", row.names=FALSE, col.names=TRUE)
  }
  else {notExist <- oneSiteName}
}

dielStats <- NULL

dielDir <- "c:/Users/estets/Documents/R/workSpaces/POWELL_CENTER/stream_metab_usa/sandbox_ted/data/diel_saturation/"

for (i in 1:nrow(diel_sites)) {
  dielName <- paste0(diel_sites$site_id[i],"_range.csv")
  if (file.exists(paste0(dielDir,dielName)) == "TRUE"){
    dielData <- read.csv(paste0(dielDir,dielName), header = TRUE)
    diel90 <- quantile(dielData$O2Range,.90,names=FALSE)
    diel50 <- quantile(dielData$O2Range,.50,names=FALSE)
    #dielSkew <- skewness(dielData$O2Range)
    dielMean <- mean(dielData$O2Range,na.rm=TRUE)
    dielStatsLine <- data.frame(site_id=diel_sites$site_id[i],diel90=diel90,diel50=diel50,
          dielMean=dielMean)
    #diel90 <- aggregate(dielData$O2Range,quantile,probs=c(0.90))
    #dielStatsLine <- cbind(diel_sites$site_id[i],diel90)
  }
  else {
    dielStatsLine <- data.frame(site_id=diel_sites$site_id[i],diel90=NA,diel50=NA,dielMean=NA)
  }
  dielStats <- rbind(dielStats,dielStatsLine)
}
dielStats <- subset(dielStats,is.finite(dielStats$dielMean))

par(new=FALSE)
dielStats$rank90 <- rank(dielStats$diel90)
dielStats$rank50 <- rank(dielStats$diel50)
dielStats$rankMean <- rank(dielStats$dielMean)
plot(x=dielStats$rank90,y=dielStats$diel90)
plot(x=dielStats$rank50,y=dielStats$diel50)
plot(x=dielStats$rankMean,y=dielStats$dielMean)



#  output = data.frame(metadata, flux.co2.calc, flux.ch4.calc, GTV.co2.calc, GTV.ch4.calc,mean.r2.co2, mean.r2.ch4)
#  str(output)
#  write.table(output, output.file, sep=",", row.names=FALSE, col.names=TRUE)


#dielSaturation <- function(infile,longitude,elevation){
#  bp <- ((1-(2.25577e-5*elevation))^5.25588)*760
#  ddply(
#    group_by(mutate(infile,
#         Date=as.Date(convert_GMT_to_solartime(as.POSIXct(infile$DateTime,
#          tz = "GMT"),longitude,
#          time.type="apparent solar")), 
#         o2Sat = (exp(2.00907 + 3.22014 * (log((298.15-infile$ts_wtr) / 
#          (273.15 + infile$ts_wtr))) + 4.0501 * (log((298.15 - infile$ts_wtr) /
#          (273.15 + infile$ts_wtr))) ^ 2 + 4.94457 * (log((298.15 - infile$ts_wtr) /
#          (273.15 + infile$ts_wtr))) ^ 3 - 0.256847 * (log((298.15 - infile$ts_wtr) / 
#          (273.15 + infile$ts_wtr))) ^ 4 + 3.88767 * (log((298.15 - infile$ts_wtr) / 
#          (273.15 + infile$ts_wtr))) ^ 5)) * 1.4276 * bp / 760, 
#         dO2 = (1000*infile$ts_doobs/32)-(1000*o2Sat/32)), Date),
#    "Date",
#    summarise,diel_range = max(dO2) - min(dO2), ndays=length(unique(Date)))
    
  #group_by(infile,Date)  
  #ddply(infile,"Date",summarise,diel_range = max(dO2)-min(dO2),ndays=length(unique(Date)))
#}
