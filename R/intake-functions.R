# # HRV Data
get_hrv_files <- function() {
	
	# Relative location to current
	loc <- file.path(dirname(dirname(getwd())), "data", "biobank", "proc_hrv")
	
	# All HRV files
	files <- list.files(loc, pattern = "*HRV*", include.dirs = TRUE, recursive = TRUE, full.names = TRUE) 
	
	# Return
	files
	
}

get_hrv_data <- function(file_hrv) {
	
	# Read in all HRV concatenated
	hrv <- 
		file_hrv %>%
		map_dfr(
			~ read_csv(.x, col_types = cols("patID" = col_character(), "t_start" = col_double())) %>%
				select(patID, t_start, NNmean, SDNN, RMSSD, pnn50, ulf, vlf, lf, hf, lfhf, ttlpwr, ac, dc, SampEn, ApEn) %>%
				na.omit()
		) %>%
		janitor::clean_names() %>%
		rename(patid = pat_id) 
	
	# Return
	hrv
	
}

get_dyx_data <- function(file_dyx) {
	
	# Read in DYX data
	dyx <- 
		readxl::read_xlsx(file_dyx) %>%
		janitor::clean_names() %>%
		select(
			patient_id,
			sequence,
			dyx_average, 
			average_r2r
		) %>%
		mutate(
			patient_id = gsub("_rr", "", patient_id)
		) %>%
		rename(
			patid = patient_id,
			index = sequence,
			dyx = dyx_average,
			rr = average_r2r
		)
	
	# Return
	dyx
	
}

# Vivalnk
get_timings <- function(file_vivalnk, file_cath_timings) {
	
	# Read in start times
	vivalnk <-
		read_csv(file_vivalnk) %>%
		janitor::clean_names() %>%
		select(-c(end, duration))
	
	# Read in cath procedure timings
	cath <-
		readxl::read_xlsx(file_cath_timings) %>%
		select(
			patid = geneidadm,
			time_start,
			time_balloon,
			time_sedation,
			time_end
		) %>%
		mutate(patid = gsub("EUH", "", patid)) 
	
	# Combine 
	all <-
		full_join(vivalnk, cath, by = "patid")
	
	# Return
	all
}

get_clinical_data <- function(file_biobank_values) {
	
	# Read in demographic data
	df <-
		read_csv(
			file_biobank_values,
			col_names = TRUE,
			col_types = c(
				uniqueid = "c",
				geneidadm = "c",
				mrn = "c"
			)
		)
	
	# Correct / add in the patid for ensure proper naming
	df$patid <-
		parse_number(df$geneidadm) %>%
		str_pad(., 5, side = "left", pad = "0")
	
	# Special cases
	df$patid[df$uniqueid == "7616"] <- "UI7616"
	
	# Return
	df
	
}

get_labels <- function(file_biobank_labels) {
	
	# Read in data
	df <- read_csv(file_biobank_labels)
	
	# Return
	df
	
}

