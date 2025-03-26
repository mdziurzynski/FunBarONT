process create_final_table {
    input:
        path 'results_aggregation_script.py'
        val(json_files)  // This is a list of file paths (strings or Path objects)
        val(run_id)

    output:
        path("${run_id}.results.xlsx"), emit: results_excel

    publishDir "${run_id}_results/", mode: 'move'

    script:
        // Join all file paths into a single string
        def files_arg = json_files.collect { it.toString() }.join(" ")
        """
        python3 results_aggregation_script.py --json_files ${files_arg} --rel_abu_threshold 10 --output ${run_id}.results.xlsx
        """
}