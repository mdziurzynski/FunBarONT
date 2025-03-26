// Cluster sequences with VSEARCH
process clustering {
    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(chopper_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(chopper_file), path("$processing_dir/combined.${barcode_name}.chopper.centeroids.fasta.gz"), emit: data_tuple

    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 🔬 Running VSEARCH clustering" | tee -a $processing_dir/processing.log
    mkdir -p $processing_dir/combined.clusters
    vsearch --cluster_fast $processing_dir/$chopper_file \
            --id 0.95 \
            --clusters $processing_dir/combined.clusters/combined.${barcode_name}.chopper.cluster \
            --centroids $processing_dir/combined.${barcode_name}.chopper.centeroids.fasta \
            --strand both \
            --sizeout 2>> $processing_dir/processing.log
    gzip $processing_dir/combined.${barcode_name}.chopper.centeroids.fasta
    
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Clustering complete" | tee -a $processing_dir/processing.log
    """
}