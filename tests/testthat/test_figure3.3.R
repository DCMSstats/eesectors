context("figure3.3 works as expected")

test_that(
  "figure3.3 runs without errors",
  {

    gva <- year_sector_data(GVA_by_sector_2016)

    expect_silent(figure3.3(gva))

  }
)
