---
title: "Bioclimatic Variables"
author: Erik Kusch
date: '2022-05-26'
slug: bioclim
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: "Using KrigR to obtain bioclimatic variables."
summary: 'Using KrigR to obtain bioclimatic variables.'
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
    weight: 20
weight: 20
---








{{% hint danger %}}
This part of the workshop is dependant on set-up and preparation done previously [here](/courses/krigr/prep/).
{{% /hint %}}

For bioclimatic variable calculation, this workshop makes use of the  `SpatialPolygons` spatial preferences which we set up [here](/courses/krigr/prep/#shape-of-interest-spatialpolygons).

First, we load `KrigR`:


```r
library(KrigR)
```

{{% hint info %}}
To obtain bioclimatic data with `KrigR` we want to use the `BioClim()` function. 
{{% /hint %}}

In the next sections, I will show you how to use it and how the resulting data objects may differ and why.

{{% hint warning %}}
Bioclimatic variables are often treated as very robust metrics - I do not believe so and hope the following will demonstrate the nuance in bioclimatic metrics.
{{% /hint %}}

## Our First Bioclimatic Data Set
Let's start with the most basic of bioclimatic data products. So what are the specifications? Well, we:  

1. Query data for the period between 2010 (`Y_start`) and 2020 (`Y_end`, including 2020).  
2. Obtain data from the era5-land (`DataSet`) catalogue of data.  
3. Approximate water availability through precipitation (`Water_Var`) in keeping with typical practices.  
4. Extreme metrics for temperature minimum and maximum are calculated from daily (`T_res`) aggregates of the underlying hourly temperature data. 

{{% hint warning %}}
You will see function call to `BioClim()` wrapped in if statements which check for whether the output is already present or not. `BioClim` compilation can take significant time and I do this here to avoid recompilation on changes to the text of the blogpost on my end.
{{% /hint %}}

{{% hint %}}
Setting the argument ` Keep_Monthly = TRUE` will prompt the function to retain monthly aggregates of temperature and water availability alongside the final output. When `BioClim()` recognises that any of the underlying data is already present, it will skip the steps necessary to create this data.
{{% /hint %}}

<details>
  <summary>Click here for file if download & processing takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/Present_BC.nc">Present_BC.nc</a> and place it into your data directory.
</details> 


```r
if(!file.exists(file.path(Dir.Data, "Present_BC.nc"))){
  BC2010_ras <- BioClim(
      Water_Var = "total_precipitation",
      Y_start = 2010,
      Y_end = 2020,
      DataSet = "era5-land",
      T_res = "day",
      Extent = Shape_shp,
      Dir = Dir.Data,
      Keep_Monthly = FALSE,
      FileName = "Present_BC",
      API_User = API_User,
      API_Key = API_Key,
      Cores = numberOfCores,
      TimeOut = 60^2*48,
      SingularDL = TRUE,
      verbose = TRUE,
      Keep_Raw = FALSE,
      TryDown = 5
    )
}else{
  BC2010_ras <- stack(file.path(Dir.Data, "Present_BC.nc"))
}
```

Now let's plot our results. Note that temperature is recorded in Kelvin and precipitation in cubic metres (i.e. litres). To do so, we use one of our [user-defined plotting functions](/courses/krigr/prep/#visualising-our-study-setting):


```r
Plot_BC(BC2010_ras, Shp = Shape_shp)
```

<img src="krigr-bioclim_files/figure-html/BC1b-1.png" width="1440" />

There's not much commenting on the output above as the output should look familiar to most macroecologists.

## Time-Frames

{{% hint warning %}}
Time window of baseline climate data (e.g; climatology time frames) ought to be adjusted to the specific needs of each study. This is true also for bioclimatic data. **Pre-made data sets do not deliver on this need!**
{{% /hint %}}

{{% hint info %}}
With `KrigR`, you can build the bioclimatic data sets you need for your study.
{{% /hint %}}

Let's move on to the first important functionality of the `KrigR::BioClim()` function: **selection of time-frames**. With this, you can obtain bioclimatic data for exactly the duration that your study requires. Here, we query data for the period between 1951 and 1960:

<details>
  <summary>Click here for file if download & processing takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/Past_BC.nc">Past_BC.nc</a> and place it into your data directory.
</details> 


```r
if(!file.exists(file.path(Dir.Data, "Past_BC.nc"))){
  BC1951_ras <- BioClim(
      Water_Var = "total_precipitation",
      Y_start = 1951,
      Y_end = 1960,
      DataSet = "era5-land",
      T_res = "day",
      Extent = Shape_shp,
      Dir = Dir.Data,
      Keep_Monthly = FALSE,
      FileName = "Past_BC",
      API_User = API_User,
      API_Key = API_Key,
      Cores = numberOfCores,
      TimeOut = 60^2*48,
      SingularDL = TRUE,
      verbose = TRUE
    )
}else{
  BC1951_ras <- stack(file.path(Dir.Data, "Past_BC.nc"))
}
```

I will forego plotting the data itself and instead plot the difference between our bioclimatic data of the present which we created prior and the newly created bioclimatic product of the past. Let me walk you through them 1 by 1.

{{% hint warning %}}
The below plots show the differences in bioclimatic data products of the 2010-2020 and 1951-1960.
{{% /hint %}}

### Annual Temperature
As you can see below, the time period of 2010 to 2020 was about 1.5-1.9 Kelvin warmer than the period of 1951 to 1960:

```r
Plot_BC(BC2010_ras-BC1951_ras, Shp = Shape_shp, which = 1)
```

<img src="krigr-bioclim_files/figure-html/BC_Early1-1.png" width="1440" />

### Temperatures
Let's bundle the differences for all remaining temperature-related bioclimatic variables:

```r
Plot_BC(BC2010_ras-BC1951_ras, Shp = Shape_shp, which = 2:11)
```

<img src="krigr-bioclim_files/figure-html/BC_Early2-1.png" width="1440" />

Again, you should easily identify just how much the data changes when setting different calculation time frames for bioclimatic variables.

### Water Availability
Now for the water-related bioclimatic variables:

```r
Plot_BC(BC2010_ras-BC1951_ras, Shp = Shape_shp, which = 12:19)
```

<img src="krigr-bioclim_files/figure-html/BC_Early8-1.png" width="1440" />
Clearly, my home area turned much drier with more pronounced seasonality and extreme precipitation events.

I hope that the above has clearly demonstrated on thing:

{{% hint warning %}}
**Appropriate use of bioclimatic variables is largely dependant on data retrieval for relevant time frames.**
{{% /hint %}}

## Water-Availability Variables

{{% hint warning %}}
**Precipitation** might not be the most useful or appropriate water availability metric for your study region or requirements.
{{% /hint %}}

{{% hint info %}}
With `KrigR`, you can decide which water availability variable from the ERA5(-Land) catalogue to use for calculation of bioclimatic data sets.
{{% /hint %}}

Contrary to current practices in macroecology, I have gripes with the use of precipitation data in bioclimatic variable computation. Why is that? I strongly believe that other water availability variables are much better suited for our analyses for two reasons:  

1. Bioclimatic products are usually derived from observation-based climate products (such as WorldClim) which do not do a terrific job at accurately representing precipitation to begin with.  
2. Further downscaling of bioclimatic products containing precipitation information is terribly difficult.  

Both issues are related to one central problem: **Statistical interpolation of precipitation data is difficult and usually done insufficiently**. 

Luckily, with ERA5(-Land), we aren't tied to precipitation and can instead use other water availability metrics such as volumetric soil water content - also known as soil moisture. What's more, this data is available in four distinct depth layers which can be linked to root depth and growth forms. 

Here, I demonstrate the use of the shallowest layer of soil moisture data. As you can see, we are using the same specification as for our basic bioclimatic product with the exception for the `Water_Var` argument:

<details>
  <summary>Click here for file if download & processing takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/Qsoil_BC.nc">Qsoil_BC.nc</a> and place it into your data directory.
</details> 


```r
if(file.exists(file.path(Dir.Data, "Qsoil_BC.nc"))){
  BCq_ras <- stack(file.path(Dir.Data, "Qsoil_BC.nc"))
}else{
  BCq_ras <- BioClim(
      Water_Var = "volumetric_soil_water_layer_1",
      Y_start = 2010,
      Y_end = 2020,
      Extent = Shape_shp,
      Dir = Dir.Data,
      Keep_Monthly = FALSE,
      FileName = "Qsoil_BC",
      API_User = API_User,
      API_Key = API_Key,
      Cores = numberOfCores,
      TimeOut = Inf,
      SingularDL = TRUE
    )
}
```

That's how easy it is to obtain different bioclimatic products with `KrigR`. Let's plot this:

```r
Plot_BC(BCq_ras, Shp = Shape_shp, Water_Var = "Soil Moisture")
```

<img src="krigr-bioclim_files/figure-html/BC_QsoilB-1.png" width="1440" />

Again, I would like to investigate the changes in how we understand the climatic regimes across our study area now that we are using soil moisture for our water availability as compared to when we used precipitation data.

### Temperatures
As is hardly surprising, there are no differences in annual temperature data or any other temperature variable except for BIO8 and BIO9. Since we change by what we quantify dryness and wetness, there is tremendous potential in quantifying temperature of driest and wettest quarter differently:

```r
Plot_BC(BC2010_ras-BCq_ras, Shp = Shape_shp, which = 8:9)
```

<img src="krigr-bioclim_files/figure-html/BC_Q1-1.png" width="1440" />

{{% hint warning %}}
Changing water availability metric in bioclimatic considerations can drastically change even *temperature* metrics.
{{% /hint %}}

{{% hint info %}}
Volumetric soil moisture exhibits more pronounced spatial patterns than precipitation records do thus supplying bioclimatic modelling exercises with more pronounced information.
{{% /hint %}}

### Water Availability
Now for the water-related bioclimatic variables. This is where the rubber meets the road! Aside from the quantitative differences in water availability estimates when using soil moisture over precipitation records, please take note of the much more pronounced spatial patterns (particularly along the river throughout Saxony-Anhalt in the north-western region of our study area) when using soil moisture data. This is much more likely to accurately represent bioclimatic envelopes than the smooth patterns you can see for precipitation records.

```r
Plot_BC(BC2010_ras-BCq_ras, Shp = Shape_shp, which = 12:19)
```

<img src="krigr-bioclim_files/figure-html/BC_Q2-1.png" width="1440" />

I hope that the above has clearly demonstrated on thing:

{{% hint warning %}}
**Choice of water availability variable has strong implications for how we quantify bioclimatic envelopes.**
{{% /hint %}}

## Extreme Value Calculations
Lastly, let us concern ourselves with the retrieval of extreme climate metrics which will affect almost all of our temperature-reliant bioclimatic variables. 

{{% hint warning %}}
Extreme event calculation is highly relevant for our understanding of bioclimatic envelopes and often turns into a blackbox exercise.
{{% /hint %}}

{{% hint info %}}
With `KrigR`, you can decide how to calculate extreme metrics.
{{% /hint %}}

So far, we have calculated monthly minimum and maximum temperatures from daily aggregates. However, with `KrigR::BioClim()` we can also obtain these extremes from hourly records simply by changing `T_res`:

<details>
  <summary>Click here for file if download & processing takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/Hourly_BC.nc">Hourly_BC.nc</a> and place it into your data directory.
</details> 


```r
if(file.exists(file.path(Dir.Data, "Hourly_BC.nc"))){
  BCh_ras <- stack(file.path(Dir.Data, "Hourly_BC.nc"))
}else{
  BCh_ras <- BioClim(
    Water_Var = "volumetric_soil_water_layer_1",
    Y_start = 2010,
    Y_end = 2020,
    T_res = "hour",
    Extent = Shape_shp,
    Dir = Dir.Data,
    Keep_Monthly = FALSE,
    FileName = "Hourly_BC",
    API_User = API_User,
    API_Key = API_Key,
    Cores = numberOfCores,
    TimeOut = Inf,
    SingularDL = TRUE
  )
}
```

Once again, let me plot the outcome of this.

### Annual Temperature
The differences in annual temperature are negligible and only arise through slight deviations in hourly aggregates to monthly aggregates and daily aggregates.

<details><summary> Click here for the plot </summary>

```r
Plot_BC(BCq_ras - BCh_ras, Shp = Shape_shp, Water_Var = "Soil Moisture", which = 1)
```

<img src="krigr-bioclim_files/figure-html/BC_Diff1-1.png" width="1440" />

</details>

### Temperatures
Let's bundle the differences for all remaining temperature-related bioclimatic variables. 

You will immediately see that all metrics reliant of mean values such as BIO4 and BIO8-BIO11 remain almost completely unaltered when using hourly aggregates. The stark differences manifest in all temperature-extreme variables:

```r
Plot_BC(BCq_ras - BCh_ras, Shp = Shape_shp, Water_Var = "Soil Moisture", which = 2:11)
```

<img src="krigr-bioclim_files/figure-html/BC_Diff2-1.png" width="1440" />

{{% hint warning %}}
Extraction of extremes at an hourly resolution amplifies said extremes.
{{% /hint %}}

### Water Availability
Unsurprisingly, there are no changes to our quantification of water availability metrics. You may plot this for yourself if you are interested.

I hope that the above has clearly demonstrated on thing:

{{% hint warning %}}
**Choice of temporal resolution of extreme metrics changes how we quantify bioclimatic envelopes drastically.**
{{% /hint %}}

## Kriging Bioclimatic Products

You might be unhappy with the spatial resolution of the bioclimatic data products generated through `KrigR::BioClim()`. You can remedy this through statistical interpolation which is conveniently built into `KrigR`.

When you do so, you do it at your own risk as I can not guarantee that the results will always be sensible. Investigate them before using them. It would be wiser to downscale the underlying data rather than the finished product, but I don't feel like spending days on end kriging the underlying data so instead I show you how kriging can be performed, but I do so for the entire product.

Since I mentioned earlier that statistical interpolation of precipitation data is fraught with errors, I am demonstrating how to downscale the soil moisture product (`BCq_ras`). We have demonstrated capability of downscaling soil moisture data reliably using Kriging in this [this publication (Figure 3)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf).

### Temperatures  

Here, we follow the same basic kriging steps as demonstrated [previously](/courses/krigr/kriging/) in this workshop material.

First, we create our DEM covariate rasters:

```r
Covs_ls <- download_DEM(Train_ras = BCq_ras,
                        Target_res = .02,
                        Shape = Shape_shp,
                        Dir = Dir.Covariates,
                        Keep_Temporary = TRUE)
```

```
## 
  |                                                                                      
  |                                                                                |   0%
  |                                                                                      
  |                                                                                |   1%
  |                                                                                      
  |=                                                                               |   1%
  |                                                                                      
  |=                                                                               |   2%
  |                                                                                      
  |==                                                                              |   2%
  |                                                                                      
  |==                                                                              |   3%
  |                                                                                      
  |===                                                                             |   3%
  |                                                                                      
  |===                                                                             |   4%
  |                                                                                      
  |====                                                                            |   4%
  |                                                                                      
  |====                                                                            |   5%
  |                                                                                      
  |====                                                                            |   6%
  |                                                                                      
  |=====                                                                           |   6%
  |                                                                                      
  |=====                                                                           |   7%
  |                                                                                      
  |======                                                                          |   7%
  |                                                                                      
  |======                                                                          |   8%
  |                                                                                      
  |=======                                                                         |   8%
  |                                                                                      
  |=======                                                                         |   9%
  |                                                                                      
  |========                                                                        |   9%
  |                                                                                      
  |========                                                                        |  10%
  |                                                                                      
  |========                                                                        |  11%
  |                                                                                      
  |=========                                                                       |  11%
  |                                                                                      
  |=========                                                                       |  12%
  |                                                                                      
  |==========                                                                      |  12%
  |                                                                                      
  |==========                                                                      |  13%
  |                                                                                      
  |===========                                                                     |  13%
  |                                                                                      
  |===========                                                                     |  14%
  |                                                                                      
  |============                                                                    |  14%
  |                                                                                      
  |============                                                                    |  15%
  |                                                                                      
  |============                                                                    |  16%
  |                                                                                      
  |=============                                                                   |  16%
  |                                                                                      
  |=============                                                                   |  17%
  |                                                                                      
  |==============                                                                  |  17%
  |                                                                                      
  |==============                                                                  |  18%
  |                                                                                      
  |===============                                                                 |  18%
  |                                                                                      
  |===============                                                                 |  19%
  |                                                                                      
  |================                                                                |  19%
  |                                                                                      
  |================                                                                |  20%
  |                                                                                      
  |================                                                                |  21%
  |                                                                                      
  |=================                                                               |  21%
  |                                                                                      
  |=================                                                               |  22%
  |                                                                                      
  |==================                                                              |  22%
  |                                                                                      
  |==================                                                              |  23%
  |                                                                                      
  |===================                                                             |  23%
  |                                                                                      
  |===================                                                             |  24%
  |                                                                                      
  |====================                                                            |  24%
  |                                                                                      
  |====================                                                            |  25%
  |                                                                                      
  |====================                                                            |  26%
  |                                                                                      
  |=====================                                                           |  26%
  |                                                                                      
  |=====================                                                           |  27%
  |                                                                                      
  |======================                                                          |  27%
  |                                                                                      
  |======================                                                          |  28%
  |                                                                                      
  |=======================                                                         |  28%
  |                                                                                      
  |=======================                                                         |  29%
  |                                                                                      
  |========================                                                        |  29%
  |                                                                                      
  |========================                                                        |  30%
  |                                                                                      
  |========================                                                        |  31%
  |                                                                                      
  |=========================                                                       |  31%
  |                                                                                      
  |=========================                                                       |  32%
  |                                                                                      
  |==========================                                                      |  32%
  |                                                                                      
  |==========================                                                      |  33%
  |                                                                                      
  |===========================                                                     |  33%
  |                                                                                      
  |===========================                                                     |  34%
  |                                                                                      
  |============================                                                    |  34%
  |                                                                                      
  |============================                                                    |  35%
  |                                                                                      
  |============================                                                    |  36%
  |                                                                                      
  |=============================                                                   |  36%
  |                                                                                      
  |=============================                                                   |  37%
  |                                                                                      
  |==============================                                                  |  37%
  |                                                                                      
  |==============================                                                  |  38%
  |                                                                                      
  |===============================                                                 |  38%
  |                                                                                      
  |===============================                                                 |  39%
  |                                                                                      
  |================================                                                |  39%
  |                                                                                      
  |================================                                                |  40%
  |                                                                                      
  |================================                                                |  41%
  |                                                                                      
  |=================================                                               |  41%
  |                                                                                      
  |=================================                                               |  42%
  |                                                                                      
  |==================================                                              |  42%
  |                                                                                      
  |==================================                                              |  43%
  |                                                                                      
  |===================================                                             |  43%
  |                                                                                      
  |===================================                                             |  44%
  |                                                                                      
  |====================================                                            |  44%
  |                                                                                      
  |====================================                                            |  45%
  |                                                                                      
  |====================================                                            |  46%
  |                                                                                      
  |=====================================                                           |  46%
  |                                                                                      
  |=====================================                                           |  47%
  |                                                                                      
  |======================================                                          |  47%
  |                                                                                      
  |======================================                                          |  48%
  |                                                                                      
  |=======================================                                         |  48%
  |                                                                                      
  |=======================================                                         |  49%
  |                                                                                      
  |========================================                                        |  49%
  |                                                                                      
  |========================================                                        |  50%
  |                                                                                      
  |========================================                                        |  51%
  |                                                                                      
  |=========================================                                       |  51%
  |                                                                                      
  |=========================================                                       |  52%
  |                                                                                      
  |==========================================                                      |  52%
  |                                                                                      
  |==========================================                                      |  53%
  |                                                                                      
  |===========================================                                     |  53%
  |                                                                                      
  |===========================================                                     |  54%
  |                                                                                      
  |============================================                                    |  54%
  |                                                                                      
  |============================================                                    |  55%
  |                                                                                      
  |============================================                                    |  56%
  |                                                                                      
  |=============================================                                   |  56%
  |                                                                                      
  |=============================================                                   |  57%
  |                                                                                      
  |==============================================                                  |  57%
  |                                                                                      
  |==============================================                                  |  58%
  |                                                                                      
  |===============================================                                 |  58%
  |                                                                                      
  |===============================================                                 |  59%
  |                                                                                      
  |================================================                                |  59%
  |                                                                                      
  |================================================                                |  60%
  |                                                                                      
  |================================================                                |  61%
  |                                                                                      
  |=================================================                               |  61%
  |                                                                                      
  |=================================================                               |  62%
  |                                                                                      
  |==================================================                              |  62%
  |                                                                                      
  |==================================================                              |  63%
  |                                                                                      
  |===================================================                             |  63%
  |                                                                                      
  |===================================================                             |  64%
  |                                                                                      
  |====================================================                            |  64%
  |                                                                                      
  |====================================================                            |  65%
  |                                                                                      
  |====================================================                            |  66%
  |                                                                                      
  |=====================================================                           |  66%
  |                                                                                      
  |=====================================================                           |  67%
  |                                                                                      
  |======================================================                          |  67%
  |                                                                                      
  |======================================================                          |  68%
  |                                                                                      
  |=======================================================                         |  68%
  |                                                                                      
  |=======================================================                         |  69%
  |                                                                                      
  |========================================================                        |  69%
  |                                                                                      
  |========================================================                        |  70%
  |                                                                                      
  |========================================================                        |  71%
  |                                                                                      
  |=========================================================                       |  71%
  |                                                                                      
  |=========================================================                       |  72%
  |                                                                                      
  |==========================================================                      |  72%
  |                                                                                      
  |==========================================================                      |  73%
  |                                                                                      
  |===========================================================                     |  73%
  |                                                                                      
  |===========================================================                     |  74%
  |                                                                                      
  |============================================================                    |  74%
  |                                                                                      
  |============================================================                    |  75%
  |                                                                                      
  |============================================================                    |  76%
  |                                                                                      
  |=============================================================                   |  76%
  |                                                                                      
  |=============================================================                   |  77%
  |                                                                                      
  |==============================================================                  |  77%
  |                                                                                      
  |==============================================================                  |  78%
  |                                                                                      
  |===============================================================                 |  78%
  |                                                                                      
  |===============================================================                 |  79%
  |                                                                                      
  |================================================================                |  79%
  |                                                                                      
  |================================================================                |  80%
  |                                                                                      
  |================================================================                |  81%
  |                                                                                      
  |=================================================================               |  81%
  |                                                                                      
  |=================================================================               |  82%
  |                                                                                      
  |==================================================================              |  82%
  |                                                                                      
  |==================================================================              |  83%
  |                                                                                      
  |===================================================================             |  83%
  |                                                                                      
  |===================================================================             |  84%
  |                                                                                      
  |====================================================================            |  84%
  |                                                                                      
  |====================================================================            |  85%
  |                                                                                      
  |====================================================================            |  86%
  |                                                                                      
  |=====================================================================           |  86%
  |                                                                                      
  |=====================================================================           |  87%
  |                                                                                      
  |======================================================================          |  87%
  |                                                                                      
  |======================================================================          |  88%
  |                                                                                      
  |=======================================================================         |  88%
  |                                                                                      
  |=======================================================================         |  89%
  |                                                                                      
  |========================================================================        |  89%
  |                                                                                      
  |========================================================================        |  90%
  |                                                                                      
  |========================================================================        |  91%
  |                                                                                      
  |=========================================================================       |  91%
  |                                                                                      
  |=========================================================================       |  92%
  |                                                                                      
  |==========================================================================      |  92%
  |                                                                                      
  |==========================================================================      |  93%
  |                                                                                      
  |===========================================================================     |  93%
  |                                                                                      
  |===========================================================================     |  94%
  |                                                                                      
  |============================================================================    |  94%
  |                                                                                      
  |============================================================================    |  95%
  |                                                                                      
  |============================================================================    |  96%
  |                                                                                      
  |=============================================================================   |  96%
  |                                                                                      
  |=============================================================================   |  97%
  |                                                                                      
  |==============================================================================  |  97%
  |                                                                                      
  |==============================================================================  |  98%
  |                                                                                      
  |=============================================================================== |  98%
  |                                                                                      
  |=============================================================================== |  99%
  |                                                                                      
  |================================================================================|  99%
  |                                                                                      
  |================================================================================| 100%
```

Next, we carry out the interpolation. A few things of note here: (1) I only hand the first 11 layers to the kriging call because those are the temperature data, (2) I leave out the `Cores` argument, so that `krigR()` determines how many cores your machine has and uses all of them to speed up the computation of the multi-layer raster, and (3) I set `nmax` to 80 to approximate a typical weather system in size:


```r
BC_Temperature_Krig <- krigR(Data = BCq_ras[[1:11]],
      Covariates_coarse = Covs_ls[[1]],
      Covariates_fine = Covs_ls[[2]],
      Keep_Temporary = FALSE,
      nmax = 80,
      FileName = "BC_Temperature_Krig",
      Dir = Dir.Exports
      )
```

```
## Commencing Kriging
```

```
## 
  |                                                                                      
  |                                                                                |   0%
  |                                                                                      
  |=======                                                                         |   9%
  |                                                                                      
  |===============                                                                 |  18%
  |                                                                                      
  |======================                                                          |  27%
  |                                                                                      
  |=============================                                                   |  36%
  |                                                                                      
  |====================================                                            |  45%
  |                                                                                      
  |============================================                                    |  55%
  |                                                                                      
  |===================================================                             |  64%
  |                                                                                      
  |==========================================================                      |  73%
  |                                                                                      
  |=================================================================               |  82%
  |                                                                                      
  |=========================================================================       |  91%
  |                                                                                      
  |================================================================================| 100%
```

Finally, we analyse the outputs of our plotting exercise. I break these up into smaller chunks for easier digestion.

#### BIO1 - Annual Mean Temperature

{{% hint normal %}}
Interpolating this data is just like statistically downscaling any other temperature product and can be done without any problems.
{{% /hint %}}


<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 1), 
           Shp = Shape_shp,
           Dates = "BIO1 - Annual Mean Temperature"
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-4-1.png" width="1440" />
</details> 

