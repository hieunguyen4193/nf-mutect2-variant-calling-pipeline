
# =====================================================================
# Variant calling with MUTECT2 - tumor-only mode for normal samples
# =====================================================================
path_to_fasta=/media/tronghieu/GSHD_HN01/annotation_resources/HG38DIR/hg38_selected.fa;


# CRC SAMPLES! --------------------------------------------------------
# INPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM;
# OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2;
# ---------------------------------------------------------------------

# LBH SAMPLES! --------------------------------------------------------
INPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/LBH_BAM/CONTROL;
OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/LBH_VCF_HAPLOTYPE/CONTROL;
# ---------------------------------------------------------------------
num_samples=$(ls $INPUTDIR/*.bam| wc -l);
echo -e "Number of samples in this set: " $num_samples "\n";
mkdir -p $OUTPUTDIR;
echo -e "****************************************************************** \n";
echo -e "WORKING ON" $sampletype "\n";
echo -e "****************************************************************** \n";
ALL_BAM_FILES=$(ls ${INPUTDIR}/*.bam | xargs -n 1 basename);
OUTPUT_VCF_DIR=${OUTPUTDIR};
mkdir -p $OUTPUT_VCF_DIR;
parallel -j 5 --memfree 8G gatk HaplotypeCaller -R $path_to_fasta -I ${INPUTDIR}/{} -O $OUTPUT_VCF_DIR/{.}.vcf.gz -ERC GVCF ::: $ALL_BAM_FILES;
