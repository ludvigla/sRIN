# sRIN heat map

This tool can be used to plot a heat map of RIN values at single cell resolution using the spatial RIN (sRIN). 
The tool requires TIF files with fluorescence data obtained for each of 4 probes designed for the sRIN assay and a TIF file for the background signal (denoted P0). 
The background signal is only used to adjust the signal of the probes. The four probes binds to various parts of the 18S rRNA with probe1 closest to the 3' end and probe4 closest to the 5' end of the transcript
and their fluorescence signal can be used as a proxy for the total length of the rRNA transcript.

To run the script you need to have R installed pon your computer. You will also need to install the following R packages:

````
# Run in an R session
install.packages(c("raster", "rgdal", "argparse")
````

If you use this script in your research pelase consider citing [REF]

## Examples

### create sRIN heatmap for test data 

```
# Only plot sRIN heatmap
./sRIN_heatmap.R MOB_P0.tif MOB_P1.tif MOB_P2.tif MOB_P3.tif MOB_P4.tif

# Include error plot
./sRIN_heatmap.R MOB_P0.tif MOB_P1.tif MOB_P2.tif MOB_P3.tif MOB_P4.tif --plot-error

```

### sRIN heat map of MOB tissue

![](data/sRIN_heatmap.png?raw=True "sRIN heatmap")

### Error distribution

Missaligned pixels are colored in white and makes up a total of 0.51% of the image.

![](data/sRIN_error.png?raw=True "sRIN heatmap")
