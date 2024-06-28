#!/bin/bash

# Directory variables
HOME_PATH=/media/samba/alexandros/analysis
FASTQ_PATH=/media/samba/alexandros/fastq_files/fastq_files_umi-extracted
BAM_PATH=$FASTQ_PATH/hisat_files #the dir inside home_path dir, where hisat2 output files will be stored 

# Command tool variables
SAMTOOLS_COMMAND=/opt/ngstools/samtools/samtools
HISAT2_COMMAND=/home/alexandros/tools/hisat2/hisat2-2.1.0/hisat2 #path to hisat2 alignment command
BOWTIE2_COMMAND=/opt/ngstools/bowtie2/bowtie2
BEDTOOLS_COMMAND=/home/alexandros/tools/bedtools2/bin/bedtools

# Reference Genome Index
HISAT2_INDEX=/home/alexandros/tools/hisat2/hisat2-2.1.0/indexes/mm10/genome 

#Bowtie Index
BOWTIE2_INDEX=/media/raid/resources/igenomes/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/genome # the path and lastly the basename where ref.genome index is stored

# Organism; just for reference as it is not used anywhere 
ORG=mm10

# Number of cores to use
CORES=20


mkdir -p $BAM_PATH
#Execute HISAT2
for FILE in `ls $FASTQ_PATH/*_1.fq.gz`
do
    SAMPLE=`basename $FILE | sed s/_ext_1\.fq.gz//`
    echo "===== Mapping with hisat2 for $SAMPLE..."
    $HISAT2_COMMAND -p $CORES \
        --un-conc $BAM_PATH/unmapped.fastq \
        -x $HISAT2_INDEX \
        -1 $FASTQ_PATH/$SAMPLE"_ext_1.fq.gz" \
        -2 $FASTQ_PATH/$SAMPLE"_ext_2.fq.gz" \
        -S $BAM_PATH/hisat2.sam \
        --no-unal \
        --no-mixed \
        --no-discordant
    echo " "
    
    echo "===== Trying to map unmapped reads with bowtie2 for $SAMPLE..."
    $BOWTIE2_COMMAND --local \
        --very-sensitive-local --dovetail \
        -p $CORES -x $BOWTIE2_INDEX \
        -1 $BAM_PATH/unmapped.1.fastq \
        -2 $BAM_PATH/unmapped.2.fastq | \
        $SAMTOOLS_COMMAND view -bhS \
        -o $BAM_PATH/unmapped_remap.uns -
    
    echo "===== Merging all reads for $SAMPLE..." 
    $SAMTOOLS_COMMAND view \
        -bhS $BAM_PATH/hisat2.sam > \
        $BAM_PATH/hisat2.bam
    $SAMTOOLS_COMMAND merge \
        -f $BAM_PATH/$SAMPLE".tmb" \
        $BAM_PATH/hisat2.bam \
        $BAM_PATH/unmapped_remap.uns
    
    echo "===== Coordinate sorting all reads for $SAMPLE..."
    $SAMTOOLS_COMMAND sort $BAM_PATH/$SAMPLE".tmb" > $BAM_PATH/$SAMPLE".bam"
    $SAMTOOLS_COMMAND index $BAM_PATH/$SAMPLE".bam"
    
    echo "===== Removing intermediate garbage for $SAMPLE..."
    rm $BAM_PATH/hisat2.bam \
        $BAM_PATH/hisat2.sam \
        $BAM_PATH/unmapped*.fastq \
        $BAM_PATH/unmapped_remap.uns \
        $BAM_PATH/$SAMPLE".tmb"
    echo " "
done
