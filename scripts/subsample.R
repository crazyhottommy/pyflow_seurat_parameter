library(scclusteval)

## see https://bitbucket.org/snakemake/snakemake/issues/917/enable-stdout-and-stderr-redirection
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

seurat_obj<- readRDS(snakemake@input[[1]])
k<- snakemake@wildcards[["k"]]
resolution<- snakemake@wildcards[["resolution"]]
pc.use<- snakemake@wildcards[["pc"]]
run_id<- snakemake@wildcards[["run_id"]]

PreprocessSubsetData_pars<- snakemake@params[["PreprocessSubsetData_pars"]]

subset_seurat_obj<- RandomSubsetData(seurat_obj, rate = snakemake@params[["rate"]])
original_ident<- Idents(subset_seurat_obj)

## after reprocessing, the ident slot will be updated with the new cluster id
command<- paste("PreprocessSubsetData", "(", "seurat_obj,", "k.param=", k, ",", "pc.use=", pc.use, ",",
                                   "resolution=", resolution, ",", PreprocessSubsetData_pars, ")")
subset_seurat_obj<- eval(parse(text=command))

res<- tibble::tibble(pc = pc.use, resolution = resolution, k_param = k, original_ident = list(original_ident),
    recluster_ident = list(Idents(subset_seurat_obj)), round = run_id)


outfile<- paste0("subsample/subsample_", "k_", k, "_resolution_", resolution, "_PC_", pc.use, "_round_", run_id, ".rds")
saveRDS(res, file = outfile)

## make sure it is not empty file
info<- file.info(outfile)
if (info$size == 0) {
    quit(status = 1)
}

