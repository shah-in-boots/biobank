# Tidy HRV/DYX
tidy_ecg <- function(raw_hrv, raw_dyx, raw_timings) {
	
	# Clean up raw timings
	raw_timings <- 
		raw_timings %>%
		mutate(
			time_start = hms::as_hms(time_start),
			time_balloon = hms::as_hms(time_balloon),
			time_sedation = hms::as_hms(time_sedation),
			time_end = hms::as_hms(time_end)
		)
	
	# Dyx
	dyx <- 
		raw_dyx %>%
		mutate(
			sdyx = (dyx - mean(dyx, na.rm = TRUE)) / sd(dyx, na.rm = TRUE),
			cp = ifelse(dyx < 2.0, 1, 0)
		) %>%
		left_join(raw_timings, ., by = "patid") %>%
		mutate(
			datetime = start + hours(index - 1),
			hour = hour(datetime)
		) %>%
		mutate(hour = if_else(hour == 0, 24, as.double(hour))) %>%
		group_by(patid, hour) %>%
		slice(1) %>%
		ungroup() %>%
		select(-index) %>%
		labelled::set_variable_labels(
			dyx  = "DYX",
			sdyx = "Standardized DYX",
			cp = "Abnormal DYX"
		)
	
	# HRV
	hrv <-
		raw_hrv %>%
		left_join(., raw_timings, by = "patid") %>%
		mutate(timestamp = start + seconds(t_start)) %>%
		arrange(patid, timestamp) %>%
		mutate(hour = hour(timestamp)) %>%
		mutate(hour = if_else(hour == 0, 24, as.double(hour))) %>%
		group_by(patid, hour) %>%
		summarise(across(n_nmean:ap_en, ~ mean(.x, na.rm = TRUE)), .groups = "keep") %>%
		ungroup() %>%
		labelled::set_variable_labels(
			n_nmean = "RR Interval",
			sdnn = "SDNN",
			rmssd = "RMSSD",
			pnn50 = "PNN50",
			ulf = "Ultra Low Frequency",
			vlf = "Very Low Frequency",
			lf = "Low Frequency",
			hf = "High Frequency",
			lfhf = "Low/High Frequency Ratio",
			ttlpwr = "Total Power",
			ac = "Acceleration Capacity",
			dc = "Deceleration Capacity",
			samp_en = "Sample Entropy",
			ap_en = "Approximate Entropy"
		)
	
	
	# Merged
	merged <- 
		full_join(hrv, dyx, by = c("patid", "hour")) %>%
		arrange(patid) 
	
	# Compare with specific cath timings
	timed <- 
		raw_hrv %>%
		left_join(., raw_timings, by = "patid") %>%
		mutate(timestamp = start + seconds(t_start)) %>%
		mutate(
			time_start = as_date(start) + hms(time_start),
			time_balloon = as_date(start) + hms(time_balloon),
			time_sedation = as_date(start) + hms(time_sedation),
			time_end = as_date(start) + hms(time_end),
		) %>%
		mutate(
			pre = timestamp %within% interval(time_start - minutes(60), time_start),
			start = timestamp %within% interval(time_start, time_start + minutes(15)),
			balloon = timestamp %within% interval(time_balloon, time_balloon + minutes(15)),
			sedation = timestamp %within% interval(time_sedation, time_sedation + minutes(15)),
			end = timestamp %within% interval(time_end, time_end + minutes(30))
		) %>%
		select(-starts_with(c("t_", "time"))) %>%
		pivot_longer(cols = c(pre, start, balloon, sedation, end), names_to = "context") %>%
		filter(value == TRUE) %>%
		group_by(patid, context) %>%
		summarise(across(n_nmean:ap_en, ~ mean(.x, na.rm = TRUE)), .groups = "keep") %>%
		ungroup() %>%
		labelled::set_variable_labels(
			n_nmean = "RR Interval",
			sdnn = "SDNN",
			rmssd = "RMSSD",
			pnn50 = "PNN50",
			ulf = "Ultra Low Frequency",
			vlf = "Very Low Frequency",
			lf = "Low Frequency",
			hf = "High Frequency",
			lfhf = "Low/High Frequency Ratio",
			ttlpwr = "Total Power",
			ac = "Acceleration Capacity",
			dc = "Deceleration Capacity",
			samp_en = "Sample Entropy",
			ap_en = "Approximate Entropy"
		)
	
	# List
	ecg <- list(
		dyx = dyx,
		hrv = hrv,
		merged = merged,
		timed = timed
	)
			
	# Return
	ecg
	
}

