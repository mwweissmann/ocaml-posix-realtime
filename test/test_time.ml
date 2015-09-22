let print_time time =
  Printf.printf "s = %s, ns = %s"
    (Int64.to_string Posix_realtime.Timespec.(time.tv_sec)) 
    (Int64.to_string Posix_realtime.Timespec.(time.tv_nsec)) 

let print = function
  | Result.Ok time -> print_time time
  | Result.Error (`EUnix err) -> print_endline (Unix.error_message err)

let test name c =
  let () = print_string name in
  match c with
  | Some clock ->
    begin
      print_string "\n * time: "; print (Posix_realtime.clock_gettime clock);
      print_string "\n * resolution: "; print (Posix_realtime.clock_getres clock); print_endline "";
    end
  | None -> print_endline "\n * unavailable"

let _ =
  let open Posix_realtime.Clock in
  let () = test "realtime" (Some realtime) in
  let () = test "monotonic" monotonic in
  let () = test "process_cputime_id" process_cputime_id in
  let () = test "thread_cputime_id" thread_cputime_id in
  let () = test "boottime" boottime in
  let () = test "monotonic_coarse" monotonic_coarse in
  let () = test "monotonic_fast" monotonic_fast in
  let () = test "monotonic_precise" monotonic_precise in
  let () = test "monotonic_raw" monotonic_raw in
  let () = test "prof" prof in
  let () = test "realtime_coarse" realtime_coarse in
  let () = test "realtime_fast" realtime_fast in
  let () = test "realtime_precise" realtime_precise in
  let () = test "second" second in
  let () = test "uptime" uptime in
  let () = test "uptime_fast" uptime_fast in
  let () = test "uptime_precise" uptime_precise in
  let () = test "virtual_" virtual_ in
  let () = match Posix_realtime.clock_getcpuclockid 0 with
    | Result.Ok clk -> test "clock_getcpuclockid" (Some clk)
    | Result.Error (`EUnix err) -> begin print_string "clock_getcpuclockid, error: "; print_endline (Unix.error_message err) end
  in
  print_endline "done"

let _ =
  let open Posix_realtime.Clock in
  print_string "nanosleep\n * ";
  let sec1 = Posix_realtime.Timespec.create Int64.one Int64.zero in
  let () = match Posix_realtime.nanosleep sec1 with
    | Result.Ok t -> (begin match t with None -> print_string "without interrupt" | Some t -> print_time t end; print_endline "")
    | Result.Error (`EUnix err) -> begin print_string "error: "; print_endline (Unix.error_message err) end
  in

  print_string "clock_nanosleep realtime\n * ";
  let () = match Posix_realtime.clock_nanosleep realtime sec1 with
    | Result.Ok t -> (begin match t with None -> print_string "without interrupt" | Some t -> print_time t end; print_endline "")
    | Result.Error (`EUnix err) -> begin print_string "error: "; print_endline (Unix.error_message err) end
  in
  print_endline "done"

