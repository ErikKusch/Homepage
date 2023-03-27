---
title: "Third-Party Data"
author: Erik Kusch
date: '2022-05-26'
slug: third-party
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: "Using KrigR with third-party data"
summary: 'Using `KrigR` with third-party data.'
authors: []
lastmod: '2021-05-26T20:00:00+01:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: 
output:
  blogdown::html_page:
    keep_md: true
    # toc: true
    # toc_depth: 1
    # number_sections: false
# header-includes:
#   <script src = "https://polyfill.io/v3/polyfill.min.js?features = es6"></script>
#   <script id = "MathJax-script" async src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
math: true
type: docs
toc: true 
menu:
  krigr:
    parent: Workshop
    weight: 25
weight: 25
---






{{% hint danger %}}
This part of the workshop is dependant on set-up and preparation done previously [here](/courses/krigr/prep/).
{{% /hint %}}

First, we load `KrigR`:


```r
library(KrigR)
```

## Matching Third-Party Data

I expect that you won't want to downscale to specific resolutions most of the time, but rather, match an already existing spatial data set in terms of spatial resolution and extent. Again, the `KrigR` package got you covered!

{{% hint warning %}}
Usually, you probably want to downscale data to match a certain pre-existing data set rather than a certain resolution.
{{% /hint %}}

Here, we illustrate this with an NDVI-based example. The NDVI is a satellite-derived vegetation index which tells us how green the Earth is. It comes in bi-weekly intervals and at a spatial resolution of `.08333` (roughly 9km). Here, we download all NDVI data for the year 2015 and then create the annual mean. This time, we do so for all of Germany because of its size and topographical variety.

### Third-Party Data


```r
Shape_shp <- ne_countries(country = "Germany")
```




```r
## downloading gimms data
gimms_files <- downloadGimms(x = as.Date("2015-01-01"), # download from January 1982
                             y = as.Date("2015-12-31"), # download to December 1982
                             dsn = Dir.Data, # save downloads in data folder
                             quiet = FALSE # show download progress
                             )
## prcoessing gimms data
gimms_raster <- rasterizeGimms(x = gimms_files, # the data we rasterize
                               remove_header = TRUE # we don't need the header of the data
                               )
indices <- monthlyIndices(gimms_files) # generate month indices from the data
gimms_raster_mvc <- monthlyComposite(gimms_raster, # the data
                                     indices = indices # the indices
                                     )
Negatives <- which(values(gimms_raster_mvc) < 0) # identify all negative values
values(gimms_raster_mvc)[Negatives] <- 0 # set threshold for barren land (NDVI<0)
gimms_raster_mvc <- crop(gimms_raster_mvc, extent(Shape_shp)) # crop to extent
gimms_mask <- KrigR::mask_Shape(gimms_raster_mvc[[1]], Shape = Shape_shp) # create mask ith KrigR-internal function to ensure all edge cells are contained
NDVI_ras <- mask(gimms_raster_mvc, gimms_mask) # mask out shape
NDVI_ras <- calc(NDVI_ras, fun = mean, na.rm = TRUE) # annual mean
writeRaster(NDVI_ras, format = "CDF", file = file.path(Dir.Data, "NDVI")) # save file
```

So what does this raster look like?


```r
NDVI_ras
```

```
## class      : RasterStack 
## dimensions : 92, 108, 9936, 1  (nrow, ncol, ncell, nlayers)
## resolution : 0.08333333, 0.08333333  (x, y)
## extent     : 6, 15, 47.33333, 55  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## names      :     layer 
## min values : 0.2430333 
## max values : 0.8339083
```

And a visualisation of the same:

