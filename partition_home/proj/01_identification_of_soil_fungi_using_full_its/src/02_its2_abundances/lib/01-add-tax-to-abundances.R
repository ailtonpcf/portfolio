library(tidyverse)
source("src/00-r-defaults/defaults.R")

# Taxonomic ranks to parse unite taxonomy
groups <- list(
  "species" = c("kingdom", "phylum", "class", "order", "family", "genus", "species")
)

# Import unite taxonomy
unite_tax <- read_tsv("~/draco/ref/unite/all_euk9/unite97dyn_tax.txt", col_names = F, skip = 1) %>% 
  mutate(X2 = str_remove_all(X2, "[a-z]__")) %>% 
  separate(col = X2, into = groups$species, sep = ";") %>% 
  rename(otu = X1)

# abundances from qiime2
abundance_path <- c(
  "~/work/proj/02-compost-microbes/cache/26-compost76-its2-abundances",
  "all-euk-its2-abundances/unite97dyn-feature-table-abundances.tsv"
) %>% paste(collapse = "/")

# Import abundances
raw_abundance <- read_tsv(file = abundance_path, skip = 1)

tax_abundances_dir <- c(
  "~/work/proj/02-compost-microbes/cache/26-compost76-its2-abundances",
  "abundances-with-taxonomy"
) %>% paste(collapse = "/")

dir.create(path = tax_abundances_dir, recursive = T)

# Save raw abundances with taxonomy
euk_tax_qc <- 
raw_abundance %>% 
  rename(otu = `#OTU ID`) %>% 
  pivot_longer(cols = -otu, names_to = "sample", values_to = "abundance") %>% 
  filter(abundance > 0) %>% 
  filter(!sample  %in% failed_samples$sample) %>% 
  left_join(unite_tax) %>% 
  write_tsv(paste(tax_abundances_dir, "raw-all-euk.tsv", sep = "/"))



