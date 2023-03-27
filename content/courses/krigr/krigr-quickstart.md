---
title: "Quick Guide"
author: Erik Kusch
date: '2022-05-26'
slug: quickstart
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: ""
summary: ''
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
    parent: Quick Start
    weight: 3
weight: 3
---



<!-- # ```{r, sourcing-previous, echo = FALSE} -->
<!-- # source_rmd <- function(file, local = FALSE, ...){ -->
<!-- #   options(knitr.duplicate.label = 'allow') -->
<!-- #  -->
<!-- #   tempR <- tempfile(tmpdir = ".", fileext = ".R") -->
<!-- #   on.exit(unlink(tempR)) -->
<!-- #   knitr::purl(file, output=tempR, quiet = TRUE) -->
<!-- #  -->
<!-- #   envir <- globalenv() -->
<!-- #   source(tempR, local = envir, ...) -->
<!-- # } -->
<!-- # source_rmd("krigr-locations.Rmd") -->
<!-- # ``` -->


{{% hint danger %}}
This part of the workshop is meant to give a **very brief** introduction to `KrigR` and I highly recommend you peruse the rest of the content, too.
{{% /hint %}}


<!-- {{% hint danger %}} -->
<!-- This part of the workshop is dependant on set-up and preparation done previously [here](/courses/krigr/prep/). -->
<!-- {{% /hint %}} -->

## Pre-`KrigR` Housekeeping
Before we can commence the quick start guide, I want to set up a directory structure and prepare some plotting functions to make the rest of the guide run more smoothly.

### Setting up Directories
For this guide to run in a structured way, we create a folder/directory structure. We create the following directories:  

- A **Data** directory for all of our data downloads  
- A **Covariate** directory for all of our covariate data  
- An **Exports** directory for all of our Kriging outputs  


```r
Dir.Base <- getwd() # identifying the current directory
Dir.Data <- file.path(Dir.Base, "Data") # folder path for data
Dir.Covariates <- file.path(Dir.Base, "Covariates") # folder path for covariates
Dir.Exports <- file.path(Dir.Base, "Exports") # folder path for exports
## create directories, if they don't exist yet
Dirs <- sapply(
  c(Dir.Data, Dir.Covariates, Dir.Exports),
  function(x) if (!dir.exists(x)) dir.create(x)
)
```

### Visualiation Functions 

In order to easily visualise our Kriging procedure including (1) inputs, (2) covariates, and (3) outputs without repeating too much of the same code, I have prepared some plotting functions which you can download as [FUN_Plotting.R](/courses/krigr/FUN_Plotting.R).

With the `FUN_Plotting.R` file placed in the project directory of your workshop material (i.e., the directory returned by `Dir.Base`), running the following will register the three plotting functions in your `R` environment.


```r
source("FUN_Plotting.R")
```

The plotting functions you have just loaded are called:  

- `Plot_Raw()` - we will use this function to visualise data downloaded with `KrigR`  
- `Plot_Covs()` - this function will help us visualise the covariates we use for statistical interpolation  
- `Plot_Krigs()` - kriged products and their associated uncertainty will be visualised using this function  

Don’t worry about understanding how these functions work off the bat here. Kriging and the package `KrigR` are what we want to demonstrate here - not visualisation strategies. 

## Using `KrigR`

Before we start these exercises, we need to load `KrigR`:


```r
library(KrigR)
```

`KrigR` can be used in one of two ways. 

{{% hint %}}
I strongly recommend you use **The Three Steps** as **The Pipeline** is only applicable for a fringe of use-cases.
{{% /hint %}}


### The Three Steps
Using `KrigR` in this way, you use the three core functions `download_ERA()`, `download_DEM()`, and `krigR()`. 

{{% hint info %}}
Running these functions individually gives you the most control and oversight of the `KrigR` workflow.
{{% /hint %}}

The most simple way in which you can run the functions of the `KrigR` package is by specifying a rectangular bounding box (i.e., an `extent`) to specify your study region(s). 

