# Rebellion

Analyze ARB files for possible issues. Find missing translations. Translate missing items using ChatGPT. Add it to your CI job to make sure all strings are translated and have no problems.

# Installation

```sh
todo
```

# Usage

### Analyze

Find problems in ARB file(s):

```sh
rebellion analyze ./l10n/
```

You can turn off certain options. See `rebellion analyze --help` for all options:

```sh
Usage: rebellion analyze [arguments]
-h, --help                                 Print this usage information.
    --[no-]missing-translations            (defaults to on)
    --[no-]redundant-translations          (defaults to on)
    --[no-]redundant-at-key                (defaults to on)
    --[no-]duplicated-keys                 (defaults to on)
    --[no-]all-caps                        (defaults to on)
    --[no-]missing-plurals                 (defaults to on)
    --[no-]locale-definition               (defaults to on)
    --[no-]empty-at-key                    (defaults to on)
    --[no-]at-key-without-key              (defaults to on)
    --[no-]at-key-type                     (defaults to on)
    --[no-]missing-placeholders            (defaults to on)
    --[no-]mandatory-at-key-description
    --main-locale                          (defaults to "en")
    --naming-convention                    [camel (default), snake]
```

### Diff

Find missing translations for each translation file.

### Translate

Translate missing items using ChatGPT:

```sh
rebellion translate ./l10n/
```

Providing a description for keys in the main file could make translations better.

### Sort

```sh
rebellion sort ./l10n/
```

# Configuration

# Name

Rebellion comes from [**Rebel** App Studio](https://rebelappstudio.com) and l10n which can be misread as "**lion**".
