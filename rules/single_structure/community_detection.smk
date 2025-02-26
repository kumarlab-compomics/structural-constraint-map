
rule single_community_detection:
        input:
                "results/single_structure/walktrap_input/{sample}_contact-map.csv"
        output:
                "results/single_structure/walktrap_output/{sample}_walktrap-output.txt"
        shell: """
                source ~/envs/clustering/bin/activate
                python ~/structural-constraint-map/scripts/one-conformation/walktrap_translated_seq.py {input} {output}
        """
