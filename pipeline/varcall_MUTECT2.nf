// ======================================================================================
// VARIANT CALLING WITH MUTECT2 PIPELINE
// Author: Trong-Hieu Nguyen
// hieunguyen@genesolutions.vn  
// ======================================================================================
println """\
        ===================================================================
                    S O M A T I C - V A R I A N T - C A L L I N G  
                                ----- ----- -----
                            B Y [G A T K] M U T E C T 2 
                                GATK Version 4.0.12    
         
         ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** 
        
         Author: TRONG - HIEU NGUYEN
         Email: hieunguyen@genesolutions.vn
         
        ===================================================================
         """
         .stripIndent()

// Input parameters ---------------------------------------------------------------------
params.METADATA=""
params.OUTPUTDIR=""
params.SAMPLE_TYPE=""

params.germline_resource=""
germline_resource=file(params.germline_resource)
params.germline_resource_index = ""
germline_resource_index=file(params.germline_resource_index)
// Human reference genome 
params.FASTA=""

// Control samples are used to generate PANEL OF NORMALS. 
// The MIN_OCCURRENCE_PON number define the minimum number of occurrences of a variants among 
// all control samples to be called "normal".
params.PATH_TO_CONTROL_SAMPLES=""
params.MIN_OCCURRENCE_PON=""

// File vcf containing common variants. Generate this file by intersecting our target bedfile 
// with the gnomAD files downloaded from GATK database.
params.path_to_gnomAD_common_variants=""
params.path_to_gnomAD_common_variants_tbi=""

common_variant_AF_vcf=file(params.path_to_gnomAD_common_variants)
common_variant_AF_vcf_tbi=file(params.path_to_gnomAD_common_variants_tbi)

// process VarCall_ControlSamples{

// }

// Define the main channel input from metadata .csv file ---------------------------------
Channel
    .fromPath(params.METADATA)
    .splitCsv(header:true)
    .map{ row -> tuple(row.ID, file(row.FFPE), file(row.WBC)) }
    .view()
    .into { Pair_samples_ch; CalculateContamination; filter_bias_orientation}


process CreatePanelOfNormals {
    cache "deep"
    publishDir "$params.OUTPUTDIR/PanelOfNormals", mode: 'copy'
    output: 
        tuple "${params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz", "${params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz.tbi" into panel_of_normals_ch 
    shell:
    '''
    files=$(ls !{params.PATH_TO_CONTROL_SAMPLES}/*.vcf.gz);
    touch tmp_args_file.args;
    for file in $files;do \
        echo $file >> tmp_args_file.args;done
    
    gatk CreateSomaticPanelOfNormals -vcfs tmp_args_file.args \
    -O !{params.SAMPLE_TYPE}_panel_of_normals.multiallelic.vcf.gz \
    --min-sample-count !{params.MIN_OCCURRENCE_PON};
    rm -rf tmp_args_file.args;
    
    bcftools norm -m -any !{params.SAMPLE_TYPE}_panel_of_normals.multiallelic.vcf.gz \
    -o !{params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz;
    
    tabix -p vcf !{params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz;
    '''
}

process CalculateContamination {
    cache "deep" 
    publishDir "$params.OUTPUTDIR/Contamination_Table", mode: 'copy'
    maxForks 5
    input: 
        set sampleID, file(LB_file), file(WBC_file) from CalculateContamination
        file common_variant_AF_vcf
        file common_variant_AF_vcf_tbi
    output: 
        file "${sampleID}_calculatecontamination.table" into contamination_table_ch
    script:
    """
    gatk GetPileupSummaries -I $LB_file -V $common_variant_AF_vcf \
    -O ${sampleID}_getpileupsummaries.table -L $common_variant_AF_vcf;

    gatk CalculateContamination -I ${sampleID}_getpileupsummaries.table -O ${sampleID}_calculatecontamination.table;
    """    
}

