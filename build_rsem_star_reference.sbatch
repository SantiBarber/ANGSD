#!/bin/bash
#SBATCH --job-name=rsem_star_ref
#SBATCH --output=rsem_star_ref_%j.out
#SBATCH --error=rsem_star_ref_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

source ~/.bashrc
mamba activate STAR

cd /storage/scratch01/groups/md/microproteins/BROWN_GTEx_TPM_STAR

rsem-prepare-reference \
  --gtf gencode.v39.annotation.gtf \
  --star \
  GRCh38.primary_assembly.genome.fa \
  rsem_star_reference/gencode_v39
