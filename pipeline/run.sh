# Script to run this pipeline 
nextflow=/media/tronghieu/HNSD01/nextflow_exe/nextflow;
export PATH=/home/tronghieu/samtools/bin:$PATH; 
export PATH=/home/tronghieu/bcftools/bin:$PATH;

path_to_fasta=/media/tronghieu/GSHD_HN01/annotation_resources/HG38DIR/hg38_selected;
germline_resource=/media/tronghieu/GSHD_HN01/PREPROCESSED_DATA/ECD_DATA/gnomAD_AFonly/somatic-hg38_af-only-gnomad.hg38.vcf.gz;

# CRC ---------------------------------------------------------------------
# sampletype=CRC
# metadata=/media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/data/CRC_sample_metadata.csv;
# path_to_control_vcf=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/CONTROL;
# path_to_gnomAD_common_variants=/media/tronghieu/GSHD_HN01/PREPROCESSED_DATA/ECD_DATA/gnomAD_AFonly/oncoTTYSH_common_variant_AF.vcf.gz;
# MIN_OCCURRENCE_PON=90

# LBH ---------------------------------------------------------------------
sampletype=LBH
metadata=/media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/data/LBH_sample_metadata.csv;
path_to_control_vcf=/media/tronghieu/HNSD01/WORKING_DATA/LBH_VCF_MUTECT2/CONTROL
path_to_gnomAD_common_variants=/media/tronghieu/GSHD_HN01/PREPROCESSED_DATA/ECD_DATA/gnomAD_AFonly/onco08_common_variant_AF.vcf.gz;
MIN_OCCURRENCE_PON=100

$nextflow varcall_MUTECT2.nf \
-w ./work \
--PATH_TO_CONTROL_SAMPLES $path_to_control_vcf \
--SAMPLE_TYPE $sampletype \
--MIN_OCCURRENCE_PON $MIN_OCCURRENCE_PON \
--OUTPUTDIR ./OUTPUT \
--METADATA $metadata \
--path_to_gnomAD_common_variants $path_to_gnomAD_common_variants \
--path_to_gnomAD_common_variants_tbi $path_to_gnomAD_common_variants.tbi \
--germline_resource $germline_resource \
--germline_resource_index $germline_resource.tbi \
--FASTA $path_to_fasta \
-resume
