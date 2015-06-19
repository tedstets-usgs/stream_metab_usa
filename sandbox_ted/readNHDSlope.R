#Read NHDPlus attribute files stored on Ted's computer and merge with GAGESII station ID.
#Remove all intermediate files after running the program.

#library(foreign)
nhdDir <- "C:/DATASAVE/weasel/NHDPlus/"
nhdFile <- "NHDPlusAttributes/elevslope.dbf"
nhdAttr18 <- read.dbf(paste0(nhdDir,"NHDPlusCA/NHDPlus18/",nhdFile))
nhdAttr14 <- read.dbf(paste0(nhdDir,"NHDPlusCO/NHDPlus14/",nhdFile))
nhdAttr15 <- read.dbf(paste0(nhdDir,"NHDPlusCO/NHDPlus15/",nhdFile))
nhdAttr16 <- read.dbf(paste0(nhdDir,"NHDPlusGB/NHDPlus16/",nhdFile))
nhdAttr04 <- read.dbf(paste0(nhdDir,"NHDPlusGL/NHDPlus04/",nhdFile))
nhdAttr02 <- read.dbf(paste0(nhdDir,"NHDPlusMA/NHDPlus02/",nhdFile))
nhdAttr05 <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus05/",nhdFile))
nhdAttr06 <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus06/",nhdFile))
nhdAttr07 <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus07/",nhdFile))
nhdAttr08 <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus08/",nhdFile))
nhdAttr10U <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus10U/",nhdFile))
nhdAttr10L <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus10L/",nhdFile))
nhdAttr11 <- read.dbf(paste0(nhdDir,"NHDPlusMS/NHDPlus11/",nhdFile))
nhdAttr01 <- read.dbf(paste0(nhdDir,"NHDPlusNE/NHDPlus01/",nhdFile))
nhdAttr17 <- read.dbf(paste0(nhdDir,"NHDPlusPN/NHDPlus17/",nhdFile))
nhdAttr13 <- read.dbf(paste0(nhdDir,"NHDPlusRG/NHDPlus13/",nhdFile))
nhdAttr03N <- read.dbf(paste0(nhdDir,"NHDPlusSA/NHDPlus03N/",nhdFile))
nhdAttr03S <- read.dbf(paste0(nhdDir,"NHDPlusSA/NHDPlus03S/",nhdFile))
nhdAttr03W <- read.dbf(paste0(nhdDir,"NHDPlusSA/NHDPlus03W/",nhdFile))
nhdAttr09 <- read.dbf(paste0(nhdDir,"NHDPlusSR/NHDPlus09/",nhdFile))
nhdAttr12 <- read.dbf(paste0(nhdDir,"NHDPlusTX/NHDPlus12/",nhdFile))

NHDAttr <- rbind(nhdAttr18,nhdAttr14,nhdAttr15,nhdAttr16,nhdAttr04,nhdAttr02,nhdAttr02,
        nhdAttr05,nhdAttr06,nhdAttr07,nhdAttr08,nhdAttr10U,nhdAttr10L,nhdAttr11,nhdAttr01,
        nhdAttr17,nhdAttr13,nhdAttr03N,nhdAttr03S,nhdAttr03W,nhdAttr09,nhdAttr12)

gagesCOMIDscolClasses <- c("character","character","numeric","character")
gagesCOMIDs <- read.table("c:/DATASAVE/weasel/GAGESII/comid_table.txt",
        colClasses=gagesCOMIDscolClasses,sep="\t",header=TRUE)

gagesSlopes <- merge(x=NHDAttr,y=gagesCOMIDs,by="COMID",all.y=TRUE)

gagesSlopes$site_id <- paste0("nwis_",gagesSlopes$STAID)

keeps <- c("COMID","FDATE","SLOPE","SLOPELENKM","FTYPE","site_id")
gagesSlopes <- gagesSlopes[keeps]

#rm(NHDAttr,nhdAttr18,nhdAttr14,nhdAttr15,nhdAttr16,
#  nhdAttr04,nhdAttr02,nhdAttr05,nhdAttr06,nhdAttr07,
#  nhdAttr08,nhdAttr10U,nhdAttr10L,nhdAttr11,nhdAttr01,
#  nhdAttr17,nhdAttr13,nhdAttr03N,nhdAttr03S,nhdAttr03W,
#  nhdAttr09,nhdAttr12,nhdFile,nhdDir,gagesCOMIDs,gagesCOMIDscolClasses)




