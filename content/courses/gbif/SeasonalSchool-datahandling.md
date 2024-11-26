---
title: "Handling & Visualising Data"
author: Erik Kusch
date: '2023-11-14'
slug: NFDI-handling
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: "Investigating, cleaning, and plotting GBIF mediated data"
summary: 'A quick overview of common data handling steps for GBIF data.'
authors: []
lastmod: '2023-11-14T20:00:00+01:00'
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
    parent: NFDI4Biodiversity Seasonal School
    weight: 2
weight: 10
---



{{% alert warning %}}
This section of material is dependant on you having walked through the section on [finding & downloading data](/courses/gbif/nfdi-download/) first.
{{% /alert %}}

## Required `R` Packages & Preparations

Like before, we require some `R` packages for this step of the material. However, this time around, we are focusing on visualisations of data and spatial operations thereof.


``` r
## Custom install & load function
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, repos = "http://cran.us.r-project.org")
  }
  require(x, character.only = TRUE)
}
## names of packages we want installed (if not installed yet) and loaded
package_vec <- c(
  "rgbif", # for access to gbif
  "knitr", # for rmarkdown table visualisations
  "ggplot2", # for plotting
  "cowplot", # for grids of ggplots
  "sf", # for spatial operations
  "sp", # for CRS support
  "rnaturalearth", # for shapefiles
  "rnaturalearthdata" # for high resolution shapefiles
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
##             rgbif             knitr           ggplot2           cowplot                sf 
##              TRUE              TRUE              TRUE              TRUE              TRUE 
##                sp     rnaturalearth rnaturalearthdata 
##              TRUE              TRUE              TRUE
```

{{% alert success %}}
With the packages loaded and the `NFDI4Bio_GBIF.csv` and `NFDI4Bio_GBIF.RData` produced from the [previous section](/courses/gbif/nfdi-download/), you are now ready to handle and visualise data obtained through GBIF.
{{% /alert %}}

## Inspecting GBIF Data

Data mediated by GBIF comes from many sources. Very likely, the data you obtain for any project will be made up of contents from several different datasets which GBIF has extracted and bundled for you. As you can imagine, different data sources mean different precision and potential issues across datasets making up our GBIF data query result. We need to carefully investigate the data we have obtained and make sure no issues exist that would affect our subsequent analyses.

First, let's load the .csv file we created previously. Obviously, we could also use the `NFDI4Bio_GBIF.RData` we created previously. In this case, we would have to call `occ_download_get()` again. Since I assume most of you will want to save the GBIF data in a new format like .csv for downstream analyses, we are working with the .csv:

``` r
GBIF_df <- read.csv("NFDI4Bio_GBIF.csv")
```

Let's have a quick look at this data (note that you do not need the `knitr::kable()` command when executing this code directly in `R`):


``` r
knitr::kable(head(GBIF_df))
```



