# sysmaint-scripts-slackware

Automated system maintenance scripts for Slackware, including package updates, Perl module updates, and Python PIP module updates.

---

## Prerequisites

### Required

* **slapt-get** – Slackware package manager extension for dependency handling and updates.
  Installation & info: [https://github.com/jaos/slapt-get](https://github.com/jaos/slapt-get)

* **Perl** – Base Perl interpreter. The `perthings` script updates Perl modules via CPAN.
  Optional CPAN utilities may include `cpan-outdated`.

* **Python & pip** – Base Python interpreter. The `pipthings` script updates Python packages via `pip-review`.

### Optional / Recommended

* **needrestart** – Detects services that need restarting after package updates.
  Installation & info: [https://github.com/liske/needrestart](https://github.com/liske/needrestart)

* **wmctrl** – Moves open file manager windows to specific workspaces.
  SlackBuild: [https://slackbuilds.org/result/?search=wmctrl&sv=](https://slackbuilds.org/result/?search=wmctrl&sv=)
  Alternative / upstream: [https://github.com/dancor/wmctrl](https://github.com/dancor/wmctrl)

* **xdotool** – Alternative for moving windows in XWayland or Wayland via XWayland.

---

## Included Scripts

### 1. System Updates (`sysmaint-scripts-slackware`)

* Uses `slapt-get` to update system packages.
* Handles:

  * MD5 mismatches
  * HTTP errors
  * Excluded packages and sources
* Supports moving the file manager window to a specific workspace for visibility.

Example usage:

```bash
windowtomoveto="4"
wintomv="/path/to/package/dir"
. /etc/windowlabelandmove.sh
wlm-fn_windowlabelandmove
```

### 2. Perl Module Updates (`perthings`)

* Updates Perl modules via `cpan`.
* Excludes modules listed in `ExcludedModules`.
* Attempts updates up to 5 times to handle dependency chains.
* Tracks:

  * Modules successfully updated
  * Excluded modules installed
  * Excluded modules not installed
  * Failed updates

Configure excluded modules:

```bash
ExcludedModules="Image::Magick,ExtUtils::Command,ExtUtils::Install,File::Temp,DBD::mysql,Time::Piece"
```

Run script:

```bash
./perthings.sh
```

### 3. Python PIP Updates (`pipthings`)

* Updates Python packages via `pip-review`.
* Clears pip cache on each attempt.
* Loops up to 5 times to handle recursive dependency installations.
* Skips if everything is already up-to-date.

Run script:

```bash
./pipthings.sh
```

---

## Notes

* The scripts are designed for unattended execution (e.g., cron jobs), but some display behavior (workspace/window moves) may require a running X server.
* Excluded modules/packages allow safe skipping of critical or problematic items.
* The scripts use `set -euo pipefail` for strict error handling wherever appropriate.
* To remove a Perl module manually:

```bash
perldoc -l Module::Name
rm -rf /path/to/module.pm
```

---

## License

MIT License – see the `LICENSE` file for details.

---
