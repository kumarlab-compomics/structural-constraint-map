
rule ensemble_calculate_mtr:
        input:
                walktrap_output = "results/ensemble_structure/walktrap_output/{sample}_walktrap-output.txt",
        output:
                "results/ensemble_structure/mtr/{sample}_mtr.csv"
        params: gnomad_mutations = config["mtr_data"]["gnomad_mutations_path"],
                cadd_mutations = config["mtr_data"]["cadd_mutations_path"],
                gnomad_coverage = config["mtr_data"]["gnomad_coverage_path"],
                chrom=get_chr,
                transcript = "{sample}"
        resources:
                mem_mb=5000,
                time="01:00:00"
        shell: """
                source ~/envs/clustering/bin/activate
                python ~/structural-constraint-map/scripts/MTR/calculate_mtr.py {params.transcript} {params.gnomad_mutations}/missense/gnomad.union.v4.1.sites.SNP.INFOvep.PASS.expanded.missense.chr{params.chrom}.vcf \
                {params.gnomad_mutations}/synonymous/gnomad.union.v4.1.sites.SNP.INFOvep.PASS.expanded.synonymous.chr{params.chrom}.vcf {input.walktrap_output} {params.cadd_mutations}/cadd_chr{params.chrom}_missense.tsv \
                {params.cadd_mutations}/cadd_chr{params.chrom}_synonymous.tsv {params.gnomad_coverage}/exomes/chr{params.chrom}_gnomAD_v4.1.0_coverage.tsv {params.gnomad_coverage}/genomes/chr{params.chrom}_gnomAD_v4.1.0_coverage.tsv \
                {output}
        """

rule ensemble_create_mtr_file:
        input:
                "results/ensemble_structure/walktrap_output/{sample}_walktrap-output.txt"
        output:
                "results/ensemble_structure/mtr/{sample}_mtr.csv"
        shell: """
                touch {output}
        """

rule ensemble_concatenate_mtr:
        input:
                mtrs=[expand("results/ensemble_structure/mtr/{sample}_mtr.csv".format(sample=s)) for s in samples.index]
        output:
                "results/ensemble_structure/final/all_mtr.csv"
        shell: """
                cat {input} > {output}
        """
