library(raster)
library(sp)
library(ResistanceGA)

## I tested two surfaces at a time, otherwise the resistanceGA functions had a segmentation error
elevation<-raster("wc2.1_2.5m_elev_cropped.tif")
elevation<-setValues(elevation, ifelse(is.na(values(elevation)), 0, values(elevation)))
### the MS_optim function errors out if there are NA values
ocean<-raster("Ocean_cropped.tif")
pred_subset1=stack(elevation, ocean)


names(pred_subset1)= c("Elevation", "Ocean")
write.dir=("/scratch/user/nhamilton/ResistanceGA/ms_optim_ElevOcean_Downsample/")
GA.inputs <- GA.prep(ASCII.dir = pred_subset1,
                     Results.dir = write.dir,
                     method = "LL",
                     max.cat = 100,
                     max.cont = 1000,
                     seed = 555,
                     parallel = 4, 
                     cat.levels=15)


distance<-read.csv("FST.csv", header=F)
my.matrix<-as.matrix(distance)
genetic_dis<-lower(my.matrix)
locals<-read.csv("Geog_Coords.csv")
Sample.locals<-SpatialPoints(locals[,c("Longitude", "Latitude")])

gdist.inputs <- gdist.prep(response=genetic_dis,
                           samples = Sample.locals,
                           n.Pops=10,
                           method = 'commuteDistance') # Optimize using commute disance

