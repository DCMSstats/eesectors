
library(dplyr)
library(readxl)

# This is set up to be run from within the eesectors_data_extract folder. All 
# paths are relative to that. You may need to source the utils.R script before
# running this script.

# Extract the entire worksheet from excel

tourism <- readxl::read_excel(
  '../OFFICIAL/dcms/OFFICIAL_working_file_dcms_V13.xlsm', 
  sheet = 'Tourism',
  col_names = TRUE
)

colnames(tourism) <- c('year','gva','total','perc','overlap')
# Remove the extraneous rows

tourism <- tourism %>%
  dplyr::filter(!(is.na(year) & is.na(gva) & is.na(total) & is.na(perc) & is.na(overlap)))

# Save out to file

tourism %>% saveRDS('../OFFICIAL/cleaned/OFFICIAL_tourism_data.Rds')
