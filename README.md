# POSIX clock and time for OCaml

The ocaml-time library provides [POSIX clock and time](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/time.h.html) bindings for OCaml.

This library has been tested on Linux, but QNX, Solaris etc. should work, too.
Mac OS X currently does not support many POSIX time functions like ```clock_gettime``` (as of OS X 10.10).

The [API of ocaml-time](http://time.forge.ocamlcore.org/doc/) is online at the [OCaml Forge](https://forge.ocamlcore.org/).

The source code of time is available under the MIT license.

This library is originally written by [Markus Weissmann](http://www.mweissmann.de/)
