external common_initialize : unit -> unit = "common_initialize"
let () = common_initialize ()

external time_initialize : unit -> (
      int * int option * int option * int option *
      int option * int option * int option * int option *
      int option * int option * int option * int option *
      int option * int option * int option * int option *
      int option * int option
    ) = "time_initialize"

module Clock = struct
  type t = int

  let (
    realtime,
    monotonic,
    process_cputime_id,
    thread_cputime_id,
    boottime,
    monotonic_coarse,
    monotonic_fast,
    monotonic_precise,
    monotonic_raw,
    prof,
    realtime_coarse,
    realtime_fast,
    realtime_precise,
    second,
    uptime,
    uptime_fast,
    uptime_precise,
    virtual_
  ) = time_initialize ()
end

module Timespec = struct
  type t = {
    tv_sec : int64;
    tv_nsec : int64;
  }

  let max_nsec = Int64.of_float 1e9

  let compare x y =
    match Int64.compare x.tv_sec y.tv_sec with
    | 0 -> Int64.compare x.tv_nsec y.tv_nsec
    | d -> d

  let create sec nsec =
    let rec normalize sec nsec =
      if nsec < Int64.zero then
        normalize (Int64.pred sec) (Int64.add nsec max_nsec)
      else if nsec > max_nsec then
        normalize (Int64.succ sec) (Int64.sub nsec max_nsec)
      else
        sec, nsec
    in
    let tv_sec, tv_nsec = normalize sec nsec in
    { tv_sec; tv_nsec }

  let add x y =
    create Int64.(add x.tv_sec y.tv_sec) Int64.(add x.tv_nsec y.tv_nsec)

  let sub x y =
    create Int64.(sub x.tv_sec y.tv_sec) Int64.(sub x.tv_nsec y.tv_nsec)

  let add_sec sec t = { t with tv_sec = Int64.add t.tv_sec sec }

  let sub_sec sec t = { t with tv_sec = Int64.sub t.tv_sec sec }

  let add_nsec nsec t = create t.tv_sec (Int64.add t.tv_nsec nsec)

  let sub_nsec nsec t = create t.tv_sec (Int64.sub t.tv_nsec nsec)
end

external clock_getcpuclockid : int -> (Clock.t, [>`EUnix of Unix.error]) Result.result = "time_clock_getcpuclockid"

external clock_gettime : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result = "time_clock_gettime"

external clock_getres : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result = "time_clock_getres"

external clock_settime : Clock.t -> Timespec.t -> (unit, [>`EUnix of Unix.error]) Result.result = "time_clock_settime"

external nanosleep : Timespec.t -> ((Timespec.t option), [> `EUnix of Unix.error]) Result.result = "time_nanosleep"

external clock_nanosleep : Clock.t -> ?abs:bool -> Timespec.t -> ((Timespec.t option), [> `EUnix of Unix.error]) Result.result = "time_clock_nanosleep"

(*
external timer_create : Clock.t -> Sigevent.t -> (timer, [>`EUnix of Unix.error]) Result.result = "time_timer_create"
*)

type mqd = Unix.file_descr

type mq_attr = {
  mq_flags : int;
  mq_maxmsg : int;
  mq_msgsize : int;
  mq_curmsgs : int
}

type message = {
  payload : Bytes.t;
  priority : int;
}

external mq_open : string -> Unix.open_flag list -> Unix.file_perm -> mq_attr ->
  (mqd, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_open"

external mq_close : mqd ->
  (unit, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_close"

external mq_send : mqd -> message ->
  (unit, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_send"

external mq_timedsend : mqd -> message -> Timespec.t ->
  (unit, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_timedsend"

external mq_receive : mqd -> int ->
  (message, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_receive"

external mq_timedreceive : mqd -> int -> Timespec.t ->
  (message, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_timedreceive"

external mq_unlink : string ->
  (unit, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_unlink"

external mq_getattr : mqd ->
  (mq_attr, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_getattr"

external mq_setattr : mqd -> mq_attr ->
  (mq_attr, [>`EUnix of Unix.error]) Result.result = "mqueue_mq_setattr"

external mq_prio_max_ext : unit -> int = "mqueue_mq_prio_max"
let mq_prio_max = mq_prio_max_ext ()

external mq_name_max_ext : unit -> int = "mqueue_mq_name_max"
let mq_name_max = mq_name_max_ext ()

external fd_of_mqd : mqd -> Unix.file_descr = "%identity"

