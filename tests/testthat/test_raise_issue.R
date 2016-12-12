context('Test the raise_issue function')

# Create an example data frame

test_that(
  'Test that raise_issue returns warnings',
  {

    expect_warning(
      raise_issue('Error string to convert to warning')
    )

  }
)

# Note that this test will require a valid GITHUB_PAT without which the test may
# fail. In addition you will need an internet connection since this test uses
# the github API via the gh package.

test_that(
  'Test that raise_issue creates github issues',
  {

    # Create a test github issue

    hash <- digest::digest(Sys.time())
    owner = 'ukgovdatascience'
    repo = 'issue_testing'
    body = 'Test issue created by eesectors package'

    suppressWarnings(raise_issue(
      'Error string to convert to warning',
      log_issues = TRUE,
      title = hash,
      body = body
    )
    )

    # Check that the issue was successfully created

    issues <- gh::gh(
      '/repos/:owner/:repo/issues',
      owner = 'ukgovdatascience',
      repo = 'issue_testing'
    )

    issues_df <- data.frame(
      number = purrr::map_int(issues, 'number'),
      title = purrr::map_chr(issues, 'title')
    )

    expect_true(
      hash %in% issues_df$title
    )

    # Close the github issue

    gh::gh(
      'PATCH /repos/:owner/:repo/issues/:number',
      owner = 'ukgovdatascience',
      repo = 'issue_testing',
      number = issues_df[issues_df$title == hash,'number'],
      state = 'closed'
    )

  }
)
