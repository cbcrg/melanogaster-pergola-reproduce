#!/usr/bin/env Rscript

#  Copyright (c) 2014-2018, Centre for Genomic Regulation (CRG).
#  Copyright (c) 2014-2018, Jose Espinosa-Carrasco and the respective authors.
#
#  This file is part of Pergola.
#
#  Pergola is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Pergola is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Pergola.  If not, see <http://www.gnu.org/licenses/>.
############################################################################
### Jose Espinosa-Carrasco CB-CRG Group. Dec 2016                        ###
############################################################################
### Volcano plot from comparison between annotated and not annotated     ###
### regions                                                              ### 
############################################################################

#####################
## VARIABLES
## Reading arguments
args <- commandArgs (TRUE) #if not it doesn't start to count correctly

## Default setting when no arguments passed
if ( length(args) < 1) {
  args <- c("--help")
}

## Help section
if("--help" %in% args) {
  cat("
      volcano_plot_jaaba
      
      Arguments:
      --path2file=someValue       - character, path to read bedGraph files              
      --image_format=image_format - character
      --help                      - print this text
      
      Example:
      ./volcano_plot_jaaba.R --path2file=\"/foo/variables\" --image_format=\"image_format\" \n")
  
  q (save="no")
}

## Use to parse arguments beginning by --
parseArgs <- function(x) 
{
  strsplit (sub ("^--", "", x), "=")
}

## Parsing arguments
argsDF <- as.data.frame (do.call("rbind", parseArgs(args)))
argsL <- as.list (as.character(argsDF$V2))
names (argsL) <- argsDF$V1

# path to variables bedgraph files
{
  if (is.null (argsL$path2file)) 
  {
    stop ("[FATAL]: Path to file containing P-values and fold-changes is mandatory")
  }
  else
  {
    path2file <- argsL$path2file
  }
}

# plot image format
{
  if (is.null (argsL$image_format))
  {
    image_format <- "tiff"
    warning ("[Warning]: format for plots not provided, default tiff")
  }
  else
  {
    image_format <- argsL$image_format
  }
}
## Loading libraries
library("ggplot2")
library("ggrepel")

fc_pvalue <- read.table(path2file, header=FALSE)

colnames (fc_pvalue) <- c("variable", "log2FoldChange", "pvalue")
max_y <- max (fc_pvalue$log2FoldChange)

fc_pvalue$highlight <- ifelse(abs(fc_pvalue$log2FoldChange) > 0.2 & -log10(fc_pvalue$pvalue) > 90, "black", "red") 

fc_pvalue_int <- fc_pvalue [abs(fc_pvalue$log2FoldChange) > 0.4 & -log10(fc_pvalue$pvalue) > 90, ]
fc_pvalue$logPvalue <- log(fc_pvalue$pvalue)

fc_pvalue <- fc_pvalue [fc_pvalue$pvalue != 0,] 
volcano_ggplot <- ggplot(fc_pvalue) +                  
                  geom_point(aes(x=log2FoldChange, y=-log10(pvalue), color=highlight)) +                  
                  scale_color_manual(values=c('red','black'))+
                  geom_text_repel(data=fc_pvalue_int, aes(log2FoldChange, -log10(pvalue), label = variable), size=8) +
                  theme_classic(base_size = 16) +
                  theme(legend.position="none") +
                  labs (title = "\n", y = paste("-Log10(p-value)\n", sep=""), 
                        x = "Log2(Fold change)\n") +
                  xlim(c(-0.5, 1.5))
volcano_ggplot 
plot_width <- 14
plot_height <- 8

name_out <- paste ("volcano_plot_flies", ".", image_format, sep="")
ggsave (file=name_out, width=plot_width, height=plot_height)

fc_pvalue$pvalue <- -log10(fc_pvalue$pvalue)
write.table(fc_pvalue, "tbl_fc_pvalues.txt", sep="\t", col.names=TRUE, row.names=FALSE)
