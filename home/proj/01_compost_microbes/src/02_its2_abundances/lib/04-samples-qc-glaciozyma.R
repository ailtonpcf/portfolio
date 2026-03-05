source("src/26-compost76-its2-abundances/lib/01-add-tax-to-abundances.R")


its2_tss <- 
euk_tax_raw %>% 
  group_by(sample, genus) %>% 
  summarise(abundance = sum(abundance)) %>% 
  mutate(tss = abundance/sum(abundance)) %>% 
  filter(genus == "Glaciozyma") %>% 
  filter(!str_detect(sample, "ctl")) %>% 
  mutate(seq_samples = if_else(tss > 0.6, "Re-sequence", sample))

boxp <- 
  its2_tss %>% 
  ggplot(aes("", tss)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(color = seq_samples)) +
  geom_hline(yintercept = 0.6) +
  labs(x = "Glaciozyma martinii", y = "TSS", color = "Samples for re-sequencing") +
  apereira_theme()

apereira_save_plot(plot = boxp, plot_dir = its2_res, plot_name = "samples-cutoff-glaciozyma-boxp")

hist_ <- 
  its2_tss %>% 
  ggplot(aes(tss)) +
  geom_histogram(bins = 30) +
  geom_density() +
  geom_vline(xintercept = 0.6) +
  labs(x = "TSS", y = "Counts") +
  apereira_theme()

apereira_save_plot(plot = hist_, plot_dir = its2_res, plot_name = "samples-cutoff-glaciozyma-hist")

its2_tss_all <- 
  euk_tax_raw %>% 
  group_by(sample, genus) %>% 
  summarise(abundance = sum(abundance)) %>% 
  mutate(tss = abundance/sum(abundance)) %>% 
  filter(!str_detect(sample, "ctl")) %>% 
  mutate(label = if_else(str_detect(genus, "Glaciozyma"), "Glaciozyma", "Other")) %>% 
  group_by(sample, label) %>% 
  summarise(tss = sum(tss))

its2_tss_all %>% 
  ggplot(aes(fct_reorder2(sample, label, tss), tss)) +
  geom_col(aes(fill = label)) +
  apereira_theme() +
  theme(axis.text.x = element_text(angle = 40, vjust = 0.5))

         