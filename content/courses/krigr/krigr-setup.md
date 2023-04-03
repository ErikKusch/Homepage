---
title: "Setting up KrigR"
author: Erik Kusch
date: '2022-05-26'
slug: setup
categories:
  - KrigR
  - Climate Data
tags:
  - Climate Data
  - Statistical Downscaling
  - KrigR
subtitle: "Hitting the Ground Running with `KrigR`"
summary: 'Set-up instructions for `KrigR` and preparations for the workshop.'
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
    parent: Quick Start
    weight: 1
weight: 1
---



<!-- # Setting Things Up & Preparing the Workshop -->
## Installing `KrigR`
First of all, we need to install `KrigR`. 

{{% alert warning %}}
Until we have implemented our [development ideas and goals](/courses//krigr/outlook/), `KrigR` will not be submitted to [CRAN](https://cran.r-project.org/) to avoid the hassle of updating an already accepted package.
{{% /alert %}}

{{% alert info %}}
For the time being, `KrigR` is only available through the associated [GitHub](https://github.com/ErikKusch/KrigR) repository.
{{% /alert %}}

<!-- {{% alert danger %}} -->
<!-- Example text that *may* contain **markdown** `markup`. -->
<!-- {{% /alert %}} -->

<!-- {{% alert normal %}} -->
<!-- Example text that *may* contain **markdown** `markup`. -->
<!-- {{% /alert %}} -->

Here, we use the `devtools` package within `R` to get access to the `install_github()` function. For this to run, we need to tell `R` to not stop the installation from GitHub as soon as a warning is produced. This would stop the installation process as early as one of the `KrigR` dependencies hits a warning as benign as `Package XYZ was built under R Version X.X.X` which can usually be ignored safely. 

Subsequently, `KrigR` can be installed and loaded as follows:


```r
Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS = "true")
devtools::install_github("https://github.com/ErikKusch/KrigR")
library(KrigR)
```


## CDS API Access
Before you can access [Climate Data Store](https://cds.climate.copernicus.eu/) (CDS) products through `KrigR`, you need to open up an account at the CDS and [create an API key](https://cds.climate.copernicus.eu/api-how-to). 

Once you have done so, we recommend you register the user ID and API Key as characters as seen below (this will match the naming scheme in our workshop material):


```r
API_User <- 12345
API_Key <- "YourApiKeyGoesHereAsACharacterString"
```

{{% alert warning %}}
Don't forget to sign the [terms and conditions](https://cds.climate.copernicus.eu/cdsapp/#!/terms/licence-to-use-copernicus-products) of the CDS!
{{% /alert %}}

{{% alert normal %}}
You are now **ready** for `KrigR`.
{{% /alert %}}

If this is your **first contact** with `KrigR`, we recommend strongly you **follow the workshop material in order**. If you **return to** `KrigR` with specific questions or ideas, we recommend you make use of the **search function** at the top left of this page. If you are short on time, the [quick start](/courses/krigr/quickstart/) guide will be useful to you.

<!-- ## Session Info -->
<!-- ```{r, echo = FALSE} -->
<!-- sessionInfo() -->
<!-- ``` -->
