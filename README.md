# Nanopore Fungal Barcodes Pipeling
A bioinformatics pipeline to process Nanopore barcoding data for fungi.

The pipeline runs using NextFlow workflow system.

Installation

1. Install NextFlow in conda

```
conda create -n nf-env -c bioconda -c conda-forge nextflow
```

2. Download the repository

```
git clone git@github.com:mdziurzynski/ont_fungal_barcoding_pipeline.git
cd ont_fungal_barcoding_pipeline
```

3. Prepare blast database of UNITE database

   - download fasta release of UNITE database
   - unpack and make it into a BLAST database

```
makeblastdb -in <your_unite.fasta> -dbtype nucl -out <unite_blastdb>
    
```


4. Run your analysis

First analysis may take a little bit longer to launch because the system will setup conda environment.

```
conda activate nf-env
nextflow run main.nf \
    --ONT_DIRECTORY <FULL PATH your ONT data after basecalling - must have pass folder with barcode01-XX folders within>
    --BLASTDB_PATH <FULL PATH to your unite_blastdb>
    --RUN_ID <your analysis ID>
```

5. Outputs

Pipeline results will be availble in folder `<run_id>_results`