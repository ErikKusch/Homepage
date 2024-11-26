---
title: "Climate Data"
author: Erik Kusch
date: '2023-11-14'
slug: NFDI-climate
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: "Matching GBIF mediated data to relevant climate data obtained with `KrigR`"
summary: 'A quick overview of using `KrigR` with GBIF data.'
authors: []
lastmod: '2023-11-14T20:00:00+01:00'
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
  gbif:
    parent: NFDI4Biodiversity Seasonal School
    weight: 3
weight: 11
---



{{% alert warning %}}
This section of material is dependant on you having walked through the section on [finding & downloading data](/courses/gbif/nfdi-download/) first.
{{% /alert %}}

## Required `R` Packages & Preparations

Once more, we need some `R` packages:


``` r
## Custom install & load function
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, repos = "http://cran.us.r-project.org")
  }
  require(x, character.only = TRUE)
}
## names of packages we want installed (if not installed yet) and loaded
package_vec <- c(
  "knitr", # for rmarkdown table visualisations
  "sf", # for spatial operations
  "terra", # for matching spatialobjects with raster data
  "devtools", # for installation of additional package from github
  "rnaturalearth", # for shapefiles
  "rnaturalearthdata", # for high resolution shapefiles
  "ggplot2" # some additional plotting capabilities
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
##             knitr                sf             terra          devtools     rnaturalearth 
##              TRUE              TRUE              TRUE              TRUE              TRUE 
## rnaturalearthdata           ggplot2 
##              TRUE              TRUE
```

In addition to these packages, we also need another `R` package, not hosted on CRAN, but instead hosted on GitHub and developed and maintained by me. We need at least version 0.9.4 of it:

``` r
if (packageVersion("KrigR") < "0.9.4") { # KrigR check
  devtools::install_github("https://github.com/ErikKusch/KrigR")
}
library(KrigR)
```

{{% alert success %}}
With the packages loaded and the `NFDI4Bio_GBIF.csv` and `NFDI4Bio_GBIF.RData` produced from the [previous section](/courses/gbif/nfdi-handling/), you are now ready to combine your GBIF mediated data with other relevant data products.
{{% /alert %}}

## Climate Data in Ecological Research

Understanding ecological processes often necessitates knowing about the environmental conditions life on Earth experiences. To gain this information, we consult climate data sets.

### Data Sources & Considerations

There are many climate data products out there. Many of them will fit your needs. Some of them will fit your needs much better than others. Judging the applicability of a given climate data product for your biological research is beyond your formal training and I do not blame you for not knowing where to get started on this.

In short, climate data science has made substantial advances that ecological research has not yet readily adopted into our workflows. I have a whole [talk and workshop](/courses/krigr/background/) ready trying to overcome these issues.

For now, just know that we will not be using ready-made datasets like WorldClim here for reasons pertaining mostly to accuracy and reliability and I do not recommend you use WorldClim for anything but exploratory data analyses. Using a dataset like this usually restricts you more than the ease-of-its-use is worth, to my mind.

{{% alert warning %}}
Where possible, I recommend you investigate thoroughly which climate data product to obtain your data from. Do not shy away from heavy data lifting.
{{% /alert %}}

### Bioclimatic Variables

