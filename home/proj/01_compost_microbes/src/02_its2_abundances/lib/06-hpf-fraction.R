source("src/26-compost76-its2-abundances/lib/01-add-tax-to-abundances.R")

hp_genus <- hpf %>% 
  distinct(genus) %>% 
  pull(genus) %>% 
  discard(~ .x == "Aspergillus") %>% 
  paste(collapse = "|")

hpf_df <- 
euk_tax_qc %>% 
  filter(!sample %in% pull(failed_samples, sample)) %>% 
  filter(!genus == "Glaciozyma") %>% 
  mutate(group = case_when(
    str_detect(genus, hp_genus) ~ "Human pathogenic fungi",
    genus == "Aspergillus" ~ "Aspergillus",
    TRUE ~ "Non-human pathogenic fungi"
  )) %>%
  group_by(sample, group) %>% 
  summarise(abundance = sum(abundance))

hpf_sample_order <- 
  hpf_df %>% 
  filter(!str_detect(sample, "ctl")) %>% 
  filter(!group == "Non-human pathogenic fungi") %>% 
  group_by(sample) %>% 
  summarise(abundance = sum(abundance)) %>% 
  arrange(desc(abundance)) %>% 
  pull(sample)

afu_hpf_colors <- c(
  "Aspergillus"               ="#d01c8b",
  "Human pathogenic fungi"    ="#0571b0",
 "Non-human pathogenic fungi" ="#4dac26"
)

p <- 
hpf_df %>% 
  filter(!str_detect(sample, "ctl")) %>% 
  mutate(sample = factor(sample, levels = hpf_sample_order)) %>% 
  mutate(group = factor(group, levels = c("Aspergillus", "Human pathogenic fungi", "Non-human pathogenic fungi"))) %>% 
  ggplot(aes(sample, abundance)) +
  geom_col(aes(fill = group), position = "fill") +
  scale_fill_manual(values = afu_hpf_colors) +
  apereira_theme() +
  labs(x = "", y = "Relative abundance (%)", fill = "Group") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")

apereira_save_plot(plot = p,
                   plot_dir = "results/26-compost76-its2-abundances/plt", 
                   plot_name = "hpf-its2-old",width = 11, height = 4)

