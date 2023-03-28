---
title: Reconciling high resolution climate datasets using KrigR
abstract: There is an increasing need for high spatial and temporal resolution climate data for the wide community of researchers interested in climate change and its consequences. Currently, there is a large mismatch between the spatial resolutions of global climate model and reanalysis datasets (at best around 0.25o and 0.1o respectively) and the resolutions needed by many end-users of these datasets, which are typically on the scale of 30 arcseconds (~900m). This need for improved spatial resolution in climate datasets has motivated several groups to statistically downscale various combinations of observational or reanalysis datasets. However, the variety of downscaling methods and inputs used makes it difficult to reconcile the resultant differences between these high-resolution datasets. Here we make use of the KrigR R-package to statistically downscale the world-leading ERA5(-Land) reanalysis data using kriging. We show that kriging can accurately recover spatial heterogeneity of climate data given strong relationships with co-variates; that by preserving the uncertainty associated with the statistical downscaling, one can investigate and account for confidence in high-resolution climate data; and that the statistical uncertainty provided by KrigR can explain much of the difference between widely used high resolution climate datasets (CHELSA, TerraClimate, and WorldClim2) depending on variable, timescale, and region. This demonstrates the advantages of using KrigR to generate customized high spatial and/or temporal resolution climate data.
authors:
- Richard Davy
- ErikKusch
date: "2021-11-16T00:00:00Z"
doi: ""
featured: false
projects:
- KrigR
publication: "*Environmental Research Letters*"
# publication_short: ""
publication_types: # 1 = conference paper, 2 = journal article, 3 = preprint, 4 = conference paper, 5 = book, 6 = Book section, 7 = Thesis, 8 = patent
- "2"
publishDate: "2021-11-16T00:00:00Z"
tags:
 - Climate Data
 - Statistical Downscaling
 - KrigR
# url_code: https://github.com/ErikKusch/KrigR
# url_dataset: ''
url_pdf: https://doi.org/10.1088/1748-9326/ac39bf
# url_poster: ""
# url_slides: /post/krigr-mats/KrigRSlides.rar
# url_source: '#'
# url_video: https://www.youtube.com/watch?v=wwb107L4wVw&ab_channel=ErikKusch

summary: Exploration of the usage of KrigR and implications for the wider field of climate data products for the use in Life Science research.
---
