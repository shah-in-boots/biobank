#!/usr/bin/env Rscript

df <- subset(df_cog, redcap_event_name == "enrollment_1_arm_1")

## Angiography data {{{ ====

# Cath data
svar <- c(
"ang1dom",
"ang1edp",
"ang1ef",
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

cath <- df[c("uniqueid", svar)]

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
"uniqueid",
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
  select(., c(uniqueid, ang1sten1:ang1sten22)) %>%
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
angio_scores <- inner_join(df[c("uniqueid", "gensini")], tmp, by = "uniqueid") %>%
  subset(., !is.na(stenosis))

# }}}

