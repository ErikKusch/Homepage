---
date: "2020-12-28T00:00:00Z"
authors:
- ErikKusch
external_link: ""
image:
  caption: PhD WorkFlow
  focal_point: Smart
links:
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/KuschErik
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://github.com/ErikKusch/PhD-Project
- icon: researchgate
  icon_pack: fab
  name: Updates
  url: https://www.researchgate.net/project/Cross-Trophic-Effects-of-Differential-Extinctions
# slides: example
summary: My PhD project and its working packages.
tags:
- Biological Networks
- Resilience
- Climate Data
- Active
title: Effects of Biological Extinctions across Scales and Trophic Levels
url_code: ""
url_pdf: ""
url_slides: ""
url_video: ""
---


# Motivation
Throughout my PhD project, I aim to understand and predict the consequences of differential extinctions across trophic levels on a global scale. In doing so, I am focusing on drivers of differential extinctions, species-associations, extinction debt, biodiversity changes, shifts in functional communities, as well as ecosystem processes. These are my initial plans which have been set aside in favor of a revised PhD research project with a new set of work packages. My PhD project is a part of the greater [BIORATES](/project/biorates/) project.

# Description
1. **Co-Occurrences & Species-Interactions**. Firstly, I collect(ed) species range estimates from a variety of data sources and aggregate(d) these to global and local co-occurrence matrices at the species-level. Subsequently, I use additional data such as phylogenies and trait expressions of all species included in my analysis to delineate species-interactions and build global as well as local species-dependce networks.
2. **Climate Data & Extinction Risks**. My PhD project leverage(s/d) state-of-the art climate reanalysis data which vastly improves on previously utilised legacy data sets of macroecology (see my KrigR project for more information). I use(d) these spatio-temporal data sets to assess local and global risk of extinction for each species contained within my analysis by virtue of safety margins, range shifts/contractions, or IUCN red list status.
3. **Extinction Debt Effects**. Using the estimates of species extinctions, I perturb(ed) local and global species-dependence networks by removing vertices of species estimated to go extinct. This generates an extinction cascade (also known as extinction debt) which I analyse(d) on three different levels:
    - Biodiversity – This step look(s/ed) at changes in local species richness and species-dependence network architecture.
    - Functional Spaces – These are/were assessed by quantifying the changes in local functional trait hyperspaces.
    - Ecosystem Function – I am currently unsure how to link these up, but am hoping for a viable link to be establishable with my recent vegetation memory work.

# Work Packages

## Updated Plans
### Work Package 1 - `KrigR`
- Products:
    - R Package KrigR + KrigR paper
    - SDM comparison paper
- Resources:
    - Global and local data bases of species presence
    - ERA5 climate data
    - HWSD DEM product
- Deadline: 31/08/21

Within this work package, I am identifying the best practices of downscaling state-of-the-art climate data to biologically relevant spatial resolutions.

### Work Package 2 - Cross-Scale
- Products:
    - A set of species-networks based on different input data
    - “Cross-Scale Changes in Association Network Topology” paper
- Resources:
    - Global and local data bases of species presence:
      - PFTC data
      - sPlot, GFBI
      - GBIF
      - SDM outputs (e.g. IUCN, BirdLife, and BIEN)
    - Global and local data bases of trait expressions:
      - BirdLife
      - Phylacine
      - TRY
      - BIEN
    - Species phylogenies
- Deadline: 30/07/22

Within this work package, I am investigating the ups and downs of leveraging different data sources of varying quality and coverage for the purpose of establishing species-networks .

### Work Package 3 - Biodiversity Simplification
- Products:
    - Species-vulnerability proxies
    - “Cross-Scale Effects of Biodiversity Simplification/Reduction on Network Topology” paper
- Resources:
    - Outputs of Work Package 1 & 2
- Deadline: 30/07/22

Throughout this work package, I am building the synthesis of work packages 1 & 2 by analysing the consequences of simulated extinctions on species-dependence networks given species vulnerability and fine-scale climate projections. This work is carried out within trophic levels (e.g. plants and herbivores separately).

### Work Package 4 - Cross-Trophic Effects
- Products:
    - “Cross-Trophic Effects of Extinction Debt on Network Topology” paper
- Resources:
    - Outputs of Work Package 1, 2 & 3
- Deadline: 31/12/22

In this work package, I am investigating the consequences of differential extinctions and extinction debt across trophic levels (e.g. plants and herbivores in one network of species-dependence).

### Work Package 5 - Science Dissemination
- Products: PhD Diary, Presentations, Posters
- Resources: Outputs of all other Work Packages, This website
- Deadline: 15/01/23

I have elected to set aside some serious time for science communication throughout my PhD studies. This work package is the catalyst.

----------------------------------------------------------------------

## Initial Plans
### WP 1 - Co-Occurrences
- Products: Global co-occurence matrix, local species-dependency networks
- Resources: Global and local data bases of species presence
- Deadline: 13/11/20

Within this work package, I am establishing a global understanding of species-dependence on one-another from a data-driven standpoint.

### WP 2 - Prerequisites
- Products: Downscaling Method for climate data, measures of species vulnerability (i.e. extinction risk)
- Resources: Global and local data bases of species presence, ERA5 climate data, HWSD DEM product
- Deadline: 26/02/21

Within this work package, I am identifying the abiotic drivers of species vulnerability and best practices of downscaling those to biologically relevant spatial resolutions.

### WP 3 - Biodiversity
- Products: Estimate of global change of biodiversity patterns following simulated extinctions
- Resources: Outputs of Work Package 1 & 2
- Deadline: 15/05/21

Throughout this work package, I am building the synthesis of work packages 1 & 2 by analysing the consequences of simulated extinctions on species-dependence networks given species vulnerability and fine-scale climate projections.

### WP 4 - Function & Demography
- Products: Estimate of global changes of functional trait space patterns following simulated extinctions as well as changes in demographies of communities.
- Resources: Outputs of Work Package 1 & 2, Functional trait data and COM(P)ADRE data
- Deadline: 28/01/22
In this work package, I am investigating the consequences of differential extinctions and extinction debt to local expressions within functional trait spaces and along axes of life history variation.

### WP 5 - Ecosystem Functions & Processes
- Products: Estimate of global changes of ecosystem functioning and processes following simulated extinctions
- Resources: Outputs of Work Package 1 & 2, Measures of Ecosystem processes/functions
- Deadline: 14/10/22

This work package is aimed at understanding how extinctions and extinction debt may affect ecosystem services and processes of future biological landscapes.

### WP 6 - Science Dissemination
- Products: PhD Diary, Presentations, Posters
- Resources: Outputs of all other Work Packages, This website
- Deadline: 15/01/23

I have elected to set aside some serious time for science communication throughout my PhD studies. This work package is the catalyst.