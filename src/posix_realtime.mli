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

(** {2 POSIX time specifier} *)

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

(** {2 POSIX clocks } *)

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

(** {2 POSIX message queue} *)

(** type of a message queue *)
type mqd

(** Attributes of a queue *)
type mq_attr = {
  mq_flags : int;
  mq_maxmsg : int;
  mq_msgsize : int;
  mq_curmsgs : int
}

(** Type of a message with payload and priority; priority is a non-negative
  integer with system-specific upper bound of [mq_prio_max]. *)
type message = {
  payload : Bytes.t;
  priority : int;
}

(** Open a POSIX message queue; [mq_open p fs perm attr] opens the message queue
  of name [p] with the given flags [fs], permissions [perm] (if created) and
  queue attributes [attr].
  [mq_open "/myqueue" [O_RDWR; O_CREAT] 0o644 {mq_flags=0; mq_maxmsg=10; mq_msgsize=512; mq_curmsgs=0}]
  opens the message queue "/myqueue" for reading and writing; if the queue does
  not yet exist, it is created with the Unix permissions set to [0o644]; it can
  hold as most 10 messages of size 512 bytes each. The number of current
  messages in the queue [mq_curmsgs] is ignored by the system call.
  Queue names follow the form of "/somename", with a leading slash and at least
  one following character (none of which are slashes) with a maximum length of
  [mq_name_max ()].
  Potential causes for errors are not obeying the naming scheme, not having
  access rights to an already existing queue and using queue sizes larger than
  allowed for normal users.
*)
val mq_open : string -> Unix.open_flag list -> Unix.file_perm -> mq_attr -> (mqd, [> `EUnix of Unix.error ]) Result.result

(** [mq_send q m] sends the nessage [m] on the queue [q]; if the queue is full,
  this call will block; *)
val mq_send : mqd -> message -> (unit, [> `EUnix of Unix.error ]) Result.result

(** [mq_timedsend q m time] behaves like [mq_send q m] except that if the queue
  is full -- and [O_NONBLOCK] is not enabled for [q] -- then [time] will give an
  absolute ceiling for a timeout (given as absolute time since 01.01.1970 00:00:00 (UTC)). *)
val mq_timedsend : mqd -> message -> Timespec.t -> (unit, [> `EUnix of Unix.error ]) Result.result

(** [mq_receive q bufsiz] removes the oldest  message  with  the highest
  priority from the message queue. The [bufsiz] argument must be at least the
  maximum message size [.mq_msgsize] of the queue attributes. The returned
  message is a copy and will not be altered by subsequent calls. *)
val mq_receive : mqd -> int -> (message, [> `EUnix of Unix.error ]) Result.result

(** [mq_timedreceive q bufsiz time] behaves like [mq_send q bufsiz] except
  that if the queue is empty -- and the O_NONBLOCK flag is not enabled for
  [q] -- then [time] will give an absolute ceiling for a timeout (given as
  absolute time since 01.01.1970 00:00:00 (UTC)). *)
val mq_timedreceive : mqd -> int -> Timespec.t -> (message, [> `EUnix of Unix.error ]) Result.result

(** Close the message queue *)
val mq_close : mqd -> (unit, [> `EUnix of Unix.error ]) Result.result

(** [mq_unlink "/somequeue"] deletes the message queue ["/somequeue"]. *)
val mq_unlink : string -> (unit, [> `EUnix of Unix.error ]) Result.result

(** [mq_setattr q attr] tries to set the attributes of the message queue [q] to
  the new attributes [attr]. The new actual attributes are returned. *)
val mq_setattr : mqd -> mq_attr -> (mq_attr, [> `EUnix of Unix.error ]) Result.result
  
(** [mq_getattr q] returns the attributes of the message queue [q] *)
val mq_getattr : mqd -> (mq_attr, [> `EUnix of Unix.error ]) Result.result

(** [mq_prio_max] provides the maximum priority that can be given to a
  message; the lowest priority is [0]; POSIX guarantees [mq_prio_max >= 31] *)
val mq_prio_max : int
  
(** [mq_name_max] provides the maximum name length of a message queue. *)
val mq_name_max : int

(** Get the Unix file descriptor of the given message queue; this can then
  be used with [Unix.select]. This operation is valid on systems that implement
  message queues as file descriptor (e.g. Linux and FreeBSD).
  On systems providing no compatibility between file descriptors and message
  queues, this call may provide some random file descriptor! *)
val fd_of_mqd : mqd -> Unix.file_descr

