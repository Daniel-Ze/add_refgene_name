#!/usr/bin/env Rscript
library(R.utils)
library(ggplot2)
library(readr)

input <- cmdArg("i")

if ( is.na(input) || input == TRUE || is.null(input) ) {
	printf("[error]\tInput required.\n")
	quit()
}

file_path <- dirname( input )
file_name <- basename( input )

one_to_many <- read_tsv(input)

one_to_many$one_to_many <- as.character(one_to_many$one_to_many)

p1<-ggplot(one_to_many, aes(one_to_many, counts))+
	geom_bar(stat = "identity", alpha = 0.6)+
	geom_text(aes(label=round(counts,2)), hjust=-0.2, angle=45)+
	scale_y_continuous(limits = c(0,max(one_to_many$counts)+15000), breaks = seq(0,55000, 5000))+
	theme_bw()+
	xlab("Number of reference gene IDs per annoted genes")+
	ggtitle("Annotated genes with assigned reference gene IDs")

ggsave(file=paste0(file_path,"/",file_name,"_plot.png"), p1, width=8, height=4)
	