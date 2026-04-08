#!/usr/bin/env bash
#SBATCH --job-name=star_hg38_v39
#SBATCH --output=STAR_RUN.out
#SBATCH --error=STAR_RUN.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

set -euo pipefail

# User-configurable paths

PROJECT_DIR="/athena/angsd/scratch/sdb4002/Final_project"
INDEX_DIR="${PROJECT_DIR}/STAR_index_GENCODE_v39"
FASTQ_DIR="${PROJECT_DIR}/FASTQ"
BAM_DIR="${PROJECT_DIR}/BAMs"

# Fasta and GTF 
GENOME_FA="/athena/angsd/scratch/sdb4002/Final_project/GRCh38.primary_assembly.genome.fa"
GTF_FILE="/athena/angsd/scratch/sdb4002/Final_project/gencode.v39.annotation.gtf"

# Since fastq files are 50bp
SJDB_OVERHANG=49

# Environment
source /home/fs01/sdb4002/miniconda3/etc/profile.d/conda.sh
conda activate angsd

# Build STAR index using downloaded reference and FASTA (GENCODE v39, GRCh38/hg38)
mkdir -p "${INDEX_DIR}"
mkdir -p "${BAM_DIR}"

# check if the Index already exist first...
if [[ -s "${INDEX_DIR}/Genome" && -s "${INDEX_DIR}/SA" && -s "${INDEX_DIR}/SAindex" ]]; then
  echo "STAR index already exists in ${INDEX_DIR}; skipping Index creation."
else
  echo "STAR index not found (or incomplete); generating in ${INDEX_DIR}..."
  STAR \
    --runMode genomeGenerate \
    --runThreadN "${SLURM_CPUS_PER_TASK:-1}" \
    --genomeDir "${INDEX_DIR}" \
    --genomeFastaFiles "${GENOME_FA}" \
    --sjdbGTFfile "${GTF_FILE}" \
    --sjdbOverhang "${SJDB_OVERHANG}"
fi

# Align each FASTQ in FASTQ directory and write BAMs to BAM directory
shopt -s nullglob # so it does not crash if FASTQs are not found
FASTQS=("${FASTQ_DIR}"/*.fastq.gz)
(( ${#FASTQS[@]} > 0 )) || { echo "No FASTQs found in ${FASTQ_DIR}" >&2; exit 1; }

for fastq in "${FASTQS[@]}"; do
  sample="$(basename "${fastq}" .fastq.gz)"
  prefix="${BAM_DIR}/${sample}.STAR."

  STAR \
    --runMode alignReads \
    --runThreadN "${SLURM_CPUS_PER_TASK:-1}" \
    --genomeDir "${INDEX_DIR}" \
    --readFilesIn "${fastq}" \
    --readFilesCommand zcat \
    --outFileNamePrefix "${prefix}" \
    --outSAMattributes All \
    --outSAMtype BAM SortedByCoordinate

  samtools index "${prefix}Aligned.sortedByCoord.out.bam"
done