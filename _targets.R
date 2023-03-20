library(targets)
library(tarchetypes)

# Functions
tar_source()

# Set target-specific options such as packages.
tar_option_set(
	packages = c(
		# Personal
		"card", "arcana", "volundr",
		# Tidyverse/models
		"tidyverse", "tidymodels", "readxl", "haven", "janitor", "lubridate",
		# Tables / figures
		"gt", "gtsummary", "ggdag", "ggridges", "labelled",
		# Stats
		"lme4", "Hmisc", "survival", "skimr", "multilevelmod", "broom.mixed",
		# Helpers
		"magrittr"
	),
	error = "continue"
)

# Define targets
targets <- list(
	
	# Files
	tar_file(data_loc, find_data_folder()),
	tar_target(file_dyx, "../../data/biobank/HeartTrends/dyx_data-04-20-20.xlsx", format = "file"),
	tar_target(file_hrv, get_hrv_files(), format = "file"),
	tar_target(file_vivalnk, "../../data/biobank/proc_hrv/vivalnk_data.csv", format = "file"),
	tar_target(file_cath_timings, "../../data/biobank/clinical/cath_timings.xlsx"),
	tar_file(file_biobank_data, file.path(data_loc, "clinical", "biobank_data_numerical_04-06-20.csv")),
	tar_file(file_biobank_labels, file.path(data_loc, "clinical", "biobank_data_labels_04-06-20.csv")),
	
	# Intake data
	tar_target(raw_timings, get_timings(file_vivalnk, file_cath_timings)),
	tar_target(raw_hrv, get_hrv_data(file_hrv)),
	tar_target(raw_dyx, get_dyx_data(file_dyx)),
	tar_target(raw_clinical, get_clinical_data(file_biobank_data)),
	tar_target(biobank_labels, get_labels(file_biobank_labels)),
	
	# Labeling data
	
	# Tidy data
	tar_target(ecg, tidy_ecg(raw_hrv, raw_dyx, raw_timings)),
	tar_target(clinical, tidy_clinical(raw_clinical)),
	
	# Modeling data
	tar_target(tables, make_tables(clinical, ecg, labels)),
	tar_target(models, make_models(clinical, ecg)),
	
	# Results
	tar_render(results, "R/results.Rmd")
)
