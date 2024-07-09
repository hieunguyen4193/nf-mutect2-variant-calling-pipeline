idxs=$(cat /media/tronghieu/HNSD01/src_github/ECD-FRAGMENTATION-PROFILING/MUTECT2-VarCallPipeline/list_of_sample_idx.txt);
parallel -j 8 --memfree 8G ./mutect2_matched_sample_variant_calling.sh -i {} ::: $idxs
