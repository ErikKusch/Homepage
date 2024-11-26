---
title: "Setting up rgbif"
author: Erik Kusch
date: '2023-05-21'
slug: setup
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: "Ensuring full `rgbif` Functionality"
summary: 'Set-up instructions for `rgbif` and preparations for the workshop.'
authors: []
lastmod: '2023-05-21T20:00:00+01:00'
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
    parent: Introduction
    weight: 3
weight: 3
---



`rgbif` enables programmatic access to GBIF mediated data via its API.

## Installing `rgbif`

Before we can use the `R` package, we need to install it. In the simplest way this can be done with the `install.packages(...)` command:

``` r
install.packages("rgbif")
```

Following successful installation of `rgbif`, we simply need to load it into our `R` session to make its functionality available to use via the `library(...)` command:

``` r
library(rgbif)
```

{{% alert success %}}
You can now use for `rgbif` functionality.
{{% /alert %}}


{{% alert warning %}}
I **strongly** suggest **never** installing and loading packages this way in a script that is meant to be reproducible. Using the `install.packages(...)` command forces installation of an `R` package irrespective of whether it is already installed or not which leads to three distinct issues:
1. Already installed versions of `R` packages are overwritten potentially breaking pre-existing scripts.
2. Package installation time is wasted time if packages are already installed ion the first place.
3. Package installation is dependent on internet connection making offline sourcing of scripts impossible.

{{% alert info %}}
<details>
  <summary>For a user-defined function that avoids these issues, click here:</summary>
    Below, I create a user defined function called `install.load.package(...)`. This function takes as an input the name of an `R` package just like the `install.packages(...)` function does. Instead of simply forcing package installation, however, `install.load.package(...)` checks whether the package in question is already installed and only carries out installation if it isn't. Before concluding, `install.load.package(...)` loads the package.

``` r
## Custom install & load function
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, repos = "http://cran.us.r-project.org")
  }
  require(x, character.only = TRUE)
}
```
  To further streamline package installation and loading, we can use `sapply(...)` to execute the `install.load.package(...)` function sequentially for all the packages we desire or require:

``` r
## names of packages we want installed (if not installed yet) and loaded
package_vec <- c(
  "rgbif"
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
## rgbif 
##  TRUE
```
</details> 
{{% /alert %}}
{{% /alert %}}

## GBIF Account

`rgbif` functionality can be used without registering an account at [GBIF](https://www.gbif.org/). However, doing so imposes some crucial limitations:
1. Downloads are capped at 100,000 records per download
2. Once downloaded, GBIF mediated data needs to be queried again for re-download
3. Accrediting and referencing GBIF mediated data becomes difficult

Having a GBIF account and using it for download querying resolves all these limitations. So, let's get you registered with GBIF.

### Opening an Account at GBIF

First, navigate to [gbif.org](https://www.gbif.org/) and click the **Login** button:
<a href="https://www.gbif.org/" target="_blank"><img src="/courses/gbif/GBIFHome.jpeg" width="900"/></a>

Chose your preferred method of registering your account:
<img src="/courses/gbif/GBIFRegister.png" width="900"/>

Connect your [ORCID](https://orcid.org/). This step is not strictly necessary, but will make subsequent logins very straightforward and streamline citation and data use tracking:
<img src="/courses/gbif/GBIF_ORCID.jpeg" width="900"/>

### Registering your GBIF Account in `R`

Lastly, we need to tell your `R` session about your GBIF credentials. This can either be done for each individual function call executed from `rgbif` to the GBIF API, or set once per `R` session. I prefer the latter, so let's register your GBIF credentials as follows:


``` r
options(gbif_user = "my gbif username")
options(gbif_email = "my registred gbif e-mail")
options(gbif_pwd = "my gbif password")
```

{{% alert success %}}
You are now **ready** for the full suite of functionality of `rgbif`.
{{% /alert %}}

<!-- ## Session Info -->
<!-- ```{r, echo = FALSE} -->
<!-- sessionInfo() -->
<!-- ``` -->
