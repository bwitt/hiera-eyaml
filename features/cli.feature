Feature: eyaml command line

  In order to discover how to use eyaml
  As a developer using hiera-eyaml
  I want the eyaml tool to dispatch subcommands and validate their arguments

  Scenario: running eyaml without a subcommand lists the subcommands
    When I run `eyaml`
    Then the output should contain "Unknown subcommand"
    And the output should match /createkeys, decrypt, edit, encrypt, recrypt, version/

  Scenario: running eyaml with an unknown subcommand
    When I run `eyaml frobnicate`
    Then the output should contain "Unknown subcommand: frobnicate"

  Scenario: show the help page
    When I run `eyaml help`
    Then the output should contain "Available subcommands:"
    And the output should match /^\s+encrypt: encrypt some data/
    And the output should match /^\s+decrypt: decrypt some data/
    And the output should contain "Installed Plugins:"
    And the output should match /^\s+plaintext$/

  Scenario: a leading option shows the help page
    When I run `eyaml --help`
    Then the output should contain "Available subcommands:"

  Scenario: show help for a subcommand
    When I run `eyaml encrypt --help`
    Then the output should contain "eyaml encrypt: encrypt some data"
    And the output should contain "--output"

  Scenario: show the version
    When I run `eyaml version`
    Then the exit status should be 0
    And the stderr should match /hiera-eyaml \(core\): \d+\.\d+\.\d+/
    And the stderr should match /hiera-eyaml-plaintext \(gem\): /

  Scenario: encrypt requires a source
    When I run `eyaml encrypt`
    Then the exit status should not be 0
    And the stderr should contain "You must specify a source"

  Scenario: encrypt accepts only one source
    When I run `eyaml encrypt -s some_string -f test_input.txt`
    Then the exit status should not be 0
    And the stderr should contain "You can only specify one of (string, file)"

  Scenario: decrypt requires a source
    When I run `eyaml decrypt`
    Then the exit status should not be 0
    And the stderr should contain "You must specify a source"

  Scenario: decrypt accepts only one source
    When I run `eyaml decrypt -s some_string -e test_input.yaml`
    Then the exit status should not be 0
    And the stderr should contain "You can only specify one of (eyaml, string)"

  Scenario: edit requires a file
    When I run `eyaml edit`
    Then the exit status should not be 0
    And the stderr should contain "You must specify an eyaml file"

  Scenario: recrypt requires a file
    When I run `eyaml recrypt`
    Then the exit status should not be 0
    And the stderr should contain "You must specify an eyaml file"

  Scenario: recrypt reports a missing file
    When I run `eyaml recrypt does_not_exist.eyaml`
    Then the exit status should be 1
    And the stderr should contain "No such file or directory"
