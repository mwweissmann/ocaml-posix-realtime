# POSIX realtime

This library provides access to the set of operating system services standardized by [IEEE Std 1003.1b-1993 Realtime Extension](http://pubs.opengroup.org/onlinepubs/9699919799/functions/V2_chap02.html#tag_15_08) or short *POSIX realtime*.

It currently implements clocks, timers and message passing.

The POSIX realtime extension must be available on your operating system and likely is on current versions of Linux, BSD, Solaris, QNX, etc.
Mac OS X currently does not support many POSIX realtime functions and therefore will not work (as of OS X 10.10).

The [API of ocaml-posix-realtime](http://time.forge.ocamlcore.org/doc/) is online at the [OCaml Forge](https://forge.ocamlcore.org/).

The source code of time is available under the MIT license.

This library is originally written by [Markus Weissmann](http://www.mweissmann.de/)
