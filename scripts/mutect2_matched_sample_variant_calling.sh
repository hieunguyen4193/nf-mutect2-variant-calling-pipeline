# =====================================================================
# Variant calling for matched-sample with panel of normal variants. 
# =====================================================================

while getopts i: flag
do
    case "${flag}" in
        i) idx=${OPTARG};;
    esac
done

path_to_fasta=/media/tronghieu/GSHD_HN01/annotation_resources/HG38DIR/hg38_selected.fa;

# OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/MATCHED_LB_SAMPLE_CALLING;
OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/MATCHED_FFPE_SAMPLE_CALLING;

mkdir -p $OUTPUTDIR;

LBDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM/LB;
WBCDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM/WBC;
FFPEDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM/FFPE;

panel_of_normal=/media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/MUTECT2-VarCallPipeline/panels_of_normal/panel_of_normals_healthyControl_samples.vcf.gz;
path_to_germline_resrc=/media/tronghieu/GSHD_HN01/PREPROCESSED_DATA/ECD_DATA/gnomAD_AFonly/somatic-hg38_af-only-gnomad.hg38.vcf.gz;

# tumorsample=$(ls ${LBDIR}/*-CRCB${idx}_*.bam);
tumorsample=$(ls ${FFPEDIR}/*-CRCT${idx}_*.bam);

wbcsample=$(ls ${WBCDIR}/*-BCRCB${idx}_*.bam);

tumor_sample_name=$(basename $tumorsample);
tumor_sample_name=${tumor_sample_name%.bam*}
normalname=$(basename $wbcsample);
normalname=${normalname%.bam*};

echo -e "===================================================================== \n";
echo -e "Working on sample" $tumor_sample_name "and" $normalname "\n"; 
echo -e "===================================================================== \n";
gatk Mutect2 -R $path_to_fasta -I $tumorsample \
    -tumor $tumor_sample_name \
    -I $wbcsample \
    -normal $normalname \
    --panel-of-normals $panel_of_normal \
    --germline-resource $path_to_germline_resrc \
    --af-of-alleles-not-in-resource 0.001 \
    -O $OUTPUTDIR/pair_Sample_${idx}.vcf.gz;
