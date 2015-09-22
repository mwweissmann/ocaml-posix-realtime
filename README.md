# POSIX realtime

This library provides access to the set of operating system services standardized by [IEEE Std 1003.1b-1993 Realtime Extension](http://pubs.opengroup.org/onlinepubs/9699919799/functions/V2_chap02.html#tag_15_08) or short *POSIX realtime*.

It currently implements clocks, timers and message passing.

The POSIX realtime extension must be available on your operating system and likely is on current versions of Linux, BSD, Solaris, QNX, etc.
Mac OS X currently does not support many POSIX realtime functions and therefore will not work (as of OS X 10.10).

The [API of ocaml-posix-realtime](http://time.forge.ocamlcore.org/doc/) is online at the [OCaml Forge](https://forge.ocamlcore.org/).

## Examples

### POSIX message queue
Here is an example program that opens a queue, sends a message and then receives it's own message again:
```ocaml
open Rresult
open Posix_realtime

let name = "/myqueue"

let _ =
  let rc =
    (* open the queue, creating it if it does not exist *)
    (mq_open name [O_RDWR; O_CREAT] 0o644 {mq_flags=0; mq_maxmsg=5; mq_msgsize=32; mq_curmsgs=0}) >>=

    (* if the queue is opened successfully... *)
    (fun mq ->
      (* .. send a message .. *)
      (mq_send mq {payload="hello ocaml-mqueue!"; priority=23}) >>=

      (* .. and receive a message .. *)
      (fun () -> mq_receive mq 32) >>|
      
      (* .. and print the message *)
      (fun msg -> print_endline msg.payload)
    )
  in

  (* remove the queue from the system  *)
  let _ = mq_unlink name in

  (* handle the result *)
  match rc with
  | Rresult.Ok () -> print_endline "done"
  | Rresult.Error (`EUnix errno) -> print_endline (Unix.error_message errno)
```

### POSIX clocks and timers
```ocaml
open Posix_realtime

let print_timespec time =
  Printf.printf "s = %s, ns = %s"
    (Int64.to_string Posix_realtime.Timespec.(time.tv_sec))
    (Int64.to_string Posix_realtime.Timespec.(time.tv_nsec))

let _ =
  let sec1 = Timespec.create Int64.one Int64.zero in (* 1 second, 0 nanoseconds *)

  nanosleep sec1; (* sleep for sec1 *)

  clock_nanosleep Clock.realtime sec1; (* sleep for sec1 on the realtime clock *)

  match Clock.monotonic with
  | Some monotonic_clock -> clock_nanosleep monotonic_clock sec1 (* sleep for sec1 on the monotonic clock *)
  | None -> print_endline "no monotonic clock available";

  let now = clock_gettime Clock.realtime in (* get the current time on the realtime clock *)
  match now with
  | Result.Ok time -> print_timespec time
  | Result.Error (`EUnix err) -> print_endline (Unix.error_message err)
```

The source code of time is available under the MIT license.

This library is originally written by [Markus Weissmann](http://www.mweissmann.de/)
