# structural-constraint-map
Building a constraint map that incorporates 3D protein structure and protein motion data.

### Usage

Clone repo into your home directory to use.  
Run the below command in a directory with your .pdb file. It will generate an output directory there with all the input/output and intermediate files.  

```
sh ~/structural-constraint-map/scripts/one-conformation/run_ring_to_walktrap.sh <.pdb> <bond_energy/contact> <path to activate of venv>
```

Will either generate edges using RING (for bond energies) or Contact Map Explorer (for contacts), run community detection using walktrap, then generate a re-written .pdb file with communities in the place of b-factors, to aid in faster visualization.   

If you want to run multiple samples, use the batch script:  

```
sh ~/structural-constraint-map/scripts/one-conformation/batch_run.sh <directory with pdb files> <bond_energy/contact> <path to activate of venv>
```

If you want to count the number of communities in a directory containing output from the runs above, run this:  

```
sh ~/structural-constraint-map/scripts/utils/get_num_communities.sh
```

If you want to create RMSD plots for the output from MD or AlphaFlow, run this:  

```
sh ~/structural-constraint-map/scripts/utils/rmsd_wrapper.sh <path to activate of venv>
```
