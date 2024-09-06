# Rebellion

Rebellion is a linter for Flutter's ARB translation files.

Analyze ARB files and find possible issues. Find missing translations. Sort ARB files. Add Rebellion to your CI job to make sure all strings are translated and have no issues.

* [Github repo](https://github.com/rebelappstudio/rebellion/)
* [pub.dev page](https://pub.dev/packages/rebellion)
* [Rebel App Studio](https://rebelappstudio.com)

## Installation

```sh
TODO
```

## Analyze ARB files

Find problems in ARB files:

```sh
rebellion analyze ./myLocalizationsFolder
```

See Configuration section below to customize set of rules.

## Diff

Find missing translations:

```sh
rebellion diff ./myLocalizationsFolder
```

By default this command prints missing translations to console. If you wish you may instruct Rebellion to create "diff" ARB files with missing translations using `--output` option (available values: `console` or `file`).

## Sort

Sort ARB files alphabetically, in reverse alphabetical order or follow main ARB file's order:

```sh
rebellion sort ./myLocalizationsFolder
```

Use `--sorting` to change sorting: `alphabetical` (default), `alphabetical-reverse` or `follow-main-file`


## Configuration

`analyze` and `diff` use main app locale to compare ARB files. Default locale is `en` but you can change it using `--main-locale` option:

```sh
rebellion diff --main-locale=fi .
```

You can disable some rules or set `sort` or `diff` settings using a configuration file. Create a file called `rebellion_options.yaml` in the root of your app and enable certain rules and options:

```yaml
# List all rules that rebellion should follow
rules:
    # Enable mandatory @-key description rule (it's off by default)
    - mandatory_at_key_description
    
    # Disable missing translations rule
    # - missing_translations

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
  # Set main locale to run some checks against
  main_locale: en
  
  # Set naming convention that all keys should follow
  # Available options: snake or camel
  naming_convention: snake

  # Set sorting for the `sort` command
  # Available options: alphabetical, alphabetical-reverse, follow-main-file
  sorting: alphabetical
```

Consider committing this file to git so all developers and CI actions use the same setup.

## Available rules:

* `missing_plurals` - check that `plural` strings contain all required plural options for current locale and doesn't contain unused strings for this locale
* `missing_placeholders` - check that @-keys don't contain empty placeholders
* `all_caps` - check that strings are not written in capital letters
* `string_type` - check that all strings are of type String
* `at_key_type` - check that @-key has correct type
* `duplicated_keys` - check that ARB files don't contain duplicated keys
* `empty_at_key` - check that ARB files don't contain empty @-keys
* `locale_definition` - check that ARB file has locale definition key (`@@locale`)
* `mandatory_at_key_description` - check that all @-keys have `description` provided. Disabled by default
* `missing_translations` - check that translations have translations for all keys from the main localization file
* `naming_convention` - check that key names are following naming conventions (camelCase or snake_case)
* `redundant_at_key` - check that only main localization file contains @-keys
* `redundant_translations` - check that translation files don't have keys not present in the main localization file
* `unused_at_key` - check that all @-keys have corresponding key

## Updating plurals rules

Rebellion uses plural rules from Unicode when checking is certain plural options should be or should be not present for a given locale. To get updated rules in a format that Rebellion understands, run the script:

```sh
TODO how to run the script
```

In addition, this script is run periodically in CI.

## Name

*Rebellion* comes from [**Rebel** App Studio](https://rebelappstudio.com) and l10n which can be misread as *"lion"*. The name is rebellion, rebel lion and localization at the same time.
