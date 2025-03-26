process check_if_lt_10_seqs {

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), env("TOO_FEW_SEQUENCES"), emit: data_tuple
    
    script:
    """
    if [ "\$(zcat $fastq_file | wc -l)" -lt 40 ]; then
        TOO_FEW_SEQUENCES=1
    else
        TOO_FEW_SEQUENCES=0
    fi
    """
}

process emit_empty_result {

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), val(too_few_results)

    output:
    path("${barcode_name}.results.json") , emit: final_empty_json

    script:
    """
    echo '{ "barcode_id": "$barcode_name", "message": "Analysis aborted! Not enough sequences (less than 10)" }' > ${barcode_name}.results.json
    """
}
process check_if_lt_10_seqs_after_chopper {

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(chopper_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(chopper_file), env("TOO_FEW_SEQUENCES"), emit: data_tuple
    
    script:
    """
    if [ "\$(zcat $chopper_file | wc -l)" -lt 20 ]; then
        TOO_FEW_SEQUENCES=1
    else
        TOO_FEW_SEQUENCES=0
    fi
    """
}

process emit_empty_result_after_chopper {

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(chopper_file), val(too_few_results)

    output:
    path("${barcode_name}.results.json") , emit: final_empty_json

    script:
    """
    echo '{ "barcode_id": "$barcode_name", "message": "Analysis aborted! Not enough sequences AFTER QUALITY FILTERING (less than 10)." }' > ${barcode_name}.results.json
    """
}