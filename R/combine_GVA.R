#' @title Combine GVA, ABS, SIC91, and Tourism datasets
#'
#' @description Combines datasets exracted from the underlying spreadsheet using
#'   the \code{extract_XXX} functions. A notebook version of this function
#'   (which may be easier to debug) can be downloaded using the
#'   \code{get_gva_combine()} function. Note that this function in its current
#'   form will only work to reproduce the 2016 SFR, and requires adjustment to
#'   generalise it over new years.
#'
#'   NOTE: THIS FUNCTION RELIES ON DATA WHICH ARE CLASSIFIED AS
#'   OFFICIAL-SENSITIVE. THE OUTPUT OF THIS FUNCTION IS AGGREGATED, AND
#'   PUBLICALLY AVAILABLE IN THE FINAL STATISTICAL RELEASE, HOWEVER CARE MUST BE
#'   EXERCISED WHEN CREATING A PIPELINE INCLUDING THIS FUNCTION. IT IS HIGHLY
#'   ADVISEABLE TO ENSURE THAT THE DATA WHICH ARE CREATED BY THE \code{extract_}
#'   FUNCTIONS ARE NOT STORED IN A FOLDER WHICH IS A GITHUB REPOSITORY TO
#'   MITIGATE AGAINST ACCIDENTAL COMMITTING OF OFFICIAL DATA TO GITHUB. TOOLS TO
#'   FURTHER HELP MITIGATE THIS RISK ARE AVAILABLE AT
#'   https://github.com/ukgovdatascience/dotfiles.
#'
#' @details The best way to understand what happens when you run this function
#'   is to look at the \code{inst/gva_combine.Rmd} notebook, which can be
#'   downloaded automatically using the \code{get_gva_combine()} function, or by
#'   visiting
#'   \url{https://github.com/ukgovdatascience/eesectors/blob/master/inst/gva_combine.Rmd}.
#'    A brief explanation of what the function does here:
#'
#'   1. Remove SIC 91 data from \code{ABS} and swap in values from \code{SIC91})
#'   2. Duplicate the 2014 \code{ABS} values to use for 2015 (2015 values not
#'   being available - this may change in future years.). 2. Merge the
#'   \code{eesectors::DCMS_sectors} into \code{ABS} to get the 2 digit SIC code.
#'   3. Calculate sums across sectors and years. 4. Add in total UK GVA from
#'   \code{GVA}. 5. Match in \code{tourism} data. 6. Add \code{tourism} overlap.
#'   7. Build the dataframe into a format that is expected by the
#'   \code{long_data} class.
#'
#' @param ABS ABS data as extracted by \code{eesectors::extract_ABS_data()}.
#' @param GVA ABS data as extracted by \code{eesectors::extract_GVA_data()}.
#' @param SIC91 ABS data as extracted by \code{eesectors::extract_SIC91_data()}.
#' @param DCMS_sectors ABS data as extracted by
#'   \code{eesectors::extract_DCMS_sectors()} or matching the
#'   \code{eesectors::DCMS_sectors} in-built dataset.
#' @param tourism ABS data as extracted by \code{eesectors::extract_tourism_data()}.
#'
#' @return A \code{data.frame} as expected by the \code{long_data} class.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#'
#' input <- 'OFFICIAL_working_file_dcms_V13.xlsm'
#'
#' combine_GVA(
#'   ABS = eesectors::extract_ABS_data(input),
#'   GVA = eesectors::extract_ABS_data(input),
#'   SIC91 = eesectors::extract_ABS_data(input),
#'   DCMS_sectors = eesectors::DCMS_sectors,
#'   tourism = eesectors::extract_ABS_data(input)
#' )
#' }
#'
#' @export

