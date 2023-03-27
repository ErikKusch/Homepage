---
title: "Statistical Downscaling"
author: Erik Kusch
date: '2022-05-26'
slug: kriging
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: "Using KrigR to downscale ECMWF products"
summary: 'Kriging specifications and considerations with `KrigR`.'
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
    weight: 15
weight: 15
---







{{% hint danger %}}
This part of the workshop is dependant on set-up and preparation done previously [here](/courses/krigr/prep/).
{{% /hint %}}

First, we load `KrigR`:


```r
library(KrigR)
```

{{% hint info %}}
Statistical downscaling with `KrigR` is handled via the `krigR()` function and requires a set of spatial covariates.
{{% /hint %}}

{{% hint warning %}}
For an introduction to the statistical downscaling process, I will first walk you through the `SpatialPolygons` spatial preference.
{{% /hint %}}

First, we load the data we wish to statistically downscale. We established these data [here](/courses/krigr/download//#climate-data).

```r
SpatialPolygonsRaw <- stack(file.path(Dir.Data, "SpatialPolygonsRaw.nc"))
```

We are now ready to begin our journey to high-spatial resolution data products!

## Covariates

First, we use the `download_DEM()` function which comes with `KrigR` to obtain elevation data as our covariate of choice. This produces two rasters:  
1. A raster of **training** resolution which matches the input data in all attributes except for the data in each cell.  
2. A raster of **target** resolution which matches the input data as closely as possible in all attributes except for the resolution (which is specified by the user).  

Both of these products are bundled into a `list` where the first element corresponds to the *training* resolution and the second element contains the *target* resolution covariate data. Here, we specify a target resolution of `.02`.

This is how we specify `download_DEM()` to prepare DEM covariates for us:




```r
Covs_ls <- download_DEM(Train_ras = SpatialPolygonsRaw, # the data we want to downscale
                        Target_res = .02, # the resolution we want to downscale to
                        Shape = Shape_shp, # extra spatial preferences
                        Dir = Dir.Covariates # where to store the covariate files
                        )
```

For now, let's simply inspect our list of covariate rasters:

```r
Covs_ls
```

```
## [[1]]
## class      : RasterLayer 
## dimensions : 34, 54, 1836  (nrow, ncol, ncell)
## resolution : 0.1000189, 0.09999998  (x, y)
## extent     : 9.726991, 15.12801, 49.75, 53.15  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : DEM 
## values     : 20.11554, 861.7248  (min, max)
## 
## 
## [[2]]
## class      : RasterLayer 
## dimensions : 204, 324, 66096  (nrow, ncol, ncell)
## resolution : 0.01666667, 0.01666667  (x, y)
## extent     : 9.72486, 15.12486, 49.74986, 53.14986  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : DEM 
## values     : 15.75, 1173  (min, max)
```

You will find that the target resolution covariate data comes at a resolution of 0.017 instead of the 0.02 resolution we specified. This happens because `download_DEM()` calls upon the `raster::aggregate()` function when aggregating the high-resolution covariate data to your desired target resolution and is thus only capable of creating target-resolution covariates in multiples of the base resolution of the GMTED 2010 DEM we are using as our default covariate. This happens only when the `Target_res` argument is specified to be a number.

{{% hint warning %}}
Specifying the `Target_res` argument as a number will lead to best approximation of the desired resolution due to usage of the `raster::aggregate()` within `download_DEM()`. If you need an exact resolution to match pre-existing data, please refer to [this part of the workshop](/courses/krigr/third-party/#matching-third-party-data).
{{% /hint %}}

Notice that despite the covariate rasters (and input rasters, for that matter) containing 1836 and 6.6096\times 10^{4} for training and target resolution respectively, we only obtain data for 938 and 30167 cells respectively due to our specification of `SpatialPolygons`. This will come in handy when doing the statistical interpolation (see [this section](/courses/krigr/kriging/#spatial-limitation) for details).

Before moving on, let's visualise the covariate data:


```r
Plot_Covs(Covs_ls, Shape_shp)
```

<img src="krigr-downscaling_files/figure-html/unnamed-chunk-3-1.png" width="1440" />

Notice just how much more clearly the mountainous areas in our study region show up at our target resolution.

### Considerations for `download_DEM()`

#### `Target_res`

Alternatively to specifying a target resolution, you can specify a different raster which should be matched in all attributes by the raster at target resolution. We get to this again when discussing [third-party](/courses/krigr/third-party/#matching-third-party-data) data usage.  

{{% hint %}}
`Target_res` can be used for a numeric input or to match a pre-existing `raster` object.
{{% /hint %}}

#### `Shape` 

Spatial preferences with `download_DEM()` are specified slightly differently when compared to `download_ERA()`. Whereas `download_ERA()` uses the `Extent` argument, `download_DEM()` uses the `Shape` argument. The reason? `download_DEM()` automatically reads out the extent of the input raster and carries out `extent` limitation according to this. `SpatialPolygons` and `data.frame` inputs are supported. For clarity, we simply recognise them with the `Shape` argument to avoid confusion and unnecessary `extent` inputs.

{{% hint %}}
Spatial preferences are handed to `download_DEM()` using the `Shape` argument.
{{% /hint %}}

#### `Keep_Temporary`

By default, this argument is set to `FALSE` and raw, global DEM data will be deleted when the covariates you queried have been established. Setting this argument to `TRUE` will retain the raw data and make it so you do not have to re-download the DEM data for later use.

{{% hint %}}
Setting `Keep_Temporary = TRUE` will retain global DEM data on your hard drive.
{{% /hint %}}

#### `Source`

This argument specifies where to download the DEM data from. By default, we query the data from the official USGS website. However, this website has given some users issues with connection instabilities. Consequently, the raw DEM data is also available from a dropbox which you can query download from by setting `Source = "Drive"`.

{{% hint %}}
When experiencing connection issues with the USGS servers, we recommend setting `Source = "Drive"` to obtain covariate data.
{{% /hint %}}

## Kriging

{{% hint danger %}}
Kriging can be a very **computationally expensive** exercise.
{{% /hint %}}

The expense of kriging is largely determined by three factors:  
1. Change in spatial resolution.  
2. Number of cells containing data; i.e. [Spatial Limitation](/courses/krigr/kriging/#spatial-limitation).    
3. Localisation of Kriging; i.e. [Localisation of Results](/courses/krigr/kriging/#spatial-limitation).  

{{% hint warning %}}
We explore two of these further down in this workshop material. For more information, please consult [this publication (Figure 4)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf).
{{% /hint %}}

Finally, we are ready to interpolate our input data given our covariates with the `krigR()` function:




```r
SpatialPolygonsKrig <- krigR(Data = SpatialPolygonsRaw, # data we want to krig as a raster object
      Covariates_coarse = Covs_ls[[1]], # training covariate as a raster object
      Covariates_fine = Covs_ls[[2]], # target covariate as a raster object
      Keep_Temporary = FALSE, # we don't want to retain the individually kriged layers on our hard-drive
      Cores = 1, # we want to krig on just one core
      FileName = "SpatialPolygonsKrig", # the file name for our full kriging output
      Dir = Dir.Exports # which directory to save our final input in
      )
```

```
## Commencing Kriging
```

```
## Kriging of remaining 3 data layers should finish around: 2022-06-07 14:00:30
```

```
## 
  |                                                                                      
  |                                                                                |   0%
  |                                                                                      
  |====================                                                            |  25%
  |                                                                                      
  |========================================                                        |  50%
  |                                                                                      
  |============================================================                    |  75%
  |                                                                                      
  |================================================================================| 100%
```

Just like with the `download_ERA()` function, `krigR()` updates you on what it is currently working on. Again, I implemented this to make sure people don't get too anxious staring at an empty console in `R`. If this feature is not appealing to you, you can turn this progress tracking off by setting `verbose = FALSE` in the function call to `krigR()`. 

{{% hint warning %}}
For the rest of this workshop, I suppress messages from `krigR()` via other means so that when you execute, you get progress tracking.
{{% /hint %}}



There we go. As output of the `krigR()` function, we obtain a list of downscaled data as the first element and downscaling standard errors as the second list element. Let's look at that:

```r
SpatialPolygonsKrig[-3] # we will talk later about the third element
```

```
## $Kriging_Output
## class      : RasterBrick 
## dimensions : 191, 309, 59019, 4  (nrow, ncol, ncell, nlayers)
## resolution : 0.01666667, 0.01666667  (x, y)
## extent     : 9.87486, 15.02486, 49.88319, 53.06653  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : var1.pred.1, var1.pred.2, var1.pred.3, var1.pred.4 
## min values :    269.5768,    266.5758,    265.7707,    261.4294 
## max values :    275.0120,    273.3299,    272.1343,    270.0602 
## 
## 
## $Kriging_SE
## class      : RasterBrick 
## dimensions : 191, 309, 59019, 4  (nrow, ncol, ncell, nlayers)
## resolution : 0.01666667, 0.01666667  (x, y)
## extent     : 9.87486, 15.02486, 49.88319, 53.06653  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : var1.stdev.1, var1.stdev.2, var1.stdev.3, var1.stdev.4 
## min values :    0.1251704,    0.1585938,    0.1427118,    0.1373274 
## max values :    0.1435884,    0.1745415,    0.1761995,    0.2816519
```

All the data has been downscaled and we do have uncertainties recorded for all of our outputs. Let's visualise the data:


```r
Plot_Krigs(SpatialPolygonsKrig, 
           Shp = Shape_shp,
           Dates = c("01-1995", "02-1995", "03-1995", "04-1995")
           )
```

<img src="krigr-downscaling_files/figure-html/KrigPlot-1.png" width="1440" />

As you can see, the elevation patterns show up clearly in our kriged air temperature output. Furthermore, you can see that our certainty of Kriging predictions drops on the 04/01/1995 in comparison to the preceding days. However, do keep in mind that a maximum standard error of 0.144, 0.175, 0.176, 0.282 (for each layer of our output respectively) on a total range of data of 5.435, 6.754, 6.364, 8.631 (again, for each layer in the output respectively) is evident of a downscaling result we can be confident in. We also demonstrated reliability of kriging in [this publication (Figure 3)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf).  

Finally, this `SpatialPolygons`-informed downscaling took roughly 4 minutes on my machine (this may vary drastically on other devices).

### Spatial Limitation

{{% hint info %}}
Kriging can be sped up tremendously by limiting downscaling efforts to smaller regions.
{{% /hint %}}

To demonstrate how spatial limitation affects computational time, we downscale all of our remaining [target data](/courses/krigr/download//#climate-data) (i.e., `extent` and `data.frame` time-series specifications).

<details><summary> Click here for kriging calls </summary>

#### `extent` Data







#### Point-Data (`data.frame`)




```r
PtsRaw <- stack(file.path(Dir.Data, "PointsRaw.nc"))
Covs_ls <- download_DEM(Train_ras = PtsRaw,
                        Target_res = .02,
                        Shape = Mountains_df,
                        Buffer = 0.5,
                        ID = "Mountain",
                        Dir = Dir.Covariates,
                        Keep_Temporary = TRUE)
PtsKrig <- krigR(Data = PtsRaw, 
      Covariates_coarse = Covs_ls[[1]], 
      Covariates_fine = Covs_ls[[2]], 
      Keep_Temporary = FALSE, 
      Cores = 1, 
      FileName = "PointsKrig",
      Dir = Dir.Exports
      )
```



</details>

How long did the kriging for each data set take? Let me list these out to highlight just how much of a difference the spatial limitation makes here:  
1. `extent` specification (7344 data cells in training resolution) - roughly 30 minutes  
2. `SpatialPolygons` specification (3752 data cells in training resolution) - roughly 4 minutes  
3. Point (`data.frame`) specification (1908 data cells in training resolution) - roughly 30 seconds

As you can see, there is a huge benefit to reducing the cells containing data to speed up computation. But what is the impact of doing so for our [points of interest](/courses/krigr/prep/#points-of-interest-dataframe)?

<details><summary> Click here for data extraction and plotting </summary>


```r
Extract_df <- data.frame(
  AirTemp = c(
    raster::extract(
      x = SpatialPolygonsKrig[[1]][[1]],
      y = Mountains_df[, c("Lon", "Lat")]), 
    raster::extract(
      x = ExtKrig[[1]][[1]],
      y = Mountains_df[, c("Lon", "Lat")]), 
    raster::extract(
      x = PtsKrig[[1]][[1]],
      y = Mountains_df[, c("Lon", "Lat")])
  ), 
  Uncertainty = c(
    raster::extract(
      x = SpatialPolygonsKrig[[2]][[1]],
      y = Mountains_df[, c("Lon", "Lat")]), 
    raster::extract(
      x = ExtKrig[[2]][[1]],
      y = Mountains_df[, c("Lon", "Lat")]), 
    raster::extract(
      x = PtsKrig[[2]][[1]],
      y = Mountains_df[, c("Lon", "Lat")])
  ), 
  Mountain = rep(Mountains_df$Mountain, 3),
  Spatial = rep(c("Polygons", "Extent", "Points"), 
                each = nrow(Mountains_df))
)
```

```r
ggplot(data = Extract_df, aes(y = Mountain, x = AirTemp, col = Spatial)) +
  geom_point(cex = 5, pch = 18) +
  geom_errorbar(aes(xmin = AirTemp - Uncertainty/2, 
                    xmax = AirTemp + Uncertainty/2)) +
  theme_bw()
```

</details>

<img src="krigr-downscaling_files/figure-html/unnamed-chunk-12-1.png" width="1440" />

As you can see, the differences between the different data sets at our points of interest are noticeable and often times not negligible (as far as statistical interpolation uncertainty, i.e., error bars) are concerned.

{{% hint danger %}}
When statistically downscaling data products it is **vital you inspect the output data** for inconsistencies or other issues. 

**Kriging is not a one-size-fits all solution to spatial resolution needs!**
{{% /hint %}}

### Localisation of Results

{{% hint warning %}}
By default Kriging of the `krigR()` function uses all cells in a spatial product to downscale individual cells of rasters. 
{{% /hint %}}

{{% hint info %}}
The `nmax` argument can circumvent this.
{{% /hint %}}

Let’s build further on our above example by adding the `nmax` argument (passed on to `gstat::krige()`) to our `krigR()` function call. This argument controls how many of the closest cells the Kriging algorithm should consider in the downscaling of individual coarse, training cells.

First, we need to re-establish our covariate data:

```r
Covs_ls <- download_DEM(Train_ras = SpatialPolygonsRaw,
                        Target_res = .02,
                        Shape = Shape_shp,
                        Dir = Dir.Covariates,
                        Keep_Temporary = TRUE)
```

Now we may use locally weighted kriging:

```r
SpatialPolygonsLocalKrig <- krigR(Data = SpatialPolygonsRaw,
      Covariates_coarse = Covs_ls[[1]],
      Covariates_fine = Covs_ls[[2]],
      Keep_Temporary = FALSE,
      Cores = 1, 
      nmax = 10,
      FileName = "SpatialPolygonsLocalKrig",
      Dir = Dir.Exports
      )
Plot_Krigs(SpatialPolygonsLocalKrig, 
           Shp = Shape_shp,
           Dates = c("01-1995", "02-1995", "03-1995", "04-1995")
           )
```

<img src="krigr-downscaling_files/figure-html/KrigShpLocal-1.png" width="1440" />

The air temperature prediction/downscaling results look just like the ones that we obtained above (we will investigate this claim in a second here). However, we seriously improved our localised understanding of Kriging uncertainties (i.e., we see much more localised patterns of Kriging standard error). In the case of our study region, uncertainties seem to be highest for areas where the landscape is dominated by large, abrupt changes in elevation (e.g. around the mountainous areas) and water-dominated areas such as streams and lakes (e.g. the lakes around Leipzig in the North of Saxony).

{{% hint info %}}
Using the `nmax` argument helps to identify highly localised patterns in the Kriging uncertainty as well as predictions!
{{% /hint %}}

Now let's investigate how much of a difference there is between our two predictions of statistically downscaled air temperature when using locally weighted kriging or domain-average kriging as before:


```r
Plot_Raw(SpatialPolygonsLocalKrig[[1]]-SpatialPolygonsKrig[[1]], 
         Shp = Shape_shp,
         Dates = c("01-1995", "02-1995", "03-1995", "04-1995"))
```

<img src="krigr-downscaling_files/figure-html/KrigShpLocalDiff-1.png" width="1440" />

Again, limiting the number of data points that the Kriging algorithm has access to changes the data we obtain. Therefore, let me reiterate:

{{% hint danger %}}
When statistically downscaling data products it is **vital you inspect the output data** for inconsistencies or other issues. 

**Kriging is not a one-size-fits all solution to spatial resolution needs!**
{{% /hint %}}

### Considerations for `krigR()`

`krigR()` is a complex function with many things happening under the hood. To make sure you have the best experience with this function, I have compiled a few bits of *good-to-know* information about the workings of `krigR()`.

#### `Cores`

Kriging is computationally expensive and can be a time-consuming exercise first and foremost. However, the `gstat::krige()` function which `krigR()` makes calls to, and which carries out the kriging itself, does not support multi-core processing. Conclusively, we can hand separate kriging jobs to separate cores in our machines and drastically reduce computation time. We do so via the `Cores` argument.

{{% hint %}}
Using the `Cores` argument, `krigR()` carries out parallel kriging of multi-layer rasters.
{{% /hint %}}

#### `nmax` and `maxdist`

Localised kriging is achieved through either `nmax` or `maxdist`.

{{% hint warning %}}
When using `nmax` or `maxdist`, we recommend you ensure that the distance represented by these arguments approximates the area of typical weather system (around 150km).
{{% /hint %}}

For the purpose of showing clear patterns in the localisation of uncertainty patterns, we did not to so in the above.

#### `Keep_Temporary`

Kriging is time-consuming. Particularly for multi-layer rasters with many layers. To make it so you can interrupt kriging of multi-layer rasters and resume the process at a later time, we have implemented temporary file saving. `krigR()` checks for presence of temporary files and only loads already kriged layers rather than kriging them again. Upon completion and saving of the final output, you may choose to delete the temporary files or keep them.

#### `KrigingEquation`

`krigR()` can accommodate any covariate pair (training and target resolution) you supply. However, when using [third-party covariates](/courses/krigr/third-party/#third-party-data-covariates) in non-linear combinations, you will need to use the `KrigingEquation` argument to do so.

{{% hint %}}
With the `KrigingEquation` argument, you may specify non-linear combinations of covariates for your call to `krigR()`.
{{% /hint %}}

#### Kriging Reliability

Kriging reliability and robustness is largely dependant on the statistical link between your target variable and covariates of your choice. 

{{% hint danger %}}
**Elevation will not be a useful covariate for all climate variables!**
{{% /hint %}}

We demonstrate that Kriging is a reliable interpolation method when carefully choosing covariates in [this publication (Figure 3)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf). One large factor in reliability of kriging is the change in resolution between training and target resolutions - as a rule of thumb, we do not recommend downscaling representing more than roughly one order of magnitude. If you attempt to do so `krigR()` will throw a warning message, but proceed regardless. 

{{% hint warning %}}
Kriging is a very flexible tool for statistical interpolation. Consider your choice of covariates and change in resolutions carefully. **Always inspect your data**.
{{% /hint %}}

#### Call List

So far, we have only ever looked at the first two elements in the list returned by `krigR()`. A quick look at the help file, the code, or this guide reveals that there is a third list element - the *call list*. When coding this feature into `krigR()` I intended for this to be a neat, clean, storage-friendly way of keeping track of how the spatial product was created. It does so without storing additional spatial products. Let's have a look at it: 

<details><summary> Click here for call list query and output </summary>


```r
SpatialPolygonsKrig[[3]]
```

```
## $Data
## $Data$Class
## [1] "RasterStack"
## attr(,"package")
## [1] "raster"
## 
## $Data$Dimensions
## $Data$Dimensions$nrow
## [1] 34
## 
## $Data$Dimensions$ncol
## [1] 54
## 
## $Data$Dimensions$ncell
## [1] 1836
## 
## 
## $Data$Extent
## class      : Extent 
## xmin       : 9.726991 
## xmax       : 15.12801 
## ymin       : 49.75 
## ymax       : 53.15 
## 
## $Data$CRS
## CRS arguments: +proj=longlat +datum=WGS84 +no_defs 
## 
## $Data$layers
## [1] "X1" "X2" "X3" "X4"
## 
## 
## $Covariates_coarse
## $Covariates_coarse$Class
## [1] "RasterLayer"
## attr(,"package")
## [1] "raster"
## 
## $Covariates_coarse$Dimensions
## $Covariates_coarse$Dimensions$nrow
## [1] 34
## 
## $Covariates_coarse$Dimensions$ncol
## [1] 54
## 
## $Covariates_coarse$Dimensions$ncell
## [1] 1836
## 
## 
## $Covariates_coarse$Extent
## class      : Extent 
## xmin       : 9.726991 
## xmax       : 15.12801 
## ymin       : 49.75 
## ymax       : 53.15 
## 
## $Covariates_coarse$CRS
## CRS arguments: +proj=longlat +datum=WGS84 +no_defs 
## 
## $Covariates_coarse$layers
## [1] "DEM"
## 
## 
## $Covariates_fine
## $Covariates_fine$Class
## [1] "RasterLayer"
## attr(,"package")
## [1] "raster"
## 
## $Covariates_fine$Dimensions
## $Covariates_fine$Dimensions$nrow
## [1] 204
## 
## $Covariates_fine$Dimensions$ncol
## [1] 324
## 
## $Covariates_fine$Dimensions$ncell
## [1] 66096
## 
## 
## $Covariates_fine$Extent
## class      : Extent 
## xmin       : 9.72486 
## xmax       : 15.12486 
## ymin       : 49.74986 
## ymax       : 53.14986 
## 
## $Covariates_fine$CRS
## CRS arguments: +proj=longlat +datum=WGS84 +no_defs 
## 
## $Covariates_fine$layers
## [1] "DEM"
## 
## 
## $KrigingEquation
## ERA ~ DEM
## <environment: 0x0000000038f701e8>
## 
## $Cores
## [1] 1
## 
## $FileName
## [1] "SpatialPolygonsKrig"
## 
## $Keep_Temporary
## [1] FALSE
## 
## $nmax
## [1] Inf
## 
## $Data_Retrieval
## [1] "None needed. Data was not queried via krigR function, but supplied by user."
```

</details>

This lengthy list should contain all information you need to trace how you created a certain data set using `krigR()`. If you feel like anything is missing in this list, please contact us.


## Aggregate Uncertainty

{{% hint danger %}}
Every climate data product is subject to an error-rate / range of data uncertainty. Unfortunately, **almost none** of the established climate data products **communicate associated uncertainties**. This leads to a dangerous **overestimation of data credibility**.
{{% /hint %}}

{{% hint info %}}
With the `KrigR` workflow, it is trivial to obtain uncertainty flags for all of your data - no matter the spatial or temporal resolution. 
{{% /hint %}}

To understand the full certainty of our data obtained via the `KrigR` workflow, we should combine [dynamical uncertainty](/courses/krigr/download/#dynamical-data-uncertainty) with the statistical uncertainty we obtained from the `krigR()` function call above.

To do so, we require two data sets:  
- `SpatialPoylgonsKrig` - [created above](/courses/krigr/kriging/#kriging) containing statistical uncertainty in the second list position  
- `SpatialPoylgonsEns` - [created here](/courses/krigr/download/#dynamical-data-uncertainty-1); [download here](/courses/krigr/Data/SpatialPolygonsEns.nc) containing dynamical uncertainty  

First, we load the data and assign them to objects with shorter names:

```r
SpatialPolygonsEns <- stack(file.path(Dir.Data, "SpatialPolygonsEns.nc"))
DynUnc <- SpatialPolygonsEns
KrigUnc <- SpatialPolygonsKrig[[2]]
```

Next, we need to align the rasters of statistical uncertainty (resolution: 0.017) and dynamical uncertainty (resolution: 0.5). As you can see, these are of differing resolutions and so cannot easily be combined using raster math. Instead, we first disaggregate the coarser-resolution raster (`DynUnc`) as disaggregation does not attempt any interpolation thus preserving the data, but representing it with smaller cells. To fix final remaining alignment issues, we allow for some resampling between the two raster:

```r
EnsDisagg <- disaggregate(DynUnc, fact=res(DynUnc)[1]/res(KrigUnc)[1])
DynUnc <- resample(EnsDisagg, KrigUnc)
```

Finally, we combine the two uncertainty data products to form an aggregate uncertainty product:

```r
FullUnc <- DynUnc + KrigUnc
```

Now, we are ready to plot our aggregate uncertainty:

```r
Plot_Raw(FullUnc, 
         Shp = Shape_shp, 
         Dates = c("01-1995", "02-1995", "03-1995", "04-1995"), 
         COL = rev(viridis(100)))
```

<img src="krigr-downscaling_files/figure-html/unnamed-chunk-17-1.png" width="1440" />

As you can see, at short time-scales dynamic uncertainty eclipses statistical uncertainty. However, this phenomenon reverses at longer time-scales as shown in [this publication (Figure 1)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf).

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
