Feature: eyaml key sources

  In order to keep my keys where it suits me
  As a developer using hiera-eyaml
  I want to use the eyaml tool with keys from files and environment variables

  Scenario: encrypt and decrypt with key files given on the command line
    When I run `eyaml createkeys --pkcs7-private-key custom_keys/private.pem --pkcs7-public-key custom_keys/public.pem`
    And I run `bash -c "eyaml encrypt -o string -s 'custom key files' --pkcs7-public-key custom_keys/public.pem > custom.txt"`
    And I run `eyaml decrypt -f custom.txt --pkcs7-private-key custom_keys/private.pem --pkcs7-public-key custom_keys/public.pem`
    Then the exit status should be 0
    And the stdout should contain exactly "custom key files"

  Scenario: encrypt and decrypt with keys from environment variables
    Given I load the keypair into envvars
    When I run `bash -c "eyaml encrypt -o string -s 'keys from env' --pkcs7-public-key-env-var EYAML_PUBLIC_KEY --pkcs7-public-key does_not_exist.pem | eyaml decrypt --stdin --pkcs7-private-key-env-var EYAML_PRIVATE_KEY --pkcs7-private-key does_not_exist.pem"`
    Then the exit status should be 0
    And the stdout should contain exactly "keys from env"

  Scenario: encrypt and decrypt with keys from base64 encoded environment variables
    Given I load the keypair into base64 envvars
    When I run `bash -c "eyaml encrypt -o string -s 'keys from b64 env' --pkcs7-b64-public-key-env-var EYAML_B64_PUBLIC_KEY --pkcs7-public-key does_not_exist.pem | eyaml decrypt --stdin --pkcs7-b64-private-key-env-var EYAML_B64_PRIVATE_KEY --pkcs7-private-key does_not_exist.pem"`
    Then the exit status should be 0
    And the stdout should contain exactly "keys from b64 env"

  Scenario: encrypt with a missing public key file
    When I run `eyaml encrypt -o string -s some_string --pkcs7-public-key does_not_exist.pem`
    Then the exit status should be 1
    And the stderr should contain "file does_not_exist.pem does not exist"

  Scenario: decrypt with a missing private key file
    When I run `eyaml decrypt -f test_input.encrypted.txt --pkcs7-private-key does_not_exist.pem`
    Then the exit status should be 1
    And the stderr should contain "file does_not_exist.pem does not exist"

  Scenario: decrypt with an unset private key environment variable
    When I run `eyaml decrypt -f test_input.encrypted.txt --pkcs7-private-key-env-var UNSET_EYAML_PRIVATE_KEY`
    Then the exit status should be 1
    And the stderr should contain "env UNSET_EYAML_PRIVATE_KEY is not set"

  Scenario: decrypt with an unset base64 private key environment variable
    When I run `eyaml decrypt -f test_input.encrypted.txt --pkcs7-b64-private-key-env-var UNSET_EYAML_B64_PRIVATE_KEY`
    Then the exit status should be 1
    And the stderr should contain "env UNSET_EYAML_B64_PRIVATE_KEY is not set"
