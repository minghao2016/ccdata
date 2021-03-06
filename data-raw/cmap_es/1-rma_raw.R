library(affy)
library(data.table)

setwd("~/Documents/Batcave/GEO/ccdata/data-raw/")

#raw data from https://www.broadinstitute.org/cmap/cel_file_chunks.jsp



# CMAP Metadata --------------------------------------------


cmap_instances <- read.table("raw/cmap_instances_02.csv", 
                             header=TRUE, sep="\t", quote='', fill=TRUE, stringsAsFactors=FALSE)

cmap_instances <- data.table(cmap_instances)



#HT_HG-U133A_EA & HG-U133A ---------------------------------


array_instances <- cmap_instances[array3 =="HG-U133A",]

celfiles = c() # Each cel file has multiple controls
controls = list()  # So we keep them in a list

for (i in 1:length(array_instances$perturbation_scan_id)) {
  # This is the instance (cell exposed to drug) CEL file
  id = as.character(array_instances$perturbation_scan_id[i])
  id = gsub("'","",id)
  # This is the control cell (not exposed to drug)
  cid = as.character(array_instances$vehicle_scan_id4[i])
  
  #add path for instance file
  file = paste('raw/', id, ".CEL", sep="")
  celfiles = c(celfiles,file) 
  
  #add paths for control files (multiple controls)
  if (length(strsplit(cid, "[.]")[[1]]) > 2) {
    
    id = strsplit(id,"[.]")[[1]][1]
    cid = strsplit(cid,"[.]")
    cid = cid[[1]][-which(cid[[1]] %in% "")]
    
    tmp = c()
    for (c in 1:length(cid)){
      cinstance = paste(id,".",cid[c],sep="")
      file = paste('raw/', cinstance, ".CEL", sep="")
      tmp = c(tmp,file)    
    }
    controls = c(controls,list(tmp))
    
  #add paths for control files (single control)
  } else {
    tmp = c()
    for (c in 1:length(cid)){
      file = paste('raw/', cid, ".CEL", sep="")
      tmp = c(tmp,file)    
    }
    controls = c(controls,list(tmp)) 
    
  }
}

cel_paths <- unique(c(celfiles, unlist(controls)))
raw_data <- ReadAffy (filenames=cel_paths)
data <- affy::rma(raw_data)

saveRDS(data, "cmap-es/rma_HG-U133A.rds")




# HT_HG-U133A --------------------------------------------


#   - remove all "~/Documents/Batcave/GEO/ccdata/data-raw/raw/" & run up to cel_paths
#   - library(xps) #only worked in terminal R
#   - library(Biobase)
#   - scheme.hthgu133a.na35 <- root.scheme("/home/alex/Documents/Batcave/affy/schemes/na35/hthgu133a.root")
#   - celdir <- "~/Documents/Batcave/GEO/ccdata/data-raw/raw"
#   - cmap_hthgu133a <- import.data(scheme.hthgu133a.na35, "cmap_hthgu133a", celdir=celdir, celfiles=cel_paths, verbose=TRUE)
#   - cmap_hthgu133a_rma <- rma(cmap_hthgu133a, "cmap_hthgu133a_rma", verbose=FALSE)
#   - eset <- new("ExpressionSet", exprs = as.matrix(cmap_hthgu133a_rma))
#   - saveRDS(eset, "HT_HG-U133A.rds")