Here, we will run a small downscaling exercise for the region I was born and grew up in. For a more detailed discussion of this region, please refer to this [section](/courses/krigr/prep/#our-workshop-target-region): 

Here's the full area for which we will be obtaining and downscaling data for:

```r
Extent_ext <- extent(c(9.87, 15.03, 49.89, 53.06))
Extent_ext
```

```
## class      : Extent 
## xmin       : 9.87 
## xmax       : 15.03 
## ymin       : 49.89 
## ymax       : 53.06
```

#### Climate Data

For this part of the tutorial, we download air temperature for a three-day interval around my birthday (03-01-1995) using the extent highlighted above.

{{% hint %}}
Notice that the downloading of ERA-family reanalysis data may take a short while to start as the download request gets queued with the CDS of the ECMWF before it is executed.
{{% /hint %}}

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/QS_Raw.nc">QS_Raw.nc</a> and place it into your data directory.
</details> 


```r
QS_Raw <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-02",
  DateStop = "1995-01-04",
  TResolution = "day",
  TStep = 1,
  Extent = Extent_ext,
  Dir = Dir.Data,
  FileName = "QS_Raw",
  API_User = API_User,
  API_Key = API_Key
)
Plot_Raw(QS_Raw, Dates = c("02-01-1995", "03-01-1995", "04-01-1995"))
```

<img src="krigr-quickstart_files/figure-html/ClimExt-1.png" width="1440" />

<!-- As you can see the `download_ERA()` function updates you on what it is currently working on at each major step. I implemented this to make sure people don't get too anxious staring at an empty console in `R`. If this feature is not appealing to you, you can turn this progress tracking off by setting `verbose = FALSE` in the function call to `download_ERA()`. -->

Now, let's look at the raster that was produced:

```r
QS_Raw
```

```
## class      : RasterStack 
## dimensions : 34, 54, 1836, 3  (nrow, ncol, ncell, nlayers)
## resolution : 0.09999999, 0.09999998  (x, y)
## extent     : 9.72, 15.12, 49.74, 53.14  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## names      :       X1,       X2,       X3 
## min values : 268.0212, 266.9561, 262.7402 
## max values : 273.2443, 272.5641, 270.0796
```

As you can see, we obtained a RasterStack object with 3 layers of data (one for each day we are interested in). Notice that extent of our downloaded data set does not fit the extent we set earlier manually. This is a precaution we have taken within `KrigR` to make sure that all data cells you are interested in are covered.

{{% hint info %}}
`KrigR` widens the spatial extent that is specified to ensure full coverage of the respective ERA5(-Land) raster cells. Global downloads are not affected by this and work just as you'd expect.
{{% /hint %}}

{{% hint %}}
More detailed instructions on how to make the most effective use of the `download_ERA()` function and ensure you receive the data you require can be found [here](/courses/krigr/download/).
{{% /hint %}}

Keep in mind that every function within the `KrigR` package produces NetCDF (.nc) files in the specified directory (`Dir` argument in the function call) to allow for further manipulation outside of `R` if necessary (for example, using Panoply).

#### Covariates  
Next, we use the `download_DEM()` function which comes with `KrigR` to obtain elevation data as our covariate of choice. This produces two rasters:  

1. A raster of **training** resolution which matches the input data in all attributes except for the data in each cell.  
2. A raster of **target** resolution which matches the input data as closely as possible in all attributes except for the resolution (which is specified by the user).  

Both of these products are bundled into a `list` where the first element corresponds to the *training* resolution and the second element contains the *target* resolution covariate data. Here, we specify a target resolution of `.02`.


```r
Covs_ls <- download_DEM(
  Train_ras = QS_Raw,
  Target_res = .02,
  Dir = Dir.Covariates,
  Keep_Temporary = TRUE
)
Plot_Covs(Covs_ls)
```

<img src="krigr-quickstart_files/figure-html/CovExt-1.png" width="1440" />

{{% hint %}}
Alternatively to specifying a target resolution, you can specify a different raster which should be matched in all attributes by the raster at target resolution. This is explained more in-depth in [this part of the workshop](/courses/krigr/third-party).  
{{% /hint %}}

For now, let's simply inspect our list of covariate rasters:

```r
Covs_ls
```

```
## [[1]]
## class      : RasterLayer 
## dimensions : 34, 54, 1836  (nrow, ncol, ncell)
## resolution : 0.09999999, 0.09999998  (x, y)
## extent     : 9.72, 15.12, 49.74, 53.14  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : DEM 
## values     : 3.156112, 847.6525  (min, max)
## 
## 
## [[2]]
## class      : RasterLayer 
## dimensions : 204, 324, 66096  (nrow, ncol, ncell)
## resolution : 0.01666667, 0.01666667  (x, y)
## extent     : 9.716527, 15.11653, 49.74153, 53.14153  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : DEM 
## values     : -1.5, 1111.75  (min, max)
```

<!-- This set of covariates has 1836 and 66096 cells containing values at training and target resolution, respectively. -->

#### Kriging  
Now let's statistically downscale these data:




```r
QS_Krig <- krigR(
  Data = QS_Raw, # data we want to krig as a raster object
  Covariates_coarse = Covs_ls[[1]], # training covariate as a raster object
  Covariates_fine = Covs_ls[[2]], # target covariate as a raster object
  Keep_Temporary = FALSE, # we don't want to retain the individually kriged layers on our hard-drive
  nmax = 40, # degree of localisation
  Cores = 3, # we want to krig using three cores to speed this process up
  FileName = "QS_Krig.nc", # the file name for our full kriging output
  Dir = Dir.Exports # which directory to save our final input in
)
Plot_Krigs(QS_Krig, Dates = c("02-01-1995", "03-01-1995", "04-01-1995"))
```

<img src="krigr-quickstart_files/figure-html/KrigExt-1.png" width="1440" />



This operation took 1 seconds on my machine (this may vary drastically on other devices).

There we go. All the data has been downscaled and we do have uncertainties recorded for all of our outputs. As you can see, the elevation patterns show up clearly in our kriged air temperature output. Furthermore, you can see that our certainty of Kriging predictions drops on the 04/01/1995 in comparison to the two preceding days. However, do keep in mind that a maximum standard error of 0.22, 0.251, 0.445 (for each layer of our output respectively) on a total range of data of 6.281, 6.511, 8.388 (again, for each layer in the output respectively) is evident of a downscaling result we can be confident in.  

Now, what does the output actually look like?

```r
QS_Krig[-3] # we will talk later about why we leave out the third list element produced by krigR here
```

```
## $Kriging_Output
## class      : RasterBrick 
## dimensions : 204, 324, 66096, 3  (nrow, ncol, ncell, nlayers)
## resolution : 0.01666667, 0.01666667  (x, y)
## extent     : 9.716527, 15.11653, 49.74153, 53.14153  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : var1.pred.1, var1.pred.2, var1.pred.3 
## min values :    266.9992,    266.0957,    261.7828 
## max values :    273.2800,    272.6068,    270.1708 
## 
## 
## $Kriging_SE
## class      : RasterBrick 
## dimensions : 204, 324, 66096, 3  (nrow, ncol, ncell, nlayers)
## resolution : 0.01666667, 0.01666667  (x, y)
## extent     : 9.716527, 15.11653, 49.74153, 53.14153  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : memory
## names      : var1.stdev.1, var1.stdev.2, var1.stdev.3 
## min values :   0.11882790,   0.05715606,   0.08283082 
## max values :    0.2200428,    0.2507924,    0.4449649
```

As output of the `krigR()` function, we obtain a list of downscaled data as the first element and downscaling standard errors as the second list element.

{{% hint %}}
More detailed instructions on how to make the most effective use of the `krigR()` function can be found [here](/courses/krigr/kriging/).
{{% /hint %}}

### The Pipeline
Now that we've seen how you can execute the `KrigR` workflow using three separate functions, it is time that we show you the most simplified function call to obtain some downscaled products: the **pipeline**.

{{% hint danger %}}
Using `KrigR` through the pipeline approach limits you to the default covariate data and takes away control from you. Use this only if you know exactly what you are doing.
{{% /hint %}}

We have coded the `krigR()` function in such a way that it can either be addressed at already present spatial products within your `R` environment, or handle all the downloading and resampling of input data and covariates for you from scratch. To run the exact same Kriging approach as within our extent-example, we can specify the `krigR()` function as such:


```r
Pipe_Krig <- krigR(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-02",
  DateStop = "1995-01-04",
  TResolution = "day",
  TStep = 1,
  Extent = Extent_ext,
  API_User = API_User,
  API_Key = API_Key,
  Target_res = .02,
  Source = "Drive",
  nmax = 40,
  Cores = 3,
  FileName = "QS_Pipe.nc",
  Dir = Dir.Exports
)
Plot_Krigs(Pipe_Krig, Dates = c("02-01-1995", "03-01-1995", "04-01-1995"))
```

<img src="krigr-quickstart_files/figure-html/PipeExec-1.png" width="1440" />

Let's just check how this compares to non-pipeline product:

```r
all.equal(QS_Krig[[1]], Pipe_Krig[[1]])
```

```
## [1] TRUE
```

Surprise! There is no difference.

{{% hint warning %}}
This concludes the quick start tutorial for `KrigR`. For more effective use of the `KrigR` toolbox, I suggest you peruse the rest of the workshop material or use the search function if you have specific queries.
{{% /hint %}}

For a use-case of the pipeline see [this part](/courses/krigr/third-party/#krigr-workflow) of our workshop.

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
##  [1] KrigR_0.1.2       httr_1.4.2        stars_0.5-3       abind_1.4-5      
##  [5] fasterize_1.0.3   sf_1.0-0          lubridate_1.7.10  automap_1.0-14   
##  [9] doSNOW_1.0.19     snow_0.4-3        doParallel_1.0.16 iterators_1.0.13 
## [13] foreach_1.5.1     rgdal_1.5-23      raster_3.4-13     sp_1.4-5         
## [17] stringr_1.4.0     keyring_1.2.0     ecmwfr_1.3.0      ncdf4_1.17       
## [21] cowplot_1.1.1     viridis_0.6.0     viridisLite_0.4.0 ggplot2_3.3.6    
## [25] tidyr_1.1.3      
## 
## loaded via a namespace (and not attached):
##  [1] xts_0.12.1         R.cache_0.14.0     tools_4.0.5        backports_1.2.1   
##  [5] bslib_0.3.1        utf8_1.2.1         R6_2.5.0           KernSmooth_2.23-18
##  [9] DBI_1.1.1          colorspace_2.0-0   withr_2.4.2        tidyselect_1.1.0  
## [13] gridExtra_2.3      curl_4.3.2         compiler_4.0.5     gstat_2.0-7       
## [17] labeling_0.4.2     bookdown_0.22      sass_0.4.1         scales_1.1.1      
## [21] classInt_0.4-3     proxy_0.4-25       digest_0.6.27      rmarkdown_2.14    
## [25] R.utils_2.10.1     pkgconfig_2.0.3    htmltools_0.5.2    styler_1.4.1      
## [29] highr_0.9          fastmap_1.1.0      rlang_0.4.11       FNN_1.1.3         
## [33] jquerylib_0.1.4    generics_0.1.0     farver_2.1.0       zoo_1.8-9         
## [37] jsonlite_1.7.2     dplyr_1.0.5        R.oo_1.24.0        magrittr_2.0.1    
## [41] Rcpp_1.0.7         munsell_0.5.0      fansi_0.4.2        lifecycle_1.0.0   
## [45] R.methodsS3_1.8.1  stringi_1.5.3      yaml_2.2.1         plyr_1.8.6        
## [49] grid_4.0.5         crayon_1.4.1       lattice_0.20-41    knitr_1.33        
## [53] pillar_1.6.0       spacetime_1.2-4    codetools_0.2-18   glue_1.4.2        
## [57] evaluate_0.14      blogdown_1.3       vctrs_0.3.7        gtable_0.3.0      
## [61] purrr_0.3.4        rematch2_2.1.2     reshape_0.8.8      assertthat_0.2.1  
## [65] cachem_1.0.4       xfun_0.31          lwgeom_0.2-6       e1071_1.7-6       
## [69] class_7.3-18       tibble_3.1.1       intervals_0.15.2   memoise_2.0.0     
## [73] units_0.7-2        ellipsis_0.3.2
```
