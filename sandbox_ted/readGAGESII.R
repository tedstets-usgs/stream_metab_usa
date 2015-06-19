dielGages <- NULL

gagesIIDir <- "c:/DATASAVE/weasel/GAGESII/"

#################
#1. Hydro
#################
hydroColClasses <- c("character",rep("numeric",33))
contermHydro <- read.table(paste0(gagesIIDir,"conterm_hydro.txt"),colClasses=hydroColClasses,
    header=TRUE,sep=",")
contermHydro$site_id <- as.factor(paste0("nwis_",contermHydro$STAID))
dielGages <- merge(x=dielStats,y=contermHydro,by="site_id",all.x=TRUE,all.y=FALSE,na.rm=TRUE)

#################
#2. 100m Mainstem Riparian
#################
lc06_100ColClasses <- c("character",rep("numeric",19))
contermLC06_100 <- read.table(paste0(gagesIIDir,"conterm_lc06_mains100.txt"),
  colClasses=lc06_100ColClasses,header=TRUE,sep=",")
contermLC06_100$site_id <- as.factor(paste0("nwis_",contermLC06_100$STAID))
dielGages <- merge(x=dielGages,y=contermLC06_100,by="site_id",all.x=TRUE,all.y=FALSE,na.rm=TRUE)

#################
#3. Climate
#################
climateColClasses <- c("character",rep("numeric",49))
contermClimate <- read.table(paste0(gagesIIDir,"conterm_climate.txt"),
  colClasses=climateColClasses,header=TRUE,sep=",")
contermClimate$site_id <- as.factor(paste0("nwis_",contermClimate$STAID))
dielGages <- merge(x=dielGages,y=contermClimate,by="site_id",all.x=TRUE,all.y=FALSE,na.rm=TRUE)

#################
#4. NHD Reach Slope
#################
#The data.frame gagesSlopes was created in the script readNHDSlope.R
dielGages <- merge(x=dielGages,y=gagesSlopes,by="site_id",all.x=TRUE,all.y=FALSE)

#################
#5. 800m Mainstem Riparian
#################
LC06_Mains800ColClasses <- c("character",rep("numeric",19))
contermLC06_800 <- read.table(paste0(gagesIIDir,"conterm_lc06_mains800.txt"),
                             colClasses=LC06_Mains800ColClasses,header=TRUE,sep=",")
contermLC06_800$site_id <- as.factor(paste0("nwis_",contermLC06_800$STAID))
dielGages <- merge(x=dielGages,y=contermLC06_800,by="site_id",all.x=TRUE,all.y=FALSE,na.rm=TRUE)

#################
#Create a corrgram with selected variables.
#################
climateVars <- c("diel90","diel50","dielMean","PPTAVG_BASIN","PPTAVG_SITE","T_AVG_BASIN","T_AVG_SITE","RH_BASIN","RH_SITE","PET")
climateCorrelation <- dielGages[climateVars]

#hydroVars <- c("diel90","diel50","dielMean","STREAMS_KM_SQ_KM","STRAHLER_MAX","MAINSTEM_SINUOUSITY","HIRES_LENTIC_PCT","BFI_AVE")
hydroVars <- c("diel90","diel50","dielMean","BFI_AVE","SLOPE","PERDUN","PERHOR","TOPWET","RUNAVE7100")
hydroCorrelation <- dielGages[hydroVars]

lc06800Vars <- c("diel90","diel50","dielMean","MAINS800_DEV","MAINS800_FOREST","MAINS800_PLANT","MAINS800_11",
                  "MAINS800_12","MAINS800_21","MAINS800_22","MAINS800_23","MAINS800_24",
                  "MAINS800_31","MAINS800_41","MAINS800_42","MAINS800_43","MAINS800_52",
                  "MAINS800_71","MAINS800_81","MAINS800_82","MAINS800_90","MAINS800_95")
lc06800Correlation <- dielGages[lc06800Vars]

corrgram(lc06800Correlation,order=NULL,lower.panel=panel.shade,upper.panel=NULL,
         label.srt=0,font.labels=1.2,row1attop=TRUE,gap=0,cex.labels=1, cor.method="spearman")

#################
#Functions for investigating single variable correlation.
#################
diel50Cor <- function(predictor){
  predvar <- dielGages[,predictor] # predictor can now be a variable describing a character string
  a<-cor.test(dielGages$diel50,predvar,method="spearman")
  predvar <- ifelse(predvar == 0, predvar + 0.01, predvar) # ifelse(x, y, z)  works in a vector, whereas if(x) y else() z looks for a single T/F value for x
  plot(x=predvar,y=dielGages$diel50,log="x",
    text(quantile(predvar,0.05,na.rm=TRUE),325,round(a$p.value,3)))
}

diel90Cor <- function(predictor){
  predvar <- dielGages[,predictor] # predictor can now be a variable describing a character string
  a<-cor.test(dielGages$diel90,predvar,method="spearman")
  predvar <- ifelse(predvar == 0, predvar + 0.01, predvar) # ifelse(x, y, z)  works in a vector, whereas if(x) y else() z looks for a single T/F value for x
  plot(x=predvar,y=dielGages$diel90,log="x",
       text(quantile(predvar,0.05,na.rm=TRUE),325,round(a$p.value,3)))
}
