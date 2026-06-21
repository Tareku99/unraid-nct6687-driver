# Unraid NCT6687d Driver Plugin

NCT6687D kernel module for Unraid, enabling hardware monitoring and fan control on motherboards with the Nuvoton NCT6687-R chipset (common on MSI B550/B650/X670/Z690/Z790 and similar boards).

Based on: https://github.com/Fred78290/nct6687d

---

## Installation

### Via Unraid Web UI (recommended)
1. Open **Apps** tab
2. Click **Install Plugin** (top-right)
3. Paste this URL:
   ```
   https://raw.githubusercontent.com/ich777/unraid-nct6687-driver/master/nct6687-driver.plg
   ```
4. Click **Install**

### Via command line
```sh
wget -O /boot/config/plugins/nct6687-driver.plg \
  https://raw.githubusercontent.com/ich777/unraid-nct6687-driver/master/nct6687-driver.plg
/usr/local/emhttp/plugins/plugin/install.plg /boot/config/plugins/nct6687-driver.plg
```

## What it does

On every boot, the plugin:
1. **Blacklists** the stock `nct6683` kernel module (which conflicts with `nct6687`)
2. **Checks** the running kernel version (`uname -r`)
3. **Downloads** the matching `.txz` driver package from the GitHub releases
4. **Installs** the package with `installpkg` + `depmod -a`
5. **Loads** the `nct6687` module
6. Pre-downloads the driver ahead of Unraid OS updates via the **Plugin Update Helper**

## Fan Control

After install, writable PWM controls are available:

```sh
# List NCT6687 sysfs path
for d in /sys/class/hwmon/*; do echo "$d: $(cat $d/name 2>/dev/null)"; done | grep nct6687
```

### Manual fan control
```sh
# Set fan to manual mode
echo 1 > /sys/class/hwmon/hwmon*/pwm1_enable
# Set fan to 50% speed
echo 128 > /sys/class/hwmon/hwmon*/pwm1
# Return to auto
echo 99 > /sys/class/hwmon/hwmon*/pwm1_enable
```

### Automatic fan control
Install **Dynamix System Autofan** from the Apps tab to configure temperature-based fan curves.

## Module Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| force | bool | false | Enable support for unknown vendors |
| manual | bool | false | Manual voltage input/label configuration |
| msi_fan_brute_force | bool | false | [BETA] Write PWM to all 7 curve points for MSI boards |

See upstream docs: https://github.com/Fred78290/nct6687d

## Troubleshooting

**No PWM controls visible?**
The `nct6683` module may have loaded instead. The plugin auto-blacklists it, but if you see read-only `pwm` files, verify the active module:
```sh
cat /sys/class/hwmon/hwmon*/name
```
If it says `nct6683`, run:
```sh
rmmod nct6683
modprobe nct6687
```

**After Unraid OS update:**
The Plugin Update Helper pre-downloads the matching driver before the update. If it doesn't load after reboot, reinstall or manually download the matching release from GitHub.

## Support

Support Thread: https://forums.unraid.net/topic/92865-support-ich777-nvidiadvbzfsiscsimft-kernel-helperbuilder-docker/
