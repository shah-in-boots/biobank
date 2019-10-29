#!/usr/bin/env Rscript

## Read in data {{{ ----------------------------------------

# Read in demographic data
df_num <- read_csv('biobank_data_numerical.csv', col_names = TRUE)
df_txt <- read_csv('biobank_data_text.csv', col_names = TRUE)

# Save the labels to match later
numVar <- names(df_num)
txtVar <- names(df_txt)

# Rename text file for ease of manipulation
names(df_txt) <- names(df_num)

# }}}

## Demographic variables {{{ -------------------------------

svar <- c(
'uniqueid',
'gend',
'race',
'age',
'subwtkg',
'blbmi',
'bsa',
'adm_reason',
'admcathdate',
'lhc_adm',
'pci_adm',
'rhc_adm',
'pvd_adm',
'valv_adm',
'incp',
'inpalp',
'insyncope',
'insob',
'smoking',
'behq8',
'behq2',
'behq6',
'behq14'
'behq10'
)

demo <- df_num[svar]

# }}}

## Psychological and behavioral variables {{{ --------------

svar <- c(
'mdplea',
'mddep',
'mdsleep',
'mdtired',
'mdappt',
'mdbad',
'mdconc',
'mdspeak',
'mddead',
'mdcouns',
'qhealth',
'stress1',
'stress2',
'stress3',
'stress4',
'nightsnore',
'sleepynap',
'restless',
'hourssleep',
'sleepy1',
'sleepy2',
'sleepy3',
'sleepy4',
'sleepy5',
'sleepy6',
'sleepy7',
'sleepy8',
'saqtime',
'saqnitro',
'qdasi1',
'qdasi2',
'qdasi3',
'qdasi4',
'qdasi5',
'qdasi6',
'qdasi7',
'qdasi8',
'qdasi9',
'qdasi10',
'qdasi11',
'qdasi12',
'physical_activities_hours',
'sanyha',
'chron1',
'chron2',
'chron3',
'chron4',
'chron5',
'chron6',
'chron7',
'chron8',
'chron9',
'chronic_burden_complete'
)

psych <- df_num[svar]

#}}}

## Clinical history {{{ ------------------------------------

svar <- c(
'mihist',
'gmiage',
'cphist',
'cpage',
'cadhist',
'cadage',
'hfhist',
'hfage',
'strhist',
'strage',
'icshist',
'icsage',
'vtehist',
'vteage',
'padhist',
'padage',
'arrhist',
'arrage',
'valhist',
'valage',
'aahist',
'aaage',
'htnhist',
'htnage',
'hldhist',
'hldage',
'dmhist',
'dmage',
'ashist',
'asage',
'copdhist',
'copdage',
'dephist',
'depage',
'apnhist',
'apnage',
'canhist',
'canage',
'canstatus',
'rahist',
'raage',
'slehist',
'sleage',
'ibdhist',
'ibdage',
'thyhist',
'thyage',
'pudhist',
'pudage',
'cabg',
'cabgnum',
'byart',
'cabgyr',
'histcath',
'histang',
'angnum',
'histstent',
'corstent',
'artstent',
'angyr',
'transp',
'transpyr',
'htvalv',
'valvdesc',
'yrvalv',
'permpace',
'paceyr',
'icd',
'yricd',
)

history <- df_num[svar]

# }}}