```r
Plot_Raw(NDVI_ras, 
         Shp = Shape_shp,
         Dates = "Mean NDVI 2015", 
         COL = viridis(100, begin = 0.5, direction = -1))
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-5-1.png" width="1440" />
As stated above, we want to match this with our output.  

### `KrigR` Workflow

We could do this whole analysis in our three steps as outlined above, but why bother when the [pipeline](/courses/krigr/quickstart/#the-pipeline) gets the job done just as well?

{{% hint info %}}
Matching Kriging outputs with a pre-existing data set is as easy as plugging the pre-existing raster into the `Target_res` argument of the `krigR()` or the `download_DEM()` function.
{{% /hint %}}

This time we want to downscale from ERA5 resolution (roughly 30km) because the ERA5-Land data already matches the NDVI resolution (roughly 9km). Here's how we do this:

```r
NDVI_Krig <- krigR(
  ## download_ERA block
  Variable = '2m_temperature',
  Type = 'reanalysis',
  DataSet = 'era5',
  DateStart = '2015-01-01',
  DateStop = '2015-12-31',
  TResolution = 'year',
  TStep = 1,
  Extent = Shape_shp,
  API_User = API_User,
  API_Key = API_Key,
  SingularDL = TRUE,
  ## download_DEM block
  Target_res = NDVI_ras,
  Source = "Drive",
  ## krigR block
  Cores = 1,
  FileName = "AirTemp_NDVI.nc",
  nmax = 80, 
  Dir = Dir.Exports)
```

```
## download_ERA() is starting. Depending on your specifications, this can take a significant time.
```

```
## User 39340 for cds service added successfully in keychain
```

```
## Staging 1 download(s).
```

```
## Staging your request as a singular download now. This can take a long time due to size of required product.
```

```
## 0001_2m_temperature_2015-01-01_2015-12-31_year.nc download queried
```

```
## Requesting data to the cds service with username 39340
```

```
## - staging data transfer at url endpoint or request id:
```

```
##   850485ad-d5f1-43f5-94e8-e238c5ec9593
```

```
## - timeout set to 10.0 hours
```

```
## - polling server for a data transfer \ polling server for a data transfer | polling
## server for a data transfer / polling server for a data transfer - polling server for a
## data transfer \ polling server for a data transfer | polling server for a data transfer /
## polling server for a data transfer - polling server for a data transfer \ polling server
## for a data transfer | polling server for a data transfer / polling server for a data
## transfer - polling server for a data transfer \ polling server for a data transfer |
## polling server for a data transfer / polling server for a data transfer - polling server
## for a data transfer \ polling server for a data transfer | polling server for a data
## transfer / polling server for a data transfer - polling server for a data transfer \
## polling server for a data transfer | polling server for a data transfer / polling server
## for a data transfer - polling server for a data transfer
```

```
## 
  |                                                                                      
  |                                                                                |   0%
  |                                                                                      
  |=============================================================                   |  76%
  |                                                                                      
  |================================================================================| 100%
```

```
## - moved temporary file to -> C:/Users/erike/Documents/Website/content/courses/krigr/Exports/0001_2m_temperature_2015-01-01_2015-12-31_year.nc
## - request purged from queue!
## Checking for known data issues.
## Loading downloaded data for masking and aggregation.
## Masking according to shape/buffer polygon
## Aggregating to temporal resolution of choice
```

```
## 
  |                                                                                      
  |                                                                                |   0%
  |                                                                                      
  |===========================                                                     |  33%
  |                                                                                      
  |=====================================================                           |  67%
  |                                                                                      
  |================================================================================| 100%
## 
```

```
## Commencing Kriging
```

```
## 
  |                                                                                      
  |                                                                                |   0%
  |                                                                                      
  |================================================================================| 100%
