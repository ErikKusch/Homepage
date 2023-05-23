---
title: "Working with the GBIF Backbone"
author: Erik Kusch
date: '2023-05-21'
slug: backbone
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: "Name Resolving GBIF for Mediated Data"
summary: 'A quick overview of name resolution with `rgbif`.'
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
    weight: 4
weight: 4
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
  "rnaturalearth", # for shapefile access
  "wicket" # for transforming polygons into wkt format; may have to run: remotes::install_version("wicket", "0.4.0")
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
##         rgbif         knitr rnaturalearth        wicket 
##          TRUE          TRUE          TRUE          TRUE
```

```r
options(gbif_user = "my gbif username")
options(gbif_email = "my registred gbif e-mail")
options(gbif_pwd = "my gbif password")
```
</details> 
{{% /alert %}}

The ways in which we record and report species identities is arguably more varied than recorded species identities themselves. For example, while the binomial nomenclature is widely adopted across scientific research, the same species may be still be referred to via different binomial names with descriptor or subspecies suffixes. In addition, particularly when dealing with citizen science data, species names may not always be recorded according to the binomial nomenclature but rather via vernacular names.

The [GBIF Backbone Taxonomy](https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c) circumvents these issues on the data-management side as it assigns unambiguous keys to taxonomic units of interest - these are known as **taxonKeys**.

{{% alert danger %}}
GBIF recognises taxonomic units via unique identifiers which are linked to more commonly used names and descriptors.
{{% /alert %}}

Matching between what you require and how GBIF indexes its data is therefore vital to ensure you retrieve the data you need accurately and in full. To discover data themselves, we first need to discover their corresponding relevant identifiers.

## Finding the **taxonKeys**

To identify the relevant taxonKeys for our [study organism](/courses/gbif/#study-organism) (*Calluna vulgaris*), we will use the `name_backbone(...)` function to match our binomial species name to the GBIF backbone as follows:


```r
sp_name <- "Calluna vulgaris"
sp_backbone <- name_backbone(name = sp_name)
```
Let's look at the output of this function call:

```r
knitr::kable(sp_backbone)
```



| usageKey|scientificName             |canonicalName    |rank    |status   | confidence|matchType |kingdom |phylum       |order    |family    |genus   |species          | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey| speciesKey|synonym |class         |verbatim_name    |
|--------:|:--------------------------|:----------------|:-------|:--------|----------:|:---------|:-------|:------------|:--------|:---------|:-------|:----------------|----------:|---------:|--------:|--------:|---------:|--------:|----------:|:-------|:-------------|:----------------|
|  2882482|Calluna vulgaris (L.) Hull |Calluna vulgaris |SPECIES |ACCEPTED |         97|EXACT     |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |Calluna vulgaris |          6|   7707728|      220|     1353|      2505|  2882481|    2882482|FALSE   |Magnoliopsida |Calluna vulgaris |

The data frame / `tibble` returned by the `name_backbone(...)` function contains important information regarding the confidence and type of match achieved between the input species name and the GBIF backbone. In addition, it lists all relevant taxonKeys. Of particular to most use-cases are the following columns:

- `usageKey`: The taxonKey by which this species is indexed in the GBIF backbone.
- `matchType`: This can be either: 
  - EXACT: binomial input matched 1-1 to backbone
  - FUZZY: binomial input was matched to backbone assuming misspelling
  - HIGHERRANK: binomial input is not a species-level name, but indexes a higher-rank taxonomic group
  - NONE: no match could be made

Let's extract the `usageKey` of *Calluna vulgaris* in the GBIF backbone for later use in this workshop.

```r
sp_key <- sp_backbone$usageKey
sp_key
```

```
## [1] 2882482
```

{{% alert success %}}
We now have a unique identifier for *Caluna vulgaris* which we can use to query GBIF for data.
{{% /alert %}}

## Resolving Taxonomic Names

Not all species identities are as straightforwardly matched to the GBIF backbone and there is more information stored in the GBIF backbone which may be relevant to users. Here, I would like to spend some time delving further into these considerations.

### Matching Input to Backbone

To widen the backbone matching, we can set `verbose = TRUE` in the `name_backbone(...)` function. Doing so for *Calluna vulgaris*, we obtain the following:

```r
sp_backbone <- name_backbone(name = sp_name, verbose = TRUE)
knitr::kable(t(sp_backbone))
```



|                 |1                          |2                              |3                   |4                      |
|:----------------|:--------------------------|:------------------------------|:-------------------|:----------------------|
|usageKey         |2882482                    |8208549                        |3105380             |7918820                |
|scientificName   |Calluna vulgaris (L.) Hull |Calluna vulgaris Salisb., 1802 |Carlina vulgaris L. |Carlina vulgaris Schur |
|canonicalName    |Calluna vulgaris           |Calluna vulgaris               |Carlina vulgaris    |Carlina vulgaris       |
|rank             |SPECIES                    |SPECIES                        |SPECIES             |SPECIES                |
|status           |ACCEPTED                   |SYNONYM                        |ACCEPTED            |DOUBTFUL               |
|confidence       |97                         |97                             |70                  |64                     |
|matchType        |EXACT                      |EXACT                          |FUZZY               |FUZZY                  |
|kingdom          |Plantae                    |Plantae                        |Plantae             |Plantae                |
|phylum           |Tracheophyta               |Tracheophyta                   |Tracheophyta        |Tracheophyta           |
|order            |Ericales                   |Ericales                       |Asterales           |Asterales              |
|family           |Ericaceae                  |Ericaceae                      |Asteraceae          |Asteraceae             |
|genus            |Calluna                    |Calluna                        |Carlina             |Carlina                |
|species          |Calluna vulgaris           |Calluna vulgaris               |Carlina vulgaris    |Carlina vulgaris       |
|kingdomKey       |6                          |6                              |6                   |6                      |
|phylumKey        |7707728                    |7707728                        |7707728             |7707728                |
|classKey         |220                        |220                            |220                 |220                    |
|orderKey         |1353                       |1353                           |414                 |414                    |
|familyKey        |2505                       |2505                           |3065                |3065                   |
|genusKey         |2882481                    |2882481                        |3105349             |3105349                |
|speciesKey       |2882482                    |2882482                        |3105380             |7918820                |
|synonym          |FALSE                      |TRUE                           |FALSE               |FALSE                  |
|class            |Magnoliopsida              |Magnoliopsida                  |Magnoliopsida       |Magnoliopsida          |
|acceptedUsageKey |NA                         |2882482                        |NA                  |NA                     |
|verbatim_name    |Calluna vulgaris           |Calluna vulgaris               |Calluna vulgaris    |Calluna vulgaris       |

Here, you can see how fuzzy matching has resulted in an erroneous match with a different plant: *Carlina vulgaris* - the thistle - also a neat plant, but not the one we are after here.

### Competing Name Matches

By horribly misspelling our binomial input, we can coerce an output of HIGHERRANK match which now indexes the Genus itself:

```r
knitr::kable(name_backbone("Calluna vul", verbose = TRUE))
```



| usageKey|scientificName  |canonicalName |rank  |status   | confidence|matchType  |kingdom |phylum       |order    |family    |genus   | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey|synonym |class         |verbatim_name |
|--------:|:---------------|:-------------|:-----|:--------|----------:|:----------|:-------|:------------|:--------|:---------|:-------|----------:|---------:|--------:|--------:|---------:|--------:|:-------|:-------------|:-------------|
|  2882481|Calluna Salisb. |Calluna       |GENUS |ACCEPTED |         94|HIGHERRANK |Plantae |Tracheophyta |Ericales |Ericaceae |Calluna |          6|   7707728|      220|     1353|      2505|  2882481|FALSE   |Magnoliopsida |Calluna vul   |

To truly see how competing name identifiers can cause us to struggle identifying the correct `usageKey` we must turn away from *Calluna vulgaris*. Instead, let us look at *Glocianus punctiger* - a species of weevil:

```r
knitr::kable(name_backbone("Glocianus punctiger", verbose = TRUE))
```



| usageKey|scientificName                           |canonicalName       |rank    |status   | confidence|matchType  |kingdom  |phylum     |order      |family        | kingdomKey| phylumKey| classKey| orderKey| familyKey|synonym |class   | acceptedUsageKey|genus          |species                  | genusKey| speciesKey|verbatim_name       |
|--------:|:----------------------------------------|:-------------------|:-------|:--------|----------:|:----------|:--------|:----------|:----------|:-------------|----------:|---------:|--------:|--------:|---------:|:-------|:-------|----------------:|:--------------|:------------------------|--------:|----------:|:-------------------|
|     4239|Curculionidae                            |Curculionidae       |FAMILY  |ACCEPTED |         97|HIGHERRANK |Animalia |Arthropoda |Coleoptera |Curculionidae |          1|        54|      216|     1470|      4239|FALSE   |Insecta |               NA|NA             |NA                       |       NA|         NA|Glocianus punctiger |
|  4464480|Glocianus punctiger (C.R.Sahlberg, 1835) |Glocianus punctiger |SPECIES |SYNONYM  |         97|EXACT      |Animalia |Arthropoda |Coleoptera |Curculionidae |          1|        54|      216|     1470|      4239|TRUE    |Insecta |          1187423|Rhynchaenus    |Rhynchaenus punctiger    |  1187150|    1187423|Glocianus punctiger |
| 11356251|Glocianus punctiger (Gyllenhal, 1837)    |Glocianus punctiger |SPECIES |SYNONYM  |         97|EXACT      |Animalia |Arthropoda |Coleoptera |Curculionidae |          1|        54|      216|     1470|      4239|TRUE    |Insecta |          1178810|Ceuthorhynchus |Ceuthorhynchus punctiger |  8265946|    1178810|Glocianus punctiger |

Here, we find that there exist two competing identifiers for *Glocianus punctiger* in the GBIF backbone in accordance with their competing descriptors. To query data for all *Glocianus punctiger* records, we should thus always use the keys 4464480 and 11356251.

### Matching Names and Backbone for several Species

The above use of `name_backbone(...)` can be executed for multiple species at once using instead the `name_backbone_checklist(...)` function:

```r
checklist_df <- name_backbone_checklist(c(sp_name, "Glocianus punctiger"))
knitr::kable(checklist_df)
```



| usageKey|scientificName             |canonicalName    |rank    |status   | confidence|matchType  |kingdom  |phylum       |order      |family        |genus   |species          | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey| speciesKey|synonym |class         |verbatim_name       | verbatim_index|
|--------:|:--------------------------|:----------------|:-------|:--------|----------:|:----------|:--------|:------------|:----------|:-------------|:-------|:----------------|----------:|---------:|--------:|--------:|---------:|--------:|----------:|:-------|:-------------|:-------------------|--------------:|
|  2882482|Calluna vulgaris (L.) Hull |Calluna vulgaris |SPECIES |ACCEPTED |         97|EXACT      |Plantae  |Tracheophyta |Ericales   |Ericaceae     |Calluna |Calluna vulgaris |          6|   7707728|      220|     1353|      2505|  2882481|    2882482|FALSE   |Magnoliopsida |Calluna vulgaris    |              1|
|     4239|Curculionidae              |Curculionidae    |FAMILY  |ACCEPTED |         97|HIGHERRANK |Animalia |Arthropoda   |Coleoptera |Curculionidae |NA      |NA               |          1|        54|      216|     1470|      4239|       NA|         NA|FALSE   |Insecta       |Glocianus punctiger |              2|

{{% alert success %}}
It is best practise to carefully investigate the match between your binomial input and the GBIF backbone.
{{% /alert %}}

## Name Suggestions and Lookup

To catch other commonly used or relevant names for a species of interest, you can use the `name_suggest(...)` function. This is particularly useful when data mining publications or data sets for records which can be grouped to the same species although they might be recorded with different names:

```r
sp_suggest <- name_suggest(sp_name)$data
knitr::kable(t(head(sp_suggest)))
```



|              |                 |                 |                           |                         |                          |                         |
|:-------------|:----------------|:----------------|:--------------------------|:------------------------|:-------------------------|:------------------------|
|key           |2882482          |8208549          |11077703                   |7953575                  |12164569                  |9270560                  |
|canonicalName |Calluna vulgaris |Calluna vulgaris |Calluna vulgaris albiflora |Calluna vulgaris hirsuta |Calluna vulgaris pubesens |Calluna vulgaris hirsuta |
|rank          |SPECIES          |SPECIES          |VARIETY                    |VARIETY                  |VARIETY                   |VARIETY                  |
To trawl GBIF mediated data sets for records of a specific species, one may use the `name_lookup(...)` function:

```r
sp_lookup <- name_lookup(sp_name)$data
knitr::kable(head(sp_lookup))
```



|       key|scientificName             |datasetKey                           |  nubKey| parentKey|parent    |genus   |  genusKey|canonicalName    |nameType   |taxonomicStatus |origin | numDescendants| numOccurrences|habitats    |nomenclaturalStatus |threatStatuses |synonym | nameKey|kingdom |phylum       |order    |family    |species          | kingdomKey| phylumKey|  classKey|  orderKey| familyKey| speciesKey|authorship |rank    |class         |constituentKey | acceptedKey|accepted |publishedIn | basionymKey|basionym |accordingTo |
|---------:|:--------------------------|:------------------------------------|-------:|---------:|:---------|:-------|---------:|:----------------|:----------|:---------------|:------|--------------:|--------------:|:-----------|:-------------------|:--------------|:-------|-------:|:-------|:------------|:--------|:---------|:----------------|----------:|---------:|---------:|---------:|---------:|----------:|:----------|:-------|:-------------|:--------------|-----------:|:--------|:-----------|-----------:|:--------|:-----------|
| 164940665|Calluna vulgaris           |e1fd4493-a11a-438d-a27f-ca3ca5152f6b | 2882482| 209476827|Calluna   |Calluna | 209476827|Calluna vulgaris |SCIENTIFIC |ACCEPTED        |SOURCE |              0|              0|NA          |NA                  |NA             |FALSE   |      NA|NA      |NA           |NA       |NA        |NA               |         NA|        NA|        NA|        NA|        NA|         NA|NA         |NA      |NA            |NA             |          NA|NA       |NA          |          NA|NA       |NA          |
| 164940660|Calluna vulgaris           |e1fd4493-a11a-438d-a27f-ca3ca5152f6b | 2882482| 209476827|Calluna   |Calluna | 209476827|Calluna vulgaris |SCIENTIFIC |ACCEPTED        |SOURCE |              0|              0|NA          |NA                  |NA             |FALSE   |      NA|NA      |NA           |NA       |NA        |NA               |         NA|        NA|        NA|        NA|        NA|         NA|NA         |NA      |NA            |NA             |          NA|NA       |NA          |          NA|NA       |NA          |
| 164940666|Calluna vulgaris           |e1fd4493-a11a-438d-a27f-ca3ca5152f6b | 2882482| 209476827|Calluna   |Calluna | 209476827|Calluna vulgaris |SCIENTIFIC |ACCEPTED        |SOURCE |              0|              0|NA          |NA                  |NA             |FALSE   |      NA|NA      |NA           |NA       |NA        |NA               |         NA|        NA|        NA|        NA|        NA|         NA|NA         |NA      |NA            |NA             |          NA|NA       |NA          |          NA|NA       |NA          |
| 100222089|Calluna vulgaris           |b351a324-77c4-41c9-a909-f30f77268bc4 | 2882482|        NA|NA        |NA      |        NA|Calluna vulgaris |SCIENTIFIC |ACCEPTED        |SOURCE |              0|              0|NA          |NA                  |NA             |FALSE   |      NA|NA      |NA           |NA       |NA        |NA               |         NA|        NA|        NA|        NA|        NA|         NA|NA         |NA      |NA            |NA             |          NA|NA       |NA          |          NA|NA       |NA          |
| 162496909|Calluna vulgaris (L.) Hull |15147db1-27c3-49b5-9c69-c78d55a4b8ff | 2882482| 201308749|Ericaceae |NA      |        NA|Calluna vulgaris |SCIENTIFIC |ACCEPTED        |SOURCE |              0|              0|TERRESTRIAL |NA                  |NA             |FALSE   | 1843465|Plantae |Tracheophyta |Ericales |Ericaceae |Calluna vulgaris |  201308187| 201308188| 201308206| 201308743| 201308749|  162496909|(L.) Hull  |SPECIES |Magnoliopsida |NA             |          NA|NA       |NA          |          NA|NA       |NA          |
| 196388823|Calluna vulgaris (L.) Hull |b95e74e0-b772-430c-a729-9d56ce0182e2 | 2882482| 201288386|Ericaceae |NA      |        NA|Calluna vulgaris |SCIENTIFIC |ACCEPTED        |SOURCE |              0|              0|TERRESTRIAL |NA                  |NA             |FALSE   | 1843465|Plantae |Tracheophyta |Ericales |Ericaceae |Calluna vulgaris |  201288193| 201288216| 201288343| 201288379| 201288386|  196388823|(L.) Hull  |SPECIES |Magnoliopsida |NA             |          NA|NA       |NA          |          NA|NA       |NA          |

Here, we see clearly that *Calluna vulgaris* is recorded slightly differently in the datasets mediated by GBIF, but are indexed just fine for GBIF to find them for us.

Lastly, to gain a better understanding of the variety of vernacular names by which our species is know, we can use the `name_usage(..., data = "vernacularnames")` function as follows:

```r
sp_usage <- name_usage(key = sp_key, data = "vernacularNames")$data
knitr::kable(head(sp_usage))
```



| taxonKey|vernacularName |language |source                                                                                         | sourceTaxonKey|country |area |
|--------:|:--------------|:--------|:----------------------------------------------------------------------------------------------|--------------:|:-------|:----|
|  2882482|Besenheide     |         |Catalogue of Life Checklist                                                                    |      171596574|NA      |NA   |
|  2882482|Besenheide     |deu      |Taxon list of vascular plants from Bavaria, Germany compiled in the context of the BFL project |      116794811|DE      |NA   |
|  2882482|Callune        |fra      |DAISIE - Inventory of alien invasive species in Europe                                         |      159511353|NA      |NA   |
|  2882482|Heather        |         |Catalogue of Life Checklist                                                                    |      171596574|NA      |NA   |
|  2882482|Heather        |eng      |Checklist of Vermont Species                                                                   |      160786202|US      |NA   |
|  2882482|Heather        |eng      |Martha's Vineyard species checklist                                                            |      202603884|NA      |NA   |

`name_usage(...)` can be tuned to output different information and its documentation gives a good overview of this. Simply call `?name_usage` to look for yourself.
