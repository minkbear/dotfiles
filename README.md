# My personal dotfiles

My personal dotfiles for an Mac with M4 Chip.

It contains the installation of some basic tools, some handy aliases and functions. Backups of settings are done via [Mackup](https://github.com/lra/mackup).

You can install them by cloning the repository as `.dotfiles` in your home directory and running the bootstrap script.

```
git clone git@github.com:jimping/dotfiles.git .dotfiles
cd .dotfiles
./bootstrap
```

The bootstrap script can be run by cd-ing into the `.dotfiles` directory and performing this command:

```bash
./bootstrap
```

# New Macbook

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-keygen -t rsa -b 2048 -C "your_email@example.com"

ssh-add --apple-use-keychain ~/.ssh/id_rsa
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Feel free to create an issue on this repo if you have any questions about them.

![screenshot](https://jimping.github.io/dotfiles/screenshot.png)
