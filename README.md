<div align="center">
  <h1>Portico</h1>
  <img src="https://github.com/paysonwallach/portico/blob/master/media/screencast.gif" />
  <br>
  <br>
  <p>A LightDM Greeter for Pantheon.</p>
  <a href="https://github.com/paysonwallach/portico/releases/latest">
    <img alt="Version 5.0.4" src="https://img.shields.io/badge/version-5.0.4-red.svg?cacheSeconds=2592000&style=flat-square" />
  </a>

  <a href="https://github.com/paysonwallach/portico/blob/master/LICENSE" target="\_blank">
    <img alt="Licensed under the GNU General Public License v3.0" src="https://img.shields.io/github/license/paysonwallach/Portico?style=flat-square" />
  </a>

  <a href="https://buymeacoffee.com/paysonwallach">
    <img src="https://img.shields.io/badge/donate-Buy%20me%20a%20coffe-yellow?style=flat-square">
  </a>
  <br>
  <br>
</div>

[Portico](https://github.com/paysonwallach/portico) is a fork of [Pantheon Greeter](https:///github.com/elementary/greeter).

## Installation

[Portico](https://github.com/paysonwallach/portico) requires the following dependencies:

* gnome-settings-daemon
* libaccountsservice-dev
* libgdk-pixbuf2.0-dev
* libgranite-dev
* libgtk-3-dev
* liblightdm-gobject-1-dev
* libmutter
* libwingpanel-2.0-dev
* libx11-dev
* meson
* valac

Clone this repository or download the [latest release](https://github.com/paysonwallach/portico/releases/latest).

```sh
git clone https://github.com/paysonwallach/portico
```

Configure the build directory at the root of the project.

```sh
meson --prefix=/usr build
```

Install with `ninja`.

```sh
ninja -C build install
```

Set the `greeter-session` in `/etc/lightdm/lightdm.conf` to `com.paysonwallach.portico`:

```
[Seat:*]
...
greeter-session=com.paysonwallach.portico
```

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[Portico](https://github.com/paysonwallach/portico) is licensed under the [GNU General Public License v3.0](https://github.com/paysonwallach/portico/blob/master/LICENSE).
