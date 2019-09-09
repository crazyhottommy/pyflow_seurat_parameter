# Snakemake workflow for subsampling and repeat clustering

A snakemake pipeline to scatter and gather Seurat@ident by subsampling the cells and repeat for 
multiple times. This is useful for evaluating the cluster stability using different parameters.

For now, three paramters are tested.

* number of PCs (principle components) used for `RunPCA` (npcs) and `FindNeighbors` (dims).
* `k.param` for `FindNeighbors`
* `resolution` for `FindClusters` 

on `odyssey` cluster(SLURM):

```bash
ssh odyssey

## start a screen session
screen

git clone https://github.com/crazyhottommy/pyflow_seuratv3_parameter

conda create n=snakemake python=3.6 snakemake

source activate snakemake

# R3.5.1, make sure you load R after source activate conda environment
module load R

#hdf5, seurat needs a more recent hdf5 to be able to install
module load hdf5

R
>install.package("Seurat")

```

If you do not want to install `Seurat` yourself, a singularity container image is avaiable if you evoke snakemake:

```
snakemake --use-singularity
```

copy your seurat object into the `pyflow_seuratv3_parameter` folder and 

open the `config.ymal` file to edit some configurations.

```bash
# dry run
snakemake -np 

# if on bioinfo1 or bioinfo2 (there are 64 cores avaiable on each node)
snakemake -j 40

# if submitting job to queue 

./pyflow-scBoot.sh
```