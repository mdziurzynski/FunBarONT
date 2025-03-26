#!/usr/bin/env python3

import sys
import pandas as pd
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('--json_files', nargs='+', required=True, help='List of JSON result files')
parser.add_argument('--rel_abu_threshold', type=float, required=True, help='Relative abundance threshold (0–100)')
parser.add_argument('--output', type=str, required=True, help='Path to output file')

args = parser.parse_args()

empty_json_dfs = []
json_dfs = []
for json_path in args.json_files:
    with open(f'{json_path}', 'r') as f:
        json_data = json.load(f)

        # manage nonprocessed barcodes
        if "cluster_data" not in json_data:
            empty_data = [{
                "Barcode": json_data["barcode_id"],
                "Number of clusters": json_data["message"]
            }]
            empty_df = pd.DataFrame(empty_data)
            empty_json_dfs.append(empty_df)
            continue
        
        clusters_data = []
        for cluster in json_data["cluster_data"]:
            clusters_data.append({
                "Cluster ID": cluster["cluster_id"],
                "Cluster size": cluster["cluster_size"],
                "Cluster relative abundance": cluster["relative_abundance"] * 100,
                "Cluster sequence": cluster["cluster_sequence"],
                "BLASTn taxonomy assignment": cluster["blastn_tax_name"],
                "BLASTn perc. ident.": cluster["blastn_pident"],
                "BLASTn query coverage": cluster["blastn_query_coverage"],
                "BLASTn query length": cluster["blastn_query_length"],
                "BLASTn subject length": cluster["blastn_subject_length"],
                "BLASTn evalue": cluster["blastn_evalue"],
                "BLASTn subject SH": cluster["blastn_sh_id"],
                "BLASTn full taxonomy": cluster["blastn_full_taxonomy"]
            })
            
        clusters_df = pd.DataFrame(clusters_data)
        clusters_df["Barcode"] = json_data["barcode_id"]
        clusters_df["Number of clusters"] = json_data["number_of_clusters"]
        clusters_df["Total reads after filtering"] = json_data["total_reads_after_filtering"]
        # Reorder columns
        cols = ["Barcode", "Number of clusters", "Total reads after filtering"] + \
               [col for col in clusters_df.columns if col not in ["Barcode", "Number of clusters", "Total reads after filtering"]]
        clusters_df = clusters_df[cols]
        json_dfs.append(clusters_df)

df = pd.concat(json_dfs, ignore_index=True)

# apply rel abu threshold
df = df[df["Cluster relative abundance"] >= args.rel_abu_threshold]

df = df.sort_values(by=["Barcode", "Cluster relative abundance"], ascending=[True, False])

if empty_json_dfs:
    # put nonprocessed barcodes on top
    to_concat = empty_json_dfs + [df]
    df = pd.concat(to_concat, ignore_index=True)

df.to_excel(f"{args.output}", engine="openpyxl", index=False)
        
    
