---
title: "Introduction to R"
subtitle: 'First Steps in R'
author: Erik Kusch
date: "2020-06-10"
slug: Introduction to R
categories: 
  - BioStat101
tags: 
  - R
  - Statistics
summary: 'These are the solutions to the exercises contained within the handout to Introduction to R which walks you through the basics of the `R` machinery. `R` is a coding language that can be highly individualised and hence there are often multiple solutions to the same problem. Within these solutions, I shall only present you with one solution for every given task. However, do keep in mind that there is probably a myriad of other ways to achieve your goal.'
lastmod: '2020-06-10'
featured: no
projects:
output:
  blogdown::html_page:
    keep_md: true
    # toc: true
    # toc_depth: 2
    # number_sections: false
    fig_width: 8
linktitle: 02 - Introduction to R
menu:
  example:
    parent: Sessions
    weight: 2
toc: true
type: docs
weight: 2
---



## Theory
These are the solutions to the exercises contained within the handout to Introduction to R which walks you through the basics of the `R` machinery. `R` is a coding language that can be highly individualised and hence there are often multiple solutions to the same problem. Within these solutions, I shall only present you with one solution for every given task. However, do keep in mind that there is probably a myriad of other ways to achieve your goal. I have prepared some slides for this session:
<a href="https://htmlpreview.github.io/?https://github.com/ErikKusch/Homepage/blob/master/static/courses/biostat101/02---Introduction-to-R_Handout.html" target="_blank"><img src="/courses/BioStat101/02---BioStat101_featured.png" width="900" margin-top = "0"/></a>  

<!-- [Lecture Slides](erikkusch.com/courses/An Introduction to Biostatistics/02---Introduction-to-R_Handout.html) for this session. -->

## Creating and Inspecting Objects
### Vector
- A vector reading: "A", "B", "C"  

```r
Letters_vec <- c("A", "B", "C")
Letters_vec
```

```
## [1] "A" "B" "C"
```

```r
length(Letters_vec)
```

```
## [1] 3
```
- A vector reading: 1, 2, 3  

```r
Numbers_vec <- c(1, 2, 3)
Numbers_vec
```

```
## [1] 1 2 3
```

```r
length(Numbers_vec)
```

```
## [1] 3
```
- A vector reading: `TRUE`, `FALSE`  

```r
Logic_vec <- c(TRUE, FALSE)
Logic_vec
```

```
## [1]  TRUE FALSE
```

```r
length(Logic_vec)
```

```
## [1] 2
```
- A vector of the elements of the first three vectors

```r
Big_vec <- c(Letters_vec, Numbers_vec, Logic_vec)
Big_vec
```

```
## [1] "A"     "B"     "C"     "1"     "2"     "3"     "TRUE"  "FALSE"
```

```r
length(Big_vec)
```

```
## [1] 8
```
- A vector reading as a sequence of full numbers from 1 to 20

```r
Seq_vec <- c(1:20)
Seq_vec
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
```

```r
length(Seq_vec)
```

```
## [1] 20
```

### Factor
- A factor reading: "A", "B", "C"  

```r
Letters_fac <- factor(x = c("A", "B", "C"))
Letters_fac
```

```
## [1] A B C
## Levels: A B C
```

```r
length(Letters_fac)
```

```
## [1] 3
```
- A factor reading: 1, 2, 3  

```r
Numbers_fac <- factor(x = c(1, 2, 3))
Numbers_fac
```

```
## [1] 1 2 3
## Levels: 1 2 3
```

```r
length(Numbers_fac)
```

```
## [1] 3
```
- A factor reading: 1, 2, 3 but only levels 1 and 2 are allowed  

```r
Constrained_fac <- factor(x = c(1, 2, 3), levels = c(1, 2))
Constrained_fac
```

```
## [1] 1    2    <NA>
## Levels: 1 2
```

```r
length(Constrained_fac)
```

```
## [1] 3
```

- A factor reading: 1, 2, 3 levels 1 - 4 are allowed  

```r
Expanded_fac <- factor(x = c(1, 2, 3), levels = c(1, 2, 3, 4))
Expanded_fac
```

```
## [1] 1 2 3
## Levels: 1 2 3 4
```

```r
length(Expanded_fac)
```

```
## [1] 3
```

### Matrix
- The first two vectors we established in distinct columns of a matrix

```r
Combine_mat <- matrix(data = c(Numbers_vec, Letters_vec), ncol = 2)
Combine_mat
```

```
##      [,1] [,2]
## [1,] "1"  "A" 
## [2,] "2"  "B" 
## [3,] "3"  "C"
```

```r
dim(Combine_mat)
```

