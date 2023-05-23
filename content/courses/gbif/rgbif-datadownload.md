---
title: "Downloading Data with rgbif"
author: Erik Kusch
date: '2023-05-21'
slug: datadownload
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: "Obtaining GBIF Mediated Data"
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
    weight: 6   
weight: 6
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
  "knitr", # for rmarkdown table visualisations
  "rio" # for dwc import
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
## rgbif knitr   rio 
##  TRUE  TRUE  TRUE
```

```r
options(gbif_user = "my gbif username")
options(gbif_email = "my registred gbif e-mail")
options(gbif_pwd = "my gbif password")
```
</details> 
{{% /alert %}}

First, we need to register the correct **usageKey** for *Calluna vulgaris*:

```r
sp_name <- "Calluna vulgaris"
sp_backbone <- name_backbone(name = sp_name)
sp_key <- sp_backbone$usageKey
```

Second, this is the specific data we are interested in obtaining:

```r
occ_final <- occ_search(
  taxonKey = sp_key,
  country = "NO",
  year = "2000,2022",
  basisOfRecord = "HUMAN_OBSERVATION",
  occurrenceStatus = "PRESENT"
)
```

Finally, we are ready to obtain GBIF mediated data we may want to use in downstream analyses and applications. This can be done in one of two ways - either via:
1. Near-Instant Download - via `occ_data(...)`
2. Asynchronous Download - via `occ_download(...)`

Let's explore both of these in turn.

# Near-Instant Download

{{% alert warning %}}
Near-instant downloads should only ever be used for initial data exploration and data stream/model building and **not for final publications**.
{{% /alert %}}

Near-instant downloads do not require a GBIF account to be set-up and are the quickest way to obtain GBIF mediated data, but also the more limited functionality since near-instant downloads allow the user to only obtain 100,000 records per query and do not create citable DOIs for easy reference and accreditation of GBIF mediated data.

Let me demonstrate how these can be executed nevertheless.

As a matter of fact, we have already executed one of these through our call to `occ_search(...)` at the top of this page. While this function does download data via the `...$data` output it provides, let's showcase instead how we could use the `occ_data(...)` function to arrive at the same result:


```r
NI_occ <- occ_data(
  taxonKey = sp_key,
  country = "NO",
  year = "2000,2022",
  basisOfRecord = "HUMAN_OBSERVATION",
  occurrenceStatus = "PRESENT"
)
knitr::kable(head(NI_occ$data))
```



|key        |scientificName             | decimalLatitude| decimalLongitude|issues             |datasetKey                           |publishingOrgKey                     |installationKey                      |publishingCountry |protocol    |lastCrawled                   |lastParsed                    | crawlId|hostingOrganizationKey               |basisOfRecord     |occurrenceStatus | taxonKey| kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey| speciesKey| acceptedTaxonKey|acceptedScientificName     |kingdom |phylum       |order    |family    |genus   |species          |genericName |specificEpithet |taxonRank |taxonomicStatus |iucnRedListCategory |dateIdentified      | coordinateUncertaintyInMeters|continent |stateProvince   | year| month| day|eventDate           |modified                      |lastInterpreted               |references                                         |license                                                 |isInCluster |datasetName                             |recordedBy                                                     |identifiedBy                            |geodeticDatum |class         |countryCode |country |rightsHolder                            |identifier                                    |http://unknown.org/nick |verbatimEventDate      |collectionCode |gbifID     |verbatimLocality   |occurrenceID                                       |taxonID |catalogNumber |institutionCode |eventTime      |http://unknown.org/captive |identificationID |locationID |associatedReferences                               |county   |municipality |locality                              |habitat                    |dynamicProperties                                                                               |footprintWKT |projectId | individualCount| elevation| elevationAccuracy|lifeStage |vernacularName |higherClassification |datasetID |fieldNotes |name                       |
|:----------|:--------------------------|---------------:|----------------:|:------------------|:------------------------------------|:------------------------------------|:------------------------------------|:-----------------|:-----------|:-----------------------------|:-----------------------------|-------:|:------------------------------------|:-----------------|:----------------|--------:|----------:|---------:|--------:|--------:|---------:|--------:|----------:|----------------:|:--------------------------|:-------|:------------|:--------|:---------|:-------|:----------------|:-----------|:---------------|:---------|:---------------|:-------------------|:-------------------|-----------------------------:|:---------|:---------------|----:|-----:|---:|:-------------------|:-----------------------------|:-----------------------------|:--------------------------------------------------|:-------------------------------------------------------|:-----------|:---------------------------------------|:--------------------------------------------------------------|:---------------------------------------|:-------------|:-------------|:-----------|:-------|:---------------------------------------|:---------------------------------------------|:-----------------------|:----------------------|:--------------|:----------|:------------------|:--------------------------------------------------|:-------|:-------------|:---------------|:--------------|:--------------------------|:----------------|:----------|:--------------------------------------------------|:--------|:------------|:-------------------------------------|:--------------------------|:-----------------------------------------------------------------------------------------------|:------------|:---------|---------------:|---------:|-----------------:|:---------|:--------------|:--------------------|:---------|:----------|:--------------------------|
|3456494582 |Calluna vulgaris (L.) Hull |        63.01656|         7.352901|cdc,cdround        |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |28eb1a3f-1c15-4a95-931a-4af90ecb574d |997448a8-f762-11e1-a439-00145eb45e9a |US                |DWC_ARCHIVE |2023-05-16T21:02:29.727+00:00 |2023-05-22T15:25:06.281+00:00 |     366|28eb1a3f-1c15-4a95-931a-4af90ecb574d |HUMAN_OBSERVATION |PRESENT          |  2882482|          6|   7707728|      220|     1353|      2505|  2882481|    2882482|          2882482|Calluna vulgaris (L.) Hull |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |Calluna     |vulgaris        |SPECIES   |ACCEPTED        |NE                  |2022-01-08T20:47:58 |                            31|EUROPE    |Møre og Romsdal | 2022|     1|   8|2022-01-08T21:38:00 |2022-01-14T10:51:53.000+00:00 |2023-05-22T15:25:06.281+00:00 |https://www.inaturalist.org/observations/104596730 |http://creativecommons.org/licenses/by-nc/4.0/legalcode |FALSE       |iNaturalist research-grade observations |Science Coordinator on MS Otto Sverdrup                        |Science Coordinator on MS Otto Sverdrup |WGS84         |Magnoliopsida |NO          |Norway  |Science Coordinator on MS Otto Sverdrup |104596730                                     |scienceco_os            |2022/01/08 9:38 PM CET |Observations   |3456494582 |Hustadvika, Norway |https://www.inaturalist.org/observations/104596730 |119450  |104596730     |iNaturalist     |21:38:00+01:00 |wild                       |230446798        |NA         |NA                                                 |NA       |NA           |NA                                    |NA                         |NA                                                                                              |NA           |NA        |              NA|        NA|                NA|NA        |NA             |NA                   |NA        |NA         |Calluna vulgaris (L.) Hull |
|3456429606 |Calluna vulgaris (L.) Hull |        63.01652|         7.352836|cdc,cdround        |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |28eb1a3f-1c15-4a95-931a-4af90ecb574d |997448a8-f762-11e1-a439-00145eb45e9a |US                |DWC_ARCHIVE |2023-05-16T21:02:29.727+00:00 |2023-05-22T15:25:18.025+00:00 |     366|28eb1a3f-1c15-4a95-931a-4af90ecb574d |HUMAN_OBSERVATION |PRESENT          |  2882482|          6|   7707728|      220|     1353|      2505|  2882481|    2882482|          2882482|Calluna vulgaris (L.) Hull |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |Calluna     |vulgaris        |SPECIES   |ACCEPTED        |NE                  |2022-01-08T20:47:59 |                            31|EUROPE    |Møre og Romsdal | 2022|     1|   8|2022-01-08T21:38:00 |2022-01-14T10:50:23.000+00:00 |2023-05-22T15:25:18.025+00:00 |https://www.inaturalist.org/observations/104596731 |http://creativecommons.org/licenses/by-nc/4.0/legalcode |FALSE       |iNaturalist research-grade observations |Science Coordinator on MS Otto Sverdrup                        |Science Coordinator on MS Otto Sverdrup |WGS84         |Magnoliopsida |NO          |Norway  |Science Coordinator on MS Otto Sverdrup |104596731                                     |scienceco_os            |2022/01/08 9:38 PM CET |Observations   |3456429606 |Hustadvika, Norway |https://www.inaturalist.org/observations/104596731 |119450  |104596731     |iNaturalist     |21:38:00+01:00 |wild                       |230446799        |NA         |NA                                                 |NA       |NA           |NA                                    |NA                         |NA                                                                                              |NA           |NA        |              NA|        NA|                NA|NA        |NA             |NA                   |NA        |NA         |Calluna vulgaris (L.) Hull |
|3459987324 |Calluna vulgaris (L.) Hull |        58.73242|         9.134815|cdc,cdround,gass84 |b124e1e0-4755-430f-9eab-894f25a9b59c |d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |7bdf9f6d-317a-45ec-8bb7-7ff61345d6a6 |NO                |EML         |2023-05-17T05:32:53.562+00:00 |2023-05-17T06:34:50.325+00:00 |     267|d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |HUMAN_OBSERVATION |PRESENT          |  2882482|          6|   7707728|      220|     1353|      2505|  2882481|    2882482|          2882482|Calluna vulgaris (L.) Hull |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |Calluna     |vulgaris        |SPECIES   |ACCEPTED        |NE                  |NA                  |                           250|EUROPE    |Agder           | 2022|     1|  22|2022-01-22T00:00:00 |2022-01-25T07:14:54.000+00:00 |2023-05-17T06:34:50.325+00:00 |NA                                                 |http://creativecommons.org/licenses/by/4.0/legalcode    |FALSE       |NA                                      |Fred William Christoffersen&#124;Bjørg Kathrine Christoffersen |NA                                      |WGS84         |Magnoliopsida |NO          |Norway  |NA                                      |urn:uuid:212cf9f4-2cc3-477c-ab63-6d8056e4a419 |NA                      |NA                     |so2-vascular   |3459987324 |NA                 |urn:uuid:212cf9f4-2cc3-477c-ab63-6d8056e4a419      |NA      |28426312      |nbf             |NA             |NA                         |NA               |346430     |https://www.artsobservasjoner.no/Sighting/28426312 |Agder    |Risør        |Bjønndalsknatten D, Barmen, Risør, Ag |NA                         |NA                                                                                              |NA           |NA        |              NA|        NA|                NA|NA        |NA             |NA                   |NA        |NA         |Calluna vulgaris (L.) Hull |
|3428943335 |Calluna vulgaris (L.) Hull |        59.45032|        10.711485|cdc,cdround,gass84 |b124e1e0-4755-430f-9eab-894f25a9b59c |d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |7bdf9f6d-317a-45ec-8bb7-7ff61345d6a6 |NO                |EML         |2023-05-17T05:32:53.562+00:00 |2023-05-17T06:33:29.461+00:00 |     267|d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |HUMAN_OBSERVATION |PRESENT          |  2882482|          6|   7707728|      220|     1353|      2505|  2882481|    2882482|          2882482|Calluna vulgaris (L.) Hull |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |Calluna     |vulgaris        |SPECIES   |ACCEPTED        |NE                  |NA                  |                            10|EUROPE    |Viken           | 2022|     1|   1|2022-01-01T00:00:00 |2022-01-01T13:48:09.000+00:00 |2023-05-17T06:33:29.461+00:00 |NA                                                 |http://creativecommons.org/licenses/by/4.0/legalcode    |FALSE       |NA                                      |Bård Haugsrud                                                  |NA                                      |WGS84         |Magnoliopsida |NO          |Norway  |NA                                      |urn:uuid:25b09107-14d8-47b9-a5b0-3356d4a210d0 |NA                      |NA                     |so2-vascular   |3428943335 |NA                 |urn:uuid:25b09107-14d8-47b9-a5b0-3356d4a210d0      |NA      |28273365      |nbf             |NA             |NA                         |NA               |1820270    |https://www.artsobservasjoner.no/Sighting/28273365 |Viken    |Moss         |Noretjernet, Moss, Vi                 |NA                         |NA                                                                                              |NA           |NA        |              NA|        NA|                NA|NA        |NA             |NA                   |NA        |NA         |Calluna vulgaris (L.) Hull |
|3459970330 |Calluna vulgaris (L.) Hull |        59.78265|        10.133823|cdc,cdround,gass84 |b124e1e0-4755-430f-9eab-894f25a9b59c |d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |7bdf9f6d-317a-45ec-8bb7-7ff61345d6a6 |NO                |EML         |2023-05-17T05:32:53.562+00:00 |2023-05-17T06:33:31.217+00:00 |     267|d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |HUMAN_OBSERVATION |PRESENT          |  2882482|          6|   7707728|      220|     1353|      2505|  2882481|    2882482|          2882482|Calluna vulgaris (L.) Hull |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |Calluna     |vulgaris        |SPECIES   |ACCEPTED        |NE                  |NA                  |                            10|EUROPE    |Viken           | 2022|     1|  23|2022-01-23T00:00:00 |2022-01-24T10:31:52.000+00:00 |2023-05-17T06:33:31.217+00:00 |NA                                                 |http://creativecommons.org/licenses/by/4.0/legalcode    |FALSE       |NA                                      |Endre Nygaard                                                  |NA                                      |WGS84         |Magnoliopsida |NO          |Norway  |NA                                      |urn:uuid:315c5234-8c79-4836-9c58-7d4672888d9c |NA                      |NA                     |so2-vascular   |3459970330 |NA                 |urn:uuid:315c5234-8c79-4836-9c58-7d4672888d9c      |NA      |28439861      |nbf             |NA             |NA                         |NA               |1833029    |https://www.artsobservasjoner.no/Sighting/28439861 |Viken    |Drammen      |Steinkjerringa, Drammen, Vi           |bergknaus                  |{"habitatRemark":"bergknaus","Biotopbeskrivelse":"bergknaus"}                                   |NA           |NA        |              NA|        NA|                NA|NA        |NA             |NA                   |NA        |NA         |Calluna vulgaris (L.) Hull |
|3440209347 |Calluna vulgaris (L.) Hull |        58.91246|         5.745283|cdc,cdround,gass84 |b124e1e0-4755-430f-9eab-894f25a9b59c |d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |7bdf9f6d-317a-45ec-8bb7-7ff61345d6a6 |NO                |EML         |2023-05-17T05:32:53.562+00:00 |2023-05-17T06:34:57.697+00:00 |     267|d3978a37-635a-4ae3-bb85-7b4d41bc0b88 |HUMAN_OBSERVATION |PRESENT          |  2882482|          6|   7707728|      220|     1353|      2505|  2882481|    2882482|          2882482|Calluna vulgaris (L.) Hull |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |Calluna     |vulgaris        |SPECIES   |ACCEPTED        |NE                  |NA                  |                            50|EUROPE    |Rogaland        | 2022|     1|   1|2022-01-01T00:00:00 |2022-01-13T19:54:43.000+00:00 |2023-05-17T06:34:57.697+00:00 |NA                                                 |http://creativecommons.org/licenses/by/4.0/legalcode    |FALSE       |NA                                      |Tor Helgeland                                                  |NA                                      |WGS84         |Magnoliopsida |NO          |Norway  |NA                                      |urn:uuid:36aaf72d-6ce7-4316-9756-6ae7b91e889c |NA                      |NA                     |so2-vascular   |3440209347 |NA                 |urn:uuid:36aaf72d-6ce7-4316-9756-6ae7b91e889c      |NA      |28348519      |nbf             |NA             |NA                         |NA               |1825478    |https://www.artsobservasjoner.no/Sighting/28348519 |Rogaland |Stavanger    |Boganeset, Stavanger, Ro              |blandingsskog kystlandskap |{"habitatRemark":"blandingsskog kystlandskap","Biotopbeskrivelse":"blandingsskog kystlandskap"} |NA           |NA        |              NA|        NA|                NA|NA        |NA             |NA                   |NA        |NA         |Calluna vulgaris (L.) Hull |

The near-instantaneous nature of this type of download is largely due to the hard limit on how much data you may obtain. For our example, the 100,000 record limit is not an issue as we are dealing with only 24347 records being available to us, but queries to GBIF mediated records can easily and quickly exceed this limit.

# Asynchronous Download

{{% alert success %}}
This is how you should obtain data **for publication-level research and reports**.
{{% /alert %}}

To avoid the reproducibility and data richness limitations of near-instant downloads, we must make a more formal download query to the GBIF API and await processing of our data request - an asynchronous download. To do so, we need to do three things in order:

1. Specify the data we want and request processing and download from GBIF
2. Download the data once it is processed
3. Load the downloaded data into `R`

{{% alert info %}}
Time between registering a download request and retrieval of data may vary according to how busy the GBIF API and servers are as well as the size and complexity of the data requested. GBIF will only handle a maximum of 3 download request per user simultaneously.
{{% /alert %}}

Let's tackle these step-by-step.

## Data Request at GBIF

To start this process of obtaining GBIF-mediated occurrence records, we first need to make a request to GBIF to start processing of the data we require. This is done with the `occ_download(...)` function. Making a data request at GBIF via the `occ_download(...)` function comes with two important considerations:

1. `occ_download(...)` specific syntax
2. data query metadata

### Syntax and Query through `occ_download()`

The `occ_download(...)` function - while powerful - requires us to confront a new set of syntax which translates the download request as we have seen it so far into a form which the GBIF API can understand. To do so, we use a host of `rgbif` functions built around the GBIF predicate DSL (domain specific language). These functions (with a few exceptions which you can see by calling the documentation - `?download_predicate_dsl`) all take two arguments:

- `key` - this is a core term which we want to target for our request
- `value` - this is the value for the core term which we are interested in

Finally, the relevant functions and how the relate `key` to `value` are:
- `pred(...)`: equals
- `pred_lt(...)`: lessThan
- `pred_lte(...)`: lessThanOrEquals
- `pred_gt(...)`: greaterThan
- `pred_gte(...)`: greaterThanOrEquals
- `pred_like(...)`: like
- `pred_within(...)`: within (only for geospatial queries, and only accepts a WKT string)
- `pred_notnull(...)`: isNotNull (only for geospatial queries, and only accepts a WKT string)
- `pred_isnull(...)`: isNull (only for stating that you want a key to be null)
- `pred_and(...)`: and (accepts multiple individual predicates, separating them by either "and" or "or")
- `pred_or(...)`: or (accepts multiple individual predicates, separating them by either "and" or "or")
- `pred_not(...)`: not (negates whatever predicate is passed in)
- `pred_in(...)`: in (accepts a single key but many values; stating that you want to search for all the values)

Let us use these to query the data we are interested in:



```r
res <- occ_download(
  pred("taxonKey", sp_key),
  pred("basisOfRecord", "HUMAN_OBSERVATION"),
  pred("country", "NO"),
  pred("hasCoordinate", TRUE),
  pred_gte("year", 2000),
  pred_lte("year", 2022)
)
```

Now that the download request has been made with GBIF, you need to wait for GBIF to process your query and return the desired data to you. You will find an overview of all your requested and processed downloads in your personal [download tab](https://www.gbif.org/user/download) on the GBIF webportal.

### Data Query Metadata
To keep track of all your data queries, each call to `occ_download(...)` returns a set of metadata for your download request as part of its object structure. This can be assessed as follows:

```r
occ_download_meta(res)
```

```
## <<gbif download metadata>>
##   Status: SUCCEEDED
##   DOI: 10.15468/dl.awgk9s
##   Format: DWCA
##   Download key: 0256615-230224095556074
##   Created: 2023-05-22T19:49:39.661+00:00
##   Modified: 2023-05-22T19:50:53.445+00:00
##   Download link: https://api.gbif.org/v1/occurrence/download/request/0256615-230224095556074.zip
##   Total records: 24904
```

It can even be subset for relevant parts of it like so:

```r
occ_download_meta(res)$downloadLink
```

```
## [1] "https://api.gbif.org/v1/occurrence/download/request/0256615-230224095556074.zip"
```

This is done according to the underlying structure of the metadata:


```r
str(occ_download_meta(res), max.level = 1)
```

```
## List of 12
##  $ key           : chr "0256615-230224095556074"
##  $ doi           : chr "10.15468/dl.awgk9s"
##  $ license       : chr "http://creativecommons.org/licenses/by-nc/4.0/legalcode"
##  $ request       :List of 5
##  $ created       : chr "2023-05-22T19:49:39.661+00:00"
##  $ modified      : chr "2023-05-22T19:50:53.445+00:00"
##  $ eraseAfter    : chr "2023-11-22T19:49:39.577+00:00"
##  $ status        : chr "SUCCEEDED"
##  $ downloadLink  : chr "https://api.gbif.org/v1/occurrence/download/request/0256615-230224095556074.zip"
##  $ size          : int 6513729
##  $ totalRecords  : int 24904
##  $ numberDatasets: int 47
##  - attr(*, "class")= chr "occ_download_meta"
##  - attr(*, "format")= chr "DWCA"
```

**Note:** You will find that the number of records in our query made via `occ_download(...)` here and `occ_search(...)` above are different:

```r
occ_download_meta(res)$totalRecords
```

```
## [1] 24904
```


```r
NI_occ$meta$count
```
```
## [1] 24347
```

This is due to different ways data ranges are handled. Running `occ_search(...)` instead like so fixes the mismatch:


```r
occ_search(
  taxonKey = sp_key,
  country = "NO",
  year = "2000,2023", # we need to expand the upper range limit here
  basisOfRecord = "HUMAN_OBSERVATION",
  occurrenceStatus = "PRESENT",
  hasGeospatialIssue = FALSE,
  hasCoordinate = TRUE
)$meta$count
```
```
## [1] 24904
```
Now the data products match.

## Data Download

Now that the download request is registered with GBIF, it is time to actually obtain the data you have queried. To facilitate this, there are three distinct ways to obtain the data itself:

1. Webportal
2. `rgbif`
3. File download with `R`

Personally, I can not recommend any of these methods over the `rgbif`-internal download method. However, in case you might prefer other options, I will quickly show how these work, too.

### GBIF Portal Download Method

At the most basic level, you may obtain data through the [GBIF portal](https://www.gbif.org/user/download) where you will find an overview of your download requests. Any individual download request can be investigated more deeply by clicking the "SHOW" button:

<img src="/courses/gbif/gbif-download1.jpeg" width="100%"/></a>

There, you will see a breakdown of your download request and also whether it is still being processed or already finished:
<img src="/courses/gbif/gbif-download2.jpeg" width="100%"/></a>

Upon completion of your request on the GBIF end, a "DOWNLOAD" button will appear on the specific download request overview page:
<img src="/courses/gbif/gbif-download3.jpeg" width="100%"/></a>

For requests of few data points you will usually have to be quite quick to see this in action as GBIF is often pretty fast and getting data ready for you.

### `rgbif` Download Method

{{% alert success %}}
This is the **preferred method** for downloading data you have requested from GBIF.
{{% /alert %}}

To download our data programmatically, we need to execute roughly the same steps as we did above:

1. Wait for data to be ready for download
2. Download the data
3. Load the data into `R` (we didn't do this in the above)

This is done with the following three corresponding functions:

```r
## 1. Check GBIF whether data is ready, this function will finish running when done and return metadata
res_meta <- occ_download_wait(res, status_ping = 5, curlopts = list(), quiet = FALSE)
## 2. Download the data as .zip (can specify a path)
res_get <- occ_download_get(res)
## 3. Load the data into R
res_data <- occ_download_import(res_get)
```

Let's have a look at the data we just loaded:

```r
dim(res_data)
```

```
## [1] 24904   259
```

```r
knitr::kable(head(res_data))
```



|    gbifID|abstract |accessRights |accrualMethod |accrualPeriodicity |accrualPolicy |alternative |audience |available |bibliographicCitation |conformsTo |contributor |coverage |created |creator |date |dateAccepted |dateCopyrighted |dateSubmitted |description |educationLevel |extent |format |hasFormat |hasPart |hasVersion |identifier |instructionalMethod |isFormatOf |isPartOf |isReferencedBy |isReplacedBy |isRequiredBy |isVersionOf |issued |language |license   |mediator |medium |modified |provenance |publisher |references |relation |replaces |requires |rights |rightsHolder |source |spatial |subject |tableOfContents |temporal |title |type |valid |institutionID |collectionID |datasetID |institutionCode |collectionCode |datasetName |ownerInstitutionCode |basisOfRecord     |informationWithheld |dataGeneralizations |dynamicProperties |occurrenceID |catalogNumber |recordNumber |recordedBy |recordedByID | individualCount| organismQuantity|organismQuantityType |sex |lifeStage |reproductiveCondition |behavior |establishmentMeans |degreeOfEstablishment |pathway |georeferenceVerificationStatus |occurrenceStatus |preparations |disposition |associatedOccurrences |associatedReferences |associatedSequences |associatedTaxa |otherCatalogNumbers |occurrenceRemarks |organismID |organismName |organismScope |associatedOrganisms |previousIdentifications |organismRemarks |materialSampleID |eventID |parentEventID |fieldNumber |eventDate  |eventTime |startDayOfYear |endDayOfYear | year| month| day|verbatimEventDate |habitat |samplingProtocol | sampleSizeValue|sampleSizeUnit |samplingEffort |fieldNotes |eventRemarks |locationID |higherGeographyID |higherGeography |continent |waterBody |islandGroup |island |countryCode |stateProvince |county |municipality |locality                                  |verbatimLocality |verbatimElevation |verticalDatum |verbatimDepth |minimumDistanceAboveSurfaceInMeters |maximumDistanceAboveSurfaceInMeters |locationAccordingTo |locationRemarks | decimalLatitude| decimalLongitude| coordinateUncertaintyInMeters|coordinatePrecision |pointRadiusSpatialFit |verbatimCoordinateSystem |verbatimSRS |footprintWKT |footprintSRS |footprintSpatialFit |georeferencedBy |georeferencedDate |georeferenceProtocol |georeferenceSources |georeferenceRemarks |geologicalContextID |earliestEonOrLowestEonothem |latestEonOrHighestEonothem |earliestEraOrLowestErathem |latestEraOrHighestErathem |earliestPeriodOrLowestSystem |latestPeriodOrHighestSystem |earliestEpochOrLowestSeries |latestEpochOrHighestSeries |earliestAgeOrLowestStage |latestAgeOrHighestStage |lowestBiostratigraphicZone |highestBiostratigraphicZone |lithostratigraphicTerms |group |formation |member |bed | identificationID|verbatimIdentification |identificationQualifier |typeStatus |identifiedBy |identifiedByID |dateIdentified |identificationReferences |identificationVerificationStatus |identificationRemarks |taxonID |scientificNameID |acceptedNameUsageID |parentNameUsageID |originalNameUsageID |nameAccordingToID |namePublishedInID |taxonConceptID |scientificName             |acceptedNameUsage |parentNameUsage |originalNameUsage |nameAccordingTo |namePublishedIn |namePublishedInYear |higherClassification |kingdom |phylum       |class         |order    |family    |subfamily |genus   |genericName |subgenus |infragenericEpithet |specificEpithet |infraspecificEpithet |cultivarEpithet |taxonRank |verbatimTaxonRank |vernacularName |nomenclaturalCode |taxonomicStatus |nomenclaturalStatus |taxonRemarks |datasetKey                           |publishingCountry |lastInterpreted     | elevation| elevationAccuracy| depth| depthAccuracy|distanceAboveSurface |distanceAboveSurfaceAccuracy | distanceFromCentroidInMeters|issue                                                                              |mediaType |hasCoordinate |hasGeospatialIssues | taxonKey| acceptedTaxonKey| kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey|subgenusKey | speciesKey|species          |acceptedScientificName     |verbatimScientificName |typifiedName |protocol |lastParsed          |lastCrawled         |repatriated |relativeOrganismQuantity |level0Gid |level0Name |level1Gid |level1Name      |level2Gid   |level2Name |level3Gid |level3Name |iucnRedListCategory |eventType |
|---------:|:--------|:------------|:-------------|:------------------|:-------------|:-----------|:--------|:---------|:---------------------|:----------|:-----------|:--------|:-------|:-------|:----|:------------|:---------------|:-------------|:-----------|:--------------|:------|:------|:---------|:-------|:----------|:----------|:-------------------|:----------|:--------|:--------------|:------------|:------------|:-----------|:------|:--------|:---------|:--------|:------|:--------|:----------|:---------|:----------|:--------|:--------|:--------|:------|:------------|:------|:-------|:-------|:---------------|:--------|:-----|:----|:-----|:-------------|:------------|:---------|:---------------|:--------------|:-----------|:--------------------|:-----------------|:-------------------|:-------------------|:-----------------|:------------|:-------------|:------------|:----------|:------------|---------------:|----------------:|:--------------------|:---|:---------|:---------------------|:--------|:------------------|:---------------------|:-------|:------------------------------|:----------------|:------------|:-----------|:---------------------|:--------------------|:-------------------|:--------------|:-------------------|:-----------------|:----------|:------------|:-------------|:-------------------|:-----------------------|:---------------|:----------------|:-------|:-------------|:-----------|:----------|:---------|:--------------|:------------|----:|-----:|---:|:-----------------|:-------|:----------------|---------------:|:--------------|:--------------|:----------|:------------|:----------|:-----------------|:---------------|:---------|:---------|:-----------|:------|:-----------|:-------------|:------|:------------|:-----------------------------------------|:----------------|:-----------------|:-------------|:-------------|:-----------------------------------|:-----------------------------------|:-------------------|:---------------|---------------:|----------------:|-----------------------------:|:-------------------|:---------------------|:------------------------|:-----------|:------------|:------------|:-------------------|:---------------|:-----------------|:--------------------|:-------------------|:-------------------|:-------------------|:---------------------------|:--------------------------|:--------------------------|:-------------------------|:----------------------------|:---------------------------|:---------------------------|:--------------------------|:------------------------|:-----------------------|:--------------------------|:---------------------------|:-----------------------|:-----|:---------|:------|:---|----------------:|:----------------------|:-----------------------|:----------|:------------|:--------------|:--------------|:------------------------|:--------------------------------|:---------------------|:-------|:----------------|:-------------------|:-----------------|:-------------------|:-----------------|:-----------------|:--------------|:--------------------------|:-----------------|:---------------|:-----------------|:---------------|:---------------|:-------------------|:--------------------|:-------|:------------|:-------------|:--------|:---------|:---------|:-------|:-----------|:--------|:-------------------|:---------------|:--------------------|:---------------|:---------|:-----------------|:--------------|:-----------------|:---------------|:-------------------|:------------|:------------------------------------|:-----------------|:-------------------|---------:|-----------------:|-----:|-------------:|:--------------------|:----------------------------|----------------------------:|:----------------------------------------------------------------------------------|:---------|:-------------|:-------------------|--------:|----------------:|----------:|---------:|--------:|--------:|---------:|--------:|:-----------|----------:|:----------------|:--------------------------|:----------------------|:------------|:--------|:-------------------|:-------------------|:-----------|:------------------------|:---------|:----------|:---------|:---------------|:-----------|:----------|:---------|:----------|:-------------------|:---------|
| 932753202|NA       |             |NA            |NA                 |NA            |NA          |NA       |NA        |                      |NA         |NA          |NA       |NA      |NA      |NA   |NA           |NA              |NA            |NA          |NA             |NA     |NA     |NA        |NA      |NA         |           |NA                  |NA         |NA       |NA             |NA           |NA           |NA          |NA     |         |CC_BY_4_0 |NA       |NA     |NA       |NA         |NA        |           |NA       |NA       |NA       |NA     |             |NA     |NA      |NA      |NA              |NA       |NA    |     |NA    |NA            |             |          |naturgucker     |naturgucker    |            |                     |HUMAN_OBSERVATION |                    |NA                  |                  |             |1543631469    |             |341725260  |             |              NA|               NA|                     |NA  |          |                      |NA       |NA                 |NA                    |NA      |NA                             |PRESENT          |             |NA          |NA                    |                     |NA                  |NA             |                    |                  |NA         |NA           |NA            |NA                  |NA                      |NA              |NA               |        |              |            |2011-08-06 |          |NA             |NA           | 2011|     8|   6|                  |        |                 |              NA|               |NA             |           |             |           |NA                |                |EUROPE    |NA        |NA          |NA     |NO          |              |       |             |Skardsfjella                              |                 |NA                |NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        62.90898|        12.040329|                           250|NA                  |NA                    |                         |NA          |             |             |NA                  |NA              |NA                |NA                   |NA                  |                    |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |               NA|                       |NA                      |NA         |             |               |NA             |NA                       |                                 |                      |        |NA               |NA                  |NA                |NA                  |NA                |NA                |               |Calluna vulgaris (L.) Hull |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Ericales |Ericaceae |NA        |Calluna |Calluna     |NA       |NA                  |vulgaris        |NA                   |NA              |SPECIES   |NA                |               |NA                |ACCEPTED        |NA                  |NA           |6ac3f774-d9fb-4796-b3e9-92bf6c81c084 |DE                |2023-01-24 21:46:36 |        NA|                NA|    NA|            NA|NA                   |NA                           |                           NA|COORDINATE_ROUNDED;GEODETIC_DATUM_ASSUMED_WGS84;CONTINENT_DERIVED_FROM_COORDINATES |          |TRUE          |FALSE               |  2882482|          2882482|          6|   7707728|      220|     1353|      2505|  2882481|NA          |    2882482|Calluna vulgaris |Calluna vulgaris (L.) Hull |Calluna vulgaris       |NA           |BIOCASE  |2023-01-24 21:46:36 |2023-01-03 03:39:57 |TRUE        |NA                       |NOR       |Norway     |NOR.15_1  |Sør-Trøndelag   |NOR.15.25_1 |Tydal      |          |           |NE                  |NA        |
| 920990580|NA       |             |NA            |NA                 |NA            |NA          |NA       |NA        |                      |NA         |NA          |NA       |NA      |NA      |NA   |NA           |NA              |NA            |NA          |NA             |NA     |NA     |NA        |NA      |NA         |           |NA                  |NA         |NA       |NA             |NA           |NA           |NA          |NA     |         |CC_BY_4_0 |NA       |NA     |NA       |NA         |NA        |           |NA       |NA       |NA       |NA     |             |NA     |NA      |NA      |NA              |NA       |NA    |     |NA    |NA            |             |          |naturgucker     |naturgucker    |            |                     |HUMAN_OBSERVATION |                    |NA                  |                  |             |937498444     |             |341725260  |             |              NA|               NA|                     |NA  |          |                      |NA       |NA                 |NA                    |NA      |NA                             |PRESENT          |             |NA          |NA                    |                     |NA                  |NA             |                    |                  |NA         |NA           |NA            |NA                  |NA                      |NA              |NA               |        |              |            |2011-08-06 |          |NA             |NA           | 2011|     8|   6|                  |        |                 |              NA|               |NA             |           |             |           |NA                |                |EUROPE    |NA        |NA          |NA     |NO          |              |       |             |Stugudalen Fjell                          |                 |NA                |NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        62.96623|        11.862488|                           250|NA                  |NA                    |                         |NA          |             |             |NA                  |NA              |NA                |NA                   |NA                  |                    |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |               NA|                       |NA                      |NA         |             |               |NA             |NA                       |                                 |                      |        |NA               |NA                  |NA                |NA                  |NA                |NA                |               |Calluna vulgaris (L.) Hull |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Ericales |Ericaceae |NA        |Calluna |Calluna     |NA       |NA                  |vulgaris        |NA                   |NA              |SPECIES   |NA                |               |NA                |ACCEPTED        |NA                  |NA           |6ac3f774-d9fb-4796-b3e9-92bf6c81c084 |DE                |2023-01-24 21:46:15 |        NA|                NA|    NA|            NA|NA                   |NA                           |                           NA|COORDINATE_ROUNDED;GEODETIC_DATUM_ASSUMED_WGS84;CONTINENT_DERIVED_FROM_COORDINATES |          |TRUE          |FALSE               |  2882482|          2882482|          6|   7707728|      220|     1353|      2505|  2882481|NA          |    2882482|Calluna vulgaris |Calluna vulgaris (L.) Hull |Calluna vulgaris       |NA           |BIOCASE  |2023-01-24 21:46:15 |2023-01-03 03:39:57 |TRUE        |NA                       |NOR       |Norway     |NOR.15_1  |Sør-Trøndelag   |NOR.15.25_1 |Tydal      |          |           |NE                  |NA        |
| 920989292|NA       |             |NA            |NA                 |NA            |NA          |NA       |NA        |                      |NA         |NA          |NA       |NA      |NA      |NA   |NA           |NA              |NA            |NA          |NA             |NA     |NA     |NA        |NA      |NA         |           |NA                  |NA         |NA       |NA             |NA           |NA           |NA          |NA     |         |CC_BY_4_0 |NA       |NA     |NA       |NA         |NA        |           |NA       |NA       |NA       |NA     |             |NA     |NA      |NA      |NA              |NA       |NA    |     |NA    |NA            |             |          |naturgucker     |naturgucker    |            |                     |HUMAN_OBSERVATION |                    |NA                  |                  |             |1389779363    |             |1597687675 |             |              NA|               NA|                     |NA  |          |                      |NA       |NA                 |NA                    |NA      |NA                             |PRESENT          |             |NA          |NA                    |                     |NA                  |NA             |                    |                  |NA         |NA           |NA            |NA                  |NA                      |NA              |NA               |        |              |            |2012-07-24 |          |NA             |NA           | 2012|     7|  24|                  |        |                 |              NA|               |NA             |           |             |           |NA                |                |EUROPE    |NA        |NA          |NA     |NO          |              |       |             |Raubergstulen am Jotunheimen-Nationalpark |                 |NA                |NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        61.71839|         8.392684|                           250|NA                  |NA                    |                         |NA          |             |             |NA                  |NA              |NA                |NA                   |NA                  |                    |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |               NA|                       |NA                      |NA         |             |               |NA             |NA                       |                                 |                      |        |NA               |NA                  |NA                |NA                  |NA                |NA                |               |Calluna vulgaris (L.) Hull |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Ericales |Ericaceae |NA        |Calluna |Calluna     |NA       |NA                  |vulgaris        |NA                   |NA              |SPECIES   |NA                |               |NA                |ACCEPTED        |NA                  |NA           |6ac3f774-d9fb-4796-b3e9-92bf6c81c084 |DE                |2023-01-24 21:45:30 |        NA|                NA|    NA|            NA|NA                   |NA                           |                           NA|COORDINATE_ROUNDED;GEODETIC_DATUM_ASSUMED_WGS84;CONTINENT_DERIVED_FROM_COORDINATES |          |TRUE          |FALSE               |  2882482|          2882482|          6|   7707728|      220|     1353|      2505|  2882481|NA          |    2882482|Calluna vulgaris |Calluna vulgaris (L.) Hull |Calluna vulgaris       |NA           |BIOCASE  |2023-01-24 21:45:30 |2023-01-03 03:39:57 |TRUE        |NA                       |NOR       |Norway     |NOR.11_1  |Oppland         |NOR.11.9_1  |Lom        |          |           |NE                  |NA        |
| 920901692|NA       |             |NA            |NA                 |NA            |NA          |NA       |NA        |                      |NA         |NA          |NA       |NA      |NA      |NA   |NA           |NA              |NA            |NA          |NA             |NA     |NA     |NA        |NA      |NA         |           |NA                  |NA         |NA       |NA             |NA           |NA           |NA          |NA     |         |CC_BY_4_0 |NA       |NA     |NA       |NA         |NA        |           |NA       |NA       |NA       |NA     |             |NA     |NA      |NA      |NA              |NA       |NA    |     |NA    |NA            |             |          |naturgucker     |naturgucker    |            |                     |HUMAN_OBSERVATION |                    |NA                  |                  |             |960113698     |             |1597687675 |             |              NA|               NA|                     |NA  |          |                      |NA       |NA                 |NA                    |NA      |NA                             |PRESENT          |             |NA          |NA                    |                     |NA                  |NA             |                    |                  |NA         |NA           |NA            |NA                  |NA                      |NA              |NA               |        |              |            |2012-07-28 |          |NA             |NA           | 2012|     7|  28|                  |        |                 |              NA|               |NA             |           |             |           |NA                |                |EUROPE    |NA        |NA          |NA     |NO          |              |       |             |Molde - Varden  (Aussichtsberg)           |                 |NA                |NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        62.74858|         7.127151|                           250|NA                  |NA                    |                         |NA          |             |             |NA                  |NA              |NA                |NA                   |NA                  |                    |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |               NA|                       |NA                      |NA         |             |               |NA             |NA                       |                                 |                      |        |NA               |NA                  |NA                |NA                  |NA                |NA                |               |Calluna vulgaris (L.) Hull |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Ericales |Ericaceae |NA        |Calluna |Calluna     |NA       |NA                  |vulgaris        |NA                   |NA              |SPECIES   |NA                |               |NA                |ACCEPTED        |NA                  |NA           |6ac3f774-d9fb-4796-b3e9-92bf6c81c084 |DE                |2023-01-24 21:45:14 |        NA|                NA|    NA|            NA|NA                   |NA                           |                           NA|COORDINATE_ROUNDED;GEODETIC_DATUM_ASSUMED_WGS84;CONTINENT_DERIVED_FROM_COORDINATES |          |TRUE          |FALSE               |  2882482|          2882482|          6|   7707728|      220|     1353|      2505|  2882481|NA          |    2882482|Calluna vulgaris |Calluna vulgaris (L.) Hull |Calluna vulgaris       |NA           |BIOCASE  |2023-01-24 21:45:14 |2023-01-03 03:39:57 |TRUE        |NA                       |NOR       |Norway     |NOR.8_1   |Møre og Romsdal |NOR.8.16_1  |Molde      |          |           |NE                  |NA        |
| 920890359|NA       |             |NA            |NA                 |NA            |NA          |NA       |NA        |                      |NA         |NA          |NA       |NA      |NA      |NA   |NA           |NA              |NA            |NA          |NA             |NA     |NA     |NA        |NA      |NA         |           |NA                  |NA         |NA       |NA             |NA           |NA           |NA          |NA     |         |CC_BY_4_0 |NA       |NA     |NA       |NA         |NA        |           |NA       |NA       |NA       |NA     |             |NA     |NA      |NA      |NA              |NA       |NA    |     |NA    |NA            |             |          |naturgucker     |naturgucker    |            |                     |HUMAN_OBSERVATION |                    |NA                  |                  |             |425209179     |             |1597687675 |             |              NA|               NA|                     |NA  |          |                      |NA       |NA                 |NA                    |NA      |NA                             |PRESENT          |             |NA          |NA                    |                     |NA                  |NA             |                    |                  |NA         |NA           |NA            |NA                  |NA                      |NA              |NA               |        |              |            |2012-07-27 |          |NA             |NA           | 2012|     7|  27|                  |        |                 |              NA|               |NA             |           |             |           |NA                |                |EUROPE    |NA        |NA          |NA     |NO          |              |       |             |Brücke am Siken                           |                 |NA                |NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        63.24830|         9.706270|                           250|NA                  |NA                    |                         |NA          |             |             |NA                  |NA              |NA                |NA                   |NA                  |                    |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |               NA|                       |NA                      |NA         |             |               |NA             |NA                       |                                 |                      |        |NA               |NA                  |NA                |NA                  |NA                |NA                |               |Calluna vulgaris (L.) Hull |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Ericales |Ericaceae |NA        |Calluna |Calluna     |NA       |NA                  |vulgaris        |NA                   |NA              |SPECIES   |NA                |               |NA                |ACCEPTED        |NA                  |NA           |6ac3f774-d9fb-4796-b3e9-92bf6c81c084 |DE                |2023-01-24 21:45:00 |        NA|                NA|    NA|            NA|NA                   |NA                           |                           NA|COORDINATE_ROUNDED;GEODETIC_DATUM_ASSUMED_WGS84;CONTINENT_DERIVED_FROM_COORDINATES |          |TRUE          |FALSE               |  2882482|          2882482|          6|   7707728|      220|     1353|      2505|  2882481|NA          |    2882482|Calluna vulgaris |Calluna vulgaris (L.) Hull |Calluna vulgaris       |NA           |BIOCASE  |2023-01-24 21:45:00 |2023-01-03 03:39:57 |TRUE        |NA                       |NOR       |Norway     |NOR.15_1  |Sør-Trøndelag   |NOR.15.14_1 |Orkdal     |          |           |NE                  |NA        |
| 920874053|NA       |             |NA            |NA                 |NA            |NA          |NA       |NA        |                      |NA         |NA          |NA       |NA      |NA      |NA   |NA           |NA              |NA            |NA          |NA             |NA     |NA     |NA        |NA      |NA         |           |NA                  |NA         |NA       |NA             |NA           |NA           |NA          |NA     |         |CC_BY_4_0 |NA       |NA     |NA       |NA         |NA        |           |NA       |NA       |NA       |NA     |             |NA     |NA      |NA      |NA              |NA       |NA    |     |NA    |NA            |             |          |naturgucker     |naturgucker    |            |                     |HUMAN_OBSERVATION |                    |NA                  |                  |             |743258513     |             |1597687675 |             |              NA|               NA|                     |NA  |          |                      |NA       |NA                 |NA                    |NA      |NA                             |PRESENT          |             |NA          |NA                    |                     |NA                  |NA             |                    |                  |NA         |NA           |NA            |NA                  |NA                      |NA              |NA               |        |              |            |2012-07-30 |          |NA             |NA           | 2012|     7|  30|                  |        |                 |              NA|               |NA             |           |             |           |NA                |                |EUROPE    |NA        |NA          |NA     |NO          |              |       |             |Trollstigen                               |                 |NA                |NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        62.45808|         7.669903|                           250|NA                  |NA                    |                         |NA          |             |             |NA                  |NA              |NA                |NA                   |NA                  |                    |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |               NA|                       |NA                      |NA         |             |               |NA             |NA                       |                                 |                      |        |NA               |NA                  |NA                |NA                  |NA                |NA                |               |Calluna vulgaris (L.) Hull |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Ericales |Ericaceae |NA        |Calluna |Calluna     |NA       |NA                  |vulgaris        |NA                   |NA              |SPECIES   |NA                |               |NA                |ACCEPTED        |NA                  |NA           |6ac3f774-d9fb-4796-b3e9-92bf6c81c084 |DE                |2023-01-24 21:45:06 |        NA|                NA|    NA|            NA|NA                   |NA                           |                           NA|COORDINATE_ROUNDED;GEODETIC_DATUM_ASSUMED_WGS84;CONTINENT_DERIVED_FROM_COORDINATES |          |TRUE          |FALSE               |  2882482|          2882482|          6|   7707728|      220|     1353|      2505|  2882481|NA          |    2882482|Calluna vulgaris |Calluna vulgaris (L.) Hull |Calluna vulgaris       |NA           |BIOCASE  |2023-01-24 21:45:06 |2023-01-03 03:39:57 |TRUE        |NA                       |NOR       |Norway     |NOR.8_1   |Møre og Romsdal |NOR.8.21_1  |Rauma      |          |           |NE                  |NA        |

Note that the structure of this data set is different to that obtained with `occ_search(...)` hence enforcing that you **should always stage downloads whose data are used in publications with `occ_download(...)`!**

### File Download Method

If, for some reason, you prefer a programmatic solution that does not use `rgbif`, you can also use base `R` functions to (1) wait for your download to be ready, (2) obtain your data and (3) load it into `R`.

To this end, we can code our own function:

```r
#------------------------------------------------------------------------------
# Asyncronous download from the GBIF API.
# The function tries, with given time interval to download data generated
# by the download key as object given by "occ_download" function of the "rgbif"
# library.
#
# Input:
# download_url: GBIF API download url (e.g. from occ_download in rgbif package)
# n_try: Number of times the function should keep trying
# Sys.sleep_duration: Time interval between each try (in seconds)
#
# Output:
# Downloaded dwc-archive, named with the download key and written to the
# the current R session working directory.
#------------------------------------------------------------------------------
download_GBIF_API <- function(download_url, n_try = 10, Sys.sleep_duration = 60, destfile_name) {
  # Download waiting and downloading
  n_try_count <- 1
  try_download <- try(download.file(
    url = download_url, destfile = destfile_name,
    quiet = TRUE
  ), silent = TRUE)
  while (inherits(try_download, "try-error") & n_try_count < n_try) {
    Sys.sleep(Sys.sleep_duration)
    n_try_count <- n_try_count + 1
    try_download <- try(download.file(
      url = download_url, destfile = destfile_name,
      quiet = TRUE
    ), silent = TRUE)
    print(paste(
      "trying... Download link not ready. Time elapsed (min):",
      round(as.numeric(paste(difftime(Sys.time(), start_time, units = "mins"))), 2)
    ))
  }

  # Data Loading
  archive_files <- unzip(destfile_name, files = "NULL", list = TRUE)
  occurrence_data <- rio::import(unzip(destfile_name, files = "occurrence.txt"), header = TRUE, sep = "\t")

  # Retunring data
  return(occurrence_data)
}

