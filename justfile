firmware := "A-LAS-CL-LTS-LONGER-V2.2.8.bin"
port := env("PORT", `env -u CLICOLOR_FORCE -u CLICOLOR ls /dev/cu.usbserial* 2>/dev/null | head -n1`)
baud := env("BAUD", "460800")

# List available recipes
default:
    @just --list

# Show chip and flash info from the connected device
info:
    @test -n "{{port}}" || { echo "No /dev/cu.usbserial* device found; set PORT=/dev/cu.xxx"; exit 1; }
    uv run --no-sync esptool --port {{port}} flash-id

# Flash the full firmware image (bootloader, partitions, app) at 0x0
flash:
    @test -n "{{port}}" || { echo "No /dev/cu.usbserial* device found; set PORT=/dev/cu.xxx"; exit 1; }
    uv run --no-sync esptool --port {{port}} --baud {{baud}} write-flash 0x0 {{firmware}}