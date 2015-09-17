external initialize : unit -> (
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
  ) = initialize ()
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
    let open Int64 in
    let rec normalize sec nsec =
      if nsec < zero then
        normalize (pred sec) (add nsec max_nsec)
      else if nsec > max_nsec then
        normalize (succ sec) (sub nsec max_nsec)
      else
        sec, nsec
    in
    let tv_sec, tv_nsec = normalize sec nsec in
    { tv_sec; tv_nsec }

  let add x y =
    create Int64.(add x.tv_sec y.tv_sec) Int64.(add x.tv_nsec y.tv_nsec)

  let sub x y =
    create Int64.(sub x.tv_sec y.tv_sec) Int64.(sub x.tv_nsec y.tv_nsec)
end

external clock_gettime : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result = "time_clock_gettime"

external clock_getres : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result = "time_clock_getres"

external clock_settime : Clock.t -> Timespec.t -> (unit, [>`EUnix of Unix.error]) Result.result = "time_clock_settime"

external nanosleep : Clock.t -> ((bool * Clock.t), [> `EUnix of Unix.error]) Result.result = "time_nanosleep"

