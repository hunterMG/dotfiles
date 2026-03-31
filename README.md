# dotfiles

Dotfiles and setup scripts for a fresh Debian (>=12) installation.

## ‼️ Disclaimer

Use it at your own risk. Review before running.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/hunterMG/dotfiles/main/debian-setup.sh -o debian-setup.sh | bash debian-setup.sh
```

or  

```bash
curl -fsSL https://gitee.com/huntermg/dotfiles/raw/main/debian-setup.sh -o debian-setup.sh && bash debian-setup.sh
```

## ⚠️ Warning about `stable` in [apt](./apt/)

Debian's `stable` is a moving alias:

- Debian 12 → `stable = bookworm`
- Debian 13 → `stable = trixie`

After a new Debian release, running:

```bash
sudo apt update && sudo apt upgrade
```

may upgrade your system to the next major Debian version automatically.

If you want to stay on a specific release, replace `stable` with a codename (e.g. `bookworm`).

## Credits

This project includes configurations adapted from third-party sources.

See [third_party/README.md](third_party/README.md) for details.
