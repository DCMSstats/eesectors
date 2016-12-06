context('Test the long_data class')

# Create an example data frame

test_that(
  'The long_data() class return as expected?',
  {

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