|  X|     gbifID|accessRights |bibliographicCitation |language |license      |modified            |publisher       |references                                         |rightsHolder    |type |institutionID |collectionID |datasetID |institutionCode |collectionCode |datasetName                             |ownerInstitutionCode |basisOfRecord     |informationWithheld                                                       |dataGeneralizations |dynamicProperties |occurrenceID                                       |catalogNumber |recordNumber |recordedBy      |recordedByID                          | individualCount| organismQuantity|organismQuantityType |sex |lifeStage |reproductiveCondition |caste |behavior |vitality |establishmentMeans |degreeOfEstablishment |pathway |georeferenceVerificationStatus |occurrenceStatus |preparations |disposition |associatedOccurrences |associatedReferences |associatedSequences |associatedTaxa |otherCatalogNumbers |occurrenceRemarks |organismID |organismName |organismScope |associatedOrganisms |previousIdentifications |organismRemarks |materialEntityID |materialEntityRemarks |verbatimLabel |materialSampleID |eventID |parentEventID |eventType |fieldNumber |eventDate           |eventTime      | startDayOfYear| endDayOfYear| year| month| day|verbatimEventDate                         |habitat |samplingProtocol | sampleSizeValue|sampleSizeUnit |samplingEffort |fieldNotes |eventRemarks |locationID |higherGeographyID |higherGeography |continent |waterBody |islandGroup |island |countryCode |stateProvince          |county |municipality |locality |verbatimLocality                              | verbatimElevation|verticalDatum |verbatimDepth |minimumDistanceAboveSurfaceInMeters |maximumDistanceAboveSurfaceInMeters |locationAccordingTo |locationRemarks | decimalLatitude| decimalLongitude| coordinateUncertaintyInMeters|coordinatePrecision | pointRadiusSpatialFit|verbatimCoordinateSystem |verbatimSRS |footprintWKT |footprintSRS |footprintSpatialFit |georeferencedBy |georeferencedDate |georeferenceProtocol |georeferenceSources |georeferenceRemarks |geologicalContextID |earliestEonOrLowestEonothem |latestEonOrHighestEonothem |earliestEraOrLowestErathem |latestEraOrHighestErathem |earliestPeriodOrLowestSystem |latestPeriodOrHighestSystem |earliestEpochOrLowestSeries |latestEpochOrHighestSeries |earliestAgeOrLowestStage |latestAgeOrHighestStage |lowestBiostratigraphicZone |highestBiostratigraphicZone |lithostratigraphicTerms |group |formation |member |bed | identificationID|verbatimIdentification |identificationQualifier |typeStatus |identifiedBy             |identifiedByID                        |dateIdentified      |identificationReferences |identificationVerificationStatus |identificationRemarks |taxonID | scientificNameID| acceptedNameUsageID|parentNameUsageID |originalNameUsageID |nameAccordingToID |namePublishedInID |taxonConceptID |scientificName            |acceptedNameUsage |parentNameUsage |originalNameUsage |nameAccordingTo |namePublishedIn |namePublishedInYear |higherClassification |kingdom |phylum       |class         |order   |superfamily |family   |subfamily |tribe |subtribe |genus   |genericName |subgenus |infragenericEpithet |specificEpithet |infraspecificEpithet |cultivarEpithet |taxonRank |verbatimTaxonRank |vernacularName |nomenclaturalCode |taxonomicStatus |nomenclaturalStatus |taxonRemarks |datasetKey                           |publishingCountry |lastInterpreted          | elevation| elevationAccuracy|depth |depthAccuracy | distanceFromCentroidInMeters|issue                                                                              |mediaType                        |hasCoordinate |hasGeospatialIssues | taxonKey| acceptedTaxonKey| kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey|subgenusKey | speciesKey|species           |acceptedScientificName    |verbatimScientificName |typifiedName |protocol    |lastParsed               |lastCrawled              |repatriated |relativeOrganismQuantity |projectId |isSequenced |gbifRegion |publishedByGbifRegion |level0Gid |level0Name |level1Gid |level1Name    |level2Gid   |level2Name                 |level3Gid      |level3Name |iucnRedListCategory |
|--:|----------:|:------------|:---------------------|:--------|:------------|:-------------------|:---------------|:--------------------------------------------------|:---------------|:----|:-------------|:------------|:---------|:---------------|:--------------|:---------------------------------------|:--------------------|:-----------------|:-------------------------------------------------------------------------|:-------------------|:-----------------|:--------------------------------------------------|:-------------|:------------|:---------------|:-------------------------------------|---------------:|----------------:|:--------------------|:---|:---------|:---------------------|:-----|:--------|:--------|:------------------|:---------------------|:-------|:------------------------------|:----------------|:------------|:-----------|:---------------------|:--------------------|:-------------------|:--------------|:-------------------|:-----------------|:----------|:------------|:-------------|:-------------------|:-----------------------|:---------------|:----------------|:---------------------|:-------------|:----------------|:-------|:-------------|:---------|:-----------|:-------------------|:--------------|--------------:|------------:|----:|-----:|---:|:-----------------------------------------|:-------|:----------------|---------------:|:--------------|:--------------|:----------|:------------|:----------|:-----------------|:---------------|:---------|:---------|:-----------|:------|:-----------|:----------------------|:------|:------------|:--------|:---------------------------------------------|-----------------:|:-------------|:-------------|:-----------------------------------|:-----------------------------------|:-------------------|:---------------|---------------:|----------------:|-----------------------------:|:-------------------|---------------------:|:------------------------|:-----------|:------------|:------------|:-------------------|:---------------|:-----------------|:--------------------|:-------------------|:-------------------|:-------------------|:---------------------------|:--------------------------|:--------------------------|:-------------------------|:----------------------------|:---------------------------|:---------------------------|:--------------------------|:------------------------|:-----------------------|:--------------------------|:---------------------------|:-----------------------|:-----|:---------|:------|:---|----------------:|:----------------------|:-----------------------|:----------|:------------------------|:-------------------------------------|:-------------------|:------------------------|:--------------------------------|:---------------------|:-------|----------------:|-------------------:|:-----------------|:-------------------|:-----------------|:-----------------|:--------------|:-------------------------|:-----------------|:---------------|:-----------------|:---------------|:---------------|:-------------------|:--------------------|:-------|:------------|:-------------|:-------|:-----------|:--------|:---------|:-----|:--------|:-------|:-----------|:--------|:-------------------|:---------------|:--------------------|:---------------|:---------|:-----------------|:--------------|:-----------------|:---------------|:-------------------|:------------|:------------------------------------|:-----------------|:------------------------|---------:|-----------------:|:-----|:-------------|----------------------------:|:----------------------------------------------------------------------------------|:--------------------------------|:-------------|:-------------------|--------:|----------------:|----------:|---------:|--------:|--------:|---------:|--------:|:-----------|----------:|:-----------------|:-------------------------|:----------------------|:------------|:-----------|:------------------------|:------------------------|:-----------|:------------------------|:---------|:-----------|:----------|:---------------------|:---------|:----------|:---------|:-------------|:-----------|:--------------------------|:--------------|:----------|:-------------------|
|  1| 2269252307|             |                      |         |CC_BY_4_0    |2019-06-16 07:35:33 |iNaturalist.org |https://www.inaturalist.org/observations/27039839  |Alexis          |     |              |             |          |iNaturalist     |Observations   |iNaturalist research-grade observations |                     |HUMAN_OBSERVATION |                                                                          |                    |                  |https://www.inaturalist.org/observations/27039839  |27039839      |             |Alexis          |                                      |              NA|               NA|                     |    |          |NA                    |NA    |NA       |NA       |                   |NA                    |NA      |NA                             |PRESENT          |NA           |NA          |NA                    |                     |NA                  |NA             |NA                  |                  |           |NA           |NA            |NA                  |NA                      |                |NA               |NA                    |NA            |NA               |        |              |NA        |            |2019-06-14T12:28    |12:28:00+02:00 |            165|          165| 2019|     6|  14|2019/06/14 12:28 PM CEST                  |        |                 |              NA|               |NA             |NA         |             |NA         |NA                |                |EUROPE    |NA        |            |       |DE          |Berlin                 |       |             |         |Charlottenburg-Wilmersdorf, Berlin, Germany   |                NA|NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        52.48053|         13.19752|                            41|NA                  |                    NA|                         |            |             |             |NA                  |NA              |NA                |NA                   |NA                  |NA                  |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |         58998490|                       |                        |NA         |Alexis                   |                                      |2019-06-15 19:09:14 |NA                       |                                 |                      |56133   |               NA|             2878688|NA                |NA                  |NA                |NA                |               |Quercus robur L.          |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Fagales |NA          |Fagaceae |NA        |NA    |NA       |Quercus |Quercus     |NA       |NA                  |robur           |                     |NA              |SPECIES   |NA                |               |                  |ACCEPTED        |NA                  |             |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |US                |2024-11-19T02:01:45.486Z |        NA|                NA|NA    |NA            |                           NA|COORDINATE_ROUNDED;CONTINENT_DERIVED_FROM_COORDINATES;TAXON_MATCH_TAXON_ID_IGNORED |StillImage                       |TRUE          |FALSE               |  2878688|          2878688|          6|   7707728|      220|     1354|      4689|  2877951|NA          |    2878688|Quercus robur     |Quercus robur L.          |Quercus robur          |NA           |DWC_ARCHIVE |2024-11-19T02:01:45.486Z |2024-11-17T09:49:24.302Z |TRUE        |NA                       |null      |FALSE       |EUROPE     |NORTH_AMERICA         |DEU       |Germany    |DEU.3_1   |Berlin        |DEU.3.1_1   |Berlin                     |DEU.3.1.1_1    |Berlin     |LC                  |
|  2| 2609113599|             |                      |         |CC_BY_4_0    |2023-03-10 16:04:25 |iNaturalist.org |https://www.inaturalist.org/observations/42521643  |Jakob Fahr      |     |              |             |          |iNaturalist     |Observations   |iNaturalist research-grade observations |                     |HUMAN_OBSERVATION |                                                                          |                    |                  |https://www.inaturalist.org/observations/42521643  |42521643      |             |Jakob Fahr      |https://orcid.org/0000-0002-9174-1204 |              NA|               NA|                     |    |          |NA                    |NA    |NA       |NA       |                   |NA                    |NA      |NA                             |PRESENT          |NA           |NA          |NA                    |                     |NA                  |NA             |NA                  |                  |           |NA           |NA            |NA                  |NA                      |                |NA               |NA                    |NA            |NA               |        |              |NA        |            |2020-04-18T17:52:36 |17:52:36+02:00 |            109|          109| 2020|     4|  18|2020-04-18 5:52:36 PM GMT+02:00           |        |                 |              NA|               |NA             |NA         |             |NA         |NA                |                |EUROPE    |NA        |            |       |DE          |Niedersachsen          |       |             |         |38329 Wittmar, Germany                        |                NA|NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        52.13933|         10.63529|                            21|NA                  |                    NA|                         |            |             |             |NA                  |NA              |NA                |NA                   |NA                  |NA                  |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |         96232020|                       |                        |NA         |Jakob Fahr               |https://orcid.org/0000-0002-9174-1204 |2020-04-18 23:12:35 |NA                       |                                 |                      |54227   |               NA|             2882316|NA                |NA                  |NA                |NA                |               |Fagus sylvatica L.        |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Fagales |NA          |Fagaceae |NA        |NA    |NA       |Fagus   |Fagus       |NA       |NA                  |sylvatica       |                     |NA              |SPECIES   |NA                |               |                  |ACCEPTED        |NA                  |             |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |US                |2024-11-19T02:03:38.653Z |        NA|                NA|NA    |NA            |                           NA|COORDINATE_ROUNDED;CONTINENT_DERIVED_FROM_COORDINATES;TAXON_MATCH_TAXON_ID_IGNORED |StillImage                       |TRUE          |FALSE               |  2882316|          2882316|          6|   7707728|      220|     1354|      4689|  2874875|NA          |    2882316|Fagus sylvatica   |Fagus sylvatica L.        |Fagus sylvatica        |NA           |DWC_ARCHIVE |2024-11-19T02:03:38.653Z |2024-11-17T09:49:24.302Z |TRUE        |NA                       |null      |FALSE       |EUROPE     |NORTH_AMERICA         |DEU       |Germany    |DEU.9_1   |Niedersachsen |DEU.9.45_1  |Wolfenbüttel               |DEU.9.45.5_1   |Elm-Asse   |LC                  |
|  3| 2634302330|             |                      |         |CC_BY_NC_4_0 |2020-05-25 08:09:04 |iNaturalist.org |https://www.inaturalist.org/observations/47162872  |murky           |     |              |             |          |iNaturalist     |Observations   |iNaturalist research-grade observations |                     |HUMAN_OBSERVATION |                                                                          |                    |                  |https://www.inaturalist.org/observations/47162872  |47162872      |             |murky           |                                      |              NA|               NA|                     |    |          |NA                    |NA    |NA       |NA       |                   |NA                    |NA      |NA                             |PRESENT          |NA           |NA          |NA                    |                     |NA                  |NA             |NA                  |                  |           |NA           |NA            |NA                  |NA                      |                |NA               |NA                    |NA            |NA               |        |              |NA        |            |2020-05-24T17:37:14 |17:37:14+02:00 |            145|          145| 2020|     5|  24|2020-05-24 5:37:14 PM GMT+02:00           |        |                 |              NA|               |NA             |NA         |             |NA         |NA                |                |EUROPE    |NA        |            |       |DE          |Bayern                 |       |             |         |Eichstätt, DE-BY, DE                          |                NA|NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        48.94080|         11.40697|                            NA|NA                  |                    NA|                         |            |             |             |NA                  |NA              |NA                |NA                   |NA                  |NA                  |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |        105379124|                       |                        |NA         |murky                    |                                      |2020-05-24 19:19:47 |NA                       |                                 |                      |54227   |               NA|             2882316|NA                |NA                  |NA                |NA                |               |Fagus sylvatica L.        |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Fagales |NA          |Fagaceae |NA        |NA    |NA       |Fagus   |Fagus       |NA       |NA                  |sylvatica       |                     |NA              |SPECIES   |NA                |               |                  |ACCEPTED        |NA                  |             |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |US                |2024-11-19T02:48:37.805Z |        NA|                NA|NA    |NA            |                           NA|COORDINATE_ROUNDED;CONTINENT_DERIVED_FROM_COORDINATES;TAXON_MATCH_TAXON_ID_IGNORED |StillImage;StillImage;StillImage |TRUE          |FALSE               |  2882316|          2882316|          6|   7707728|      220|     1354|      4689|  2874875|NA          |    2882316|Fagus sylvatica   |Fagus sylvatica L.        |Fagus sylvatica        |NA           |DWC_ARCHIVE |2024-11-19T02:48:37.805Z |2024-11-17T09:49:24.302Z |TRUE        |NA                       |null      |FALSE       |EUROPE     |NORTH_AMERICA         |DEU       |Germany    |DEU.2_1   |Bayern        |DEU.2.27_1  |Eichstätt                  |DEU.2.27.15_1  |Kipfenberg |LC                  |
|  4| 3455277552|             |                      |         |CC_BY_NC_4_0 |2021-12-17 15:41:13 |iNaturalist.org |https://www.inaturalist.org/observations/34915487  |rbk-jones       |     |              |             |          |iNaturalist     |Observations   |iNaturalist research-grade observations |                     |HUMAN_OBSERVATION |                                                                          |                    |                  |https://www.inaturalist.org/observations/34915487  |34915487      |             |rbk-jones       |                                      |              NA|               NA|                     |    |          |NA                    |NA    |NA       |NA       |                   |NA                    |NA      |NA                             |PRESENT          |NA           |NA          |NA                    |                     |NA                  |NA             |NA                  |                  |           |NA           |NA            |NA                  |NA                      |                |NA               |NA                    |NA            |NA               |        |              |NA        |            |2019-10-26T15:30:07 |15:30:07+02:00 |            299|          299| 2019|    10|  26|Sat Oct 26 2019 17:30:07 GMT+0200 (GMT+2) |        |                 |              NA|               |NA             |NA         |             |NA         |NA                |                |EUROPE    |NA        |            |       |DE          |Sachsen                |       |             |         |Bonhoefferstraße, Leipzig, Sachsen, DE        |                NA|NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        51.36412|         12.38828|                            65|NA                  |                    NA|                         |            |             |             |NA                  |NA              |NA                |NA                   |NA                  |NA                  |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |         75865880|                       |                        |NA         |Rolf Theodor Borlinghaus |                                      |2019-10-27 05:25:50 |NA                       |                                 |                      |54785   |               NA|             8313153|NA                |NA                  |NA                |NA                |               |Quercus palustris Münchh. |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Fagales |NA          |Fagaceae |NA        |NA    |NA       |Quercus |Quercus     |NA       |NA                  |palustris       |                     |NA              |SPECIES   |NA                |               |                  |ACCEPTED        |NA                  |             |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |US                |2024-11-19T02:42:19.456Z |        NA|                NA|NA    |NA            |                           NA|COORDINATE_ROUNDED;CONTINENT_DERIVED_FROM_COORDINATES;TAXON_MATCH_TAXON_ID_IGNORED |StillImage                       |TRUE          |FALSE               |  8313153|          8313153|          6|   7707728|      220|     1354|      4689|  2877951|NA          |    8313153|Quercus palustris |Quercus palustris Münchh. |Quercus palustris      |NA           |DWC_ARCHIVE |2024-11-19T02:42:19.456Z |2024-11-17T09:49:24.302Z |TRUE        |NA                       |null      |FALSE       |EUROPE     |NORTH_AMERICA         |DEU       |Germany    |DEU.14_1  |Sachsen       |DEU.14.6_1  |Leipzig (Kreisfreie Stadt) |DEU.14.6.1_1   |Leipzig    |LC                  |
|  5| 4952933770|             |                      |         |CC_BY_NC_4_0 |2024-09-29 15:29:02 |iNaturalist.org |https://www.inaturalist.org/observations/219629641 |dailyexpedition |     |              |             |          |iNaturalist     |Observations   |iNaturalist research-grade observations |                     |HUMAN_OBSERVATION |Coordinate uncertainty increased to 25717m at the request of the observer |                    |                  |https://www.inaturalist.org/observations/219629641 |219629641     |             |dailyexpedition |                                      |              NA|               NA|                     |    |          |NA                    |NA    |NA       |NA       |                   |NA                    |NA      |NA                             |PRESENT          |NA           |NA          |NA                    |                     |NA                  |NA             |NA                  |                  |           |NA           |NA            |NA                  |NA                      |                |NA               |NA                    |NA            |NA               |        |              |NA        |            |2019-07-21T14:14    |14:14:00+02:00 |            202|          202| 2019|     7|  21|2019/07/21 2:14 PM                        |        |                 |              NA|               |NA             |NA         |             |NA         |NA                |                |EUROPE    |NA        |            |       |DE          |Mecklenburg-Vorpommern |       |             |         |Mecklenburg-Vorpommern, DE                    |                NA|NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        54.51062|         13.69519|                         25717|NA                  |                    NA|                         |            |             |             |NA                  |NA              |NA                |NA                   |NA                  |NA                  |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |        494883722|                       |                        |NA         |dailyexpedition          |                                      |2024-05-31 23:05:28 |NA                       |                                 |                      |54227   |               NA|             2882316|NA                |NA                  |NA                |NA                |               |Fagus sylvatica L.        |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Fagales |NA          |Fagaceae |NA        |NA    |NA       |Fagus   |Fagus       |NA       |NA                  |sylvatica       |                     |NA              |SPECIES   |NA                |               |                  |ACCEPTED        |NA                  |             |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |US                |2024-11-19T02:35:41.808Z |        NA|                NA|NA    |NA            |                           NA|COORDINATE_ROUNDED;CONTINENT_DERIVED_FROM_COORDINATES;TAXON_MATCH_TAXON_ID_IGNORED |StillImage                       |TRUE          |FALSE               |  2882316|          2882316|          6|   7707728|      220|     1354|      4689|  2874875|NA          |    2882316|Fagus sylvatica   |Fagus sylvatica L.        |Fagus sylvatica        |NA           |DWC_ARCHIVE |2024-11-19T02:35:41.808Z |2024-11-17T09:49:24.302Z |TRUE        |NA                       |null      |FALSE       |EUROPE     |NORTH_AMERICA         |          |           |          |              |            |                           |               |           |LC                  |
|  6| 4018588336|             |                      |         |CC0_1_0      |2023-01-11 13:59:51 |iNaturalist.org |https://www.inaturalist.org/observations/45185825  |Peter Gabler    |     |              |             |          |iNaturalist     |Observations   |iNaturalist research-grade observations |                     |HUMAN_OBSERVATION |                                                                          |                    |                  |https://www.inaturalist.org/observations/45185825  |45185825      |             |Peter Gabler    |                                      |              NA|               NA|                     |    |          |NA                    |NA    |NA       |NA       |                   |NA                    |NA      |NA                             |PRESENT          |NA           |NA          |NA                    |                     |NA                  |NA             |NA                  |                  |           |NA           |NA            |NA                  |NA                      |                |NA               |NA                    |NA            |NA               |        |              |NA        |            |2020-05-07T19:06:10 |19:06:10+02:00 |            128|          128| 2020|     5|   7|Thu May 07 2020 19:06:10 GMT+0200 (GMT+2) |        |                 |              NA|               |NA             |NA         |             |NA         |NA                |                |EUROPE    |NA        |            |       |DE          |Sachsen                |       |             |         |Michael-Wolgemut-Straße, Zwickau, Sachsen, DE |                NA|NA            |NA            |NA                                  |NA                                  |NA                  |NA              |        50.72724|         12.51091|                           101|NA                  |                    NA|                         |            |             |             |NA                  |NA              |NA                |NA                   |NA                  |NA                  |NA                  |NA                          |NA                         |NA                         |NA                        |NA                           |NA                          |NA                          |NA                         |NA                       |NA                      |NA                         |NA                          |NA                      |NA    |NA        |NA     |NA  |        101434333|                       |                        |NA         |Peter Gabler             |                                      |2020-05-07 17:55:12 |NA                       |                                 |                      |56133   |               NA|             2878688|NA                |NA                  |NA                |NA                |               |Quercus robur L.          |NA                |NA              |NA                |NA              |NA              |NA                  |                     |Plantae |Tracheophyta |Magnoliopsida |Fagales |NA          |Fagaceae |NA        |NA    |NA       |Quercus |Quercus     |NA       |NA                  |robur           |                     |NA              |SPECIES   |NA                |               |                  |ACCEPTED        |NA                  |             |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |US                |2024-11-19T02:49:39.745Z |        NA|                NA|NA    |NA            |                           NA|COORDINATE_ROUNDED;CONTINENT_DERIVED_FROM_COORDINATES;TAXON_MATCH_TAXON_ID_IGNORED |StillImage                       |TRUE          |FALSE               |  2878688|          2878688|          6|   7707728|      220|     1354|      4689|  2877951|NA          |    2878688|Quercus robur     |Quercus robur L.          |Quercus robur          |NA           |DWC_ARCHIVE |2024-11-19T02:49:39.745Z |2024-11-17T09:49:24.302Z |TRUE        |NA                       |null      |FALSE       |EUROPE     |NORTH_AMERICA         |DEU       |Germany    |DEU.14_1  |Sachsen       |DEU.14.13_1 |Zwickau                    |DEU.14.13.23_1 |Zwickau    |LC                  |

