#!/bin/bash

source /opt/conda/etc/profile.d/conda.sh
conda activate ont_fungal_barcoding_env

# Help message
usage() {
    echo "FunBarONT - A bioinformatics pipeline for processing Nanopore barcoding data of fungi."
    echo 
    echo "Written by Mikolaj Dziurzynski"
    echo
    echo "Usage: $0 --ONT_DIRECTORY <path> --BLASTDB_PATH <path> --RUN_ID <id> [optional arguments]"
    echo
    echo "Required arguments:"
    echo "  --ONT_DIRECTORY         Full path to basecalled ONT data directory"
    echo "  --BLASTDB_PATH          Full path to folder containing unite_blastdb"
    echo "  --RUN_ID                Identifier for this analysis run"
    echo
    echo "Optional arguments:"
    echo "  --MEDAKA_MODEL          Medaka model [default: r1041_e82_400bps_hac_variant_v4.3.0]"
    echo "  --USE_ITSX              Use ITSx for full ITS extraction (1 = yes, 0 = no) [default: 1]"
    echo "  --CHOPPER_MIN_READ_LENGTH  Minimum read length for clustering [default: 150]"
    echo "  --CHOPPER_MAX_READ_LENGTH  Maximum read length for clustering [default: 1000]"
    echo "  --REL_ABU_THRESHOLD     Relative abundance threshold [default: 10]"
    echo
    exit 1
}
# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ONT_DIRECTORY) ONT_DIR="$2"; shift ;;
        --BLASTDB_PATH) BLASTDB="$2"; shift ;;
        --RUN_ID) RUN_ID="$2"; shift ;;
        --help) usage ;;
        --*) ADDITIONAL_ARGS+="$1 $2 "; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Validate required arguments
if [[ -z "$ONT_DIR" || -z "$BLASTDB" || -z "$RUN_ID" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

# Compose the full command as a variable
CMD="nextflow run main.nf \
    --ONT_DIRECTORY \"$ONT_DIR\" \
    --BLASTDB_PATH \"$BLASTDB\" \
    --RUN_ID \"$RUN_ID\" \
    $ADDITIONAL_ARGS"

# Echo the command before running
echo "Running command:"
echo "$CMD"

# Run the command
eval $CMD
