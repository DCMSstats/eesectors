context("get_gva_combine works as expected")

testdl <- file.path('testdata', 'gva_combine.Rmd')

test_that(
  "get_gva_combine can download latest version of gva_combine",
  {

    expect_message(get_gva_combine(file = testdl))
    expect_true(file.exists(testdl))
    expect_error(get_gva_combine(url = '127.0.0.1/gva_combine.Rmd',file = testdl))

  }
)

file.remove(testdl)
