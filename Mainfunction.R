##author:Yan Zeng
##Date:5-12-2013
##MakeHistofMean,TimeSeriesofModis

##Main function1
##plot the histogram of different of mean ndvi of whole year
MakeHistofMean<-function(modis,LandCover){
  meanndvi<-MeanofImage(modis)
  ##build a brick of landcover and mean ndvi of whole year
  cov<-Brick(meanndvi,LandCover)
  ##build valuetable of meanndvi of different class
  valuetable<-ValueT(cov)
  ##remove the class not in the image
  ClassTable <- ClassTable[ClassTable$classcode %in% valuetable$classcode,]
  valuetable<-merge(valuetable,ClassTable)
  ##plot the histgoram of each class of mean ndvi
  p1 <- ggplot(valuetable, aes(x=NDVI)) +
    geom_histogram(binwidth=10) +
    facet_wrap(~ class) +
    theme_bw()
  return(p1)
}


##Main function 2
##compare the different mean ndvi value of different class
TimeSeriesofModis<-function(modis,LandCover,ClassTable){ 
  projection(LandCover) <- projection(modis)
  meanndvi<-MeanofImage(modis)
  ##resample two data with different extent and resolution
  y<-intersect(modis,LandCover)
  LandCoverR<-resample(LandCover, y, method = "ngb")
  modisR<-resample(modis, y, method = "ngb")
  ##get the mean of each each class and each time series
  meanNDVI<-GetMeanPerClass(modisR,LandCoverR,ClassTable)
  dates <- substr(names(modis), 10, 16)
  ###make time series table of each class
  Classts<-data.frame(dates=as.Date(dates, format="%Y%j"),
                      ndvi=as.numeric(meanNDVI[1,2:24]),
                      class=ClassTable[1,2]
  )
  for(i in 2:14){
    
    Classtsadd<-data.frame(dates=as.Date(dates, format="%Y%j"),
                           ndvi=as.numeric(meanNDVI[i,2:24]),
                           class=ClassTable[i,2])
    Classts <- rbind(Classts,Classtsadd)
  }
  ## time series plot
  p1<-ggplot(data = Classts, aes(x = dates, y = ndvi)) +
    geom_point() +
    scale_x_date() +
    labs(y = "NDVI") +
    facet_wrap(~ class, nrow = 5,ncol=3) +
    theme_bw()
  return(p1)
}