```
## [1] 3 2
```
- The first two vectors we established in distinct rows of a matrix

```r
Pivot_mat <- matrix(data = c(Numbers_vec, Letters_vec), nrow = 2, byrow = TRUE)
Pivot_mat
```

```
##      [,1] [,2] [,3]
## [1,] "1"  "2"  "3" 
## [2,] "A"  "B"  "C"
```

```r
dim(Pivot_mat)
```

```
## [1] 2 3
```
- The above matrix with meaningful names

```r
Names_mat <- Pivot_mat
dimnames(Names_mat) <- list(c("Numbers", "Letters"))
Names_mat
```

```
##         [,1] [,2] [,3]
## Numbers "1"  "2"  "3" 
## Letters "A"  "B"  "C"
```

```r
dim(Names_mat)
```

```
## [1] 2 3
```

### Data Frame
- The first matrix we established as a data frame

```r
Combine_df <- data.frame(Combine_mat)
Combine_df
```

```
##   X1 X2
## 1  1  A
## 2  2  B
## 3  3  C
```

```r
dim(Combine_df)
```

```
## [1] 3 2
```
- The previous data frame with meaningful names

```r
Names_df <- Combine_df
colnames(Names_df) <- c("Numbers", "Letters")
Names_df
```

```
##   Numbers Letters
## 1       1       A
## 2       2       B
## 3       3       C
```

```r
dim(Names_df)
```

```
## [1] 3 2
```

### List
  - The first two vectors we created  

```r
Vectors_ls <- list(Numbers_vec, Letters_vec)
Vectors_ls
```

```
## [[1]]
## [1] 1 2 3
## 
## [[2]]
## [1] "A" "B" "C"
```

```r
length(Vectors_ls)
```

```
## [1] 2
```

## Statements and Loops
### Statements
- `Numbers_vec` contains more elements than `Letters_fac`?

```r
length(Numbers_vec) > length(Letters_fac)
```

```
## [1] FALSE
```
- The first column of `Combine_df` is shorter than `Vectors_ls`?

```r
length(Combine_df[, 1]) < length(Vectors_ls)
```

```
## [1] FALSE
```
- The elements of `Letters_vec` are the same as the elements of `Letters_fac`?

```r
Letters_vec == Letters_fac
```

```
## [1] TRUE TRUE TRUE
```

### Loops
- Print each element of `Vectors_ls`  

```r
for (i in 1:length(Vectors_ls)) {
    print(Vectors_ls[[i]])
}
```

```
## [1] 1 2 3
## [1] "A" "B" "C"
```
- Print each element of `Numbers_vec` + 1  

```r
Numbers_veca <- Numbers_vec + 1
for (i in 1:length(Numbers_veca)) {
    print(Numbers_veca[i])
}
```

```
## [1] 2
## [1] 3
## [1] 4
```
- Subtract 1 from each element of the first column of `Combine_mat` and print each element separately

```r
Mat_column <- Combine_mat[, 1]  # extract data
Mat_column <- as.numeric(Mat_column)  # convert to numeric
Mat_column <- Mat_column - 1  # substract 1
for (i in 1:length(Mat_column)) {
    print(Mat_column[i])
}
```

```
## [1] 0
## [1] 1
## [1] 2
```
## Useful Commands
- Read out your current working directory (not showing you the result as it is different on every machine, it should start like this "C:/Users/....")

```r
getwd()
```
- Inspect the `Vectors_ls` object using the `View()` function (again, I am not showing you the result as this only works directly in `R` or Rstudio)

```r
View(Vectors_ls)
```
- Inspect the `Combine_df` object using the `View()` function (again, I am not showing you the result as this only works directly in `R` or Rstudio)

```r
View(Combine_df)
```
- Get the help documentation for the `as.matrix()` function (again, I am not showing you the result as this only works directly in `R` or Rstudio)

```r
`?`(as.matrix)
```
- Install and load the `dplyr` package  

```r
install.packages("dplyr")
library(dplyr)
```
- Remove the `Logic_vec` object from your working environment  

```r
rm(Logic_vec)
```
- Clear your entire working environment 

```r
ls()  # this command shows you all the object in the environment
```

```
##  [1] "Big_vec"         "Combine_df"      "Combine_mat"     "Constrained_fac"
##  [5] "Expanded_fac"    "i"               "Letters_fac"     "Letters_vec"    
##  [9] "Mat_column"      "Names_df"        "Names_mat"       "Numbers_fac"    
## [13] "Numbers_vec"     "Numbers_veca"    "Pivot_mat"       "Seq_vec"        
## [17] "Vectors_ls"
```

```r
rm(list = ls())
```
