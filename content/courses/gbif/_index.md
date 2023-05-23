---
title: Accessing, handling, and referencing open biodiversity data using the Global Biodiversity Information Facility (GBIF)
linktitle: Motivation & Workshop
slug: overview
date: 2021-01-01
authors:
- ErikKusch
external_link: ""
summary: Workshop material introducing concepts and giving practical examples for obtaining GBIF data using `rgbif`. Presented at the Living Norway Colloquium 2023 in Trondheim.
categories:
  - GBIF
  - Biodiversity
  - Open Science
tags:
  - GBIF
  - Biodiversity
  - Open Science
math: true
type: docs
toc: true 
menu:
  gbif:
    parent: Introduction
    weight: 1
weight: 1
---

In the age of changes and threat to the Ecosphere at macroecological scales, big data has crystallized as a go-to tool for ecological research. To facilitate the creation of, access to, and referencing of contributors to such big data repositories, the Global Biodiversity Information Facility (GBIF) has established data streams that make readily available a wealth of biodiversity data. Navigating and accessing such large data sets and ensuring fair use and accreditation of observations can seem daunting. In this workshop, we will introduce GBIF, show how to navigate its data portal, demonstrate data streams to obtain and handle data programmatically, and communicate accreditation procedures. 

Throughout this workshop material, I present practical examples for obtaining GBIF data using `rgbif`. Much of this work has been directly inspired or adapted from the official [`rgbif` website](https://docs.ropensci.org/rgbif/index.html) and a [previous GBIF workshop](https://gbif-europe.github.io/nordic_oikos_2018_r/).

## Learning Goals

Throughout this workshop, you will be introduced to:  

1. The Global Biodiversity Information Facility (GBIF)
- What it is
- What data it makes available
- How to navigate the data
- How to query and obtain specific records
- What to consider with regards to data content, richness and quality
- How to reference and accredit GBIF-mediated data

2. The `rgbif` package
- Functionality for querying, accessing, and handling GBIF data programmatically
- Data handling practices in `R`

## Study Organism
Most of the time, GBIF users query data for individual species so we will establish a comparable use-case here. For most of this material, I will be focussing on *Calluna vulgaris* - the common heather. It is my favourite plant and lends itself well to a demonstration of `rgbif` functionality.

<img src="/courses/gbif/Calluna.png" width="900"/>

## Disclaimer
If you find any typos in my material, are unhappy with some of what or how I am presenting or simply unclear about thing, do not hesitate to [contact me](/about/#contact).

All the best,  
Erik
