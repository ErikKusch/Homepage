---
title: "Development Goals"
author: Erik Kusch
date: '2022-05-26'
slug: outlook
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: "The future directions for `KrigR`"
summary: 'The future directions for `KrigR`.'
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
    parent: Introduction
    weight: 8
---



{{% hint danger %}}
The current release of `KrigR` is stable, but it is still undergoing development. Any and all feedback you can give us is more than welcome.
{{% /hint %}}

{{% hint info %}}
I am currently in the progress of closing out my [PhD Project](/project/phd-packages/) and am thus unable to develop `KrigR` right now. If you, or someone you know, would happen to be interested in hiring me to do so after my PhD, I'd be more than happy for that opportunity.
{{% /hint %}}


## Data Objects to be included in `KrigR`:

In the future, we hope to ship `KrigR` with a few in-built data sets for easier demoing of the package: 
- ERA5-Land data  
- GMTED 2010 data  

To improve user-friendliness of the `download_ERA()` experience, we plan to ship `KrigR` with metadata files for each data set containing:  
- Name of dataset  
- Dataset spatial extent  
- Time-window of dataset  
- Subsets of dataset (e.g. monthly averaged reanalysis, vs. monthly averaged reanalysis by hour of the day)  
- Temporal resolution of dataset and subsets  
- Variables contained in dataset  
- Variable-dependant issues (i.e. missing values for starting intervals of time series, cumulative records)  
- Obligatory and optional arguments for API call  
- Citation key  
- Link to data set  

These metadata files will be used for sanity checking of download request before execution, automatic fixes of first-hour issues and the like, easier request building and piping through `ecmwfr` behind the scenes, and will be possible to query to give users an overview of datasets.

## Function Changes

`KrigR` works as intended, but there are some changes to the core functions of `KrigR` which we have set our eyes on in an effort to improve efficiency and user-friendliness:  

### General Function Changes
- Try `terra` functions instead of `raster` functions for a potential increase in computational speed  
- Check if `tidyverse` is loaded and multiple cores are specified. Unload tidyverse packages at the beginning of `KrigR` functions and reload them when code exits with `on.exit()`
- Enable saving of raster in non-NETCDF formats  

### Download Function

- Support additional ECMWF products (e.g.: CMIP6 climate projections)  
- Download by hours of date, too  
- Export NETCDFS with layer names according to desired time-window and temporal resolution  
- Make temporal aggregation dependant on dataset metadata file  
- Ensemble spread download for data sets which offer ensembles for uncertainty metrics  
- Optional argument to return extracted values for points in data frame with arguments passed on to `raster::extract()` function  
- Temporal aggregation time windows and entire time series match check before downloading  
- Investigate ways to reduce the two month data download for a single month of cumulative records  
- Toggle `SingularDL` on intelligently depending on download specification by default  
- Multi-core temporal aggregation  
- Make it recognise tibbles or spatialpoints for points  
- Query to CDS download queue?  
- Cumulative back calculation function  
- Check for cumulatively stored variables and cumulative back-calculation  

### Covariate Function	

- Include query to HWSD and Soil Property covariates  
- Aggregation and preparation of user-provided covariates (provided at target resolution)  
	
### Kriging Function

- Kriging recommendation table  
- Covariates that vary over time  
- Duration timer into call list  
	
## Shiny / Web-Client Application

To further reduce barrier of entry to the use of `KrigR`, we intend to, in the future, ship `KrigR` with a shiny app with which to create download scripts from a more visual interface.

- Browser-based creation of download script for `KrigR`  
- Time-line with coloured sections according to chosen time-window and temporal resolution  
- Map for Visualisation of dataset extent  
- Map for Extent selection  
- Map for Polygon shapefile creation  
- Map for Point selection by clicking or typing coordinates out  
