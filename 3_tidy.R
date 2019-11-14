#!/usr/bin/env Rscript


## Demographic information {{{ ====

# Demographics

# }}}

## Depression scores {{{ ==== 

# Depression data set
df <- psych

# Create phq9
# Modified it so NA rows won't interfere c- overall score
# If some answers are done, its unlikely that total score will be zero
df %<>%
 mutate(phq = select(., mdplea:mddead) %>% rowSums(na.rm = TRUE)) 
df$missing <- rowSums(df[c('uniqueid', phq9)])
df$phq[df$phq == 0 & is.na(df$missing)] <- NA

# Cut off of 10 for PHQ9
df$sad <- ifelse(df$phq >9, 1, 0)

# Drop row that is missing
df <- subset(df, select = -missing)

# Return to original df
psych <- df

# }}}


## Medical history {{{ ====

# need to reconcile the two clinical and chart histories
df <- inner_join(clinHx, chartHx, by = 'uniqueid')

# Final form
history <- df

# }}}

## Angiographic findings {{{ ====

# Data frame
df <- cath

# Stenoses are present?
df$stenosis <- df$ang1results
df$stenosis[is.na(df$stenosis)] <- 0


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

# Epicardial vessels... left main
df$lm <- df$ang1sten1
df$lm[is.na(df$lm)] <- 0

# LAD
df$lad <- apply(X = df[c('ang1sten2', 'ang1sten3', 'ang1sten4', 'ang1sten5')], MARGIN = 1, FUN = max, na.rm = TRUE)
df$lad[df$lad == -Inf] <- 0

# LCX
df$lcx <- apply(X = df[c('ang1sten6', 'ang1sten7', 'ang1sten8')], MARGIN = 1, FUN = max, na.rm = TRUE)
df$lcx[df$lcx == -Inf] <- 0

# RCA
df$rca <- apply(X = df[c('ang1sten9', 'ang1sten10', 'ang1sten11', 'ang1sten12')], MARGIN = 1, FUN = max, na.rm = TRUE)
df$rca[df$rca == -Inf] <- 0

# Cass-50
df$cass50 <- 0
df$cass50[df$lad >= 50] <- df$cass50[df$lad >= 50] + 1
df$cass50[df$lcx >= 50] <- df$cass50[df$lcx >= 50] + 1
df$cass50[df$lm >= 50] <- 2
df$cass50[df$rca >= 50] <- df$cass50[df$rca >= 50] + 1

# Cass-70
df$cass70 <- 0
df$cass70[df$lad >= 70] <- df$cass70[df$lad >= 70] + 1
df$cass70[df$lcx >= 70] <- df$cass70[df$lcx >= 70] + 1
df$cass70[df$lm >= 70] <- 2
df$cass70[df$rca >= 70] <- df$cass70[df$rca >= 70] + 1

svar <- c(
'uniqueid', 
'stenosis', 
'lm', 
'lad', 
'lcx', 
'rca',
'cass50', 
'cass70'
)

cad <- df[svar]

# }}}









#### HRV Transformation ####

# Data
df <- df_hrv

# Transform HRV appropriately
df$BPM <- (df$NN/1000/60)^-1
df$PNN50 <- df$PNN50 * 100
df$HF %<>% log()
df$LF %<>% log()
df$VLF %<>% log()
df$TP %<>% log()

df_hrv <- df

#### HRV Time Series ####

# Data frame
df <- df_hrv

# Convert time series 
start_time <- today() + hms("13:34:00")
cath_time <- as.POSIXct(today() + hms("14:25:00"))
df$time <- start_time + dseconds(df$time)
df$time %<>% as.POSIXct()

df_hrv <- df
