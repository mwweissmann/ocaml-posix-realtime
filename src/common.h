#ifndef COMMON_H
#define COMMON_H

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/unixsupport.h>

int get_open_flags(value flags);

extern value eunix;

#endif

