rm(list=ls())
setwd("~/Documents/[Research] Active Projects/[R Package] KrigR")
source("PersonalSettings.R")
setwd("~/Documents/[Research] Active Projects/[R Package] KrigR/KrigRHelps")

devtools::install_github("https://github.com/ErikKusch/KrigR", ref = "Development")
3
library(KrigR)
?CDownloadS
?CovariateSetup
?Kriging

### Downloads ------
## Raw data for one month of full globe
RawGlobe_rast <- CDownloadS(
	Variable = "2m_temperature",
	DataSet = "reanalysis-era5-land-monthly-means",
	Type = "monthly_averaged_reanalysis",
	# time-window, default set to range of dataset-type
	DateStart = "1995-01-01 00:00",
	DateStop = "1995-01-01 23:00",
	TZone = "CET",
	# temporal aggregation
	TResolution = "month",
	TStep = 1,
	# file storing
	FileName = "RawGlobe",
	# API credentials
	API_User = API_User,
	API_Key = API_Key
)
terra::plot(RawGlobe_rast)

## Monthly air temperature aggregated to bi-annual maximum by SpatRaster
CDS_rast <- terra::rast(system.file("extdata", "CentralNorway.nc", package="KrigR"))
BiAnnAirTemp_rast <- CDownloadS(
	Variable = "2m_temperature",
	DataSet = "reanalysis-era5-land-monthly-means",
	Type = "monthly_averaged_reanalysis",
	# time-window, default set to range of dataset-type
	DateStart = "1995-01-01 00:00",
	DateStop = "1996-12-31 23:00",
	TZone = "EET",
	# temporal aggregation
	TResolution = "year",
	TStep = 2,
	# spatial
	Extent = CDS_rast,
	# file storing
	FileName = "BiAnnAirTemp",
	# API credentials
	API_User = API_User,
	API_Key = API_Key
)
terra::plot(BiAnnAirTemp_rast)

## Hourly back-calculated precipitation aggregated to daily averages by shapefiles
data("Jotunheimen_poly")
Jotunheimen_poly
DailyBackCPrecip_rast <- CDownloadS(
  Variable = "total_precipitation",
  CumulVar = TRUE,
  # time-window, default set to range of dataset-type
  DateStart = "1995-01-01 00:00",
  DateStop = "1995-01-03 23:00",
  TZone = "CET",
  # temporal aggregation
  TResolution = "day",
  # spatial
  Extent = Jotunheimen_poly,
  # file storing
  FileName = "DailyBackCPrecip",
  # API credentials
  API_User = API_User,
  API_Key = API_Key
)
terra::plot(DailyBackCPrecip_rast)

## 6-hourly ensemble member spread sum for air temperature by buffered points
data("Mountains_df")
EnsembleSpreadSum6hour_rast <- CDownloadS(
	Variable = "2m_temperature",
	DataSet = "reanalysis-era5-single-levels",
	Type = "ensemble_spread",
	# time-window, default set to range of dataset-type
	DateStart = "1995-01-01 00:00:00",
	DateStop = "1995-01-01 21:00:00",
	TZone = "UTC",
	# temporal aggregation
	TResolution = "hour",
	TStep = 6,
	FUN = sum,
	# spatial
	Extent = Mountains_df,
	Buffer = 0.2,
	# file storing
	FileName = "EnsembleSpreadSum6hour",
	FileExtension = ".tif",
	# API credentials
	API_User = API_User,
	API_Key = API_Key,
	Keep_Raw = TRUE
)
terra::plot(EnsembleSpreadSum6hour_rast)

### Covariates ------
## Rectangular Covariate data according to input data
CDS_rast <- terra::rast(system.file("extdata", "CentralNorway.nc", package="KrigR"))
Covariates_ls <- CovariateSetup(Training = CDS_rast,
                                Target = 0.01,
                                Covariates = "GMTED2010",
                                Keep_Global = TRUE,
                                FileExtension = ".nc")
