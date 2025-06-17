
process its_extraction {
    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file)
    val(use_itsx)
    val(cpu_threads)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file), path("${barcode_name}.after_itsx.fasta"), emit: data_tuple


    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 💥 Running BLASTn vs UNITE database" | tee -a $processing_dir/processing.log
    if [ $use_itsx = 1 ]; then
        mkdir -p ${barcode_name}_itsx_output
        ITSx -i $medaka_file/consensus.fasta -o ${barcode_name}_itsx_output/itsx_output --cpu $cpu_threads
        # clean fasta headers
        sed '/^>/ s/|.*//' ${barcode_name}_itsx_output/itsx_output.full.fasta > ${barcode_name}.after_itsx.fasta
    else
        cp $medaka_file/consensus.fasta ${barcode_name}.after_itsx.fasta
    fi
    
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ BLASTing complete" | tee -a $processing_dir/processing.log
    """
}