Feature: eyaml hiera 5 integration

  In order to use eyaml as a hiera 5 lookup_key function
  As a developer using hiera-eyaml
  I want to verify that puppet lookup can use eyaml_lookup_key to decrypt data

  Scenario: lookup a plain value from an eyaml file
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s plain_value`
    Then the exit status should be 0
    And the output should match /^not a secret$/

  Scenario: lookup an encrypted string
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s secret_string`
    Then the exit status should be 0
    And the output should match /^the eagle has landed$/

  Scenario: lookup an encrypted block
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s secret_block`
    Then the exit status should be 0
    And the output should match /^block of secrets$/

  Scenario: lookup an encrypted multiline string
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s secret_multiline`
    Then the exit status should be 0
    And the output should match /^line one\nline two$/

  Scenario: lookup an array containing encrypted values
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as json secret_array`
    Then the exit status should be 0
    And the output should contain '["first secret","plain item"]'

  Scenario: lookup a hash containing encrypted values
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as json secret_hash`
    Then the exit status should be 0
    And the output should contain '{"user":"admin","password":"hunter2"}'

  Scenario: lookup an encrypted value that uses interpolation
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s secret_interpolated`
    Then the exit status should be 0
    And the output should match /^prefix not a secret suffix$/

  Scenario: lookup a value encrypted with multiple plugins
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s secret_mixed_plugins`
    Then the exit status should be 0
    And the output should match /^red lorry yellow lorry$/

  Scenario: deep merge encrypted and plain hashes across hierarchy levels
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as json --merge deep merged_hash`
    Then the exit status should be 0
    And the output should contain '"from_secrets":"decrypted and merged"'
    And the output should contain '"from_common":"plain and merged"'

  Scenario: lookup an encrypted value with keys from environment variables
    Given I load the keypair into envvars
    When I run `puppet lookup --confdir ./puppet-hiera5 --render-as s envvar_secret`
    Then the exit status should be 0
    And the output should match /^keys from the environment$/

  Scenario: lookup an encrypted value with a missing private key
    When I run `puppet lookup --confdir ./puppet-hiera5 --explain unreadable_secret`
    Then the output should contain "hiera-eyaml backend error decrypting"
    And the output should contain "file ./missing/private_key.pkcs7.pem does not exist"

  Scenario: lookup a value encrypted with newly created keys
    When I run `eyaml createkeys --pkcs7-private-key new_keys/private_key.pkcs7.pem --pkcs7-public-key new_keys/public_key.pkcs7.pem`
    And I run `bash -c 'echo "---" > puppet-hiera5/environments/local/data/new_keys.eyaml'`
    And I run `bash -c 'eyaml encrypt -o string -l new_secret -s "freshly encrypted" --pkcs7-public-key new_keys/public_key.pkcs7.pem >> puppet-hiera5/environments/local/data/new_keys.eyaml'`
    And I run `puppet lookup --confdir ./puppet-hiera5 --render-as s new_secret`
    Then the exit status should be 0
    And the output should match /^freshly encrypted$/
