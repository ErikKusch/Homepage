---
title: "Downloading & Processing"
author: Erik Kusch
date: '2022-05-26'
slug: download
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: "Accessing State-of-the-Art Climate Data with `KrigR`"
summary: 'Download specifications and considerations with `KrigR`.'
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
    weight: 10
weight: 10
---








{{% hint danger %}}
This part of the workshop is dependant on set-up and preparation done previously [here](/courses/krigr/prep/).
{{% /hint %}}

First, we load `KrigR`:


```r
library(KrigR)
```

{{% hint info %}}
Downloads and data processing with `KrigR` are staged and executed with the `download_ERA()`function.
{{% /hint %}}

`download_ERA()` is a very versatile function and I will show you it's capabilities throughout this material.

{{% hint warning %}}
We will start with a **simple calls**  to `KrigR` and subsequently make them **more sophisticated** during this workshop.
{{% /hint %}}

## Downloading Climate Data

Let's start with a very basic call to `download_ERA()`. 

For this part of the workshop, we download air temperature for my birth month (January 1995) using the extent of our [target region](/courses/prep/#our-workshop-target-region). 

See the code chunk below for explanations on each function argument. If you want to know about the defaults for any argument in `download_ERA()` simply run `?download_ERA()`. Doing so should make it obvious why we specify the function as we do below.

{{% hint %}}
Notice that the downloading of ERA-family reanalysis data may take a short while to start as the download request gets queued with the CDS of the ECMWF before it is executed.
{{% /hint %}}

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/FirstDL.nc">FirstDL.nc</a> and place it into your data directory.
</details> 


```r
FirstDL <- download_ERA(
    Variable = "2m_temperature", # the variable we want to obtain data for
    DataSet = "era5-land", # the data set we want to obtain data from
    DateStart = "1995-01-01", # the starting date of our time-window
    DateStop = "1995-01-31", # the final date of our time-window
    Extent = Extent_ext, # the spatial preference we are after
    Dir = Dir.Data, # where to store the downloaded data
    FileName = "FirstDL", # a name for our downloaded file
    API_User = API_User, # your API User Number
    API_Key = API_Key # your API User Key
  )
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
## 0001_FirstDL.nc download queried
```

```
## Requesting data to the cds service with username 39340
```

```
## - staging data transfer at url endpoint or request id:
```

```
##   d19d450c-2a1a-4974-9da4-c022a4db654f
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
##   |                                                                                        |                                                                                |   0%  |                                                                                        |================================================================================| 100%
```

```
## - moved temporary file to -> C:/Users/erike/Documents/Website/content/courses/krigr/Data/0001_FirstDL.nc
## - request purged from queue!
## Checking for known data issues.
## Loading downloaded data for masking and aggregation.
## Aggregating to temporal resolution of choice
```

As you can see the `download_ERA()` function updates you on what it is currently working on at each major step. I implemented this to make sure people don't get too anxious staring at an empty console in `R`. If this feature is not appealing to you, you can turn this progress tracking off by setting `verbose = FALSE` in the function call to `download_ERA()`. 

{{% hint warning %}}
For the rest of this workshop, I suppress messages from `download_ERA()` via other means so that when you execute, you get progress tracking.
{{% /hint %}}

I will make exceptions to this rule when there are special things I want to demonstrate.

Now, let's look at the raster that was produced:

```r
FirstDL
```

```
## class      : RasterStack 
## dimensions : 34, 54, 1836, 1  (nrow, ncol, ncell, nlayers)
## resolution : 0.09999999, 0.09999998  (x, y)
## extent     : 9.72, 15.12, 49.74, 53.14  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## names      :       X1 
## min values : 268.8695 
## max values : 274.6665
```

One layer (i.e., one month) worth of data. That seems to have worked. If you are keen-eyed, you will notice that the extent on this object does not align with the extent we supplied with `Extent_ext`. The reason? To download the data, we need to snap to the nearest full cell in the data set from which we query our downloads. `KrigR` always ends up widening the extent to ensure all the data you desire will be downloaded.

Finally, let's visualise our downloaded data with one of our [user-defined plotting functions](/courses/krigr/prep/#visualising-our-study-setting):


```r
Plot_Raw(FirstDL, Dates = "01-1995")
```

<img src="krigr-downloads_files/figure-html/FirstDLVis-1.png" width="1440" />

That is all there is to downloading ERA5(-Land) data with `KrigR`. You can already see how, even at the relatively course resolution of ERA5-Land, the mountain ridges along the German-Czech border are showing up. This will become a lot clearer of a pattern once we [downscale our data](/courses/krigr/kriging/).

{{% hint info %}}
`download_ERA()` provides you with a lot more functionality than *just* access to the ERA5(-Land) data sets. 
{{% /hint %}}

{{% hint %}}
With `download_ERA()`, you can also carry out processing of the downloaded data. Data processing with `download_ERA()` includes:  
1. *Spatial Limitation* to cut down on the data that is stored on your end.  
2. *Temporal Aggregation* to establish data at the temporal resolution you desire.  
{{% /hint %}}

## Spatial Limitation
Let's start with spatial limitation. As discussed [previously](/courses/krigr/prep/#spatial-preferences-in-krigr), `download_ERA()` can handle a variety of inputs describing spatial preferences.

{{% hint %}}
`KrigR` is capable of learning about your spatial preferences in three ways:  

1. As an `extent` input (a rectangular box).  
2. As a `SpatialPolygons` input (a polygon or set of polygons).  
3. As a set of locations stored in a `data.frame`.  

These spatial preferences are registered in `KrigR` functions using the `Extent` argument.
{{% /hint %}}

You might now ask yourself: How does `KrigR` achieve spatial limitation of the data? Couldn't we just simply download only the data we are interested in? 

The ECMWF CDS gives us tremendous capability of retrieving only the data we want. However, the CDS only recognises rectangular boxes (i.e., `extent`s) for spatial limitation. Consequently, we always have to download data corresponding to a rectangular box in space. When informing `KrigR` of your spatial preferences using a `data.frame` or `SpatialPolygons`, `download_ERA()` automatically (1) identifies the smallest `extent` required by your input, (2) downloads data corresponding to this `extent`, and (3) masks our any data not queried by you.

{{% hint info %}}
Using `KrigR`'s spatial limitation features ensures faster computation and smaller file sizes (depending on file type).
{{% /hint %}}

In the following, I demonstrate how to use the `Extent` argument in `download_ERA()`.

### Shape (`SpatialPolygons`)

Let me show you how `SpatialPolygons` show up in our data with `download_ERA()`. Remember that these `SpatialPolygons` originate [here](/courses/krigr/prep/#shape-of-interest-spatialpolygons). First, we query our download as follows:

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/SpatialPolygons_DL.nc">SpatialPolygons_DL.nc</a> and place it into your data directory.
</details> 


```r
SpatialPolygons_DL <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-01",
  DateStop = "1995-01-31",
  Extent = Shape_shp, # we simply switch the Extent Argument
  Dir = Dir.Data,
  FileName = "SpatialPolygons_DL",
  API_User = API_User,
  API_Key = API_Key
)  
Plot_Raw(SpatialPolygons_DL, Dates = "01-1995", Shp = Shape_shp)
```

<img src="krigr-downloads_files/figure-html/unnamed-chunk-3-1.png" width="1440" />

You will find that the data retained with the spatial limitation in `download_ERA()` contains all raster cells of which even a fraction falls within the bounds of the `SpatialPolygons` you supplied. This is different from standard `raster` masking through which only cells whose centroids fall within the `SpatialPolygons` are retained.

{{% hint info %}}
`raster` masking in `KrigR` always ensures that the entire area of your spatial preferences are retained.
{{% /hint %}}

### Points (`data.frame`)

Now we move on to point-locations. Often times, we are researching very specific sets of coordinates, rather than entire regions. `download_ERA()` is capable of limiting data to only small areas (of a size of your choosing) around your point-locations. For our purposes here, we make use of a set of mountain-top coordinates throughout our study region. Remember that these coordinates (stored in a `data.frame`) originate [here](/courses/krigr/prep/#points-of-interest-dataframe). 

This time around, we need to tell `download_ERA()` about not just the `Extent`, but also specify how much of a buffer (`Buffer` in $°$) to retain data for around each individual (`ID`) location.

{{% hint %}}
The `data.frame` input to the `Extent` must contain a column called `Lat` and a column called `Lon`:  

In addition, one must also specify:  
1. A `Buffer` in $°$ to be drawn around each location.  
2. The name of the `ID` column in your `data.frame` which indexes each individual location.  
{{% /hint %}}

{{% hint %}}
Our [development goals](/courses/outlook/) include support for a broader range of point-location specifications.
{{% /hint %}}

Let's stage such a download:

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/points_DL.nc">points_DL.nc</a> and place it into your data directory.
</details> 


```r
points_DL <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-01",
  DateStop = "1995-01-31",
  Extent = Mountains_df, # our data.frame with Lat and Lon columns
  Buffer = 0.5, # a half-degree buffer
  ID = "Mountain", # the ID column in our data.frame
  Dir = Dir.Data,
  FileName = "points_DL",
  API_User = API_User,
  API_Key = API_Key
)
Plot_Raw(points_DL, Dates = "01-1995") + 
  geom_point(aes(x = Lon, y = Lat), data = data.frame(Mountains_sp), 
             colour = "green", size = 10, pch = 14)
```

<img src="krigr-downloads_files/figure-html/unnamed-chunk-5-1.png" width="1440" />

Above you can see how the mountain tops we are interested in lie exactly at the centre of the retained data. As we will see later, such spatial limitation greatly reduces computation cost of statistical downscaling procedures.

## Temporal Aggregation

So far, we have downloaded a single layer of data (i.e., one monthly average layer) from the CDS. However, ERA5(-Land) products come at **hourly temporal resolutions** from which we can generate climate data at almost any temporal resolution we may require. This is what **temporal aggregation** in `download_ERA()` is for.

{{% hint info %}}
With **temporal aggregation** in `download_ERA()` you can achieve almost any temporal resolution and aggregate metric you may desire.
{{% /hint %}}

{{% hint %}}
Temporal aggregation with `download_ERA()` uses the arguments:  
- `TResolution` and `TStep` to achieve desired temporal resolutions  
- `FUN` to calculate desired aggregate metrics  
{{% /hint %}}

### Temporal Resolution (`TResolution` and `TStep`)

Let's start by querying data at non-CDS temporal resolutions.

{{% hint %}}
The `download_ERA()` function in the `KrigR` package accepts the following arguments which you can use to control the temporal resolution of your climate data:  
- `TResolution` controls the time-line that `TStep` indexes. You can specify anything from the following:  `'hour'`, `'day'`, `'month'`, or `'year'`. The default is `'month'`.   
- `TStep` controls how many time-steps to aggregate into one layer of data each. Aggregation is done via taking the mean per cell in each raster comprising time steps that go into the final, aggregated time-step. The default is `1`.  
{{% /hint %}}

For now, let's download hourly data from the CDS (this achieved by specifying a `TResolution` of `"hour"` or `"day"`) and aggregate these to 1-day intervals. To make the result easier to visualise, we focus only on the first four days of January 1995:

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/TimeSeries.nc">TimeSeries.nc</a> and place it into your data directory.
</details> 


```r
TimeSeries <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-01",
  DateStop = "1995-01-04",
  TResolution = "day", # aggregate to days
  TStep = 1, # aggregate to 1 day each
  Extent = Shape_shp,
  Dir = Dir.Data,
  FileName = "TimeSeries",
  API_User = API_User,
  API_Key = API_Key
)
Plot_Raw(TimeSeries, Dates = c("01-1995", "02-1995", 
                               "03-1995", "04-1995"),
         Shp = Shape_shp)
```

<img src="krigr-downloads_files/figure-html/unnamed-chunk-7-1.png" width="1440" />
Looks like a cold front rolled over my home area at the beginning of 1995.


{{% hint info %}}
`KrigR` automatically identifies which data set to download from given your temporal aggregation specification.
{{% /hint %}}

As soon as `TResolution` is set to `'month'` or `'year'`, the package automatically downloads monthly mean data from the CDS. We do this to make the temporal aggregation calculation more light-weight on your computing units and to make downloads less heavy.

Let's run through a few examples to make clear how desired temporal resolution of data can be achieved using the `KrigR` package:  

<table>
  <tr>
    <th>What We Want</th>
    <th>TResolution </th>
    <th>TStep</th>
  </tr>
  <tr>
    <td>Hourly intervals</td>
    <td>hour</td>
    <td>1</td>
  </tr>
  <tr>
    <td>6-hour intervals</td>
    <td>hour</td>
    <td>6</td>
  </tr>
  <tr>
    <td>Half-day intervals</td>
    <td>hour</td>
    <td>12</td>
  </tr>
  <tr>
    <td>Daily intervals </td>
    <td>day</td>
    <td>1</td>
  </tr>
  <tr>
    <td>3-day intervals</td>
    <td>day</td>
    <td>3</td>
  </tr>
  <tr>
    <td>Weekly intervals</td>
    <td>day</td>
    <td>7</td>
  </tr>
  <tr>
    <td>Monthly aggregates</td>
    <td>month</td>
    <td>1</td>
  </tr>
  <tr>
    <td>4-month intervals</td>
    <td>month</td>
    <td>4</td>
  </tr>
  <tr>
    <td>Annual intervals</td>
    <td>year</td>
    <td>1</td>
  </tr>
  <tr>
    <td>10-year intervals</td>
    <td>year</td>
    <td>10</td>
  </tr>
</table> 

{{% hint warning %}}
Specifying `TResolution` of `'month'` will result in the download of full month aggregates for every month included in your time series.
{{% /hint %}}

For example, `DateStart = "2000-01-20"`, `DateStop = "2000-02-20"` with `TResolution = 'month'`, and `TStep = 1` **does not** result in the mean aggregate for the month between the 20/01/200 and the 20/02/2000, but **does result** in the monthly aggregates for January and February 2000. If you desire the former, you would need to specify `DateStart = "2000-01-20"`, `DateStop = "2000-02-20"` with `TResolution = 'day'`, and `TStep = 32` (the number of days between the two dates). 

### Aggregate Metrics (`FUN`)

Aggregate metrics can be particularly useful for certain study settings when climate variability or exposure to extreme events are sought after.

{{% hint %}}
The `FUN` argument in `download_ERA()` controls which values to calculate for the temporal aggregates, e.g.: `'min'`, `'max'`, or `'mean'` (default). 

Any function which returns a single value when fed a vector of values is supported.
{{% /hint %}}

Let's say we are interested in the variability of temperature across our study region in daily intervals. Again, we shorten our time-series to just four days:

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/TimeSeriesSD.nc">TimeSeriesSD.nc</a> and place it into your data directory.
</details> 


```r
TimeSeriesSD <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-01",
  DateStop = "1995-01-04",
  TResolution = "day",
  TStep = 1,
  FUN = sd, # query standard deviation
  Extent = Shape_shp,
  Dir = Dir.Data,
  FileName = "TimeSeriesSD",
  API_User = API_User,
  API_Key = API_Key
)
Plot_Raw(TimeSeriesSD, Dates = c("01-1995", "02-1995", 
                                 "03-1995", "04-1995"),
         Shp = Shape_shp)
```

<img src="krigr-downloads_files/figure-html/unnamed-chunk-9-1.png" width="1440" />
Seems like the temperatures fluctuated most on the third and fourth of January, but the area of temperature fluctuations changed location between those two days.

{{% hint info %}}
You should now be able to query data for any location you study and achieve temporal resolutions and aggregate metrics which your study requires.
{{% /hint %}}

## Dynamical Data Uncertainty

With climate reanalyses, you also gain access to uncertainty flags of the data stored in the reanalysis product. For the ERA5-family of products, this uncertainty can be obtained by assessing the standard deviation of the 10 ensemble members which make up the underlying ERA5 model exercise.

With `download_ERA()` you can obtain this information as follows:

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/SpatialPolygonsEns_DL.nc">SpatialPolygonsEns_DL.nc</a> and place it into your data directory.
</details> 


```r
SpatialPolygonsEns_DL <- download_ERA(
    Variable = "2m_temperature",
    DataSet = "era5",
    Type = "ensemble_members",
    DateStart = "1995-01-01",
    DateStop = "1995-01-02",
    TResolution = "day",
    TStep = 1,
    FUN = sd,
    Extent = Shape_shp,
    Dir = Dir.Data,
    FileName = "SpatialPolygonsEns_DL",
    API_User = API_User,
    API_Key = API_Key
  )
Plot_Raw(SpatialPolygonsEns, Dates = c("01-1995", "02-1995"),
         Shp = Shape_shp, COL = rev(viridis(100)))
```

<img src="krigr-downloads_files/figure-html/unnamed-chunk-11-1.png" width="1440" />

As you can see here, there is substantial disagreement between the ensemble members of daily average temperatures across our study region. This uncertainty among ensemble members is greatest at high temporal resolution and becomes negligible at coarse temporal resolution. We document this phenomenon in [this publication (Figure 1)](https://iopscience.iop.org/article/10.1088/1748-9326/ac39bf).

## Final Downloads for Workshop Progress

Now that we know how to use spatial limitation and temporal aggregation with `download_ERA()` it is time to generate the data products we will use for the rest of this workshop material.

### Climate Data

{{% hint info %}}
To streamline this workshop material, I will focus on just three short-time series of data with different spatial limitations. I visualise them all side-by-side further down.
{{% /hint %}}

<details><summary> Click here for download calls </summary>
  
#### `extent` Data

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/ExtentRaw.nc">ExtentRaw.nc</a> and place it into your data directory.
</details> 


```r
Extent_Raw <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-01",
  DateStop = "1995-01-04",
  TResolution = "day",
  TStep = 1,
  Extent = Extent_ext,
  Dir = Dir.Data,
  FileName = "ExtentRaw",
  API_User = API_User,
  API_Key = API_Key
)
```



#### `SpatialPolygons` Data

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/SpatialPolygonsRaw.nc">SpatialPolygonsRaw.nc</a> and place it into your data directory.
</details> 


```r
SpatialPolygons_Raw <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-03",
  DateStop = "1995-01-03",
  TResolution = "day",
  TStep = 1,
  Extent = Shape_shp,
  Dir = Dir.Data,
  FileName = "SpatialPolygonsRaw",
  API_User = API_User,
  API_Key = API_Key
)
```



#### Point(`data.frame`) Data

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/PointsRaw.nc">PointsRaw.nc</a> and place it into your data directory.
</details> 




```r
Points_Raw <- download_ERA(
  Variable = "2m_temperature",
  DataSet = "era5-land",
  DateStart = "1995-01-01",
  DateStop = "1995-01-4",
  TResolution = "day",
  TStep = 1,
  Extent = Mountains_df,
  Buffer = 0.5,
  ID = "Mountain",
  Dir = Dir.Data,
  FileName = "PointsRaw",
  API_User = API_User,
  API_Key = API_Key
)
```
  
</details>

Now let's visualise these data for a better understanding of what they contain:

```r
Extent_gg <- Plot_Raw(Extent_Raw[[1]], Dates = "Extent")
SP_gg <- Plot_Raw(SpatialPolygons_Raw[[1]], Dates = "SpatialPolygons")
Points_gg <- Plot_Raw(Points_Raw[[1]], Dates = "SpatialPolygons")
plot_grid(Extent_gg, SP_gg, Points_gg, ncol = 3)
```

<img src="krigr-downloads_files/figure-html/dataviz-1.png" width="1440" />

### Dynamical Data Uncertainty

{{% hint info %}}
For an aggregate understanding of data uncertainty, we also obtain dynamical uncertainty for our target region and time frame. For simplicity, we do so only for the `SpatialPolygons` specification.
{{% /hint %}}

<details><summary> Click here for download call </summary>

<details>
  <summary>Click here for file if download takes too long:</summary>
    Download 
<a href="/courses/krigr/Data/SpatialPolygonsEns.nc">SpatialPolygonsEns.nc</a> and place it into your data directory.
</details> 


```r
SpatialPolygonsEns <- download_ERA(
    Variable = "2m_temperature",
    DataSet = "era5",
    Type = "ensemble_members",
    DateStart = "1995-01-01",
    DateStop = "1995-01-04",
    TResolution = "day",
    TStep = 1,
    FUN = sd,
    Extent = Shape_shp,
    Dir = Dir.Data,
    FileName = "SpatialPolygonsEns",
    API_User = API_User,
    API_Key = API_Key
  )
```



</details> 


```r
Plot_Raw(SpatialPolygonsEns, Dates = c("01-1995", "02-1995", 
                                          "03-1995", "04-1995"),
         Shp = Shape_shp, COL = rev(viridis(100)))
```

<img src="krigr-downloads_files/figure-html/unnamed-chunk-17-1.png" width="1440" />

We will see how these uncertainties stack up against other sources of uncertainty when we arrive at [aggregate uncertainty](/courses/krigr/kriging/#aggregate-uncertainty) of our final product.

## Considerations for `download_ERA()`

`download_ERA()` is a complex function with many things happening under the hood. To make sure you have the best experience with this interface to the ERA5(-Land) products through `R`, I have compiled a few bits of *good-to-know* information about the workings of `download_ERA()`.

### Effeciency

Download speeds with `download_ERA()` are largely tied to CDS queue time, but there are some things worth considering when querying downloads of time-series data.

{{% hint warning %}}
The `download_ERA()` function automatically breaks down download requests into monthly intervals thus circumventing the danger of running into making a download request that is too big for the CDS.
{{% /hint %}}

For example, `DateStart = "2000-01-20"`, `DateStop = "2000-02-20"` with `TResolution = 'day'`, and `TStep = 8` will lead to two download requests to the CDS: (1) hourly data in the range 20/01/2000 00:00 to 31/01/2000 23:00, and (2) hourly data in the range 01/02/2000 00:00 to 20/02/2000 23:00. These data sets are subsequently fused in `R`, aggregated to daily aggregates, and finally, aggregated to four big aggregates.  
This gives you a lot of flexibility, but always keep in mind that third-party data sets might not account for leap-years so make sure the dates of third-party data (should you chose to use some) lines up with the ones as specified by your calls to the functions of the `KrigR` package.

#### `SingularDL`

ECMWF CDS downloads come with a hard limit of 100,000 layers worth of data. This corresponds to more than 1 month worth of data. As a matter of fact, even ar hourly time-scales, you could theoretically download ~11 years worth of data without hitting this limit. In this particular case, `download_ERA()` stages, by default, 132 individual downloads (1 per month) when the CDS would be just fine accepting the download request for all the data in one download call.

Is there any way to bypass the monthly downloads in `download_ERA()`? Yes, there is. With the `SingularDL` argument.

{{% hint info %}}
Setting `SingularDL = TRUE` in `download_ERA()` bypasses the automatic month-wise download staging. A pre-staging check breaks the operation if you query more than the CDS hard limit on data.
{{% /hint %}}

{{% hint %}}
Our [development goals](/courses/outlook/) include changing month-wise default downloads to downloads of 100,000 layers at a time.
{{% /hint %}}

#### `Cores`

Continuing on from the previous point, let's consider you want to obtain more than 100,000 layers worth of data for your analysis and thus can't make use of the `SingularDL` argument. 
By default `download_ERA()` stages downloads sequentially. Most modern PCs come with multiple cores each of which could theoretically stage it's own download in parallel. Couldn't we make use of this for more efficient download staging? Yes, we can with the `Cores` argument.

{{% hint info %}}
Using the `Cores` argument in `download_ERA()` you can specify how many downloads to stage in parallel rather than sequentially.
{{% /hint %}}

#### Disk Space

`KrigR` uses NETCDF (.nc) files as they represent the standard in climate science. NETCDF file size is not connected to data content in the raster but number of cells. Other formats, such as GeoTiff (.tif) do however scale in file size with non-NA cell number in the saved rasters.

{{% hint %}}
Our [development goals](/courses/outlook/) include giving the user control over the file type as which `KrigR`-derived products are saved.
{{% /hint %}}

For example, the file size of the above `FirstDL` raster is 7kb while the `SpatialPolygons` and `data.frame` driven data is saved as GeoTiffs of 4kb and 3kb, respectively.

{{% hint %}}
If you need to optimise storage space, particularly when using [spatial limitation](/courses/krigr/download/#spatial-limitation) with `KrigR`, I can thus recommend re-saving `KrigR` outputs as GeoTiffs.
{{% /hint %}}

### Cummulative Variables (`PrecipFix`)

{{% hint danger %}}
Some variables in the ERA5(-Land) data sets are stored as cumulative records for pre-set time-windows, but temporal aggregation in `download-ERA()` cannot handle such data.
{{% /hint %}}

Consequently, cumulative records need to be transformed into single-time-step records with respect to their base temporal resolution and cumulative aggregation interval like so:

<img src="/post/krigr-mats/PrecipFix.jpg" width="900"/>

{{% hint %}}
To make cumulatively stored variables compatible with temporal aggregation in `download_ERA()` simple toggle `PrecipFix = TRUE` in the function call.
{{% /hint %}}

{{% hint info %}}
To identify which variables are stored cumulatively, we recommend searching for variables listed as "This variable is accumulated from the beginning of the forecast time to the end of the forecast step." on the data set documentation page (e.g., [ERA5-Land](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land?tab=overview)).
{{% /hint %}}

{{% hint %}}
Our [development goals](/courses/outlook/) include an error check for specification of `PrecipFix = TRUE` on non-cumulatively stored variables.
{{% /hint %}}

### Stability

`download_ERA()` requires a stable connection to the ECWMF CDS. Sometimes, however, a connection may drop or the CDS queue is so long that our downloads just fail. To mitigate the annoyance caused by these issues, I have implemented to extra arguments to the `download_ERA()` function call:

#### `TimeOut`

`TimeOut` is a numeric argument which specifies how many seconds to wait for the CDS to return the queried data. The default equates to 10 hours.

#### `TryDown`

`TryDown` is a numeric argument which specifies how often to retry a download before giving up and moving on or stopping the execution of `download_ERA()`. The default is 10.


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
##  [4] webshot_0.5.2            tools_4.0.5              bslib_0.2.4             
##  [7] utf8_1.2.1               R6_2.5.0                 zyp_0.10-1.1            
## [10] KernSmooth_2.23-18       DBI_1.1.1                colorspace_2.0-0        
## [13] withr_2.4.2              tidyselect_1.1.0         gridExtra_2.3           
## [16] leaflet_2.0.4.1          curl_4.3.2               compiler_4.0.5          
## [19] leafem_0.1.3             gstat_2.0-7              labeling_0.4.2          
## [22] bookdown_0.22            sass_0.3.1               scales_1.1.1            
## [25] classInt_0.4-3           proxy_0.4-25             digest_0.6.27           
## [28] rmarkdown_2.7            base64enc_0.1-3          jpeg_0.1-8.1            
## [31] pkgconfig_2.0.3          htmltools_0.5.1.1        highr_0.9               
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
## [73] cachem_1.0.4             xfun_0.22                lwgeom_0.2-6            
## [76] e1071_1.7-6              rnaturalearthhires_0.2.0 class_7.3-18            
## [79] Kendall_2.2              tibble_3.1.1             intervals_0.15.2        
## [82] memoise_2.0.0            units_0.7-2              ellipsis_0.3.2
```
