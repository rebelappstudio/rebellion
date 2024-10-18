![Banner](https://github.com/rebelappstudio/rebellion/raw/main/assets/banner.png)

# Rebellion

Rebellion is a linter for Flutter's ARB translation files.

Features:
* Analyze ARB files and find possible issues
* Find missing translations
* Sort ARB files

At the moment rebellion is meant to be used as a CLI tool and can't be used as a custom lint rule. Consider adding it to your CI job to make sure all strings are translated and have no issues.

* [Github repo](https://github.com/rebelappstudio/rebellion/)
* [pub.dev page](https://pub.dev/packages/rebellion)
* [Rebel App Studio](https://rebelappstudio.com)


## Example

```
> rebellion analyze ./l10n/

l10n/intl_fi.arb: all caps string key "key2"
l10n/intl_fi.arb: no @@locale key found
l10n/intl_en.arb: key "@key4" is missing placeholders definition
l10n/intl_fi.arb key "key3" is missing a plural value "one"
l10n/intl_en.arb key "key3" contains a redundant plural value "zero"
l10n/intl_fi.arb: missing translation for key "key_5"
l10n/intl_fi.arb: @-key "@key" should only be present in the main file
l10n/intl_en.arb: key "key_5" does not match selected naming convention (camel case)

8 issues found
```

## Installation

```sh
dart pub global activate rebellion
```

## Analyze ARB files

Find problems in ARB files:

```sh
rebellion analyze ./l10n/
```

See Configuration section below to customize the set of rules.

## Diff

Find missing translations:

```sh
> rebellion diff ./l10n/

l10n/intl_fi.arb: 2 missing translations:
 - key4
 - key_5
```

By default this command prints missing translations to the console. You can instruct Rebellion to create "diff" ARB files with missing translations using `--output` option (available values: `console` or `file`).

`diff` uses main app locale to compare ARB files. Default locale is `en` but you can change it using `--main-locale` option

## Sort

Sort ARB files alphabetically, in reverse alphabetical order or follow main ARB file's order:

```sh
rebellion sort ./l10n/
```

Use `--sorting` to change sorting: `alphabetical` (default), `alphabetical-reverse` or `follow-main-file`

## Configuration

You can disable some rules, set `sort` and `diff` settings using a configuration file. Create a file called `rebellion_options.yaml` in the root of your app and enable certain rules and options:

```yaml
# List all rules that rebellion should follow
rules:
    # Enable mandatory @-key description rule (it's off by default)
    - mandatory_at_key_description
    
    # Disable missing translations rule
    # - missing_translations

    # Enable all other rules
    - all_caps
    - string_type
    - at_key_type
    - duplicated_keys
    - empty_at_key
    - locale_definition
    - missing_placeholders
    - missing_plurals
    - naming_convention
    - redundant_at_key
    - redundant_translations
    - unused_at_key

options:
  # Set main locale
  main_locale: en
  
  # Set naming convention that all keys should follow
  # Available options: snake or camel
  naming_convention: snake

  # Set sorting for the `sort` command
  # Available options: alphabetical, alphabetical-reverse, follow-main-file
  sorting: alphabetical
```

If this YAML file could not be found, default set of options is used. Consider committing this file to git so all developers and CI actions use the same config.

## Available rules

* ### `missing_plurals`

  Check that `plural` strings contain all required plural options for current locale and don't contain unused strings for this locale.

  For example:
    - English uses `one` ("1 book") and `other` ("0 books", "20 books"). All other options are never used
    - French uses `one`, `many` and `other`
    - Arabic uses `zero`, `one`, `two`, `few`, `many`, `other`
    - Vietnamese uses `other`

* ### `missing_placeholders` 
  
  Check that @-keys don't contain empty placeholders

* ### `all_caps` 
  
  Check that strings are not written in capital letters

* ### `string_type` 
  
  Check that all strings are of type String

* ### `at_key_type` 
  
  Check that @-key has correct type

* ### `duplicated_keys` 
  
  Check that ARB files don't contain duplicated keys

* ### `empty_at_key` 
  
  Check that ARB files don't contain empty @-keys

  There's no need for ARB files

* ### `locale_definition` 
  
  Check that ARB file has locale definition key (`@@locale`)

* ### `mandatory_at_key_description` 
  
  Check that all @-keys have `description` provided. Disabled by default

* ### `missing_translations` 
  
  Check that translation files have strings for all keys (checked against the main 
  localization file)
* ### `naming_convention` 
  
  Check that key names are following naming conventions (camelCase or snake_case)

* ### `redundant_at_key` 
  
  Check that only main localization file contains @-keys

* ### `redundant_translations` 
  
  Check that translation files don't have keys not present in the main localization file

* ### `unused_at_key` 
  
  Check that all @-keys have corresponding key


## Updating plurals rules

Rebellion uses Unicode's [plural rules](https://www.unicode.org/cldr/charts/45/supplemental/language_plural_rules.html) when checking if certain plural options should be or should be not present in a translation file. To get updated rules in a format that Rebellion understands, run the script:

```sh
dart packages/plural_rules_generator/bin/plural_rules_generator.dart ./lib/src/generated/plural_rules.dart
```

There's a CI action that runs this script periodically so rules are up-to-date.

## Name

* "Rebel" is from [Rebel App Studio](https://rebelappstudio.com)
* "Lion" is `l10n` (localization) that could be misread as `lion`

It's rebel, lion and localization at the same time. Roar!
