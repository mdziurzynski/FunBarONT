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
    check_if_at_least_one_seq_afer_racon
    emit_empty_result_after_racon
} from '../modules/helpers/main.nf'

workflow ont_barcode_workflow {
    take:
    run_id
    medaka_model
    use_itsx
    chopper_min
    chopper_max
    cpu_threads
    data_tuple

    main:

    final_data = channel.of()

    setup_processing_folder(data_tuple)

    unzip_merge_fastq(setup_processing_folder.out.data_tuple)

    check_if_lt_10_seqs(unzip_merge_fastq.out.data_tuple)

    // check if we have more than 10 sequences to work with
    check_if_lt_10_seqs.out.data_tuple.branch { it ->
        mt_10_seqs: it.last() == "0"
        lt_10_seqs: it.last() == "1"
        other: true
    }.set { result }
    emit_empty_result(result.lt_10_seqs)
    final_data = final_data.mix(emit_empty_result.out.final_empty_json)

    quality_assessment_with_nanoplot(run_id, result.mt_10_seqs.map{ it[0..-2] }, cpu_threads)

    chopper_filtering(result.mt_10_seqs.map{ it[0..-2] }, chopper_min, chopper_max, cpu_threads)

    check_if_lt_10_seqs_after_chopper(chopper_filtering.out.data_tuple)

    // check if we have more than 10 sequences to work with
    check_if_lt_10_seqs_after_chopper.out.data_tuple.branch { it ->
        mt_10_seqs_after_chopper: it.last() == "0"
        lt_10_seqs_after_chopper: it.last() == "1"
        other: true
    }.set { result_after_chopper }
    emit_empty_result_after_chopper(result_after_chopper.lt_10_seqs_after_chopper)
    final_data = final_data.mix(emit_empty_result_after_chopper.out.final_empty_json)

    clustering(result_after_chopper.mt_10_seqs_after_chopper.map { it[0..-2] })

    map_fastq(clustering.out.data_tuple, cpu_threads)

    polish_with_racon(map_fastq.out.data_tuple, cpu_threads)

    // check if we have more than 1 sequence to work with - racon does not output unpolished sequences
    check_if_at_least_one_seq_afer_racon(polish_with_racon.out.data_tuple)

    check_if_at_least_one_seq_afer_racon.out.data_tuple.branch { it ->
        mt_1_seqs_after_racon: it.last() == "0"
        lt_1_seqs_after_racon: it.last() == "1"
        other: true
    }.set { result_after_racon }
    emit_empty_result_after_racon(result_after_racon.lt_1_seqs_after_racon)
    final_data = final_data.mix(emit_empty_result_after_racon.out.final_empty_json)

    polish_with_medaka(result_after_racon.mt_1_seqs_after_racon.map { it[0..-2] }, medaka_model, cpu_threads)

    its_extraction(polish_with_medaka.out.data_tuple, use_itsx, cpu_threads)

    blastn_vs_unite(its_extraction.out.data_tuple, cpu_threads)

    barcode_results_aggregation(blastn_vs_unite.out.data_tuple)
    barcode_results_aggregation.out.final_json.set { final_json }

    final_data = final_data.mix(final_json)

    emit:
    final_data
}