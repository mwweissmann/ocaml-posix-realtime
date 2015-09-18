(*_ $Id: $
Copyright (c) 2015 Markus W. Weissmann <markus.weissmann@in.tum.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)

(** POSIX clock and time

  @author Markus W. Weissmann
*)

(** The list of known clocks. Only some of these are supported by operating
    systems: If a particular clock is found, it's value is set to [Some clock]
    else to [None]. *)
module Clock : sig

  (** clock identifier type *)
  type t

  (** This clock represents the clock measuring real time for the system.
      The value returned representes the amount of time since the Epoch. *)
  val realtime : t

  (** This clock represents a monotonic time with an unspecified point in the
      past. *)
  val monotonic : t option

  (** This clock represents the amount of execution time of the process
      associated with the clock *)
  val process_cputime_id : t option

  (** This clock represents the amount of exection time of the thread
      associated with the clock *)
  val thread_cputime_id : t option

  val boottime : t option
  val monotonic_coarse : t option
  val monotonic_fast : t option
  val monotonic_precise : t option
  val monotonic_raw : t option
  val prof : t option
  val realtime_coarse : t option
  val realtime_fast : t option
  val realtime_precise : t option
  val second : t option
  val uptime : t option
  val uptime_fast : t option
  val uptime_precise : t option
  val virtual_ : t option
end

(** Time specifier including seconds [tv_sec] and nanoseconds [tv_nsec]. *)
module Timespec : sig

  (** POSIX timespec time specifier with seconds and nanoseconds. A normalized
      value of type [t] must have a value of [tv_nsec] between [0] and
      [1000000000] (inclusive). *)
  type t = private {
    tv_sec : int64;
    tv_nsec : int64;
  }

  (** [create sec nsec] creates a new normalized timespec with [sec] seconds
      and [nsec] nanoseconds. *)
  val create : int64 -> int64 -> t

  (** [add t1 t2] adds the two timespec values, returning a normalized value *)
  val add : t -> t -> t

  (** [sub t1 t2] subtracts [t2] from [t1], creating a new normalized time
      value. *)
  val sub : t -> t -> t

  val add_sec : int64 -> t -> t
  val add_nsec : int64 -> t -> t
  val sub_sec : int64 -> t -> t
  val sub_nsec : int64 -> t -> t

  (** [compare t1 t2] compares the two time values [t1] and [t2]. It returns
      [0] if [t1] is equal to [2], a negative integer if [t1] is less than [t2],
      and a positive integer if [t1] is greater than [t2]. *)
  val compare : t -> t -> int
end

(** [clock_getres clock] returns the resolution (precision) of the specified
    clock.
    If the clock [clock] is not supported by the operating system, [Error]
    is returned.  *)
val clock_getres : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result

(** [clock_gettime clock] retrieves the time of the clock [clock].
    If the clock [clock] is not supported by the operating system, [Error]
    is returned.  *)
val clock_gettime : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result

(** [clock_settime clock time] sets the time of the clock [clock] to [time].
    If the clock [clock] is not supported by the operating system, [Error]
    is returned.  *)
val clock_settime : Clock.t -> Timespec.t -> (unit, [>`EUnix of Unix.error]) Result.result

(** [nanosleep time] lets the system sleep for [time]. If the call was
    interrupted by a signal, the [Ok] return value will bring [Some time] value
    carrying the remaining time -- otherwise [None]. *)
val nanosleep : Timespec.t -> ((Timespec.t option), [> `EUnix of Unix.error]) Result.result

(** [clock_nanosleep clock time ~abs:a] lets the system sleep for [time]. The
    duration is based on the clock [clock]. [time] either gives a relative time
    when [~abs] is false or an absolute time when [~abs] is true. The default
    case is relative time.
    The return value is analog to [nanosleep]. *)
val clock_nanosleep : Clock.t -> ?abs:bool -> Timespec.t -> ((Timespec.t option), [> `EUnix of Unix.error]) Result.result