{{% alert success %}}
With data loaded, it is now time to investigate it!
{{% /alert %}}

## Data Manipulation

As you can see in our quick glance at the data above, there are a lot of columns for our 437136 observations obtained via GBIF. We can probably leverage some of that information contained therein to refine our dataset for our purpose (e.g., SDMs). Additionally, We probably do not need all of that data and so want to cut back on some columns or obersvation to reduce the weight of our data on our disk or in RAM.

### Data Quality and Issues

In order to reduce our data to the useful information therein, we want to first and foremost investigate the quality and potential issues already indicated via [Issues & Flags](https://data-blog.gbif.org/post/issues-and-flags/) registered to the observations by GBIF.

Since we are interested in using the data for species distribution modelling, we are interested in four particular issues:
1. Whether the data comes with coordinates attached (we cannot use observations that are not geo-referenced):

``` r
## how many observations are recorded without coordinates?
sum(!GBIF_df$hasCoordinate)
```

```
## [1] 480
```

``` r
## subsetting the data for observations with recorded coordinates
GBIF_df <- GBIF_df[GBIF_df$hasCoordinate, ]
```
2. Whether data coordinates suffer from geospatial issues (we might be able to resolve these, but for now we just discard them):

``` r
## how many observations' coordinates have geospatial issues?
sum(GBIF_df$hasGeospatialIssues)
```

```
## [1] 6
```

``` r
## subsetting the data for observations with coordinates without geospatial issues
GBIF_df <- GBIF_df[!GBIF_df$hasGeospatialIssues, ]
```
3. Coordinate uncertainty (if we are highly uncertain of where an observation was made, we probably don't want to learn bioclimatic niches from it):

``` r
## Some coordinate uncertainties are recorded as NA, I remove those - others don't. THis is up to you.
GBIF_df <- GBIF_df[!is.na(GBIF_df$coordinateUncertaintyInMeters), ]
## Visualising the distribution of coordinate uncertainty in the data
ggplot(GBIF_df, aes(x = coordinateUncertaintyInMeters)) +
  geom_histogram(bins = 1e3) +
  theme_bw() +
  scale_y_continuous(trans = "log10")
```

<img src="SeasonalSchool-datahandling_files/figure-html/unnamed-chunk-5-1.png" width="1440" />

``` r
## how many observations are made with sub-kilometre accuracy?
sum(GBIF_df$coordinateUncertaintyInMeters < 1000)
```

```
## [1] 58304
```

``` r
## subsetting the data for observations with acceptable coordinate uncertainty,
GBIF_df <- GBIF_df[which(GBIF_df$coordinateUncertaintyInMeters < 1000), ]
```
4. Whether the observations encode presence or absence. While both types of information are valuable, absence recording in GBIF is uncommon. As to not bias our SDMs, I remove the absences here:

``` r
## how many observations even record absence?
sum(GBIF_df$occurrenceStatus == "ABSENT")
```

```
## [1] 0
```

``` r
## subsetting the data for observations only recording presence
GBIF_df <- GBIF_df[GBIF_df$occurrenceStatus == "PRESENT", ]
```

**Lastly**, let's reduce the number of columns in our data to the ones relevant to us:


``` r
GBIF_df <- GBIF_df[
  ,
  c(
    "scientificName", "taxonKey", "family", "familyKey", "species", # taxonomic identifiers
    "decimalLongitude", "decimalLatitude", # geospatial identifiers
    "year", "month", "day", "eventDate", # temporal identifiers
    "countryCode", "municipality", "stateProvince", # administrative identifiers
    "catalogNumber", "mediaType", "datasetKey" # GBIF data identifiers
  )
]
```

Again, let's have a glimpse at the data:

``` r
knitr::kable(head(GBIF_df))
```



|   |scientificName            | taxonKey|family   | familyKey|species           | decimalLongitude| decimalLatitude| year| month| day|eventDate            |countryCode |municipality |stateProvince          |catalogNumber |mediaType                        |datasetKey                           |
|:--|:-------------------------|--------:|:--------|---------:|:-----------------|----------------:|---------------:|----:|-----:|---:|:--------------------|:-----------|:------------|:----------------------|:-------------|:--------------------------------|:------------------------------------|
|1  |Quercus robur L.          |  2878688|Fagaceae |      4689|Quercus robur     |        13.197520|        52.48053| 2019|     6|  14|2019-06-14T12:28     |DE          |             |Berlin                 |27039839      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |
|2  |Fagus sylvatica L.        |  2882316|Fagaceae |      4689|Fagus sylvatica   |        10.635290|        52.13933| 2020|     4|  18|2020-04-18T17:52:36  |DE          |             |Niedersachsen          |42521643      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |
|4  |Quercus palustris Münchh. |  8313153|Fagaceae |      4689|Quercus palustris |        12.388285|        51.36412| 2019|    10|  26|2019-10-26T15:30:07  |DE          |             |Sachsen                |34915487      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |
|6  |Quercus robur L.          |  2878688|Fagaceae |      4689|Quercus robur     |        12.510908|        50.72724| 2020|     5|   7|2020-05-07T19:06:10  |DE          |             |Sachsen                |45185825      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |
|7  |Fagus sylvatica L.        |  2882316|Fagaceae |      4689|Fagus sylvatica   |         9.592076|        51.47528| 2020|     5|  21|2020-05-21T11:07:39  |DE          |             |Hessen                 |46711391      |StillImage;StillImage;StillImage |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |
|8  |Quercus robur L.          |  2878688|Fagaceae |      4689|Quercus robur     |        12.791288|        53.45432| 2019|     5|  29|2019-05-29T14:44:56Z |DE          |             |Mecklenburg-Vorpommern |26128754      |StillImage                       |50c9509d-22c7-4a22-a47d-8c48425ef4a7 |

Finally, we save the data as its own .csv file:


``` r
write.csv(GBIF_df, file = "NFDI4Bio_GBIF_subset.csv")
```

Notice that this new file is 56.63 times smaller than the original data we obtained.

{{% alert success %}}
We now have succesfully investigated and subsetted our data to the relevant and reliable components for our purposes.
{{% /alert %}}


### Creating a Spatially Explicit Object

Much of downstream analyses of GBIF data require use of the coordinate components of the data so let's make the data into a spatial feature object to facilitate such work in `R`:


``` r
## make coordinates easy to read for the machine
options(digits = 8) # set 8 digits (ie. all digits, not decimals) for the type cast as.double to keep decimals
GBIF_df$lon <- as.double(GBIF_df$decimalLongitude) # cast lon from char to double
GBIF_df$lat <- as.double(GBIF_df$decimalLatitude) # cast lat from char to double
## make spatial features object
GBIF_sf <- st_as_sf(GBIF_df, coords = c("lon", "lat"), remove = FALSE)
## assign a CRS
st_crs(GBIF_sf) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
## look at the object created
GBIF_sf
```

```
## Simple feature collection with 58304 features and 19 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: 5.871829 ymin: 47.272701 xmax: 14.995758 ymax: 54.991665
## Geodetic CRS:  BOUNDCRS[
##     SOURCECRS[
##         GEOGCRS["unknown",
##             DATUM["World Geodetic System 1984",
##                 ELLIPSOID["WGS 84",6378137,298.257223563,
##                     LENGTHUNIT["metre",1]],
##                 ID["EPSG",6326]],
##             PRIMEM["Greenwich",0,
##                 ANGLEUNIT["degree",0.0174532925199433],
##                 ID["EPSG",8901]],
##             CS[ellipsoidal,2],
##                 AXIS["longitude",east,
##                     ORDER[1],
##                     ANGLEUNIT["degree",0.0174532925199433,
##                         ID["EPSG",9122]]],
##                 AXIS["latitude",north,
##                     ORDER[2],
##                     ANGLEUNIT["degree",0.0174532925199433,
##                         ID["EPSG",9122]]]]],
##     TARGETCRS[
##         GEOGCRS["WGS 84",
##             DATUM["World Geodetic System 1984",
##                 ELLIPSOID["WGS 84",6378137,298.257223563,
##                     LENGTHUNIT["metre",1]]],
##             PRIMEM["Greenwich",0,
##                 ANGLEUNIT["degree",0.0174532925199433]],
##             CS[ellipsoidal,2],
##                 AXIS["latitude",north,
##                     ORDER[1],
##                     ANGLEUNIT["degree",0.0174532925199433]],
##                 AXIS["longitude",east,
##                     ORDER[2],
##                     ANGLEUNIT["degree",0.0174532925199433]],
##             ID["EPSG",4326]]],
##     ABRIDGEDTRANSFORMATION["Transformation from unknown to WGS84",
##         METHOD["Geocentric translations (geog2D domain)",
##             ID["EPSG",9603]],
##         PARAMETER["X-axis translation",0,
##             ID["EPSG",8605]],
##         PARAMETER["Y-axis translation",0,
##             ID["EPSG",8606]],
##         PARAMETER["Z-axis translation",0,
##             ID["EPSG",8607]]]]
## First 10 features:
##                scientificName taxonKey   family familyKey           species
## 1            Quercus robur L.  2878688 Fagaceae      4689     Quercus robur
## 2          Fagus sylvatica L.  2882316 Fagaceae      4689   Fagus sylvatica
## 4  Quercus palustris Münchh.  8313153 Fagaceae      4689 Quercus palustris
## 6            Quercus robur L.  2878688 Fagaceae      4689     Quercus robur
## 7          Fagus sylvatica L.  2882316 Fagaceae      4689   Fagus sylvatica
## 8            Quercus robur L.  2878688 Fagaceae      4689     Quercus robur
## 9         Pinus sylvestris L.  5285637 Pinaceae      3925  Pinus sylvestris
## 10           Quercus robur L.  2878688 Fagaceae      4689     Quercus robur
## 11         Fagus sylvatica L.  2882316 Fagaceae      4689   Fagus sylvatica
## 12           Quercus robur L.  2878688 Fagaceae      4689     Quercus robur
##    decimalLongitude decimalLatitude year month day            eventDate countryCode
## 1         13.197520       52.480531 2019     6  14     2019-06-14T12:28          DE
## 2         10.635290       52.139326 2020     4  18  2020-04-18T17:52:36          DE
## 4         12.388285       51.364118 2019    10  26  2019-10-26T15:30:07          DE
## 6         12.510908       50.727237 2020     5   7  2020-05-07T19:06:10          DE
## 7          9.592076       51.475282 2020     5  21  2020-05-21T11:07:39          DE
## 8         12.791288       53.454316 2019     5  29 2019-05-29T14:44:56Z          DE
## 9         12.429091       50.773137 2020     6  19  2020-06-19T17:06:40          DE
## 10        13.243034       52.502898 2020     1  16     2020-01-16T13:21          DE
## 11         9.352532       51.333704 2020     5  12 2020-05-12T13:11:54Z          DE
## 12         9.697503       49.030169 2020     8  23     2020-08-23T12:13          DE
##    municipality          stateProvince catalogNumber                        mediaType
## 1                               Berlin      27039839                       StillImage
## 2                        Niedersachsen      42521643                       StillImage
## 4                              Sachsen      34915487                       StillImage
## 6                              Sachsen      45185825                       StillImage
## 7                               Hessen      46711391 StillImage;StillImage;StillImage
## 8               Mecklenburg-Vorpommern      26128754                       StillImage
## 9                              Sachsen      50177410            StillImage;StillImage
## 10                              Berlin      37713663                       StillImage
## 11                              Hessen      45676495                       StillImage
## 12                  Baden-Württemberg      57726302                       StillImage
##                              datasetKey       lon       lat                    geometry
## 1  50c9509d-22c7-4a22-a47d-8c48425ef4a7 13.197520 52.480531  POINT (13.19752 52.480531)
## 2  50c9509d-22c7-4a22-a47d-8c48425ef4a7 10.635290 52.139326  POINT (10.63529 52.139326)
## 4  50c9509d-22c7-4a22-a47d-8c48425ef4a7 12.388285 51.364118 POINT (12.388285 51.364118)
## 6  50c9509d-22c7-4a22-a47d-8c48425ef4a7 12.510908 50.727237 POINT (12.510908 50.727237)
## 7  50c9509d-22c7-4a22-a47d-8c48425ef4a7  9.592076 51.475282  POINT (9.592076 51.475282)
## 8  50c9509d-22c7-4a22-a47d-8c48425ef4a7 12.791288 53.454316 POINT (12.791288 53.454316)
## 9  50c9509d-22c7-4a22-a47d-8c48425ef4a7 12.429091 50.773137 POINT (12.429091 50.773137)
## 10 50c9509d-22c7-4a22-a47d-8c48425ef4a7 13.243034 52.502898 POINT (13.243034 52.502898)
## 11 50c9509d-22c7-4a22-a47d-8c48425ef4a7  9.352532 51.333704  POINT (9.352532 51.333704)
## 12 50c9509d-22c7-4a22-a47d-8c48425ef4a7  9.697503 49.030169  POINT (9.697503 49.030169)
```

We will need this spatial features object later so let's save it to our disk:


``` r
save(GBIF_sf, file = "GBIF_sf.RData")
```

### Matching Observations with Polygons

Let's say, for example, we want to quantify abundances of our taxonomic families across administrative states within Germany:


``` r
## Obtain sf object
DE_municip <- rnaturalearth::ne_states(country = "Germany", returnclass = "sf") # get shapefiles for German states
## loop over family identities
abundances_ls <- lapply(unique(GBIF_sf$family), FUN = function(family) {
  ## Identify overlap of points and polygons
  cover_sf <- st_intersects(DE_municip, GBIF_sf[GBIF_sf$family == family, ])
  names(cover_sf) <- DE_municip$name
  ## report abundances
  abundances_municip <- unlist(lapply(cover_sf, length))
  abundances_municip
})
names(abundances_ls) <- unique(GBIF_sf$family)
## make a data frame of it
abundances_df <- as.data.frame(do.call(cbind, abundances_ls))
## look at the data frame in html page
knitr::kable(abundances_df)
```



|                       | Fagaceae| Pinaceae|
|:----------------------|--------:|--------:|
|Sachsen                |     1189|      704|
|Bayern                 |     4756|     3769|
|Rheinland-Pfalz        |     2563|      444|
|Saarland               |      632|       46|
|Schleswig-Holstein     |     1752|      545|
|Niedersachsen          |     4461|     1235|
|Nordrhein-Westfalen    |     6814|     2135|
|Baden-Württemberg      |     5650|     3796|
|Brandenburg            |     2515|      974|
|Mecklenburg-Vorpommern |      919|      461|
|Bremen                 |       96|       66|
|Hamburg                |      354|       40|
|Hessen                 |     5529|     2545|
|Thüringen              |      510|     1037|
|Sachsen-Anhalt         |      410|      163|
|Berlin                 |     1263|      449|

And therew we go, abundances of *Pinaceae* and *Fagaceae* tallied across states in Germany.

{{% alert success %}}
You can now create and do basic spatial operations from GBIF mediated data!
{{% /alert %}}


## Data visualisation

Now that we have created some fancy `R` objects and summary statistics of our data, we should visualise it.

### Plotting Occurrences on a Map

First, we plot our observations by taxonomic family across Germany:


``` r
## get background map
DE_shp <- rnaturalearth::ne_countries(country = "Germany", scale = 10, returnclass = "sf")[, 1]
## make plot
ggplot() +
  geom_sf(data = DE_shp) +
  geom_sf(data = GBIF_sf[, 1], aes(col = GBIF_sf$family)) +
  theme_bw() +
  theme(legend.position = "bottom") +
  guides(col = guide_legend(title = "Taxonomic families")) +
  scale_color_manual(values = c("darkorange", "forestgreen")) +
  labs(title = "Occurrences of Pinaceae and Fagaceae recorded by human observations between 1970 and 2020")
```

<img src="SeasonalSchool-datahandling_files/figure-html/unnamed-chunk-13-1.png" width="1440" />

### Plotting Abundances by State

Next, we visualise the state-wise abundances:

``` r
# Fagaceae
## adding data to shapefiles
DE_municip$Fagaceae <- abundances_df$Fagaceae
## making plot
Fa_gg <- ggplot(data = DE_municip) +
  geom_sf(aes(fill = Fagaceae)) +
  scale_fill_viridis_c() +
  labs(x = "Longitude", y = "Latitude", col = "Abundance", title = "Fagaceae Abundance") +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_fill_gradient(low = "white", high = "darkorange") +
  guides(fill = guide_colourbar(theme = theme(
    legend.key.width  = unit(21, "lines"),
    legend.key.height = unit(3, "lines")
  )))

# Pinaceae
## adding data to shapefiles
DE_municip$Pinaceae <- abundances_df$Pinaceae
## making plot
Pi_gg <- ggplot(data = DE_municip) +
  geom_sf(aes(fill = Pinaceae)) +
  scale_fill_viridis_c() +
  labs(x = "Longitude", y = "Latitude", col = "Abundance", title = "Pinaceae Abundance") +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_fill_gradient(low = "white", high = "forestgreen") +
  guides(fill = guide_colourbar(theme = theme(
    legend.key.width  = unit(21, "lines"),
    legend.key.height = unit(3, "lines")
  )))

## combined plot
plot_grid(Fa_gg, Pi_gg, ncol = 2)
```

<img src="SeasonalSchool-datahandling_files/figure-html/unnamed-chunk-14-1.png" width="1440" />

### Plotting A Time-Series of Observations

Lastly, let's visualise how our knowledge of our target taxonomic families has evolved over time:


``` r
## plotting data frame skeleton
plot_df <- expand.grid(1970:2020, c("Fagaceae", "Pinaceae"))
# plot_df$abundances <- 0
colnames(plot_df) <- c("year", "family")

## cumulative number of records per year per taxonomic family
obsyears <- aggregate(day ~ year + family, GBIF_sf, FUN = length)
colnames(obsyears)[3] <- "abundance"

## merging plotting skeleton and obsyears
plot_df <- merge.data.frame(plot_df, obsyears, by = c("family", "year"), all = TRUE)
plot_df$abundance[is.na(plot_df$abundance)] <- 0

## calculate cumulative records
plot_df$cumulative <- c(
  cumsum(plot_df$abundance[plot_df$family == unique(plot_df$family)[1]]),
  cumsum(plot_df$abundance[plot_df$family == unique(plot_df$family)[2]])
)

## make plot
ggplot(data = plot_df, aes(x = as.factor(year), y = cumulative)) +
  geom_bar(stat = "identity", aes(fill = "black")) +
  geom_bar(stat = "identity", aes(y = abundance, fill = family)) +
  theme_bw() +
  scale_fill_manual(
    name = "Records",
    values = c("black" = "black", "Pinaceae" = "forestgreen", "Fagaceae" = "darkorange"), labels = c("Cumulative Total", "New per Year (Fagaceae)", "New per Year (Pinaceae)")
  ) +
  facet_wrap(~family) +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = -60, vjust = 0.2, hjust = 0)
  ) +
  labs(x = "Year", y = "Records for Fagaceae and Pinaceae across Germany starting 1970")
```

<img src="SeasonalSchool-datahandling_files/figure-html/unnamed-chunk-15-1.png" width="1440" />

{{% alert success %}}
Some basic visualisations when dealing with GBIF mediated data are now open to you.
{{% /alert %}}

## Citing Data Downloaded via GBIF

When using data mediated by GBIF, you are benefitting from the hard work of many who have come before you. THese peoples' efforts ought to be credited in the role they played facilitating your work. Likewise, when or if you contribute data to our shared knowledge pool available via GBIF, you would surely want the same treatment. To properly give credit, GBIF creates a **DOI** (digital object identifier) for each query submitted to it. You can (and should) cite this.

Additionally, citing the DOI will also make it so the work you do based off of GBIF mediated data will be reproducible - the hallmark of proper science.

{{% alert warning %}}
**Citing the DOI** of your GBIF query is **not optional**!
{{% /alert %}}

### Citing the data download

Remember when we saved the details of the GBIF data request in the previous section? This is where we bring it back in. Let's load the file:


``` r
load("NFDI4Bio_GBIF.RData") # this loads the object called "res"
```

To cite the data query we have made and thus ensure reproducibility of our work and give proper credit to data curators, we just need to include the following reference in our writing:


``` r
paste("GBIF Occurrence Download", occ_download_meta(res)$doi, "accessed via GBIF.org on", substr(occ_download_meta(res)$created, 1, 10))
```

```
## [1] "GBIF Occurrence Download 10.15468/dl.gejvsf accessed via GBIF.org on 2024-11-25"
```

### Citing a derived data set

Often times, you will heavily modify the data you have obtained through GBIF. As a matter of fact, we have done so here. In these cases, you might want to consider registering the data you actually work with as a derived dataset on GBIF to refine credit forwarding from your work.

Derived datasets are citable records of GBIF-mediated occurrence data derived either from:
- a GBIF.org download that has been filtered/reduced significantly, or
- data accessed through a cloud service, e.g. Microsoft AI for Earth (Azure), or
- data obtained by any means for which no DOI was assigned, but one is required (e.g. third-party tools accessing the GBIF search API)

For our purposes, we have used a heavily subsetted data download - just look at the number of records in the original and the subsetted data:

``` r
## Loading the data
Original_df <- read.csv("NFDI4Bio_GBIF.csv")
Final_df <- read.csv("NFDI4Bio_GBIF_subset.csv")

## making a plot
ggplot(data.frame(
  Records = c(nrow(Original_df), nrow(Final_df)),
  Data = c("Original", "Subset")
), aes(y = Data, x = Records)) +
  geom_bar(stat = "identity", fill = "#4f004e") +
  theme_bw(base_size = 12)
```

<img src="SeasonalSchool-datahandling_files/figure-html/barsdatasubset-1.png" width="1440" />

To correctly reference the underlying data sets mediated by GBIF and contributing to our final dataset, we should register a derived data set. When created, a derived dataset is assigned a unique DOI that can be used to cite the data. To create a derived dataset you will need to authenticate using a GBIF.org account and provide:  
- a title of the dataset,
- a list of the GBIF datasets (by DOI or datasetKey) from which the data originated, ideally with counts of how many records each dataset contributed,
- a persistent URL of where the extracted dataset can be accessed,
- a description of how the dataset was prepared,
- (optional) the GBIF download DOI, if the dataset is derived from an existing download , and
- (optional) a date for when the derived dataset should be registered if not immediately .

Arguably, the most important aspect here is the list of GBIF datasets and the counts of data used per dataset. First, let's isolate how many datasets contributed to our original data and the subsetted, final data:

``` r
## Original
length(unique(Original_df$datasetKey))
```

```
## [1] 580
```

``` r
## Subsetted
length(unique(Final_df$datasetKey))
```

```
## [1] 13
```

There is a signifcant decrease in number of datasets which make up our final data product post-subsetting. Subsequently, to prepare a potential query to GBIF to establish a derived data set for us, we can tabulate the counts of records per dataset key as follows:

``` r
knitr::kable(table(Final_df$datasetKey))
```



|Var1                                 |  Freq|
|:------------------------------------|-----:|
|04871911-1b00-41f3-8dc6-fc0cea421f96 |     9|
|14d5676a-2c54-4f94-9023-1e8dcd822aa0 | 10821|
|2e102194-f384-4712-89a4-5db7a3fc409a | 13527|
|3580c8a0-33eb-40ac-b172-995854622428 |   111|
|50c9509d-22c7-4a22-a47d-8c48425ef4a7 |  2872|
|6ac3f774-d9fb-4796-b3e9-92bf6c81c084 | 28748|
|7a3679ef-5582-4aaa-81f0-8c2545cafc81 |   825|
|857bce66-f762-11e1-a439-00145eb45e9a |    63|
|8a863029-f435-446a-821e-275f4f641165 |  1135|
|cf910a71-5c97-40b9-b10c-7d9a1eca2c85 |    21|
|e1beb83c-9b83-4d17-ac5e-d24e09507ec5 |    20|
|e6c97f6e-e952-11e2-961f-00145eb45e9a |    50|
|e6fb3d46-977a-4deb-99be-e8493024feb2 |   102|

Finally, we can head to the [registration for derived data sets](https://www.gbif.org/derived-dataset/register) at GBIF and supply our information:

<img src="/courses/gbif/gbif-derived.png" width="100%"/></a>

{{% alert success %}}
Now you know how to properly cite the data you obtain from GBIF to ensure reproducibility and proper accreditation of your work.
{{% /alert %}}

# Session Info

```
## R version 4.4.0 (2024-04-24 ucrt)
## Platform: x86_64-w64-mingw32/x64
## Running under: Windows 11 x64 (build 22631)
## 
## Matrix products: default
## 
## 
## locale:
## [1] C
## 
## time zone: Europe/Oslo
## tzcode source: internal
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] rnaturalearthdata_1.0.0 rnaturalearth_1.0.1     sp_2.1-4               
## [4] sf_1.0-17               cowplot_1.1.3           ggplot2_3.5.1          
## [7] knitr_1.48              rgbif_3.8.1            
## 
## loaded via a namespace (and not attached):
##  [1] gtable_0.3.6                  xfun_0.47                    
##  [3] bslib_0.8.0                   lattice_0.22-6               
##  [5] vctrs_0.6.5                   tools_4.4.0                  
##  [7] generics_0.1.3                curl_5.2.2                   
##  [9] tibble_3.2.1                  proxy_0.4-27                 
## [11] fansi_1.0.6                   highr_0.11                   
## [13] pkgconfig_2.0.3               R.oo_1.26.0                  
## [15] KernSmooth_2.23-22            data.table_1.16.0            
## [17] lifecycle_1.0.4               R.cache_0.16.0               
## [19] compiler_4.4.0                farver_2.1.2                 
## [21] stringr_1.5.1                 munsell_0.5.1                
## [23] terra_1.7-78                  codetools_0.2-20             
## [25] htmltools_0.5.8.1             class_7.3-22                 
## [27] sass_0.4.9                    yaml_2.3.10                  
## [29] lazyeval_0.2.2                pillar_1.9.0                 
## [31] jquerylib_0.1.4               whisker_0.4.1                
## [33] R.utils_2.12.3                classInt_0.4-10              
## [35] cachem_1.1.0                  wk_0.9.4                     
## [37] styler_1.10.3                 tidyselect_1.2.1             
## [39] digest_0.6.37                 stringi_1.8.4                
## [41] dplyr_1.1.4                   purrr_1.0.2                  
## [43] bookdown_0.40                 labeling_0.4.3               
## [45] fastmap_1.2.0                 grid_4.4.0                   
## [47] colorspace_2.1-1              cli_3.6.3                    
## [49] magrittr_2.0.3                triebeard_0.4.1              
## [51] crul_1.5.0                    utf8_1.2.4                   
## [53] e1071_1.7-16                  withr_3.0.2                  
## [55] scales_1.3.0                  oai_0.4.0                    
## [57] rmarkdown_2.28                httr_1.4.7                   
## [59] blogdown_1.19                 rnaturalearthhires_1.0.0.9000
## [61] R.methodsS3_1.8.2             evaluate_0.24.0              
## [63] viridisLite_0.4.2             s2_1.1.7                     
## [65] urltools_1.7.3                rlang_1.1.4                  
## [67] Rcpp_1.0.13                   httpcode_0.3.0               
## [69] glue_1.7.0                    DBI_1.2.3                    
## [71] xml2_1.3.6                    jsonlite_1.8.8               
## [73] R6_2.5.1                      plyr_1.8.9                   
## [75] units_0.8-5
```
