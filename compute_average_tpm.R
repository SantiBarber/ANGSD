library(dplyr)
library(readr)
library(purrr)

# 1) All gene-level result files
gene_files <- list.files(pattern = "\\.genes\\.results$")

# 2) Read each file: gene_id + TPM, TPM column named by sample
read_one <- function(f) {
  sample <- sub("\\.genes\\.results$", "", f)
  read_tsv(f, show_col_types = FALSE) %>%
    select(gene_id, TPM) %>%
    rename(!!sample := TPM)
}

gene_list <- lapply(gene_files, read_one)

# 3) Merge on gene_id
merged_tpm <- reduce(gene_list, full_join, by = "gene_id")

# 4) Replace NAs with 0
merged_tpm[is.na(merged_tpm)] <- 0

# 5) Row-wise mean TPM
avg_tpm <- merged_tpm %>%
  rowwise() %>%
  mutate(mean_TPM = mean(c_across(-gene_id))) %>%
  ungroup() %>%
  select(gene_id, mean_TPM)

# 6) Save
write_tsv(avg_tpm, "average_TPM_across_samples.tsv")
