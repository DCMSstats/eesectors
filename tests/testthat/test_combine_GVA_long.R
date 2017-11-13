context("combine_GVA_long works as expected")

input <- example_working_file("example_working_file.xlsx")
ABS = suppressMessages(extract_ABS_data(input))
GVA = suppressMessages(extract_GVA_data(input))
SIC91 = suppressMessages(extract_SIC91_data(input))
tourism = suppressMessages(extract_tourism_data(input))

combine_GVA_long <- combine_GVA_long(
  ABS = ABS,
  GVA = GVA,
  SIC91 = SIC91,
  DCMS_sectors = eesectors::DCMS_sectors)


test_that(
  "combine_GVA_long returns object with right class", {
    expect_identical(
      class(combine_GVA_long),
      c("combine_GVA_long", "tbl_df", "tbl", "data.frame"))
  }
)

test_that(
  "combine_GVA_long throws error if given wrong dataframe", {
    class(ABS) <- class(ABS)[-1]
    expect_error(combine_GVA_long(
      ABS = ABS,
      GVA = GVA,
      SIC91 = SIC91,
      DCMS_sectors = eesectors::DCMS_sectors))
  }
)





