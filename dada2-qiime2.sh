#dada2-qiime2.sh

#NOTE: The first few steps must be completed within a virtual machine with SBanalyzer from ShorelineBiome. We are using SBanalyzer version 3.1-3.

#Demultiplex samples using the SBanalyzer GUI. Use the "Demux-NoTrim.txt" pipeline.

#Run sb-dada2 within the ShorelineBiome virtual machine.
sb-dada2 -n Run1 -i SequencingRun1 -s StrainID -c 1e-120

#Assign taxonomy with Athena database within the ShorelineBiome virtual machine.
/opt/sbanalyzer/bin/sbsearch \
--mode Search --seqs test.fasta \
--db /home/shoreline/Documents/SBanalyzer_Master/.user_lib/lib/athena_v2_2/index.bin \
--tax /home/shoreline/Documents/SBanalyzer_Master/.user_lib/lib/athena_v2_2/athena_v2_2.tax \
-op /home/shoreline/Documents/

#The following steps can also be run in the virtual machine, or can be run outside of it.

#Installing Qiime2
#First, update miniconda
conda update conda

#Next, install the correct version of qiime2 (these commands are for macOS)
wget https://data.qiime2.org/distro/core/qiime2-2021.8-py38-osx-conda.yml
conda env create -n qiime2-2021.8 --file qiime2-2021.8-py38-osx-conda.yml
rm qiime2-2021.8-py38-osx-conda.yml

#Activate qiime2
conda activate qiime2-2021.8

#Next, import the data into qiime2
qiime tools import \
  --input-path Run1_sequence_table_nochiR.biom \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV100Format \
  --output-path table.qza

qiime tools import \
  --input-path un1_ASVs_only_nochiR_md5.fasta \
  --output-path rep-seqs.qza \
  --type 'FeatureData[Sequence]'
  
qiime tools import \
  --input-path taxonomy.tax \
  --output-path taxonomy.qza \
  --type 'FeatureData[Taxonomy]'


#Create visualizations of the table and rep-seqs files to view at https://view.qiime2.org/. The file "table.qzv" will help pick a rarefaction depth.
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file metadata.txt

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

#Use a filtered metadata file to remove any unwanted samples
qiime feature-table filter-samples \
  --i-table table.qza \
  --m-metadata-file metadata_filter.txt \
  --o-filtered-table filtered-table.qza

#Create phylogenetic trees based on the rep-seqs file.
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

#Move to R for further analysis and visualizations.