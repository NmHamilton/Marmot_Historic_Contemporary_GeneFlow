library(biomod2)
library(sp)
library(raster)
library(dismo)

setwd("path/to/wd")

files2=list.files(pattern = '.tif$', full.names = TRUE) #list all .tif files (replace with extension that matches your rasters)

landcover<-raster(files2[1])
landcover<-as.factor(landcover) ## categorical variable as factor
bio18<-raster("files2[8])")
bio19<-raster("files2[9]")
pred=stack(landcover,files2[2], files2[3], files2[4], files2[5], files2[6], files2[7], files2[8], files2[9]) ##stack all environmental variables
names(pred)=c("landcover", "bio01", "bio10", "bio15", "bio02", "bio08", "elevation", "bio18", "bio19") ## make sure environmental variables have name

occurrence<-read.csv("/ENM/Occurrence_Values/5km_thinned_thin1.csv") #load occurrence values
myRespXY<-occurrence[,c("decimalLongitude", "decimalLatitude")] # extract Long, Lat 
occurrence$presence<-'1' # create a presence column
myResp<- as.numeric(occurrence[, "presence"]) # input for biomod2


myBiomodData<- BIOMOD_FormatingData(resp.var=myResp,
                                    expl.var=pred,
                                    resp.xy=myRespXY,
                                    resp.name="M_caligata_5kmRARE_disk100kmEnsemblerun_newvars",
                                    PA.nb.rep=1,
                                    PA.nb.absences=7500,
                                    PA.strategy='disk',
                                    PA.dist.min=100000,
                                    PA.dist.max=NULL,
                                    na.rm=T)

myBiomodModelOut <- BIOMOD_Modeling(bm.format = myBiomodData,
                                    models=c('GLM','GBM', 'GAM', 'CTA', 'ANN', 'SRE','FDA', 'MARS', 'RF','MAXNET'),
                                    CV.strategy = 'kfold',
                                    CV.nb.rep = 5,
                                    CV.k=5,
                                    var.import = 100,
                                    metric.eval = c('TSS','ROC'))
# seed.val = 123)
# nb.cpu = 8)


get_evaluations(myBiomodModelOut)
get_variables_importance(myBiomodModelOut)

# Represent evaluation scores & variables importance
bm_PlotEvalMean(bm.out = myBiomodModelOut)
bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'algo'))
bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'run'))
bm_PlotVarImpBoxplot(bm.out = myBiomodModelOut, group.by = c('expl.var', 'algo', 'algo'))
bm_PlotVarImpBoxplot(bm.out = myBiomodModelOut, group.by = c('expl.var', 'algo', 'run'))
bm_PlotVarImpBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'expl.var', 'run'))

# Represent response curves
bm_PlotResponseCurves(bm.out = myBiomodModelOut, 
                      models.chosen = get_built_models(myBiomodModelOut)[c(1:3, 12:14)],
                      fixed.var = 'median')
bm_PlotResponseCurves(bm.out = myBiomodModelOut, 
                      models.chosen = get_built_models(myBiomodModelOut)[c(1:3, 12:14)],
                      fixed.var = 'min')
bm_PlotResponseCurves(bm.out = myBiomodModelOut, 
                      models.chosen = get_built_models(myBiomodModelOut)[3],
                      fixed.var = 'median',
                      do.bivariate = TRUE)

myBiomodEM <- BIOMOD_EnsembleModeling(bm.mod = myBiomodModelOut,
                                      models.chosen = 'all',
                                      em.by = 'all',
                                      em.algo = c('EMmean', 'EMcv', 'EMci', 'EMmedian', 'EMca', 'EMwmean'),
                                      metric.select = c('ROC'),
                                      metric.select.thresh = c(0.8),
                                      metric.eval = c('TSS', 'ROC'),
                                      var.import = 5,
                                      EMci.alpha = 0.05,
                                      EMwmean.decay = 'proportional')
myBiomodEM

get_evaluations(myBiomodEM)
get_variables_importance(myBiomodEM)

# Represent evaluation scores & variables importance
bm_PlotEvalMean(bm.out = myBiomodEM, group.by = 'full.name')
bm_PlotEvalBoxplot(bm.out = myBiomodEM, group.by = c('full.name', 'full.name'))
bm_PlotVarImpBoxplot(bm.out = myBiomodEM, group.by = c('expl.var', 'full.name', 'full.name'))
bm_PlotVarImpBoxplot(bm.out = myBiomodEM, group.by = c('algo', 'expl.var', 'merged.by.run'))


# Represent response curves
bm_PlotResponseCurves(bm.out = myBiomodEM, 
                      models.chosen = get_built_models(myBiomodEM)[c(1, 6, 7)],
                      fixed.var = 'median')
bm_PlotResponseCurves(bm.out = myBiomodEM, 
                      models.chosen = get_built_models(myBiomodEM)[c(1, 6, 7)],
                      fixed.var = 'min')
bm_PlotResponseCurves(bm.out = myBiomodEM, 
                      models.chosen = get_built_models(myBiomodEM)[5],
                      fixed.var = 'mean',
                      do.bivariate = TRUE)

myBiomodEMProj <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM,
                                             proj.name = 'CurrentEM_100km_Run9_5Rare',
                                             new.env = pred,
                                             models.chosen = 'all',
                                             metric.binary = 'all',
                                             metric.filter = 'all')

