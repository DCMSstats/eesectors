context('relative_to functions as expected')

test_that(
  'Works on negative single cases',
  {
    expect_equal(
      relative_to(101,100),
      -0.99
    )
  }
)

test_that(
  'Works on positive single cases',
  {
    expect_equal(
      relative_to(100,101),
      1
    )
  }
)

test_that(
  'Works on mixed vectors',
  {
    expect_equal(
      relative_to(100, 90:110),
      -10:10
    )
  }
)
