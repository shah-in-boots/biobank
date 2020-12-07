#!/usr/bin/env Rscript

## Read in files {{{ ====

# Identify all file names by ID
raw_folder <- file.path(dirname(getwd()), "data", "raw_data")
proc_folder <- file.path(dirname(getwd()), "data", "proc_data")

patid <- list.dirs(path = proc_folder, recursive = FALSE, full.names = FALSE)

# Need the timestamps of all the data
vivalnk <- read_csv(file.path(proc_folder, 'vivalnk_data.csv'), col_names = TRUE) %>% na.omit()

# Only process HRV on patients that have it completed
logfile <- read_xlsx(file.path(raw_folder, 'patient_log.xlsx'), col_names = TRUE)
patid <- patid[which(patid %in% logfile$ID[logfile$Status == "processed"])]

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
  names(removed)[1] <- "patid"
  hrvparams <- read_csv(Sys.glob(file.path(proc_folder, name, "Parameters*.csv")), col_names = TRUE)
  hrvparams$patid <- name
  hrvparams %<>% pivot_wider(., names_from = Tab1, values_from = Tab2)

  # The parameter data should be combined
  x <- removed

  if(exists("df_param")) {
    df_param %<>% bind_rows(., x)
  } else {df_param <- x}

  # HRV should be combined into a raw dataframe
  y <- proc_hrv_matlab(proc_folder, name)
  y$clock <- hours(y$t_hour) + vivalnk$Start[vivalnk$patid == name]

  if(exists("df_hrv")) {
    df_hrv %<>% bind_rows(., y)
  } else {df_hrv <- y}
}

# Save the all the data
hrv_params <- inner_join(vivalnk, df_param, by = "patid")
hrv_raw <- df_hrv
names(hrv_raw) <- c("patid", "index", "NN", "SDNN", "RMSSD", "PNN50", "ULF", "VLF", "LF", "HF", "LFHF", "TP", "AC", "DC", "SampEn", "ApEn", "missing", "clock")

# Reindex HRV time points to be consistent
hrv_raw$index %<>% '+'(.,1)

# Clean
rm(df_hrv, df_param, hrvparams)

# }}}

## DYX data {{{ ====

# Data intakee
df <- read_xlsx(file.path(getwd(), '..', 'data', 'HeartTrends', 'dyx_data-04-20-20.xlsx'), col_names = TRUE) %>% na.omit()

# Relevant columns
svar <- c("Sequence", "PatientID", "Final Dyx")
df <- df[svar]
names(df) <- c("index", "patid", "DYX")
df$patid <- sub("*_rr", "", df$patid)

# This data frame still has the hours misaligned, will need to reorganize
df <- inner_join(df, vivalnk[c("patid", "Start")], by = "patid")
df$clock <- hours(df$index-1) + df$Start

# Final form
hrv_dyx <- df[c("patid", "index", "clock", "DYX")]

# Clean up
rm(df, svar)

#}}}

## Troubleshooting problem MRNs {{{ ====

# 06944, 06965, 07020, 07032, 07036
# Fixed by using column type definitions

# }}}