```

So? Did we match the pre-existing data?

```r
NDVI_Krig[[1]]
```

```
## class      : RasterBrick 
## dimensions : 92, 108, 9936, 1  (nrow, ncol, ncell, nlayers)
## resolution : 0.08333333, 0.08333333  (x, y)
## extent     : 6, 15, 47.33333, 55  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : var1.pred 
## min values :  275.9705 
## max values :  285.7357
```
We nailed this!

Let's take one final look at our (A) raw ERA5 data, (B) NDVI data, (C) Kriged ERA5 data, and (D) standard error of our Kriging output:

<details><summary> Click here for download plotting calls </summary>

```r
### ERA-Plot
ERA_df <- as.data.frame(raster(file.path(Dir.Exports, "2m_temperature_2015-01-01_2015-12-31_year.nc")), xy = TRUE) # turn raster into dataframe
colnames(ERA_df)[c(-1,-2)] <- "Air Temperature 2015 (ERA5)"
ERA_df <- gather(data = ERA_df, key = Values, value = "value", colnames(ERA_df)[c(-1,-2)]) #  make ggplot-ready
Raw_plot <- ggplot() + # create a plot
  geom_raster(data = ERA_df , aes(x = x, y = y, fill = value)) + # plot the raw data
  facet_wrap(~Values) + # split raster layers up
  theme_bw() + labs(x = "Longitude", y = "Latitude") + # make plot more readable
  scale_fill_gradientn(name = "Air Temperature [K]", colours = inferno(100)) + # add colour and legend
  geom_polygon(data = Shape_shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
### NDVI-Plot
NDVI_df <- as.data.frame(NDVI_ras, xy = TRUE) # turn raster into dataframe
colnames(NDVI_df)[c(-1,-2)] <- "NDVI 2015"
NDVI_df <- gather(data = NDVI_df, key = Values, value = "value", colnames(NDVI_df)[c(-1,-2)]) #  make ggplot-ready
NDVI_plot <- ggplot() + # create a plot
  geom_raster(data = NDVI_df , aes(x = x, y = y, fill = value)) + # plot the raw data
  facet_wrap(~Values) + # split raster layers up
  theme_bw() + labs(x = "Longitude", y = "Latitude") + # make plot more readable
  scale_fill_gradientn(name = "NDVI", colours = rev(terrain.colors(100))) + # add colour and legend
  geom_polygon(data = Shape_shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
### KRIGED-Plots
Dates = c("Kriged Air Temperature 2015 (NDVI Resolution)")
Type_vec <- c("Prediction", "Standard Error") # these are the output types of krigR
Colours_ls <- list(inferno(100), rev(viridis(100))) # we want separate colours for the types
Plots_ls <- as.list(NA, NA) # this list will be filled with the output plots
KrigDF_ls <- as.list(NA, NA) # this list will be filled with the output data
for(Plot in 1:2){ # loop over both output types
  Krig_df <- as.data.frame(NDVI_Krig[[Plot]], xy = TRUE) # turn raster into dataframe
  colnames(Krig_df)[c(-1,-2)] <- paste(Type_vec[Plot], Dates) # set colnames
  Krig_df <- gather(data = Krig_df, key = Values, value = "value", colnames(Krig_df)[c(-1,-2)]) # make ggplot-ready
  Plots_ls[[Plot]] <- ggplot() + # create plot
    geom_raster(data = Krig_df , aes(x = x, y = y, fill = value)) + # plot the kriged data
    facet_wrap(~Values) + # split raster layers up
    theme_bw() + labs(x = "Longitude", y = "Latitude") + # make plot more readable
    scale_fill_gradientn(name = "Air Temperature [K]", colours = Colours_ls[[Plot]]) + # add colour and legend
    theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) + # reduce margins (for fusing of plots)
    geom_polygon(data = Shape_shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
  KrigDF_ls[[Plot]] <- Krig_df
} # end of type-loop
```


</details>


```r
plot_grid(plotlist = list(Raw_plot, NDVI_plot, Plots_ls[[1]], Plots_ls[[2]]), 
          nrow = 2, labels = "AUTO")
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-9-1.png" width="1440" />

So what can we learn from this? Let's plot the relation between temperature and NDVI:

```r
plot_df <- as.data.frame(cbind(KrigDF_ls[[1]][,4], 
                               KrigDF_ls[[2]][,4],
                               NDVI_df[,4]))
colnames(plot_df) <- c("Temperature", "Uncertainty", "NDVI")
ggplot(plot_df,
       aes(x = Temperature, y = NDVI, size = Uncertainty)) + 
  geom_point(alpha = 0.15) + 
  theme_bw()
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-10-1.png" width="1440" />

Looks like NDVI increases as mean annual temperatures rise, but reaches a peak around 281-282 Kelvin with a subsequent decrease as mean annual temperatures rise higher.

## Using Third-Party Data

{{% hint danger %}}
**ATTENTION:** Kriging only works on **square-cell spatial products**!
{{% /hint %}}

The `krigR()` function is designed to work with non-ERA5(-Land) data as well as non-GMTED2010 covariate data. To downscale your own spatial products using different covariate data than the GMTED2010 DEM we use as a default, you need to step into the three-step workflow. 

{{% hint warning %}}
Most spatial products won't be reliably downscaled using only elevation covariate data.
{{% /hint %}}

`krigR()` supports any combination of ERA5-family reanalysis, GMTED2010, third-party climate data, and third-party covariate data. Here, we just demonstrate the use of other covariates than the GMTED2010 used by `KrigR` by default.  

The product we will focus on here is the soil moisture data contained in our `BCq_ras` product established [here](/courses/krigr/bioclim/#water-availability-variables). With this data set, we also revert back to our original [study region](/courses/krigr/prep/#shape-of-interest-spatialpolygons):



The reason we focus on soil moisture for this exercise? In [this publication (Figure 3)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf), we demonstrate that soil moisture data can be statistically downscales using kriging with some third-party covariates. As such, we pick up from where we left off when we discussed [kriging of bioclimatic products](/courses/krigr/bioclim/#water-availability-3).

<details>
  <summary>Click here for file:</summary>
      Download 
<a href="/courses/krigr/Data/Qsoil_BC.nc">Qsoil_BC.nc</a> and place it into your data directory.
</details> 


```r
BCq_ras <- stack(file.path(Dir.Data, "Qsoil_BC.nc"))
```

### Third-Party Data Covariates

In [this publication](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf), we demonstrate how soil moisture data can be reliably statistically downscaled using soil property data which we obtain from the [Land-Atmosphere Interaction Research Group at Sun Yat-sen University](http://globalchange.bnu.edu.cn/research/soil4.jsp).

Below, you will find the code needed to obtain the data of global coverage at roughly 1km spatial resolution. The code chunk below also crops and masks the data according to our study region and subsequently deletes the storage-heavy global files (3.5GB each in size). This process takes a long time due to download speeds.

<details>
  <summary>Click here for the covariate file to save yourself downloading and processing of global data:</summary>
      Download 
<a href="/courses/krigr/Covariates/SoilCovs.nc">SoilCovs.nc</a> and place it into your covariates directory.
</details> 


```r
# documentation of these can be found here http://globalchange.bnu.edu.cn/research/soil4.jsp
SoilCovs_vec <- c("tkdry", "tksat", "csol", "k_s", "lambda", "psi", "theta_s") # need these names for addressing soil covariates
if(!file.exists(file.path(Dir.Covariates, "SoilCovs.nc"))){
  print("#### Loading SOIL PROPERTY covariate data. ####") 
  # create lists to combine soil data into one
  SoilCovs_ls <- as.list(rep(NA, length(SoilCovs_vec)))
  names(SoilCovs_ls) <- c(SoilCovs_vec)
  ## Downloading, unpacking, and loading
  for(Soil_Iter in SoilCovs_vec){
    if(!file.exists(file.path(Dir.Covariates, paste0(Soil_Iter, ".nc")))) { # if not downloaded and processed yet
      print(paste("Handling", Soil_Iter, "data."))
      Dir.Soil <- file.path(Dir.Covariates, Soil_Iter)
      dir.create(Dir.Soil)
      download.file(paste0("http://globalchange.bnu.edu.cn/download/data/worldptf/", Soil_Iter,".zip"),
                    destfile = file.path(Dir.Soil, paste0(Soil_Iter, ".zip"))
      ) # download data
      unzip(file.path(Dir.Soil, paste0(Soil_Iter, ".zip")), exdir = Dir.Soil) # unzip data
      File <- list.files(Dir.Soil, pattern = ".nc")[1] # only keep first soil layer
      Soil_ras <- raster(file.path(Dir.Soil, File)) # load data
      SoilCovs_ls[[which(names(SoilCovs_ls) == Soil_Iter)]] <- Soil_ras # save to list
      writeRaster(x = Soil_ras, filename = file.path(Dir.Covariates, Soil_Iter), format = "CDF")
      unlink(Dir.Soil, recursive = TRUE)
    }else{
      print(paste(Soil_Iter, "already downloaded and processed."))
      SoilCovs_ls[[which(names(SoilCovs_ls) == Soil_Iter)]] <- raster(file.path(Dir.Covariates, paste0(Soil_Iter, ".nc")))
    }
  }
  ## data handling and manipulation
  SoilCovs_stack <- stack(SoilCovs_ls) # stacking raster layers from list
  SoilCovs_stack <- crop(SoilCovs_stack, extent(BCq_ras)) # cropping to extent of data we have
  SoilCovs_mask <- KrigR::mask_Shape(SoilCovs_stack[[1]], Shape = Shape_shp) # create mask with KrigR-internal function to ensure all edge cells are contained
  SoilCovs_stack <- mask(SoilCovs_stack, SoilCovs_mask) # mask out shape
  ## writing the data
  writeRaster(x = SoilCovs_stack, filename = file.path(Dir.Covariates, "SoilCovs"), format = "CDF")
  ## removing the global files due to their size
  unlink(file.path(Dir.Covariates, paste0(SoilCovs_vec, ".nc")))
}
SoilCovs_stack <- stack(file.path(Dir.Covariates, "SoilCovs.nc"))
names(SoilCovs_stack) <- SoilCovs_vec
```

Let's have a look at these data:


```r
SoilCovs_stack
```

```
## class      : RasterStack 
## dimensions : 408, 648, 264384, 7  (nrow, ncol, ncell, nlayers)
## resolution : 0.008333333, 0.008333333  (x, y)
## extent     : 9.725, 15.125, 49.75, 53.15  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## names      :         tkdry,         tksat,          csol,           k_s,        lambda,           psi,       theta_s 
## min values :  5.200000e-02,  1.337000e+00,  2.141000e+06,  5.212523e+00,  8.600000e-02, -5.307258e+01,  3.230000e-01 
## max values :  2.070000e-01,  2.862000e+00,  2.346400e+06,  2.461686e+02,  3.330000e-01, -5.205317e+00,  5.320000e-01
```

Now we need to establish target and training resolution of our covariate data.

First, we focus on the training resolution covariate data. We match our covariate data to our spatial product which we wish to downscale by resampling the covariate data to the coarser resolution:

```r
Coarsecovs <- resample(x = SoilCovs_stack, y = BCq_ras)
```

Second, we aggregate the covariate data to our desired resolution. In this case, 0.02 as done previously [here](/courses/krigr/bioclim/#kriging-bioclimatic-products):


```r
Finecovs <- aggregate(SoilCovs_stack, fact = 0.02/res(SoilCovs_stack)[1])
```

Finally, we combine these into a list like the output of `download_DEM()`:


```r
Covs_ls <- list(Coarsecovs, Finecovs)
Plot_Covs(Covs = Covs_ls, Shape_shp)
```

<img src="krigr-third-party_files/figure-html/SoilCovs-1.png" width="1440" />

{{% hint %}}
Our [development goals](/courses/outlook/) include creating a function that automatically carries out all of the above for you with a specification alike to `download_DEM()`.
{{% /hint %}}

### Kriging Third-Party Data

Finally, we can statistically downscale our soil moisture data using the soil property covariates. For this, we need to specify a new `KrigingEquation`. 

{{% hint %}}
With the `KrigingEquation` argument, you may specify non-linear combinations of covariates for your call to `krigR()`.
{{% /hint %}}

{{% hint info %}}
If you don't specify a `KrigingEquation` in `krigR()` and your covariates do not contain a layer called `"DEM"`, `krigR()` will notify you that its default formula cannot be executed and will attempt to build an additive formula from the data it can find. `krigr()` will inform you of this and ask for your approval before proceeding.
{{% /hint %}}

This auto-generated formula would be the same as the one we specify here - an additive combination of all covariates found both at coarse and fine resolutions. Of course, this formula can also be specified to reflect interactive effects.

Here, I automate the generation of our `KrigingEquation`:


```r
KrigingEquation <- paste0("ERA ~ ", paste(SoilCovs_vec, collapse = " + "))
KrigingEquation
```

```
## [1] "ERA ~ tkdry + tksat + csol + k_s + lambda + psi + theta_s"
```

In accordance with our [downscaling of the temperature-portion of the bioclimatic data](/courses/krigr/bioclim/#temperatures-3), (1) I only hand the last 8 layers to the kriging call because those are the soil moisture data, (2) I leave out the `Cores` argument, so that `krigR()` determines how many cores your machine has and uses all of them to speed up the computation of the multi-layer raster, and (3) I set `nmax` to 80 to approximate a typical weather system in size:


```r
BC_Water_Krig  <- krigR(Data = BCq_ras[[12:19]], 
                    Covariates_coarse = Covs_ls[[1]], 
                    Covariates_fine = Covs_ls[[2]],
                    KrigingEquation = KrigingEquation, 
                    FileName = "BC_Water_Krig",
                    Dir = Dir.Covariates,
                    nmax = 80
)
```

#### BIO12 - Annual Mean Soil Moisture

{{% hint normal %}}
Interpolating this data is just like statistically downscaling any other soil moisture product and can be done without any problems.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  
{{% hint normal %}}
Look at how well the river Elbe sows up in this!
{{% /hint %}}

```r
Plot_Krigs(lapply(BC_Water_Krig[-3], "[[", 1), 
           Shp = Shape_shp,
           Dates = "BIO12 - Annual Mean Soil Moisture")
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-18-1.png" width="1440" />
</details>

#### BIO13 - Soil Moisture of Wettest Month

{{% hint normal %}}
Interpolating this data is just like statistically downscaling any other soil moisture product and can be done without any problems.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  

```r
Plot_Krigs(lapply(BC_Water_Krig[-3], "[[", 2), 
           Shp = Shape_shp,
           Dates = "BIO13 - Soil Moisture of Wettest Month")
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-19-1.png" width="1440" />
</details>

#### BIO14 - Soil Moisture of Driest Month

{{% hint normal %}}
Interpolating this data is just like statistically downscaling any other soil moisture product and can be done without any problems.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  

```r
Plot_Krigs(lapply(BC_Water_Krig[-3], "[[", 3), 
           Shp = Shape_shp,
           Dates = "BIO13 - Soil Moisture of Driest Month")
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-20-1.png" width="1440" />
</details>

#### BIO15 - Soil Moisture Seasonality

{{% hint warning %}}
This data product is calculated using the standard deviation of mean values throughout our time frame. Conclusively, it would be interpolated better by first statistically downscaling the underlying data rather than the final bioclimatic variable.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  

```r
Plot_Krigs(lapply(BC_Water_Krig[-3], "[[", 4), 
           Shp = Shape_shp,
           Dates = "BIO15 - Precipitation Seasonality")
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-21-1.png" width="1440" />
</details>

#### BIO16 & BIO17 - Soil Moisture of Wettest and Driest Quarter

{{% hint danger %}}
**I do not recommend you use these kriging outputs!** They rely on mean quarterly soil moisture data which is not being interpolated here. Subsequently, the patchiness of the underlying data is lost and with it: information.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Water_Krig[-3], "[[", 5:6), 
           Shp = Shape_shp,
           Dates = c("BIO16 - Soil Moisture of Wettest Quarter", 
                     "BIO17 - Soil Moisture of Driest Quarter")
           )
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-22-1.png" width="1440" />
</details>


#### BIO18 & BIO19 - Precipitation of Warmest and Coldest Quarter

{{% hint danger %}}
**I do not recommend you use these kriging outputs!** They rely on mean quarterly temperature data which is not being interpolated here. Subsequently, the patchiness of the underlying data is lost and with it: information.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Water_Krig[-3], "[[", 7:8), 
           Shp = Shape_shp,
           Dates = c("BIO16 - Soil Moisture of Warmest Quarter", 
                     "BIO17 - Soil Moisture of Coldest Quarter")
           )
```

<img src="krigr-third-party_files/figure-html/unnamed-chunk-23-1.png" width="1440" />
</details>

This concludes our exercise for using third-party data in `KrigR`.

## Session Info

```r
sessionInfo()
```

```
## R version 4.0.5 (2021-03-31)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 19043)
## 
## Matrix products: default
## 
## locale:
## [1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252   
## [3] LC_MONETARY=English_United Kingdom.1252 LC_NUMERIC=C                           
## [5] LC_TIME=English_United Kingdom.1252    
## 
## attached base packages:
## [1] parallel  stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] mapview_2.10.2          rnaturalearthdata_0.1.0 rnaturalearth_0.1.0    
##  [4] gimms_1.2.0             ggmap_3.0.0             cowplot_1.1.1          
##  [7] viridis_0.6.0           viridisLite_0.4.0       ggplot2_3.3.6          
## [10] tidyr_1.1.3             KrigR_0.1.2             httr_1.4.2             
## [13] stars_0.5-3             abind_1.4-5             fasterize_1.0.3        
## [16] sf_1.0-0                lubridate_1.7.10        automap_1.0-14         
## [19] doSNOW_1.0.19           snow_0.4-3              doParallel_1.0.16      
## [22] iterators_1.0.13        foreach_1.5.1           rgdal_1.5-23           
## [25] raster_3.4-13           sp_1.4-5                stringr_1.4.0          
## [28] keyring_1.2.0           ecmwfr_1.3.0            ncdf4_1.17             
## 
## loaded via a namespace (and not attached):
##  [1] bitops_1.0-7             satellite_1.0.2          xts_0.12.1              
##  [4] webshot_0.5.2            tools_4.0.5              bslib_0.3.1             
##  [7] utf8_1.2.1               R6_2.5.0                 zyp_0.10-1.1            
## [10] KernSmooth_2.23-18       DBI_1.1.1                colorspace_2.0-0        
## [13] withr_2.4.2              tidyselect_1.1.0         gridExtra_2.3           
## [16] leaflet_2.0.4.1          curl_4.3.2               compiler_4.0.5          
## [19] leafem_0.1.3             gstat_2.0-7              labeling_0.4.2          
## [22] bookdown_0.22            sass_0.4.1               scales_1.1.1            
## [25] classInt_0.4-3           proxy_0.4-25             digest_0.6.27           
## [28] rmarkdown_2.14           base64enc_0.1-3          jpeg_0.1-8.1            
## [31] pkgconfig_2.0.3          htmltools_0.5.2          highr_0.9               
## [34] fastmap_1.1.0            htmlwidgets_1.5.3        rlang_0.4.11            
## [37] FNN_1.1.3                farver_2.1.0             jquerylib_0.1.4         
## [40] generics_0.1.0           zoo_1.8-9                jsonlite_1.7.2          
## [43] crosstalk_1.1.1          dplyr_1.0.5              magrittr_2.0.1          
## [46] Rcpp_1.0.7               munsell_0.5.0            fansi_0.4.2             
## [49] lifecycle_1.0.0          stringi_1.5.3            yaml_2.2.1              
## [52] plyr_1.8.6               grid_4.0.5               crayon_1.4.1            
## [55] lattice_0.20-41          knitr_1.33               pillar_1.6.0            
## [58] boot_1.3-27              rjson_0.2.20             spacetime_1.2-4         
## [61] stats4_4.0.5             codetools_0.2-18         glue_1.4.2              
## [64] evaluate_0.14            blogdown_1.3             vctrs_0.3.7             
## [67] png_0.1-7                RgoogleMaps_1.4.5.3      gtable_0.3.0            
## [70] purrr_0.3.4              reshape_0.8.8            assertthat_0.2.1        
## [73] cachem_1.0.4             xfun_0.31                lwgeom_0.2-6            
## [76] e1071_1.7-6              rnaturalearthhires_0.2.0 class_7.3-18            
## [79] Kendall_2.2              tibble_3.1.1             intervals_0.15.2        
## [82] memoise_2.0.0            units_0.7-2              ellipsis_0.3.2
```
