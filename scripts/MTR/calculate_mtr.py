import pandas as pd
from pathlib import Path
import os
import sys

SAMPLE = sys.argv[1]
GENCODE_ID = SAMPLE.split('_')[0]
GENE = SAMPLE.split('_')[-1]

##gnomAD
# Read mutation data into dataframes
fmis= sys.argv[2] # file containing missense mutation data of the chromosome on which the gene is found
fsyn= sys.argv[3] #file containing synonymous mutation data of the chromosome on which the gene is found

chunk_size = 10 ** 5
dfmis_t = []
dfsyn_t = []

# read in gnomAD files in chunks to reduce memory overhead
for mis_chunk_gnomad in pd.read_csv(fmis, chunksize=chunk_size, sep='\t', low_memory=False):
        dfmis_t.append(mis_chunk_gnomad[mis_chunk_gnomad['Feature'].str.contains(GENCODE_ID)])

dfmis_t = pd.concat(dfmis_t, ignore_index=True)

for syn_chunk_gnomad in pd.read_csv(fsyn, chunksize=chunk_size, sep='\t', low_memory=False):
        dfsyn_t.append(syn_chunk_gnomad[syn_chunk_gnomad['Feature'].str.contains(GENCODE_ID)])

dfsyn_t = pd.concat(dfsyn_t, ignore_index=True)


fclust = sys.argv[4]

# note: '_t' means 'transcript' e.g. df_mis_t means "dataframe containing missense mutations data of the transcript

# Read in and extract expected mutations related to the transcript
fmiscadd = sys.argv[5]
fsyncadd = sys.argv[6]

# read CADD chr files in chunks to keep memory overhead low
dfmiscadd_t = []
dfsyncadd_t = []

for mis_chunk in pd.read_csv(fmiscadd, chunksize=chunk_size, sep='\t', low_memory=False):
	dfmiscadd_t.append(mis_chunk[mis_chunk['FeatureID'].str.contains(GENCODE_ID)])

dfmiscadd_t = pd.concat(dfmiscadd_t, ignore_index=True)

for syn_chunk in pd.read_csv(fsyncadd, chunksize=chunk_size, sep='\t', low_memory=False):
	dfsyncadd_t.append(syn_chunk[syn_chunk['FeatureID'].str.contains(GENCODE_ID)])

dfsyncadd_t = pd.concat(dfsyncadd_t, ignore_index=True)

# read in coverage files
fcov_ex = sys.argv[7]
fcov_gen = sys.argv[8]

coverage_columns = ["#CHROM", "Pos", "mean", "median_approx", "total_DP", "over_1", "over_5", "over_10", "over_15", "over_20", "over_25", "over_30", "over_50", "over_100"]

dfcov_ex = []
dfcov_gen = []

lower_pos = min(dfmiscadd_t['Pos'].min(), dfsyncadd_t['Pos'].min())
upper_pos = max(dfmiscadd_t['Pos'].max(), dfsyncadd_t['Pos'].max())

for ex_cov_chunk in pd.read_csv(fcov_ex, chunksize=chunk_size, sep='\t', low_memory=False, names = coverage_columns):
	dfcov_ex.append(ex_cov_chunk[(ex_cov_chunk['Pos'] >= lower_pos) & (ex_cov_chunk['Pos'] <= upper_pos)])

dfcov_ex = pd.concat(dfcov_ex,ignore_index=True)

for gen_cov_chunk in pd.read_csv(fcov_gen, chunksize=chunk_size, sep='\t', low_memory=False, names=coverage_columns ):
	dfcov_gen.append(gen_cov_chunk[(gen_cov_chunk['Pos'] >= lower_pos) & (gen_cov_chunk['Pos'] <= upper_pos)])

dfcov_gen = pd.concat(dfcov_gen,ignore_index=True)

if ((dfmis_t.shape[0] == 0) and (dfsyn_t.shape[0] == 0)) and ((dfmiscadd_t.shape[0] == 0) and (dfsyncadd_t.shape[0] == 0)):
	print(SAMPLE + ",gnomad-and-cadd-Empty," + ",,,,,") # transcript is missing in both gnomAD and CADD files
elif ((dfmis_t.shape[0] == 0) and (dfsyn_t.shape[0] == 0)):
	print(SAMPLE + ",dfmis_t-dfsyn_t-Empty," + ",,,,,") # DECISION: For now, will keep cases where only either of missense or synonymous count is 0. This is because if we want to filter them out, we can once MTR is calculated, but we cannot recover them if we filter them out at this step.
elif ((dfmiscadd_t.shape[0] == 0) and (dfsyncadd_t.shape[0] == 0)):
	print(SAMPLE + ",dfmiscadd_t-dfsyncadd_t-Empty,"+ ",,,,,") # highlight transcripts that are missing in CADD file
