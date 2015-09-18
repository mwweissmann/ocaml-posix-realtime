let print time =
  Printf.printf "s = %s, ns = %s"
    (Int64.to_string Time.Timespec.(time.tv_sec)) 
    (Int64.to_string Time.Timespec.(time.tv_nsec)) 

let print = function
  | Result.Ok time -> print time
  | Result.Error (`EUnix err) -> print_endline (Unix.error_message err)

let test name c =
  let () = print_string name in
  match c with
  | Some clock ->
    begin
      print_string ", time: "; print (Time.clock_gettime clock);
      print_string ", resolution: "; print (Time.clock_getres clock);
      print_endline ""
    end
  | None -> print_endline " unavailable"

let _ =
  let open Time.Clock in
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
  print_endline "done"

