# sRIN heatmap

This tool can be used to plot a heatmap of RIN values at single cell resolution using the spatial RIN (sRIN). The tool requires TIF files with fluorescence data obtained for each of 5 probes designed for the sRIN assay. Probe 0 is used as a background to normalize while the other four probes binds to various parts of the 18S rRNA with probe1 closest to the 3' end and probe4 closest to the 5' end of the transcript.

To run the script you need to have R installed pon your computer. You will also need to install the following R packages:

````
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

![](data/sRIN_heatmap.png?raw=True "sRIN heatmap")
![](data/sRIN_error.png?raw=True "sRIN heatmap")
