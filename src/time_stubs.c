#include <assert.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <errno.h>
#include <time.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h> 
#include <caml/threads.h> 
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/unixsupport.h>

static value eunix;

#define Val_none Val_int(0)

static value Val_some_int(int i) {   
  CAMLparam0();
  CAMLlocal1(some);
  some = caml_alloc(1, 0);
  Store_field(some, 0, Val_int(i));
  CAMLreturn(some);
}

CAMLprim value time_initialize(void) {
  CAMLparam0();
  CAMLlocal1(clocks);

  eunix = caml_hash_variant("EUnix");

  clocks = caml_alloc(18, 0);

  Store_field(clocks, 0, Val_int(CLOCK_REALTIME));

#ifdef CLOCK_MONOTONIC
  Store_field(clocks, 1, Val_some_int(CLOCK_MONOTONIC));
#else
  Store_field(clocks, 1, Val_none);
#endif

#ifdef CLOCK_PROCESS_CPUTIME_ID
  Store_field(clocks, 2, Val_some_int(CLOCK_PROCESS_CPUTIME_ID));
#else
  Store_field(clocks, 2, Val_none);
#endif

#ifdef CLOCK_THREAD_CPUTIME_ID
  Store_field(clocks, 3, Val_some_int(CLOCK_THREAD_CPUTIME_ID));
#else
  Store_field(clocks, 3, Val_none);
#endif

#ifdef CLOCK_BOOTTIME
  Store_field(clocks, 4, Val_some_int(CLOCK_BOOTTIME));
#else
  Store_field(clocks, 4, Val_none);
#endif

#ifdef CLOCK_MONOTONIC_COARSE
  Store_field(clocks, 5, Val_some_int(CLOCK_MONOTONIC_COARSE));
#else
  Store_field(clocks, 5, Val_none);
#endif

#ifdef CLOCK_MONOTONIC_FAST
  Store_field(clocks, 6, Val_some_int(CLOCK_MONOTONIC_FAST));
#else
  Store_field(clocks, 6, Val_none);
#endif

#ifdef CLOCK_MONOTONIC_PRECISE
  Store_field(clocks, 7, Val_some_int(CLOCK_MONOTONIC_PRECISE));
#else
  Store_field(clocks, 7, Val_none);
#endif

#ifdef CLOCK_MONOTONIC_RAW
  Store_field(clocks, 8, Val_some_int(CLOCK_MONOTONIC_RAW));
#else
  Store_field(clocks, 8, Val_none);
#endif

#ifdef CLOCK_PROF
  Store_field(clocks, 9, Val_some_int(CLOCK_PROF));
#else
  Store_field(clocks, 9, Val_none);
#endif

#ifdef CLOCK_REALTIME_COARSE
  Store_field(clocks, 10, Val_some_int(CLOCK_REALTIME_COARSE));
#else
  Store_field(clocks, 10, Val_none);
#endif

#ifdef CLOCK_REALTIME_FAST
  Store_field(clocks, 11, Val_some_int(CLOCK_REALTIME_FAST));
#else
  Store_field(clocks, 11, Val_none);
#endif

#ifdef CLOCK_REALTIME_PRECISE
  Store_field(clocks, 12, Val_some_int(CLOCK_REALTIME_PRECISE));
#else
  Store_field(clocks, 12, Val_none);
#endif

#ifdef CLOCK_SECOND
  Store_field(clocks, 13, Val_some_int(CLOCK_SECOND));
#else
  Store_field(clocks, 13, Val_none);
#endif

#ifdef CLOCK_UPTIME
  Store_field(clocks, 14, Val_some_int(CLOCK_UPTIME));
#else
  Store_field(clocks, 14, Val_none);
#endif

#ifdef CLOCK_UPTIME_FAST
  Store_field(clocks, 15, Val_some_int(CLOCK_UPTIME_FAST));
#else
  Store_field(clocks, 15, Val_none);
#endif

#ifdef CLOCK_UPTIME_PRECISE
  Store_field(clocks, 16, Val_some_int(CLOCK_UPTIME_PRECISE));
#else
  Store_field(clocks, 16, Val_none);
#endif

#ifdef CLOCK_VIRTUAL
  Store_field(clocks, 17, Val_some_int(CLOCK_VIRTUAL));
#else
  Store_field(clocks, 17, Val_none);
#endif

  CAMLreturn(clocks);
}

