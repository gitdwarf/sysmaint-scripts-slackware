# sysmaint-scripts-slackware

Automated Slackware system maintenance scripts for updating packages, managing dependencies, and assisting with window management during updates.

These scripts are designed to run regularly (e.g., via cron) or manually, and are tailored for Slackware systems using **slapt-get** as the package manager.

---

## Features

* Automatically update Slackware packages using `slapt-get`.
* Handle HTTP download errors, MD5 mismatches, and problematic sources automatically.
* Optional integration with `needrestart` for restarting services after updates.
* Moves file manager windows to a specific workspace after updates (via `wmctrl` or `xdotool`).
* Designed to run safely unattended, with careful handling of exclusions, backups, and retries.

---

## Prerequisites

### Required

* **slapt-get**
  Dependency for all scripts; used for updating and managing packages on Slackware.
  **Slackpkg or other update tools are not compatible.**
  Installation & info: [https://github.com/jaos/slapt-get](https://github.com/jaos/slapt-get)

### Optional

* **needrestart**
  Detects services that require a restart after updates. Useful for fully automated maintenance.
  Installation & info: [https://github.com/liske/needrestart](https://github.com/liske/needrestart)

* **wmctrl** (X11 window management)
  Used by `windowlabelandmove.sh` to move file manager windows to a specific workspace.
  SlackBuild: [https://slackbuilds.org/result/?search=+wmctrl&sv=](https://slackbuilds.org/result/?search=+wmctrl&sv=)
  Alternative / upstream source: [https://github.com/dancor/wmctrl](https://github.com/dancor/wmctrl)

* **xdotool** (XWayland / Wayland fallback)
  Optional fallback for moving windows when `wmctrl` is unavailable or in mixed XWayland setups.

---

## Installation

1. Clone or download the repository:

```bash
git clone https://github.com/yourusername/sysmaint-scripts-slackware.git
cd sysmaint-scripts-slackware
```

2. Ensure `slapt-get` is installed and configured with your Slackware sources.

3. Make scripts executable:

```bash
chmod +x *.sh
```

4. Configure `windowlabelandmove.sh` if you wish to use the workspace automation feature.

---

## Usage

Run scripts manually or schedule via cron. Example:

```bash
/path/to/sysmaint-scripts-slackware/update-system.sh
```

* `update-system.sh` handles downloading, upgrading, and resolving errors.
* `windowlabelandmove.sh` is a helper script for window management, called internally as needed.

---

## Notes

* Scripts are designed for **Slackware** only.
* Workspace management with `wmctrl` / `xdotool` is **best-effort**; failures are silently ignored.
* All updates are performed **safely**, with backups and exclusion handling for problematic packages.
* Designed for unattended operation, e.g., scheduled overnight.

---

## License

MIT License. See LICENSE file for details.

---
