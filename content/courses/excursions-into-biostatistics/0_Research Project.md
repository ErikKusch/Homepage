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

I have created a large data set for this exercise which is available in a cleaned and properly handled version {{< staticref "courses/excursions-into-biostatistics/Data.rar" "newtab" >}} here{{< /staticref >}}.

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
<div id="htmlwidget-3c63c9ca5e7feb33e868" style="width:1440px;height:768px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-3c63c9ca5e7feb33e868">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[60,54,-25,-21.1,70,55,31,17.25,4,10.5,-51.75],[100,-2,135,55.6,-90,-97,-92,-88.75,-53,-67,-59.17],null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},["Native;Continental","Native;Coastal","Introduced;Continental","Introduced;Coastal","Introduced;Coastal","Introduced;Semi-Coastal","Introduced;Coastal","Introduced;Coastal","Introduced;Coastal","Introduced;Coastal","Introduced;Coastal"],null,null,null,["SI","UK","AU","RE","NU","MA","LO","BE","FG","SA","FI"],{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-51.75,70],"lng":[-97,135]}},"evals":[],"jsHooks":[]}</script>
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
## R version 4.0.5 (2021-03-31)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 19043)
## 
## Matrix products: default
## 
## locale:
## [1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252    LC_MONETARY=English_United Kingdom.1252 LC_NUMERIC=C                           
## [5] LC_TIME=English_United Kingdom.1252    
## 
## attached base packages:
## [1] parallel  stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] KrigR_0.1.2       httr_1.4.2        stars_0.5-3       abind_1.4-5       fasterize_1.0.3   sf_1.0-0          lubridate_1.7.10  automap_1.0-14    doSNOW_1.0.19     snow_0.4-3       
## [11] doParallel_1.0.16 iterators_1.0.13  foreach_1.5.1     rgdal_1.5-23      raster_3.4-13     sp_1.4-5          stringr_1.4.0     keyring_1.2.0     ecmwfr_1.3.0      ncdf4_1.17       
## [21] leaflet_2.0.4.1  
## 
## loaded via a namespace (and not attached):
##  [1] sass_0.3.1         jsonlite_1.7.2     R.utils_2.10.1     bslib_0.2.4        assertthat_0.2.1   yaml_2.2.1         pillar_1.6.0       backports_1.2.1    lattice_0.20-41    glue_1.4.2        
## [11] digest_0.6.27      htmltools_0.5.1.1  R.oo_1.24.0        plyr_1.8.6         pkgconfig_2.0.3    bookdown_0.22      purrr_0.3.4        intervals_0.15.2   gstat_2.0-7        tibble_3.1.1      
## [21] proxy_0.4-25       styler_1.4.1       generics_0.1.0     ellipsis_0.3.2     cachem_1.0.4       magrittr_2.0.1     crayon_1.4.1       memoise_2.0.0      evaluate_0.14      R.methodsS3_1.8.1 
## [31] fansi_0.4.2        R.cache_0.14.0     lwgeom_0.2-6       xts_0.12.1         class_7.3-18       FNN_1.1.3          blogdown_1.3       tools_4.0.5        lifecycle_1.0.0    compiler_4.0.5    
## [41] jquerylib_0.1.4    e1071_1.7-6        spacetime_1.2-4    rlang_0.4.11       classInt_0.4-3     units_0.7-2        grid_4.0.5         htmlwidgets_1.5.3  crosstalk_1.1.1    rmarkdown_2.7     
## [51] codetools_0.2-18   DBI_1.1.1          reshape_0.8.8      rematch2_2.1.2     R6_2.5.0           zoo_1.8-9          knitr_1.33         dplyr_1.0.5        fastmap_1.1.0      utf8_1.2.1        
## [61] KernSmooth_2.23-18 stringi_1.5.3      Rcpp_1.0.7         vctrs_0.3.7        tidyselect_1.1.0   xfun_0.22
```
