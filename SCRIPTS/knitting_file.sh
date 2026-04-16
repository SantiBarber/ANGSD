#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "First: activate R conda environment"
  echo "Usage: bash knitting_file.sh <file.Rmd> [output_format]" >&2
  exit 1
fi

INPUT_RMD="$1"
OUTPUT_FORMAT="${2:-html_document}"
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${WORKDIR}"

if ! command -v Rscript >/dev/null 2>&1; then
  echo "Rscript was not found in PATH." >&2
  exit 1
fi

if [[ ! -f "${INPUT_RMD}" ]]; then
  echo "Input file not found: ${INPUT_RMD}" >&2
  exit 1
fi

echo "Rendering ${INPUT_RMD} to ${OUTPUT_FORMAT}"

Rscript -e "rmarkdown::render(input = '${INPUT_RMD}', output_format = '${OUTPUT_FORMAT}', envir = new.env(parent = globalenv()))"

echo "Render completed."