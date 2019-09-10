shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

configfile: "config.yaml"

CLUSTER = json.load(open(config['CLUSTER_JSON']))

NUM_OF_SUBSAMPLE = config["num_of_subsample"]
ks = config["subsample_ks"].strip().split()
resolutions = config["subsample_resolutions"].strip().split()
pcs = config["subsample_pcs"].strip().split()
INPUT_SEURAT = config["input_seurat"]


SUBSAMPLE_K_RESOLUTION_PC = expand("subsample/subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}.rds", \
	k = ks, resolution = resolutions, pc = pcs, run_id = range(NUM_OF_SUBSAMPLE))

FULLSAMPLE_K_RESOLUTION_PC = expand("full_sample_preprocess/full_sample_k_{k}_resolution_{resolution}_PC_{pc}.rds", \
	k = ks, resolution = resolutions, pc = pcs)

TARGETS = []

TARGETS.extend(SUBSAMPLE_K_RESOLUTION_PC)
TARGETS.append("gather_subsample.rds")
TARGETS.append("gather_full_sample.rds")

localrules: all, gather_subsample, gather_full_sample_preprocess
rule all:
    input: TARGETS


## the full data set, preprocessing using a set of k, resolution and PC
rule full_sample_preprocess:
	input: INPUT_SEURAT
	output: "full_sample_preprocess/full_sample_k_{k}_resolution_{resolution}_PC_{pc}.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/full_sample_k_{k}_resolution_{resolution}_PC_{pc}.log"
	params: jobname = "full_sample_k_{k}_resolution_{resolution}_PC_{pc}",
			PreprocessSubsetData_pars = config.get("PreprocessSubsetData_subsample_pars", "")
	message: "preprocessing original full seurat object using k of {wildcards.k} resolution of {wildcards.resolution}, {wildcards.pc} PCs with {threads} threads"
	script: "scripts/preprocess.R"


rule gather_full_sample_preprocess:
	input: FULLSAMPLE_K_RESOLUTION_PC
	output: "gather_full_sample.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/full_sample_gather_idents.log"
	message: "gathering full sample idents"
	script: "scripts/gather_fullsample.R"


## subsample e.g. 80% of the cells and re-do the clustering for n times
rule subsample_cluster:
	input: "subsample_preprocess/subsample_k_{k}_resolution_{resolution}_PC_{pc}.rds"
	output: "subsample/subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}.log"
	params: jobname = "subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}",
			rate = config["subsample_rate"],
			PreprocessSubsetData_pars = config.get("PreprocessSubsetData_subsample_pars", "")
	message: "subsampling {params.rate} from the full data set, recluster using k of {wildcards.k} resolution of {wildcards.resolution}, {wildcards.pc} PCs for round {wildcards.run_id} using {threads} threads"
	script: "scripts/subsample.R"


## gather the subsampled and reclustered cell idents
rule gather_subsample:
	input: rds = SUBSAMPLE_K_RESOLUTION_PC
	output: "gather_subsample.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/gather_subsample.log"
	threads: 1
	message: "gathering idents for subsample k"
	script: "scripts/gather_subsample.R"



