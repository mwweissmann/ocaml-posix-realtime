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

external clock_gettime : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result = "time_clock_gettime"

external clock_getres : Clock.t -> (Timespec.t, [>`EUnix of Unix.error]) Result.result = "time_clock_getres"

external clock_settime : Clock.t -> Timespec.t -> (unit, [>`EUnix of Unix.error]) Result.result = "time_clock_settime"

external nanosleep : Timespec.t -> ((Timespec.t option), [> `EUnix of Unix.error]) Result.result = "time_nanosleep"

external clock_nanosleep : Clock.t -> ?abs:bool -> Timespec.t -> ((Timespec.t option), [> `EUnix of Unix.error]) Result.result = "time_clock_nanosleep"