#### BIO2 - Mean Diurnal Range

{{% hint warning %}}
This data product is calculated from extreme values and would be interpolated better by first statistically downscaling the underlying data rather than the final bioclimatic variable.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

{{% hint warning %}}
The smooth patterns in this plot clearly highlight the issue with using `krigr()` on the final bioclimatic product.
{{% /hint %}}

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 2), 
           Shp = Shape_shp,
           Dates = "BIO2 - Mean Diurnal Range"
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-5-1.png" width="1440" />
</details>

#### BIO3 - Isothermality

{{% hint warning %}}
This data product is calculated from BIO2 and BIO7 and thus relies on extreme values. Conclusively, it would be interpolated better by first statistically downscaling the underlying data rather than the final bioclimatic variable.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  
{{% hint warning %}}
The smooth patterns in this plot clearly highlight the issue with using `krigr()` on the final bioclimatic product.
{{% /hint %}}

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 3), 
           Shp = Shape_shp,
           Dates = "BIO3 - Isothermality"
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-6-1.png" width="1440" />
</details>

#### BIO4 - Temperature Seasonality

{{% hint warning %}}
This data product is calculated using the standard deviation of mean values throughout our time frame. Conclusively, it would be interpolated better by first statistically downscaling the underlying data rather than the final bioclimatic variable.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  
{{% hint warning %}}
The smooth patterns in this plot clearly highlight the issue with using `krigr()` on the final bioclimatic product.
{{% /hint %}}

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 4), 
           Shp = Shape_shp,
           Dates = "BIO4 - Temperature Seasonality"
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-7-1.png" width="1440" />
</details>

