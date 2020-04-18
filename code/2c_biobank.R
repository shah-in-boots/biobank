#!/usr/bin/env Rscript

## Read in data {{{ ====

# Read in demographic data
df_num <- read_csv("../data/biobank_data_numerical_04-06-20.csv", col_names = TRUE,
                   col_types = c(
                     uniqueid = "c",
                     geneidadm = "c",
                     mrn = "c"
                   )
)
df_txt <- read_csv("../data/biobank_data_labels_04-06-20.csv", col_names = TRUE)

# Save the labels to match later
numVar <- names(df_num)
txtVar <- names(df_txt)

names(df_txt) <- names(df_num)


# Correct / add in the patid for ensure proper naming
df_num$patid <-
  parse_number(df_num$geneidadm) %>%
  str_pad(., 5, side = "left", pad = "0")

# Special cases
df_num$patid[df_num$uniqueid == "7616"] <- "UI7616"

# }}}

## Demographic variables {{{ ====

svar <- c(
"patid",
"redcap_event_name",
"redcap_survey_identifier",
"geneidadm",
"patient_identification_timestamp",
"mrn",
"recordid",
"dob",
"gend",
"race",
"raceoth",
"age",
"blbmi",
"setting",
"adm_reason",
"admcathdate",
"lhc_adm",
"adm_reason_other",
"pci_adm",
"rhc_adm",
"pvd_adm",
"valv_adm",
"incp",
"inother",
"inpalp",
"insyncope",
"insob",
"enroldt"
)

demo <- df_num[svar]

# }}}

## Psychological and behavioral variables {{{ ====

phq9 <- c(
"mdplea",
"mddep",
"mdsleep",
"mdtired",
"mdappt",
"mdbad",
"mdconc",
"mdspeak",
"mddead"
)

psych <- df_num[c("patid", phq9)]

#}}}

## Medical history {{{ ====

# Patient reported
svar <- c(
"patid",
"mihist",
"cphist",
"cadhist",
"hfhist",
"strhist",
"icshist",
"vtehist",
"padhist",
"arrhist",
"aahist",
"valhist",
"htnhist",
"hldhist",
"dmhist",
"apnhist",
"copdhist",
"ashist",
"canhist",
"slehist",
"ibdhist",
"thyhist",
"histcath",
"histang",
"histstent",
"transp",
"htvalv",
"permpace",
"icd"
)

clinHx <- df_num[svar]

# Per chart review
svar <- c(
"patid",
"prevmi",
"mienz",
"ecgq",
"ecgst",
"lv",
"cad",
"cadstr",
"cadev",
"cadct",
"cadcal",
"rerx",
"pcitype",
"repvd",
"restroke",
"arrtype",
"htfail",
"cardtr",
"valvdis",
"diab",
"hyp",
"dys",
"airways",
"apnea"
)

chartHx <- df_num[svar]

# }}}

## Angiography data {{{ ====

# Cath data
svar <- c(
"patid",
"ang1dom",
"ang1edp",
"ang1ef",
"ang1cabg",
"ang1cabg1",
"ang1cabg2",
"ang1cabg3",
"ang1cabg4",
"ang1cabg5",
"ang1cabg6",
"ang1cabg7",
"ang1cabg8",
"ang1cabg9",
"ang1cabg10",
"ang1cabg11",
"ang1cabg12",
"ang1cabg13",
"ang1cabg14",
"ang1results",
"ang1graf",
"ang1isr",
"ang1sten",
"ang1isrsten",
"ang1cabgsten1",
"ang1cabgsten2",
"ang1cabgsten3",
"ang1cabgsten4",
"ang1cabgsten5",
"ang1cabgsten6",
"ang1cabgsten7",
"ang1cabgsten8",
"ang1cabgsten9",
"ang1cabgsten10",
"ang1cabgsten11",
"ang1cabgsten12",
"ang1cabgsten13",
"ang1cabgsten14",
"ang1sten1",
"ang1sten2",
"ang1sten3",
"ang1sten4",
"ang1sten5",
"ang1sten6",
"ang1sten7",
"ang1sten8",
"ang1sten9",
"ang1sten10",
"ang1sten11",
"ang1sten12",
"ang1sten13",
"ang1sten14",
"ang1sten15",
"ang1sten16",
"ang1sten17",
"ang1sten18",
"ang1sten19",
"ang1sten20",
"ang1sten21",
"ang1sten22",
"ang1int1",
"ang1int2",
"ang1int3",
"ang1int4",
"ang1int5",
"ang1int6",
"ang1int7",
"ang1int8",
"ang1int9",
"ang1int10",
"ang1int11",
"ang1int12",
"ang1int13",
"ang1int14",
"ang1int15",
"ang1int16",
"ang1int17",
"ang1int18",
"ang1int19",
"ang1int20",
"ang1int21",
"ang1int22",
"ang1graftint1",
"ang1graftint2",
"ang1graftint3",
"ang1graftint4",
"ang1graftint5",
"ang1graftint6",
"ang1graftint7",
"ang1graftint8",
"ang1graftint9",
"ang1graftint10",
"ang1graftint11",
"ang1graftint12",
"ang1graftint13",
"ang1graftint14",
"ang1outcomes"
)

cath <- df_num[svar]

#}}}

