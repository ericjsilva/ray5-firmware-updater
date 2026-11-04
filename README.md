# Lonoger Ray5 Firmware Updater

Tooling to flash the latest Longer Ray5 firmware image from the Longer website onto the board over USB serial, using [esptool](https://github.com/espressif/esptool). The `justfile` sets the image filename in its `firmware` variable (currently `A-LAS-CL-LTS-LONGER-V2.2.8.bin`).

## Requirements

- macOS
- [uv](https://docs.astral.sh/uv/)
- [just](https://github.com/casey/just)
- The board connected over USB

Install the Python environment (Python 3.14 and esptool):

```bash
uv sync
```

## Get the firmware

The `.bin` file is not stored in git. Download the latest firmware from the Longer website:

https://www.longer.net/pages/download-software

Put the file in the project root. If the version differs from `A-LAS-CL-LTS-LONGER-V2.2.8.bin`, update the `firmware` variable at the top of the `justfile`.

## Get device info

```bash
just info
```

This reads the chip and flash details from the board. If it prints them, the connection works and you can flash.

## Flash the firmware

```bash
just flash
```

This writes the whole image (bootloader, partitions and app) at address 0x0. It replaces everything on the flash, so run `just info` first to confirm the board responds.

The recipes use the first `/dev/cu.usbserial*` device they find, at 460800 baud. Override either one with environment variables:

```bash
PORT=/dev/cu.wchusbserial1234 just flash
BAUD=115200 just flash
```

Use a lower baud rate such as 115200 if transfers fail partway through.

## Troubleshooting

### No device found

`No /dev/cu.usbserial* device found` means macOS does not see a serial port. Try a different cable (some are charge-only) and a different USB port, then list ports with:

```bash
ls /dev/cu.*
```

If the port has a different name, pass it with `PORT=`.

### `termios.error: (22, 'Invalid argument')`

This error means macOS's built-in CH340 driver refuses to configure the port. It happens with boards that use a WCH CH340 USB-serial chip (USB ID 1a86:7523, shown as "USB Serial"). Installing WCH's driver fixes it.

1. Check the chip:

   ```bash
   system_profiler SPUSBDataType | grep -B3 -A8 "USB Serial"
   ```

   A vendor ID of 0x1a86 (6790) confirms a WCH chip.
2. Install the driver with Homebrew:

   ```bash
   brew install --cask wch-ch34x-usb-serial-driver
   ```

3. Approve the system extension in System Settings > Privacy & Security if macOS asks.
4. Reboot.
5. Unplug and replug the board, then check the port name with `ls /dev/cu.*`. It may now appear as `/dev/cu.wchusbserial*`.
6. Confirm the port accepts settings:

   ```bash
   stty -f /dev/cu.usbserial-110 115200
   ```

   Use your port name. No output means it works. Then run `just info` again.

### `Missing command` from esptool

Color codes in the `ls` output (for example with `CLICOLOR_FORCE=1`) corrupt the port name. The justfile disables color for the port lookup. If the error appears anyway, set `PORT=` explicitly.

## License

[MIT](LICENSE). This covers the tooling in this repository only. The Longer firmware image is not included and is subject to Longer's own terms.
