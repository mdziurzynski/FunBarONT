process setup_processing_folder {
    input:
        tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH)

    output:
        tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path("processing_${barcode_name}"), emit: data_tuple

    script:
    """
    mkdir -p processing_$barcode_name
    touch processing_${barcode_name}/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Created processing directory: processing" | tee -a processing_$barcode_name/processing.log
    """
}

process unzip_merge_fastq {
    input:
        tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir)

    output:
        tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path("$processing_dir/combined.${barcode_name}.fastq.gz"), emit: data_tuple

    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 📂 Processing: ${processing_dir}" | tee -a $processing_dir/processing.log
    zcat ${barcode_dir}/*.fastq.gz | gzip > $processing_dir/combined.${barcode_name}.fastq.gz 2>> $processing_dir/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Created: $processing_dir/combined.${barcode_name}.fastq.gz" | tee -a $processing_dir/processing.log
    """
}