# Marmot-Historic-Contemporary-GeneFlow
This contains code for data analysis for research on gene flow among PNW marmot species


## Contents
- [Ultraconserved Element Processing](#Ultraconserved-Element-Processing)
  - [Installing Phyluce](#installing-phyluce)
  - [Calling snps](#Calling-snps)
    - [Choose reference individual](#Choose-reference-individual)
    - [BWA mapping](#BWA-mapping)
    - [Indel realigner](#Indel-realigner)
    - [Genotype recall](#Genotype-recall)
  - [PhyloNetworks](#PhyloNetworks)
    - [IQTREES](#IQTREES)
    - [SNAQ](#SNAQ)
  - [Dsuite](#Dsuite)
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

## Indel realigner
Run the indel realigner script, source = https://github.com/zarzamora23/SNPs_from_UCEs/blob/master/2_indelrealigner-WLET_copy.sh
My Script : [2_indelrealigner.sh](Scripts/2_indelrealigner.sh)

You will need to use GATK 3.8.1.0

## Genotype recall
Run the genotype recall script, source = https://github.com/zarzamora23/SNPs_from_UCEs/blob/master/3_genotype-recal-WLET_copy.sh
My Script: [3_Genotype_recall.sh](Scripts/3_Genotype_recall.sh)

You will need to use GATK 3.46
Change thresholds and filters as needed. 

## PhyloNetworks
As input data into SNAQ, I used gene trees for each locus, estimated with IQTREE. I used the 75% complete UCE dataset, which included only those loci that were present in at least 75% of individuals. 
## IQTREES
Loop for making gene trees, using the phyluce IQTREE software
```
#!bin/bash
for file in *.nexus; do
    if [[ -e "${file%.nexus}.contree" ]]; then
        echo "$file done"
    else
        iqtree -s "$file" -bb 1000 -m GTR -nt 4
    fi
done
```
As input for SNAQ, you will want to concatenate the gene trees and use a guide tree which you can make from ASTRAL or iqtree of 75% matrix.
```
cat *.contree > Marmot_genetrees.tre
```

## SNAQ
To install SNAQ after being in the Julia environment
```
using Pkg
Pkg.add("PhyloNetworks")
Pkg.add("PhyloPlots")
```
To add trees to environment and summarize them by quartets
```
using PhyloNetworks, PhyloPlots
genetrees = readMultiTopology("Marmot_genetrees.tre")
speciestree = readTopologyLevel1("IQTREE-75p.contree")
q,t = countquartetsintrees(genetrees);
df = writeTableCF(q,t)
using CSV
CSV.write("tableCF.csv", df); 
```

Then you can run different scenarios, allowing different amounts of hybridization
The first, hnet=0 can be a starting network to see if the topology is the same as the topology you got from IQTREE

```
iqtreeCF = readTableCF("tableCF.csv")
net0 = snaq!(speciestree, iqtreeCF, hmax=0, filename="marmot.net0", seed=1234)
```
You can choose ot use the output from other runs as input into later SNAQ runs, an example of using the net0 as net1 input, you can use net1 as net2 input and so forth
```
net1 = snaq!(net0, iqtreeCF, hmax=1, filename="marmot.net1", seed=1235)
```
To visualize the networks, you can read in the results and use PhyloPlots and RCall
I like to root the tree on the outgroup to make visualization easier
```
using PhyloPlots, RCall
net2=readMultiTopology("Marmot.net2.networks")
net2rooted= rootatnode!(net2[1], "FLV_UAM112562")
R"pdf"("Marmot_Hybrid2.pdf")
plot(net2rooted, shownodenumber=true)
R"dev.off()"
```
As you can see here, the lines overlap the tree, so we can rotate the nodes to make this less messy 

<img width="554" alt="Screen Shot 2024-05-09 at 1 38 03 PM" src="https://github.com/NmHamilton/Marmot_Historic_Contemporary_GeneFlow/assets/29608081/41c3120c-f0ba-4116-8a2d-963907c30f33">

```
rotate!(net2rooted, 17)
rotate!(net2rooted, 14)
rotate!(net2rooted, 18)
rotate!(net2rooted, 19)
```

![Screen Shot 2024-05-09 at 2 31 37 PM](https://github.com/NmHamilton/Marmot_Historic_Contemporary_GeneFlow/assets/29608081/0b79df72-6148-445e-ad74-948a8b8ba697)

Okay now this looks better, and we can put the gamma information. 
```
R"pdf"("Marmot_net2_rotated.pdf")
plot(net2rooted, showgamma=true);
R"dev.off()"
```
![Screen Shot 2024-05-09 at 2 33 33 PM](https://github.com/NmHamilton/Marmot_Historic_Contemporary_GeneFlow/assets/29608081/2d4492c9-f6e1-467b-97b6-5f61c5a5fed8)

I edited the final image in illustrator because futzing around with the settings in R/Julia was more annoying. 
![Screen Shot 2024-05-09 at 2 36 36 PM](https://github.com/NmHamilton/Marmot_Historic_Contemporary_GeneFlow/assets/29608081/b540e641-1094-4c64-b689-4d2f6f0a5b9e)

## Dsuite
Dsuite uses ABBA-BABA statistics to infer ancestral gene flow. 
The input is a vcf file from calling SNPs that is further filtered to reflect one biallelic SNP per locus. 
```
vcftools --vcf genotyped_X_samples_only_PASS_snp_5th.vcf --min-alleles 2 --max-alleles 2 --thin 1000 --max-missing 0.75 --max-non-ref-af 0.99 --recode --out Marmot_filtered_vcf75p.vcf
```
We also need a 'map file that matches each specimen to a putative species. If you want to include an outgroup, must be labeled "outgroup"
You can also exclude individuals from the analysis by replacing the species name with "xxx" 
[Example file](Scripts/Files/Sets.txt)

To do fbranch stats, you'll need a species tree, which must be rooted using the Outgroup. 
```
Dsuite Dtrios -t Species.tre Marmot_filtered_vcf75p.vcf Sets.txt
```

With the output file Sets_tree.txt, you can run fbranch 
```
Dsuite Fbranch Species.tree Sets_tree.txt > Marmot_Fbranch.txt
```
This can be plotted with the python scripts that are included with a Dsuite installation
```
python dtools.py Marmot_Fbranch.txt
```

![Screen Shot 2024-05-10 at 8 50 36 AM](https://github.com/NmHamilton/Marmot_Historic_Contemporary_GeneFlow/assets/29608081/c35f0b4f-6bfb-4b03-a9ef-96e85bba3426)
