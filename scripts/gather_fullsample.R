library(tidyverse)
library(Seurat)

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")


rdss<- snakemake@input[["rds"]]

get_idents<- function(rds){
        x<- readRDS(rds)
        k<- gsub("full_sample_k_([0-9]+)_resolution_([0-9\\.]+)_PC_([0-9]+).rds", "\\1", basename(rds))
        resolution<- gsub("full_sample_k_([0-9]+)_resolution_([0-9\\.]+)_PC_([0-9]+).rds", "\\2", basename(rds))
        pc.use<- gsub("full_sample_k_([0-9]+)_resolution_([0-9\\.]+)_PC_([0-9]+).rds", "\\3", basename(rds))
        df<- tibble::tibble(pc = pc.use, resolution = resolution, k_param = k, original_ident_full = list(Idents(x)))
        return(df)
}

dat.list<- lapply(rdss, get_idents)

gather_idents<- do.call(bind_rows, dat.list)
saveRDS(gather_idents, file = snakemake@output[[1]])

