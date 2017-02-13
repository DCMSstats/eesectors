context('Test the year_sector_data class')

# Create an example data frame

test_that(
  'The year_sector_data() class return as expected?',
  {

    expect_message(
      year_sector_data(GVA_by_sector_2016)
    )

    expect_is(
      year_sector_data(GVA_by_sector_2016),
      'year_sector_data'
    )

    expect_equal(
      attributes(year_sector_data(GVA_by_sector_2016))$names,
      c("df", "colnames", "type", "sector_levels", "sectors_set", "years")
    )

  }
)


test_that(
  'year_sector_data() fails under bad cases',
  {

    expect_error(
      year_sector_data(mtcars)
    )

    expect_is(
      year_sector_data(GVA_by_sector_2016),
      'year_sector_data'
    )

  }
)




test_that(
  'year_sector_data raises warnings when data fail statistical tests',
 {

   # Create a deliberately problematic dataset
   # Case when there one value is just too high

   gva_outlier <- GVA_by_sector_2016 %>%
     dplyr::mutate(
       GVA = ifelse(sector == 'sport' & year == 2015, GVA + 10^4, GVA)
     )

  expect_warning(
    year_sector_data(gva_outlier)
    )

  # Case when one value is out of step with the trend. Note that when x = 6 for
  # within_n_mads(x), then the sensitivity of the test when instantiatin gthe
  # class is pretty poor, and unlikely to detect much. For now this will remain
  # the behaviour, as any otehr behaviour causes a failure in compilation on
  # travis.

  gva_maha_distance <- GVA_by_sector_2016 %>%
    dplyr::mutate(
      GVA = ifelse(sector == 'UK' & year == 2013, 12000000, GVA)
    )

    expect_warning(
    year_sector_data(gva_maha_distance)
  )


   }
 )
