---
title: "An Introduction to GBIF & rgbif"
author: Erik Kusch
date: '2023-21-05'
slug: theory
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
subtitle: ""
summary: 'An introduction to the Global Biodiversity Information Facility (GBIF), its organisation, data, data standards, and accrediation scheme.'
authors: []
lastmod: '2023-21-05T20:00:00+01:00'
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
    weight: 2
weight: 2
---



To obtain billions of biodiversity data records at global coverage, one may obtain data from the The Global Biodiversity Information Facility (GBIF) using the `rgbif` package. Both are complex. Here I present and link to material for a deeper understanding of them.

## The Global Biodiversity Information Facility (GBIF)

Within these slides, I present the organisation of GBIF, the data it makes available, how to discover relevant data, query download thereof, what to be aware of with regards to data quality, richness and availability, as well as how GBIF handles accreditation of the data it mediates. Simply click the screenshot of the presentation below:
<a href="http://htmlpreview.github.io/?https://github.com/ErikKusch/Homepage/blob/master/content/courses/gbif/GBIFWorkshop_LivingNorway_presentation.html" target="_blank"><img src="/courses/gbif/featured.png" width="900"/></a>


## The `rbif` Package

The `rgbif` package has been designed to offer a programmatic interface to the GBIF API and enable:

1. Data discovery
2. Data query and download

The following material in this workshop is aimed at giving an overview to the functionality in `rgbif` and has been heavily inspired by the [`rgbif` website](https://docs.ropensci.org/rgbif/index.html) and a [previous GBIF workshop](https://gbif-europe.github.io/nordic_oikos_2018_r/).
