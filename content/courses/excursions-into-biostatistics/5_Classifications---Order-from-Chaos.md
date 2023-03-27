---
title: Classifications
subtitle: Order from Chaos
date: "2021-02-27"
slug: Classifications - Order from Chaos
categories: [Excursion into Biostatistics]
tags: [R, Statistics]
summary: 'These are exercises and solutions meant as a compendium to my talk on Classifications.'
authors: [Erik Kusch]
lastmod: '2020-02-27'
featured: no
projects:
output:
  blogdown::html_page:
    keep_md: true
    # toc: true
    # toc_depth: 2
    # number_sections: false
    fig_width: 8
linktitle: Classifications - Order from Chaos
menu:
  Excursions:
    parent: Seminars
    weight: 6
toc: true
type: docs
weight: 6
---



## Theory
These are exercises and solutions meant as a compendium to my talk on Model Selection and Model Building.  

I have prepared some {{< staticref "courses/excursions-into-biostatistics/Classifications---Order-from-Chaos.html" "newtab" >}} Lecture Slides {{< /staticref >}} for this session.

## Our Resarch Project

Today, we are looking at a big (and entirely fictional) data base of the common house sparrow (*Passer domesticus*). In particular, we are interested in the **Evolution of *Passer domesticus* in Response to Climate Change** which was previously explained {{< staticref "courses/excursions-into-biostatistics/research-project/" "newtab" >}} here{{< /staticref >}}.

### The Data

I have created a large data set for this exercise which is available {{< staticref "courses/excursions-into-biostatistics/Data.rar" "newtab" >}} here{{< /staticref >}} and we previously cleaned up so that is now usable {{< staticref "courses/excursions-into-biostatistics/data-handling-and-data-assumptions/" "newtab" >}} here{{< /staticref >}}.

### Reading the Data into `R`

Let's start by reading the data into `R` and taking an initial look at it:

```r
Sparrows_df <- readRDS(file.path("Data", "SparrowDataClimate.rds"))
head(Sparrows_df)
```

```
##   Index Latitude Longitude     Climate Population.Status Weight Height Wing.Chord Colour    Sex Nesting.Site Nesting.Height Number.of.Eggs Egg.Weight Flock Home.Range Predator.Presence Predator.Type
## 1    SI       60       100 Continental            Native  34.05  12.87       6.67  Brown   Male         <NA>             NA             NA         NA     B      Large               Yes         Avian
## 2    SI       60       100 Continental            Native  34.86  13.68       6.79   Grey   Male         <NA>             NA             NA         NA     B      Large               Yes         Avian
## 3    SI       60       100 Continental            Native  32.34  12.66       6.64  Black Female        Shrub          35.60              1       3.21     C      Large               Yes         Avian
## 4    SI       60       100 Continental            Native  34.78  15.09       7.00  Brown Female        Shrub          47.75              0         NA     E      Large               Yes         Avian
## 5    SI       60       100 Continental            Native  35.01  13.82       6.81   Grey   Male         <NA>             NA             NA         NA     B      Large               Yes         Avian
## 6    SI       60       100 Continental            Native  32.36  12.67       6.64  Brown Female        Shrub          32.47              1       3.17     E      Large               Yes         Avian
##       TAvg      TSD
## 1 269.9596 15.71819
## 2 269.9596 15.71819
## 3 269.9596 15.71819
## 4 269.9596 15.71819
## 5 269.9596 15.71819
## 6 269.9596 15.71819
```

### Hypotheses
Let's remember our hypotheses:  

1. **Sparrow Morphology** is determined by:  
    A. *Climate Conditions* with sparrows in stable, warm environments fairing better than those in colder, less stable ones.  
    B. *Competition* with sparrows in small flocks doing better than those in big flocks.  
    C. *Predation* with sparrows under pressure of predation doing worse than those without.    
2. **Sites**  accurately represent **sparrow morphology**. This may mean:  
    A. *Population status* as inferred through morphology.  
    B. *Site index* as inferred through morphology.  
    C. *Climate* as inferred through morphology.  

Quite obviously, **hypothesis 2** is the only one lending itself well to classification exercises. In fact, what we want to answer is the question: *"Can we successfully classify populations at different sites according to their morphological expressions?"*.

