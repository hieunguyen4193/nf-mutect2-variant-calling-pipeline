# Extract region of interest in the germline resource.
path_to_CRC_bedfile=/media/tronghieu/GSHD_HN01/annotation_resources/target_genes/new_version/oncoTTYSH.targets.hg38.bed;
path_to_LBH_bedfile=/media/tronghieu/GSHD_HN01/annotation_resources/target_genes/new_version/onco08.targets.hg38.bed;
path_to_gnomAD_folder=/media/tronghieu/GSHD_HN01/PREPROCESSED_DATA/ECD_DATA/gnomAD_AFonly;

# bedtools intersect -header -a ${path_to_gnomAD_folder}/somatic-hg38_af-only-gnomad.hg38.vcf.gz -b $path_to_CRC_bedfile | bgzip -c > $path_to_gnomAD_folder/oncoTTYSH_common_variant_AF.vcf.gz
# bedtools intersect -header -a ${path_to_gnomAD_folder}/somatic-hg38_af-only-gnomad.hg38.vcf.gz -b $path_to_LBH_bedfile | bgzip -c > $path_to_gnomAD_folder/onco08_common_variant_AF.vcf.gz

echo -e "finish generating germline resource in region of interest \n";

# path_to_all_tumor_bam=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM/LB;
# OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_LB_contamination;

path_to_all_tumor_bam=/media/tronghieu/HNSD01/WORKING_DATA/CRC_BAM/FFPE;
OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_FFPE_contamination;

mkdir -p $OUTPUTDIR;

files=$(ls $path_to_all_tumor_bam/*.bam | xargs -n 1 basename);
for file in $files;do \
    samplename=${file%.bam*};
    echo -e "working on sample: " $samplename "\n";
    # gatk GetPileupSummaries -I $path_to_all_tumor_bam/$file -V $path_to_gnomAD_folder/oncoTTYSH_common_variant_AF.vcf.gz \
    # -O $OUTPUTDIR/${samplename}_getpileupsummaries.table -L $path_to_gnomAD_folder/oncoTTYSH_common_variant_AF.vcf.gz;
    gatk GetPileupSummaries -I $path_to_all_tumor_bam/$file -V $path_to_gnomAD_folder/onco08_common_variant_AF.vcf.gz \
    -O $OUTPUTDIR/${samplename}_getpileupsummaries.table -L $path_to_gnomAD_folder/onco08_common_variant_AF.vcf.gz;

    echo -e "get pileup summaries finished ... \n"
    
    gatk CalculateContamination -I $OUTPUTDIR/${samplename}_getpileupsummaries.table -O $OUTPUTDIR/${samplename}_calculatecontamination.table;
    echo -e "contamination calculated... \n";
    done