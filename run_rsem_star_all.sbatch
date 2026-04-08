#!/bin/bash
#SBATCH --job-name=rsem_star_all
#SBATCH --output=rsem_star_all_%j.out
#SBATCH --error=rsem_star_all_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G

source ~/.bashrc
mamba activate STAR

cd /storage/scratch01/groups/md/microproteins/BROWN_GTEx_TPM_STAR/Cohort_1

mkdir -p rsem_results

REF_PREFIX="/storage/scratch01/groups/md/microproteins/BROWN_GTEx_TPM_STAR/Cohort_2/rsem_star_reference/gencode_v39"
STAR_PATH=$(dirname "$(which STAR)")

for fastq in ERR*.fastq.gz; do
    sample=$(basename "$fastq" .fastq.gz)
    echo "Quantifying sample: $sample"

    rsem-calculate-expression \
        --star \
        --star-path "$STAR_PATH" \
        --star-gzipped-read-file \
        -p 8 \
        "$fastq" \
        "$REF_PREFIX" \
        "rsem_results/${sample}"

    echo "Done: $sample"
    echo "-----------------------------------------"
done