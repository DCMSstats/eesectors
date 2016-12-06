context('Test that incoming data matches that in the existing SFR')

# This test is designed to test the process of cleaning the data, not the
# package itself. Assume that GVA_by_sector_new is the new data being imported
# from code that has been written to extract it from raw data sources. In time
# it may make sense to move this into a second package.

# For development packages, just duplicate the existing dataset.

GVA_by_sector_new <- GVA_by_sector_2016

test_that(
  'GVA_by_sector_new matches GVA_by_sector_2016 in shape and form',
  {
    expect_is(
      GVA_by_sector_new,
      c('tbl_df', 'tbl', 'data.frame')
    )

    # Check that the dimensions match the original dataset. This is a very
    # specific test, and may fail under certain conditions, see below for more
    # generic tests.

    expect_equal(
      dim(GVA_by_sector_new),
      dim(GVA_by_sector_2016)
    )

  }
)

test_that(
  'Check for NAs in any column',
  {

    # Check whether there are any NAs contained in any column

    expect_false(
      anyNA(GVA_by_sector_new$sector)
    )

    expect_false(
      anyNA(GVA_by_sector_new$year)
    )

    expect_false(
      anyNA(GVA_by_sector_new$GVA)
    )

  }
)

### Generic assumptions that should work on any new df

test_that(
  'GVA_by_sector_new has the expected dimensions',
  {
    # If there are x years and y sectors, then there should be x * y rows,
    # unless there are missing values, which should be coded with NA

    n_sectors <- length(unique(GVA_by_sector_new$sector))
    n_years <- length(unique(GVA_by_sector_new$year))
    n_rows_expected <- n_sectors * n_years

    expect_equal(
      dim(GVA_by_sector_new),
      c(n_rows_expected, 3)
    )
  }
)


# Previous data were built in previous publications. We'll make the
# assumption that those are right, so produce a test that checks our most
# recently calculated figures against everything that came before.

# One could play with the multiples of mad to achieve better precision at
# spotting errors.

bounds <- calculate_bounds(GVA_by_sector_2016, 2015, tol = 3)

print(bounds)

test_that(
  'New value is GVA values are less than the median + median absolute deviation of previous values',
  {

    # Rationale: upper bound should always be higher than the new GVA

    expect_equal(
      bounds$upper_bound - bounds$GVA > 0,
      rep(TRUE,nrow(bounds))
    )
  }
)

test_that(
  'New GVA values are greater than the median - median absolute deviation of previous values',
  {

    # Rationale: GVA should always be higher than the lower bound

    expect_equal(
      bounds$GVA - bounds$lower_bound > 0,
      rep(TRUE,nrow(bounds))
    )
  }
)