#### BIO5 - Max Temperature of Warmest Month

{{% hint normal %}}
Interpolating this data is just like statistically downscaling any other temperature product and can be done without any problems.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 5), 
           Shp = Shape_shp,
           Dates = c("BIO5 - Max Temperature of Warmest Month")
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-8-1.png" width="1440" />
</details>

#### BIO6 - Min Temperature of Coldest Month

{{% hint normal %}}
Interpolating this data is just like statistically downscaling any other temperature product and can be done without any problems.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 6), 
           Shp = Shape_shp,
           Dates = "BIO6 - Min Temperature of Coldest Month"
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-9-1.png" width="1440" />
</details>

#### BIO7 - Temperature Annual Range (BIO5-BIO6)

{{% hint warning %}}
This data product is calculated from BIO5 and BIO6 and thus relies on extreme values. Conclusively, it would be interpolated better by first statistically downscaling the underlying data rather than the final bioclimatic variable.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>
  
{{% hint warning %}}
The smooth patterns in this plot clearly highlight the issue with using `krigr()` on the final bioclimatic product.
{{% /hint %}}

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 7), 
           Shp = Shape_shp,
           Dates = "BIO7 - Temperature Annual Range (BIO5-BIO6)"
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-10-1.png" width="1440" />
</details>

{{% hint info %}}
Since BIO5 and BIO6 can be interpolated well themselves, one may chose to use the downscaled versions of BIO5 and BIO6 to create a downscaled version of BIO7.
{{% /hint %}}

