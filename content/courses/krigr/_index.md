---
title: KrigR Workshop
linktitle: Motivation & Workshop
slug: overview
date: 2021-01-01
authors:
- ErikKusch
external_link: ""
summary: Workshop material for getting started and becoming adept at using the `R` Package `KrigR`.
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
math: true
type: docs
toc: true 
menu:
  krigr:
    parent: Introduction
    weight: 1
---

{{% alert danger %}}
Please note that `KrigR` is currently undergoing major redevelopment with respect to updating functionality to remove deprecated dependencies and to enable operations targeting the new CDS. The workshop material presented here is being redeveloped at the same time. At present, I recommend to use the development version of `KrigR` - the workshop material detailing setup and quickguide have already been reworked to reference this version of the package which will soon become the new main version of `KrigR`.
{{% /alert %}}

<img align="right" width="90" src="overview/CDSLogo.png" />

The [Copernicus Climate Data Store (CDS)](https://cds.climate.copernicus.eu/) host a variety of data products - like world-leading climate reanalysis products - which provide more accurate environmental information at higher temporal resolution than traditional climate data products used in downstream applications in ecology, anthropology, macroeconomics, epidemeology, and many others.

<img align="left" width="125" src="overview/KrigRLogo.png" />

The `KrigR` R-package reduces barriers for users to (a) download CDS-hosted data (b) aggregate these data to desired temporal resolutions and metrics, (c) acquire and prepare co-variates matching these products, and (d) statistically downscale spatial data using co-variates via kriging which allows for integration of data uncertainty with interpolation uncertainty for improved data reliability indicators.

The `KrigR` workflow allows highly flexible data product creation for unparalleled aligning of data set specifications with research objectives. Climate and weather products obtained through `KrigR` offer great potential for quantification of exposure to extreme events due to their combinations of high spatial and temporal resolutions. Lastly, `KrigR` can incorporate third-party data which enables generation of high-resolution, bias-corrected climate projection data allowing for forecasting at high-resolution.

I have created `KrigR` for download, temporal aggregation, masking, and statistically interpolating ERA5(-Land) data. We first presented the R-Package (`KrigR`) itself in [Kusch,Davy, 2022](https://doi.org/10.1088/1748-9326/ac48b3). In [Davy, Kusch, 2021](https://doi.org/10.1088/1748-9326/ac39bf) published previously my colleague and I demonstrated how data obtained through the `KrigR` framework relate to previously offered ready-made data sets and why we strongly believe that data handling pipelines (rather than ready-made data sets) are the way forward for downstream analyses.

Throughout this workshop material, I walk you through the functionality, use-cases, and quality of life aspects with `KrigR`.


<!-- ## Recording Availability
A recording of me presenting an earlier version of this workshop (with much of the contents herein) can be found on [YouTube](https://www.youtube.com/watch?v=wwb107L4wVw&ab_channel=ErikKusch). --->

## Learning Goals 

Throughout this workshop, you will learn how to:  

- Query downloads of state-of-the-art climate data using `KrigR`  
- Use the data processing functionality contained in `KrigR` to achieve data at desired spatial scales and temporal resolutions  
- Obtain and process covariate data for use in statistical interpolation via kriging  
- Carry out kriging using the `KrigR` package  
<!-- - Use `KrigR` to obtain bioclimatic data and what to consider in doing so
- Use third-party data with the `KrigR` toolbox  
- Establish high spatial resolution, bias-corrected climate projections using `KrigR` --->


## Issues & Feature Requests

If you run into any error messages, bugs, want to inquire about some `KrigR` functionality, or request new functionality, please do so by registering an [issue on the `KrigR` GitHub](https://github.com/ErikKusch/KrigR/issues/new/choose). Please, **refrain from sending these via E-mail**.

## Disclaimer

If you find any typos in my material, are unhappy with some of what or how I am presenting or simply unclear about thing, do not hesitate to [contact me](/about/#contact).

All the best,  
Erik
