library(scclusteval)

## see https://bitbucket.org/snakemake/snakemake/issues/917/enable-stdout-and-stderr-redirection
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

seurat_obj<- readRDS(snakemake@input[[1]])
k<- snakemake@wildcards[["k"]]
resolution<- snakemake@wildcards[["resolution"]]
pc.use<- snakemake@wildcards[["pc"]]


PreprocessSubsetData_pars<- snakemake@params[["PreprocessSubsetData_pars"]]
## this is not subsetted data, but the PreprocessSubsetData function can be used as well for any seurat object
seurat_obj<- eval(parse(text=paste("PreprocessSubsetData", "(", "seurat_obj,", "k.param=", k, ",", "pc.use=", pc.use, ",",
                                   "resolution=", resolution, ",", PreprocessSubsetData_pars, ")")))
saveRDS(seurat_obj, file = paste0("resample_preprocess/resample_", "k_", k, "_resolution_", resolution, "_PC_", pc.use, ".rds"))
