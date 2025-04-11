// Run NanoPlot on merged data
process quality_assessment_with_nanoplot {
    cpus 10 

    input:
    val(run_id)
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file)

    output:
    path "${barcode_name}_NanoPlot_results"

    publishDir "${run_id}_results/", mode: 'move'

    script:
    """
    echo "\$(date '+%Y-%m-%d %H:%M:%S') 🔬 Running NanoPlot: ${processing_dir}" | tee -a $processing_dir/processing.log
    NanoPlot \
    	--threads 10 \
    	--outdir ${barcode_name}_NanoPlot_results \
    	--info_in_report \
    	--only-report \
    	--N50 \
    	--title $barcode_name \
    	--fastq_rich $fastq_file 2>> $processing_dir/processing.log
    echo "\$(date '+%Y-%m-%d %H:%M:%S') ✅ Created: $processing_dir/${barcode_name}_NanoPlot_results" | tee -a $processing_dir/processing.log
    """
}