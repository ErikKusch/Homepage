---
title: Research Project
subtitle: A Fictional Study of Sparrows
date: "2021-02-27"
slug: Research Project
categories: [Excursion into Biostatistics]
tags: [R, Statistics]
summary: 'This is a quick documentation of a mock research project used throughout all `R` exercises during this seminar series.'
authors: [Erik Kusch]
lastmod: '2020-02-27'
featured: no
projects:
output:
  blogdown::html_page:
    keep_md: true
    # toc: true
    # toc_depth: 2
    # number_sections: false
    fig_width: 8
linktitle: Research Project for our Exercises
menu:
  Excursions:
    parent: Seminars
    weight: 4
toc: true
type: docs
weight: 4
---



## Our Resarch Project

Here (and over the next few exercises in this "course"), we are looking at a big (and entirely fictional) data base of the common house sparrow (*Passer domesticus*). In particular, we are interested in the **Evolution of *Passer domesticus* in Response to Climate Change**.

### The Data

I have created a large data set for this exercise which is available in a cleaned and properly handled version {{< staticref "https://github.com/ErikKusch/Homepage/raw/master/content/courses/excursions-into-biostatistics/Data.rar" "newtab" >}} here{{< /staticref >}}.

#### Reading the Data into `R`

Let's start by reading the data into `R` and taking an initial look at it:

```r
Sparrows_df <- readRDS(file.path("Data", "SparrowData.rds"))
Sparrows_df <- Sparrows_df[!is.na(Sparrows_df$Weight), ]
head(Sparrows_df)
```

```
##   Index Latitude Longitude     Climate Population.Status Weight Height Wing.Chord Colour    Sex Nesting.Site Nesting.Height Number.of.Eggs Egg.Weight Flock Home.Range Predator.Presence Predator.Type
## 1    SI       60       100 Continental            Native  34.05  12.87       6.67  Brown   Male         <NA>             NA             NA         NA     B      Large               Yes         Avian
## 2    SI       60       100 Continental            Native  34.86  13.68       6.79   Grey   Male         <NA>             NA             NA         NA     B      Large               Yes         Avian
## 3    SI       60       100 Continental            Native  32.34  12.66       6.64  Black Female        Shrub          35.60              1       3.21     C      Large               Yes         Avian
## 4    SI       60       100 Continental            Native  34.78  15.09       7.00  Brown Female        Shrub          47.75              0         NA     E      Large               Yes         Avian
## 5    SI       60       100 Continental            Native  35.01  13.82       6.81   Grey   Male         <NA>             NA             NA         NA     B      Large               Yes         Avian
## 6    SI       60       100 Continental            Native  32.36  12.67       6.64  Brown Female        Shrub          32.47              1       3.17     E      Large               Yes         Avian
```

#### Variables
When building models or trying to explain anything about our data set, we need to consider all the different variables and the information contained therein. In this data set, we have access to:  

1. `Index` [*Factor*] - an abbreviation of `Site` records  
2. `Latitude` [*Numeric*] - an identifier of where specific sparrow measurements where taken  
3. `Longitude` [*Numeric*] - an identifier of where specific sparrow measurements where taken  
4. `Climate` [*Factor*] - local climate types that sparrows are subjected to (e.g. coastal, continental, and semi-coastal)  
5. `Population.Status` [*Factor*] - population status (e.g. native or introduced)  
6. `Weight` [*Numeric*] - sparrow weight [g]; Range: 13-40g  
7. `Height` [*Numeric*] - sparrow height/length [cm]; Range: 10-22cm  
8. `Wing.Chord` [*Numeric*] - wing length [cm]; Range: 6-10cm  
9. `Colour` [*Factor*] - main plumage colour (e.g. brown, grey, and black)  
10. `Sex` [*Factor*] - sparrow sex  
11. `Nesting.Site` [*Factor*] - nesting conditions, only recorded for females (e.g. tree or shrub)  
12. `Nesting.Height` [*Numeric*] - nest elevation above ground level, only recorded for females  
13. `Number.of.Eggs` [*Numeric*] - number of eggs per nest, only recorded for females  
14. `Egg.Weight` [*Numeric*] - mean weight of eggs per nest, only recorded for females  
15. `Flock` [*Factor*] - which flock at each location each sparrow belongs to  
16. `Home.Range` [*Factor*] - size of home range of each flock (e.g. Small, Medium, and Large)  
17. `Predator.Presence` [*Factor*] - if a predator is present at a station (e.g. No or Yes)  
18. `Predator.Type` [*Factor*] - what kind of predator is present (e.g. Avian, Non-Avian, or None)  

