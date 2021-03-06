sparkle_appcast
===============


NAME
----

`sparkle_appcast` -- A simple Sparkle `appcast.xml` tool


SYNOPSIS
--------

    sparkle_appcast COMMAND [OPTIONS...] [ARGS...]


DESCRIPTION
-----------

`sparkle_appcast` is a Ruby gem that provides a command line interface and a Ruby library
to create and update `appcast.xml` for [Sparkle](https://sparkle-project.org).

`sparkle_appcast` command line interface takes next commands.

### `appcast [OPTIONS...] FILE_PATH`

Create `appcast.xml` with an application archive at `FILE_PATH`.
The application archive file must contain exact one application bundle.

The value or content of each template-enabled key can include [Mustache](https://mustache.github.io/) style (``{{key}}``) template.
Each template is replaced with the value with the information of application bundle.
Use `info` command to list all possible template keys.

* `--key=KEY`

    Path to DSA private key file. Required.

* `--url=URL`

    URL to the application archive file published. Required.
    Template is enabled.

* `--release-note=RELEASE_NOTE`

    Path to a release note text file in [Markdown](https://daringfireball.net/projects/markdown/syntax) format. Required.
    Template is enabled on the content of text file.

* `--output=OUTPUT`

    Path to an output `appcast.xml`. Optional.
    Default to puts in the standard output.

* `--title=TITLE`

    Title for the release note. Optional.
    Default to `{{bundle_name}} {{bundle_short_version_string}} ({{bundle_version}})`
    Template is enabled.

* `--publish-date=PUBLISH_DATE`

    Publish date time in local timezone. Optional.
    Default to the creation time of the application archive file.

* `--channel-title=CHANNEL_TITLE`

    Title of the channel. Optional.
    Default to `{{bundle_name}} Changelog`.
    Template is enabled.

* `--channel-description=CHANNEL_DESCRIPTION`

    Description of the channel. Optional.
    Default to `Most recent changes with links to updates.`.
    Template is enabled.

* `--channel-language=CHANNEL_LANGUAGE`

    Language of the channel. Optional.
    Default to `en`.
    Template is enabled.

### `info [OPTIONS...] [FILE_PATH]`

Print information about the application bundle at `FILE_PATH`.
`FILE_PATH` can be either an application archive or application bundle.

Use `help info` for all possible options.

### `sign [OPTIONS...] [FILE_PATH]`

Sign data at `FILE_PATH` or reading from the standard input with `DSA_PRIVATE_KEY_PATH`
and print signature that can be used in `appcast.xml`.
Use this for testing private key.

* `--key=KEY`

    Path to DSA private key file. Required.

### `markdown [FILE_PATH]`

Format Markdown text file at `FILE_PATH` or reading from the standard input in HTML.
Use this for writing the release note.


USAGE
-----

Use Ruby Gems to install `sparkle_appcast`.

    gem install sparkle_appcast

Or use [bundler](http://bundler.io/), add next line to `Gemfile` in your project.

    gem "sparkle_appcast"


SEE ALSO
--------

 * [generate-key](https://github.com/sparkle-project/Sparkle/blob/master/bin/generate_keys)
 * [sign-update](https://github.com/sparkle-project/Sparkle/blob/master/bin/sign_update)
 * [generate-appcast](https://github.com/sparkle-project/Sparkle/tree/master/generate_appcast)
