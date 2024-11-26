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
lastmod: '2024-11-06T20:00:00+01:00'
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
    parent: LivingNorway Open Science
    weight: 1
weight: 4
---



{{% alert normal %}}
<details>
  <summary>Preamble, Package-Loading, and GBIF API Credential Registering (click here):</summary>

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
  "rgbif",
  "knitr" # for rmarkdown table visualisations
)
## executing install & load for each package
sapply(package_vec, install.load.package)
```

```
## rgbif knitr 
##  TRUE  TRUE
```

``` r
options(gbif_user = "my gbif username")
options(gbif_email = "my registred gbif e-mail")
options(gbif_pwd = "my gbif password")
```
</details> 
{{% /alert %}}

 
Most of the time, GBIF users query data for individual species so we will establish a comparable use-case here. For most of this material, I will be focussing on *Lagopus muta* - the rock ptarmigan (see below). I have particularly fond memories of these birds flying alongside an uncle of mine and I on a topptur-ski trip in Lofoten earlier this year. It also lends itself well to a demonstration of `rgbif` functionality.

<img src="/courses/gbif/Lagopus.png" width="900"/>

The ways in which we record and report species identities is arguably more varied than recorded species identities themselves. For example, while the binomial nomenclature is widely adopted across scientific research, the same species may be still be referred to via different binomial names with descriptor or subspecies suffixes. In addition, particularly when dealing with citizen science data, species names may not always be recorded according to the binomial nomenclature but rather via vernacular names.

The [GBIF Backbone Taxonomy](https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c) circumvents these issues on the data-management side as it assigns unambiguous keys to taxonomic units of interest - these are known as **taxonKeys**.

{{% alert danger %}}
GBIF recognises taxonomic units via unique identifiers which are linked to more commonly used names and descriptors.
{{% /alert %}}

Matching between what you require and how GBIF indexes its data is therefore vital to ensure you retrieve the data you need accurately and in full. To discover data themselves, we first need to discover their corresponding relevant identifiers.

## Finding the **taxonKeys**

To identify the relevant taxonKeys for our [study organism](/courses/gbif/#study-organism) (*Lagopus muta*), we will use the `name_backbone(...)` function to match our binomial species name to the GBIF backbone as follows:


``` r
sp_name <- "Lagopus muta"
sp_backbone <- name_backbone(name = sp_name)
```
Let's look at the output of this function call:

``` r
knitr::kable(sp_backbone)
```



| usageKey|scientificName              |canonicalName |rank    |status   | confidence|matchType |kingdom  |phylum   |order       |family      |genus   |species      | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey| speciesKey|synonym |class |verbatim_name |
|--------:|:---------------------------|:-------------|:-------|:--------|----------:|:---------|:--------|:--------|:-----------|:-----------|:-------|:------------|----------:|---------:|--------:|--------:|---------:|--------:|----------:|:-------|:-----|:-------------|
|  5227679|Lagopus muta (Montin, 1781) |Lagopus muta  |SPECIES |ACCEPTED |         99|EXACT     |Animalia |Chordata |Galliformes |Phasianidae |Lagopus |Lagopus muta |          1|        44|      212|      723|      9331|  2473369|    5227679|FALSE   |Aves  |Lagopus muta  |

The data frame / `tibble` returned by the `name_backbone(...)` function contains important information regarding the confidence and type of match achieved between the input species name and the GBIF backbone. In addition, it lists all relevant taxonKeys. Of particular to most use-cases are the following columns:

- `usageKey`: The taxonKey by which this species is indexed in the GBIF backbone.
- `matchType`: This can be either: 
  - EXACT: binomial input matched 1-1 to backbone
  - FUZZY: binomial input was matched to backbone assuming misspelling
  - HIGHERRANK: binomial input is not a species-level name, but indexes a higher-rank taxonomic group
  - NONE: no match could be made

Let's extract the `usageKey` of *Lagopus muta* in the GBIF backbone for later use in this workshop.

``` r
sp_key <- sp_backbone$usageKey
sp_key
```

```
## [1] 5227679
```

{{% alert success %}}
We now have a unique identifier for *Lagpus muta* which we can use to query GBIF for data.
{{% /alert %}}

## Resolving Taxonomic Names

Not all species identities are as straightforwardly matched to the GBIF backbone and there is more information stored in the GBIF backbone which may be relevant to users. Here, I would like to spend some time delving further into these considerations.

### Matching Input to Backbone

To widen the backbone matching, we can set `verbose = TRUE` in the `name_backbone(...)` function. Doing so for *Lagopus muta*, we obtain the following:

``` r
sp_backbone <- name_backbone(name = sp_name, verbose = TRUE)
knitr::kable(sp_backbone)
```



| usageKey|scientificName              |canonicalName |rank    |status   | confidence|matchType |kingdom  |phylum   |order       |family      |genus   |species      | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey| speciesKey|synonym |class |verbatim_name |
|--------:|:---------------------------|:-------------|:-------|:--------|----------:|:---------|:--------|:--------|:-----------|:-----------|:-------|:------------|----------:|---------:|--------:|--------:|---------:|--------:|----------:|:-------|:-----|:-------------|
|  5227679|Lagopus muta (Montin, 1781) |Lagopus muta  |SPECIES |ACCEPTED |         99|EXACT     |Animalia |Chordata |Galliformes |Phasianidae |Lagopus |Lagopus muta |          1|        44|      212|      723|      9331|  2473369|    5227679|FALSE   |Aves  |Lagopus muta  |

Seems like, even with widened backbone matching, *Lagopus muta* is precise enough of a specification for there to be one direct match.

To demonstrate how this widened backbone matching can result in multiple matches, let's consider *Calluna vulgaris* - the common heather and my favourite plant:

``` r
sp_backbone2 <- name_backbone(name = "Calluna vulgaris", verbose = TRUE)
knitr::kable(t(sp_backbone2))
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