# Clinical data
tidy_clinical <- function(raw_clinical) {
	
	### DEPRESSION 
	
	df <- raw_clinical %>% 
		select(patid, starts_with("md"))
	
	# Create phq9
	# Modified it so NA rows won"t interfere c- overall score
	# If some answers are done, its unlikely that total score will be zero
	df %<>%
		mutate(phq = rowSums(across(starts_with("md"), na.rm = TRUE)))
	df$phq[df$phq == 0] <- NA
	df$phq[!is.na(df$phq)] <-
		df$phq[!is.na(df$phq)] - 9 # Since start at 0
	df$phq[df$phq <= 0] <- 0
	
	# Cut off of 10 for PHQ9
	df$sad <- ifelse(df$phq > 9, 1, 0)
	df$sad %<>% factor()
	
	# Save data
	psych <- df 
	
	### CATH
	
	df <- raw_clinical %>%
		select(patid, starts_with("ang1"))
	
	# Stenoses are present?
	df$stenosis <- df$ang1results %>% factor()
	
	## CASS score generation
	
	# CASS score? Generated as follows
	# 3 Major epicardioal vessles c- >70% stenosis = 1 point
	# LAD, LCX, RCA .... LM = LAD + LCX
	# Stenosis >50% in left main = 2 vessel disease = 2 point
	# Final score is sum of all points, analogous with 1-3 vessel dz
	# Can be defined as >70% stenosis or >50% stenosis
	
	# ang1sten tell us which arteries have stenosis
	# ang1sten(num) tell us the percent stenosis in that vessel
	# ang1cabgsten(num) tell us percent stenosis in the graft
	# ang1sten1 = left main
	# ang1sten[2-5] = LAD prox_before, prox_after, mid, distal
	# ang1sten[6-8] = LCX prox, mid, distal
	# ang1sten[9-12] = RCA prox, mid, distal, distal_post
	
	# THe epicardial vessels should be scores
	df$lm <- df$ang1sten1
	df$lm[is.na(df$lm)] <- 0
	df$lad <- apply(X = df[c("ang1sten2", "ang1sten3", "ang1sten4", "ang1sten5")], MARGIN = 1, FUN = max, na.rm = TRUE)
	df$lad[df$lad == -Inf] <- 0
	df$lcx <- apply(X = df[c("ang1sten6", "ang1sten7", "ang1sten8")], MARGIN = 1, FUN = max, na.rm = TRUE)
	df$lcx[df$lcx == -Inf] <- 0
	df$rca <- apply(X = df[c("ang1sten9", "ang1sten10", "ang1sten11", "ang1sten12")], MARGIN = 1, FUN = max, na.rm = TRUE)
	df$rca[df$rca == -Inf] <- 0
	
	# CASS-50 score is needed
	df$cass50 <- 0
	df$cass50[df$lad >= 50] <- df$cass50[df$lad >= 50] + 1
	df$cass50[df$lcx >= 50] <- df$cass50[df$lcx >= 50] + 1
	df$cass50[df$lm >= 50] <- 2
	df$cass50[df$rca >= 50] <- df$cass50[df$rca >= 50] + 1
	df$cass50[is.na(df$ang1results)] <- NA
	
	# CASS-70 score is needed
	df$cass70 <- 0
	df$cass70[df$lad >= 70] <- df$cass70[df$lad >= 70] + 1
	df$cass70[df$lcx >= 70] <- df$cass70[df$lcx >= 70] + 1
	df$cass70[df$lm >= 70] <- 2
	df$cass70[df$rca >= 70] <- df$cass70[df$rca >= 70] + 1
	df$cass70[is.na(df$ang1results)] <- NA
	
	svar <- c(
		"patid",
		"stenosis",
		"lm",
		"lad",
		"lcx",
		"rca",
		"cass50",
		"cass70"
	)
	
	tmp <- df[svar]
	
	### Gensini Score
	# Points for amount stenosis
	# 1 pt > 0%
	# 2 pt > 25%
	# 4 pt > 50%
	# 8 pt > 75%
	# 16 pt > 90%
	# 32 pt = 100%
	# Points are multiplied by lesion importance in circulation
	# 5 x LM
	# 2.5 x prox LAD
	# 2.5 x prox LCX
	# 1.5 x mid LAD
	# 1.0 x RCA | distal LAD | posterolateral (PDA) | obtuse marginal
	# 0.5 x all other segments
	# Gensini score is the sum of all segments
	
	# Appropriately named arteries for scoring
	df <-
		df %>%
		dplyr::select(., c(patid, ang1sten1:ang1sten22)) %>%
		mutate_all(., ~replace(., is.na(.), 0))
	
	# Need to have overall stenoses score points
	df[-1] %<>%
		mutate_all(., function(x) {
			case_when(
				x == 100 ~ 32,
				x > 90 ~ 16,
				x > 75 ~ 8,
				x > 50 ~ 4,
				x > 25 ~ 2,
				x >= 0 ~ 1
			)}
		)
	
	# Need to multiply the column by their point values
	df %<>%
		dplyr::rename(
			lm = ang1sten1,
			plad1 = ang1sten2,
			plad2 = ang1sten3,
			plcx = ang1sten6,
			mlad = ang1sten4,
			dlad = ang1sten5,
			rca1 = ang1sten9,
			rca2 = ang1sten10,
			rca3 = ang1sten11,
			rca4 = ang1sten12,
			pda = ang1sten13,
			om1 = ang1sten18,
			om2 = ang1sten19,
			om3 = ang1sten20
		)
	
	# Find maximum points per groups of arteries
	df$plad <- apply(X = df[c("plad1", "plad2")], MARGIN = 1, FUN = max, na.rm = TRUE)
	df$plad[df$plad == -Inf] <- 0
	
	df$rca <- apply(X = df[c("rca1", "rca2", "rca3", "rca4")], MARGIN = 1, FUN = max, na.rm = TRUE)
	df$rca[df$rca == -Inf] <- 0
	
	df$om <- apply(X = df[c("om1", "om2", "om3")], MARGIN = 1, FUN = max, na.rm = TRUE)
	df$om[df$om == -Inf] <- 0
	
	df %<>% dplyr::select(., -c(plad1, plad2, rca1, rca2, rca3, rca4, om1, om2, om3))
	
	# Multiple the scores!
	df %<>% within(., {
		lm = lm * 5
		plad %<>% `*`(2.5)
		plcx %<>% `*`(2.5)
		mlad %<>% `*`(1.5)
		rca %<>% `*`(1.0)
		dlad %<>% `*`(1.0)
		pda %<>% `*`(1.0)
		om %<>% `*`(1.0)
		ang1sten7 %<>% `*`(0.5)
		ang1sten8 %<>% `*`(0.5)
		ang1sten14 %<>% `*`(0.5)
		ang1sten15 %<>% `*`(0.5)
		ang1sten16 %<>% `*`(0.5)
		ang1sten17 %<>% `*`(0.5)
		ang1sten21 %<>% `*`(0.5)
		ang1sten22 %<>% `*`(0.5)
	})
	
	df$gensini <-
		df[-1] %>%
		rowSums(.)
	
	df$gensini[is.na(df$ang1results)] <- NA
	
	# Final data set
	angio_scores <- inner_join(df[c("patid", "gensini")], tmp, by = "patid")
	
	### PUT ALL DATA TOGETHER
	all <- 
		raw_clinical %>%
		select(c(patid, age, race, blbmi, gend, setting)) %>%
		left_join(., psych, by = "patid") %>%
		left_join(., angio_scores, by = "patid") %>%
		set_variable_labels(
			patid = "Patient ID",
			age = "Age (years)",
			race = "Race",
			blbmi = "BMI (kg/m^2)",
			gend = "Sex",
			phq = "PHQ-9 Score",
			sad = "Depression",
			gensini = "Gensini Score",
			stenosis = "Stenosis",
			cass50 = "CASS-50 Score",
			cass70 = "CASS-70 Score"
		)
		
	# Return
	all
	
}