process SomaticCalling{
    cache "deep"
    publishDir "$params.OUTPUTDIR/SomaticCalling", mode: 'copy'
    maxForks 6
    input: 
        set sampleID, file(LB_file), file(WBC_file) from Pair_samples_ch
        tuple "${params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz", "${params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz.tbi" from panel_of_normals_ch 
        file germline_resource
        file germline_resource_index
        
    output: 
        tuple sampleID, "somatic_variants_FFPE_${sampleID}.vcf.gz", "somatic_variants_FFPE_${sampleID}.vcf.gz.tbi" into somatic_var_ch
    shell: 
    '''
    LB_file_name=!{LB_file};
    LB_file_name=${LB_file_name%.bam*};
    
    WBC_file_name=!{WBC_file};
    WBC_file_name=${WBC_file_name%.bam*};

    gatk Mutect2 -R !{params.FASTA}.fa -I !{LB_file} \
    -tumor ${LB_file_name}\
    -I !{WBC_file} \
    -normal ${WBC_file_name} \
    --panel-of-normals !{params.SAMPLE_TYPE}_panel_of_normals.biallelic.vcf.gz \
    --germline-resource !{germline_resource} \
    --af-of-alleles-not-in-resource 0.001 \
    -O somatic_variants_FFPE_!{sampleID}.vcf.gz;
    '''
}

// process Filter_by_Contamination{
//     cache "deep"
//     publishDir "$params.OUTPUTDIR/Filtered_Somatic_Variants"

//     maxForks 5
//     input: 
//         tuple sampleID, "somatic_variants_${sampleID}.vcf.gz", "somatic_variants_${sampleID}.vcf.gz.tbi" from somatic_var_ch
//         file "*" from contamination_table_ch.collect()
//     output:
//         tuple sampleID, "somatic_variants_${sampleID}.filtered.vcf.gz", "somatic_variants_${sampleID}.filtered.vcf.gz.tbi" into filter_bias_orientation_ch
//     // shell:
//     // '''
//     // isNaNinContamination=$(cat !{sampleID}_calculatecontamination.table | grep -c "NaN");
//     // if [[ "$isNaNinContamination" -eq 1 ]];then mv somatic_variants_!{sampleID}.vcf.gz somatic_variants_!{sampleID}.filtered.vcf.gz;  
//     // else gatk FilterMutectCalls -V somatic_variants_!{sampleID}.vcf.gz --contamination-table !{sampleID}_calculatecontamination.table -O somatic_variants_!{sampleID}.filtered.vcf.gz;
//     // fi
//     // '''
//     script:
//     """
//     isNaNinContamination=\$(cat ${sampleID}_calculatecontamination.table | grep -c "NaN");
//     if [[ "\${isNaNinContamination}" -eq 1 ]];then mv somatic_variants_${sampleID}.vcf.gz somatic_variants_${sampleID}.filtered.vcf.gz  
//     else gatk FilterMutectCalls -V somatic_variants_${sampleID}.vcf.gz --contamination-table ${sampleID}_calculatecontamination.table -O somatic_variants_${sampleID}.filtered.vcf.gz
//     fi
//     """
// }

// process FilterByBiasOrientation {
//     cache "deep"
//     publishDir "$params.OUTPUTDIR/FilterByBiasOrientation"
//     maxForks 5
//     input:
//         set sampleID, file(LB_file), file(WBC_file) from filter_bias_orientation
//         tuple sampleID, "somatic_variants_${sampleID}.vcf.gz", "somatic_variants_${sampleID}.vcf.gz.tbi" from somatic_var_ch
//     output: 
//         set sampleID, "somatic_variants_${sampleID}.bias_filtered.vcf.gz" into final_ch
//     script:
//     """
//     gatk CollectSequencingArtifactMetrics \
//     -I ${LB_file} \
//     -O ${sampleID}.tumor.artifact.txt \
//     -R ${params.FASTA}.fa
    
//     gatk FilterByOrientationBias \
//     -A G/T \
//     -A C/T \
//     -V somatic_variants_${sampleID}.filtered.vcf.gz \
//     -P ${sampleID}.tumor.artifact.txt \
//     -O somatic_variants_${sampleID}.bias_filtered.vcf.gz
//     """
// }
// process FilterByBiasOrientation{

// }


