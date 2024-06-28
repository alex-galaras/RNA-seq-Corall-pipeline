HOME_PATH=/media/samba/alexandros/analysis
NORMALIZE=normalize_bedgraph.pl #File provided in the repository
BAM_DIR=$HOME_PATH/bam_umi_dedup
BEDGRAPH_DIR=$BAM_DIR/bedgraphs
BIGWIG_DIR=$BAM_DIR/bigwigs
CORES=24
LINK=http://epigenomics.fleming.gr/~alexandros/
BEDTOOLS=$(command -v bedtools)
KENTTOOLS=/home/alexandros/tools/bedGraphToBigWig
GENOME=/media/raid/resources/igenomes/Mus_musculus/UCSC/mm10/Annotation/Genes/ChromInfo.txt

mkdir -p $BEDGRAPH_DIR
mkdir -p $BIGWIG_DIR

for FILE in $BAM_DIR/*.bam
do
SAMPLE=`basename $FILE | sed s/\.bam//`

#### First mate
# First mate - forward strand
# Flags: -f 64 (first read in pair), -F 16 (exclude reverse strand reads)
samtools view -@ $CORES -bh -f64 -F16 $FILE > mate1_forward.bam    # Create BAM for first read in pair mapped to forward strand
samtools index -@ $CORES mate1_forward.bam                        # Index the BAM file

# First mate - reverse strand
# Flags: -f 80 (first read in pair & reverse strand)
samtools view -bh -@ $CORES -f80 $FILE > mate1_reverse.bam   # Create BAM for second read in pair mapped to forward strand
samtools index -@ $CORES mate1_reverse.bam                        # Index the BAM file

#### Second mate

# Second mate - forward strand
# Flags: -f 128 (second read in pair), -F 16 (exclude reverse strand reads)
samtools view -bh -@ $CORES -f128 -F16 $FILE > mate2_forward.bam           # Create BAM for second read in pair mapped to forward strand
samtools index -@ $CORES mate2_forward.bam                                # Index the BAM file

# Second mate - reverse strand
# Flags: -f 144 (second read in pair, mapped to reverse strand)
samtools view -bh -@ $CORES -f144 $FILE > mate2_reverse.bam               # Create BAM for second read in pair mapped to reverse strand
samtools index -@ $CORES mate2_reverse.bam                               # Index the BAM file

###Merge
samtools merge -@ $CORES $SAMPLE"_for.bam" mate1_forward.bam mate2_reverse.bam
samtools merge -@ $CORES $SAMPLE"_rev.bam" mate1_reverse.bam mate2_forward.bam

#### tracks
$BEDTOOLS genomecov -bg -split -ibam $SAMPLE"_for.bam" | grep -vP 'chrJH|chrMT|chrGL|_GL|_JH'  | sort -k1,1 -k2g,2 > $SAMPLE".plus.bedGraph" 

$BEDTOOLS genomecov -bg -split -ibam $SAMPLE"_rev.bam" | grep -vP 'chrJH|chrMT|chrGL|_GL|_JH' | sort -k1,1 -k2g,2 | awk '{ print $1"\t"$2"\t"$3"\t-"$4 }' > $SAMPLE".minus.bedGraph" 


#Normalize

perl $NORMALIZE --input $SAMPLE".plus.bedGraph" --sumto 500000000 --exportfactors p_normfactors.txt --ncores 8

perl $NORMALIZE --input $SAMPLE".minus.bedGraph" --sumto -500000000 --exportfactors m_normfactors.txt --ncores 8

#Create bigwig files for every bedGraph

for FILE in *_norm.bedGraph
do
	SAMPLE=`basename $FILE | sed s/\.bedGraph//`
	$KENTTOOLS/bedGraphToBigWig $FILE $GENOME $SAMPLE".bigWig"
done

for FILE in *.plus_norm.bigWig
do
    SAMPLE=`basename $FILE | sed s/\.plus_norm.bigWig//`

    echo "
track $SAMPLE"_stranded"
container multiWig
aggregate transparentOverlay
showSubtrackColorOnUi on
shortLabel $SAMPLE
longLabel $SAMPLE RNA-sequencing
boxedCfg on
autoScale on
maxHeightPixels 128:64:16
visibility full
type bigWig

track $SAMPLE"_plus"
parent $SAMPLE"_stranded"
type bigWig
bigDataUrl $LINK/$SAMPLE".plus_norm.bigWig"
color 255,0,0

track $SAMPLE"_minus"
parent $SAMPLE"_stranded"
type bigWig
bigDataUrl $LINK/$SAMPLE".minus_norm.bigWig"
color 153,0,0
" >> $BIGWIG_DIR/trackdb.txt
done

rm *for* *rev* *normfactors.txt


mv *.bedGraph $BEDGRAPH_DIR
mv *.bigWig $BIGWIG_DIR
done


