library(dplyr)
library(readr)
library(purrr)

base_dir <- "/storage/scratch01/users/sbarber/GTEX/rnaseqc_results"

gene_files <- list.files( # list of all gene TPM files generated
  path = base_dir,
  pattern = "\\.gene_tpm\\.gct$",
  recursive = TRUE,
  full.names = TRUE)

read_one <- function(f) { # function to read one gene TPM file and extract the sample name from the file name
  sample <- sub("\\.gene_tpm\\.gct$", "", basename(f))

  dat <- read_tsv( # read the gene TPM file, skipping the first 2 lines of metadata
    f,
    skip = 2, # spkip 2
    show_col_types = FALSE)

  tpm_col <- setdiff(names(dat), c("Name", "Description"))[1] # get the name of the TPM column (should be the only one other than Name and Description, name of the sample)

  dat %>% # keep only the gene_id and TPM column, and rename them to "gene_id" and the sample name, respectively
    transmute( # drop all other columns, opposite of mutate()
      gene_id = Name,
      !!sample := .data[[tpm_col]])} # name TPM column with the sample name

gene_list <- lapply(gene_files, read_one) # read all gene TPM files into a list

merged_tpm <- reduce(gene_list, full_join, by = "gene_id") # merge all data frames in the list by "gene_id", keeping all genes (full_join)
merged_tpm[is.na(merged_tpm)] <- 0

median_tpm <- merged_tpm %>% # calculate the median TPM across all BAT samples for each gene
  rowwise() %>%
  mutate(median_TPM = median(c_across(-gene_id))) %>%
  ungroup() %>%
  select(gene_id, median_TPM)

write_tsv(median_tpm, "median_TPM_across_samples_cohort_2.tsv")