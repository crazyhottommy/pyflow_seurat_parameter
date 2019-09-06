shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

configfile: "config.yaml"

CLUSTER = json.load(open(config['CLUSTER_JSON']))

NUM_OF_SUBSAMPLE = config["num_of_subsample"]
ks = config["subsample_ks"].strip().split()
resolutions = config["subsample_resolutions"].strip().split()
pcs = config["subsample_pcs"].strip().split()
INPUT_SEURAT = config["input_seurat"]


subsample_K_RESOLUTION_PC = expand("subsample_k_and_resolution/subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}.rds", \
	k = ks, resolution = resolutions, pc = pcs, run_id = range(NUM_OF_SUBSAMPLE))


TARGETS = []

TARGETS.extend(subsample_K_RESOLUTION_PC)
TARGETS.append("gather_subsample.rds")


localrules: all, gather_subsample
rule all:
    input: TARGETS



rule subsample_preprocess:
	input: INPUT_SEURAT
	output: "subsample_preprocess/subsample_k_{k}_resolution_{resolution}_PC_{pc}.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/subsample_k_{k}_resolution_{resolution}_PC_{pc}.log"
	params: jobname = "subsample_k_{k}_resolution_{resolution}_PC_{pc}",
			PreprocessSubsetData_pars = config.get("PreprocessSubsetData_subsample_pars", "")
	message: "preprocessing original seurat object using k of {wildcards.k} resolution of {wildcards.resolution}, {wildcards.pc} PCs with {threads} threads"
	script: "scripts/preprocess.R"
	
rule subsample_cluster:
	input: "subsample_preprocess/subsample_k_{k}_resolution_{resolution}_PC_{pc}.rds"
	output: "subsample/subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}.log"
	params: jobname = "subsample_k_{k}_resolution_{resolution}_PC_{pc}_round_{run_id}",
			rate = config["subsample_rate"],
			PreprocessSubsetData_pars = config.get("PreprocessSubsetData_subsample_pars", "")
	message: "subsampleping k of {wildcards.k} resolution of {wildcards.resolution}, {wildcards.pc} PCs for round {wildcards.run_id} using {threads} threads"
	script: "scripts/subsample.R"


rule gather_subsample:
	input: rds = subsample_K_RESOLUTION_PC
	output: "gather_subsample.rds"
	singularity: "docker://crazyhottommy/seuratv3"
	log: "00log/gather_subsample.log"
	threads: 1
	message: "gathering idents for subsample k"
	script: "scripts/gather_subsample.R"



