library(dplyr)
library(testthat)

source('utils.R')

# Load the appropriate sheet. Drop the 13th column which contains a free text 
# note, the 4th column which contains nchar() of column DOMVAL, column 5 which
# is unnamed and simply repeats column DOMVAL, and columns 2 and 3, which a
# replicates of column 11 and 12.

abs <- readxl::read_excel(
  '../OFFICIAL/dcms/OFFICIAL_working_file_dcms_V13.xlsm', 
  sheet = 'New ABS Data'
)[,c(-(2:5),-13)]

# Strip out extraneous columns (Length and ``), then pivot the years into a 
# single column. This step should actually do nothing if the above step worked
# as espected.

abs <- abs %>% 
  dplyr::select(DOMVAL, `2008`, `2009`, `2010`, `2011`, `2012`, `2013`, `2014`)

# Pivot the data into long form. In doing so, I discovered that some of the 
# values in the original data were not being cleanly converted into an integer. 
# Here I check why this is the case. This is due to the presence of full stops 
# in the data, which are either SUPPRESSED, or look like they should be zeros.
# See issue: https://github.gds/DataScience/eesectors_data/issues/1

# First convert to long form

abs <- abs %>%
  tidyr::gather(
    year, abs, `2008`:`2014`
  ) %>%
  dplyr::mutate(
    year = as.integer(year)
  )

# Run the integrity check function to check for conversion issues.

check_na <- integrity_check(abs$abs)
abs$abs[check_na]

# Check that this is what occured in previous attempts (i.e. full stops!)

expect_identical(abs$abs[check_na], rep(".", 11))

# Lots of full stops... After examining the data, it looks like these values 
# should be zeros. But will chase up with DCMS. Convert them to zeros here:

abs <- abs %>%
  dplyr::mutate(
    abs = ifelse(check_na, 0, abs),
    abs = as.numeric(abs)
  )

# Now check again that they were successfully removed.

expect_identical(abs$abs[check_na], rep(0, 11))

# Yes... they have been converted to zeros as expected

# Finally, clean up the sic code by adding a full stop to cases when it is a
# three or four character codes.

abs <- abs %>%
  dplyr::mutate(
    SIC = clean_sic(DOMVAL)
  )

abs %>% 
  saveRDS('../OFFICIAL/cleaned/OFFICIAL_ABS.Rds')