else:
    # Skip mapping mutations if community detection result is not available
    # specify the file containing community detection output
	fclust_path = Path(fclust)
	if fclust_path.exists() == False:
		print(SAMPLE + ",cmty_detection_output_DNE," + ",,,,,") #DNE = "Does Not Exist"
	else:
		 # Read clustering result of the sample
		dfclust = pd.read_csv(fclust, sep=',', names=['idx', 'clusterID'])
		mis_obs_counts = dfmis_t['Protein_position'].value_counts()
		syn_obs_counts = dfsyn_t['Protein_position'].value_counts()
		
		# format missense in data frame
		df_mis_obs_counts = mis_obs_counts.reset_index()
		df_mis_obs_counts.columns = ['idx', 'mis_obs']
		df_mis_obs_counts = df_mis_obs_counts.set_index('idx')
		
		#format syn in data frame
		df_syn_obs_counts = syn_obs_counts.reset_index()
		df_syn_obs_counts.columns = ['idx', 'syn_obs']
		df_syn_obs_counts = df_syn_obs_counts.set_index('idx')
		
		dfclust = dfclust.set_index('idx')
		
		dfclust = pd.concat([dfclust, df_mis_obs_counts, df_syn_obs_counts], axis=1).reindex(dfclust.index)
		
		dfclust['mis_obs'] = dfclust['mis_obs'].fillna(0)
		dfclust['syn_obs'] = dfclust['syn_obs'].fillna(0)
		
		community_obs = dfclust.groupby(['clusterID']).sum()
		
		# EXPECTED
		
		# join in exome coverage to expected variants from CADD
		dfmiscadd_t = dfmiscadd_t.merge(dfcov_ex, how='left', on='Pos')
		dfsyncadd_t = dfsyncadd_t.merge(dfcov_ex, how='left', on='Pos')
		
		# join in genome coverage to expected variants from CADD
		dfmiscadd_t = dfmiscadd_t.merge(dfcov_gen, how='left', on='Pos')
		dfsyncadd_t = dfsyncadd_t.merge(dfcov_gen, how='left', on='Pos')
		
		# filter to keep only expected variants in a region with 10X coverage in at least 80% of the exomes or genomes
		dfmiscadd_t = dfmiscadd_t[(dfmiscadd_t['over_10_x'] >= 0.8) | (dfmiscadd_t['over_10_y'] >= 0.8)]
		dfsyncadd_t = dfsyncadd_t[(dfsyncadd_t['over_10_x'] >= 0.8) |  (dfsyncadd_t['over_10_y'] >= 0.8)]
		
		# count variants at each protein position
		mis_exp_counts = dfmiscadd_t['protPos'].value_counts()
		syn_exp_counts = dfsyncadd_t['protPos'].value_counts()
		
		df_mis_exp_counts = mis_exp_counts.reset_index()
		df_mis_exp_counts.columns = ['idx', 'mis_exp']
		df_mis_exp_counts = df_mis_exp_counts.set_index('idx')
		
		df_syn_exp_counts = syn_exp_counts.reset_index()
		df_syn_exp_counts.columns = ['idx', 'syn_exp']
		df_syn_exp_counts = df_syn_exp_counts.set_index('idx')
		
		dfclust = pd.read_csv(fclust, sep=',', names=['idx', 'clusterID'])
		dfclust = dfclust.set_index('idx')
		
		dfclust = pd.concat([dfclust, df_mis_exp_counts, df_syn_exp_counts], axis=1)
		
		dfclust['mis_exp'] = dfclust['mis_exp'].fillna(0)
		dfclust['syn_exp'] = dfclust['syn_exp'].fillna(0)
		
		community_exp = dfclust.groupby(['clusterID']).sum()
		
		# MTR
		
		combined = pd.concat([community_obs, community_exp], axis=1).reindex(community_obs.index)
		combined['denom_obs'] = combined['mis_obs'] + combined['syn_obs']
		combined['MTR_num'] = combined.apply(lambda row: row['mis_obs'] / row['denom_obs'] if row['denom_obs'] != 0 else 0, axis=1)
		#combined['MTR_num'] = combined['mis_obs'] / combined['denom_obs']
		combined['denom_exp'] = combined['mis_exp'] + combined['syn_exp']
		combined['MTR_denom'] = combined.apply(lambda row: row['mis_exp'] / row['denom_exp'] if row['denom_exp'] != 0 else 0, axis=1)
		#combined['MTR_denom'] = combined['mis_exp'] / combined['denom_exp']
		combined['MTR'] = combined.apply(lambda row: row['MTR_num'] / row['MTR_denom'] if row['MTR_denom'] != 0 else 'div0', axis=1)
		#combined['MTR'] = combined['MTR_num'] / combined['MTR_denom']
		combined = combined.drop(columns=['denom_obs', 'MTR_num', 'denom_exp', 'MTR_denom'])

		# add in sample name output designator lines
		
		combined = combined.reset_index()
		
		name_col_num = 0
		new_col = [7, 8, 9]
		combined.insert(loc=name_col_num, column='SAMPLE', value=SAMPLE)
		
		output_col_num = 1
		new_col = "Output line"
		combined.insert(loc=output_col_num, column='Output', value=new_col)
		
		combined.to_csv(sys.argv[9], index=False, header = False)  
