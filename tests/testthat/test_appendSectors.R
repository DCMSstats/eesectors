context("appendSectors works as expected")

reference <- file.path('testdata', 'test_reference_APS.Rds')

test_that(
  "appendSectors adds the right number of sector membership variables",
  {
    #test that the output spss file matches the expected format
    APS_reference <- readRDS(reference)
    APS_sectors <- appendSectors(APS_reference)
    nsectors <- length(unique(DCMS_sectors$sector))

    expect_equal(length(APS_sectors), length(APS_reference) + 2 * nsectors)

    #test that each variable contains expected data type (logical)
    for(s in unique(DCMS_sectors$sector)){
      expect_type(eval(parse(text=paste0("APS_sectors$", s,"_main"))),"logical")
      }
  }
)
