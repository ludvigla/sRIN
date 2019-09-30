#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  if (!require("raster")) install.packages("raster")
  library(raster)
  if (!require("rgdal")) install.packages("rgdal")
  library(rgdal)
  if (!require("argparse")) install.packages("argparse")
  library(argparse)
})

# Create parser object
parser <- ArgumentParser()

# specify our desired options 
# by default ArgumentParser will add an help option 
parser$add_argument("files", nargs=5, help="TIF files for each probe")
parser$add_argument("-o", "--output-folder", action="store", default="", 
                    help="Specify folder to save the plots in")
parser$add_argument("--plot-error", default=FALSE, action="store_true",
                    help="Should the alignment error be plotted? [default %(default)s]")
parser$add_argument("-v", "--verbose", action="store_true", default=FALSE,
                    help="Print extra output [default]")

args <- parser$parse_args()

tif_files <- args$files
#tif_files <- c("~/sRIN/tifs/tif_for_single_wells_G70/D1_P0.tif", "~/sRIN/tifs/tif_for_single_wells_G70/D1_P1.tif", "~/sRIN/tifs/tif_for_single_wells_G70/D1_P2.tif",
#               "~/sRIN/tifs/tif_for_single_wells_G70/D1_P3.tif", "~/sRIN/tifs/tif_for_single_wells_G70/D1_P4.tif")

sRIN_path <- paste0(args$output_folder, "sRIN_heatmap.png")
sRIN_error_path <- paste0(args$output_folder, "sRIN_error.png")

# Check that files exists
for (f in tif_files) {
  if (!file.exists(f)) stop(paste0("Invalid path: ", f), call. = F)
}

#Load probe sets. Probe 0 is the optional background probe
if (args$verbose) cat("Loading TIFs ... \n")
probes <- setNames(lapply(tif_files, raster), nm = paste0("P", 0:4))

#Set colours for plot. The first colour is the background colour. If you want black as the background, then the first two colours are black and black
colours <- c( "black", "cyan", "yellow", "red", "dark red")

#Gather all images into one object. calling plot() on this object will draw one plot for every probe
if (args$verbose) cat("Stacking probes ... \n")
probe_brick <- brick(stack(probes))

#Set the background threshold. Currently the 75th quantile of the background probe
threshold <- quantile(probes[["P0"]], probs=0.75)
if (args$verbose) cat(paste0("Setting background threshold to ", threshold, " ... \n"))

#Create a dataset to use for normalisation
if (args$verbose) cat("Defining background signal ... \n")
norm_data <- pmin(pmax(as.matrix(probes[["P1"]] - threshold - probes[["P0"]]), 0), threshold)

#Normalise data for each probe and convert it to sRIN scale
if (args$verbose) cat("Normalizing signal intensities ... \n")
normalized_probes <- lapply(names(probes[2:5]), function(probe) {
  raster(ifelse(is.finite(pmin(pmax(as.matrix(probes[[probe]] - threshold - probes[["P0"]]), 0), threshold)/norm_data*2.5), pmin(pmax(as.matrix(probes[[probe]] - threshold - probes[["P0"]]), 0), threshold)/norm_data*2.5, 0))
})

#Add all the values together in one object
if (args$verbose) cat("Plotting sRIN heatmap ... \n")
png(filename = sRIN_path, width = probes[["P0"]]@ncols, height = probes[["P0"]]@nrows)
sRIN <- overlay(brick(stack(normalized_probes)), fun = function(a, b, c, d) (a + b + c + d), unstack=TRUE)
bb <- c(0, 0, 2.5, 5, 7.5, 10)
par(mar = c(0, 0, 0, 0))
image(sRIN, col = colours, breaks = bb, main = "Title", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
lg_width <- round(probes[["P0"]]@ncols/10); lg_height <- round(lg_width*1.5)
legend(x = c(0, lg_width/probes[["P0"]]@ncols), 
       y = c(probes[["P0"]]@nrows - lg_height, probes[["P0"]]@nrows)/probes[["P0"]]@nrows, 
       legend = c("10","7.5","5","2.5","0"), 
       fill = rev(colours), 
       title = "sRIN", cex = 2)
dev.off()
if (args$verbose) cat(paste0("Heatmap saved to ", sRIN_path, " ... \n"))

# Plot error is specified
if (args$plot_error) {
  if (args$verbose) cat("Plotting error heatmap ... \n")
  png(filename = sRIN_error_path, width = probes[["P0"]]@ncols, height = probes[["P0"]]@nrows)
  col2 <- c("black")
  brks <- c(0, 11)
  par(mar = c(0, 0, 0, 0))
  image(sRIN, col = col2, breaks = brks)
  lg_width <- round(probes[["P0"]]@ncols/5); lg_height <- round(lg_width/4)
  legend(x = c(0, lg_width/probes[["P0"]]@ncols), 
         y = c(probes[["P0"]]@nrows - lg_height, probes[["P0"]]@nrows)/probes[["P0"]]@nrows, 
         legend = paste("Error rate: ", round(sum(values(sRIN > 10))/ncell(sRIN)*100, digits = 2), "%", sep = ""), 
         cex = 2)
  dev.off()
  if (args$verbose) cat(paste0("Error heatmap saved to ", sRIN_path, " ... \n"))
}

if (args$verbose) cat(paste0("Complete. \n"))