# call function
occurrence_data <- download_GBIF_API(
  download_url = occ_download_meta(res)$downloadLink,
  destfile_name = tempfile(),
  n_try = 5, Sys.sleep_duration = 30
)
```
*Note:* The current script is set up to store the downloaded data to a temporary file. If you work with large datasets you probably want to store the data on disk for re-use in later sessions.  

Now to test if that works the same as the more streamlined `rgbif` implementation:


```r
all.equal(data.frame(occurrence_data), data.frame(res_data))
```

```
## [1] TRUE
```

That worked!

{{% alert success %}}
You now have the means of **obtaining GBIF mediated data**. Next, you will need to work with that data locally.
{{% /alert %}}

# Session Info

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
## [1] rio_0.5.29  knitr_1.42  rgbif_3.7.7
## 
## loaded via a namespace (and not attached):
##  [1] gtable_0.3.3      xfun_0.39         bslib_0.4.2       ggplot2_3.4.2    
##  [5] vctrs_0.6.2       tools_4.3.0       generics_0.1.3    curl_5.0.0       
##  [9] tibble_3.2.1      fansi_1.0.4       pkgconfig_2.0.3   R.oo_1.25.0      
## [13] data.table_1.14.8 readxl_1.4.2      lifecycle_1.0.3   R.cache_0.16.0   
## [17] compiler_4.3.0    stringr_1.5.0     munsell_0.5.0     htmltools_0.5.5  
## [21] sass_0.4.6        yaml_2.3.7        lazyeval_0.2.2    pillar_1.9.0     
## [25] jquerylib_0.1.4   whisker_0.4.1     R.utils_2.12.2    cachem_1.0.8     
## [29] styler_1.9.1      tidyselect_1.2.0  zip_2.3.0         digest_0.6.31    
## [33] stringi_1.7.12    dplyr_1.1.2       purrr_1.0.1       bookdown_0.34    
## [37] forcats_1.0.0     fastmap_1.1.1     grid_4.3.0        colorspace_2.1-0 
## [41] cli_3.6.1         magrittr_2.0.3    triebeard_0.4.1   crul_1.4.0       
## [45] utf8_1.2.3        foreign_0.8-84    scales_1.2.1      bit64_4.0.5      
## [49] oai_0.4.0         rmarkdown_2.21    httr_1.4.5        bit_4.0.5        
## [53] cellranger_1.1.0  blogdown_1.16     R.methodsS3_1.8.2 hms_1.1.3        
## [57] openxlsx_4.2.5.2  evaluate_0.20     haven_2.5.2       rlang_1.1.1      
## [61] urltools_1.7.3    Rcpp_1.0.10       glue_1.6.2        httpcode_0.3.0   
## [65] xml2_1.3.4        rstudioapi_0.14   jsonlite_1.8.4    R6_2.5.1         
## [69] plyr_1.8.8
```
