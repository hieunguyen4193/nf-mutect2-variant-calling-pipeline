while getopts i: flag
do
    case "${flag}" in
        i) idx=${OPTARG};;
    esac
done

# OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/FILTERED_MATCHED_LB_SAMPLE_CALLING;
OUTPUTDIR=/media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/FILTERED_MATCHED_FFPE_SAMPLE_CALLING;

mkdir -p $OUTPUTDIR;

# matched_sample_called_variant=$(ls /media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/MATCHED_LB_SAMPLE_CALLING/*_${idx}.vcf.gz);
# calculated_contamination_table=$(ls /media/tronghieu/HNSD01/WORKING_DATA/CRC_LB_contamination/*CRCB${idx}_*calculatecontamination.table)

matched_sample_called_variant=$(ls /media/tronghieu/HNSD01/WORKING_DATA/CRC_VCF_MUTECT2/MATCHED_FFPE_SAMPLE_CALLING/*_${idx}.vcf.gz);
calculated_contamination_table=$(ls /media/tronghieu/HNSD01/WORKING_DATA/CRC_FFPE_contamination/*CRCT${idx}_*calculatecontamination.table)

echo $matched_sample_called_variant;
echo $calculated_contamination_table;
gatk FilterMutectCalls -V $matched_sample_called_variant --contamination-table $calculated_contamination_table -O ${OUTPUTDIR}/pair_${idx}.matched_sample.filtered.vcf.gz