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
  'roundf returns expected values',
  {

    expect_is(roundf(pi), 'character')

    expect_identical(roundf(pi*10^3, fmt = '%.2f'), as.character(3.14))

  }
)

test_that(
  'roundf works on vectors',
  {

    vec <- rep(pi * 10^3, 10)

    expect_identical(roundf(vec, fmt = '%.2f'), as.character(rep(3.14, 10)))

  }
)

test_that(
  'roundf will do nothing to characters',
  {

    expect_identical(roundf('character vector'), 'character vector')

  }
)

test_that(
  'roundf works for dataframes',
  {

    expect_is(roundf(mtcars), c('tbl_df','tbl','data.frame'))

    expect_is(class(roundf(mtcars)[[1]]), 'character')

  }
)


test_that(
  'clean_sic works as expected.',
  {

    expect_identical(clean_sic(1234), "12.34")
    expect_identical(clean_sic(c(1234,1234)), c("12.34","12.34"))
    expect_identical(clean_sic(NA), NA)
    expect_identical(clean_sic(12), 12)
    expect_identical(clean_sic(12345), 12345)
    expect_identical(clean_sic(c(12,123,1234,12345, NA)), c('12', '12.3', '12.34', 12345, NA))

  }
)


test_that(
  'na_cols works as expected.',
  {
    # Check it works when there are no NAs

    expect_equal(character(0), na_cols(mtcars))

    # Create test dataframe:

    df <- data.frame(
      a = c(1:10, NA),
      b = NA,
      c = 1:11
    )

    # Check that we only see NAs in a and b

    expect_equal(c('a','b'), na_cols(df))

  }
)


test_that(
  'integrity_check() works as expected.',
  {

    # Check that messages and warnings trigger for passes and fails
    # respectively.

    expect_silent(integrity_check('.'))
    expect_silent(integrity_check('a'))
    expect_silent(integrity_check(c(1,'a')))
    expect_silent(integrity_check(c(1,2,3,'a')))
    expect_silent(integrity_check('1'))
    expect_silent(integrity_check(NA))
    expect_silent(integrity_check(c(1, 1.1, 1.2)))
    expect_silent(integrity_check(c(1, 1.1, 1.2, NA)))

    # Check what actual content is returned. Supressing the warning messages may
    # not be the best approach here, but the test will still fail if it needs
    # to.

    expect_equal(case1 <- integrity_check('1'), FALSE)
    expect_equal(case2 <- integrity_check(c(1, 1.2, NA, '.')), c(FALSE, FALSE, FALSE, TRUE))
    expect_equal(case3 <- integrity_check('fail'), TRUE)
    expect_equal(case4 <- integrity_check(c('.','fail')), c(TRUE, TRUE))

  }
)

full_path = file.path('testdata','mtcars.Rds')
if (file.exists(full_path)) file.remove(full_path)

test_that(
  "save_rds works as expected.",
  {

    expect_message(save_rds(mtcars, full_path))
    expect_true(file.exists(full_path))

  }
)

file.remove(full_path)


test_that(
  "year_split works as expected.",
  {
    year_range <- 1997:2015
    sheet_range <- paste(year_range, 'Use')

    expect_equal(year_range, year_split(sheet_range))
    expect_equal(2017, year_split('2017 Use'))

  }
)


test_that(
  "zero_ works as expected.",
  {

    expect_equal(zero_('1'), '01')
    expect_equal(zero_('a'), 'a')
    expect_equal(zero_('45'), '45')
    expect_equal(zero_(NA), NA)

  }
)

test_that(
  "zero_prepend works as expected.",
  {

    expect_equal(zero_prepend(1:10), c('01','02','03','04','05','06','07','08','09','10'))
    expect_equal(zero_prepend(c('0','1','a','45',NA)), c('00','01','a','45',NA))

  }
)

