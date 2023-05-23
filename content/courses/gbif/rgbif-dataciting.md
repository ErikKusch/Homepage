---
title: "Citing GBIF Data"
author: Erik Kusch
date: '2023-05-21'
slug: dataciting
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: "Referencing GBIF Mediated Data"
summary: 'A quick overview of data retrieval with `rgbif`.'
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
    parent: Practical Exercises
    weight: 8
weight: 8
---



{{% alert normal %}}
<details>
  <summary>Preamble, Package-Loading, and GBIF API Credential Registering (click here):</summary>

```r
## Custom install & load function
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, repos = "http://cran.us.r-project.org")
  }
  require(x, character.only = TRUE)
}
## names of packages we want installed (if not installed yet) and loaded
package_vec <- c(
  "rgbif",
  "ggplot2" # for visualisation
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
##   rgbif ggplot2 
##    TRUE    TRUE
```

```r
options(gbif_user = "my gbif username")
options(gbif_email = "my registred gbif e-mail")
options(gbif_pwd = "my gbif password")
```
</details> 
{{% /alert %}}

First, we obtain and load the data use for our publication like such:



```r
# Download query
res <- occ_download(
  pred("taxonKey", sp_key),
  pred_in("basisOfRecord", c("HUMAN_OBSERVATION")),
  pred("country", "NO"),
  pred("hasCoordinate", TRUE),
  pred_gte("year", 2000),
  pred_lte("year", 2022)
)
# Downloading and Loading
res_meta <- occ_download_wait(res, status_ping = 5, curlopts = list(), quiet = FALSE)
res_get <- occ_download_get(res)
res_data <- occ_download_import(res_get)
# Limiting data according to quality control
preci_data <- res_data[which(res_data$coordinateUncertaintyInMeters < 10), ]
# Subsetting data for desired variables and data markers
data_subset <- preci_data[
  ,
  c("scientificName", "decimalLongitude", "decimalLatitude", "basisOfRecord", "year", "month", "day", "eventDate", "countryCode", "municipality", "taxonKey", "species", "catalogNumber", "hasGeospatialIssues", "hasCoordinate", "datasetKey")
]
```

Now all we need to worry about is properly accrediting data sources to make our data usage fair and reproducible.

## Finding Download Citation

Much like previous steps of this workshop, identifying the correct citation for a given download from GBIF can be done via:
1. GBIF Portal
2. `rgbif` functionality

### GBIF Portal 

