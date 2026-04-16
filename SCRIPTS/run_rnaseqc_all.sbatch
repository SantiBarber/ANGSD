#!/bin/bash
#SBATCH --job-name=rnaseqc_all
#SBATCH --output=rnaseqc_all_%j.out
#SBATCH --error=rnaseqc_all_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G

source ~/.bashrc
conda activate RNA-SEQC

mkdir -p star_bam rnaseqc_results

cd /storage/scratch01/users/sbarber/GTEX

GENOME_DIR="reference/star_index"
GTF="reference/gencode.v39.annotation.gtf"
COLLAPSED_GTF="reference/rnaseqc/gencode.v39.annotation.collapsed.gtf"
FASTA="reference/GRCh38.primary_assembly.genome.fa"

# RNA-SeQC v2.4.2 expects a collapsed annotation GTF with one transcript per gene.
python collapse_gtf_for_rnaseqc.py "$GTF" "$COLLAPSED_GTF"

# generate FASTA index for RNA-SeQC
samtools faidx "$FASTA"

for fastq in ERR*.fastq.gz; do
    sample=$(basename "$fastq" .fastq.gz)
    echo "Quantifying sample: $sample"

    rnaseqc \
        "$COLLAPSED_GTF" \
        "star_bam/${sample}.Aligned.sortedByCoord.out.bam" \
        "rnaseqc_results/${sample}" \
        --sample "$sample" \
        --fasta "$FASTA" \
        -u

    echo "Done: $sample"
    echo "-----------------------------------------"
done