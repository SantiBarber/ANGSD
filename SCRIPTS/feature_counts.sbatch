#!/usr/bin/env bash
#SBATCH --job-name=featurecounts_batlas
#SBATCH --output=/athena/angsd/scratch/sdb4002/Final_project/featureCounts.out
#SBATCH --error=/athena/angsd/scratch/sdb4002/Final_project/featureCounts.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G

set -euo pipefail
shopt -s nullglob

PROJECT_DIR="/athena/angsd/scratch/sdb4002/Final_project"
BAM_DIR="${PROJECT_DIR}/BAMs"
COUNTS_DIR="${PROJECT_DIR}/counts"
GTF_FILE="${PROJECT_DIR}/gencode.v39.annotation.gtf"

source /home/fs01/sdb4002/miniconda3/etc/profile.d/conda.sh
conda activate angsd

mkdir -p "${COUNTS_DIR}"

BAMS=("${BAM_DIR}"/*.bam)
(( ${#BAMS[@]} > 0 )) || { echo "No BAM files found in ${BAM_DIR}" >&2; exit 1; }

featureCounts \
  -T "${SLURM_CPUS_PER_TASK:-1}" \
  -a "${GTF_FILE}" \
  -o "${COUNTS_DIR}/BATLAS_featureCounts.txt" \
  -t exon \
  -g gene_id \
  "${BAMS[@]}"