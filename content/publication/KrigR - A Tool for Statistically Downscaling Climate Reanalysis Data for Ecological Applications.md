---
title: KrigR – A tool for downloading and statistically downscaling climate reanalysis data
abstract: Advances in climate science have rendered obsolete the gridded observation data widely used in downstream applications. Novel climate reanalysis products outperform legacy data products in accuracy, temporal resolution, and provision of uncertainty metrics. Consequently, there is an urgent need to develop a workflow through which to integrate these improved data into biological analyses. The ERA5 product family (ERA5 and ERA5-Land) are the latest and most advanced global reanalysis products created by the European Center for Medium-range Weather Forecasting (ECMWF). These data products offer up to 83 essential climate variables (ECVs) at hourly intervals for the time-period of 1981 to today with preliminary back-extensions being available for 1950-1981. Spatial resolutions range from 30x30km (ERA5) to 11x11km (ERA5-Land) and can be statistically downscaled to study-requirements at finer spatial resolutions. Kriging is one such method to interpolate data to finer resolutions and has the advantages that one can leverage additional covariate information and obtain the uncertainty associated with the downscaling. The KrigR R-package enables users to (1) download ERA5(-Land) climate reanalysis data for a user-specified region, and time-period, (2) aggregate these climate products to desired temporal resolutions and metrics, (3) acquire topographical co-variates, and (4) statistically downscale spatial data to a user-specified resolution using co-variate data via kriging. KrigR can execute all these tasks in a single function call, thus enabling the user to obtain any of 83 (ERA5) / 50 (ERA5-Land) climate variables at high spatial and temporal resolution with a single R-command. Additionally, KrigR contains functionality for computation of bioclimatic variables and aggregate metrics from the variables offered by ERA5(-Land). This R-package provides an easy-to-implement workflow for implementation of state-of-the-art climate data while avoiding issues of storage limitations at high temporal and spatial resolutions by providing data according to user-needs rather than in global data sets. Consequently, KrigR provides a toolbox to obtain a wide range of tailored climate data at unprecedented combinations of high temporal and spatial resolutions thus enabling the use of world-leading climate data through the R-interface and beyond.
authors:
- ErikKusch
- Richard Davy
date: "2022-01-07T00:00:00Z"
doi: ""
featured: false
projects:
- KrigR
publication: "*Environmental Research Letters*"
# publication_short: ""
publication_types: # 1 = conference paper, 2 = journal article, 3 = preprint, 4 = conference paper, 5 = book, 6 = Book section, 7 = Thesis, 8 = patent
- "2"
# publishDate: "2022-01-07T00:00:00Z"
tags:
 - Climate Data
 - Statistical Downscaling
 - KrigR
# url_code: https://github.com/ErikKusch/KrigR
# url_dataset: ''
url_pdf: https://doi.org/10.1088/1748-9326/ac48b3
# url_poster: ""
# url_slides: /post/krigr-mats/KrigRSlides.rar
# url_source: '#'
# url_video: https://www.youtube.com/watch?v=wwb107L4wVw&ab_channel=ErikKusch

summary: An R Package aimed at end-users of state-of-the-art climate reanalysis data to streamline retrieval, pre-processing, and statistical interpolation of ERA5(-Land) data.
---