Here, you can see how fuzzy matching has resulted in an erroneous match with a different plant: *Carlina vulgaris* - the thistle - also a neat plant, but not the one I was after here.

### Competing Name Matches

By horribly misspelling our binomial input, we can coerce an output of match type FUZZY (a match achieved with deviations to the supplied string) or HIGHERRANK  (a match indexing the Genus itself):

``` r
knitr::kable(name_backbone("Lagopus mut", verbose = TRUE))
```



| confidence|matchType |synonym | usageKey|scientificName                 |canonicalName |rank  |status   |kingdom  |phylum       |order       |family         |genus        | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey|class         | acceptedUsageKey|verbatim_name |
|----------:|:---------|:-------|--------:|:------------------------------|:-------------|:-----|:--------|:--------|:------------|:-----------|:--------------|:------------|----------:|---------:|--------:|--------:|---------:|--------:|:-------------|----------------:|:-------------|
|        100|NONE      |FALSE   |       NA|NA                             |NA            |NA    |NA       |NA       |NA           |NA          |NA             |NA           |         NA|        NA|       NA|       NA|        NA|       NA|NA            |               NA|Lagopus mut   |
|         69|EXACT     |FALSE   |  2473369|Lagopus Brisson, 1760          |Lagopus       |GENUS |ACCEPTED |Animalia |Chordata     |Galliformes |Phasianidae    |Lagopus      |          1|        44|      212|      723|      9331|  2473369|Aves          |               NA|Lagopus mut   |
|         68|EXACT     |TRUE    |  3233696|Lagopus (Gren. & Godr.) Fourr. |Lagopus       |GENUS |SYNONYM  |Plantae  |Tracheophyta |Lamiales    |Plantaginaceae |Plantago     |          6|   7707728|      220|      408|      2420|  3189695|Magnoliopsida |          3189695|Lagopus mut   |
|         68|EXACT     |TRUE    |  3233247|Lagopus Bernh.                 |Lagopus       |GENUS |SYNONYM  |Plantae  |Tracheophyta |Fabales     |Fabaceae       |Trifolium    |          6|   7707728|      220|     1370|      5386|  2973363|Magnoliopsida |          2973363|Lagopus mut   |
|         68|EXACT     |TRUE    |  8132572|Lagopus Hill                   |Lagopus       |GENUS |SYNONYM  |Plantae  |Tracheophyta |Fabales     |Fabaceae       |Trifolium    |          6|   7707728|      220|     1370|      5386|  2973363|Magnoliopsida |          2973363|Lagopus mut   |
|         68|EXACT     |TRUE    |  6007644|Lagopus Reichenbach, 1817      |Lagopus       |GENUS |SYNONYM  |Animalia |Arthropoda   |Lepidoptera |Noctuidae      |Callopistria |          1|        54|      216|      797|      7015|  8875134|Insecta       |          8875134|Lagopus mut   |
|         43|FUZZY     |TRUE    |  4825684|Lagomus McEnery, 1859          |Lagomus       |GENUS |SYNONYM  |Animalia |Chordata     |Lagomorpha  |Prolagidae     |Prolagus     |          1|        44|      359|      785|      5468|  2436678|Mammalia      |          2436678|Lagopus mut   |
|         38|FUZZY     |FALSE   |  4834660|Lagodus Pomel, 1852            |Lagodus       |GENUS |DOUBTFUL |Animalia |Chordata     |NA          |NA             |Lagodus      |          1|        44|      359|       NA|        NA|  4834660|Mammalia      |               NA|Lagopus mut   |

