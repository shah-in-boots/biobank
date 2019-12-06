#!/usr/bin/env Rscript

## Demographic information {{{ ====

# Demographics

# }}}

## Depression scores {{{ ==== 

# Depression data set
df <- psych

# Create phq9
# Modified it so NA rows won"t interfere c- overall score
# If some answers are done, its unlikely that total score will be zero
df %<>%
  mutate(phq = select(., mdplea:mdspeak) %>% rowSums(na.rm = TRUE)) 
df$phq[df$phq == 0] <- NA
df$phq[!is.na(df$phq)] <- df$phq[!is.na(df$phq)] - 9 # Since start at 0
df$phq[df$phq <= 0] <- 0

# Cut off of 10 for PHQ9
df$sad <- ifelse(df$phq >9, 1, 0)
df$sad %<>% factor()

# Return to original df
psych <- df

# }}}


## Medical history {{{ ====

# need to reconcile the two clinical and chart histories
df <- inner_join(clinHx, chartHx, by = "patid")

# Final form
history <- df

# }}}

## Angiographic findings {{{ ====

# Data frame
df <- cath

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
  cath %>%
  select(., c(patid, ang1sten1:ang1sten22)) %>%
  mutate_all(., ~replace(., is.na(.), 0)) 

# Need to have overal stenoses points
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

df %<>% select(., -c(plad1, plad2, rca1, rca2, rca3, rca4, om1, om2, om3))

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

df$gensini[is.na(cath$ang1results)] <- NA

# Final data set
angio_scores <- inner_join(df[c("patid", "gensini")], tmp, by = "patid")

# }}}

## HRV transformation {{{ ====

# Data
df <- hrv_raw

# The data should be normalized-ish
df$BPM <- (df$NN/1000/60)^-1
df$PNN50 <- df$PNN50 * 100
df$HF %<>% log()
df$LF %<>% log()
df$VLF %<>% log()
df$TP %<>% log()

# Transformed data
hrv_proc <- df

# Long data as well
hrv_long <- hrv_proc %>%
  pivot_longer(., names_to = "hrv", values_to = "value", values_drop_na = TRUE, -c(patid, index, clock))

# HRV should be blocked into single hours
df$hour <- hour(df$clock)

# The data should also be >80% available for each hour block
hrv_quality <-
  df %>% 
  group_by(patid, hour) %>%
  dplyr::summarise(duration = length(index)*5/3600,
                   missing = sum(is.na(NN))/length(NN))
  
# Hourly data
hrv_blocks <- df %>%
  group_by(patid, hour) %>%
  dplyr::summarise(
    NN = mean(NN, na.rm = TRUE),
    SDNN = mean(SDNN, na.rm = TRUE),
    RMSSD = mean(RMSSD, na.rm = TRUE),
    PNN50 = mean(PNN50, na.rm = TRUE),
    ULF = mean(ULF, na.rm = TRUE),
    VLF = mean(VLF, na.rm = TRUE),
    LF = mean(LF, na.rm = TRUE),
    HF = mean(HF, na.rm = TRUE),
    LFHF = mean(LFHF, na.rm = TRUE),
    TP = mean(TP, na.rm = TRUE),
    AC = mean(AC, na.rm = TRUE),
    DC = mean(DC, na.rm = TRUE),
    SampEn = mean(SampEn, na.rm = TRUE),
   ApEn = mean(ApEn, na.rm = TRUE)
  ) %>% left_join(., hrv_dyx, by = c("patid", "hour"))

# Can restrict it to good quality data
df <- left_join(hrv_blocks, hrv_quality, by = c("patid", "hour"))
hrv_qual_blocks <- subset(df, missing < 0.2)

# First hour collected data
df <- 
  hrv_proc %>%
  na.omit() %>%
  group_by(patid) %>%
  slice(which.min(clock))

df$hour <- hour(df$clock)
df <- subset(df, select = c(patid, index, clock, hour))

hrv_first_hour <- inner_join(hrv_blocks, df, by = c("patid", "hour"))

# }}}
