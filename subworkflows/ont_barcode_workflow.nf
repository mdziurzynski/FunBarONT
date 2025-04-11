nextflow.enable.dsl = 2

include {
    setup_processing_folder
    unzip_merge_fastq
} from '../modules/setup/main.nf'

include { quality_assessment_with_nanoplot } from '../modules/nanoplot/main.nf'
include { chopper_filtering } from '../modules/chopper/main.nf'
include { clustering } from '../modules/vsearch/main.nf'
include { map_fastq } from '../modules/minimap2_mapping/main.nf'
include { polish_with_racon } from '../modules/racon/main.nf'
include { polish_with_medaka } from '../modules/medaka/main.nf'
include { its_extraction } from '../modules/itsx/main.nf'
include { blastn_vs_unite } from '../modules/blast/main.nf'
include { barcode_results_aggregation } from '../modules/json_creation/main.nf'

include {
    check_if_lt_10_seqs
    emit_empty_result
    check_if_lt_10_seqs_after_chopper
    emit_empty_result_after_chopper
} from '../modules/helpers/main.nf'

workflow ont_barcode_workflow {
    take:
    run_id
    data_tuple

    main:
    setup_processing_folder(data_tuple)

    unzip_merge_fastq(setup_processing_folder.out.data_tuple)

    check_if_lt_10_seqs(unzip_merge_fastq.out.data_tuple)

    // check if we have more than 10 sequences to work with
    check_if_lt_10_seqs.out.data_tuple.branch { it ->
        mt_10_seqs: it.last() == "0"
        lt_10_seqs: it.last() == "1"
        other: true
    }.set { result }
    final_empty_json = emit_empty_result(result.lt_10_seqs)
    
    quality_assessment_with_nanoplot(run_id, result.mt_10_seqs.map{ it[0..-2] })

    chopper_filtering(result.mt_10_seqs.map{ it[0..-2] })

    check_if_lt_10_seqs_after_chopper(chopper_filtering.out.data_tuple)

    // check if we have more than 10 sequences to work with
    check_if_lt_10_seqs_after_chopper.out.data_tuple.branch { it ->
        mt_10_seqs_after_chopper: it.last() == "0"
        lt_10_seqs_after_chopper: it.last() == "1"
        other: true
    }.set { result_after_chopper }
    final_empty_json_after_chopper = emit_empty_result_after_chopper(result_after_chopper.lt_10_seqs_after_chopper)
    
    clustering(result_after_chopper.mt_10_seqs_after_chopper.map { it[0..-2] })

    //clustering(chopper_filtering.out.data_tuple)

    map_fastq(clustering.out.data_tuple)

    polish_with_racon(map_fastq.out.data_tuple)

    polish_with_medaka(polish_with_racon.out.data_tuple)

    its_extraction(polish_with_medaka.out.data_tuple)

    blastn_vs_unite(its_extraction.out.data_tuple)

    barcode_results_aggregation(blastn_vs_unite.out.data_tuple)
    barcode_results_aggregation.out.final_json.set { final_json }

    final_data = final_json.mix(final_empty_json, final_empty_json_after_chopper)

    emit:
    final_data
}