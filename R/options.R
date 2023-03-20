# Conflicts
conflicted::conflict_prefer("select", "dplyr")
conflicted::conflict_prefer("filter", "dplyr")
conflicted::conflict_prefer("summarize", "dplyr")

# Setup based on location
find_data_folder <- function() {
	x <- sessionInfo()$running
	
	if (grepl("mac", x)) {
		file.path("/Users", "asshah4", "OneDrive - University of Illinois at Chicago", "data", "biobank")
	} else if (grepl("Windows", x)) {
		file.path("C:/Users", "asshah4", "OneDrive - University of Illinois Chicago", "data", "biobank")
	}
}

find_project_folder <- function() {
	x <- sessionInfo()$running
	if (grepl("mac", x)) {
		file.path("/Users", "asshah4", "projects")
	} else if (grepl("Windows", x)) {
		file.path("C:/Users", "asshah4", "projects")
	}
}
