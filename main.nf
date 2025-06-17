nextflow.enable.dsl = 2

params.help = 0
if ( params.help != 0 ) {
    help = """FUNGAL BARCODING WITH ONT: This pipeline streamlines the conversion of Oxford Nanopore Technologies (ONT) basecaller output into high-quality Internal Transcribed Spacer (ITS) sequences.
             |
             |Required arguments:
             |
             |  --ONT_DIRECTORY  Location of the input file file.
             |
             |  --BLASTDB_PATH  Location of the input file file.
             |
             |  --RUN_ID  Location of the input file file.
             |
             |Optional arguments:
             |
             |  --MEDAKA_MODEL  Medaka inference model. [default: r1041_e82_400bps_hac_variant_v4.3.0]
             |
             |  --USE_ITSX  Set to 0 if you want to ommit extraction of full ITS region using ITSx. [default: 1]
             |
             |  --CHOPPER_MIN_READ_LENGTH Reads shorter than this value wont be used for clusters generation. [default: 150]
             |
             |  --CHOPPER_MAX_READ_LENGTH  Reads longer than this value wont be used for clusters generation. [default: 1000]
             |
             |  --REL_ABU_THRESHOLD  Output only clusters with barcode-wise relative abundance above this value. [default: 10]
             |
             |  --CPU_THREADS  Number of CPU threads. [default: 8]
             |
""".stripMargin()

    println(help)
    exit(0)
}
params.help

// Define input barcode directory as a parameter
params.ONT_DIRECTORY
params.BLASTDB_PATH
params.RUN_ID
params.MEDAKA_MODEL = 'r1041_e82_400bps_hac_variant_v4.3.0'
params.USE_ITSX = 1

// Chopper min and max length of reads
params.CHOPPER_MIN_READ_LENGTH = 150
params.CHOPPER_MAX_READ_LENGTH = 1000

// Rel abu threshold on final table [0-100]
params.REL_ABU_THRESHOLD = 10

// CPU threads
params.CPU_THREADS = 8

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

    barcode_results = ont_barcode_workflow(
        params.RUN_ID,
        params.MEDAKA_MODEL,
        params.USE_ITSX,
        params.CHOPPER_MIN_READ_LENGTH,
        params.CHOPPER_MAX_READ_LENGTH,
        params.CPU_THREADS,
        ch_barcodes
    ).collect()

    script_path = file('results_aggregation_script.py')
    create_final_table(script_path, barcode_results, params.RUN_ID, params.USE_ITSX, params.REL_ABU_THRESHOLD)

}