To figure out how to reference a GBIF mediated set of data records you may head to the [download tab](https://www.gbif.org/user/download) of the GBIF portal where, once in the detailed overview of an individual download job, you will find proper accrediation instructions right at the top:

<img src="/courses/gbif/gbif-download4.png" width="100%"/></a>

I would like to caution against this practise as the download tab can become a bit cluttered when having a long history of asking GBIF for similar downloads.

### `rgbif`

{{% alert success %}}
This is the **preferred way of figuring out correct GBIF mediated data citation**.
{{% /alert %}}

To avoid the pitfalls of manual data citation discovery, `rgbif` download metadata make available to us directly a DOI which can be used for refrencing our data:


```r
paste("GBIF Occurrence Download", occ_download_meta(res)$doi, "accessed via GBIF.org on", Sys.Date())
```
```
## [1] "GBIF Occurrence Download 10.15468/dl.awgk9s accessed via GBIF.org on 2023-05-22"
```

With this, you are ready to reference the data you use.

## Derived Datasets

{{% alert warning %}}
When **additionally** (heavily) **filtering or subsetting** a GBIF download locally, it is **best to** not **cite** the download itself, but rather a **derived data set**.
{{% /alert %}}

Derived datasets are citable records of GBIF-mediated occurrence data derived either from:
- a GBIF.org download that has been filtered/reduced significantly, or
- data accessed through a cloud service, e.g. Microsoft AI for Earth (Azure), or
- data obtained by any means for which no DOI was assigned, but one is required (e.g. third-party tools accessing the GBIF search API)

For our purposes, we have used a heavily subsetted data download - just look at the number of records in the original and the subsetted data:

```r
ggplot(data.frame(
  Records = c(nrow(data_subset), nrow(res_data)),
  Data = c("Original", "Subset")
), aes(y = Data, x = Records)) +
  geom_bar(stat = "identity", fill = "#4f004e") +
  theme_bw(base_size = 12)
```

<img src="rgbif-dataciting_files/figure-html/unnamed-chunk-2-1.png" width="1440" />

To correctly reference the underlying data sets mediated by GBIF and contributing to our final dataset, we should register a derived data set. When created, a derived dataset is assigned a unique DOI that can be used to cite the data. To create a derived dataset you will need to authenticate using a GBIF.org account and provide:  
- a title of the dataset,
- a list of the GBIF datasets (by DOI or datasetKey) from which the data originated, ideally with counts of how many records each dataset contributed,
- a persistent URL of where the extracted dataset can be accessed,
- a description of how the dataset was prepared,
- (optional) the GBIF download DOI, if the dataset is derived from an existing download , and
- (optional) a date for when the derived dataset should be registered if not immediately .

Arguably, the most important aspect here is the list of GBIF datasets and the counts of data used per dataset. First, let's isolate how many datasets contributed to our original data and the subsetted, final data:

```r
## Original
length(unique(res_data$datasetKey))
```

```
## [1] 47
```

```r
## Subsetted
length(unique(data_subset$datasetKey))
```

```
## [1] 14
```

There is a signifcant decrease in number of datasets which make up our final data product post-subsetting. Let us visualise how the data records are spread across the individual datasets per data product we have handled:

```r
## Originally downloaded abundances per dataset
plot_data <- data.frame(table(res_data$datasetKey))
ggplot(
  plot_data,
  aes(
    x = factor(Var1, levels = plot_data$Var1[order(plot_data$Freq, decreasing = TRUE)]),
    y = Freq
  )
) +
  geom_col(color = "black", fill = "forestgreen") +
  labs(
    y = "Abundance", x = "Dataset",
    title = paste0("Originally downloaded abundances per dataset (", occ_download_meta(res)$doi, ")")
  ) +
  theme_bw(base_size = 21) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
```

<img src="rgbif-dataciting_files/figure-html/unnamed-chunk-4-1.png" width="1440" />

```r
## Subsetted abundances per dataset
plot_subset <- data.frame(table(data_subset$datasetKey))
ggplot(
  plot_subset,
  aes(
    x = factor(Var1, levels = plot_subset$Var1[order(plot_subset$Freq, decreasing = TRUE)]),
    y = Freq
  )
) +
  geom_col(color = "black", fill = "darkred") +
  labs(y = "Abundance", x = "Dataset", title = "Subsetted abundances per dataset") +
  theme_bw(base_size = 21) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
```

<img src="rgbif-dataciting_files/figure-html/unnamed-chunk-4-2.png" width="1440" />

Subsequently, to prepare a potential query to GBIF to establish a derived data set for us, we can tabulate the counts of records per dataset key as follows:

```r
knitr::kable(table(data_subset$datasetKey))
```



|Var1                                 | Freq|
|:------------------------------------|----:|
|09c38deb-8674-446e-8be8-3347f6c094ef |  133|
|0efbb3b3-6473-414a-af91-cdbcbcd8aba1 |    1|
|14d5676a-2c54-4f94-9023-1e8dcd822aa0 |   71|
|3fdf4093-6cb4-4ca6-b329-b12e96d57342 |    3|
|50c9509d-22c7-4a22-a47d-8c48425ef4a7 |  214|
|520909f1-dbca-411e-996c-448d87c6a700 |    1|
|78ab5416-bf56-4714-a2bf-096b16f0e1d8 |  231|
|7a3679ef-5582-4aaa-81f0-8c2545cafc81 |    7|
|88ea9eca-96ad-4a5a-8a01-99a4acabe050 |    4|
|8a863029-f435-446a-821e-275f4f641165 |   67|
|9678e1a6-b1c4-4e86-9d26-ebb169338655 |  503|
|a12cba4c-c620-4e76-aa22-0ec988824b6d |   12|
|ae77cf87-0f7f-4a08-91cc-5d55230fb421 |   12|
|b124e1e0-4755-430f-9eab-894f25a9b59c | 5543|

Finally, we can head to the [registration for derived data sets](https://www.gbif.org/derived-dataset/register) at GBIF and supply our information:

<img src="/courses/gbif/gbif-derived.png" width="100%"/></a>

{{% alert success %}}
You are finished - you should now be able to find relevant data for your requirements on GBIF, download said data, handle and subset it according to your needs, and now how to reference back to the data obtained and used in your final report.
{{% /alert %}}

## Session Info

```
## R version 4.3.0 (2023-04-21)
## Platform: x86_64-apple-darwin20 (64-bit)
## Running under: macOS Ventura 13.3.1
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRblas.0.dylib 
## LAPACK: /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRlapack.dylib;  LAPACK version 3.11.0
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## time zone: Europe/Oslo
## tzcode source: internal
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] ggplot2_3.4.2 rgbif_3.7.7  
## 
## loaded via a namespace (and not attached):
##  [1] styler_1.9.1      sass_0.4.6        utf8_1.2.3        generics_0.1.3   
##  [5] xml2_1.3.4        blogdown_1.16     stringi_1.7.12    httpcode_0.3.0   
##  [9] digest_0.6.31     magrittr_2.0.3    evaluate_0.20     grid_4.3.0       
## [13] bookdown_0.34     fastmap_1.1.1     R.oo_1.25.0       R.cache_0.16.0   
## [17] plyr_1.8.8        jsonlite_1.8.4    R.utils_2.12.2    whisker_0.4.1    
## [21] crul_1.4.0        urltools_1.7.3    httr_1.4.5        purrr_1.0.1      
## [25] fansi_1.0.4       scales_1.2.1      oai_0.4.0         lazyeval_0.2.2   
## [29] jquerylib_0.1.4   cli_3.6.1         rlang_1.1.1       triebeard_0.4.1  
## [33] R.methodsS3_1.8.2 bit64_4.0.5       munsell_0.5.0     withr_2.5.0      
## [37] cachem_1.0.8      yaml_2.3.7        tools_4.3.0       dplyr_1.1.2      
## [41] colorspace_2.1-0  curl_5.0.0        vctrs_0.6.2       R6_2.5.1         
## [45] lifecycle_1.0.3   stringr_1.5.0     bit_4.0.5         pkgconfig_2.0.3  
## [49] pillar_1.9.0      bslib_0.4.2       gtable_0.3.3      data.table_1.14.8
## [53] glue_1.6.2        Rcpp_1.0.10       highr_0.10        xfun_0.39        
## [57] tibble_3.2.1      tidyselect_1.2.0  rstudioapi_0.14   knitr_1.42       
## [61] farver_2.1.1      htmltools_0.5.5   labeling_0.4.2    rmarkdown_2.21   
## [65] compiler_4.3.0
```
