---
date: "2020-12-28T00:00:00Z"
external_link: https://pure.au.dk/portal/en/projects/biological-response-rates-to-current-rates-of-enviormnetal-changes(0c2fcfa4-5e72-4361-a448-6e5f4818d62a).html
authors:
- ErikKusch
links: 
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/KuschErik
- icon: github
  icon_pack: fab
  name: Download
  url: https://github.com/ErikKusch/PhD-Project
- icon: researchgate
  icon_pack: fab
  name: Updates
  url: https://www.researchgate.net/project/Varying-Relationships-between-Vegetation-Memory-and-Climate-across-Global-Drylands
image:
  caption: Global Animal Species Richness
  focal_point: Smart
summary: My PhD project is a part of this greater research framework within which my colleagues and I investigate how species compositions and interactions are shaped.
tags:
- Biological Networks
- Resilience
- PhD
- Active
title: BIOlogical response RATES to current rates of environmental changes
---

Throughout my [PhD project](/project/phd-packages/) which this is the parent project to, I aim to understand and predict the consequences of differential extinctions across trophic levels on a global scale. In doing so, I am focusing on drivers of differential extinctions, species-associations, extinction debt, biodiversity changes, shifts in functional communities, as well as ecosystem processes. These are my revised plans following my initial project ideas.

# Co-Occurrences & Species-Interactions
Firstly, I collect(ed) species-occurrence records from a variety of data sources and aggregate(d) these to global and local co-occurrence matrices at the species-level. Subsequently, I use(d) additional data such as phylogenies and trait expressions of all species included in my analysis to delineate species-interactions and build global as well as local species-dependence networks. I then compare(d) these in terms of their informative quality and network topology to elucidate the pros and cons of using different data sources and approaches to delineate species-networks.

# Climate Data & Extinction Risks
My PhD project leverage(s/d) state-of-the art climate reanalysis data which vastly improves on previously utilised legacy data sets of macroecology (see my `KrigR` package from my ([KrigR - Downloading and Downscaling of ERA5(-Land) data using R]({{< ref "project/KrigR" >}}) porject for more information). I use(d) these spatio-temporal data sets to assess local and global risk of extinction for each species contained within my analysis by virtue of safety margins, range shifts/contractions, or IUCN red list status.

# Extinction Debt Effects
Using the estimates of species extinctions, I perturb(ed) local and global species-dependence networks by removing vertices of species estimated to go extinct. This generates an extinction cascade (also known as extinction debt) which I analyse(d) according to two different approaches:
- **Within Trophic** Levels – This step look(s/ed) at changes in local species richness and species-dependence network architecture for each trophic level individually (e.g. only considering plant networks).
- **Across Trophic** Levels – These are/were assessed by quantifying the changes in cross-trophic species networks which aim to leverage as much data as possible while offering the highest spatial coverage possible.

