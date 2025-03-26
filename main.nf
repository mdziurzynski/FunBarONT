nextflow.enable.dsl = 2

// Define input barcode directory as a parameter
params.ONT_DIRECTORY = "$PWD" // Change this or pass via CLI
params.BLASTDB_PATH
params.RUN_ID

include { 
    ont_barcode_workflow
} from './subworkflows/ont_barcode_workflow.nf'

include {
    create_final_table
} from './modules/create_final_table/main.nf'

workflow {
    
    def base_dir = params.ONT_DIRECTORY
    def cmd = ["bash", "-c", "find ${base_dir} -type d -path '*/pass/barcode*' -prune"]
    def folder_list = cmd.execute().text.readLines()
    folder_list.each { println "📂 Found: $it" }
    
    def ch_barcodes = Channel.from(folder_list).map { barcode_dir ->
        def barcode_name = barcode_dir.tokenize('/')[-1]
        def barcode_fullpath = file(barcode_dir).toAbsolutePath()

        tuple(
            barcode_fullpath, barcode_name, file(barcode_dir), file(params.BLASTDB_PATH)
        )
    }

    barcode_results = ont_barcode_workflow(params.RUN_ID, ch_barcodes).collect()

    script_path = file('results_aggregation_script.py')
    create_final_table(script_path, barcode_results, params.RUN_ID)

}

