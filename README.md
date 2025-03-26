# Nanopore Fungal Barcodes Pipeline

A bioinformatics pipeline for processing Nanopore barcoding data of fungi using the Nextflow workflow system.

---

## 🚀 Installation

### 1. Install Nextflow via Conda
```bash
conda create -n nf-env -c bioconda -c conda-forge nextflow
```

### 2. Clone the Repository
```bash
git clone git@github.com:mdziurzynski/ont_fungal_barcoding_pipeline.git
cd ont_fungal_barcoding_pipeline
```

### 3. Prepare the BLAST Database (e.g., using UNITE)

- Download the FASTA release of the UNITE database.
- Unpack the archive and create a BLAST database:

```bash
makeblastdb -in <your_unite.fasta> -dbtype nucl -out <unite_blastdb>
```

---

## 🔬 Running the Pipeline

> ⚠️ The first run may take longer due to Conda environment setup.

```bash
conda activate nf-env
nextflow run main.nf \
    --ONT_DIRECTORY <FULL PATH to basecalled ONT data (must contain pass/ with barcode01-XX folders)> \
    --BLASTDB_PATH <FULL PATH to your unite_blastdb> \
    --RUN_ID <your analysis ID>
```

---

## 📁 Outputs

The results will be saved in a folder named:

```
<run_id>_results
```