Note that the variables `Longitude` and `Latitude` may be used to retrieve climate data variables from a host of data sources.

#### Locations 
Looking at our data, we notice that it comes at distinct stations. Let's visualise where they are:

```r
library("leaflet")
Plot_df <- Sparrows_df[, c("Longitude", "Latitude", "Index", "Climate", "Population.Status")]
Plot_df <- unique(Plot_df)
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m,
  lng = Plot_df$Longitude,
  lat = Plot_df$Latitude,
  label = Plot_df$Index,
  popup = paste(Plot_df$Population.Status, Plot_df$Climate, sep = ";")
)
m
```

```{=html}
<div class="leaflet html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-198293ac646900c5a74e" style="width:1440px;height:768px;"></div>
<script type="application/json" data-for="htmlwidget-198293ac646900c5a74e">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[60,54,-25,-21.1,70,55,31,17.25,4,10.5,-51.75],[100,-2,135,55.6,-90,-97,-92,-88.75,-53,-67,-59.17],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},["Native;Continental","Native;Coastal","Introduced;Continental","Introduced;Coastal","Introduced;Coastal","Introduced;Semi-Coastal","Introduced;Coastal","Introduced;Coastal","Introduced;Coastal","Introduced;Coastal","Introduced;Coastal"],null,null,null,["SI","UK","AU","RE","NU","MA","LO","BE","FG","SA","FI"],{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-51.75,70],"lng":[-97,135]}},"evals":[],"jsHooks":[]}</script>
```

Note that you can zoom and drag the above map as well as click the station markers for some additional information.

### Adding Information

How do we get the data for this? Well, I wrote an `R`-Package that does exactly that.

