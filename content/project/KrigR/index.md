---
date: "2020-12-28T00:00:00Z"
authors:
- ErikKusch
external_link: ""
image:
  caption: KrigR Workflow
  focal_point: Smart
links:
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://github.com/ErikKusch/KrigR
- icon: file-powerpoint
  icon_pack: fas
  name: Slides
  url: /talks/KrigRDemo.pptx
- icon: file-powerpoint
  icon_pack: fas
  name: Poster
  url: /talks/2022_05_Clim4EcolPoster.pdf
- icon: researchgate
  icon_pack: fab
  name: Updates
  url: https://www.researchgate.net/project/KrigR-Downloading-and-Downscaling-of-ERA5-data-using-R
- icon: code-branch
  icon_pack: fas
  name: Workshop Material
  url: /courses/krigr/
- icon: youtube
  icon_pack: fab
  name: Workshop Recording
  url: https://www.youtube.com/watch?v=wwb107L4wVw&ab_channel=ErikKusch
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/KuschErik
# slides: example
summary: An `R` package designed for intuitive downloading, aggregating, and statistical downscaling of ERA5(-Land) data.
tags:
- Climate Data
- Statistical Downscaling
- KrigR
- PhD
- Active
title: KrigR - Downloading and Downscaling of ERA5(-Land) data using R
url_code: ""
url_pdf: ""
url_slides: ""
url_video: ""
---


# Motivation
 
Contemporary studies of remote sensing and macroecology largely rely on legacy climate data which is surpassed by state-of-the-art climate reanalysis data sets such as the European Centre for Medium-range Weather Forecasts ReAnalysis 5 (ERA5) data catalogue which represents the forefront of advances in data assimilation and climate modelling.

Using these data sets within `R` – the most prominent statistical software in macroecology – is a complicated task that involves downloading of data via shell scripts, reformatting of coordinate system, and might even require rescaling of the climate data.

In order to make the use of ERA5(-Land) in future analyses more streamlined, I am developing an `R` Package (`KrigR`) which will handle downloading and reformatting of ERA5(-Land) data. Furthermore, this package offers rescaling capabilities via the Kriging functionality of the `automap` package whilst enabling multi-core processing for faster computation of time-series data.


# Description

The superiority of ERA5(-Land) data over legacy data sets is largely due to:

1. The volume of observational data used to create the ERA5 product. This includes a large volume of satellite data, ground-based weather station/independent institute data collection efforts, and other station data from a wide variety of data providers. This is in contrast to gridded observational datasets which are often characterised by their individual biases in sampling, coverage, and choice of interpolation and homogenization to create a gridded product.  
2. The advances in data assimilation procedures. Data assimilation for geophysical application has greatly developed as a field in recent decades. This has included fundamental methodological advancements, such as the development of the ensemble Kalman filter, as well developments specific to geophysical application of data assimilation, such as approaches to localisation.  
3. The complexity of the underlying models. Reanalysis products have been widely used to shed light on physical processes. ERA5 was created using the ECMWF’s integrated forecasting system which is the world’s best forecast model and is continuously developed using the latest understanding of the physics of the climate system.  

`KrigR` is a tool to streamline and standardise the implementation of state-of-the-art ERA5(-Land) data and time series in large-scale analyses. As such, the `R` Package includes the following functionality:

- Download functions for:
  - ERA5(-Land) data
  - GMTED2010 covariate data (kriging will not be limited to GMTED2010 alone)
- Preprocessing of ERA5(-Land) data
- Statistical downscaling of ERA5(-Land) data using kriging methodology
- Selection of regions by shapefiles or extents
- Variable list with guidelines for statistical downscaling (this is currently being developed)

`KrigR` downloads ERA5(-Land) upon having been provided with the required ECMWF API key and includes several self-checking statements to avoid the most common issues with the kriging methodology.
 
Users are be able to start the process of the `KrigR` workflow at any given function of the package, but it is recommended to let `KrigR` handle the entire workflow as intended.

