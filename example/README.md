## Analyze

Analyze ARB files:

```sh
rebellion analyze test_files/
```

Result:


```
test_files/intl_fi.arb: all caps string key "key2"
test_files/intl_en.arb: all caps string key "key2"
test_files/intl_en.arb: all caps string key "key4"
test_files/intl_fi.arb: no @@locale key found
test_files/intl_en.arb: key "@key4" is missing placeholders definition
test_files/intl_fi.arb key "key3" is missing a plural value "one"
test_files/intl_en.arb key "key3" contains a redundant plural value "zero"
test_files/intl_fi.arb: missing translation for key "key4"
test_files/intl_fi.arb: missing translation for key "key_5"
test_files/intl_fi.arb: @-key "@key" should only be present in the main file
test_files/intl_en.arb: key "key_5" does not match selected naming convention (camel case)

11 issues found
```

## Diff

Find missing translations and print them to console:

```sh
rebellion diff ./myLocalizationsFolder --output=console
```

Result
```
TODO
```

## Sort

Sort keys in ARB files:

```sh
rebellion sort ./myLocalizationsFolder
```
