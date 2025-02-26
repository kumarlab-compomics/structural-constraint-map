
rule ensemble_contact_map:
        input:
                get_pdb_file
        output:
                "results/ensemble_structure/walktrap_input/{sample}_contact-map.csv"
        params: cutoff=float(config["run"]["threshold"])
        shell: """
                source ~/envs/clustering/bin/activate
                python ~/structural-constraint-map/scripts/one-conformation/get_contact_map_edges.py -p {input} -o {output} -c {params.cutoff}
        """