To truly see how competing name identifiers can cause us to struggle identifying the correct `usageKey` we must turn away from *Lagopus muta*. Instead, let us look at *Glocianus punctiger* - a species of weevil:

``` r
knitr::kable(name_backbone("Glocianus punctiger", verbose = TRUE))
```



| usageKey|scientificName                           |canonicalName       |rank    |status   | confidence|matchType  |kingdom  |phylum     |order      |family        | kingdomKey| phylumKey| classKey| orderKey| familyKey|synonym |class   | acceptedUsageKey|genus          |species                  | genusKey| speciesKey|verbatim_name       |
|--------:|:----------------------------------------|:-------------------|:-------|:--------|----------:|:----------|:--------|:----------|:----------|:-------------|----------:|---------:|--------:|--------:|---------:|:-------|:-------|----------------:|:--------------|:------------------------|--------:|----------:|:-------------------|
|     4239|Curculionidae                            |Curculionidae       |FAMILY  |ACCEPTED |         97|HIGHERRANK |Animalia |Arthropoda |Coleoptera |Curculionidae |          1|        54|      216|     1470|      4239|FALSE   |Insecta |               NA|NA             |NA                       |       NA|         NA|Glocianus punctiger |
| 11356251|Glocianus punctiger (C.R.Sahlberg, 1835) |Glocianus punctiger |SPECIES |SYNONYM  |         97|EXACT      |Animalia |Arthropoda |Coleoptera |Curculionidae |          1|        54|      216|     1470|      4239|TRUE    |Insecta |          1187423|Rhynchaenus    |Rhynchaenus punctiger    |  1187150|    1187423|Glocianus punctiger |
|  4464480|Glocianus punctiger (Gyllenhal, 1837)    |Glocianus punctiger |SPECIES |SYNONYM  |         97|EXACT      |Animalia |Arthropoda |Coleoptera |Curculionidae |          1|        54|      216|     1470|      4239|TRUE    |Insecta |          1178810|Ceuthorhynchus |Ceuthorhynchus punctiger |  8265946|    1178810|Glocianus punctiger |

Here, we find that there exist two competing identifiers for *Glocianus punctiger* in the GBIF backbone in accordance with their competing descriptors. To query data for all *Glocianus punctiger* records, we should thus always use the keys 11356251 and 4464480.

### Matching Names and Backbone for several Species

The above use of `name_backbone(...)` can be executed for multiple species at once using instead the `name_backbone_checklist(...)` function. So let's do so for our target species as well as my favourite plant:

``` r
checklist_df <- name_backbone_checklist(c(sp_name, "Calluna vulgaris"))
knitr::kable(checklist_df)
```



