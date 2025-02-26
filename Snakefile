
import pandas as pd
from glob import glob
import subprocess
import os

#samples = pd.read_table(config["run"]["samples"]).set_index("sample", drop=False)

ruleorder: single_calculate_mtr > single_create_mtr_file
localrules: single_concatenate_summary_metrics, single_concatenate_mtr

ruleorder: ensemble_calculate_mtr > ensemble_create_mtr_file
localrules: ensemble_concatenate_summary_metrics, ensemble_concatenate_mtr

if config["run"]["single_structure_modality"] == True & config["run"]["ensemble_structure_modality"] == True:
	rule all:
		input:
			"results/single_structure/final/all_transcript_summary_metrics.csv",
			"results/single_structure/final/all_mtr.csv",
			"results/ensemble_structure/final/all_transcript_summary_metrics.csv",
			"results/ensemble_structure/final/all_mtr.csv"

elif config["run"]["single_structure_modality"] == True & config["run"]["ensemble_structure_modality"] == False:
	rule all:
		input:
			"results/single_structure/final/all_transcript_summary_metrics.csv",
			"results/single_structure/final/all_mtr.csv"

elif config["run"]["single_structure_modality"] == False & config["run"]["ensemble_structure_modality"] == True:
	rule all:
		input:
			"results/ensemble_structure/final/all_transcript_summary_metrics.csv",
			"results/ensemble_structure/final/all_mtr.csv"

if config["run"]["single_structure_modality"] == True & config["run"]["ensemble_structure_modality"] == True:
	include: "rules/single_structure/utils.smk"
	include: "rules/single_structure/structural_contacts.smk"
        include: "rules/single_structure/community_detection.smk"
        include: "rules/single_structure/mtr.smk"
        include: "rules/single_structure/single_structure_metrics.smk"
	include: "rules/ensemble_structure/utils.smk"
	include: "rules/ensemble_structure/structural_contacts.smk"
        include: "rules/ensemble_structure/community_detection.smk"
        include: "rules/ensemble_structure/mtr.smk"
        include: "rules/ensemble_structure/ensemble_structure_metrics.smk"

elif config["run"]["single_structure_modality"] == True & config["run"]["ensemble_structure_modality"] == False:
	include: "rules/single_structure/utils.smk"
	include: "rules/single_structure/structural_contacts.smk"
	include: "rules/single_structure/community_detection.smk"
	include: "rules/single_structure/mtr.smk"
	include: "rules/single_structure/single_structure_metrics.smk"

elif config["run"]["single_structure_modality"] == False & config["run"]["ensemble_structure_modality"] == True:
	include: "rules/ensemble_structure/utils.smk"
        include: "rules/ensemble_structure/structural_contacts.smk"
        include: "rules/ensemble_structure/community_detection.smk"
        include: "rules/ensemble_structure/mtr.smk"
	include: "rules/ensemble_structure/ensemble_structure_metrics.smk"