terra::plot(Covariates_ls[[1]])
terra::plot(Covariates_ls[[2]])

## Shapefile-limited covariate data
data("Jotunheimen_poly")
CDS_rast <- terra::rast(system.file("extdata", "CentralNorway.nc", package="KrigR"))
CDS_rast <- Handle.Spatial(CDS_rast, Jotunheimen_poly)
Covariates_ls <- CovariateSetup(Training = CDS_rast,
                                       Target = 0.01,
                                       Covariates = "GMTED2010",
                                       Extent = Jotunheimen_poly,
                                       Keep_Global = TRUE,
                                       FileExtension = ".nc")
terra::plot(Covariates_ls[[1]])
terra::plot(Covariates_ls[[2]])

## buffered-point-limited covariate data
data("Mountains_df")
CDS_rast <- terra::rast(system.file("extdata", "CentralNorway.nc", package="KrigR"))
Covariates_ls <- CovariateSetup(Training = CDS_rast,
                                       Target = 0.01,
                                       Covariates = c("tksat", "tkdry", "csol", "k_s", "lambda", "psi", "theta_s"),
                                       Source = "Drive",
                                       Extent = Mountains_df,
                                       Buffer = 0.2,
                                       Keep_Global = TRUE,
                                       FileExtension = ".nc")
terra::plot(Covariates_ls[[1]])
terra::plot(Covariates_ls[[2]])

### Kriging ------
## Kriging using pre-fab data with a rectangular extent and a fives layers of data with parallel processing
### Loading data
CDS_rast <- terra::rast(system.file("extdata", "CentralNorway.nc", package="KrigR"))
Cov_train <- terra::rast(system.file("extdata", "Covariates_Train.nc", package="KrigR"))
Cov_target <- terra::rast(system.file("extdata", "Covariates_Target.nc", package="KrigR"))
terra::varnames(Cov_train) <- terra::varnames(Cov_target) <- "GMTED2010" # we must ensure that the varnames in the Covariate file match
### kriging itself
ExtentKrig <- Kriging(
  Data = CDS_rast,
  Covariates_training = Cov_train,
  Covariates_target = Cov_target,
  Equation = "GMTED2010",
  Cores = 2,
  FileName = "KrigTest1",
  FileExtension = ".nc",
  Keep_Temporary = TRUE,
  nmax = 40,
  verbose = TRUE
)



## Kriging using full KrigR pipeline with shapefile data
### Shapefile loading
data("Jotunheimen_poly")
### CDS data download
Qsoil_rast <- CDownloadS(
  Variable = "Volumetric soil water layer 1", # can also specify as "volumetric_soil_water_layer_1"
  # time-window, default set to range of dataset-type
  DateStart = "1995-01-01 00:00",
  DateStop = "1995-01-03 23:00",
  TZone = "CET",
  # temporal aggregation
  TResolution = "day",
  # spatial
  Extent = Jotunheimen_poly,
  # file storing
  FileName = "KrigTest2_Raw",
  # API credentials
  API_User = API_User,
  API_Key = API_Key
)

### Covariate preparations
Covariates_ls <- CovariateSetup(Training = Qsoil_rast,
                                Target = 0.03,
                                Covariates = c("tksat", "tkdry", "csol", "k_s", "lambda", "psi", "theta_s"),
                                Source = "Drive",
                                Extent = Jotunheimen_poly,
                                Keep_Global = TRUE)

### kriging itself
ShapeKrig <- Kriging(
  Data = Qsoil_rast,
  Covariates_training = Covariates_ls[[1]],
  Covariates_target = Covariates_ls[[2]],
  Equation = "tksat + tkdry + csol + k_s + lambda + psi + theta_s",
  Cores = 1,
  FileName = "KrigTest2",
  FileExtension = ".nc",
  Keep_Temporary = FALSE,
  nmax = 40,
  verbose = TRUE
)

