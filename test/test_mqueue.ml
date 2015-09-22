open Posix_realtime

let (>>=) v f = match v with | Result.Ok v -> f v | Result.Error _ as e -> e
let (>>|) v f = match v with | Result.Ok v -> Result.Ok (f v) | Result.Error _ as e -> e

let name = "/myqueue"

let _ =
  let rc =
    (* open the queue, creating it if it does not exist *)
    (mq_open name [Unix.O_RDWR; Unix.O_CREAT] 0o644 {mq_flags=0; mq_maxmsg=5; mq_msgsize=32; mq_curmsgs=0}) >>=

    (* if the queue is open successfully... *)
    (fun mq ->
      (* .. send a message .. *)
      (mq_send mq {payload="hello ocaml-mqueue!"; priority=23}) >>=

      (* .. and receive a message .. *)
      (fun () ->
        let _ = Unix.select [fd_of_mqd mq] [] [] 10.0 in
        mq_receive mq 32
      ) >>|

      (* .. and print the message *)
      (fun msg -> print_endline msg.payload)
    )
  in

  (* remove the queue afterwards -- otherwise they stay *)
  let _ = mq_unlink name in

  (* handle the result *)
  match rc with
  | Result.Ok () -> print_endline "done"
  | Result.Error (`EUnix errno) -> print_endline (Unix.error_message errno)

