#!/usr/bin/env Rscript

## Read in files {{{ ====

# Identify all file names by ID
raw_folder <- file.path(getwd(), 'raw_data')
proc_folder <- file.path(getwd(), 'proc_data')
patid <- list.dirs(path = proc_folder, recursive = FALSE, full.names = FALSE)

# Need the timestamps of all the data
hrv_quality <- read_csv(file.path(proc_folder, 'vivalnk_data.csv'), col_names = TRUE) %>% na.omit()

# }}}

## Function to extract HRV into single data file, blocked by hour {{{ ====


# Function to extract HRV
read_hrv <- function(name) {
  
  # Pick out relevant columns
  svar <- c("patID", "t_start", "NNmean", "SDNN", "RMSSD", "pnn50", "ulf", "vlf", "lf", "hf", "lfhf", "ttlpwr", "ac", "dc", "SampEn", "ApEn")
  
  # Read in raw file
  df <-
    read_csv(Sys.glob(file.path(proc_folder, name, "*allwindows*.csv")), col_names = TRUE, 
             col_types = cols(
               patID = 'c', t_start = 'i', NNmean = 'd', SDNN = 'd', RMSSD = 'd', pnn50 = 'd', 
               ulf = 'd', vlf = 'd', lf = 'd', hf = 'd', lfhf = 'd', ttlpwr = 'd',
               ac = 'd', dc = 'd', SampEn = 'd', ApEn = 'd'
             )) %>%
    `[`(svar)
  
  # Rename it all
  names(df) <- c("patid", "index", "NN", "SDNN", "RMSSD", "PNN50", "ULF", "VLF", "LF", "HF", "LFHF", "TP", "AC", "DC", "SampEn", "ApEn")
 
  # Convert time index into actual time, include sequence for missing
  df$index <- seq(from = 0, to = length(df$index)*5-1, by = 5)
  df$clock <- seconds(df$index) + hrv_quality$Start[hrv_quality$patid == name]
  df$hour <- hour(df$clock)
  
  return(df)
}

# }}}

## Apply function to each patient {{{ ====

# Empty data frame
rm(df_hrv)
rm(df_param)

# Loop definition
for (i in seq_along(patid)) {
  
  # Define file
  name = patid[i]
  print(name)
  
  # All the basic analysis summary data / settings should be extracted while in each folder
  removed <- read_csv(Sys.glob(file.path(proc_folder, name , "Removed*")), col_names = TRUE)
  names(removed)[1] <- 'patid'
  hrvparams <- read_csv(Sys.glob(file.path(proc_folder, name, "Parameters*.csv")), col_names = TRUE)
  hrvparams$patid <- name
  hrvparams %<>% pivot_wider(., names_from = Tab1, values_from = Tab2)
 
  # The parameter data should be combined
  x <- inner_join(removed, hrvparams, by = 'patid') 
  
  if(exists("df_param")) {
    df_param %<>% bind_rows(., x)
  } else {df_param <- x}
  
  # HRV should be combined into a raw dataframe
  y <- read_hrv(name)
  
  if(exists("df_hrv")) {
    df_hrv %<>% bind_rows(., y)
  } else {df_hrv <- y}
}

# Save the all the data
hrv_quality %<>% inner_join(., df_param)
hrv_raw <- df_hrv
rm(df_hrv, df_param)

# }}}


## Troubleshooting problem MRNs {{{ ====

# 06944, 06965, 07020, 07032, 07036
# Fixed by using column type definitions

# }}}