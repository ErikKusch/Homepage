---
date: "2020-12-28T00:00:00Z"
authors:
- ErikKusch
external_link: ""
image:
  caption: Vegetation Memory Components
  focal_point: Smart
links:
- icon: file
  icon_pack: fas
  name: Kusch & Davy, Seddon, 2022
  url: publication/vegetation-memory-effects-and-their-association-with-vegetation-resilience-in-global-drylands/
- icon: file-pdf
  icon_pack: fas
  name: Poster
  url: https://github.com/ErikKusch/Homepage/raw/master/static/talks/2020_ISEC_Poster.pdf
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://github.com/ErikKusch/Vegetation-Memory
- icon: researchgate
  icon_pack: fab
  name: Updates
  url: https://www.researchgate.net/project/Varying-Relationships-between-Vegetation-Memory-and-Climate-across-Global-Drylands
# slides: example
summary: Vegetation memory has been proposed as a proxy for ecosystem resilience. Here, I investigate how well this proxy captures processes of vegetation performance.
tags:
- Resilience
- Statistical Downscaling
- KrigR
- Archived
title: Vegetation Memory across Global Dryland Regions
url_code: ""
url_pdf: ""
url_poster: ""
url_slides: ""
url_video: ""
---

# Motivation

Vegetation memory describes the effect of antecedent environmental and ecosystem states on ecosystem state in the present and has been used as an important proxy for ecosystem recovery rates potentially a key component of vegetation resilience, at a global scale. In particular, strong vegetation memory effects have been identified in dryland regions coinciding with decreased vegetation sensitivity towards climatological drivers.

Here, we aim to test the components and drivers of vegetation memory in dryland regions using state-of the-art climate reanalysis data and refined approaches to identify vegetation-memory characteristics across global dryland regions. We show that (1) dryland regions are characterised by strong vegetation memory (intrinsic and extrinsic), (2) it is possible to distinguish intrinsic and extrinsic vegetation memory to a hitherto unachieved degree using climate reanalysis data sets, (3) the link between intrinsic vegetation memory and resilience may be an oversimplification, and (4) dryland vegetation does not react to bioclimatic forcing in the same way across the Earth.

# Description
GIMMS NDVI 3g data was used as a proxy of vegetation response in the dryland study regions between January 1982 and December 2015. The NDVI is a compound vegetation index made up from reflectance in the red and near-infrared reflectance bands.
For independent climate data in this study, we used European Centre for Medium-range Weather Forecasts ReAnalysis 5 (ERA5) data from the European Centre for Medium-Range Weather Forecasts (ECMWF). ERA5 data is available for hourly intervals (which we assembled to monthly time steps) from 1950 to present day at a 30km × 30km spatial resolution of global coverage making the resolution of ERA5 and AVHRR-based GIMMS NDVI 3g incompatible. We resolved this issue by statistically downscaling ERA5 data using the kriging methodology (`KrigR` package of my [KrigR - Downloading and Downscaling of ERA5(-Land) data using R]({{< ref "project/KrigR" >}}) project).
 
To assess the relative importance of intrinsic memory and extrinsic climate forcing we used a linear modelling approach akin to DeKeersmaecker et al, 2015. We use NDVI anomalies on a one-month lag, air temperature (Tair) and soil moisture (Qsoil) data on different temporal lags to model anomalies of monthly NDVI values over three decades. Due to issues of multi-collinearity, we do so using a principal component regression approach.
 
The results contain information about relative importance of vegetation memory components, their temporal lags,and are presented in the context of contemporary vegetation memory and sensitivity literature.
 
Our findings demonstrate novel observations of vegetation memory patterns across dryland regions such as regional differences of processes forming vegetation memory capabilities. Consequently, this study provides a helpful stepping stone for refining and combining already existing methodology which could, in turn, generate important knowledge of ecosystem functioning and resilience.
