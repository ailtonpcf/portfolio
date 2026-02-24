#!/usr/bin/env R

library(extrafont)
# font_import(prompt = FALSE)
# loadfonts(device = "win") # Use "win" for Windows, omit for others

apereira_theme <- function(ratio = 1.1, font = "Arial", ...) { 
  
  theme_bw() %+replace%
    theme(
      plot.tag     = element_text(size = rel(ratio), family = font),
      strip.text   = element_text(size = rel(ratio), family = font),
      axis.text.x    = element_text(size = rel(ratio), family = font),
      axis.text.y    = element_text(size = rel(ratio), family = font),
      axis.title   = element_text(size = rel(ratio), family = font),
      legend.text  = element_text(size = rel(ratio), family = font),
      legend.title = element_text(size = rel(ratio), family = font),
      title              = element_text(size = rel(ratio), family = font),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.background   = element_blank(),
      panel.border       = element_rect(colour = "black", fill = NA),
      ...
    )
}