---
title: "Projection Downscaling"
author: Erik Kusch
date: '2022-05-26'
slug: projections
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
    parent: Workshop
    weight: 30
weight: 30
---







{{% hint danger %}}
This part of the workshop is dependant on set-up and preparation done previously [here](/courses/krigr/prep/).
{{% /hint %}}

First, we load `KrigR`:


```r
library(KrigR)
```

I expect that you will often be interested not just in past and current climatic conditions, but also in future projections of climate data at high spatial resolutions.

{{% hint info %}}
The `KrigR` workflow can be used to establish high-resolution, bias-corrected climate projection products.
{{% /hint %}}

This time, we run our exercise for all of Germany because of its size and topographical variety.


```r
Shape_shp <- ne_countries(country = "Germany")
```

## `KrigR` Process for Projections

We published the the `KrigR` workflow for downscaled climate projections in [this publication (Section 3.5)](https://iopscience.iop.org/article/10.1088/1748-9326/ac48b3) and I will walk you through the contents thereof here.

To achieve downscaled projection products we require three data products:  
1. Historical climate data from ERA5(-Land)  
2. Historical climate data from projection source  
3. Future climate data from projection source  


Subsequently, the data products are downscaled to the desired spatial resolution using `krigR()`. Finally, the difference between the downscaled projection-sourced data are added to the historical baseline obtained from (downscaled) ERA5(-Land) data. This achieves bias correction.

### Obtaining ERA5(-Land) Data

Now, let's obtain the historical baseline from ERA5-Land for the same time-period as our CMIP6 historical data.

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/Germany_Hist_ERA.nc">Germany_Hist_ERA.nc</a> and place it into your data directory.
</details> 


```r
if(!file.exists(file.path(Dir.Data, "Germany_Hist_ERA.nc"))){
  Hist_ERA_ras <- download_ERA(Variable = "2m_temperature",
                               DateStart = "1981-01-01",
                               DateStop = "1999-12-31",
                               TResolution = "month",
                               TStep = 1,
                               Extent = Shape_shp,
                               Dir = Dir.Data,
                               FileName = "Germany_Hist_ERA", 
                               API_Key = API_Key,
                               API_User = API_User,
                               SingularDL = TRUE)
  Index <- rep(1:12, length = nlayers(Hist_ERA_ras))
  Hist_ERA_ras <- stackApply(Hist_ERA_ras, indices = Index, fun = mean)
  writeRaster(Hist_ERA_ras, filename = file.path(Dir.Data, "Germany_Hist_ERA"), format = "CDF")
}
Hist_ERA_ras <- mean(stack(file.path(Dir.Data, "Germany_Hist_ERA.nc")))
```

### Obtaining Projection Data

Here, we use CMIP6 projection data manually sourced from the [ECMWF CDS distribution](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip6?tab=overview).

{{% hint %}}
Our [development goals](/courses/outlook/) include development of `download_ERA()` to work with other ECWMF CDS data sets aside from ERA5(-Land). This includes this CMIP6 data set.
{{% /hint %}}

#### Historical Baseline

<details>
  <summary>Click here for file:</summary>
    Download 
<a href="/courses/krigr/Data/historical_tas_1981-2000.nc">historical_tas_1981-2000.nc</a> and place it into your data directory.
</details> 


```r
train_HIST <- mean(stack(file.path(Dir.Data, "historical_tas_1981-2000.nc")))
train_HIST <- crop(train_HIST,extent(Hist_ERA_ras))
train_mask <- KrigR::mask_Shape(train_HIST, Shape_shp)
train_HIST <- mask(train_HIST, train_mask)
```

#### Future Projection

<details>
  <summary>Click here for file:</summary>
    Download 
<a href="/courses/krigr/Data/ssp585_tas_2041-2060.nc">ssp585_tas_2041-2060.nc</a> and place it into your data directory.
</details> 


```r
train_SSP <- mean(stack(file.path(Dir.Data, "ssp585_tas_2041-2060.nc")))
train_SSP <- crop(train_SSP,extent(Hist_ERA_ras))
train_mask <- KrigR::mask_Shape(train_SSP, Shape_shp)
train_SSP <- mask(train_SSP, train_mask)
```

#### Visualisation of CMIP6 Data

```r
Plot_Raw(stack(train_HIST, train_SSP), 
         Shp = Shape_shp,
         Dates = c("Historic CMIP6", "Future CMIP6"))
```

<img src="krigr-projections_files/figure-html/unnamed-chunk-5-1.png" width="1440" />

Already, we can see that quite a bit of warming is projected to happen all across Germany. However, we want to know about this at higher spatial resolutions. That's where `KrigR` comes in.

### Establishing Kriged Products

For the first time in this workshop material, we will push our spatial resolution to the finest scale supported by our default GMTED 2010 DEM covariate data: 0.008333 / ~1km.

{{% hint warning %}}
These operations take quite some time - grab a tea or coffee, go for a walk, or stretch a bit.
{{% /hint %}}

The downscaling calls should be familiar by now so I will forego explaining them. In case, the following code snippets do not make sense to you, please consult the portion of this workshop concerned with [statistical downscaling](/courses/krigr/kriging/).

#### Historical CMIP6

```r
## Covariate Data
GMTED_DE <- download_DEM(
  Train_ras = train_HIST,
  Target_res = 0.008334,
  Shape = Shape_shp,
  Keep_Temporary = TRUE,
  Dir = Dir.Covariates
)
## Kriging
Output_HIST <- krigR(
  Data = train_HIST,
  Covariates_coarse = GMTED_DE[[1]], 
  Covariates_fine = GMTED_DE[[2]],  
  Keep_Temporary = FALSE,
  Cores = 1,
  Dir = Dir.Exports,  
  FileName = "DE_CMIP-HIST", 
  nmax = 40
)
```




```r
Plot_Krigs(Output_HIST,
           Shp = Shape_shp,
           Dates = "CMIP6 Historical", columns = 2)
```

<img src="krigr-projections_files/figure-html/unnamed-chunk-8-1.png" width="1440" />

#### Future CMIP6

```r
## Covariate Data
GMTED_DE <- download_DEM(
  Train_ras = train_SSP,
  Target_res = 0.008334,
  Shape = Shape_shp,
  Keep_Temporary = TRUE,
  Dir = Dir.Covariates
)
## Kriging
Output_SSP <- krigR(
  Data = train_SSP,
  Covariates_coarse = GMTED_DE[[1]], 
  Covariates_fine = GMTED_DE[[2]],   
  Keep_Temporary = FALSE,
  Cores = 1,
  Dir = Dir.Exports,  
  FileName = "DE_SSP585_2041-2060", 
  nmax = 40
)
```




```r
Plot_Krigs(Output_SSP,
           Shp = Shape_shp,
           Dates = "CMIP6 Future", columns = 2)
```

<img src="krigr-projections_files/figure-html/unnamed-chunk-11-1.png" width="1440" />

#### Historical ERA5-Land

```r
## Covariate Data
GMTED_DE <- download_DEM(
  Train_ras = Hist_ERA_ras,
  Target_res = 0.008334,
  Shape = Shape_shp,
  Keep_Temporary = TRUE,
  Dir = Dir.Covariates
)
## Kriging
Output_ERA <- krigR(
  Data = Hist_ERA_ras,
  Covariates_coarse = GMTED_DE[[1]], 
  Covariates_fine = GMTED_DE[[2]],   
  Keep_Temporary = FALSE,
  Cores = 1,
  Dir = Dir.Exports,  
  FileName = "DE_hist", 
  nmax = 40
)
```




```r
Plot_Krigs(Output_ERA,
           Shp = Shape_shp,
           Dates = "ERA5-Land Historical", columns = 2)
```

<img src="krigr-projections_files/figure-html/unnamed-chunk-14-1.png" width="1440" />

### Putting It All Together

To establish a final product of high-resolution climate projection data, we simply add the difference between the kriged CMIP6 products to the kriged ERA5-Land product:


```r
## Creating Difference and Projection raster
Difference_ras <- Output_SSP[[1]] - Output_HIST[[1]]
Projection_ras <- Output_ERA[[1]] + Difference_ras
## Adding min and max values to ocean cells to ensure same colour scale
Output_ERA[[1]][10] <- maxValue(Projection_ras)
Output_ERA[[1]][12] <- minValue(Projection_ras)
Projection_ras[10] <- maxValue(Output_ERA[[1]])
Projection_ras[12] <- minValue(Output_ERA[[1]])
## Individual plots
A_gg <- Plot_Raw(Output_ERA[[1]], Shp = Shape_shp, 
                 Dates = "Historical ERA5-Land (1981-2000)")
B_gg <- Plot_Raw(Difference_ras[[1]], Shp = Shape_shp, 
                 Dates = "Anomalies of SSP585 - Historical CMIP-6",
                 COL = rev(viridis(100)))
C_gg <- Plot_Raw(Projection_ras[[1]], Shp = Shape_shp, 
                 Dates = "Future Projection (ERA5-Land + Anomalies)")
## Fuse the plots into one big plot
ggPlot <- plot_grid(plotlist = list(A_gg, B_gg, C_gg), 
                    ncol = 3, labels = "AUTO") 
ggPlot
```

<img src="krigr-projections_files/figure-html/unnamed-chunk-15-1.png" width="1440" />

And there we have it - a downscaled, bias-corrected projection of air temperature across Germany.

## Considerations for Projection Kriging

Projection kriging is easily the most flexible exercise you can undertake with `KrigR`. 

{{% hint warning %}}
I have submitted a research proposal to establish best practice for projection kriging.
{{% /hint %}}

So far, two particular aspects stand out to me and should be considered by you when using `KrigR` to obtain high-resolution projection data.

{{% hint danger %}}
**Do not statistically downscale precipitation data and do not use products that do so!**
{{% /hint %}}

### Reliability

Just like with all statistical downscaling exercises, it is pivotal to consider variables interpolated and consistency of statistical relationships with covariates across spatial resolutions.

{{% hint warning %}}
Kriging is a very flexible tool for statistical interpolation. Consider your choice of covariates and change in resolutions carefully. **Always inspect your data**.
{{% /hint %}}

### Uncertainty

Integration of multiple kriged data sets with statistical uncertainty and each of which comes with its own underlying dynamical data uncertainty raises the question of how to combine uncertainties for meaningful uncertainty flags.

{{% hint warning %}}
I have submitted a research proposal to assess best practice for uncertainty integration across data products.
{{% /hint %}}

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