Much like there are many climate data products, there are also many climate parameters that may be of relevance to your study needs. For species distribution modelling, the [19 bioclimatic variables](https://www.worldclim.org/data/bioclim.html) have become standard.

Personally, I do not think that this is good practice, but I am here to teach you data handling and not to overthrow agreed-upon modelling conventions. Nevertheless, I will quickly tell you qhy I believe bioclimatic variables to fall short of what we would like to use:
1. They are simply just aggregates of temperature and water availability information. We know that ecosystems and their components are affected by many more parameters for which we do have climate data products.
2. They do not account for trends in their underlying parameters over time and thus do not capture climate change trajectories well.
3. They don't capture extreme events or compound events particularly well due to coarse temporal resolutions.

{{% alert warning %}}
Please consider carefully whether bioclimatic variables alone are enough for your analysis needs.
{{% /alert %}}

## Retrieving Climatic Data with `KrigR`

Retrieving climate data is outside of your formal skillset and not a trivial undertaking. To streamline this process and ease the burden of entry into this field, I have created the `R` Package `KrigR` which gives you functionality to access state-of-the-art climate data from the ECMWF Climate Data Store.

For a full exploration of this package, please consult the separate [workshop material](/courses/krigr/) I have prepared for it.

### CDS API Credentials

Make sure you have registered your CDS API credentials as described [here](/courses/krigr/setup/).

### Bioclimatic Data

We can now use the `BioClim()` function from the `KrigR` package to obtain bioclimatic variables relevant to our study area and time-frame. This function makes all of the download calls and does all of the calculations for us, thus allowing us to easily use state-of-the-art climate data to derive bioclimatic variables.

Before we can get started with this, however, we need a shapefile describing the outline of Germany. `KrigR` doesn't work with country ISO codes like `rgbif` does, but with shapefiles. Let's load the germany shapefile we used previously:

``` r
DE_shp <- rnaturalearth::ne_countries(country = "Germany", scale = 10, returnclass = "sf")[, 1]
```

Now, we will execute our `BioClim()` download:

{{% alert danger %}}
Note that retrieval of large datasets via `KrigR` may take considerable time. This is the price you have to pay for state-of-the-art climate data for your study needs, I am afraid.
{{% /alert %}}


{{% alert info %}}
If the below takes too long to finish for you, feel free to download the resulting file from [here](https://github.com/ErikKusch/Homepage/raw/master/content/courses/gbif/Germany.nc).
{{% /alert %}}


``` r
BV_DE <- BioClim(
  Temperature_Var = "2m_temperature", # temperature variable
  Temperature_DataSet = "reanalysis-era5-land", # data product to source temperature variable data from
  Temperature_Type = NA, # type of data product to source temperature variable data from
  Water_Var = "total_precipitation", # water availability variable
  Water_DataSet = "reanalysis-era5-land-monthly-means", # data product to source water availability variable data from
  Water_Type = "monthly_averaged_reanalysis", # type of data product to source water availability variable data from
  Y_start = 1970, # first year in the time window
  Y_end = 2020, # last year in the time window
  TZone = "CET", # time zone in which we want to calculate our variables
  Extent = DE_shp, # shapefile or extent of study area
  FileName = "Germany", # name of netcdf file written to our disk by this function
  API_User = API_User, # api credentials
  API_Key = API_Key, # api credentials
  closeConnections = FALSE # needing to set this so it runs in markdown, you do not need to worry about this
)
```

```
## [1] "A file with the name Germany.nc already exists in C:/Users/erikkus/Documents/Homepage/content/courses/gbif."
## [1] "Loading this file for you from the disk."
```

As you can see, I already have the resulting file present on my disk. `KrigR` notices this and simply loads the file for me so I can use it right away instead of recalculating everything.

{{% alert warning %}}
Just like GBIF mediated data, you also need to properly accredit the environmental data you use in your research. 
{{% /alert %}}

With `KrigR` you can easily obtain the citation string for each dataset derived via `KrigR` like so:


``` r
terra::metags(BV_DE)["Citation"]
```

```
##                                                                                                 Citation 
## "Bioclimatic variables obtained with KrigR (DOI:10.1088/1748-9326/ac48b3) on 2024-11-14 16:58:36.946977"
```

Now, we can use the `KrigR`-inbuilt visualisation functionality to plot the bioclimatic variables across Germany. 

First, we plot all temperature variables:

``` r
Plot.BioClim(
  BioClims = BV_DE, SF = DE_shp,
  Which = 1:11,
  Water_Var = "Total Precipitation [mm]"
)
```

<img src="SeasonalSchool-climatedata_files/figure-html/unnamed-chunk-4-1.png" width="1440" />

Next, we plot all water availability variables:

``` r
Plot.BioClim(
  BioClims = BV_DE, SF = DE_shp,
  Which = 12:19,
  ncol = 2,
  Water_Var = "Total Precipitation [mm]"
)
```

<img src="SeasonalSchool-climatedata_files/figure-html/unnamed-chunk-5-1.png" width="1440" />

{{% alert success %}}
You now have cutting-edge bioclimatic information ready for your downstream analyses!
{{% /alert %}}

### Matching Observations with Climate Data

Lastly, all that is left to do is matching the observations we obtained from GBIF with the climate data we just prepared. To get this started, we first load the spatial features object of obvservation points we created previously:


``` r
load("GBIF_sf.RData")
```

Now let's use the `KrigR` visualisation toolbox once more to plot these points onto a map of the first bioclimatic variable (annual mean temperature):


``` r
Plot.BioClim(
  BioClims = BV_DE,
  SF = GBIF_sf,
  Which = 1,
  ncol = 1,
  Size = 1
)
```

<img src="SeasonalSchool-climatedata_files/figure-html/unnamed-chunk-7-1.png" width="1440" />

The underlying climate data is a bit coarse, so we find some data points on islands which we will not be able to match with climate data. Nevertheless, let's push on.

To extract climate data from all bioclimatic variables for each observation we have retained after cleaning our GBIF mediated data, we simply use the `extract()` function from the `terra` package:


``` r
extracted_df <- terra::extract(x = BV_DE, y = GBIF_sf)
dim(extracted_df)
```

```
## [1] 58304    20
```

You see that we have extracted information for each observation and 20 columns. Why 20 columns, aren't there just 19 bioclimatic variables? Well, yes, but we also record an ID for each observation:


``` r
knitr::kable(head(extracted_df))
```



| ID|     BIO1|     BIO2|     BIO3|     BIO4|     BIO5|     BIO6|     BIO7|     BIO8|     BIO9|    BIO10|    BIO11|     BIO12|     BIO13|     BIO14|    BIO15|     BIO16|     BIO17|     BIO18|     BIO19|
|--:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|---------:|---------:|---------:|--------:|---------:|---------:|---------:|---------:|
|  1| 282.8060| 11.56009| 23.40577| 697.0049| 301.5184| 252.1285| 49.38994| 290.7341| 286.3700| 290.7341| 275.1877| 0.6891775| 0.2492599| 0.0022743| 4.280466|  9.223780|  7.968918|  9.223780|  8.198037|
|  2| 282.2700| 11.56496| 24.08731| 652.6573| 300.2569| 252.2442| 48.01268| 289.7771| 285.3839| 289.7771| 275.1406| 0.7945873| 0.2119986| 0.0041780| 3.993065| 10.366795|  9.318233| 10.366795|  9.613353|
|  3| 282.7631| 11.80689| 23.66432| 689.1375| 300.6205| 250.7273| 49.89320| 290.6756| 286.1358| 290.6756| 275.2898| 0.7198712| 0.1815318| 0.0009143| 3.985592|  9.298201|  8.278377|  9.298201|  8.949971|
|  4| 281.6990| 12.49376| 31.00520| 682.9493| 299.1687| 258.8730| 40.29568| 289.4790| 285.1010| 289.4790| 274.2594| 0.9505705| 0.2147094| 0.0017350| 3.853150| 12.087655| 11.246518| 12.087655| 11.700603|
|  5| 281.8596| 11.29835| 28.98178| 635.9584| 299.1519| 260.1676| 38.98431| 289.1873| 284.8993| 289.1873| 274.9467| 0.8459014| 0.2779124| 0.0020682| 3.920097| 10.731587| 10.196636| 10.731587| 10.449787|
|  6| 282.0240| 10.56826| 22.84456| 674.8423| 299.6821| 253.4205| 46.26158| 289.7753| 285.3079| 289.7753| 274.4990| 0.7309243| 0.2611389| 0.0026328| 4.086557|  9.681484|  8.469324|  9.681484|  8.544147|

Let's save this data by merging the original observations with their bioclimatic characteristics and export the data ready for analysis in species distribution models. We omit any row with NAs in it, as some observations fall outside of areas where we have climatic information and thus won't be able to use these observations in SDMs:


``` r
SDMData_df <- as.data.frame(cbind(GBIF_sf, extracted_df))
SDMData_df <- na.omit(SDMData_df)
knitr::kable(head(SDMData_df))
```



|   |scientificName             | taxonKey|family   | familyKey|species           | decimalLongitude| decimalLatitude| year| month| day|eventDate            |countryCode |municipality |stateProvince          |catalogNumber |mediaType                        |datasetKey                           |       lon|      lat| ID|     BIO1|     BIO2|     BIO3|     BIO4|     BIO5|     BIO6|     BIO7|     BIO8|     BIO9|    BIO10|    BIO11|     BIO12|     BIO13|     BIO14|    BIO15|     BIO16|     BIO17|     BIO18|     BIO19|geometry                  |
|:--|:--------------------------|--------:|:--------|---------:|:-----------------|----------------:|---------------:|----:|-----:|---:|:--------------------|:-----------|:------------|:----------------------|:-------------|:--------------------------------|:------------------------------------|---------:|--------:|--:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|--------:|---------:|---------:|---------:|--------:|---------:|---------:|---------:|---------:|:-------------------------|
|1  |Quercus robur L.           |  2878688|Fagaceae |      4689|Quercus robur     |        13.197520|        52.48053| 2019|     6|  14|2019-06-14T12:28     |DE          |             |Berlin                 |27039839      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 | 13.197520| 52.48053|  1| 282.8060| 11.56009| 23.40577| 697.0049| 301.5184| 252.1285| 49.38994| 290.7341| 286.3700| 290.7341| 275.1877| 0.6891775| 0.2492599| 0.0022743| 4.280466|  9.223780|  7.968918|  9.223780|  8.198037|POINT (13.19752 52.48053) |
|2  |Fagus sylvatica L.         |  2882316|Fagaceae |      4689|Fagus sylvatica   |        10.635290|        52.13933| 2020|     4|  18|2020-04-18T17:52:36  |DE          |             |Niedersachsen          |42521643      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 | 10.635290| 52.13933|  2| 282.2700| 11.56496| 24.08731| 652.6573| 300.2569| 252.2442| 48.01268| 289.7771| 285.3839| 289.7771| 275.1406| 0.7945873| 0.2119986| 0.0041780| 3.993065| 10.366795|  9.318233| 10.366795|  9.613353|POINT (10.63529 52.13933) |
|4  |Quercus palustris Münchh. |  8313153|Fagaceae |      4689|Quercus palustris |        12.388285|        51.36412| 2019|    10|  26|2019-10-26T15:30:07  |DE          |             |Sachsen                |34915487      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 | 12.388285| 51.36412|  3| 282.7631| 11.80689| 23.66432| 689.1375| 300.6205| 250.7273| 49.89320| 290.6756| 286.1358| 290.6756| 275.2898| 0.7198712| 0.1815318| 0.0009143| 3.985592|  9.298201|  8.278377|  9.298201|  8.949971|POINT (12.38828 51.36412) |
|6  |Quercus robur L.           |  2878688|Fagaceae |      4689|Quercus robur     |        12.510908|        50.72724| 2020|     5|   7|2020-05-07T19:06:10  |DE          |             |Sachsen                |45185825      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 | 12.510908| 50.72724|  4| 281.6990| 12.49376| 31.00520| 682.9493| 299.1687| 258.8730| 40.29568| 289.4790| 285.1010| 289.4790| 274.2594| 0.9505705| 0.2147094| 0.0017350| 3.853150| 12.087655| 11.246518| 12.087655| 11.700603|POINT (12.51091 50.72724) |
|7  |Fagus sylvatica L.         |  2882316|Fagaceae |      4689|Fagus sylvatica   |         9.592076|        51.47528| 2020|     5|  21|2020-05-21T11:07:39  |DE          |             |Hessen                 |46711391      |StillImage;StillImage;StillImage |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |  9.592076| 51.47528|  5| 281.8596| 11.29835| 28.98178| 635.9584| 299.1519| 260.1676| 38.98431| 289.1873| 284.8993| 289.1873| 274.9467| 0.8459014| 0.2779124| 0.0020682| 3.920097| 10.731587| 10.196636| 10.731587| 10.449787|POINT (9.592076 51.47528) |
|8  |Quercus robur L.           |  2878688|Fagaceae |      4689|Quercus robur     |        12.791288|        53.45432| 2019|     5|  29|2019-05-29T14:44:56Z |DE          |             |Mecklenburg-Vorpommern |26128754      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 | 12.791288| 53.45432|  6| 282.0240| 10.56826| 22.84456| 674.8423| 299.6821| 253.4205| 46.26158| 289.7753| 285.3079| 289.7753| 274.4990| 0.7309243| 0.2611389| 0.0026328| 4.086557|  9.681484|  8.469324|  9.681484|  8.544147|POINT (12.79129 53.45432) |

Now to save this data as a .csv:


``` r
write.csv(SDMData_df, file = "NFDI4Bio_SDMData.csv")
```

Finally, here is a sneak-peak on how we can use this information to identify different environmental preferences across the taxonomic familie sof interest:


``` r
ggplot(SDMData_df, aes(x = family, y = BIO1)) +
  geom_boxplot() +
  theme_bw()
```

<img src="SeasonalSchool-climatedata_files/figure-html/unnamed-chunk-12-1.png" width="1440" />

{{% alert success %}}
You have done it! You are now fully equipped to interface with GBIF, critically inspect the data obtained therefrom, and match it with state-of-the-art climate data.
{{% /alert %}}

# Session Info

```
## R version 4.4.0 (2024-04-24 ucrt)
## Platform: x86_64-w64-mingw32/x64
## Running under: Windows 11 x64 (build 22631)
## 
## Matrix products: default
## 
## 
## locale:
## [1] C
## 
## time zone: Europe/Oslo
## tzcode source: internal
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] KrigR_0.9.4             ggplot2_3.5.1           rnaturalearthdata_1.0.0
## [4] rnaturalearth_1.0.1     devtools_2.4.5          usethis_3.0.0          
## [7] terra_1.7-78            sf_1.0-17               knitr_1.48             
## 
## loaded via a namespace (and not attached):
##   [1] DBI_1.2.3                     pbapply_1.7-2                
##   [3] gridExtra_2.3                 remotes_2.5.0                
##   [5] rlang_1.1.4                   magrittr_2.0.3               
##   [7] e1071_1.7-16                  compiler_4.4.0               
##   [9] vctrs_0.6.5                   ecmwfr_2.0.2                 
##  [11] stringr_1.5.1                 profvis_0.4.0                
##  [13] pkgconfig_2.0.3               crayon_1.5.3                 
##  [15] fastmap_1.2.0                 ellipsis_0.3.2               
##  [17] labeling_0.4.3                utf8_1.2.4                   
##  [19] promises_1.3.0                rmarkdown_2.28               
##  [21] sessioninfo_1.2.2             automap_1.1-12               
##  [23] purrr_1.0.2                   rnaturalearthhires_1.0.0.9000
##  [25] xfun_0.47                     cachem_1.1.0                 
##  [27] jsonlite_1.8.8                progress_1.2.3               
##  [29] highr_0.11                    later_1.3.2                  
##  [31] styler_1.10.3                 reshape_0.8.9                
##  [33] prettyunits_1.2.0             parallel_4.4.0               
##  [35] R6_2.5.1                      stringi_1.8.4                
##  [37] bslib_0.8.0                   pkgload_1.4.0                
##  [39] lubridate_1.9.3               jquerylib_0.1.4              
##  [41] stars_0.6-7                   Rcpp_1.0.13                  
##  [43] bookdown_0.40                 iterators_1.0.14             
##  [45] zoo_1.8-12                    snow_0.4-4                   
##  [47] R.utils_2.12.3                FNN_1.1.4.1                  
##  [49] httpuv_1.6.15                 R.cache_0.16.0               
##  [51] timechange_0.3.0              tidyselect_1.2.1             
##  [53] viridis_0.6.5                 abind_1.4-8                  
##  [55] yaml_2.3.10                   codetools_0.2-20             
##  [57] miniUI_0.1.1.1                blogdown_1.19                
##  [59] pkgbuild_1.4.4                lattice_0.22-6               
##  [61] tibble_3.2.1                  intervals_0.15.5             
##  [63] plyr_1.8.9                    shiny_1.9.1                  
##  [65] withr_3.0.2                   evaluate_0.24.0              
##  [67] units_0.8-5                   proxy_0.4-27                 
##  [69] urlchecker_1.0.1              xts_0.14.0                   
##  [71] pillar_1.9.0                  KernSmooth_2.23-22           
##  [73] foreach_1.5.2                 ncdf4_1.23                   
##  [75] generics_0.1.3                sp_2.1-4                     
##  [77] spacetime_1.3-2               hms_1.1.3                    
##  [79] munsell_0.5.1                 scales_1.3.0                 
##  [81] xtable_1.8-4                  class_7.3-22                 
##  [83] glue_1.7.0                    tools_4.4.0                  
##  [85] fs_1.6.4                      cowplot_1.1.3                
##  [87] grid_4.4.0                    tidyr_1.3.1                  
##  [89] colorspace_2.1-1              cli_3.6.3                    
##  [91] gstat_2.1-2                   fansi_1.0.6                  
##  [93] viridisLite_0.4.2             dplyr_1.1.4                  
##  [95] doSNOW_1.0.20                 gtable_0.3.6                 
##  [97] R.methodsS3_1.8.2             sass_0.4.9                   
##  [99] digest_0.6.37                 classInt_0.4-10              
## [101] farver_2.1.2                  htmlwidgets_1.6.4            
## [103] memoise_2.0.1                 htmltools_0.5.8.1            
## [105] R.oo_1.26.0                   lifecycle_1.0.4              
## [107] httr_1.4.7                    mime_0.12
```