## `R` Environment

For this exercise, we will need the following packages:


```r
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, repos = "http://cran.us.r-project.org")
  }
  require(x, character.only = TRUE)
}
package_vec <- c(
  "ggplot2", # for visualisation
  "mclust", # for k-means clustering,
  "vegan", # for distance matrices in hierarchical clustering
  "rpart", # for decision trees
  "rpart.plot", # for plotting decision trees
  "randomForest", # for randomForest classifier
  "car", # check multicollinearity
  "MASS" # for ordinal logistic regression
)
sapply(package_vec, install.load.package)
```

```
##      ggplot2       mclust        vegan        rpart   rpart.plot randomForest          car         MASS 
##         TRUE         TRUE         TRUE         TRUE         TRUE         TRUE         TRUE         TRUE
```

Using the above function is way more sophisticated than the usual `install.packages()` & `library()` approach since it automatically detects which packages require installing and only install these thus not overwriting already installed packages.

## Logistic Regression

Remember the **Assumptions of Logistic Regression**:  

1. Absence of influential outliers  
2. Absence of multi-collinearity  
3. Predictor Variables and log odds are related in a linear fashion  

### Binary Logistic Regression
Binary Logistic regression only accommodates binary outcomes. This leaves only one of our hypotheses open for investigation - **2.A.** *Population Status* - since this is the only response variable boasting two levels.

To reduce the effect of as many confounding variables as possible, I reduce the data set to just those observations belonging to our station in Siberia and Manitoba. Both are located at very similar latitudes. They really only differ in their climate condition and the population status:

```r
LogReg_df <- Sparrows_df[Sparrows_df$Index == "MA" | Sparrows_df$Index == "SI", c("Population.Status", "Weight", "Height", "Wing.Chord")]
LogReg_df$PS <- as.numeric(LogReg_df$Population.Status) - 1 # make climate numeric for model
```

#### Initial Model & Collinearity
Let's start with the biggest model we can build here and then assess if our assumptions are met:

```r
H2_LogReg_mod <- glm(PS ~ Weight + Height + Wing.Chord,
  data = LogReg_df,
  family = binomial(link = "logit"),
)
summary(H2_LogReg_mod)
```

```
## 
## Call:
## glm(formula = PS ~ Weight + Height + Wing.Chord, family = binomial(link = "logit"), 
##     data = LogReg_df)
## 
## Deviance Residuals: 
##        Min          1Q      Median          3Q         Max  
## -2.657e-05  -2.110e-08  -2.110e-08   2.110e-08   2.855e-05  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)
## (Intercept)  1.557e+03  3.312e+07   0.000    1.000
## Weight       7.242e+01  3.735e+04   0.002    0.998
## Height       2.153e+01  1.061e+06   0.000    1.000
## Wing.Chord  -6.247e+02  6.928e+06   0.000    1.000
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 1.8437e+02  on 132  degrees of freedom
## Residual deviance: 6.8926e-09  on 129  degrees of freedom
## AIC: 8
## 
## Number of Fisher Scoring iterations: 25
```
Well... nothing here is significant. Let's see what the culprit might be. With morphological traits, you are often looking at a whole set of collinearity, so let's start by investigating that:

```r
vif(H2_LogReg_mod)
```

```
##      Weight      Height  Wing.Chord 
##    9.409985 6550.394447 6342.683547
```

A Variance Inflation Factor (VIF) value of $\geq5-10$ is seen as identifying problematic collinearity. Quite obviously, this is the case. We need to throw away some predictors. I only want to keep `Weight`.

#### `Weight` Model and Further Assumptions
Let's run a simplified model that just used `Weight` as a predictor:

```r
H2_LogReg_mod <- glm(PS ~ Weight,
  data = LogReg_df,
  family = binomial(link = "logit")
)
summary(H2_LogReg_mod)
```

```
## 
## Call:
## glm(formula = PS ~ Weight, family = binomial(link = "logit"), 
##     data = LogReg_df)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -2.1980  -0.5331  -0.1235   0.5419   1.9067  
## 
## Coefficients:
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept) -46.3244     7.8319  -5.915 3.32e-09 ***
## Weight        1.4052     0.2374   5.920 3.23e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 184.37  on 132  degrees of freedom
## Residual deviance: 105.08  on 131  degrees of freedom
## AIC: 109.08
## 
## Number of Fisher Scoring iterations: 5
```
A significant effect, huzzah! We still need to test for our assumptions, however. Checking for **multicollinearity** makes no sense since we only use one predictor, so we can skip that.

**Linear Relationship** between predictor(s) and log-odds of the output can be assessed as follows:

```r
probabilities <- predict(H2_LogReg_mod, type = "response") # predict model response on original data
LogReg_df$Probs <- probabilities # safe probabilities to data frame
LogReg_df$LogOdds <- log(probabilities / (1 - probabilities)) # calculate log-odds
## Plot Log-Odds vs. Predictor
ggplot(data = LogReg_df, aes(x = Weight, y = LogOdds)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  theme_bw()
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-7-1.png" width="1440" />

That is clearly linear relationship!

Moving on to our final assumption, we want to assess whether there are influential **Outliers**. For this, we want to look at the *Cook's distance* as well as the *standardised residuals* per observation:

```r
## Cook's distance
plot(H2_LogReg_mod, which = 4, id.n = 3)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-8-1.png" width="1440" />

```r
## Standardises Residuals
Outlier_df <- data.frame(
  Residuals = resid(H2_LogReg_mod),
  Index = 1:nrow(LogReg_df),
  Outcome = factor(LogReg_df$PS)
)
Outlier_df$Std.Resid <- scale(Outlier_df$Residuals)
# Plot Residuals
ggplot(Outlier_df, aes(Outcome, Std.Resid)) +
  geom_boxplot() +
  theme_bw()
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-8-2.png" width="1440" />
Both of these plots do not highlight any worrying influential outliers. An influential outliers would manifest with a prominent standardises residual ($|Std.Resid|\sim3$)/Cook's distance.

Let's finally plot what the model predicts:

```r
ggplot(data = LogReg_df, aes(x = Weight, y = LogReg_df$PS)) +
  geom_point() +
  theme_bw() +
  geom_smooth(
    data = LogReg_df, aes(x = Weight, y = Probs),
    method = "glm",
    method.args = list(family = "binomial"),
    se = TRUE
  ) +
  labs(y = "Introduced Population")
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-9-1.png" width="1440" />

### Ordinal Logistic Regression
Ordinal Logistic regression allows for multiple levels of the response variable so long as they are on an ordinal scale. Here, we could test all of our above hypotheses. However, I'd like to stick with **2.C.** *Climate* for this example.

Again, to reduce the effect of as many confounding variables as possible, I reduce the data set to just those observations belonging to our station in Siberia, Manitoba, and also the United Kingdom this time. All three are located at very similar latitudes. They really only differ in their climate condition and the population status:

```r
LogReg_df <- Sparrows_df[Sparrows_df$Index == "UK" | Sparrows_df$Index == "MA" | Sparrows_df$Index == "SI", c("Climate", "Weight", "Height", "Wing.Chord")]
LogReg_df$CL <- factor(as.numeric(LogReg_df$Climate) - 1) # make climate factored numeric for model
```

#### Initial Model & Collinearity
Let's start with the biggest model we can build here and then assess if our assumptions are met:

```r
H2_LogReg_mod <- polr(CL ~ Weight + Height + Wing.Chord,
  data = LogReg_df,
  Hess = TRUE
)
summary_table <- coef(summary(H2_LogReg_mod))
pval <- pnorm(abs(summary_table[, "t value"]), lower.tail = FALSE) * 2
summary_table <- cbind(summary_table, "p value" = round(pval, 6))
summary_table
```

```
##                   Value Std. Error      t value p value
## Weight       -0.4595713 0.09750017    -4.713544   2e-06
## Height       25.0804875 0.19522593   128.469037   0e+00
## Wing.Chord -164.1081894 0.51246105  -320.235438   0e+00
## 0|1        -788.2027631 0.11008584 -7159.892373   0e+00
## 1|2        -786.7913024 0.18747881 -4196.694599   0e+00
```
Well... a lot here is significant. We identified **multicollinearity** as a problem earlier. Let's investigate that again:

```r
vif(H2_LogReg_mod)
```

```
##       Weight       Height   Wing.Chord 
## 1.205383e+13 3.563792e+15 3.782106e+15
```
Horrible!. A Variance Inflation Factor (VIF) value of $\geq5-10$ is seen as identifying problematic collinearity. Quite obviously, this is the case. We need to throw away some predictors. I only want to keep `Weight`.

#### `Weight` Model and Further Assumptions
Let's run a simplified model that just used `Weight` as a predictor:

```r
H2_LogReg_mod <- polr(CL ~ Weight,
  data = LogReg_df,
  Hess = TRUE
)
summary_table <- coef(summary(H2_LogReg_mod))
pval <- pnorm(abs(summary_table[, "t value"]), lower.tail = FALSE) * 2
summary_table <- cbind(summary_table, "p value" = round(pval, 6))
summary_table
```

```
##               Value Std. Error      t value  p value
## Weight -0.020768177  0.0761669 -0.272666718 0.785109
## 0|1    -1.354848455  2.5131706 -0.539099272 0.589818
## 1|2     0.009549511  2.5112093  0.003802754 0.996966
```

Well... this model doesn't help us at all in understanding climate through morphology of our sparrows. Let's abandon this and move on to classification methods which are much better suited to this task.


## K-Means Clustering

K-Means clustering is incredibly potent in identifying a number of appropriate clusters, their attributes, and sort observations into appropriate clusters.

### Population Status Classifier
Let's start with understanding population status through morphological traits:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord", "Population.Status")]
H2_PS_mclust <- Mclust(Morph_df[-4], G = length(unique(Morph_df[, 4])))
plot(H2_PS_mclust, what = "uncertainty")
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-14-1.png" width="1440" />

As we can see, K-means clustering is able to really neatly identify two groups in our data. But do they actually belong do the right groups of `Population.Status`? We'll find out in {{< staticref "courses/excursions-into-biostatistics/excursion-into-biostatistics/" "newtab" >}} Model Selection and Validation{{< /staticref >}}.

### Site Classifier
On to our site index classification. Running the k-means clustering algorithm returns:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord", "Index")]
H2_Index_mclust <- Mclust(Morph_df[-4], G = length(unique(Morph_df[, 4])))
plot(H2_Index_mclust, what = "uncertainty")
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-15-1.png" width="1440" />

That's a pretty bad classification. I would not place trust in these clusters seeing how much they overlap.

### Climate Classifier

Lastly, turning to our climate classification using k-means classification:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord", "Climate")]
H2_Climate_mclust <- Mclust(Morph_df[-4], G = length(unique(Morph_df[, 4])))
plot(H2_Climate_mclust, what = "uncertainty")
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-16-1.png" width="1440" />
These clusters are decent although there is quite a bit of overlap between the blue and red cluster.


### Optimal Model
K-means clustering is also able to identify the most "appropriate" number of clusters given the data and uncertainty of classification:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord")]
dataBIC <- mclustBIC(Morph_df)
summary(dataBIC) # show summary of top-ranking models
```

```
## Best BIC values:
##             VVV,7     EVV,7     EVV,8
## BIC      63.39237 -304.1895 -336.0531
## BIC diff  0.00000 -367.5819 -399.4455
```

```r
plot(dataBIC)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-17-1.png" width="1440" />

```r
G <- as.numeric(strsplit(names(summary(dataBIC))[1], ",")[[1]][2])
H2_Opt_mclust <- Mclust(Morph_df, # data for the cluster model
  G = G # BIC index for model to be built
)
H2_Opt_mclust[["parameters"]][["mean"]] # mean values of clusters
```

```
##                 [,1]      [,2]     [,3]      [,4]      [,5]      [,6]      [,7]
## Weight     34.830000 32.677280 33.63023 31.354892 30.146417 22.585240 22.796014
## Height     13.641765 13.570427 14.20721 14.317070 14.085826 18.847550 19.036621
## Wing.Chord  6.787059  6.780954  6.99186  7.044881  6.965047  8.576106  8.609035
```

```r
plot(H2_Opt_mclust, what = "uncertainty")
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-17-2.png" width="1440" />

Here, K-means clustering would have us settle on 7 clusters. That does not coincide with anything we could really test for at this point. COnclusively, this model goes into the category of "Nice to have, but ultimately useless here".

### Summary of K-Means Clustering
So what do we take from this? Well... Population status was well explained all morphological traits and so would in turn also do a good job of being a proxy for the other when doing mixed regression models, for example. Hence, we might want to include this variable in future {{< staticref "courses/excursions-into-biostatistics/regressions-correlations-for-the-advanced/" "newtab" >}} Regression Models{{< /staticref >}}.

## Hierarchical Clustering
Moving on to hierarchical clustering, we luckily only need to create a few trees to start with:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord")] # selecting morphology data
dist_mat <- dist(Morph_df) # distance matrix
## Hierarchical clustering using different linkages
H2_Hierachical_clas1 <- hclust(dist_mat, method = "complete")
H2_Hierachical_clas2 <- hclust(dist_mat, method = "single")
H2_Hierachical_clas3 <- hclust(dist_mat, method = "average")
## Plotting Hierarchies
par(mfrow = c(1, 3))
plot(H2_Hierachical_clas1, main = "complete")
plot(H2_Hierachical_clas2, main = "single")
plot(H2_Hierachical_clas3, main = "average")
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-18-1.png" width="1440" />

Here, you can see that the type of linkage employed by your hierarchical approach is very important as to how the hierarchy ends up looking like. For now, we run with all of them.

### Population Status Classifier
For our population status classifier, let's obtain our data and cluster number we are after:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord", "Population.Status")]
G <- length(unique(Morph_df[, 4]))
```

Now we can look at how well our different Hierarchies fair at explaining these categories when cut at the point where the same number of categories is present in the tree:

```r
clusterCut <- cutree(H2_Hierachical_clas1, k = G) # cut tree
table(clusterCut, Morph_df$Population.Status) # assess fit
```

```
##           
## clusterCut Introduced Native
##          1        682    134
##          2        250      0
```

```r
clusterCut <- cutree(H2_Hierachical_clas2, k = G) # cut tree
table(clusterCut, Morph_df$Population.Status) # assess fit
```

```
##           
## clusterCut Introduced Native
##          1        682    134
##          2        250      0
```

```r
clusterCut <- cutree(H2_Hierachical_clas3, k = G) # cut tree
table(clusterCut, Morph_df$Population.Status) # assess fit
```

```
##           
## clusterCut Introduced Native
##          1        682    134
##          2        250      0
```
Interestingly enough, no matter the linkage, all of these approaches get Introduced and Native populations confused in the first group, but not the second.

Let's look at the decisions that we could make when following a decision tree for this example:

```r
H2_PS_decision <- rpart(Population.Status ~ ., data = Morph_df)
rpart.plot(H2_PS_decision)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-21-1.png" width="1440" />

Following this decision tree we first ask *"Is our sparrow lighter than 35g?"*. If the answer is yes, we move to the left and ask the question *"Is the wing span of our sparrow greater/equal than 6.9cm?"*. If the answer is yes, we move to the left and assign this sparrow to an introduced population status. 62% of all observations are in this node and to 2% we believe that this node might actually be a Native node. All other nodes are explained accordingly. More about their interpretation can be found in this [PDF Manual](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwizk67jmJDvAhUnMuwKHbaiD90QFjAAegQIARAD&url=http%3A%2F%2Fwww.milbo.org%2Frpart-plot%2Fprp.pdf&usg=AOvVaw2DpMfeZC2yVdRaYZBXBA8K).


### Site Classifier
Moving on to the site index classifier, we need our data and number of clusters:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord", "Index")]
G <- length(unique(Morph_df[, 4]))
```

Looking at our different outputs:

```r
clusterCut <- cutree(H2_Hierachical_clas1, k = G) # cut tree
table(clusterCut, Morph_df$Index) # assess fit
```

```
##           
## clusterCut  AU  BE  FG  FI  LO  MA  NU  RE  SA  SI  UK
##         1   24   0   0  21   0  15  17   0   0  22  13
##         2   17   0   0   5   3   7   6   0   0  31   5
##         3   19   0   0  29  12  22  21   0   0  13  25
##         4   24  26   0   2  33   5   7  32  16   0  12
##         5    3   0   0  12   4  18  13   0   0   0  13
##         6    0  60   0   0  20   0   0  49  77   0   0
##         7    0  19   0   0   9   0   0  14  21   0   0
##         8    0   0  80   0   0   0   0   0   0   0   0
##         9    0   0 138   0   0   0   0   0   0   0   0
##         10   0   0  16   0   0   0   0   0   0   0   0
##         11   0   0  16   0   0   0   0   0   0   0   0
```

```r
clusterCut <- cutree(H2_Hierachical_clas2, k = G) # cut tree
table(clusterCut, Morph_df$Index) # assess fit
```

```
##           
## clusterCut  AU  BE  FG  FI  LO  MA  NU  RE  SA  SI  UK
##         1    0   0   0   0   0   0   0   0   0  28   0
##         2   87 102   0  69  80  67  64  95 112  32  68
##         3    0   0   0   0   0   0   0   0   0   4   0
##         4    0   0   0   0   0   0   0   0   0   2   0
##         5    0   0   0   0   1   0   0   0   0   0   0
##         6    0   1   0   0   0   0   0   0   0   0   0
##         7    0   2   0   0   0   0   0   0   0   0   0
##         8    0   0 122   0   0   0   0   0   0   0   0
##         9    0   0 126   0   0   0   0   0   0   0   0
##         10   0   0   2   0   0   0   0   0   0   0   0
##         11   0   0   0   0   0   0   0   0   2   0   0
```

```r
clusterCut <- cutree(H2_Hierachical_clas3, k = G) # cut tree
table(clusterCut, Morph_df$Index) # assess fit
```

```
##           
## clusterCut  AU  BE  FG  FI  LO  MA  NU  RE  SA  SI  UK
##         1   44   0   0  15  14  15  22   0   0  45  19
##         2   42  31   0  50  50  49  40  27   0  12  44
##         3    1   0   0   0   0   0   0   0   0   5   0
##         4    0   0   0   0   0   0   0   0   0   4   0
##         5    0   6   0   4   9   3   2   1   0   0   5
##         6    0  34   0   0   0   0   0  35  81   0   0
##         7    0  21   0   0   8   0   0  27  23   0   0
##         8    0  13   0   0   0   0   0   5  10   0   0
##         9    0   0 106   0   0   0   0   0   0   0   0
##         10   0   0 134   0   0   0   0   0   0   0   0
##         11   0   0  10   0   0   0   0   0   0   0   0
```
We can now see clearly how different linkages have a major impact in determining how our hierarchy groups different observations. I won't go into interpretations here to save time and energy since these outputs are so busy.

Our decision tree is also excrutiatingly busy:

```r
H2_Index_decision <- rpart(Index ~ ., data = Morph_df)
rpart.plot(H2_Index_decision)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-24-1.png" width="1440" />


### Climate Classifier
Back over to our climate classifier:

```r
Morph_df <- Sparrows_df[, c("Weight", "Height", "Wing.Chord", "Climate")]
G <- length(unique(Morph_df[, 4]))
```

Let's look at how the different linkages impact our results:

```r
clusterCut <- cutree(H2_Hierachical_clas1, k = G) # cut tree
table(clusterCut, Morph_df$Climate) # assess fit
```

```
##           
## clusterCut Coastal Continental Semi-Coastal
##          1     577         105           60
##          2      19          48            7
##          3     250           0            0
```

```r
clusterCut <- cutree(H2_Hierachical_clas2, k = G) # cut tree
table(clusterCut, Morph_df$Climate) # assess fit
```

```
##           
## clusterCut Coastal Continental Semi-Coastal
##          1     595         153           67
##          2       1           0            0
##          3     250           0            0
```

```r
clusterCut <- cutree(H2_Hierachical_clas3, k = G) # cut tree
table(clusterCut, Morph_df$Climate) # assess fit
```

```
##           
## clusterCut Coastal Continental Semi-Coastal
##          1     596         153           67
##          2     240           0            0
##          3      10           0            0
```

All of our linkage types have problems discerning Coastal types. I wager that is because of a ton of confounding effects which drive morphological traits in addition to climate types.

Here's another look at a decision tree:

```r
H2_Climate_decision <- rpart(Climate ~ ., data = Morph_df)
rpart.plot(H2_Climate_decision)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-27-1.png" width="1440" />

### Summary of Hierarchical Clustering
We have seen that site indices may hold some explanatory power regarding sparrow morphology, but the picture is very complex. We may want to keep them in mind as random effects for future models (don't worry if that doesn't mean much to you yet).

## Random Forest
Random Forests are one of the most powerful classification methods and I love them. They are incredibly powerful, accurate, and easy to use. Unfortunately, they are black-box algorithms (you don't know what's happening in them exactly in numerical terms) and they require observed outcomes. That's not a problem for us with this research project!

### Population Status Classifier

Running our random for model for population statuses:

```r
set.seed(42) # set seed because the process is random
H2_PS_RF <- tuneRF(
  x = Sparrows_df[, c("Weight", "Height", "Wing.Chord")], # variables which to use for clustering
  y = Sparrows_df$Population.Status, # correct cluster assignment
  strata = Sparrows_df$Population.Status, # stratified sampling
  doBest = TRUE, # run the best overall tree
  ntreeTry = 20000, # consider this number of trees
  improve = 0.0000001, # improvement if this is exceeded
  trace = FALSE, plot = FALSE
)
```

```
## -0.08235294 1e-07
```
Works perfectly. 

Random forests give us access to *confusion matrices* which tell us about classification accuracy:

```r
H2_PS_RF[["confusion"]]
```

```
##            Introduced Native class.error
## Introduced        902     30  0.03218884
## Native             55     79  0.41044776
```
Evidently, we are good at predicting Introduced population status, but Native population status is almost as random as a coin toss.

Which variables give us the most information when establishing these groups?

```r
varImpPlot(H2_PS_RF)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-30-1.png" width="1440" />

Well look who it is. `Weight` comes out as the most important variable once again!

### Site Classifier
Let's run a random forest analysis for our site indices:

```r
set.seed(42) # set seed because the process is random
H2_Index_RF <- tuneRF(
  x = Sparrows_df[, c("Weight", "Height", "Wing.Chord")], # variables which to use for clustering
  y = Sparrows_df$Index, # correct cluster assignment
  strata = Sparrows_df$Index, # stratified sampling
  doBest = TRUE, # run the best overall tree
  ntreeTry = 20000, # consider this number of trees
  improve = 0.0000001, # improvement if this is exceeded
  trace = FALSE, plot = FALSE
)
```

```
## 0.01630435 1e-07 
## 0 1e-07
```

```r
H2_Index_RF[["confusion"]]
```

```
##    AU  BE  FG FI LO MA NU RE  SA SI UK class.error
## AU 77   0   0  2  8  0  0  0   0  0  0  0.11494253
## BE  0 102   0  0  0  0  0  0   3  0  0  0.02857143
## FG  0   0 250  0  0  0  0  0   0  0  0  0.00000000
## FI  0   0   0 33  0 21  0  0   0  0 15  0.52173913
## LO  9   0   0  0 69  0  0  2   0  0  1  0.14814815
## MA  0   0   0 17  0 26  2  0   0  0 22  0.61194030
## NU  0   0   0  0  0  7 44  0   0  7  6  0.31250000
## RE  0   4   0  0  3  0  0 87   1  0  0  0.08421053
## SA  0   5   0  0  0  0  0  0 109  0  0  0.04385965
## SI  0   0   0  0  0  1  7  0   0 58  0  0.12121212
## UK  0   0   0 14  0 25  1  0   0  0 28  0.58823529
```

```r
varImpPlot(H2_Index_RF)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-31-1.png" width="1440" />

Except for Manitoba and the UK (which are often mistaken for each other), morphology (and mostly `Weight`) explains station indices quite adequately. 

### Climate Classifier
Lastly, we turn to our climate classifier again:

