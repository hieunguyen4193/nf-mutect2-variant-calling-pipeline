args_file=/media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/MUTECT2-VarCallPipeline/scripts/GVCF_LBH_WBC.args;
path_to_fasta=/media/tronghieu/GSHD_HN01/annotation_resources/HG38DIR/hg38_selected.fa;

gatk CombineGVCFs -R $path_to_fasta --arguments_file $args_file -O /media/tronghieu/HNSD01/WORKING_DATA/LBH_VCF_HAPLOTYPE/cohort_WBC/BLBHC_cohort_gvcf.vcf.gz;
