#!/usr/bin/env Rscript

## Identify all patient files {{{ ====

raw_folder <- file.path(getwd(), 'raw_data')
proc_folder <- file.path(getwd(), 'proc_data')
patid <- tools::file_path_sans_ext(list.files(path = raw_folder, pattern = '*.txt'))

# Create final data CSV
if (file.exists(file.path(proc_folder, 'vivalnk_data.csv'))) {
  unlink(file.path(proc_folder, 'vivalnk_data.csv'))
}
df <- data.frame('patid' = NA, 'Start' = NA, 'End' = NA, 'Duration' = NA)
write_csv(df, file.path(proc_folder, 'vivalnk_data.csv'))

# }}}

## Function to process individual VivaLNK file {{{ ====

process_vivalnk <- function(name) {
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
  
  # Return start time, end time, and length in list
  startTime <- head(df$datetime, 1)
  endTime <- tail(df$datetime, 1)
  lengthECG <- 
    interval(startTime, endTime) %>%
    time_length(., 'hours')
  x <- list(startTime, endTime, lengthECG)
  return(x)
}

# }}}

## Extract data from VivaLNK file {{{ ====

# Apply fn to each element of vector
for(i in seq_along(patid)) {
  
  # Print out line
  print(patid[i])
  
  # Extraction of data
  x <- process_vivalnk(patid[i])
 
  # Make data frame 
  df <- data.frame(
    'patid' = patid[i],
    'Start' = x[[1]],
    'End' = x[[2]],
    'Duration' = x[[3]]
  )
  
  # Write this to a file, appending as we go
  write_csv(df, file.path(proc_folder, 'vivalnk_data.csv'), append = TRUE)
}

# }}}

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