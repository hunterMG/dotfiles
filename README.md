# dotfiles

## ⚠️ Warning about `stable` in [apt](./apt/)

Debian's `stable` is a moving alias:

- Debian 12 → `stable = bookworm`
- Debian 13 → `stable = trixie`

After a new Debian release, running:

    sudo apt update && sudo apt upgrade

may upgrade your system to the next major Debian version automatically.

If you want to stay on a specific release, replace `stable` with a codename (e.g. `bookworm`).

## Credits

This project includes configurations adapted from third-party sources.

See [third_party/README.md](third_party/README.md) for details.
