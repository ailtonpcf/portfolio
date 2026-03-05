library(vegan)
source("src/26-compost76-its2-abundances/lib/01-add-tax-to-abundances.R")


df2rare_its2 <- euk_tax_raw %>% 
  select(sample, otu, abundance) %>% 
  group_by(sample, otu) %>% 
  summarise(abundance = sum(abundance)) %>% 
  pivot_wider(id_cols = sample, names_from = otu, values_from = abundance, values_fill = 0) %>% 
  as.data.frame() %>% 
  column_to_rownames("sample")

perm_its <- rarecurve(df2rare_its2, step = 100, tidy = T)

f <-
  perm_its %>% 
  as_tibble() %>% 
  mutate(group = if_else(str_detect(Site, "ctl"), "Control", "Sample")) %>% 
  ggplot(aes(x=Sample, y=Species, group = Site)) +
  geom_line(aes(color = group)) +
  labs(x = "Sample size", 
       y = "OTUs") +
  theme_bw() +
  theme(strip.text = element_text(size = rel(1.2)),
        axis.text = element_text(size = rel(1.2)),
        title = element_text(size = rel(1.2)),
        axis.title = element_text(size = rel(1.2)),
        legend.text = element_text(size = rel(1.2)),
        legend.title = element_text(size = rel(1.2)),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA),
        plot.margin = margin(t = 30, r = 30, b = 30, l = 30))

plt_dir <- "results/26-compost76-its2-abundances/plt"

dir.create(path = plt_dir, recursive = T)
  
ggsave(filename = paste(plt_dir, "rarecurve-its2-compost-76-spikein.pdf", sep = "/"), 
       plot = f, width = 9, height = 7, dpi = 150)

ggsave(filename = paste(plt_dir, "rarecurve-its2-compost-76-spikein.png", sep = "/"), 
       plot = f, width = 9, height = 7, dpi = 150)
