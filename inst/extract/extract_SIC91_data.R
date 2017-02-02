
library(dplyr)
library(readxl)

# This is set up to be run from within the eesectors_data_extract folder. All 
# paths are relative to that. You may need to source the utils.R script before
# running this script.

# Extract the entire worksheet from excel

SIC91 <- readxl::read_excel(
  '../OFFICIAL/dcms/OFFICIAL_working_file_dcms_V13.xlsm', 
  sheet = 'SIC 91 Sales Data',
  col_names = FALSE
) 

# Name columns

colnames(SIC91) <- c('SIC','description','year','gva','code')

# Extract columns of interest

SIC91 <- SIC91 %>%
  dplyr::select(SIC, year, gva)

# Drop rows that are completely NA from the bottom of the dataset/

SIC91 <- SIC91 %>%
  dplyr::filter(!(is.na(SIC) & is.na(year) & is.na(gva)))

# Save out to file

SIC91 %>% saveRDS('../OFFICIAL/cleaned/OFFICIAL_SIC91_data.Rds')