First, said package needs to be installed from my GitHub repository for it. Subsequently, we need to set API Key and User number obtained at the [Climate Data Store](https://cds.climate.copernicus.eu/api-how-to). I have already baked these into my material, so I don't set them here, but include lines of code that ask you for your credentials when copy & pasted over:

```r
if ("KrigR" %in% rownames(installed.packages()) == FALSE) { # KrigR check
  Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS = "true")
  devtools::install_github("https://github.com/ErikKusch/KrigR")
}
library(KrigR)
#### CDS API (needed for ERA5-Land downloads)
if (!exists("API_Key") | !exists("API_User")) { # CS API check: if CDS API credentials have not been specified elsewhere
  API_User <- readline(prompt = "Please enter your Climate Data Store API user number and hit ENTER.")
  API_Key <- readline(prompt = "Please enter your Climate Data Store API key number and hit ENTER.")
} # end of CDS API check

#### NUMBER OF CORES
if (!exists("numberOfCores")) { # Core check: if number of cores for parallel processing has not been set yet
  numberOfCores <- readline(prompt = paste("How many cores do you want to allocate to these processes? Your machine has", parallel::detectCores()))
} # end of Core check
```

Now that we have the package, we can download some state-of-the-art climate data. I have already prepared all of this in the data directory you downloaded earlier so this step will automatically be skipped:


```r
if (!file.exists(file.path("Data", "SparrowDataClimate.rds"))) {
  colnames(Plot_df)[1:3] <- c("Lon", "Lat", "ID") # set column names to be in line with what KrigR wants
  Points_Raw <- download_ERA(
    Variable = "2m_temperature",
    DataSet = "era5",
    DateStart = "1982-01-01",
    DateStop = "2012-12-31",
    TResolution = "month",
    TStep = 1,
    Extent = Plot_df, # the point data with Lon and Lat columns
    Buffer = 0.5, # a 0.5 degree buffer should be drawn around each point
    ID = "ID", # this is the column which holds point IDs
    API_User = API_User,
    API_Key = API_Key,
    Dir = file.path(getwd(), "Data"),
    FileName = "AT_Climatology.nc"
  )
  Points_mean <- calc(Points_Raw, fun = mean)
  Points_sd <- calc(Points_Raw, fun = sd)
  Sparrows_df$TAvg <- as.numeric(extract(x = Points_mean, y = Sparrows_df[, c("Longitude", "Latitude")], buffer = 0.3))
  Sparrows_df$TSD <- as.numeric(extract(x = Points_sd, y = Sparrows_df[, c("Longitude", "Latitude")], buffer = 0.3))
  saveRDS(Sparrows_df, file.path("Data", "SparrowDataClimate.rds"))
} else {
  Sparrows_df <- readRDS(file.path("Data", "SparrowDataClimate.rds"))
}
```

We have now effectively added two more variables to the data set:  

19. `TAvg` [*Numeric*] - Average air temperature for a 30-year time-period    
20. `TSD` [*Numeric*] - Standard deviation of mean monthly air temperature for a 30-year time-period     

Now we have the data set we will look at for the rest of the exercises in this seminar series. But how did we get here? Find the answer {{< staticref "courses/excursions-into-biostatistics/data-handling-and-data-assumptions/" "newtab" >}} here{{< /staticref >}}.


### Hypotheses 
Let's consider the following two hypotheses for our exercises for this simulated research project:  
  
1. **Sparrow Morphology** is determined by:  
    A. *Climate Conditions* with sparrows in stable, warm environments fairing better than those in colder, less stable ones.  
    B. *Competition* with sparrows in small flocks doing better than those in big flocks.  
    C. *Predation* with sparrows under pressure of predation doing worse than those without.    
2. **Sites**  accurately represent **sparrow morphology**. This may mean:  
    A. *Population status* as inferred through morphology.  
    B. *Site index* as inferred through morphology.  
    C. *Climate* as inferred through morphology.  
    
We try to answer these over the next few sessions.

## SessionInfo

```r
sessionInfo()
```

```
## R version 4.2.3 (2023-03-15)
## Platform: x86_64-apple-darwin17.0 (64-bit)
## Running under: macOS Big Sur ... 10.16
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.2/Resources/lib/libRblas.0.dylib
## LAPACK: /Library/Frameworks/R.framework/Versions/4.2/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] parallel  stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] KrigR_0.1.2       terra_1.7-21      httr_1.4.5        stars_0.6-0       abind_1.4-5       fasterize_1.0.4   sf_1.0-12         lubridate_1.9.2   automap_1.1-9     doSNOW_1.0.20    
## [11] snow_0.4-4        doParallel_1.0.17 iterators_1.0.14  foreach_1.5.2     rgdal_1.6-5       raster_3.6-20     sp_1.6-0          stringr_1.5.0     keyring_1.3.1     ecmwfr_1.5.0     
## [21] ncdf4_1.21        leaflet_2.1.2    
## 
## loaded via a namespace (and not attached):
##  [1] xts_0.13.0         R.cache_0.16.0     tools_4.2.3        bslib_0.4.2        utf8_1.2.3         R6_2.5.1           KernSmooth_2.23-20 DBI_1.1.3          colorspace_2.1-0   tidyselect_1.2.0  
## [11] compiler_4.2.3     cli_3.6.0          gstat_2.1-0        bookdown_0.33      sass_0.4.5         scales_1.2.1       classInt_0.4-9     proxy_0.4-27       digest_0.6.31      rmarkdown_2.20    
## [21] R.utils_2.12.2     pkgconfig_2.0.3    htmltools_0.5.4    styler_1.9.1       fastmap_1.1.1      htmlwidgets_1.6.1  rlang_1.0.6        rstudioapi_0.14    FNN_1.1.3.2        jquerylib_0.1.4   
## [31] generics_0.1.3     zoo_1.8-11         jsonlite_1.8.4     crosstalk_1.2.0    dplyr_1.1.0        R.oo_1.25.0        magrittr_2.0.3     Rcpp_1.0.10        munsell_0.5.0      fansi_1.0.4       
## [41] lifecycle_1.0.3    R.methodsS3_1.8.2  stringi_1.7.12     yaml_2.3.7         plyr_1.8.8         grid_4.2.3         lattice_0.20-45    knitr_1.42         pillar_1.8.1       spacetime_1.2-8   
## [51] codetools_0.2-19   glue_1.6.2         evaluate_0.20      blogdown_1.16      vctrs_0.5.2        gtable_0.3.1       purrr_1.0.1        reshape_0.8.9      assertthat_0.2.1   cachem_1.0.7      
## [61] ggplot2_3.4.1      xfun_0.37          lwgeom_0.2-11      e1071_1.7-13       class_7.3-21       tibble_3.2.0       intervals_0.15.3   memoise_2.0.1      units_0.8-1        timechange_0.2.0  
## [71] ellipsis_0.3.2
```
