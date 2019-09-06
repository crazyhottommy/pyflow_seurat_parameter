# scBootClusterSeurat
A snakemake pipeline to scatter and gather bootstrapped Seurat@ident

on `odyssey` cluster(SLURM):

```bash
ssh odyssey

## start a screen session
screen

git clone https://github.com/crazyhottommy/scBootClusterSeurat

conda create n=snakemake python=3.6 snakemake

source activate snakemake

# R3.5.1, make sure you load R after source activate conda environment
module load R

#hdf5, seurat needs a more recent hdf5 to be able to install
module load hdf5

R
>install.package("Seurat")
>devtools::install_github("crazyhottommy/scclusteval", auth_token="aa791fd9c20a5cb9205774df9c7a78f63fef9c2c")


```

copy your seurat object into the `scBootClusterSeurat` folder and 

open the `config.ymal` file to edit some configurations.

```bash
# dry run
snakemake -np 

# if on bioinfo1 or bioinfo2 (there are 64 cores avaiable on each node)
snakemake -j 40

# if submitting job to queue 

./pyflow-scBoot.sh
```