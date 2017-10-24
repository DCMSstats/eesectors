context("APS_timeseries works as expected")

reference <- file.path('testdata', 'test_reference_APS.Rds')

test_that(
  "APS_timeseries produces a list",
  {
    #test that the output spss file matches the expected format
    APS_reference <- readRDS(reference)
    expect_is(eesectors::APS_timeseries(APS_reference),"list")
  }
)