| usageKey|scientificName              |canonicalName    |rank    |status   | confidence|matchType |kingdom  |phylum       |order       |family      |genus   |species          | kingdomKey| phylumKey| classKey| orderKey| familyKey| genusKey| speciesKey|synonym |class         |verbatim_name    | verbatim_index|
|--------:|:---------------------------|:----------------|:-------|:--------|----------:|:---------|:--------|:------------|:-----------|:-----------|:-------|:----------------|----------:|---------:|--------:|--------:|---------:|--------:|----------:|:-------|:-------------|:----------------|--------------:|
|  5227679|Lagopus muta (Montin, 1781) |Lagopus muta     |SPECIES |ACCEPTED |         99|EXACT     |Animalia |Chordata     |Galliformes |Phasianidae |Lagopus |Lagopus muta     |          1|        44|      212|      723|      9331|  2473369|    5227679|FALSE   |Aves          |Lagopus muta     |              1|
|  2882482|Calluna vulgaris (L.) Hull  |Calluna vulgaris |SPECIES |ACCEPTED |         97|EXACT     |Plantae  |Tracheophyta |Ericales    |Ericaceae   |Calluna |Calluna vulgaris |          6|   7707728|      220|     1353|      2505|  2882481|    2882482|FALSE   |Magnoliopsida |Calluna vulgaris |              2|

{{% alert success %}}
It is best practise to carefully investigate the match between your binomial input and the GBIF backbone.
{{% /alert %}}

## Name Suggestions and Lookup

To catch other commonly used or relevant names for a species of interest, you can use the `name_suggest(...)` function. This is particularly useful when data mining publications or data sets for records which can be grouped to the same species although they might be recorded with different names:

``` r
sp_suggest <- name_suggest(sp_name)$data
knitr::kable(t(head(sp_suggest)))
```



|              |             |                       |                    |                       |                        |                       |
|:-------------|:------------|:----------------------|:-------------------|:----------------------|:-----------------------|:----------------------|
|key           |5227679      |5227684                |5227713             |5227686                |5227681                 |5227692                |
|canonicalName |Lagopus muta |Lagopus muta rupestris |Lagopus muta welchi |Lagopus muta townsendi |Lagopus muta kurilensis |Lagopus muta helvetica |
|rank          |SPECIES      |SUBSPECIES             |SUBSPECIES          |SUBSPECIES             |SUBSPECIES              |SUBSPECIES             |

To trawl GBIF mediated data sets for records of a specific species, one may use the `name_lookup(...)` function:


``` r
sp_lookup <- name_lookup(sp_name)$data
knitr::kable(head(sp_lookup))
```



