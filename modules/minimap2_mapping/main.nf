// Map reads with Minimap2
process map_fastq {
    cpus 10 

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path("$processing_dir/combined.${barcode_name}_minimap.paf"), emit: data_tuple

    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 🎯 Running Minimap2" | tee -a $processing_dir/processing.log
    minimap2 -t 10 $processing_dir/$centroids_file $processing_dir/$fastq_file > $processing_dir/combined.${barcode_name}_minimap.paf 2>> $processing_dir/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Minimap2 mapping done" | tee -a $processing_dir/processing.log
    """
}