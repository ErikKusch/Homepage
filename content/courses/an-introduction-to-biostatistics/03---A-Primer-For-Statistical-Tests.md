---
title: "A Primer For Statistical Tests"
subtitle: 'Getting to Terms With Variables'
author: "Erik Kusch"
date: "2020-06-10"
slug: A Primer For Statistical Tests
categories: [An Introduction to Biostatistics]
tags: [R, Statistics]
summary: 'These are the solutions to the exercises contained within the handout to A Primer For Statistical Tests which walks you through the basics of variables, their scales and distributions. Keep in mind that there is probably a myriad of other ways to reach the same conclusions as presented in these solutions.'
authors: [Erik Kusch]
lastmod: '2020-06-10'
featured: no
projects:
output:
  blogdown::html_page:
    keep_md: true
    # toc: true
    # toc_depth: 2
    # number_sections: false
    fig_width: 6
linktitle: 03 - A Primer For Statistical Tests
menu:
  example:
    parent: Sessions
    weight: 3
toc: true
type: docs
weight: 3
---
 


## Theory
These are the solutions to the exercises contained within the handout to A Primer For Statistical Tests which walks you through the basics of variables, their scales and distributions. Keep in mind that there is probably a myriad of other ways to reach the same conclusions as presented in these solutions.

I have prepared some I have prepared some  {{< staticref "https://htmlpreview.github.io/?https://github.com/ErikKusch/Homepage/blob/master/static/courses/an-introduction-to-biostatistics/03---A-Primer-For-Statistical-Tests_Handout.html" "newtab" >}} Lecture Slides {{< /staticref >}} for this session.

## Data
Find the data for this exercise {{< staticref "https://github.com/ErikKusch/Homepage/raw/master/static/courses/an-introduction-to-biostatistics/Data/Primer.RData" "newtab" >}} here{{< /staticref >}}.

## Loading the `R` Environment Object 

```r
load("Data/Primer.RData")  # load data file from Data folder
```

## Variables
### Finding Variables 

```r
ls()  # list all elements in working environment
```

```
## [1] "Colour"               "Depth"                "IndividualsPassingBy"
## [4] "Length"               "Reproducing"          "Sex"                 
## [7] "Size"                 "Temperature"
```
### `Colour`

```r
class(Colour)  # mode
```

```
## [1] "character"
```

```r
barplot(table(Colour))  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VColour-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | character |
| Which scale? | Nominal |
| What's implied? | Categorical data that can't be ordered |
| Does data fit scale? | Yes |



### `Depth` 

```r
class(Depth)  # mode
```

```
## [1] "numeric"
```

```r
barplot(Depth)  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VDepth-1.png" width="576" />


| Question | Answer |
|-----:|:----|
| Mode? | numeric |
| Which scale? | Interval/Discrete |
| What's implied? | Continuous data with a non-absence point of origin |
| Does data fit scale? | Debatable (is 0 depth absence of depth?) |



### `IndividualsPassingBy` 

```r
class(IndividualsPassingBy)  # mode
```

```
## [1] "integer"
```

```r
barplot(IndividualsPassingBy)  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VIndPass-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | integer |
| Which scale? | Integer |
| What's implied? | Only integer numbers with an absence point of origin |
| Does data fit scale? | Yes |



### `Length` 

```r
class(Length)  # mode
```

```
## [1] "numeric"
```

```r
barplot(Length)  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VLength-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | numeric |
| Which scale? | Relation/Ratio |
| What's implied? | Continuous data with an absence point of origin |
| Does data fit scale? | Yes |



### `Reproducing` 

```r
class(Reproducing)  # mode
```

```
## [1] "integer"
```

```r
barplot(Reproducing)  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VRepro-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | integer |
| Which scale? | Integer |
| What's implied? | Only integer numbers with an absence point of origin |
| Does data fit scale? | Yes |



### `Sex`

```r
class(Sex)  # mode
```

```
## [1] "factor"
```

```r
barplot(table(Sex))  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VSex-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | factor |
| Which scale? | Binary |
| What's implied? | Only two possible outcomes |
| Does data fit scale? | Yes |



### `Size` 

```r
class(Size)  # mode
```

```
## [1] "character"
```

```r
barplot(table(Size))  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VSize-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | character |
| Which scale? | Ordinal |
| What's implied? | Categorical data that can be ordered |
| Does data fit scale? | Yes |



### `Temperature` 

```r
class(Temperature)  # mode
```

```
## [1] "numeric"
```

```r
barplot(Temperature)  # fitting?
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/VTemp-1.png" width="576" />

| Question | Answer |
|-----:|:----|
| Mode? | numeric |
| Which scale? | Interval/Discrete |
| What's implied? | Continuous data with a non-absence point of origin |
| Does data fit scale? | Yes (the data is clearly recorded in degree Celsius) |


## Distributions

### `Length`  

```r
plot(density(Length))  # distribution plot
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/DLength-1.png" width="576" />

```r
shapiro.test(Length)  # normality check
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  Length
## W = 0.99496, p-value = 0.4331
```

The data is **normal distributed**.

### `Reproducing` 

```r
plot(density(Reproducing))  # distribution
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/DRepro-1.png" width="576" />

```r
shapiro.test(Reproducing)  # normality check
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  Reproducing
## W = 0.98444, p-value = 0.2889
```

The data is **binomial distributed** (i.e. "How many individuals manage to reproduce") but looks **normal distributed**. The normal distribution doesn't make sense here because it implies continuity whilst the data only comes in integers.

### `IndividualsPassingBy`  

```r
plot(density(IndividualsPassingBy))  # distribution
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/DIndiv-1.png" width="576" />

```r
shapiro.test(IndividualsPassingBy)  # normality check
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  IndividualsPassingBy
## W = 0.96905, p-value = 0.0187
```

The data is **poisson distributed** (i.e. "How many individuals pass by an observer in a given time frame?").

### `Depth` 

```r
plot(density(Depth))  # distribution
```

<img src="03---A-Primer-For-Statistical-Tests_files/figure-html/DDepth-1.png" width="576" />

The data is **uniform distributed**. You don't know this distribution class from the lectures and I only wanted to confuse you with this to show you that there's much more out there than I can show in our lectures.
