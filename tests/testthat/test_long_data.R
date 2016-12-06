context('Test the long_data class')

# Create an example data frame

test_that(
  'The long_data() class return as expected?',
  {

    expect_message(
      long_data(GVA_by_sector_2016)
    )

    expect_is(
      long_data(GVA_by_sector_2016),
      'long_data'
    )

    expect_equal(
      attributes(long_data(GVA_by_sector_2016))$names,
      c("df", "colnames", "type", "sector_levels", "years")
    )

  }
)


test_that(
  'long_data() fails under bad cases',
  {

    expect_error(
      long_data(mtcars)
    )

    expect_is(
      long_data(GVA_by_sector_2016),
      'long_data'
    )

  }
)




test_that(
  'long_data raises warnings when data fail statistical tests',
 {

   # Create a deliberately problematic dataset
   # Case when there one value is just too high

   gva_outlier <- GVA_by_sector_2016 %>%
     dplyr::mutate(
       GVA = ifelse(sector == 'Sport' & year == 2015, GVA + 10^4, GVA)
     )

  expect_warning(
    long_data(gva_outlier)
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
    long_data(gva_maha_distance)
  )


   }
 )
