// Apply Chopper filtering
process chopper_filtering {
    cpus 10 

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file)
    val(chopper_min)
    val(chopper_max)


    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path("${processing_dir}/combined.${barcode_name}.chopper.fasta.gz"), emit: data_tuple

    script:
    """
    chopper \
    	--minlength $chopper_min \
    	--maxlength $chopper_max \
    	--threads 10 \
    	--input $fastq_file \
    	--quality 10 | seqkit fq2fa -o $processing_dir/combined.${barcode_name}.chopper.fasta.gz 2>> $processing_dir/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Filtered with Chopper" | tee -a $processing_dir/processing.log
    """
}