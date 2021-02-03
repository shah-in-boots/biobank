# Tables
make_tables <- function(clinical, ecg, labels) {
	
	df <-
		clinical %>%
		mutate(
			race = labels$Race,
			gend = labels$Gender
		) %>%
		set_variable_labels(
			race = "Race",
			gend = "Sex"
		)
	
	# Table 1
	one <- 
		df %>%
		select(c(age, race, blbmi, gend, phq, sad, gensini, stenosis, cass50, cass70)) %>%
		tbl_summary(
			missing = "no",
			value = list(c(stenosis, sad) ~ "1")
		) %>%
		as_gt() %>%
		tab_header(title = "Biobank: Clinical Characteristics") %>%
		tab_source_note("CASS = Coronary Artery Surgery Score") %>%
		tab_options(table.font.size = "11px") %>%
		as_raw_html()

	# Tables
	tables <- list(
		one = one
	)
}

make_models <- function(clinical, ecg) {
	
	# Data
	df <- full_join(clinical, ecg$timed, by = "patid") 
	
	glmer(stenosis ~ context + (1 | patid), family = binomial, data = df) %>%
		tidy(exponentiate = TRUE, conf.int = TRUE)
	
	
}