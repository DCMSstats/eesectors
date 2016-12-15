context('Utility functions work as expected')

test_that(
  'Works on negative single cases',
  {
    expect_equal(relative_to(101,100), -0.99)
  }
)

test_that(
  'Works on positive single cases',
  {
    expect_equal(relative_to(100,101), 1)
  }
)

test_that(
  'Works on mixed vectors',
  {
    expect_equal(relative_to(100, 90:110), -10:10)
  }
)

test_that(
  'Returns expected values',
  {

    expect_is(roundf(pi), 'character')

    expect_identical(roundf(pi*10^3, fmt = '%.2f'), as.character(3.14))

  }
)

test_that(
  'Works on vectors',
  {

    vec <- rep(pi * 10^3, 10)

    expect_identical(roundf(vec, fmt = '%.2f'), as.character(rep(3.14, 10)))

  }
)

test_that(
  'Will do nothing to characters',
  {

    expect_identical(roundf('character vector'), 'character vector')

  }
)

test_that(
  'Works for dataframes',
  {

    expect_is(roundf(mtcars), c('tbl_df','tbl','data.frame'))

    expect_is(class(roundf(mtcars)[[1]]), 'character')

  }
)
