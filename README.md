# ANGSD Final Project

## Overview

This repository contains the final project for Analysis of Next Generation Sequencing Data. The project analyzes the BATLAS RNA-seq dataset to characterize human brown adipose tissue (BAT), compare it with white adipose tissue (WAT), and integrate a BAT transcript abundance profile with GTEx tissue median TPM values.

The main analysis is documented in `Final_project.Rmd`, with a rendered report available as `Final_project.html`.

## Project Goals

- Download and document BATLAS Cohort 2 RNA-seq samples from ENA study `ERP022805`.
- Align BATLAS FASTQ files to GRCh38/GENCODE v39 using STAR.
- Generate a gene-level raw count matrix with `featureCounts`.
- Perform RNA-seq QC using FastQC, MultiQC, and RSeQC.
- Compare BAT and WAT transcriptomes with DESeq2.
- Test enrichment of a brown fat marker signature with GSEA.
- Generate a BAT median TPM profile and merge it with GTEx median tissue TPM data.
- Build a gene-level UMAP from GTEx + BAT z-scored TPM values.

## Repository Structure

```text
.
├── Final_project.Rmd
├── Final_project.html
├── README.md
├── DATA/
│   ├── sample_table.tsv
│   ├── BATLAS_counts_matrix.tsv
│   ├── read_distribution_summary.tsv
│   ├── Vulcano_results.csv
│   ├── nTPM_df.csv
│   ├── GTEx_Analysis_2022-06-06_v10_RNASeQCv2.4.2_gene_median_tpm.gct
│   ├── MultiQC.png
│   └── multiqc_bam_fastqc_report.html
├── SCRIPTS/
│   ├── STAR_index_and_alignment.sbatch
│   ├── feature_counts.sbatch
│   ├── run_rnaseqc_all.sbatch
│   ├── compute_median_tpm.R
│   ├── collapse_gtf_for_rnaseqc.py
│   └── knitting_file.sh
└── gencode.v39.annotation.gtf
```

## Key Files

| File | Description |
|---|---|
| `Final_project.Rmd` | Main analysis notebook containing methods, code, results, and discussion. |
| `Final_project.html` | Rendered HTML version of the final report. |
| `DATA/sample_table.tsv` | Curated BATLAS Cohort 2 sample metadata. |
| `DATA/BATLAS_counts_matrix.tsv` | Clean featureCounts gene-by-sample raw count matrix. |
| `DATA/read_distribution_summary.tsv` | RSeQC read distribution summary across genomic features. |
| `DATA/Vulcano_results.csv` | BAT vs WAT DESeq2 result table used for the volcano plot. |
| `DATA/nTPM_df.csv` | GTEx + BAT z-scored TPM dataframe used for UMAP. |
| `SCRIPTS/STAR_index_and_alignment.sbatch` | STAR index generation and alignment script. |
| `SCRIPTS/feature_counts.sbatch` | featureCounts gene-level quantification script. |
| `SCRIPTS/run_rnaseqc_all.sbatch` | RNA-SeQC quantification script. |
| `SCRIPTS/compute_median_tpm.R` | Computes median BAT TPM values across BATLAS samples. |

## Data Sources

- BATLAS RNA-seq data: ENA study `ERP022805`
- Genome annotation: GENCODE v39
- Genome build: GRCh38
- GTEx reference expression matrix: `GTEx_Analysis_2022-06-06_v10_RNASeQCv2.4.2_gene_median_tpm.gct`

## Main Software

The analysis uses a mix of command-line and R tools:

- STAR
- samtools
- FastQC
- MultiQC
- Subread `featureCounts`
- RSeQC
- RNA-SeQC v2.4.2
- R packages: `DESeq2`, `ggplot2`, `dplyr`, `tidyr`, `readr`, `stringr`, `tibble`, `purrr`, `ggrepel`, `EnhancedVolcano`, `fgsea`, `uwot`, `RColorBrewer`

## Workflow Summary

1. Download BATLAS Cohort 2 FASTQ files from ENA.
2. Build a STAR index using GRCh38 and GENCODE v39.
3. Align FASTQ files with STAR and generate sorted BAM files.
4. Run FastQC/MultiQC and RSeQC for RNA-seq QC.
5. Quantify raw gene counts with featureCounts.
6. Import counts into DESeq2 and compare BAT vs WAT.
7. Annotate genes with the local GENCODE v39 GTF.
8. Generate volcano plot results and run GSEA for brown fat markers.
9. Quantify BAT TPM values with RNA-SeQC.
10. Merge BAT median TPM with GTEx tissue median TPM values.
11. Z-score the merged TPM matrix and generate the UMAP visualization.

## Reproducing the Reports

Some steps in the report were originally run on HPC scratch storage and use absolute cluster paths. If rerunning the full workflow locally or on a different cluster, update the paths in the scripts under `SCRIPTS/` and ensure the input data files are available in the expected locations.

## Notes

- Large intermediate files such as FASTQ files, BAM files, STAR indices, and per-sample RNA-SeQC directories are not included here.
- The GTEx + BAT UMAP is intended as a visualization-oriented comparison of tissue expression patterns, not as a batch-corrected joint expression atlas.
- BATLAS Cohort 2 does not include PET validation, so BAT identity is evaluated using transcriptomic evidence such as PCA, marker gene expression, and GSEA.
