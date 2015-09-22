#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/unixsupport.h>
#include <caml/threads.h>
#include <caml/signals.h>
#include <caml/custom.h>

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>

static int open_flag_table[14] = {
  O_RDONLY, O_WRONLY, O_RDWR, O_NONBLOCK, O_APPEND, O_CREAT, O_TRUNC, O_EXCL,
  O_NOCTTY, O_DSYNC, O_SYNC, O_RSYNC,
  0, /* O_SHARE_DELETE, Windows-only */
  O_CLOEXEC
};

value eunix;

CAMLprim value common_initialize(void) {
  CAMLparam0();
  eunix = caml_hash_variant("EUnix");
  CAMLreturn (Val_unit);
}

int get_open_flags(value flags) {
  return convert_flag_list(flags, open_flag_table);
}

