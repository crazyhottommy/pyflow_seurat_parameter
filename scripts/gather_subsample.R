library(tidyverse)

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

rdss<- snakemake@input[["rds"]]

get_df<- function(rds){
	res<- readRDS(rds)
	return(res)
}

dat.list<- lapply(rdss, get_df)

gather_idents<- do.call(bind_rows, dat.list)
saveRDS(gather_idents, file = "gather_subsample.rds")