{{% hint warning %}}
Doing so, however, raises the question of how to integrate the downscaling uncertainty associated with BIO5 and BIO6 into the product for BIO7. I have submitted a research proposal to assess best practice for issues like these.
{{% /hint %}}

<details>
  <summary>Click here for calculation, plotting call, and plot:</summary>
  
Here, I visualise the differences between the interpolated BIO7 and the recalculated BIO7 (from interpolated BIO5 and BIO6):

```r
BIO7 <- lapply(BC_Temperature_Krig[1], "[[", 5)[[1]] - lapply(BC_Temperature_Krig[1], "[[", 6)[[1]]
Plot_Raw(lapply(BC_Temperature_Krig[1], "[[", 7)[[1]]-BIO7, 
         Shp = Shape_shp,
         Dates = "BIO7 - Temperature Annual Range (BIO5-BIO6)"
         )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-11-1.png" width="1440" />

To be fair, these differences are rather small when compared to the data range in BIO7.

</details>


#### BIO8 & BIO9 - Temperatures of Wettest and Driest Quarter

{{% hint danger %}}
**I do not recommend you use these kriging outputs!** They rely on water availability data which is not being interpolated here. Subsequently, the patchiness of the underlying data is lost and with it: information.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 8:9), 
           Shp = Shape_shp,
           Dates = c("BIO8 - Mean Temperature of Wettest Quarter", 
                     "BIO9 - Mean Temperature of Driest Quarter")
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-12-1.png" width="1440" />
</details>

#### BIO10 & BIO11 - Temperatures of Warmest and Coldest Quarter

{{% hint danger %}}
**I do not recommend you use these kriging outputs!** They rely on mean quarterly temperature data which is not being interpolated here. Subsequently, the patchiness of the underlying data is lost and with it: information.
{{% /hint %}}

<details>
  <summary>Click here for plotting call and plot:</summary>

```r
Plot_Krigs(lapply(BC_Temperature_Krig[-3], "[[", 10:11), 
           Shp = Shape_shp,
           Dates = c("BIO10 - Mean Temperature of Warmest Quarter", 
                     "BIO11 - Mean Temperature of Coldest Quarter")
           )
```

<img src="krigr-bioclim_files/figure-html/unnamed-chunk-13-1.png" width="1440" />
</details>


### Water Availability

{{% hint warning %}}
Statistical downscaling of non-temperature data usually requires more than just elevation covariates.
{{% /hint %}}

{{% hint info %}}
With `KrigR`, you can use different sets of covariates. I demonstrate this in the workshop material regarding [third-party covariates](/courses/krigr/third-party/#third-party-data-covariates).
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
