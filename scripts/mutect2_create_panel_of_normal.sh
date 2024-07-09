# =====================================================================
# create a panel of normal with gatk CreateSomaticPanelofNormals
# =====================================================================

# This part is specially for CRC samples!!! ---------------------------
# for WBC samples
echo -e "working on WBC samples" "\n";
path_to_args_file_WBC=/media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/MUTECT2-VarCallPipeline/scripts/WBC_vcf.args;
gatk CreateSomaticPanelOfNormals -vcfs $path_to_args_file_WBC -O panel_of_normals_WBC_samples.vcf.gz --min-sample-count 50
    
# for control samples
echo -e "working on healthy control samples" "\n";
path_to_args_file_healthycontrol=/media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/MUTECT2-VarCallPipeline/scripts/healthyControl_vcf.args;
gatk CreateSomaticPanelOfNormals -vcfs $path_to_args_file_healthycontrol -O panel_of_normals_healthyControl_samples.vcf.gz --min-sample-count 90
# ---------------------------------------------------------------------
# Run this part for LBH samples 

