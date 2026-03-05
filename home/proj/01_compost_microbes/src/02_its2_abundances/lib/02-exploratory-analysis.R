source("src/26-compost76-its2-abundances/lib/01-add-tax-to-abundances.R")

euk_king <- euk_tax_raw %>% 
  distinct(kingdom) %>% 
  pull(kingdom)

colors <- c(
  "#a50026",
  "#d73027",
  "#f46d43",
  "#fdae61",
  "#fee090",
  "#ffffbf",
  "#e0f3f8",
  "#abd9e9",
  "#74add1",
  "#4575b4",
  "#313695"
)

king_colors <- set_names(colors, euk_king)


# Total abundance by kingdom
a <- euk_tax_raw %>% 
  group_by(sample, kingdom) %>% 
  summarise(abundance = sum(abundance)) %>% 
  ggplot(aes(x=fct_reorder(sample, abundance, .fun = sum), y = abundance)) +
  geom_col(aes(fill = fct_reorder(kingdom, abundance))) +
  labs(x = "Samples", y = "Total abundance", fill = "Kingdom") +
  scale_fill_manual(values = king_colors) +
  theme_bw() +
  theme(axis.title.x = element_text(size = rel(1.1)),
        strip.text = element_text(size = rel(1.1)),
        axis.text = element_text(size = rel(1.1)),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1)),
        axis.text.x = element_text(angle = 40, vjust = 0.5),
        legend.position = "bottom",
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA)) 

plot_dir <- "~/draco/proj/02-compost-microbes/results/26-compost76-its2-abundances/plt"
dir.create(path = plot_dir, recursive = T)

ggsave(filename = paste(plot_dir, "its2-all-euk-kingdom-raw.png", sep = "/"), 
       plot = a, width = 20, height = 7, dpi = 150)

ggsave(filename = paste(plot_dir, "its2-all-euk-kingdom-raw.pdf", sep = "/"), 
       plot = a, width = 20, height = 7, dpi = 150)

# Spike-in fraction

spike_colors <- c(
  "Glaciozyma" = "#878787",
  "Other"      = "#542788"
)

# b <- 
  euk_tax_raw %>% 
  distinct(sample, genus, abundance) %>% 
  mutate(group = map(genus, ~ if_else(.x == "Glaciozyma", "Glaciozyma", "Other"))) %>% 
  unnest(group) %>% 
  group_by(sample, group) %>% 
  summarise(abundance = sum(abundance)) %>% 
  ggplot(aes(x=fct_reorder(sample, abundance, .fun = sum), y = abundance)) +
  geom_col(aes(fill = fct_reorder(group, abundance))) +
  scale_fill_manual(values = spike_colors) +
  labs(x = "Samples", y = "Total abundance", fill = "Genus") +
  theme_bw() +
  theme(axis.title.x = element_text(size = rel(1.1)),
        strip.text = element_text(size = rel(1.1)),
        axis.text = element_text(size = rel(1.1)),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1)),
        axis.text.x = element_text(angle = 40, vjust = 0.5),
        legend.position = "bottom",
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA)) 
  
  ggsave(filename = paste(plot_dir, "glaciozyma-abundance-its2.png", sep = "/"), 
         plot = b, width = 20, height = 7, dpi = 150)
  
  ggsave(filename = paste(plot_dir, "glaciozyma-abundance-its2.pdf", sep = "/"), 
         plot = b, width = 20, height = 7, dpi = 150)

# PCA

genus_raw_wide <- euk_tax_raw %>% 
  group_by(sample, genus) %>% 
  summarise(abundance = sum(abundance)) %>% 
  pivot_wider(id_cols = genus, names_from = sample, values_from = abundance, values_fill = 0) %>% 
  column_to_rownames("genus") %>% 
  as.matrix()

corr_matrix_its <- cor(genus_raw_wide)

data_pca_its <- prcomp(corr_matrix_its, scale = F)

explained_var_its <- summary(data_pca_its)$importance[2,1:2]

# Extract principal components
pcs <- data_pca_its$x

# Create a data frame with the principal components
pc_df <- as_tibble(pcs)

# Add sample IDs to the data frame
pc_df$SampleID <- rownames(corr_matrix_its)


pc_df %>% 
  relocate(SampleID) %>% 
  select(1:3) %>% 
  ggplot(aes(x = PC1, y = PC2)) +
  geom_point() 
ggtitle("PCA Plot of ITS Amplicon Data") +
  xlab(paste("PC1 (", round(explained_var_its[1] * 100, 2), "% variance)")) +
  ylab(paste("PC2 (", round(explained_var_its[2] * 100, 2), "% variance)")) +
  theme_bw() +
  theme(
    strip.text = element_text(size = rel(1.1)),
    axis.text = element_text(size = rel(1.1)), 
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    strip.background = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA))