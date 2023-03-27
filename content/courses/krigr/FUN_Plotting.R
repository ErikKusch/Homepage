#' ####################################################################### #
#' PROJECT: [KrigR Workshop] 
#' CONTENTS: 
#'  - Plotting Functionality
#'  DEPENDENCIES:
#'  - 
#' AUTHOR: [Erik Kusch]
#' ####################################################################### #

# PREAMBLE ================================================================

## Packages ---------------------------------------------------------------
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, repos = "http://cran.us.r-project.org")
  }
  require(x, character.only = TRUE)
}
package_vec <- c(
  "tidyr", # for turning rasters into ggplot-dataframes
  "ggplot2", # for plotting
  "viridis", # colour palettes
  "cowplot" # gridding multiple plots
)
sapply(package_vec, install.load.package)

# PLOTTING FUNCTIONS ======================================================

## Raw Data ---------------------------------------------------------------
Plot_Raw <- function(Raw, Shp = NULL, Dates, Legend = "Air Temperature [K]", COL = inferno(100)) {
  Raw_df <- as.data.frame(Raw, xy = TRUE) # turn raster into dataframe
  colnames(Raw_df)[c(-1, -2)] <- Dates # set colnames
  Raw_df <- gather(data = Raw_df, key = Values, value = "value", colnames(Raw_df)[c(-1, -2)]) #  make ggplot-ready
  Raw_plot <- ggplot() + # create plot
    geom_raster(data = Raw_df, aes(x = x, y = y, fill = value)) + # plot the covariate data
    theme_bw() + facet_wrap(~Values) + 
    labs(x = "Longitude", y = "Latitude") + # make plot more readable
    scale_fill_gradientn(name = Legend, colours = COL, na.value = "transparent") + # add colour and legend
    theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) + # reduce margins (for fusing of plots)
    theme(legend.key.size = unit(1.5, 'cm'))
  if (!is.null(Shp)) { # if a shape has been designated
    Raw_plot <- Raw_plot + geom_polygon(data = Shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
  }
  return(Raw_plot)
} # export the plot


## Covariates -------------------------------------------------------------
Plot_Covs <- function(Covs, Shp = NULL, COL = cividis(100)) {
  Plots_ls <- as.list(rep(NA, nlayers(Covs[[1]]))) # create as many plots as there are covariates variables
  for (Variable in 1:nlayers(Covs[[1]])) { # loop over all covariate variables
    Covs_Iter <- list(Covs[[1]][[Variable]], Covs[[2]][[Variable]]) # extract the data for this variable
    # for (Plot in 1:2) { # loop over both resolutions for the current variable
    # Cov_df <- as.data.frame(Covs_Iter[[Plot]], xy = TRUE) # turn raster into data frame
    
    Covs_Iter <- lapply(Covs_Iter, FUN = function(x){
      Cov_df <- as.data.frame(x, xy = TRUE) # turn raster into dataframe
      gather(data = Cov_df, key = Values, value = "value", colnames(Cov_df)[c(-1, -2)]) #  make ggplot-ready
    })
    Covs_Iter[[1]][,3] <- "Native"
    Covs_Iter[[2]][,3] <- "Target"
    Cov_df <- do.call(rbind, Covs_Iter)
    Plots_ls[[Variable]] <- ggplot() + # create plot
      geom_raster(data = Cov_df, aes(x = x, y = y, fill = value)) + # plot the covariate data
      theme_bw() + facet_wrap(~Values) + 
      labs(x = "Longitude", y = "Latitude") + # make plot more readable
      scale_fill_gradientn(name = names(Covs[[1]][[Variable]]), colours = COL, na.value = "transparent") + # add colour and legend
      theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) + # reduce margins (for fusing of plots)
      theme(legend.key.size = unit(1.5, 'cm'))
    if (!is.null(Shp)) { # if a shape has been designated
      Plots_ls[[Variable]] <- Plots_ls[[Variable]] + geom_polygon(data = Shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
    }
    # } # end of resolution loop
  } # end of variable loop
  if(nlayers(Covs[[1]]) > 1){
    ggPlot <- plot_grid(plotlist = Plots_ls, ncol = 1, labels = "AUTO") # fuse the plots into one big plot 
    return(ggPlot)
  }else{
    return(Plots_ls[[1]])
  }
} # export the plot


## Kriged Data ------------------------------------------------------------
Plot_Krigs <- function(Krigs, Shp = NULL, Dates, Legend = "Air Temperature [K]", columns = 1) {
  Type_vec <- c("Prediction", "Standard Error") # these are the output types of krigR
  Colours_ls <- list(inferno(100), rev(viridis(100))) # we want separate colours for the types
  Plots_ls <- as.list(NA, NA) # this list will be filled with the output plots
  for (Plot in 1:2) { # loop over both output types
    Krig_df <- as.data.frame(Krigs[[Plot]], xy = TRUE) # turn raster into dataframe
    colnames(Krig_df)[c(-1, -2)] <- paste(Type_vec[Plot], Dates) # set colnames
    Krig_df <- gather(data = Krig_df, key = Values, value = "value", colnames(Krig_df)[c(-1, -2)]) # make ggplot-ready
    Plots_ls[[Plot]] <- ggplot() + # create plot
      geom_raster(data = Krig_df, aes(x = x, y = y, fill = value)) + # plot the kriged data
      facet_wrap(~Values) + # split raster layers up
      theme_bw() +
      labs(x = "Longitude", y = "Latitude") + # make plot more readable
      scale_fill_gradientn(name = Legend, colours = Colours_ls[[Plot]], na.value = "transparent") + # add colour and legend
      theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) + # reduce margins (for fusing of plots)
      theme(legend.key.size = unit(1, 'cm'))
    if (!is.null(Shp)) { # if a shape has been designated
      Plots_ls[[Plot]] <- Plots_ls[[Plot]] + geom_polygon(data = Shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
    }
  } # end of type-loop
  ggPlot <- plot_grid(plotlist = Plots_ls, ncol = columns, labels = "AUTO") # fuse the plots into one big plot
  return(ggPlot)
} # export the plot

## Bioclimatic Data -------------------------------------------------------
Plot_BC <- function(BC_ras, Shp = NULL, Water_Var = "Precipitation", which = "All"){
  BC_names <- c("Annual Mean Temperature", "Mean Diurnal Range", "Isothermality", "Temperature Seasonality", "Max Temperature of Warmest Month", "Min Temperature of Coldest Month", "Temperature Annual Range (BIO5-BIO6)", "Mean Temperature of Wettest Quarter", "Mean Temperature of Driest Quarter", "Mean Temperature of Warmest Quarter", "Mean Temperature of Coldest Quarter", paste("Annual", Water_Var), paste(Water_Var, "of Wettest Month"), paste(Water_Var, "of Driest Month"), paste(Water_Var, "Seasonality"), paste(Water_Var, "of Wettest Quarter"), paste(Water_Var, "of Driest Quarter"), paste(Water_Var, "of Warmest Quarter"), paste(Water_Var, "of Coldest Quarter"))
  BC_names <- paste0("BIO", 1:19, " - ", BC_names)
  BC_df <- as.data.frame(BC_ras, xy = TRUE) # turn raster into dataframe
  if(which == "All"){Iter <- 1:19}else{Iter <- which}
  BCplots_ls <- as.list(rep(NA, length(Iter)))
  counter <- 1
  for(Plot_Iter in Iter){
    Legend <- colnames(BC_df)[Plot_Iter+2]
    Plot_df <- BC_df[, c(1:2, Plot_Iter+2)]
    colnames(Plot_df)[3] <- "value"
    if(Plot_Iter < 12){
      col_grad <- inferno(1e3) 
    }else{
      col_grad <- mako(1e3)
    }
    BC_plot <- ggplot() + # create a plot
      geom_raster(data = Plot_df, aes(x = x, y = y, fill = value)) + # plot the raw data
      theme_bw() + labs(title = BC_names[Plot_Iter], x = "Longitude", y = "Latitude") + # make plot more readable
      scale_fill_gradientn(name = "", colours = col_grad) # add colour and legend
    if(!is.null(Shp)){ # if a shape has been designated
      BC_plot <- BC_plot + geom_polygon(data = Shp, aes(x = long, y = lat, group = group), colour = "black", fill = "NA") # add shape
    }
    BCplots_ls[[counter]] <- BC_plot
    counter <- counter+1
  }
  cowplot::plot_grid(plotlist = BCplots_ls, nrow = ceiling(length(Iter)/2))
}