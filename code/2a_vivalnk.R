#!/usr/bin/env Rscript

# Read in data locations
raw_folder <- file.path(dirname(getwd()), "data", "raw_data")
proc_folder <- file.path(dirname(getwd()), "data", "proc_data")

# Which patients?
patid <-
  tools::file_path_sans_ext(list.files(path = raw_folder, pattern = '*.txt'))

# Is the data already processed? This is a slow file so don't want to rerun over and over again
vivalnk <- read_csv(file.path(proc_folder, 'vivalnk_data.csv'))

# We need to make a new data summary if not available
if (nrow(vivalnk) == length(patid)) {
  print("Vivalnk summary uptodate.")
} else {
  # Create new vivalnk summary

  # List
  d <- list()

  # Apply fn to each element of vector
  for (i in seq_along(patid)) {
    # Print out line
    print(patid[i])

    # Extraction of data
    x <- read_patch_vivalnk(patid[i], raw_folder)

    # Make data frame
    df <- data.frame(
      'patid' = patid[i],
      'Start' = x[[1]],
      'End' = x[[2]],
      'Duration' = x[[3]]
    )

    d[[patid[i]]] <- df

  }

  # Write this to a file
  df <- rbindlist(d)
  write_csv(df, file.path(proc_folder, 'vivalnk_data.csv'))
  rm(df, patid, x, d, vivalnk)

}



## Clean up erroneous files {{{ ====

# Function for incorrect data
incorrect_data <- function(name) {
  # Read in file name
  tmp <- read_delim(file.path(raw_folder, paste0(name, '.txt')), delim = '\n', col_names = FALSE)

  # Structure is a very tall, tall tibble. Extract only relevant rows
  time <- tmp$X1[grep('Sample', tmp$X1)]
  rr <- tmp$X1[grep('RRI', tmp$X1)]

  # Combine into dataframe
  # Split into columns to help extract time stamps
  df <-
    # combine into a single data frame
    inner_join(enframe(time, value = 'time'), enframe(rr, value = 'RR'), by = 'name') %>%
    # Split strings into components
    separate(time, sep = ',',
             into = c('index', 'datetime', 'lead', 'flash', 'hr', 'resp', 'activity', 'mag'),
             remove = TRUE) %>%
    # Extract time
    separate(index, into = c('sample', 'index'), sep = '=', remove = TRUE, convert = TRUE) %>%
    # Convert date time column later
    separate(datetime, into = c('trash', 'datetime'), sep = '=', remove = TRUE, convert = TRUE) %>%
    # Pull HR into BPM
    separate(hr, into = c('hr', 'bpm'), sep = '=', remove = TRUE, convert = TRUE)  %>%
    # Respiratory rate
    separate(resp, into = c('rr', 'resp'), sep = '=', remove = TRUE, convert = TRUE)

  # Convert date time format, but need to preserve miliseconds
  options(digits.secs = 3)
  df$datetime %<>% ymd_hms()

  # Extract the RR intervals as well
  df$RR <- str_extract(df$RR, '\\d+') %>% as.integer(.)

  # Select relevant columns
  df <- df[c('index', 'datetime', 'bpm', 'resp', 'RR')]

  # Final form of vivalnk raw text information
  df <- df[order(df$index),]

  # return data
  return(df)
}

# Test this out
#name <- "07063"
#tmp <- incorrect_data(name)
#range(tmp$datetime)
#tmp$datetime

#}}}
