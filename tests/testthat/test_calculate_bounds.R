context('Test that calculate_bounds behaves as expected')

# Create an example data frame

ex_df <- data.frame(
  sector = c('A','B','C'),
  year = rep(2001:2010, 3),
  value = rep(1:10, 3)
)


test_that(
  'Simple test on data.frame returned by calculate_bounds()',
  {

    expect_is(
      calculate_bounds(ex_df),
      c('data.frame','tbl','data_frame')
    )

    expect_equal(
      dim(calculate_bounds(ex_df)),
      c(3, 5)
    )

    expect_equal(
      names(calculate_bounds(ex_df)),
      c("sector", "year", "value", "upper_bound", "lower_bound")
    )

  }
)


test_that(
  'Calculate_bounds creates accurate upper and lower bound for simple cases',
  {
    expect_equal(
      calculate_bounds(ex_df)$upper_bound,
      rep(median(1:9) + 3 * mad(1:9), 3)
    )

    expect_equal(
      calculate_bounds(ex_df)$lower_bound,
      rep(median(1:9) - 3 * mad(1:9), 3)
    )
  }
)

ex_df <- data.frame(
  sector = rep(c('A','B','C'), each = 10),
  year = rep(2001:2010, 3),
  value = c(1:10, 21:30, 31:40)
)

test_that(
  'Calculate_bounds creates accurate upper and lower bound for slightly more complex cases',
  {

    expect_equal(
      calculate_bounds(ex_df)$upper_bound,
      c(
        median(1:9) + 3 * mad(1:9),
        median(21:29) + 3 * mad(21:29),
        median(31:39) + 3 * mad(31:39)
      )
    )

    expect_equal(
      calculate_bounds(ex_df)$lower_bound,
      c(
        median(1:9) - 3 * mad(1:9),
        median(21:29) - 3 * mad(21:29),
        median(31:39) - 3 * mad(31:39)
      )
    )

  }
)
