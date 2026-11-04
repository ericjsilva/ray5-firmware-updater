# CLAUDE.md

## Project

Flashing tooling for the latest Longer Ray5 firmware image from the Longer website. The image filename is the `firmware` variable in the `justfile` (currently `A-LAS-CL-LTS-LONGER-V2.2.8.bin`). There is no application code. The work is in the `justfile`, which wraps esptool.

## Commands

- `uv sync` - create the venv (Python 3.14, esptool)
- `just info` - read chip and flash info (`esptool flash-id`)
- `just flash` - write the full image at 0x0 (`esptool write-flash`)

Env overrides: `PORT` (default: first `/dev/cu.usbserial*`), `BAUD` (default 460800).

## Rules

- Never run `just flash` or any `esptool write-flash`, `erase-flash` or similar without the user asking. It overwrites the bootloader and partitions on real hardware. `just info` is safe.
- Run esptool through `uv run --no-sync esptool`, as the justfile does. esptool is a project dependency in `pyproject.toml`.
- esptool is v5.x: commands are hyphenated (`write-flash`, `flash-id`), not the old underscore form.
- Keep the port lookup in the justfile free of `ls` color codes (`env -u CLICOLOR_FORCE -u CLICOLOR ls`). Colored output corrupts `--port` and causes esptool's "Missing command" error.

## Known hardware issue

The board uses a WCH CH340 USB-serial chip (1a86:7523). On macOS the built-in driver can fail with `termios.error: (22, 'Invalid argument')`, and `stty -f <port> 115200` fails the same way. The fix is WCH's driver (`brew install --cask wch-ch34x-usb-serial-driver`, approve the extension, reboot). The port may then be named `/dev/cu.wchusbserial*`, which the default `usbserial*` glob would not match. See the README troubleshooting section.

## Environment

- macOS, zsh. The user's shell sets `CLICOLOR_FORCE=1`.
- `.python-version` is 3.14.
