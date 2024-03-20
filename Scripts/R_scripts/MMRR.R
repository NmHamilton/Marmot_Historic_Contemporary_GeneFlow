### R script for running MMRR ###
### Modified from algatr workflow ###

library(raster)
library(algatr)


marm_coords<-read.table("Coords.txt") #coords need to be long, lat with column names X, Y
marm_gendist<-read.csv("Marmot_Fst.csv", header=F)
elevation<-raster("Elevation_Results/Elevation.asc")
sdm<-raster("Marmot_SDM_5km_100disc_NewVars_WeightedMean.tif")
ocean<-raster("Ocean/Ocean.asc")

Y<-as.matrix(marm_gendist)
env<-raster::extract(sdm, marm_coords)
X<-env_dist(env)
X[["geodist"]]<-geo_dist(marm_coords)
X[["resistdist"]]<-geo_dist(marm_coords, type="resistance", lyr=elevation)
results_resist <- mmrr_run(Y, X, nperm = 10000, stdz = TRUE, model = "full")
pdf("MMRR_ElevationNewVars.pdf")
mmrr_plot(Y, X, mod = results_resist$mod, plot_type = "all", stdz = TRUE)
dev.off()


X[["resistdist"]]<-geo_dist(marm_coords, type="resistance", lyr=ocean)
results_resist <- mmrr_run(Y, X, nperm = 10000, stdz = TRUE, model = "full")
pdf("MMRR_ocean_newvars.pdf")
mmrr_plot(Y, X, mod = results_resist$mod, plot_type = "all", stdz = TRUE)
dev.off()


X[["elevation"]]<-geo_dist(marm_coords, type="resistance", lyr=elevation)
results_resist <- mmrr_run(Y, X, nperm = 10000, stdz = TRUE, model = "full")
mmrr_plot(Y, X, mod = results_resist$mod, plot_type = "all", stdz = TRUE)
