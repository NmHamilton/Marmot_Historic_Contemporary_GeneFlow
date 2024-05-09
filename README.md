# Marmot-Historic-Contemporary-GeneFlow
This contains code for data analysis for research on gene flow among PNW marmot species


## Contents
- [Ultraconserved Element Processing](#Ultraconserved-Element-Processing)
  - [Installing Phyluce](#installing-phyluce)
  - [Calling snps](#Calling-snps)
    - [Choose reference individual](#Choose-reference-individual)
    - [BWA mapping](#BWA-mapping)
## Ultraconserved Element Processing
### Installing Phyluce
The first step of this project is to install phyluce wherever you are using it. 
This code was created using environments from University of Alaska Fairbanks "Chinook", different clusters will likely have slightly different commands. 
```
wget https://raw.githubusercontent.com/faircloth-lab/phyluce/v1.7.1/distrib/phyluce-1.7.1-py36-Linux-conda.yml
```
On the HPRC cluster, I created phyluce as its own environmnet and this is how I call it. (It will need to be activate before you can use any of the Phyluce commands)
```
module load Anaconda/3-5.0.0.1
source activate phyluce-1.7.1
```
## Calling snps
This workflow was adapted from the UCE-snp calling workflow in this publication: https://onlinelibrary.wiley.com/doi/full/10.1111/1755-0998.13241
Original bash scripts from paper can be found here: https://github.com/zarzamora23/SNPs_from_UCEs

## Choose reference individual 
First step is to choose an individual with the most contigs to use as the reference individual for calling snps. 
I chose Marmota monax as the reference individual from the entire UCE dataset. 

Create a config file named ref.conf
```
[ref]
Name_of_reference_individual
```
Run phyluce program to create a list of all loci present in the reference individual
```
phyluce_assembly_get_match_counts \
--locus-db path-to/4_uce-search-results/probe.matches.sqlite \
--taxon-list-config path-to-working-directory/snp_calling/ref.conf \
--taxon-group ref \
--output path-to-working-directory/snp_calling/ref-ONLY.conf
```
Then run phyluce to create a fasta file of loci present in the reference individual
```
phyluce_assembly_get_fastas_from_match_counts \
--contigs path-to/3_spades-assemblies/contigs \
--locus-db path-to/4_uce-search-results/probe.matches.sqlite \
--match-count-output path-to-working-directory/snp_calling/ref-ONLY.conf \
--output path-to-working-directory/snp-calling/ref-ONLY.fasta
```

Copy clean reads to a new directory so that you don't accidentally mess them up !!!
```
cp path-to/2_clean-fastq path-to-working-directory/snp-calling/2_clean-fastq
```
## BWA mapping
Run the BWA mapping loop on all files, source = https://github.com/zarzamora23/SNPs_from_UCEs/blob/master/1a_0_bwa_mapping_loop.sh
My Script : [1_bwa_mapping_loop.sh](Scripts/1_bwa_mapping_loop.sh)

Software needed for this: 
[bwa](https://github.com/lh3/bwa)

