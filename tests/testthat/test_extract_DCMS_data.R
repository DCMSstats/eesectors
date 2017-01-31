context("extract_DCMS_sectors works as expected")

test_that(
  "extract_DCMS_sectors can extract data from a dummy spreadsheet",
  {
    skip('Tests not yet implemented')

    extract_DCMS_sectors('~/Documents/eesectors_data/dcms/OFFICIAL_working_file_dcms_V13.xlsm')
    expect_true(file.exists('./DCMS_sectors.Rds'))

  }
)
