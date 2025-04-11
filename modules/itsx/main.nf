
process its_extraction {
    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file), path("${barcode_name}.itsx.fasta"), emit: data_tuple


    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 💥 Running BLASTn vs UNITE database" | tee -a $processing_dir/processing.log
    mkdir -p ${barcode_name}_itsx_output
    ITSx -i $medaka_file/consensus.fasta -o ${barcode_name}_itsx_output/itsx_output --cpu 10
    # clean fasta headers
    sed '/^>/ s/|.*//' ${barcode_name}_itsx_output/itsx_output.full.fasta > ${barcode_name}.itsx.fasta
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ BLASTing complete" | tee -a $processing_dir/processing.log
    """
}