library(zoo)
library(sandwich)
library(MASS)
library(quadprog)
library(tseries)
library(strucchange)
library(fracdiff)
library(forecast)
library(iterators)
library(codetools)
library(foreach)
library(bfast)
library(mailR)
library(parallel)

args <- commandArgs(trailingOnly = TRUE)

tile <- args[2]
filename <- paste0(args[1], args[2])
num_cores <- strtoi(args[3])
cluster <- makeCluster(num_cores)
clusterExport(cluster, "bfast")
clusterExport(cluster, "%dopar%")

datafile <- paste0(filename, "_ndvi_fill.csv")
inidata<-read.table(datafile, header=FALSE, sep = ",", dec = ".") #use only with small files; modify if no labels are in the input 
mdata<-as.matrix(inidata)
tpdata<-mdata
vmax<-dim(mdata)
vmax[1]
vmax[2]
clusterExport(cluster, varlist=c("tile","tpdata","vmax"))
parLapply(cluster, 1:vmax[1], function(count){
	poly_id<-tpdata[count,1]  #highlighted number identifies field that will used to ID pixel
	ndvi<-tpdata[count,2:vmax[2]]  #highlighted number identifies first column with NDVI data
	plot(ndvi)
	tsdata<-ts(ndvi,frequency=23,start=c(2001,1))
	dim(tsdata)<-NULL
	rdist<-23/length(tsdata)
	fits<-bfast(tsdata,h=rdist,season="harmonic",max.iter=1, hpc = "foreach")
	plot(fits)
	fits2<-fits$Time
	ts_trend_break_time<-t(fits2[1])
	fits3<-fits$Magnitude
	ts_trend_break_magnitude<-t(fits3[1])
	fits4<-fits$output
	fits4a<-fits4[[1]]$Vt.bp
	fits4adata<-as.matrix(fits4a)
	fits4amax<-dim(fits4adata)
	ts_trend_nbbreak<-t(fits4amax[1])
	results1<-ts_trend_break_time
	aLine<-t(c(poly_id,results1))
	write.table(aLine, file=paste0("Results/", tile, "_trend_breaks_time.txt"), append=TRUE,quote=FALSE,sep=",", eol="\n",na="NA", dec=".",row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	results2<-ts_trend_break_magnitude
	aLine<-t(c(poly_id,results2))
	write.table(aLine,file=paste0("Results/", tile, "_trend_breaks_magnitude.txt"), append=TRUE,quote=FALSE, sep=",",eol="\n", na="NA", dec=".",row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	results3<-ts_trend_nbbreak
	aLine<-t(c(poly_id,results3))
	write.table(aLine,file=paste0("Results/", tile, "_trend_nbbreaks.txt"),append=TRUE,quote=FALSE,sep=",", eol="\n",na="NA", de=".", ,row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	fits4b<-fits4[[1]]$Tt
	results4<-fits4b
	aLine<-t(c(poly_id,results4))
	write.table(aLine,file=paste0("Results/", tile, "_trend_bfast.txt"),append=TRUE,quote=FALSE, sep=",",eol="\n",na="NA",dec=".", row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	fits4c<-fits4[[1]]$Wt.bp
	fits4cdata<-as.matrix(fits4c)
	fits4cmax<-dim(fits4cdata)
	ts_season_nbbreak<-t(fits4cmax[1])
	results5<-ts_season_nbbreak
	aLine<-t(c(poly_id,results5))
	write.table(aLine,file=paste0("Results/", tile, "_season_nbbreaks.txt"),append=TRUE,quote=FALSE, sep=",",eol="\n", na="NA", de=".", row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	ts_season_breaks_time<-t(fits4cdata)
	results6<- ts_season_breaks_time
	aLine<- t(c(poly_id,results6))
	write.table(aLine,file=paste0("Results/", tile, "_season_breaks_time.txt"),append=TRUE,quote=FALSE,sep=",", eol="\n",na="NA", de=".",row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	fits4d<-fits4[[1]]$St
	results7<-fits4d
	aLine<-t(c(poly_id,results7))
	write.table(aLine,file=paste0("Results/", tile, "_season_bfast.txt"),append=TRUE,quote=FALSE,sep=",",eol="\n",na="NA",dec=".",row.names=FALSE,col.names=FALSE,qmethod=c("escape","double"))
	rm(list=ls())
})
