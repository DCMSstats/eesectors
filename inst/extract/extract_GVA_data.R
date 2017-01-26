
library(dplyr)
library(testthat)

# This is set up to be run from within the eesectors_data_extract folder. All 
# paths are relative to that. You may need to source the utils.R script before
# running this script.

# Function to extract the data from the existing working file provided by DCMS


read_gva_sheet <- function(
  sheet, 
  file = '../OFFICIAL/dcms/OFFICIAL_working_file_dcms_V13.xlsm', 
  skip = 137, 
  col_names = FALSE
) {
  
  x <- readxl::read_excel(
    file, 
    sheet = sheet, 
    skip = skip,
    col_names = FALSE
  )
  
}

# Generate a list of the years of interest present in the working file 

year_range <- paste(1997:2015)
sheet_range <- paste(year_range, 'Use')

# Extract column names and SICs from working file and clean them.

header_vars <- readxl::read_excel('../OFFICIAL/dcms/OFFICIAL_working_file_dcms_V13.xlsm', sheet = '1997 Use')[7:8,]
header_vars <- data_frame(
  SIC = as.character(header_vars[1,]), 
  product = as.character(header_vars[2,])
) %>% 
  as.tbl %>% 
  dplyr::mutate(
    product = tolower(product),
    product = gsub('\\s\\s+?', '', product),
    product = gsub('\\ \\ +?|\\\n', ' ', product),
    product = gsub('\\,', '', product),
    SIC = ifelse(is.na(SIC), product, SIC)
  ) %>%
  dplyr::filter(
    !is.na(SIC)
  ) %>%
  dplyr::slice(3:115)

# Now extract the SIC for header columns

col_names <- c('year','product_short','product', header_vars$SIC)

# Extract the data from the working file and use the cleaned column names, and
# get rid of rows that we are not interested in

gva <- sheet_range %>% 
  purrr::map_df(read_gva_sheet, .id = 'year') %>%
  dplyr::mutate(year = year_range[as.integer(year)]) %>%
  magrittr::set_colnames(col_names)

# Looks like the rows GVA(I) and GVA(P) are identical. Run some checks to
# confirm this is the case

gva %>% 
  split(.$year) %>%
  purrr::map_df(function(x) {x[1,4:116]-x[2,4:116]}) %>%
  colSums(.,na.rm=TRUE) %>%
  sum

# Great - all seem to be identical, so pick a single row fear each year (like in 2015)

gva <- gva %>%
  dplyr::filter(product_short == 'GVA(P)') %>%
  dplyr::select(-product, -product_short)

# Now put the data into a sensible long format, and format the columns into 
# sensible formats. Note that SIC needs to remain factor as it contains some
# characters

gva <- gva %>%
  tidyr::gather(
    SIC, gva, `01`:`total intermediate comsumption` 
  ) %>%
  dplyr::mutate(
    year = as.integer(year)
  ) 

# Run some checks to make sure this all looks right based on manual inspection 
# of the excel file. These tests have been moved to a sperate file which could
# be OFFICIAL because it makes access to the original data.

# source_dir('tests/')

# Now save the file out to Rds format

gva %>% saveRDS('../OFFICIAL/cleaned/OFFICIAL_gva.Rds')

# We also now have a lookup table for SIC codes to product, so save this to a 
# lookup also. Note that this can be added onto fav with dplyr::left_join(gva,
# header_vars)

header_vars <- header_vars %>% 
  dplyr::mutate_all(factor)

header_vars %>% saveRDS('../OFFICIAL/cleaned/OFFICIAL_sic_product_lookup.Rds')