CAMLprim value time_clock_gettime(value clock) {
  CAMLparam1(clock);
  CAMLlocal2(result, pair);

  struct timespec time;
  int lerrno;
  clockid_t clk;
  clk = Int_val(clock);

  if (0 != clock_gettime(clk, &time)) {
    lerrno = errno;
    goto ERROR;
  }

  pair = caml_alloc(2, 0);
  Store_field(pair, 0, caml_copy_int64(time.tv_sec));
  Store_field(pair, 1, caml_copy_int64(time.tv_nsec));

  result = caml_alloc(1, 0); // Result.Ok
  Store_field(result, 0, pair);
  goto END;

ERROR:
  pair = caml_alloc(2, 0);
  Store_field(pair, 0, eunix); // `EUnix
  Store_field(pair, 1, unix_error_of_code(lerrno));

  result = caml_alloc(1, 1); // Result.Error
  Store_field(result, 0, pair);

END:
  CAMLreturn(result);
}

CAMLprim value time_clock_getres(value clock) {
  CAMLparam1(clock);
  CAMLlocal2(result, pair);

  struct timespec time;
  int lerrno;
  clockid_t clk;
  clk = Int_val(clock);

  if (0 != clock_getres(clk, &time)) {
    lerrno = errno;
    goto ERROR;
  }

  pair = caml_alloc(2, 0);
  Store_field(pair, 0, caml_copy_int64(time.tv_sec));
  Store_field(pair, 1, caml_copy_int64(time.tv_nsec));

  result = caml_alloc(1, 0); // Result.Ok
  Store_field(result, 0, pair);
  goto END;

ERROR:
  pair = caml_alloc(2, 0);
  Store_field(pair, 0, eunix); // `EUnix
  Store_field(pair, 1, unix_error_of_code(lerrno));

  result = caml_alloc(1, 1); // Result.Error
  Store_field(result, 0, pair);
END:
  CAMLreturn(result);
}

CAMLprim value time_clock_settime(value clock, value t) {
  CAMLparam2(clock, t);
  CAMLlocal2(result, pair);

  struct timespec time;
  int lerrno;
  clockid_t clk;
  clk = Int_val(clock);

  time.tv_sec = Int64_val(Field(t, 0));
  time.tv_nsec = Int64_val(Field(t, 1));

  if (0 != clock_settime(clk, &time)) {
    lerrno = errno;
    goto ERROR;
  }

  result = caml_alloc(1, 0); // Result.Ok
  Store_field(result, 0, Val_unit);
  goto END;

ERROR:
  pair = caml_alloc(2, 0);
  Store_field(pair, 0, eunix); // `EUnix
  Store_field(pair, 1, unix_error_of_code(lerrno));

  result = caml_alloc(1, 1); // Result.Error
  Store_field(result, 0, pair);

END:
  CAMLreturn(result);
}

CAMLprim value time_nanosleep(value time) {
  CAMLparam1(time);
  CAMLlocal3(result, pair, rtime);
  struct timespec time_in;
  struct timespec time_out;
  int lerrno;
  bool interrupted = false;

  time_in.tv_sec = Int64_val(Field(time, 0));
  time_in.tv_nsec = Int64_val(Field(time, 1));

  if (0 != nanosleep(&time_in, &time_out)) {
    if (EINTR != (lerrno = errno)) {
      goto ERROR;
    }
    interrupted = true;
  }

  rtime = caml_alloc(2, 0);
  Store_field(rtime, 0, caml_copy_int64(time_out.tv_sec));
  Store_field(rtime, 1, caml_copy_int64(time_out.tv_nsec));

  pair = caml_alloc(2, 0);
  Store_field(pair, 0, Val_bool(interrupted));
  Store_field(pair, 1, rtime);

  result = caml_alloc(1, 0); // Result.Ok
  Store_field(result, 0, pair);
  goto END;

ERROR:
  pair = caml_alloc(2, 0);
  Store_field(pair, 0, eunix); // `EUnix
  Store_field(pair, 1, unix_error_of_code(lerrno));

  result = caml_alloc(1, 1); // Result.Error
  Store_field(result, 0, pair);

END:
  CAMLreturn(result);
}

// clock_nanosleep
