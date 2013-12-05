##author:Yan Zeng
##Date:5-12-2013
##title:sub function 
##MeanofImage,Brick,GetMeanPerClass

##read rom dropbox
dl_from_dropbox <- function(x, key) {
  require(RCurl)
  bin <- getBinaryURL(paste0("https://dl.dropboxusercontent.com/s/", key, "/", x),           
                      ssl.verifypeer = FALSE)
  con <- file(x, open = "wb")
  writeBin(bin, con)
  close(con)
  message(noquote(paste(x, "read into", getwd())))                        
}

##########sub function
##function to calculate the meanndvi of whole year
MeanofImage<-function(input){
  a<-input[[1]]
  for(i in 1:22){
    a<-(a+input[[i+1]])  
  }
  a<-a/23
  return(a)
}
##function to brick two object with different extent and resolution
Brick<-function(image1,image2){
  image1[image1==0]<-NA
  y<-intersect(image1,image2)
  image1R<-resample(image1, y, method = "ngb")
  image2R<-resample(image2, y, method = "ngb")
  cov<-brick(image1R,image2R)
  return(cov)
}
##make a value table,input is two layer image with value image and classification map
ValueT<-function(cov){
  valuetable <- getValues(cov)
  valuetable <- na.omit(valuetable)
  valuetable<-as.data.frame(valuetable)
  dates <- substr(names(cov), 10, 16)
  colnames(valuetable)<-as.Date(dates, format="%Y%j")
  colnames(valuetable)[1]<-'NDVI'
  colnames(valuetable)[2]<-'classcode'
  return(valuetable)
}
##get mean value of time series of per class 
GetMeanPerClass<-function(image,Classmap,ClassTable){
  
  meanValue<- zonal(image, z=Classmap, fun='mean')
  meanValue<-as.data.frame(meanValue)
  dates <- substr(names(image), 10, 16)
  names<-c('class',dates)
  colnames(meanValue)<-as.Date(names, format="%Y%j")
  colnames(meanValue)[1]<-'classcode'
  meanValue<-merge(meanValue,ClassTable)
  return(meanValue) 
}