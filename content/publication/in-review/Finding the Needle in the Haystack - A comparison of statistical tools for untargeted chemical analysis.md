---
title: Finding the "Needle in the Haystack" - A comparison of statistical tools for untargeted chemical analysis
abstract: Deciphering chemical cues and signals frequently resembles the search for a "needle in a haystack" of chemical compounds. Particularly in non-model vertebrate species, the complexity of chemical profiles combined with little prior knowledge about potential semiochemicals leads to various challenges, including the statistical analysis. Statistical tools need to be able to pinpoint accurately if and which compounds out of hundreds of candidates are associated with certain biological traits. We therefore investigated eight commonly used statistical methods (Analysis of Similarity, Mantel test, permutational MANOVA, Procrustes, GLMM, Random Forest classification, sparse Partial-least-squares discriminant analysis and Similarity Percentage analysis) for how they perform under the challenges of untargeted chemical analysis. We created more than 2000 simulated data sets that systematically varied in sample size, the number and intensity of compounds in a chemical profile, the number and intensity of compounds associated with a trait and the presence of noise. Four discrete and four continuous traits were included, half of which contained simulated associations with certain compounds while the other half did not. For each data set, we determined which compounds were found to be associated with these traits and compared the test results to the actually simulated associations. False positives were close to the nominal level for all tests in the control condition, but power to detect simulated associations varied. GLMMs with vectorized data matrix showed high power even when few or relatively small compounds were associated with a trait. Along with Random Forest classification, GLMMs also performed best in pinpointing which of the compounds were associated with the respective trait. Finally, we applied all statistical tests to real mammalian chemical profiles. Based on these analysis, we suggest that combining two to three statistical tests (e.g. GLMM, Analysis of Similarity, Random Forest Analysis) covers different analytical aspects best and allows for the most robust conclusions.
authors:
- Brigitte M. Weiß
- Erik Kusch
- Marlen Kücklich
- Anja Widdig
date: "2026-02-27T00:00:00Z"
doi: ""
featured: true
# projects:
publication: "Chemical Signals in Vertebrates 16. Cham: Springer."
# publication_short: ""
publication_types: # 1 = conference paper, 2 = journal article, 3 = preprint, 4 = conference paper, 5 = book, 6 = Book section, 7 = Thesis, 8 = patent
- "6"
# publishDate: ""
tags:
- Olfactory
- Method Comparison
- Biomarkers
# url_code: https://github.com/ErikKusch/Ecological-Network-Inference-Across-Scales
# url_dataset: ''
url_pdf: http://hdl.handle.net/21.11116/0000-0012-50B1-9
# url_poster: /media/poster/2020_ISEC/Poster - Global Dryland Vegetation Memory.pdf
# url_project: ""
# url_slides: ""
# url_source: '#'
# url_video: '#'
summary: Comparison of statistical approaches to delineating olfactory signals.
---