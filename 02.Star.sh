# Increase the max number of open file descriptors (for STAR)
ulimit -n 65535

# Define paths and tools
FASTQ_PATH="/home/analysis/fastq_files"
starGenomeDir="/home/star/mm10_indices/"
align_out_dir="/home/analysis/bam_files_bef"
SAMTOOLS='which samtools'
SAMTOOLS=$(which samtools)
STAR=$(which star)

# Make output directory if not exists
mkdir -p "$align_out_dir"

# Align reads with STAR
for FILE in "${FASTQ_PATH}"/*_1.fastq.gz
do
SAMPLE=$(basename "$FILE" | sed 's/\_1.fastq\.gz//')
rd1_fq="${FASTQ_PATH}/${SAMPLE}_1.fastq.gz"
rd2_fq="${FASTQ_PATH}/${SAMPLE}_2.fastq.gz"

 echo "===== Aligning $SAMPLE..."

"$STAR" --runThreadN $CORES  --peOverlapNbasesMin 40 --peOverlapMMp 0.8 --readFilesCommand zcat --genomeDir $starGenomeDir --readFilesIn ${rd1_fq} ${rd2_fq} --outFilterType BySJout \
		     --outFilterMultimapNmax 200 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.6 --alignIntronMin 20 --alignIntronMax 1000000 \
		     --alignMatesGapMax 1000000 --outSAMattributes NH HI NM MD --outSAMtype BAM SortedByCoordinate --outFileNamePrefix "${align_out_dir%/}/${SAMPLE}_" \
		     --limitBAMsortRAM 25000000000 --limitIObufferSize 200000000 200000000 --limitOutSJcollapsed 5000000 --seedPerWindowNmax 10
done

for BAM_FILE in "${align_out_dir%/}"/*.bam
do
"$SAMTOOLS" index -@ $CORES $BAM_FILE
done
