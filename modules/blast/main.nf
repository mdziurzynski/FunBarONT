// Align centroids to UNITE
process blastn_vs_unite {
    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file), path("$processing_dir/${barcode_name}_blastn_results.tsv"), emit: data_tuple

    //publishDir "${barcode_dir_absolute}/", mode: 'copy'

    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 💥 Running BLASTn vs UNITE database" | tee -a $processing_dir/processing.log
    blastn \
        -query $medaka_file/consensus.fasta \
        -db ${BLASTDB_PATH}/blastdb_sh_general_release_04.04.2024 \
        -out $processing_dir/${barcode_name}_blastn_results.tsv \
        -outfmt "6 qseqid sseqid pident qcovs evalue qlen slen" \
        -evalue 1e-20 \
        -num_threads 10 \
        -max_target_seqs 1 \
        -max_hsps 1 2>> $processing_dir/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ BLASTing complete" | tee -a $processing_dir/processing.log
    """
}