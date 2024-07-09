
# =====================================================================
# Variant calling with MUTECT2 - tumor-only mode for normal samples
# =====================================================================
path_to_fasta=/media/tronghieu/GSHD_HN01/annotation_resources/HG38DIR/hg38_selected.fa;
export PATH=/home/tronghieu/samtools/bin:$PATH;

# CRC SAMPLES! --------------------------------------------------------
# INPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM;
# OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2;
# ---------------------------------------------------------------------

# LBH SAMPLES! --------------------------------------------------------
INPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/LBH_BAM;
OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/LBH_VCF_MUTECT2;
# ---------------------------------------------------------------------

mkdir -p $OUTPUTDIR;
for sampletype in LB;do \
    echo -e "****************************************************************** \n";
    echo -e "WORKING ON" $sampletype "\n";
    echo -e "****************************************************************** \n";
    ALL_BAM_FILES=$(ls ${INPUTDIR}/${sampletype}/*.bam | xargs -n 1 basename);
    OUTPUT_VCF_DIR=${OUTPUTDIR}/${sampletype};
    mkdir -p $OUTPUT_VCF_DIR;
    parallel -j 6 --memfree 8G gatk Mutect2 -R $path_to_fasta -I ${INPUTDIR}/${sampletype}/{} --max-mnp-distance 0 -tumor {.} -O $OUTPUT_VCF_DIR/{.}.vcf.gz ::: $ALL_BAM_FILES;
    done


    
