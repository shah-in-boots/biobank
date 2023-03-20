
# Inclusion reports for NIH
df <- tar_read(clinical)
labs <- tar_read(biobank_labels)

ier <-
	df |>
	mutate(
		Race = labs$Race,
		Gender = labs$Gender,
		Age = round(age)
	) |>
	mutate(Ethnicity = case_when(
		is.na(Race) ~ "Unknown",
		TRUE ~ "Not Hispanic or Latino"
	)) |>
	mutate(Race = if_else(is.na(Race), "Unknown", Race)) |>
	mutate(Race = if_else(Race == "Caucasian White", "White", Race)) |>
	mutate(Race = if_else(Race == "African American Black", "Black or African American", Race)) |>
	mutate(Gender = if_else(is.na(Gender), "Unknown", Gender)) |>
	mutate('Age Unit' = "Years") |>
	select(Race, Ethnicity, Gender, Age, 'Age Unit') |>
	filter(!is.na(Age))


write.csv(ier, file = "~/Downloads/ParticpantLevelData.csv", row.names = FALSE)
