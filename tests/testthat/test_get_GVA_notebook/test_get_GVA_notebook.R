context("get_GVA_notebook works as expected")

testdl <- file.path('testdata', 'gva_combine.Rmd')

test_that(
  "get_GVA_notebook can download latest version of gva_combine",
  {

    expect_message(get_GVA_notebook(file = testdl))
    expect_true(file.exists(testdl))
    expect_error(get_GVA_notebook(url = '127.0.0.1/combine_GVA.Rmd',file = testdl))

  }
)

file.remove(testdl)
