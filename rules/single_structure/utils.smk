
def get_pdb_file(wildcards):
    return glob(f"data/alphafold2/{wildcards.sample}*.pdb")

def get_chr(wildcards):
        gene = wildcards.sample.split('_')[1]
        script_path = os.path.expanduser("~/structural-constraint-map/scripts/MTR/get_chr_from_gene.py")
        out = subprocess.run(["python", script_path, gene], capture_output=True, text=True)
        chrom = out.stdout
        return str(chrom).strip()

samples = pd.read_table(config["run"]["single_samples"]).set_index("sample", drop=False)
