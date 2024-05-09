#The GATK uses two files to access and safety check access to the reference files: 
# .dict dictionary of the contig names and sizes 
# .fai fasta index file to allow efficient random access to the reference bases. 
#prepare fasta file to use as reference with picard and samtools. 
module load Java/1.8.0
java -Xmx48g -jar /user/picard-tools-1.119/CreateSequenceDictionary.jar  R=/path-to-working-directory/snp-calling/ref-ONLY.fasta  O=ref-ONLY.dict 
samtools faidx /path-to-working-directory/snp-calling/ref-ONLY.fasta

#realigning the mapping produced with BWA with a gap penalty B=10. The minimum number of reads per locus was set to 10
REFERENCE=/path-to-working-directory/snp-calling/ref-ONLY.fasta
DEDUP_BAMS=/path-to-working-directory/snp-calling/*All_dedup.bam


for sample in $DEDUP_BAMS
do 
#taxon or sample we are working now
    echo "Processing $sample"
#create a variable with the sample name using the name of the dedup bam file. We use the cut command, using the character '/' as field delimiter.     
    DEDUPBAMNAME=$(echo $sample | cut -d/ -f4)
    DEDUPBASENAME=$(echo $DEDUPBAMNAME | cut -d. -f1)
#create the name of intervals file    
    INTERVALS_NAME=$DEDUPBASENAME'.intervals'
    echo $INTERVALS_NAME
#create output realigned bams
    REALIGNED_NAME=$DEDUPBASENAME'_realigned.bam'
    echo $REALIGNED_NAME
#execute the command in GATK to create intervals and realign reads
   
   eval $(echo "java -Xmx4g -jar /user/GenomeAnalysisTK-3.8-1-0/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $REFERENCE -o $INTERVALS_NAME -I $sample --minReadsAtLocus 10")
   eval $(echo "java -Xmx4g -jar /user/GenomeAnalysisTK-3.8-1-0/GenomeAnalysisTK.jar -T IndelRealigner -R $REFERENCE -I $sample -targetIntervals $INTERVALS_NAME  -o $REALIGNED_NAME -LOD 3.0")
    
done
