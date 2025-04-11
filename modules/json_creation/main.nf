process barcode_results_aggregation {

    input:
    tuple val(barcode_dir_absolute), val(barcode_name), path(barcode_dir), path(BLASTDB_PATH), path(processing_dir), path(fastq_file), path(filtlong_file), path(centroids_file), path(minimap_file), path(medaka_file), path(itsx_fasta), path(blastn_file)

    output:
    path("${barcode_name}.results.json") , emit: final_json

    """
    #!/usr/bin/env python3
    from Bio import SeqIO
    import json
    import os
    import pandas as pd

    def main():
        # check if we have any hits after UNITE
        if os.stat("$blastn_file").st_size == 0:
            data = {
                "barcode_id": "$barcode_name", 
                "message": "Analysis aborted! No hits vs the reference database (UNITE by default) and most probably no sequences extracted by ITSx!"
            }
            with open("${barcode_name}.results.json", "w") as json_file:
                json.dump(data, json_file, indent=4)
            return
    
        total_seqs = 0
        records_list = []
        
        # load blastn results
        columns = ["qseqid", "sseqid", "pident", "qcovs", "evalue", "qlen", "slen"]
        bout_df = pd.read_csv("$blastn_file", sep="\t", header=None, names=columns)
        bout_df["qseqid"] = bout_df["qseqid"].apply(lambda x: x.split(";")[0])
    
        # get sequences data
        for record in SeqIO.parse("$itsx_fasta", "fasta"):
            cluster_id, cluster_size = record.id.split(";")
            cluster_size = int(cluster_size.split("=")[-1])
            total_seqs += cluster_size
            cluster_data = {
                "cluster_id": cluster_id,
                "cluster_size": cluster_size,
                "cluster_sequence": str(record.seq)
            }

            # add original, untrimmed sequences
            for record in SeqIO.parse("$medaka_file/consensus.fasta", "fasta"):
                medaka_record_id = record.id.split(';')[0]
                if medaka_record_id == cluster_data["cluster_id"]:
                    cluster_data["cluster_sequence_untrimmed"] = str(record.seq)
                    break
            else:
                cluster_data["cluster_sequence_untrimmed"] = ""
        
            # find and add blastn data
            bout_data_df = bout_df[bout_df["qseqid"] == cluster_id]
            if bout_data_df.shape[0] == 0:
                continue
                records_list.append(cluster_data)
            elif bout_data_df.shape[0] > 1:
                raise Exception("Too many hits per sample - should be only one! barcode16")
            bout_data_dict = bout_data_df.to_dict(orient='records')[0]
            tax_name, ver, sh_id, seq_type, full_taxonomy = bout_data_dict['sseqid'].split("|")
            cluster_data.update({
                "blastn_tax_name": tax_name,
                "blastn_sh_id": sh_id,
                "blastn_full_taxonomy": full_taxonomy,
                "blastn_pident": bout_data_dict["pident"],
                "blastn_query_coverage": bout_data_dict["qcovs"],
                "blastn_evalue": bout_data_dict["evalue"],
                "blastn_query_length": bout_data_dict["qlen"],
                "blastn_subject_length": bout_data_dict["slen"],
            })
            records_list.append(cluster_data)
        
        sorted_data = sorted(records_list, key=lambda x: x["cluster_size"], reverse=True)
        for cluster in sorted_data:
            cluster['relative_abundance'] = cluster["cluster_size"] / total_seqs
        
        data = {
            "number_of_clusters": len(records_list),
            "total_reads_after_filtering": total_seqs,
            "cluster_data": sorted_data,
            "barcode_id": "$barcode_name"
        }
        with open("${barcode_name}.results.json", "w") as json_file:
            json.dump(data, json_file, indent=4)
    main()
    """
}