|       key|scientificName | nameKey|datasetKey                           |  nubKey| parentKey|parent      |kingdom  |order       |family      |species      | kingdomKey|  orderKey| familyKey| speciesKey|canonicalName |authorship |nameType   |taxonomicStatus |rank    |origin | numDescendants| numOccurrences|habitats |nomenclaturalStatus |threatStatuses  |synonym |phylum   |genus   | phylumKey|  classKey|  genusKey|class |taxonID |extinct |constituentKey |publishedIn | basionymKey|basionym |accordingTo | acceptedKey|accepted |
|---------:|:--------------|-------:|:------------------------------------|-------:|---------:|:-----------|:--------|:-----------|:-----------|:------------|----------:|---------:|---------:|----------:|:-------------|:----------|:----------|:---------------|:-------|:------|--------------:|--------------:|:--------|:-------------------|:---------------|:-------|:--------|:-------|---------:|---------:|---------:|:-----|:-------|:-------|:--------------|:-----------|-----------:|:--------|:-----------|-----------:|:--------|
| 123212008|Lagopus muta   | 5972798|a5dd063e-f45b-4a54-8b94-8fa3adf7f1e1 | 5227679| 167183824|Phasianidae |Animalia |Galliformes |Phasianidae |Lagopus muta |  167183684| 167183822| 167183824|  123212008|Lagopus muta  |           |SCIENTIFIC |ACCEPTED        |SPECIES |SOURCE |              0|              0|NA       |NA                  |NA              |FALSE   |NA       |NA      |        NA|        NA|        NA|NA    |NA      |NA      |NA             |NA          |          NA|NA       |NA          |          NA|NA       |
| 114449074|Lagopus muta   | 5972798|3772da2f-daa1-4f07-a438-15a881a2142c | 5227679| 183207232|Lagopus     |Animalia |Galliformes |Tetraonidae |NA           |  183203277| 183207227| 183207228|         NA|Lagopus muta  |           |SCIENTIFIC |ACCEPTED        |NA      |SOURCE |              0|              0|NA       |NA                  |NA              |FALSE   |Chordata |Lagopus | 183205906| 183206633| 183207232|Aves  |NA      |NA      |NA             |NA          |          NA|NA       |NA          |          NA|NA       |
| 133167086|Lagopus muta   | 5972798|47f16512-bf31-410f-b272-d151c996b2f6 | 5227679| 135274878|Phasianidae |Animalia |Galliformes |Phasianidae |Lagopus muta |  135274602| 135274874| 135274878|  133167086|Lagopus muta  |           |SCIENTIFIC |ACCEPTED        |SPECIES |SOURCE |              0|              0|NA       |NA                  |NA              |FALSE   |NA       |NA      |        NA| 135274603|        NA|Aves  |1613    |FALSE   |NA             |NA          |          NA|NA       |NA          |          NA|NA       |
| 119341248|Lagopus muta   | 5972798|4f1047ac-a19d-41a8-98eb-d968b2548b53 | 5227679|        NA|NA          |NA       |NA          |NA          |NA           |         NA|        NA|        NA|         NA|Lagopus muta  |           |SCIENTIFIC |ACCEPTED        |NA      |SOURCE |              0|              0|NA       |NA                  |NEAR_THREATENED |FALSE   |NA       |NA      |        NA|        NA|        NA|NA    |NA      |NA      |NA             |NA          |          NA|NA       |NA          |          NA|NA       |
| 104151733|Lagopus muta   |      NA|fab88965-e69d-4491-a04d-e3198b626e52 | 5227679| 104151714|Lagopus     |Metazoa  |Galliformes |Phasianidae |Lagopus muta |  103832354| 104149839| 104150497|  104151733|Lagopus muta  |NA         |SCIENTIFIC |ACCEPTED        |SPECIES |SOURCE |              0|              0|NA       |NA                  |NA              |FALSE   |Chordata |Lagopus | 103882489| 104106614| 104151714|Aves  |64668   |NA      |NA             |NA          |          NA|NA       |NA          |          NA|NA       |
| 177659687|Lagopus muta   |      NA|6b6b2923-0a10-4708-b170-5b7c611aceef | 5227679| 177659682|Lagopus     |Metazoa  |Galliformes |Phasianidae |Lagopus muta |  177651702| 177659367| 177659587|  177659687|Lagopus muta  |NA         |SCIENTIFIC |ACCEPTED        |SPECIES |SOURCE |              0|              0|NA       |NA                  |NA              |FALSE   |Chordata |Lagopus | 177654008| 177656782| 177659682|Aves  |64668   |NA      |NA             |NA          |          NA|NA       |NA          |          NA|NA       |

Here, we see clearly that *Lagopus muta* is recorded slightly differently in the datasets mediated by GBIF, but are indexed just fine for GBIF to find them for us.

Lastly, to gain a better understanding of the variety of vernacular names by which our species is know, we can use the `name_usage(..., data = "vernacularnames")` function as follows:


``` r
sp_usage <- name_usage(key = sp_key, data = "vernacularNames")$data
knitr::kable(head(sp_usage))
```



| taxonKey|vernacularName  |language |source                                                                   | sourceTaxonKey|country |area |preferred |
|--------:|:---------------|:--------|:------------------------------------------------------------------------|--------------:|:-------|:----|:---------|
|  5227679|Alpenschneehuhn |deu      |Multilingual IOC World Bird List, v11.2                                  |      123212008|NA      |NA   |NA        |
|  5227679|Alpenschneehuhn |deu      |Taxon list of animals with German names (worldwide) compiled at the SMNS |      116803956|DE      |NA   |NA        |
|  5227679|Alpenschneehuhn |deu      |EUNIS Biodiversity Database                                              |      101137652|NA      |NA   |NA        |
|  5227679|Alpensneeuwhoen |nld      |EUNIS Biodiversity Database                                              |      101137652|NA      |NA   |NA        |
|  5227679|Alpensneeuwhoen |nld      |Multilingual IOC World Bird List, v11.2                                  |      123212008|NA      |NA   |NA        |
|  5227679|Fjeldrype       |dan      |Multilingual IOC World Bird List, v11.2                                  |      123212008|NA      |NA   |NA        |

`name_usage(...)` can be tuned to output different information and its documentation gives a good overview of this. Simply call `?name_usage` to look for yourself.
