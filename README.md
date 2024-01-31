# Marmot-Historic-Contemporary-GeneFlow
This contains code for data analysis for research on gene flow among PNW marmot species


## Contents
- [Ultraconserved Element Processing](#Ultraconserved-Element-Processing)
  - [Installing Phyluce](#installing-phyluce)
  - [Calling snps](#Calling-snps)
    - [Choose reference individual](#Choose-reference-individual)
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