combine_data <- function(
  ABS = NULL,
  GVA = NULL,
  SIC91 = NULL,
  DCMS_sectors = eesectors::DCMS_sectors,
  tourism = NULL
) {

  #### 1. Deal with SIC 91 ----

  # The `SIC91` data needs to be merged into `ABS` as the first operation.
  # This replaces the SIC 91 data from the Annual Business Survey (ABS) with sales data.

  # Remove all the rows that correspond to SIC 91 based on the unique SIC codes in
  # SIC91.

  SIC91_mask <- unique(SIC91$SIC)

  ABS_no91 <- ABS[!ABS$SIC %in% SIC91_mask,]

  # Now merge `ABS_no91` with `SIC91`.

  ABS_91 <- dplyr::full_join(ABS_no91, SIC91)

  #### 2. Duplicate 2014 ABS data for 2015 ----

  # Since the `ABS_91` data only run to 2014, first duplicate the 2014 to be
  # used for 2015: duplicate the 2014 data for 2015

  ABS_2015 <- ABS[ABS$year == 2014,]
  ABS_2015$year <- 2015
  ABS_2015 <- rbind(ABS_2015, ABS_91)

  ### 3. Merge sectors and ABS datasets ----

  GVA_sectors <- dplyr::left_join(DCMS_sectors, ABS_2015)
  GVA_sectors$ABS_ind_GVA <- GVA_sectors$ABS
  GVA_sectors <- GVA_sectors[, !names(GVA_sectors) == 'ABS']

  # Then calculate the 2 digit SIC total GVA (from `ABS_91`) for each of the
  # DCMS sectors. Extract all the unique 2 digit SICs

  SIC2_unique_mask <- !is.na(GVA_sectors$SIC2)
  SIC2_unique <- GVA_sectors[SIC2_unique_mask, 'SIC2']
  SIC2_unique <- unique(GVA_sectors$SIC2)

  # Next we use `SIC2_unique` to extract the 2 digit SIC totals from `ABS_91`.
  # This will form the denominator in our division

  denom <- ABS_2015[ABS_2015$SIC %in% SIC2_unique,]
  denom$ABS_2digit_GVA <- denom$ABS
  denom$SIC2 <- denom$SIC
  denom <- denom[,c('year','SIC2', 'ABS_2digit_GVA')]

  # Now join this back into `GVA`. Join back into GVA for division.

  GVA_sectors <- GVA_sectors[which(GVA_sectors$present == TRUE),]
  GVA_sectors <- dplyr::left_join(GVA_sectors, denom, by = c('year', 'SIC2'))
  GVA_sectors$perc_split <- GVA_sectors$ABS_ind_GVA / GVA_sectors$ABS_2digit_GVA
  GVA_sectors <- GVA_sectors[!(is.na(GVA_sectors$year) & is.na(GVA_sectors$ABS_ind_GVA)),]

  # Now, multiply `perc_split` by `GVA` after joining with `GVA` to get the
  # `BB16_GVA` (column Q in `Working File` worksheet).

  GVA_sectors <- dplyr::left_join(GVA_sectors, GVA, by = c('SIC2' = 'SIC', 'year'))
  GVA_sectors$BB16_GVA <-  GVA_sectors$perc_split * GVA_sectors$GVA

  ### 4. Calculate sums across sectors and years ----

  # Finally calculate the sums across all sectors and years.

  GVA_by_sector <- dplyr::group_by_(GVA_sectors, ~year, ~sector)
  GVA_by_sector <- dplyr::summarise_(GVA_by_sector, GVA = ~sum(BB16_GVA))

  #### 5. Add in total UK GVA from gva ----

  # Quick lookup table to convert SIC2 to Sector

  lookup <- c('total intermediate comsumption' = 'UK')

  # Use create a table to merge in with GVA_by_sector

  GVA_UK <- GVA[GVA$SIC == names(lookup),]
  GVA_UK$sector <- lookup[GVA_UK$SIC]
  GVA_UK <- GVA_UK[,c('year', 'sector', 'GVA')]

  # Merge this into `GVA_by_sector` by full join

  GVA_by_sector <- dplyr::full_join(GVA_by_sector, GVA_UK)

  ### 6. Match in Tourism data ----

  # Tourism data is provided in a separate spreadsheet and imported in the
  # `tourism` object

  tourism_UK <- tourism
  tourism_UK$sector <- 'tourism'
  tourism_UK <- tourism_UK[, c('year', 'sector', 'GVA')]
  GVA_by_sector <- dplyr::full_join(tourism_UK, GVA_by_sector)

  ### 7. Add tourism overlap ----

  # Also need to add the `$overlap` from tourism to the `all_dcms` totals in
  # `GVA_by_sector`

  tourism_all_sectors <- tourism
  tourism_all_sectors$sector <- 'all_dcms'
  tourism_all_sectors <- tourism_all_sectors[ ,c('year', 'sector', 'overlap')]
  GVA_by_sector <- dplyr::right_join(tourism_all_sectors, GVA_by_sector)
  GVA_by_sector$GVA <- ifelse(
    !is.na(GVA_by_sector$overlap),
    GVA_by_sector$overlap + GVA_by_sector$GVA,
    GVA_by_sector$GVA
  )
  GVA_by_sector <- GVA_by_sector[, !names(GVA_by_sector) == 'overlap']

  #### 8. Build the GVA_by_sector dataframe expected by the eesectors package ----

  # Build df to match eesectors::GVA_by_sector_2016
  # Will need adjusting in future versions

  GVA_by_sector <- GVA_by_sector[GVA_by_sector$year %in% 2010:2015,]
  GVA_by_sector <- dplyr::ungroup(GVA_by_sector) # May not be required
  GVA_by_sector$GVA <- round(GVA_by_sector$GVA, 2)
  GVA_by_sector$sector <- factor(GVA_by_sector$sector)
  GVA_by_sector$year <- as.integer(GVA_by_sector$year)
  GVA_by_sector <- GVA_by_sector[, c('sector', 'year', 'GVA')]
  GVA_by_sector <- dplyr::arrange_(GVA_by_sector, ~year, ~sector)

  return(GVA_by_sector)
}
