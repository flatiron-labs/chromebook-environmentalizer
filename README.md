# Chromebook Environmentalizer

A bash script to finish bootstraping an Acer c720 Chromebook that was set up using the [Flatiron School's Chrubuntu Installer](https://github.com/flatiron-labs/ubuntu-chromebook-installer). However, if you're using Ubuntu you can still use this script. Just follow the directions below.

## What It Sets Up

1. Flatiron School's standard `.bashrc`, which includes case-insensitive auto completion, a nice prompt with git branch awareness, and many useful shortcuts.
2. RVM and Ruby 2.1.2
3. A Postgres User
4. Sensible `.gitconfig`, `.gitignore`, `.gemrc`, and `.irbrc` files
5. SSH Key for GitHub 
6. A simple directory structure for well-organized code

## What You Need Before You Begin

1. Know your admin password (you'll need to enter it once when the script first runs)
2. Know your GitHub username
3. Know the email address associated with your GitHub account
4. A personal access api token for GitHub. You can create one here: [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new). The name doesn't matter. You *must* select the following scopes (at least):
  * repo
  * public_repo
  * write:public_key
  * user
  * admin:public_key
  * gist

## Notes

1. You'll need to run this script from an account with admin status. (DO NOT prepend `sudo` to the command below.)
2. When the script first runs, you'll need to enter your admin password once.
3. During installation, Sublime Text will open for a few seconds and then close automatically. Do not close it yourself. This step is required for some important directories to be created.

## Usage

`curl -Lo- "https://raw.githubusercontent.com/flatiron-labs/chromebook-environmentalizer/master/bootstrap.sh" | bash`
