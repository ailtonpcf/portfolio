source("src/26-compost76-its2-abundances/lib/01-add-tax-to-abundances.R")
library(RColorBrewer)

# Color palete for genus
n <- 74
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
set.seed(345)
col_vector <- sample(x = col_vector, size = 74)

euk_tss <- 
  euk_tax_qc %>% 
  filter(!str_detect(sample, "ctl")) %>% 
  filter(!str_detect(genus, "Glaciozyma")) %>% 
  group_by(sample, genus) %>% 
  summarise(abundance = sum(abundance)) %>% 
  mutate(tss = abundance/sum(abundance)) %>% 
  arrange(sample, desc(tss)) %>% 
  mutate(label = if_else(tss < 0.05, "Other", genus))

genus_color_euk <- 
  euk_tss %>% 
  ungroup() %>% 
  count(label) %>% 
  rowid_to_column("index") %>% 
  left_join(
    col_vector %>% 
      as_tibble() %>% 
      rowid_to_column("index")
  ) %>% 
  distinct(label, value) %>% 
  deframe()

# p <- 
  euk_tss %>% 
  ggplot(aes(fct_reorder(sample, tss), tss)) +
  geom_col(aes(fill = fct_reorder(label, tss))) +
  scale_fill_manual(values = genus_color_euk) +
  apereira_theme() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 40, vjust = 0.5))

apereira_save_plot(plot = p, 
                   plot_dir = euk_dir, 
                   plot_name = "eukdetect-abundant-genera", 
                   width = 17)
  