```r
set.seed(42) # set seed because the process is random
H2_Climate_RF <- tuneRF(
  x = Sparrows_df[, c("Weight", "Height", "Wing.Chord")], # variables which to use for clustering
  y = Sparrows_df$Climate, # correct cluster assignment
  strata = Sparrows_df$Climate, # stratified sampling
  doBest = TRUE, # run the best overall tree
  ntreeTry = 20000, # consider this number of trees
  improve = 0.0000001, # improvement if this is exceeded
  trace = FALSE, plot = FALSE
)
```

```
## 0.05172414 1e-07 
## -0.02727273 1e-07
```

```r
H2_Climate_RF[["confusion"]]
```

```
##              Coastal Continental Semi-Coastal class.error
## Coastal          797          16           33  0.05791962
## Continental       15         137            1  0.10457516
## Semi-Coastal      47           0           20  0.70149254
```

```r
varImpPlot(H2_Climate_RF)
```

<img src="5_Classifications---Order-from-Chaos_files/figure-html/unnamed-chunk-32-1.png" width="1440" />

Oof. We get semi-coastal habitats almost completely wrong. The other climate conditions are explained well through morphology, though.

## Final Models
In our upcoming {{< staticref "courses/excursions-into-biostatistics/excursion-into-biostatistics/" "newtab" >}} Model Selection and Validation{{< /staticref >}} Session, we will look into how to compare and validate models. We now need to select some models we have created here today and want to carry forward to said session.

Personally, I am quite enamoured with our models `H2_PS_mclust` (k-means clustering of population status), `H2_PS_RF` (random forest of population status), and `H2_Index_RF` (random forest of site indices). Let's save these as a separate object ready to be loaded into our `R` environment in the coming session:


```r
save(H2_PS_mclust, H2_PS_RF, H2_Index_RF, file = file.path("Data", "H2_Models.RData"))
```

## SessionInfo

```r
sessionInfo()
```

```
## R version 4.0.5 (2021-03-31)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 19043)
## 
## Matrix products: default
## 
## locale:
## [1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252    LC_MONETARY=English_United Kingdom.1252 LC_NUMERIC=C                           
## [5] LC_TIME=English_United Kingdom.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] MASS_7.3-53.1       car_3.0-10          carData_3.0-4       randomForest_4.6-14 rpart.plot_3.0.9    rpart_4.1-15        vegan_2.5-7         lattice_0.20-41     permute_0.9-5      
## [10] mclust_5.4.7        ggplot2_3.3.3      
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.7        assertthat_0.2.1  digest_0.6.27     utf8_1.2.1        cellranger_1.1.0  R6_2.5.0          backports_1.2.1   evaluate_0.14     highr_0.9         blogdown_1.3     
## [11] pillar_1.6.0      rlang_0.4.11      readxl_1.3.1      curl_4.3.2        data.table_1.14.0 jquerylib_0.1.4   R.utils_2.10.1    R.oo_1.24.0       Matrix_1.3-2      rmarkdown_2.7    
## [21] styler_1.4.1      labeling_0.4.2    splines_4.0.5     stringr_1.4.0     foreign_0.8-81    munsell_0.5.0     compiler_4.0.5    xfun_0.22         pkgconfig_2.0.3   mgcv_1.8-34      
## [31] htmltools_0.5.1.1 tidyselect_1.1.0  tibble_3.1.1      bookdown_0.22     rio_0.5.26        fansi_0.4.2       crayon_1.4.1      dplyr_1.0.5       withr_2.4.2       R.methodsS3_1.8.1
## [41] grid_4.0.5        nlme_3.1-152      jsonlite_1.7.2    gtable_0.3.0      lifecycle_1.0.0   DBI_1.1.1         magrittr_2.0.1    scales_1.1.1      zip_2.1.1         stringi_1.5.3    
## [51] farver_2.1.0      bslib_0.2.4       ellipsis_0.3.2    generics_0.1.0    vctrs_0.3.7       openxlsx_4.2.3    rematch2_2.1.2    tools_4.0.5       forcats_0.5.1     R.cache_0.14.0   
## [61] glue_1.4.2        purrr_0.3.4       hms_1.0.0         abind_1.4-5       parallel_4.0.5    yaml_2.2.1        colorspace_2.0-0  cluster_2.1.1     knitr_1.33        haven_2.4.1      
## [71] sass_0.3.1
```
