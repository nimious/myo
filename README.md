# io-myo

Nim bindings for the Thalmic Labs Myo gesture control armband SDK.

![io-usb Logo](logo.png)


## About

io-myo contains bindings to the *Myo SDK* for the [Nim](http://nim-lang.org)
programming language. The Myo is a gesture control armband that lets users
wirelessly control a computer by detecting electrical activity in arm muscles.

## Supported Platforms

io-myo was last built and tested with **Myo SDK 0.8.1** and
**MyoConnect 0.9.1**. The bindings currently support the following platforms:

- ~~Android~~
- ~~iOS~~
- MacOS X
- Windows


## Prerequisites

### MacOS X

Download and install the latest *MyoConnect* software from the Thalmic Labs
download page, as well as the *Myo SDK for Mac* from the Thalmic Labs developer
portal. Copy the `myo32.dll` and/or `myo64.dll` files from the SDK into your
program's directory.

### Windows

Download and install the latest *MyoConnect* software from the Thalmic Labs
download page, as well as the *Myo SDK for Windows* from the Thalmic Labs
developer portal. Copy the `myo32.dll` and/or `myo64.dll` files from the SDK
into your program's directory.


## Dependencies

io-myo does not have any dependencies to other Nim packages at this time.


## Usage

Import the *libmyo* module from this package to make the bindings available
in your project:

```nimrod
import libmyo
```


## Support

Please [file an issue](https://github.com/nimious/io-myo/issues), submit a
[pull request](https://github.com/nimious/io-myo/pulls?q=is%3Aopen+is%3Apr)
or email us at info@nimio.us if this package is out of date or contains bugs.
For all other issues related to USB devices visit the libusb web site below.


## References

* [Thalmic Labs Download Page](https://www.thalmic.com/start/)
* [Thalmic Labs Developer Portal](https://developer.thalmic.com/)
* [Nim Programming Language](http://nim-lang.org/)
