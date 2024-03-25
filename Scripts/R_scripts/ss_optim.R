library(raster)
library(sp)
library(ResistanceGA)



#pred_subset1=stack(files2[2], files2[5])
pred<-raster("landcover.tif")
names(pred)=c("landcover")
write.dir=("ResistanceGA/landcover_ssoptim/")
GA.inputs <- GA.prep(ASCII.dir = pred,
                     Results.dir = write.dir,
                     method = "LL",
                     max.cat = 100,
                     max.cont = 1000,
                     seed = 555,
                     parallel = 4,
                     cat.levels=19)


distance<-read.csv("Marmot_Fst.csv", header=F)
my.matrix<-as.matrix(distance)
genetic_dis<-lower(my.matrix)
locals<-read.csv("Marmot_GISToolCoords.csv")
Sample.locals<-SpatialPoints(locals[,c("Longitude", "Latitude")])

gdist.inputs <- gdist.prep(response=genetic_dis,
                           samples = Sample.locals,
                           n.Pops=10,
                           method = 'commuteDistance') # Optimize using commute distance


SS_RESULTS.gdist <- SS_optim(gdist.inputs = gdist.inputs,
                             GA.inputs = GA.inputs)


#https://onlinelibrary.wiley.com/doi/full/10.1111/1755-0998.13831
