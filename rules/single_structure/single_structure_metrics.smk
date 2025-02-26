
rule single_summary_metrics:
        input:
                pdb=get_pdb_file,
                walktrap_input = "results/single_structure/walktrap_input/{sample}_contact-map.csv",
                walktrap_output = "results/single_structure/walktrap_output/{sample}_walktrap-output.txt"
        output:
                "results/single_structure/transcript_summaries/{sample}_summary-metrics.csv"
        shell: """
                source ~/envs/clustering/bin/activate
                python ~/structural-constraint-map/scripts/one-conformation/summarize_communities_SINGLE.py -p {input.pdb} -i {input.walktrap_input} -c {input.walktrap_output} -o {output}
        """

rule single_concatenate_summary_metrics:
        input:
                summaries=[expand("results/single_structure/transcript_summaries/{sample}_summary-metrics.csv".format(sample=s)) for s in samples.index]
        output:
                "results/single_structure/final/all_transcript_summary_metrics.csv"
        shell: """
                cat {input} > {output}
        """
