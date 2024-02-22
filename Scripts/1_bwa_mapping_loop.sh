#Indexing reference library for outgroup Aphelocoma californica nevadae in current directory or copy previously indexed files *.amb,*.ann,*.bwt,*.pac,*.sa.

#Consider adding a line to remove *.sam files and *. sorted.bam to release disk space

bwa index -p contigs -a is path-to-working-directory/snp-calling/ref-ONLY.fasta


READS_FOLDER=/path-to-working-directory/snp-calling/2_clean-fastq/*

#run for loop for all samples. 

for folder in $READS_FOLDER
	do 
	echo $folder
#create sample name based on folder's name. Get path to folder and only keep last field (5th in my case)
#when my brain is tired, the easiest way to figure that out is to count the number of "/" and add one
	SAMPLE_NAME=$(echo $folder | cut -d/ -f5)
	echo $SAMPLE_NAME
	
#map reads with algorithm mem for illumina reads 70bp-1Mb; 
eval $(echo "bwa mem -B 10 -M -R '@RG\tID:$SAMPLE_NAME\tSM:$SAMPLE_NAME\tPL:Illumina' contigs $folder/split-adapter-quality-trimmed/$SAMPLE_NAME-READ1.fastq.gz $folder/split-adapter-quality-trimmed/$SAMPLE_NAME-READ2.fastq.gz > $SAMPLE_NAME.pair.sam") 
eval $(echo "bwa mem -B 10 -M -R '@RG\tID:$SAMPLE_NAME\tSM:$SAMPLE_NAME\tPL:Illumina' contigs $folder/split-adapter-quality-trimmed/$SAMPLE_NAME-READ-singleton.fastq.gz > $SAMPLE_NAME.single.sam") 

#sort reads
eval $(echo "samtools view -bS $SAMPLE_NAME.pair.sam| samtools sort -m 30000000000 -o $SAMPLE_NAME.pair_sorted.bam")
eval $(echo "samtools view -bS $SAMPLE_NAME.single.sam | samtools sort -m 30000000000 -o $SAMPLE_NAME.single_sorted.bam")

#mark duplicates
eval $(echo "java -Xmx2g -jar /path-to-software/picard-tools-1.119/MarkDuplicates.jar INPUT=$SAMPLE_NAME.pair_sorted.bam INPUT=$SAMPLE_NAME.single_sorted.bam OUTPUT=$SAMPLE_NAME.All_dedup.bam METRICS_FILE=$SAMPLE_NAME.All_dedup_metricsfile MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=250 ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=True")

#index bam file
eval $(echo "java -Xmx2g -jar /path-to-software/picard-tools-1.119/BuildBamIndex.jar INPUT=$SAMPLE_NAME.All_dedup.bam")

eval $(echo "samtools flagstat $SAMPLE_NAME.All_dedup.bam > $SAMPLE_NAME.All_dedup_stats.txt")


#get stats only for paired files before removing duplicates
#eval $(echo "samtools flagstat $SAMPLE_NAME.pair_sorted.bam > $SAMPLE_NAME.pair_stats.txt")

#get depth with samtool. Denominator should be the length of the genome used as reference, in this case navadae sequences add up 2890195; calculated with: samtools view -H *bamfile* | grep -P '^@SQ' | cut -f 3 -d ':' | awk '{sum+=$1} END {print sum}'

samtools depth $SAMPLE_NAME.All_dedup.bam  |  awk '{sum+=$3; sumsq+=$3*$3} END { print  "Average = ",sum/2890195; print "Stdev = ",sqrt(sumsq/2890195 - (sum/2890195)**2)}' >> depth_stats.txt

done

#rm *.sam
#rm  *sorted.bam
