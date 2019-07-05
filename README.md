# Bootstrap & Dotfiles

This repo borrows heavily from [`MikeMcQuaid/strap`](https://github.com/MikeMcQuaid/strap) (and associated [Heroku app](https://macos-strap.herokuapp.com/)) along with [`mathiasbynens/dottfiles`](https://github.com/mathiasbynens/dotfiles).
In addition, it relies on [`deadc0de6/dotdrop`](https://github.com/deadc0de6/dotdrop/) to manage the dotfiles.

## Setup

This repo follows the [scripts to rule them all](https://github.com/github/scripts-to-rule-them-all) schema.
After cloning the repo, run the `setup` script:

```bash
$ script/setup
```

which will bootstrap the installation (& machine setup) and install the dotfiles.

If your working repo has not been updated in quite a while, after pulling the latest from upstream, you should run the `update` script:

```bash
$ script/update
```

## Operations performed

### [`script/setup`](https://github.com/acourtneybrown/dotfiles/blob/master/scripts/setup)

1. install OS updates
1. run `macos` script?
1. install xcode tools (need for git?)
1. install homebrew (& casks)
1. install brew bundle (Brewfile)
1. login to dropbox & sync 1password directories
1. pull ssh private key from 1password
1. pull gpg key from 1password
1. populate .env with GitHub octofactory vars from 1password
1. run `dotdrop install --profile=default`
1. *TODO: check if the current hostname/profile exists in `config.yaml` & add if not*
1. create sockets directory
1. setup go
1. setup ruby

### [`script/update`](https://github.com/acourtneybrown/dotfiles/blob/master/scripts/update)

1. install OS updates
1. install brew bundle (Brewfile)
1. populate .env with GitHub octofactory vars from 1password
1. *TODO: "update dotdrop"??*
1. setup go
1. setup ruby