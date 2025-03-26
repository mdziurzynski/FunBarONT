
// Second round of polishing - Medaka
process polish_with_medaka {
    cpus 10 

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(racon_file)

    output:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path("$processing_dir/${barcode_name}_medaka_output"), emit: data_tuple

    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 🛠️ Running Medaka polishing" | tee -a $processing_dir/processing.log
    medaka_consensus \
        -i $processing_dir/$fastq_file \
        -d $processing_dir/$racon_file \
        -o $processing_dir/${barcode_name}_medaka_output \
        -t 10 \
        -m r1041_e82_400bps_hac_variant_v4.3.0 2>> $processing_dir/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Polishing complete with Medaka" | tee -a $processing_dir/processing.log
    """
}