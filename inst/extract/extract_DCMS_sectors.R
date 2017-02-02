library(dplyr)
library(readxl)

# This is set up to be run from within the eesectors_data_extract folder. All 
# paths are relative to that. You may need to source the utils.R script before
# running this script.

sectors <- '../OFFICIAL/dcms/OFFICIAL_working_file_dcms_V13.xlsm' %>%
  readxl::read_excel(., sheet = 'Working File', skip = 7) 

# Fix the messy column names

colnames(sectors) <- colnames(sectors) %>%
  make.names(unique = TRUE) %>%
  tolower %>%
  gsub('\\.\\.+?', '_', .) %>%
  gsub('\\.', '_', .) %>%
  gsub('\\_$', '', .)
  

# Select out the columns of interest
# We drop broadcasting here as not required
col_names <- c('sic','description','creative','digital',
               'culture','telecoms','gambling','sport',
               'tourism','all_dcms')
sectors <- sectors[,col_names]

# Convert the Asterisks to logical

sectors <- sectors %>% 
  tidyr::gather(sector, present, creative:all_dcms) %>%
  dplyr::rename(SIC = sic) %>%
  dplyr::mutate(
    # Check that there are not NAs (i.e. there will be a *), and assign TRUE or
    # FALSE as appropriate.
    present = ifelse(!is.na(present), TRUE, FALSE),
    # Manual intervention on SIC = 30.12
    SIC2 = ifelse(SIC == '30.12', '30.1', substr(SIC,1,2))
  )

# Note that there are a number of blank rows that get picked up during this 
# operation. These are dropped here. This also drops the row that says 'TOURISM
# (Only available 2011-2015)' without SIC codes.

sectors <- sectors %>%
  dplyr::filter(!(is.na(SIC) & is.na(SIC2)))

# Quick fix for the tourism (62.011) entry

sectors <- sectors %>%
  dplyr::mutate(
    description = ifelse(SIC == 62.011, 'Tourism', description),
    present = ifelse(SIC == 62.011 & sector %in% c('tourism', 'all_dcms'), TRUE, present)
  )

sectors %>% saveRDS('../OFFICIAL/cleaned/OFFICIAL_dcms_sectors.Rds')