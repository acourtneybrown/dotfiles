# Bootstrap & Dotfiles

This repo borrows heavily from [`MikeMcQuaid/strap`](https://github.com/MikeMcQuaid/strap) (and associated [Heroku app](https://macos-strap.herokuapp.com/)) along with [`mathiasbynens/dottfiles`](https://github.com/mathiasbynens/dotfiles).
In addition, it relies on [`deadc0de6/dotdrop`](https://github.com/deadc0de6/dotdrop/) to manage the dotfiles.

## Setup

It may be necessary to run `xcode-select --install` if the `git` command is not initially available on the Mac.

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

### [`script/os_setup`]()

1. install OS updates
1. run `macos` script
1. install xcode tools
1. install homebrew/linuxbrew (& casks)
1. install brew bundle (Brewfile)
1. *login to dropbox & sync 1password directories*
1. *pull ssh private key from 1password*
1. *pull gpg key from 1password*
1. *pull `.env` from 1password*
1. setup go
1. setup ruby

Items in *italics* require manual intervention currently.

### [`script/bootstrap`]()

1. setup `dotdrop` environment & dependencies
1. setup `.ssh` directory
1. create `dotdrop` profile if necessary & install
1. install `oh-my-zsh`

### [`script/update`]()

1. install OS updates
1. install brew bundle (Brewfile)
1. install `dotdrop` profile
1. setup go
1. setup ruby
