const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;

pub extern fn __errno_location() [*c]c_int;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __aro_max_align_ll: c_longlong = 0,
    __aro_max_align_ld: c_longdouble = 0,
};
pub const struct___va_list_tag_1 = extern struct {
    unnamed_0: c_uint = 0,
    unnamed_1: c_uint = 0,
    unnamed_2: ?*anyopaque = null,
    unnamed_3: ?*anyopaque = null,
};
pub const __builtin_va_list = [1]struct___va_list_tag_1;
pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
pub const __fsid_t = extern struct {
    __val: [2]c_int = @import("std").mem.zeroes([2]c_int),
};
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __suseconds64_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*anyopaque;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
const union_unnamed_2 = extern union {
    __wch: c_uint,
    __wchb: [4]u8,
};
pub const __mbstate_t = extern struct {
    __count: c_int = 0,
    __value: union_unnamed_2 = @import("std").mem.zeroes(union_unnamed_2),
};
pub const struct__G_fpos_t = extern struct {
    __pos: __off_t = 0,
    __state: __mbstate_t = @import("std").mem.zeroes(__mbstate_t),
};
pub const __fpos_t = struct__G_fpos_t;
pub const struct__G_fpos64_t = extern struct {
    __pos: __off64_t = 0,
    __state: __mbstate_t = @import("std").mem.zeroes(__mbstate_t),
};
pub const __fpos64_t = struct__G_fpos64_t;
pub const struct__IO_marker = opaque {}; // /usr/include/bits/types/struct_FILE.h:75:7: warning: struct demoted to opaque type - has bitfield
pub const struct__IO_FILE = opaque {
    pub const fclose = __root.fclose;
    pub const fflush = __root.fflush;
    pub const fflush_unlocked = __root.fflush_unlocked;
    pub const setbuf = __root.setbuf;
    pub const setvbuf = __root.setvbuf;
    pub const setbuffer = __root.setbuffer;
    pub const setlinebuf = __root.setlinebuf;
    pub const fprintf = __root.fprintf;
    pub const vfprintf = __root.vfprintf;
    pub const fscanf = __root.fscanf;
    pub const vfscanf = __root.vfscanf;
    pub const fgetc = __root.fgetc;
    pub const getc = __root.getc;
    pub const getc_unlocked = __root.getc_unlocked;
    pub const fgetc_unlocked = __root.fgetc_unlocked;
    pub const getw = __root.getw;
    pub const fseek = __root.fseek;
    pub const ftell = __root.ftell;
    pub const rewind = __root.rewind;
    pub const fseeko = __root.fseeko;
    pub const ftello = __root.ftello;
    pub const fgetpos = __root.fgetpos;
    pub const fsetpos = __root.fsetpos;
    pub const clearerr = __root.clearerr;
    pub const feof = __root.feof;
    pub const ferror = __root.ferror;
    pub const clearerr_unlocked = __root.clearerr_unlocked;
    pub const feof_unlocked = __root.feof_unlocked;
    pub const ferror_unlocked = __root.ferror_unlocked;
    pub const fileno = __root.fileno;
    pub const fileno_unlocked = __root.fileno_unlocked;
    pub const pclose = __root.pclose;
    pub const flockfile = __root.flockfile;
    pub const ftrylockfile = __root.ftrylockfile;
    pub const funlockfile = __root.funlockfile;
    pub const __uflow = __root.__uflow;
    pub const __overflow = __root.__overflow;
    pub const unlocked = __root.fflush_unlocked;
    pub const uflow = __root.__uflow;
    pub const overflow = __root.__overflow;
};
pub const __FILE = struct__IO_FILE;
pub const FILE = struct__IO_FILE;
pub const _IO_lock_t = anyopaque;
pub const cookie_read_function_t = fn (__cookie: ?*anyopaque, __buf: [*c]u8, __nbytes: usize) callconv(.c) __ssize_t;
pub const cookie_write_function_t = fn (__cookie: ?*anyopaque, __buf: [*c]const u8, __nbytes: usize) callconv(.c) __ssize_t;
pub const cookie_seek_function_t = fn (__cookie: ?*anyopaque, __pos: [*c]__off64_t, __w: c_int) callconv(.c) c_int;
pub const cookie_close_function_t = fn (__cookie: ?*anyopaque) callconv(.c) c_int;
pub const struct__IO_cookie_io_functions_t = extern struct {
    read: ?*const cookie_read_function_t = null,
    write: ?*const cookie_write_function_t = null,
    seek: ?*const cookie_seek_function_t = null,
    close: ?*const cookie_close_function_t = null,
};
pub const cookie_io_functions_t = struct__IO_cookie_io_functions_t;
pub const off_t = __off_t;
pub const fpos_t = __fpos_t;
pub extern var stdin: ?*FILE;
pub extern var stdout: ?*FILE;
pub extern var stderr: ?*FILE;
pub extern fn remove(__filename: [*c]const u8) c_int;
pub extern fn rename(__old: [*c]const u8, __new: [*c]const u8) c_int;
pub extern fn renameat(__oldfd: c_int, __old: [*c]const u8, __newfd: c_int, __new: [*c]const u8) c_int;
pub extern fn fclose(__stream: ?*FILE) c_int;
pub extern fn tmpfile() ?*FILE;
pub extern fn tmpnam([*c]u8) [*c]u8;
pub extern fn tmpnam_r(__s: [*c]u8) [*c]u8;
pub extern fn tempnam(__dir: [*c]const u8, __pfx: [*c]const u8) [*c]u8;
pub extern fn fflush(__stream: ?*FILE) c_int;
pub extern fn fflush_unlocked(__stream: ?*FILE) c_int;
pub extern fn fopen(noalias __filename: [*c]const u8, noalias __modes: [*c]const u8) ?*FILE;
pub extern fn freopen(noalias __filename: [*c]const u8, noalias __modes: [*c]const u8, noalias __stream: ?*FILE) ?*FILE;
pub extern fn fdopen(__fd: c_int, __modes: [*c]const u8) ?*FILE;
pub extern fn fopencookie(noalias __magic_cookie: ?*anyopaque, noalias __modes: [*c]const u8, __io_funcs: cookie_io_functions_t) ?*FILE;
pub extern fn fmemopen(__s: ?*anyopaque, __len: usize, __modes: [*c]const u8) ?*FILE;
pub extern fn open_memstream(__bufloc: [*c][*c]u8, __sizeloc: [*c]usize) ?*FILE;
pub extern fn setbuf(noalias __stream: ?*FILE, noalias __buf: [*c]u8) void;
pub extern fn setvbuf(noalias __stream: ?*FILE, noalias __buf: [*c]u8, __modes: c_int, __n: usize) c_int;
pub extern fn setbuffer(noalias __stream: ?*FILE, noalias __buf: [*c]u8, __size: usize) void;
pub extern fn setlinebuf(__stream: ?*FILE) void;
pub extern fn fprintf(noalias __stream: ?*FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn printf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sprintf(noalias __s: [*c]u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfprintf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vprintf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vsprintf(noalias __s: [*c]u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn snprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vsnprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vasprintf(noalias __ptr: [*c][*c]u8, noalias __f: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn __asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn vdprintf(__fd: c_int, noalias __fmt: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn dprintf(__fd: c_int, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn fscanf(noalias __stream: ?*FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn scanf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfscanf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vscanf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn vsscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_1) c_int;
pub extern fn fgetc(__stream: ?*FILE) c_int;
pub extern fn getc(__stream: ?*FILE) c_int;
pub extern fn getchar() c_int;
pub extern fn getc_unlocked(__stream: ?*FILE) c_int;
pub extern fn getchar_unlocked() c_int;
pub extern fn fgetc_unlocked(__stream: ?*FILE) c_int;
pub extern fn fputc(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putc(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putchar(__c: c_int) c_int;
pub extern fn fputc_unlocked(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putc_unlocked(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn putchar_unlocked(__c: c_int) c_int;
pub extern fn getw(__stream: ?*FILE) c_int;
pub extern fn putw(__w: c_int, __stream: ?*FILE) c_int;
pub extern fn fgets(noalias __s: [*c]u8, __n: c_int, noalias __stream: ?*FILE) [*c]u8;
pub extern fn __getdelim(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, __delimiter: c_int, noalias __stream: ?*FILE) __ssize_t;
pub extern fn getdelim(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, __delimiter: c_int, noalias __stream: ?*FILE) __ssize_t;
pub extern fn getline(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, noalias __stream: ?*FILE) __ssize_t;
pub extern fn fputs(noalias __s: [*c]const u8, noalias __stream: ?*FILE) c_int;
pub extern fn puts(__s: [*c]const u8) c_int;
pub extern fn ungetc(__c: c_int, __stream: ?*FILE) c_int;
pub extern fn fread(noalias __ptr: ?*anyopaque, __size: usize, __n: usize, noalias __stream: ?*FILE) usize;
pub extern fn fwrite(noalias __ptr: ?*const anyopaque, __size: usize, __n: usize, noalias __s: ?*FILE) usize;
pub extern fn fread_unlocked(noalias __ptr: ?*anyopaque, __size: usize, __n: usize, noalias __stream: ?*FILE) usize;
pub extern fn fwrite_unlocked(noalias __ptr: ?*const anyopaque, __size: usize, __n: usize, noalias __stream: ?*FILE) usize;
pub extern fn fseek(__stream: ?*FILE, __off: c_long, __whence: c_int) c_int;
pub extern fn ftell(__stream: ?*FILE) c_long;
pub extern fn rewind(__stream: ?*FILE) void;
pub extern fn fseeko(__stream: ?*FILE, __off: __off_t, __whence: c_int) c_int;
pub extern fn ftello(__stream: ?*FILE) __off_t;
pub extern fn fgetpos(noalias __stream: ?*FILE, noalias __pos: [*c]fpos_t) c_int;
pub extern fn fsetpos(__stream: ?*FILE, __pos: [*c]const fpos_t) c_int;
pub extern fn clearerr(__stream: ?*FILE) void;
pub extern fn feof(__stream: ?*FILE) c_int;
pub extern fn ferror(__stream: ?*FILE) c_int;
pub extern fn clearerr_unlocked(__stream: ?*FILE) void;
pub extern fn feof_unlocked(__stream: ?*FILE) c_int;
pub extern fn ferror_unlocked(__stream: ?*FILE) c_int;
pub extern fn perror(__s: [*c]const u8) void;
pub extern fn fileno(__stream: ?*FILE) c_int;
pub extern fn fileno_unlocked(__stream: ?*FILE) c_int;
pub extern fn pclose(__stream: ?*FILE) c_int;
pub extern fn popen(__command: [*c]const u8, __modes: [*c]const u8) ?*FILE;
pub extern fn ctermid(__s: [*c]u8) [*c]u8;
pub extern fn flockfile(__stream: ?*FILE) void;
pub extern fn ftrylockfile(__stream: ?*FILE) c_int;
pub extern fn funlockfile(__stream: ?*FILE) void;
pub extern fn __uflow(?*FILE) c_int;
pub extern fn __overflow(?*FILE, c_int) c_int;
pub const int_least8_t = __int_least8_t;
pub const int_least16_t = __int_least16_t;
pub const int_least32_t = __int_least32_t;
pub const int_least64_t = __int_least64_t;
pub const uint_least8_t = __uint_least8_t;
pub const uint_least16_t = __uint_least16_t;
pub const uint_least32_t = __uint_least32_t;
pub const uint_least64_t = __uint_least64_t;
pub const int_fast8_t = i8;
pub const int_fast16_t = c_long;
pub const int_fast32_t = c_long;
pub const int_fast64_t = c_long;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = c_ulong;
pub const uint_fast32_t = c_ulong;
pub const uint_fast64_t = c_ulong;
pub const intmax_t = __intmax_t;
pub const uintmax_t = __uintmax_t;
pub const sig_atomic_t = __sig_atomic_t;
pub const __sigset_t = extern struct {
    __val: [16]c_ulong = @import("std").mem.zeroes([16]c_ulong),
    pub const sigemptyset = __root.sigemptyset;
    pub const sigfillset = __root.sigfillset;
    pub const sigaddset = __root.sigaddset;
    pub const sigdelset = __root.sigdelset;
    pub const sigismember = __root.sigismember;
    pub const sigsuspend = __root.sigsuspend;
    pub const sigpending = __root.sigpending;
    pub const sigwait = __root.sigwait;
    pub const sigwaitinfo = __root.sigwaitinfo;
    pub const sigtimedwait = __root.sigtimedwait;
};
pub const sigset_t = __sigset_t;
pub const pid_t = __pid_t;
pub const uid_t = __uid_t;
pub const time_t = __time_t;
pub const struct_timespec = extern struct {
    tv_sec: __time_t = 0,
    tv_nsec: __syscall_slong_t = 0,
};
pub const union_sigval = extern union {
    sival_int: c_int,
    sival_ptr: ?*anyopaque,
};
pub const __sigval_t = union_sigval;
const struct_unnamed_4 = extern struct {
    si_pid: __pid_t = 0,
    si_uid: __uid_t = 0,
};
const struct_unnamed_5 = extern struct {
    si_tid: c_int = 0,
    si_overrun: c_int = 0,
    si_sigval: __sigval_t = @import("std").mem.zeroes(__sigval_t),
};
const struct_unnamed_6 = extern struct {
    si_pid: __pid_t = 0,
    si_uid: __uid_t = 0,
    si_sigval: __sigval_t = @import("std").mem.zeroes(__sigval_t),
};
const struct_unnamed_7 = extern struct {
    si_pid: __pid_t = 0,
    si_uid: __uid_t = 0,
    si_status: c_int = 0,
    si_utime: __clock_t = 0,
    si_stime: __clock_t = 0,
};
const struct_unnamed_10 = extern struct {
    _lower: ?*anyopaque = null,
    _upper: ?*anyopaque = null,
};
const union_unnamed_9 = extern union {
    _addr_bnd: struct_unnamed_10,
    _pkey: __uint32_t,
};
const struct_unnamed_8 = extern struct {
    si_addr: ?*anyopaque = null,
    si_addr_lsb: c_short = 0,
    _bounds: union_unnamed_9 = @import("std").mem.zeroes(union_unnamed_9),
};
const struct_unnamed_11 = extern struct {
    si_band: c_long = 0,
    si_fd: c_int = 0,
};
const struct_unnamed_12 = extern struct {
    _call_addr: ?*anyopaque = null,
    _syscall: c_int = 0,
    _arch: c_uint = 0,
};
const union_unnamed_3 = extern union {
    _pad: [28]c_int,
    _kill: struct_unnamed_4,
    _timer: struct_unnamed_5,
    _rt: struct_unnamed_6,
    _sigchld: struct_unnamed_7,
    _sigfault: struct_unnamed_8,
    _sigpoll: struct_unnamed_11,
    _sigsys: struct_unnamed_12,
};
pub const siginfo_t = extern struct {
    si_signo: c_int = 0,
    si_errno: c_int = 0,
    si_code: c_int = 0,
    __pad0: c_int = 0,
    _sifields: union_unnamed_3 = @import("std").mem.zeroes(union_unnamed_3),
    pub const psiginfo = __root.psiginfo;
};
pub const SI_ASYNCNL: c_int = -60;
pub const SI_DETHREAD: c_int = -7;
pub const SI_TKILL: c_int = -6;
pub const SI_SIGIO: c_int = -5;
pub const SI_ASYNCIO: c_int = -4;
pub const SI_MESGQ: c_int = -3;
pub const SI_TIMER: c_int = -2;
pub const SI_QUEUE: c_int = -1;
pub const SI_USER: c_int = 0;
pub const SI_KERNEL: c_int = 128;
const enum_unnamed_13 = c_int;
pub const ILL_ILLOPC: c_int = 1;
pub const ILL_ILLOPN: c_int = 2;
pub const ILL_ILLADR: c_int = 3;
pub const ILL_ILLTRP: c_int = 4;
pub const ILL_PRVOPC: c_int = 5;
pub const ILL_PRVREG: c_int = 6;
pub const ILL_COPROC: c_int = 7;
pub const ILL_BADSTK: c_int = 8;
pub const ILL_BADIADDR: c_int = 9;
const enum_unnamed_14 = c_uint;
pub const FPE_INTDIV: c_int = 1;
pub const FPE_INTOVF: c_int = 2;
pub const FPE_FLTDIV: c_int = 3;
pub const FPE_FLTOVF: c_int = 4;
pub const FPE_FLTUND: c_int = 5;
pub const FPE_FLTRES: c_int = 6;
pub const FPE_FLTINV: c_int = 7;
pub const FPE_FLTSUB: c_int = 8;
pub const FPE_FLTUNK: c_int = 14;
pub const FPE_CONDTRAP: c_int = 15;
const enum_unnamed_15 = c_uint;
pub const SEGV_MAPERR: c_int = 1;
pub const SEGV_ACCERR: c_int = 2;
pub const SEGV_BNDERR: c_int = 3;
pub const SEGV_PKUERR: c_int = 4;
pub const SEGV_ACCADI: c_int = 5;
pub const SEGV_ADIDERR: c_int = 6;
pub const SEGV_ADIPERR: c_int = 7;
pub const SEGV_MTEAERR: c_int = 8;
pub const SEGV_MTESERR: c_int = 9;
pub const SEGV_CPERR: c_int = 10;
const enum_unnamed_16 = c_uint;
pub const BUS_ADRALN: c_int = 1;
pub const BUS_ADRERR: c_int = 2;
pub const BUS_OBJERR: c_int = 3;
pub const BUS_MCEERR_AR: c_int = 4;
pub const BUS_MCEERR_AO: c_int = 5;
const enum_unnamed_17 = c_uint;
pub const CLD_EXITED: c_int = 1;
pub const CLD_KILLED: c_int = 2;
pub const CLD_DUMPED: c_int = 3;
pub const CLD_TRAPPED: c_int = 4;
pub const CLD_STOPPED: c_int = 5;
pub const CLD_CONTINUED: c_int = 6;
const enum_unnamed_18 = c_uint;
pub const POLL_IN: c_int = 1;
pub const POLL_OUT: c_int = 2;
pub const POLL_MSG: c_int = 3;
pub const POLL_ERR: c_int = 4;
pub const POLL_PRI: c_int = 5;
pub const POLL_HUP: c_int = 6;
const enum_unnamed_19 = c_uint;
pub const sigval_t = __sigval_t;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
const struct_unnamed_21 = extern struct {
    _function: ?*const fn (__sigval_t) callconv(.c) void = null,
    _attribute: [*c]pthread_attr_t = null,
};
const union_unnamed_20 = extern union {
    _pad: [12]c_int,
    _tid: __pid_t,
    _sigev_thread: struct_unnamed_21,
};
pub const struct_sigevent = extern struct {
    sigev_value: __sigval_t = @import("std").mem.zeroes(__sigval_t),
    sigev_signo: c_int = 0,
    sigev_notify: c_int = 0,
    _sigev_un: union_unnamed_20 = @import("std").mem.zeroes(union_unnamed_20),
};
pub const sigevent_t = struct_sigevent;
pub const SIGEV_SIGNAL: c_int = 0;
pub const SIGEV_NONE: c_int = 1;
pub const SIGEV_THREAD: c_int = 2;
pub const SIGEV_THREAD_ID: c_int = 4;
const enum_unnamed_22 = c_uint;
pub const __sighandler_t = ?*const fn (c_int) callconv(.c) void;
pub extern fn __sysv_signal(__sig: c_int, __handler: __sighandler_t) __sighandler_t;
pub extern fn signal(__sig: c_int, __handler: __sighandler_t) __sighandler_t;
pub extern fn kill(__pid: __pid_t, __sig: c_int) c_int;
pub extern fn killpg(__pgrp: __pid_t, __sig: c_int) c_int;
pub extern fn raise(__sig: c_int) c_int;
pub extern fn ssignal(__sig: c_int, __handler: __sighandler_t) __sighandler_t;
pub extern fn gsignal(__sig: c_int) c_int;
pub extern fn psignal(__sig: c_int, __s: [*c]const u8) void;
pub extern fn psiginfo(__pinfo: [*c]const siginfo_t, __s: [*c]const u8) void;
pub extern fn sigblock(__mask: c_int) c_int;
pub extern fn sigsetmask(__mask: c_int) c_int;
pub extern fn siggetmask() c_int;
pub const sig_t = __sighandler_t;
pub extern fn sigemptyset(__set: [*c]sigset_t) c_int;
pub extern fn sigfillset(__set: [*c]sigset_t) c_int;
pub extern fn sigaddset(__set: [*c]sigset_t, __signo: c_int) c_int;
pub extern fn sigdelset(__set: [*c]sigset_t, __signo: c_int) c_int;
pub extern fn sigismember(__set: [*c]const sigset_t, __signo: c_int) c_int;
const union_unnamed_23 = extern union {
    sa_handler: __sighandler_t,
    sa_sigaction: ?*const fn (c_int, [*c]siginfo_t, ?*anyopaque) callconv(.c) void,
};
pub const struct_sigaction = extern struct {
    __sigaction_handler: union_unnamed_23 = @import("std").mem.zeroes(union_unnamed_23),
    sa_mask: __sigset_t = @import("std").mem.zeroes(__sigset_t),
    sa_flags: c_int = 0,
    sa_restorer: ?*const fn () callconv(.c) void = null,
};
pub extern fn sigprocmask(__how: c_int, noalias __set: [*c]const sigset_t, noalias __oset: [*c]sigset_t) c_int;
pub extern fn sigsuspend(__set: [*c]const sigset_t) c_int;
pub extern fn sigaction(__sig: c_int, noalias __act: [*c]const struct_sigaction, noalias __oact: [*c]struct_sigaction) c_int;
pub extern fn sigpending(__set: [*c]sigset_t) c_int;
pub extern fn sigwait(noalias __set: [*c]const sigset_t, noalias __sig: [*c]c_int) c_int;
pub extern fn sigwaitinfo(noalias __set: [*c]const sigset_t, noalias __info: [*c]siginfo_t) c_int;
pub extern fn sigtimedwait(noalias __set: [*c]const sigset_t, noalias __info: [*c]siginfo_t, noalias __timeout: [*c]const struct_timespec) c_int;
pub extern fn sigqueue(__pid: __pid_t, __sig: c_int, __val: union_sigval) c_int;
pub const struct__fpx_sw_bytes = extern struct {
    magic1: __uint32_t = 0,
    extended_size: __uint32_t = 0,
    xstate_bv: __uint64_t = 0,
    xstate_size: __uint32_t = 0,
    __glibc_reserved1: [7]__uint32_t = @import("std").mem.zeroes([7]__uint32_t),
};
pub const struct__fpreg = extern struct {
    significand: [4]c_ushort = @import("std").mem.zeroes([4]c_ushort),
    exponent: c_ushort = 0,
};
pub const struct__fpxreg = extern struct {
    significand: [4]c_ushort = @import("std").mem.zeroes([4]c_ushort),
    exponent: c_ushort = 0,
    __glibc_reserved1: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
};
pub const struct__xmmreg = extern struct {
    element: [4]__uint32_t = @import("std").mem.zeroes([4]__uint32_t),
};
pub const struct__fpstate = extern struct {
    cwd: __uint16_t = 0,
    swd: __uint16_t = 0,
    ftw: __uint16_t = 0,
    fop: __uint16_t = 0,
    rip: __uint64_t = 0,
    rdp: __uint64_t = 0,
    mxcsr: __uint32_t = 0,
    mxcr_mask: __uint32_t = 0,
    _st: [8]struct__fpxreg = @import("std").mem.zeroes([8]struct__fpxreg),
    _xmm: [16]struct__xmmreg = @import("std").mem.zeroes([16]struct__xmmreg),
    __glibc_reserved1: [24]__uint32_t = @import("std").mem.zeroes([24]__uint32_t),
};
const union_unnamed_24 = extern union {
    fpstate: [*c]struct__fpstate,
    __fpstate_word: __uint64_t,
};
pub const struct_sigcontext = extern struct {
    r8: __uint64_t = 0,
    r9: __uint64_t = 0,
    r10: __uint64_t = 0,
    r11: __uint64_t = 0,
    r12: __uint64_t = 0,
    r13: __uint64_t = 0,
    r14: __uint64_t = 0,
    r15: __uint64_t = 0,
    rdi: __uint64_t = 0,
    rsi: __uint64_t = 0,
    rbp: __uint64_t = 0,
    rbx: __uint64_t = 0,
    rdx: __uint64_t = 0,
    rax: __uint64_t = 0,
    rcx: __uint64_t = 0,
    rsp: __uint64_t = 0,
    rip: __uint64_t = 0,
    eflags: __uint64_t = 0,
    cs: c_ushort = 0,
    gs: c_ushort = 0,
    fs: c_ushort = 0,
    __pad0: c_ushort = 0,
    err: __uint64_t = 0,
    trapno: __uint64_t = 0,
    oldmask: __uint64_t = 0,
    cr2: __uint64_t = 0,
    unnamed_0: union_unnamed_24 = @import("std").mem.zeroes(union_unnamed_24),
    __reserved1: [8]__uint64_t = @import("std").mem.zeroes([8]__uint64_t),
    pub const sigreturn = __root.sigreturn;
};
pub const struct__xsave_hdr = extern struct {
    xstate_bv: __uint64_t = 0,
    __glibc_reserved1: [2]__uint64_t = @import("std").mem.zeroes([2]__uint64_t),
    __glibc_reserved2: [5]__uint64_t = @import("std").mem.zeroes([5]__uint64_t),
};
pub const struct__ymmh_state = extern struct {
    ymmh_space: [64]__uint32_t = @import("std").mem.zeroes([64]__uint32_t),
};
pub const struct__xstate = extern struct {
    fpstate: struct__fpstate = @import("std").mem.zeroes(struct__fpstate),
    xstate_hdr: struct__xsave_hdr = @import("std").mem.zeroes(struct__xsave_hdr),
    ymmh: struct__ymmh_state = @import("std").mem.zeroes(struct__ymmh_state),
};
pub extern fn sigreturn(__scp: [*c]struct_sigcontext) c_int;
pub const stack_t = extern struct {
    ss_sp: ?*anyopaque = null,
    ss_flags: c_int = 0,
    ss_size: usize = 0,
    pub const sigaltstack = __root.sigaltstack;
};
pub const greg_t = c_longlong;
pub const gregset_t = [23]greg_t;
pub const struct__libc_fpxreg = extern struct {
    significand: [4]c_ushort = @import("std").mem.zeroes([4]c_ushort),
    exponent: c_ushort = 0,
    __glibc_reserved1: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
};
pub const struct__libc_xmmreg = extern struct {
    element: [4]__uint32_t = @import("std").mem.zeroes([4]__uint32_t),
};
pub const struct__libc_fpstate = extern struct {
    cwd: __uint16_t = 0,
    swd: __uint16_t = 0,
    ftw: __uint16_t = 0,
    fop: __uint16_t = 0,
    rip: __uint64_t = 0,
    rdp: __uint64_t = 0,
    mxcsr: __uint32_t = 0,
    mxcr_mask: __uint32_t = 0,
    _st: [8]struct__libc_fpxreg = @import("std").mem.zeroes([8]struct__libc_fpxreg),
    _xmm: [16]struct__libc_xmmreg = @import("std").mem.zeroes([16]struct__libc_xmmreg),
    __glibc_reserved1: [24]__uint32_t = @import("std").mem.zeroes([24]__uint32_t),
};
pub const fpregset_t = [*c]struct__libc_fpstate;
pub const mcontext_t = extern struct {
    gregs: gregset_t = @import("std").mem.zeroes(gregset_t),
    fpregs: fpregset_t = null,
    __reserved1: [8]c_ulonglong = @import("std").mem.zeroes([8]c_ulonglong),
};
pub const struct_ucontext_t = extern struct {
    uc_flags: c_ulong = 0,
    uc_link: [*c]struct_ucontext_t = null,
    uc_stack: stack_t = @import("std").mem.zeroes(stack_t),
    uc_mcontext: mcontext_t = @import("std").mem.zeroes(mcontext_t),
    uc_sigmask: sigset_t = @import("std").mem.zeroes(sigset_t),
    __fpregs_mem: struct__libc_fpstate = @import("std").mem.zeroes(struct__libc_fpstate),
    __ssp: [4]c_ulonglong = @import("std").mem.zeroes([4]c_ulonglong),
};
pub const ucontext_t = struct_ucontext_t;
pub extern fn siginterrupt(__sig: c_int, __interrupt: c_int) c_int;
pub const SS_ONSTACK: c_int = 1;
pub const SS_DISABLE: c_int = 2;
const enum_unnamed_25 = c_uint;
pub extern fn sigaltstack(noalias __ss: [*c]const stack_t, noalias __oss: [*c]stack_t) c_int;
pub const struct_sigstack = extern struct {
    ss_sp: ?*anyopaque = null,
    ss_onstack: c_int = 0,
    pub const sigstack = __root.sigstack;
};
pub extern fn sigstack(__ss: [*c]struct_sigstack, __oss: [*c]struct_sigstack) c_int;
const struct_unnamed_26 = extern struct {
    __low: c_uint = 0,
    __high: c_uint = 0,
};
pub const __atomic_wide_counter = extern union {
    __value64: c_ulonglong,
    __value32: struct_unnamed_26,
};
pub const struct___pthread_internal_list = extern struct {
    __prev: [*c]struct___pthread_internal_list = null,
    __next: [*c]struct___pthread_internal_list = null,
};
pub const __pthread_list_t = struct___pthread_internal_list;
pub const struct___pthread_internal_slist = extern struct {
    __next: [*c]struct___pthread_internal_slist = null,
};
pub const __pthread_slist_t = struct___pthread_internal_slist;
pub const struct___pthread_mutex_s = extern struct {
    __lock: c_int = 0,
    __count: c_uint = 0,
    __owner: c_int = 0,
    __nusers: c_uint = 0,
    __kind: c_int = 0,
    __spins: c_short = 0,
    __elision: c_short = 0,
    __list: __pthread_list_t = @import("std").mem.zeroes(__pthread_list_t),
};
pub const struct___pthread_rwlock_arch_t = extern struct {
    __readers: c_uint = 0,
    __writers: c_uint = 0,
    __wrphase_futex: c_uint = 0,
    __writers_futex: c_uint = 0,
    __pad3: c_uint = 0,
    __pad4: c_uint = 0,
    __cur_writer: c_int = 0,
    __shared: c_int = 0,
    __rwelision: i8 = 0,
    __pad1: [7]u8 = @import("std").mem.zeroes([7]u8),
    __pad2: c_ulong = 0,
    __flags: c_uint = 0,
};
pub const struct___pthread_cond_s = extern struct {
    __wseq: __atomic_wide_counter = @import("std").mem.zeroes(__atomic_wide_counter),
    __g1_start: __atomic_wide_counter = @import("std").mem.zeroes(__atomic_wide_counter),
    __g_size: [2]c_uint = @import("std").mem.zeroes([2]c_uint),
    __g1_orig_size: c_uint = 0,
    __wrefs: c_uint = 0,
    __g_signals: [2]c_uint = @import("std").mem.zeroes([2]c_uint),
    __unused_initialized_1: c_uint = 0,
    __unused_initialized_2: c_uint = 0,
};
pub const __tss_t = c_uint;
pub const __thrd_t = c_ulong;
pub const __once_flag = extern struct {
    __data: c_int = 0,
};
pub const pthread_t = c_ulong;
pub const pthread_mutexattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_condattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const pthread_mutex_t = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
};
pub const pthread_cond_t = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
};
pub const pthread_rwlock_t = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_rwlockattr_t = extern union {
    __size: [8]u8,
    __align: c_long,
};
pub const pthread_spinlock_t = c_int;
pub const pthread_barrier_t = extern union {
    __size: [32]u8,
    __align: c_long,
};
pub const pthread_barrierattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub extern fn pthread_sigmask(__how: c_int, noalias __newmask: [*c]const __sigset_t, noalias __oldmask: [*c]__sigset_t) c_int;
pub extern fn pthread_kill(__threadid: pthread_t, __signo: c_int) c_int;
pub extern fn __libc_current_sigrtmin() c_int;
pub extern fn __libc_current_sigrtmax() c_int;
pub extern fn zmq_errno() c_int;
pub extern fn zmq_strerror(errnum_: c_int) [*c]const u8;
pub extern fn zmq_version(major_: [*c]c_int, minor_: [*c]c_int, patch_: [*c]c_int) void;
pub extern fn zmq_ctx_new() ?*anyopaque;
pub extern fn zmq_ctx_term(context_: ?*anyopaque) c_int;
pub extern fn zmq_ctx_shutdown(context_: ?*anyopaque) c_int;
pub extern fn zmq_ctx_set(context_: ?*anyopaque, option_: c_int, optval_: c_int) c_int;
pub extern fn zmq_ctx_get(context_: ?*anyopaque, option_: c_int) c_int;
pub extern fn zmq_init(io_threads_: c_int) ?*anyopaque;
pub extern fn zmq_term(context_: ?*anyopaque) c_int;
pub extern fn zmq_ctx_destroy(context_: ?*anyopaque) c_int;
pub const struct_zmq_msg_t = extern struct {
    _: [64]u8 align(8) = @import("std").mem.zeroes([64]u8),
    pub const zmq_msg_init = __root.zmq_msg_init;
    pub const zmq_msg_init_size = __root.zmq_msg_init_size;
    pub const zmq_msg_init_data = __root.zmq_msg_init_data;
    pub const zmq_msg_send = __root.zmq_msg_send;
    pub const zmq_msg_recv = __root.zmq_msg_recv;
    pub const zmq_msg_close = __root.zmq_msg_close;
    pub const zmq_msg_move = __root.zmq_msg_move;
    pub const zmq_msg_copy = __root.zmq_msg_copy;
    pub const zmq_msg_data = __root.zmq_msg_data;
    pub const zmq_msg_size = __root.zmq_msg_size;
    pub const zmq_msg_more = __root.zmq_msg_more;
    pub const zmq_msg_get = __root.zmq_msg_get;
    pub const zmq_msg_set = __root.zmq_msg_set;
    pub const zmq_msg_gets = __root.zmq_msg_gets;
    pub const zmq_msg_set_routing_id = __root.zmq_msg_set_routing_id;
    pub const zmq_msg_routing_id = __root.zmq_msg_routing_id;
    pub const zmq_msg_set_group = __root.zmq_msg_set_group;
    pub const zmq_msg_group = __root.zmq_msg_group;
    pub const zmq_msg_init_buffer = __root.zmq_msg_init_buffer;
    pub const init = __root.zmq_msg_init;
    pub const size = __root.zmq_msg_init_size;
    pub const data = __root.zmq_msg_init_data;
    pub const send = __root.zmq_msg_send;
    pub const recv = __root.zmq_msg_recv;
    pub const close = __root.zmq_msg_close;
    pub const move = __root.zmq_msg_move;
    pub const copy = __root.zmq_msg_copy;
    pub const more = __root.zmq_msg_more;
    pub const get = __root.zmq_msg_get;
    pub const set = __root.zmq_msg_set;
    pub const gets = __root.zmq_msg_gets;
    pub const id = __root.zmq_msg_set_routing_id;
    pub const group = __root.zmq_msg_set_group;
    pub const buffer = __root.zmq_msg_init_buffer;
};
pub const zmq_msg_t = struct_zmq_msg_t;
pub const zmq_free_fn = fn (data_: ?*anyopaque, hint_: ?*anyopaque) callconv(.c) void;
pub extern fn zmq_msg_init(msg_: [*c]zmq_msg_t) c_int;
pub extern fn zmq_msg_init_size(msg_: [*c]zmq_msg_t, size_: usize) c_int;
pub extern fn zmq_msg_init_data(msg_: [*c]zmq_msg_t, data_: ?*anyopaque, size_: usize, ffn_: ?*const zmq_free_fn, hint_: ?*anyopaque) c_int;
pub extern fn zmq_msg_send(msg_: [*c]zmq_msg_t, s_: ?*anyopaque, flags_: c_int) c_int;
pub extern fn zmq_msg_recv(msg_: [*c]zmq_msg_t, s_: ?*anyopaque, flags_: c_int) c_int;
pub extern fn zmq_msg_close(msg_: [*c]zmq_msg_t) c_int;
pub extern fn zmq_msg_move(dest_: [*c]zmq_msg_t, src_: [*c]zmq_msg_t) c_int;
pub extern fn zmq_msg_copy(dest_: [*c]zmq_msg_t, src_: [*c]zmq_msg_t) c_int;
pub extern fn zmq_msg_data(msg_: [*c]zmq_msg_t) ?*anyopaque;
pub extern fn zmq_msg_size(msg_: [*c]const zmq_msg_t) usize;
pub extern fn zmq_msg_more(msg_: [*c]const zmq_msg_t) c_int;
pub extern fn zmq_msg_get(msg_: [*c]const zmq_msg_t, property_: c_int) c_int;
pub extern fn zmq_msg_set(msg_: [*c]zmq_msg_t, property_: c_int, optval_: c_int) c_int;
pub extern fn zmq_msg_gets(msg_: [*c]const zmq_msg_t, property_: [*c]const u8) [*c]const u8;
pub extern fn zmq_socket(?*anyopaque, type_: c_int) ?*anyopaque;
pub extern fn zmq_close(s_: ?*anyopaque) c_int;
pub extern fn zmq_setsockopt(s_: ?*anyopaque, option_: c_int, optval_: ?*const anyopaque, optvallen_: usize) c_int;
pub extern fn zmq_getsockopt(s_: ?*anyopaque, option_: c_int, optval_: ?*anyopaque, optvallen_: [*c]usize) c_int;
pub extern fn zmq_bind(s_: ?*anyopaque, addr_: [*c]const u8) c_int;
pub extern fn zmq_connect(s_: ?*anyopaque, addr_: [*c]const u8) c_int;
pub extern fn zmq_unbind(s_: ?*anyopaque, addr_: [*c]const u8) c_int;
pub extern fn zmq_disconnect(s_: ?*anyopaque, addr_: [*c]const u8) c_int;
pub extern fn zmq_send(s_: ?*anyopaque, buf_: ?*const anyopaque, len_: usize, flags_: c_int) c_int;
pub extern fn zmq_send_const(s_: ?*anyopaque, buf_: ?*const anyopaque, len_: usize, flags_: c_int) c_int;
pub extern fn zmq_recv(s_: ?*anyopaque, buf_: ?*anyopaque, len_: usize, flags_: c_int) c_int;
pub extern fn zmq_socket_monitor(s_: ?*anyopaque, addr_: [*c]const u8, events_: c_int) c_int;
pub const zmq_fd_t = c_int;
pub const struct_zmq_pollitem_t = extern struct {
    socket: ?*anyopaque = null,
    fd: zmq_fd_t = 0,
    events: c_short = 0,
    revents: c_short = 0,
    pub const zmq_poll = __root.zmq_poll;
    pub const zmq_ppoll = __root.zmq_ppoll;
    pub const poll = __root.zmq_poll;
    pub const ppoll = __root.zmq_ppoll;
};
pub const zmq_pollitem_t = struct_zmq_pollitem_t;
pub extern fn zmq_poll(items_: [*c]zmq_pollitem_t, nitems_: c_int, timeout_: c_long) c_int;
pub extern fn zmq_proxy(frontend_: ?*anyopaque, backend_: ?*anyopaque, capture_: ?*anyopaque) c_int;
pub extern fn zmq_proxy_steerable(frontend_: ?*anyopaque, backend_: ?*anyopaque, capture_: ?*anyopaque, control_: ?*anyopaque) c_int;
pub extern fn zmq_has(capability_: [*c]const u8) c_int;
pub extern fn zmq_device(type_: c_int, frontend_: ?*anyopaque, backend_: ?*anyopaque) c_int;
pub extern fn zmq_sendmsg(s_: ?*anyopaque, msg_: [*c]zmq_msg_t, flags_: c_int) c_int;
pub extern fn zmq_recvmsg(s_: ?*anyopaque, msg_: [*c]zmq_msg_t, flags_: c_int) c_int;
pub const struct_iovec = opaque {};
pub extern fn zmq_sendiov(s_: ?*anyopaque, iov_: ?*struct_iovec, count_: usize, flags_: c_int) c_int;
pub extern fn zmq_recviov(s_: ?*anyopaque, iov_: ?*struct_iovec, count_: [*c]usize, flags_: c_int) c_int;
pub extern fn zmq_z85_encode(dest_: [*c]u8, data_: [*c]const u8, size_: usize) [*c]u8;
pub extern fn zmq_z85_decode(dest_: [*c]u8, string_: [*c]const u8) [*c]u8;
pub extern fn zmq_curve_keypair(z85_public_key_: [*c]u8, z85_secret_key_: [*c]u8) c_int;
pub extern fn zmq_curve_public(z85_public_key_: [*c]u8, z85_secret_key_: [*c]const u8) c_int;
pub extern fn zmq_atomic_counter_new() ?*anyopaque;
pub extern fn zmq_atomic_counter_set(counter_: ?*anyopaque, value_: c_int) void;
pub extern fn zmq_atomic_counter_inc(counter_: ?*anyopaque) c_int;
pub extern fn zmq_atomic_counter_dec(counter_: ?*anyopaque) c_int;
pub extern fn zmq_atomic_counter_value(counter_: ?*anyopaque) c_int;
pub extern fn zmq_atomic_counter_destroy(counter_p_: [*c]?*anyopaque) void;
pub const zmq_timer_fn = fn (timer_id: c_int, arg: ?*anyopaque) callconv(.c) void;
pub extern fn zmq_timers_new() ?*anyopaque;
pub extern fn zmq_timers_destroy(timers_p: [*c]?*anyopaque) c_int;
pub extern fn zmq_timers_add(timers: ?*anyopaque, interval: usize, handler: ?*const zmq_timer_fn, arg: ?*anyopaque) c_int;
pub extern fn zmq_timers_cancel(timers: ?*anyopaque, timer_id: c_int) c_int;
pub extern fn zmq_timers_set_interval(timers: ?*anyopaque, timer_id: c_int, interval: usize) c_int;
pub extern fn zmq_timers_reset(timers: ?*anyopaque, timer_id: c_int) c_int;
pub extern fn zmq_timers_timeout(timers: ?*anyopaque) c_long;
pub extern fn zmq_timers_execute(timers: ?*anyopaque) c_int;
pub extern fn zmq_stopwatch_start() ?*anyopaque;
pub extern fn zmq_stopwatch_intermediate(watch_: ?*anyopaque) c_ulong;
pub extern fn zmq_stopwatch_stop(watch_: ?*anyopaque) c_ulong;
pub extern fn zmq_sleep(seconds_: c_int) void;
pub const zmq_thread_fn = fn (?*anyopaque) callconv(.c) void;
pub extern fn zmq_threadstart(func_: ?*const zmq_thread_fn, arg_: ?*anyopaque) ?*anyopaque;
pub extern fn zmq_threadclose(thread_: ?*anyopaque) void;
pub extern fn zmq_ctx_set_ext(context_: ?*anyopaque, option_: c_int, optval_: ?*const anyopaque, optvallen_: usize) c_int;
pub extern fn zmq_ctx_get_ext(context_: ?*anyopaque, option_: c_int, optval_: ?*anyopaque, optvallen_: [*c]usize) c_int;
pub extern fn zmq_join(s: ?*anyopaque, group: [*c]const u8) c_int;
pub extern fn zmq_leave(s: ?*anyopaque, group: [*c]const u8) c_int;
pub extern fn zmq_connect_peer(s_: ?*anyopaque, addr_: [*c]const u8) u32;
pub extern fn zmq_msg_set_routing_id(msg: [*c]zmq_msg_t, routing_id: u32) c_int;
pub extern fn zmq_msg_routing_id(msg: [*c]zmq_msg_t) u32;
pub extern fn zmq_msg_set_group(msg: [*c]zmq_msg_t, group: [*c]const u8) c_int;
pub extern fn zmq_msg_group(msg: [*c]zmq_msg_t) [*c]const u8;
pub extern fn zmq_msg_init_buffer(msg_: [*c]zmq_msg_t, buf_: ?*const anyopaque, size_: usize) c_int;
pub const struct_zmq_poller_event_t = extern struct {
    socket: ?*anyopaque = null,
    fd: zmq_fd_t = 0,
    user_data: ?*anyopaque = null,
    events: c_short = 0,
};
pub const zmq_poller_event_t = struct_zmq_poller_event_t;
pub extern fn zmq_poller_new() ?*anyopaque;
pub extern fn zmq_poller_destroy(poller_p: [*c]?*anyopaque) c_int;
pub extern fn zmq_poller_size(poller: ?*anyopaque) c_int;
pub extern fn zmq_poller_add(poller: ?*anyopaque, socket: ?*anyopaque, user_data: ?*anyopaque, events: c_short) c_int;
pub extern fn zmq_poller_modify(poller: ?*anyopaque, socket: ?*anyopaque, events: c_short) c_int;
pub extern fn zmq_poller_remove(poller: ?*anyopaque, socket: ?*anyopaque) c_int;
pub extern fn zmq_poller_wait(poller: ?*anyopaque, event: [*c]zmq_poller_event_t, timeout: c_long) c_int;
pub extern fn zmq_poller_wait_all(poller: ?*anyopaque, events: [*c]zmq_poller_event_t, n_events: c_int, timeout: c_long) c_int;
pub extern fn zmq_poller_fd(poller: ?*anyopaque, fd: [*c]zmq_fd_t) c_int;
pub extern fn zmq_poller_add_fd(poller: ?*anyopaque, fd: zmq_fd_t, user_data: ?*anyopaque, events: c_short) c_int;
pub extern fn zmq_poller_modify_fd(poller: ?*anyopaque, fd: zmq_fd_t, events: c_short) c_int;
pub extern fn zmq_poller_remove_fd(poller: ?*anyopaque, fd: zmq_fd_t) c_int;
pub extern fn zmq_socket_get_peer_state(socket: ?*anyopaque, routing_id: ?*const anyopaque, routing_id_size: usize) c_int;
pub extern fn zmq_socket_monitor_versioned(s_: ?*anyopaque, addr_: [*c]const u8, events_: u64, event_version_: c_int, type_: c_int) c_int;
pub extern fn zmq_socket_monitor_pipes_stats(s: ?*anyopaque) c_int;
pub extern fn zmq_ppoll(items_: [*c]zmq_pollitem_t, nitems_: c_int, timeout_: c_long, sigmask_: [*c]const sigset_t) c_int;

pub const __VERSION__ = "Aro aro-zig";
pub const __Aro__ = "";
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __GNUC__ = @as(c_int, 7);
pub const __GNUC_MINOR__ = @as(c_int, 1);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 0);
pub const __ARO_EMULATE_CLANG__ = @as(c_int, 1);
pub const __ARO_EMULATE_GCC__ = @as(c_int, 2);
pub const __ARO_EMULATE_MSVC__ = @as(c_int, 3);
pub const __ARO_EMULATE__ = __ARO_EMULATE_GCC__;
pub inline fn __building_module(x: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &x;
    return @as(c_int, 0);
}
pub const linux = @as(c_int, 1);
pub const __linux = @as(c_int, 1);
pub const __linux__ = @as(c_int, 1);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:32:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:33:9
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __VAES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __VPCLMULQDQ__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __GFNI__ = @as(c_int, 1);
pub const __EVEX512__ = @as(c_int, 1);
pub const __AVX512CD__ = @as(c_int, 1);
pub const __AVX512VPOPCNTDQ__ = @as(c_int, 1);
pub const __AVX512VNNI__ = @as(c_int, 1);
pub const __AVX512DQ__ = @as(c_int, 1);
pub const __AVX512BITALG__ = @as(c_int, 1);
pub const __AVX512BW__ = @as(c_int, 1);
pub const __AVX512VL__ = @as(c_int, 1);
pub const __EVEX256__ = @as(c_int, 1);
pub const __AVX512VBMI__ = @as(c_int, 1);
pub const __AVX512VBMI2__ = @as(c_int, 1);
pub const __AVX512IFMA__ = @as(c_int, 1);
pub const __AVX512VP2INTERSECT__ = @as(c_int, 1);
pub const __SHA__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __PKU__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __CLWB__ = @as(c_int, 1);
pub const __SHSTK__ = @as(c_int, 1);
pub const __KL__ = @as(c_int, 1);
pub const __WIDEKL__ = @as(c_int, 1);
pub const __RDPID__ = @as(c_int, 1);
pub const __MOVDIRI__ = @as(c_int, 1);
pub const __MOVDIR64B__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __CRC32__ = @as(c_int, 1);
pub const __AVX512F__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __ELF__ = @as(c_int, 1);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __ATOMIC_BOOL_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_SHORT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_INT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LLONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_POINTER_LOCK_FREE = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SCHAR_WIDTH__ = @as(c_int, 8);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __LONG_LONG_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIG_ATOMIC_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __BITINT_MAXWIDTH__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 10);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTPTR_TYPE__ = c_long;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // <builtin>:165:9
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // <builtin>:167:9
pub const __PTRDIFF_TYPE__ = c_long;
pub const __SIZE_TYPE__ = c_ulong;
pub const __WCHAR_TYPE__ = c_int;
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // <builtin>:188:9
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub const __UINT16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // <builtin>:210:9
pub const __UINT32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // <builtin>:218:9
pub const __UINT64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const INT_LEAST8_FMTd__ = "hhd";
pub const INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const UINT_LEAST8_FMTo__ = "hho";
pub const UINT_LEAST8_FMTu__ = "hhu";
pub const UINT_LEAST8_FMTx__ = "hhx";
pub const UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const INT_FAST8_FMTd__ = "hhd";
pub const INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const UINT_FAST8_FMTo__ = "hho";
pub const UINT_FAST8_FMTu__ = "hhu";
pub const UINT_FAST8_FMTx__ = "hhx";
pub const UINT_FAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const INT_LEAST16_FMTd__ = "hd";
pub const INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST16_FMTo__ = "ho";
pub const UINT_LEAST16_FMTu__ = "hu";
pub const UINT_LEAST16_FMTx__ = "hx";
pub const UINT_LEAST16_FMTX__ = "hX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const INT_FAST16_FMTd__ = "hd";
pub const INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_FAST16_FMTo__ = "ho";
pub const UINT_FAST16_FMTu__ = "hu";
pub const UINT_FAST16_FMTx__ = "hx";
pub const UINT_FAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const INT_LEAST32_FMTd__ = "d";
pub const INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST32_FMTo__ = "o";
pub const UINT_LEAST32_FMTu__ = "u";
pub const UINT_LEAST32_FMTx__ = "x";
pub const UINT_LEAST32_FMTX__ = "X";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const INT_FAST32_FMTd__ = "d";
pub const INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_FAST32_FMTo__ = "o";
pub const UINT_FAST32_FMTu__ = "u";
pub const UINT_FAST32_FMTx__ = "x";
pub const UINT_FAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const INT_LEAST64_FMTd__ = "ld";
pub const INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_LEAST64_FMTo__ = "lo";
pub const UINT_LEAST64_FMTu__ = "lu";
pub const UINT_LEAST64_FMTx__ = "lx";
pub const UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const INT_FAST64_FMTd__ = "ld";
pub const INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_FMTo__ = "lo";
pub const UINT_FAST64_FMTu__ = "lu";
pub const UINT_FAST64_FMTx__ = "lx";
pub const UINT_FAST64_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_HAS_DENORM__ = "";
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = "";
pub const __FLT16_HAS_QUIET_NAN__ = "";
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = "";
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = "";
pub const __FLT_HAS_QUIET_NAN__ = "";
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = "";
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = "";
pub const __DBL_HAS_QUIET_NAN__ = "";
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = "";
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = "";
pub const __LDBL_HAS_QUIET_NAN__ = "";
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __pic__ = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __GLIBC_MINOR__ = @as(c_int, 42);
pub const ZMQ_BUILD_DRAFT_API = @as(c_int, 1);
pub const __ZMQ_H_INCLUDED__ = "";
pub const ZMQ_VERSION_MAJOR = @as(c_int, 4);
pub const ZMQ_VERSION_MINOR = @as(c_int, 3);
pub const ZMQ_VERSION_PATCH = @as(c_int, 5);
pub inline fn ZMQ_MAKE_VERSION(major: anytype, minor: anytype, patch: anytype) @TypeOf(((major * @as(c_int, 10000)) + (minor * @as(c_int, 100))) + patch) {
    _ = &major;
    _ = &minor;
    _ = &patch;
    return ((major * @as(c_int, 10000)) + (minor * @as(c_int, 100))) + patch;
}
pub const ZMQ_VERSION = ZMQ_MAKE_VERSION(ZMQ_VERSION_MAJOR, ZMQ_VERSION_MINOR, ZMQ_VERSION_PATCH);
pub const _ERRNO_H = @as(c_int, 1);
pub const _FEATURES_H = @as(c_int, 1);
pub const __KERNEL_STRICT_NAMES = "";
pub inline fn __GNUC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub inline fn __glibc_clang_prereq(maj: anytype, min: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &maj;
    _ = &min;
    return @as(c_int, 0);
}
pub const __GLIBC_USE = @compileError("unable to translate macro: undefined identifier `__GLIBC_USE_`"); // /usr/include/features.h:191:9
pub const _DEFAULT_SOURCE = @as(c_int, 1);
pub const __GLIBC_USE_ISOC2Y = @as(c_int, 0);
pub const __GLIBC_USE_ISOC23 = @as(c_int, 0);
pub const __USE_ISOC11 = @as(c_int, 1);
pub const __USE_POSIX_IMPLICITLY = @as(c_int, 1);
pub const _POSIX_SOURCE = @as(c_int, 1);
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __USE_POSIX = @as(c_int, 1);
pub const __USE_POSIX2 = @as(c_int, 1);
pub const __USE_POSIX199309 = @as(c_int, 1);
pub const __USE_POSIX199506 = @as(c_int, 1);
pub const __USE_XOPEN2K = @as(c_int, 1);
pub const __USE_ISOC95 = @as(c_int, 1);
pub const __USE_ISOC99 = @as(c_int, 1);
pub const __USE_XOPEN2K8 = @as(c_int, 1);
pub const _ATFILE_SOURCE = @as(c_int, 1);
pub const __WORDSIZE = @as(c_int, 64);
pub const __WORDSIZE_TIME64_COMPAT32 = @as(c_int, 1);
pub const __SYSCALL_WORDSIZE = @as(c_int, 64);
pub const __TIMESIZE = __WORDSIZE;
pub const __USE_TIME_BITS64 = @as(c_int, 1);
pub const __USE_MISC = @as(c_int, 1);
pub const __USE_ATFILE = @as(c_int, 1);
pub const __USE_FORTIFY_LEVEL = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_GETS = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_SCANF = @as(c_int, 0);
pub const __GLIBC_USE_C23_STRTOL = @as(c_int, 0);
pub const _STDC_PREDEF_H = @as(c_int, 1);
pub const __STDC_IEC_559__ = @as(c_int, 1);
pub const __STDC_IEC_60559_BFP__ = @as(c_long, 201404);
pub const __STDC_IEC_559_COMPLEX__ = @as(c_int, 1);
pub const __STDC_IEC_60559_COMPLEX__ = @as(c_long, 201404);
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const __GNU_LIBRARY__ = @as(c_int, 6);
pub const __GLIBC__ = @as(c_int, 2);
pub inline fn __GLIBC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub const _SYS_CDEFS_H = @as(c_int, 1);
pub const __glibc_has_attribute = @compileError("unable to translate macro: undefined identifier `__has_attribute`"); // /usr/include/sys/cdefs.h:45:10
pub inline fn __glibc_has_builtin(name: anytype) @TypeOf(__builtin.has_builtin(name)) {
    _ = &name;
    return __builtin.has_builtin(name);
}
pub const __glibc_has_extension = @compileError("unable to translate macro: undefined identifier `__has_extension`"); // /usr/include/sys/cdefs.h:55:10
pub const __LEAF = @compileError("unable to translate macro: undefined identifier `__leaf__`"); // /usr/include/sys/cdefs.h:65:11
pub const __LEAF_ATTR = @compileError("unable to translate macro: undefined identifier `__leaf__`"); // /usr/include/sys/cdefs.h:66:11
pub const __THROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:79:11
pub const __THROWNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:80:11
pub const __NTH = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:81:11
pub const __NTHNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // /usr/include/sys/cdefs.h:82:11
pub const __COLD = @compileError("unable to translate macro: undefined identifier `__cold__`"); // /usr/include/sys/cdefs.h:102:11
pub inline fn __P(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub inline fn __PMT(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token '##'"); // /usr/include/sys/cdefs.h:131:9
pub const __STRING = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:132:9
pub const __ptr_t = ?*anyopaque;
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub const __attribute_overloadable__ = "";
pub inline fn __bos(ptr: anytype) @TypeOf(__builtin.object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1))) {
    _ = &ptr;
    return __builtin.object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1));
}
pub inline fn __bos0(ptr: anytype) @TypeOf(__builtin.object_size(ptr, @as(c_int, 0))) {
    _ = &ptr;
    return __builtin.object_size(ptr, @as(c_int, 0));
}
pub inline fn __glibc_objsize0(__o: anytype) @TypeOf(__bos0(__o)) {
    _ = &__o;
    return __bos0(__o);
}
pub inline fn __glibc_objsize(__o: anytype) @TypeOf(__bos(__o)) {
    _ = &__o;
    return __bos(__o);
}
pub const __warnattr = @compileError("unable to translate macro: undefined identifier `__warning__`"); // /usr/include/sys/cdefs.h:366:10
pub const __errordecl = @compileError("unable to translate macro: undefined identifier `__error__`"); // /usr/include/sys/cdefs.h:367:10
pub const __flexarr = @compileError("unable to translate C expr: unexpected token '['"); // /usr/include/sys/cdefs.h:379:10
pub const __glibc_c99_flexarr_available = @as(c_int, 1);
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:410:10
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:417:11
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:419:11
pub const __ASMNAME = @compileError("unable to translate macro: undefined identifier `__USER_LABEL_PREFIX__`"); // /usr/include/sys/cdefs.h:422:10
pub const __ASMNAME2 = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:423:10
pub const __REDIRECT_FORTIFY = __REDIRECT;
pub const __REDIRECT_FORTIFY_NTH = __REDIRECT_NTH;
pub const __attribute_malloc__ = @compileError("unable to translate macro: undefined identifier `__malloc__`"); // /usr/include/sys/cdefs.h:452:10
pub const __attribute_alloc_size__ = @compileError("unable to translate macro: undefined identifier `__alloc_size__`"); // /usr/include/sys/cdefs.h:460:10
pub const __attribute_alloc_align__ = @compileError("unable to translate macro: undefined identifier `__alloc_align__`"); // /usr/include/sys/cdefs.h:469:10
pub const __attribute_pure__ = @compileError("unable to translate macro: undefined identifier `__pure__`"); // /usr/include/sys/cdefs.h:479:10
pub const __attribute_const__ = @compileError("unable to translate C expr: unexpected token '__attribute__'"); // /usr/include/sys/cdefs.h:486:10
pub const __attribute_maybe_unused__ = @compileError("unable to translate macro: undefined identifier `__unused__`"); // /usr/include/sys/cdefs.h:492:10
pub const __attribute_used__ = @compileError("unable to translate macro: undefined identifier `__used__`"); // /usr/include/sys/cdefs.h:501:10
pub const __attribute_noinline__ = @compileError("unable to translate macro: undefined identifier `__noinline__`"); // /usr/include/sys/cdefs.h:502:10
pub const __attribute_deprecated__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // /usr/include/sys/cdefs.h:510:10
pub const __attribute_deprecated_msg__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // /usr/include/sys/cdefs.h:520:10
pub const __attribute_format_arg__ = @compileError("unable to translate macro: undefined identifier `__format_arg__`"); // /usr/include/sys/cdefs.h:533:10
pub const __attribute_format_strfmon__ = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:543:10
pub const __attribute_nonnull__ = @compileError("unable to translate macro: undefined identifier `__nonnull__`"); // /usr/include/sys/cdefs.h:555:11
pub inline fn __nonnull(params: anytype) @TypeOf(__attribute_nonnull__(params)) {
    _ = &params;
    return __attribute_nonnull__(params);
}
pub const __returns_nonnull = @compileError("unable to translate macro: undefined identifier `__returns_nonnull__`"); // /usr/include/sys/cdefs.h:568:10
pub const __attribute_warn_unused_result__ = @compileError("unable to translate macro: undefined identifier `__warn_unused_result__`"); // /usr/include/sys/cdefs.h:577:10
pub const __wur = "";
pub const __always_inline = @compileError("unable to translate macro: undefined identifier `__always_inline__`"); // /usr/include/sys/cdefs.h:595:10
pub const __attribute_artificial__ = @compileError("unable to translate macro: undefined identifier `__artificial__`"); // /usr/include/sys/cdefs.h:604:10
pub const __extern_inline = @compileError("unable to translate C expr: unexpected token 'extern'"); // /usr/include/sys/cdefs.h:626:11
pub const __extern_always_inline = @compileError("unable to translate C expr: unexpected token 'extern'"); // /usr/include/sys/cdefs.h:627:11
pub const __fortify_function = __extern_always_inline ++ __attribute_artificial__;
pub const __va_arg_pack = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg_pack`"); // /usr/include/sys/cdefs.h:638:10
pub const __va_arg_pack_len = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg_pack_len`"); // /usr/include/sys/cdefs.h:639:10
pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'"); // /usr/include/sys/cdefs.h:666:10
pub inline fn __glibc_unlikely(cond: anytype) @TypeOf(__builtin.expect(cond, @as(c_int, 0))) {
    _ = &cond;
    return __builtin.expect(cond, @as(c_int, 0));
}
pub inline fn __glibc_likely(cond: anytype) @TypeOf(__builtin.expect(cond, @as(c_int, 1))) {
    _ = &cond;
    return __builtin.expect(cond, @as(c_int, 1));
}
pub const __attribute_nonstring__ = "";
pub inline fn __attribute_copy__(arg: anytype) void {
    _ = &arg;
    return;
}
pub const __LDOUBLE_REDIRECTS_TO_FLOAT128_ABI = @as(c_int, 0);
pub const __LDBL_REDIR1 = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:788:10
pub const __LDBL_REDIR = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:789:10
pub const __LDBL_REDIR1_NTH = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:790:10
pub const __LDBL_REDIR_NTH = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:791:10
pub inline fn __LDBL_REDIR2_DECL(name: anytype) void {
    _ = &name;
    return;
}
pub inline fn __LDBL_REDIR_DECL(name: anytype) void {
    _ = &name;
    return;
}
pub inline fn __REDIRECT_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT(name, proto, alias);
}
pub inline fn __REDIRECT_NTH_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT_NTH(name, proto, alias);
}
pub const __glibc_macro_warning1 = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // /usr/include/sys/cdefs.h:807:10
pub const __glibc_macro_warning = @compileError("unable to translate macro: undefined identifier `GCC`"); // /usr/include/sys/cdefs.h:808:10
pub const __HAVE_GENERIC_SELECTION = @as(c_int, 1);
pub inline fn __fortified_attr_access(a: anytype, o: anytype, s: anytype) void {
    _ = &a;
    _ = &o;
    _ = &s;
    return;
}
pub inline fn __attr_access(x: anytype) void {
    _ = &x;
    return;
}
pub inline fn __attr_access_none(argno: anytype) void {
    _ = &argno;
    return;
}
pub inline fn __attr_dealloc(dealloc: anytype, argno: anytype) void {
    _ = &dealloc;
    _ = &argno;
    return;
}
pub const __attr_dealloc_free = "";
pub const __attribute_returns_twice__ = @compileError("unable to translate macro: undefined identifier `__returns_twice__`"); // /usr/include/sys/cdefs.h:872:10
pub const __attribute_struct_may_alias__ = @compileError("unable to translate macro: undefined identifier `__may_alias__`"); // /usr/include/sys/cdefs.h:881:10
pub const __stub___compat_bdflush = "";
pub const __stub_chflags = "";
pub const __stub_fchflags = "";
pub const __stub_gtty = "";
pub const __stub_revoke = "";
pub const __stub_setlogin = "";
pub const __stub_sigreturn = "";
pub const __stub_stty = "";
pub const _BITS_ERRNO_H = @as(c_int, 1);
pub const _ASM_GENERIC_ERRNO_H = "";
pub const _ASM_GENERIC_ERRNO_BASE_H = "";
pub const EPERM = @as(c_int, 1);
pub const ENOENT = @as(c_int, 2);
pub const ESRCH = @as(c_int, 3);
pub const EINTR = @as(c_int, 4);
pub const EIO = @as(c_int, 5);
pub const ENXIO = @as(c_int, 6);
pub const E2BIG = @as(c_int, 7);
pub const ENOEXEC = @as(c_int, 8);
pub const EBADF = @as(c_int, 9);
pub const ECHILD = @as(c_int, 10);
pub const EAGAIN = @as(c_int, 11);
pub const ENOMEM = @as(c_int, 12);
pub const EACCES = @as(c_int, 13);
pub const EFAULT = @as(c_int, 14);
pub const ENOTBLK = @as(c_int, 15);
pub const EBUSY = @as(c_int, 16);
pub const EEXIST = @as(c_int, 17);
pub const EXDEV = @as(c_int, 18);
pub const ENODEV = @as(c_int, 19);
pub const ENOTDIR = @as(c_int, 20);
pub const EISDIR = @as(c_int, 21);
pub const EINVAL = @as(c_int, 22);
pub const ENFILE = @as(c_int, 23);
pub const EMFILE = @as(c_int, 24);
pub const ENOTTY = @as(c_int, 25);
pub const ETXTBSY = @as(c_int, 26);
pub const EFBIG = @as(c_int, 27);
pub const ENOSPC = @as(c_int, 28);
pub const ESPIPE = @as(c_int, 29);
pub const EROFS = @as(c_int, 30);
pub const EMLINK = @as(c_int, 31);
pub const EPIPE = @as(c_int, 32);
pub const EDOM = @as(c_int, 33);
pub const ERANGE = @as(c_int, 34);
pub const EDEADLK = @as(c_int, 35);
pub const ENAMETOOLONG = @as(c_int, 36);
pub const ENOLCK = @as(c_int, 37);
pub const ENOSYS = @as(c_int, 38);
pub const ENOTEMPTY = @as(c_int, 39);
pub const ELOOP = @as(c_int, 40);
pub const EWOULDBLOCK = EAGAIN;
pub const ENOMSG = @as(c_int, 42);
pub const EIDRM = @as(c_int, 43);
pub const ECHRNG = @as(c_int, 44);
pub const EL2NSYNC = @as(c_int, 45);
pub const EL3HLT = @as(c_int, 46);
pub const EL3RST = @as(c_int, 47);
pub const ELNRNG = @as(c_int, 48);
pub const EUNATCH = @as(c_int, 49);
pub const ENOCSI = @as(c_int, 50);
pub const EL2HLT = @as(c_int, 51);
pub const EBADE = @as(c_int, 52);
pub const EBADR = @as(c_int, 53);
pub const EXFULL = @as(c_int, 54);
pub const ENOANO = @as(c_int, 55);
pub const EBADRQC = @as(c_int, 56);
pub const EBADSLT = @as(c_int, 57);
pub const EDEADLOCK = EDEADLK;
pub const EBFONT = @as(c_int, 59);
pub const ENOSTR = @as(c_int, 60);
pub const ENODATA = @as(c_int, 61);
pub const ETIME = @as(c_int, 62);
pub const ENOSR = @as(c_int, 63);
pub const ENONET = @as(c_int, 64);
pub const ENOPKG = @as(c_int, 65);
pub const EREMOTE = @as(c_int, 66);
pub const ENOLINK = @as(c_int, 67);
pub const EADV = @as(c_int, 68);
pub const ESRMNT = @as(c_int, 69);
pub const ECOMM = @as(c_int, 70);
pub const EPROTO = @as(c_int, 71);
pub const EMULTIHOP = @as(c_int, 72);
pub const EDOTDOT = @as(c_int, 73);
pub const EBADMSG = @as(c_int, 74);
pub const EOVERFLOW = @as(c_int, 75);
pub const ENOTUNIQ = @as(c_int, 76);
pub const EBADFD = @as(c_int, 77);
pub const EREMCHG = @as(c_int, 78);
pub const ELIBACC = @as(c_int, 79);
pub const ELIBBAD = @as(c_int, 80);
pub const ELIBSCN = @as(c_int, 81);
pub const ELIBMAX = @as(c_int, 82);
pub const ELIBEXEC = @as(c_int, 83);
pub const EILSEQ = @as(c_int, 84);
pub const ERESTART = @as(c_int, 85);
pub const ESTRPIPE = @as(c_int, 86);
pub const EUSERS = @as(c_int, 87);
pub const ENOTSOCK = @as(c_int, 88);
pub const EDESTADDRREQ = @as(c_int, 89);
pub const EMSGSIZE = @as(c_int, 90);
pub const EPROTOTYPE = @as(c_int, 91);
pub const ENOPROTOOPT = @as(c_int, 92);
pub const EPROTONOSUPPORT = @as(c_int, 93);
pub const ESOCKTNOSUPPORT = @as(c_int, 94);
pub const EOPNOTSUPP = @as(c_int, 95);
pub const EPFNOSUPPORT = @as(c_int, 96);
pub const EAFNOSUPPORT = @as(c_int, 97);
pub const EADDRINUSE = @as(c_int, 98);
pub const EADDRNOTAVAIL = @as(c_int, 99);
pub const ENETDOWN = @as(c_int, 100);
pub const ENETUNREACH = @as(c_int, 101);
pub const ENETRESET = @as(c_int, 102);
pub const ECONNABORTED = @as(c_int, 103);
pub const ECONNRESET = @as(c_int, 104);
pub const ENOBUFS = @as(c_int, 105);
pub const EISCONN = @as(c_int, 106);
pub const ENOTCONN = @as(c_int, 107);
pub const ESHUTDOWN = @as(c_int, 108);
pub const ETOOMANYREFS = @as(c_int, 109);
pub const ETIMEDOUT = @as(c_int, 110);
pub const ECONNREFUSED = @as(c_int, 111);
pub const EHOSTDOWN = @as(c_int, 112);
pub const EHOSTUNREACH = @as(c_int, 113);
pub const EALREADY = @as(c_int, 114);
pub const EINPROGRESS = @as(c_int, 115);
pub const ESTALE = @as(c_int, 116);
pub const EUCLEAN = @as(c_int, 117);
pub const ENOTNAM = @as(c_int, 118);
pub const ENAVAIL = @as(c_int, 119);
pub const EISNAM = @as(c_int, 120);
pub const EREMOTEIO = @as(c_int, 121);
pub const EDQUOT = @as(c_int, 122);
pub const ENOMEDIUM = @as(c_int, 123);
pub const EMEDIUMTYPE = @as(c_int, 124);
pub const ECANCELED = @as(c_int, 125);
pub const ENOKEY = @as(c_int, 126);
pub const EKEYEXPIRED = @as(c_int, 127);
pub const EKEYREVOKED = @as(c_int, 128);
pub const EKEYREJECTED = @as(c_int, 129);
pub const EOWNERDEAD = @as(c_int, 130);
pub const ENOTRECOVERABLE = @as(c_int, 131);
pub const ERFKILL = @as(c_int, 132);
pub const EHWPOISON = @as(c_int, 133);
pub const ENOTSUP = EOPNOTSUPP;
pub const errno = __errno_location().*;
pub const __STDC_VERSION_STDDEF_H__ = @as(c_long, 202311);
pub const NULL = __helpers.cast(?*anyopaque, @as(c_int, 0));
pub const offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // /usr/local/zig/lib/compiler/aro/include/stddef.h:18:9
pub const _STDIO_H = @as(c_int, 1);
pub const __need_size_t = "";
pub const __need_NULL = "";
pub const __need___va_list = "";
pub const __STDC_VERSION_STDARG_H__ = @as(c_int, 0);
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:12:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:14:9
pub const va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:15:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:18:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:22:9
pub const __GNUC_VA_LIST = @as(c_int, 1);
pub const _BITS_TYPES_H = @as(c_int, 1);
pub const __S16_TYPE = c_short;
pub const __U16_TYPE = c_ushort;
pub const __S32_TYPE = c_int;
pub const __U32_TYPE = c_uint;
pub const __SLONGWORD_TYPE = c_long;
pub const __ULONGWORD_TYPE = c_ulong;
pub const __SQUAD_TYPE = c_long;
pub const __UQUAD_TYPE = c_ulong;
pub const __SWORD_TYPE = c_long;
pub const __UWORD_TYPE = c_ulong;
pub const __SLONG32_TYPE = c_int;
pub const __ULONG32_TYPE = c_uint;
pub const __S64_TYPE = c_long;
pub const __U64_TYPE = c_ulong;
pub const _BITS_TYPESIZES_H = @as(c_int, 1);
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __GID_T_TYPE = __U32_TYPE;
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const __PID_T_TYPE = __S32_TYPE;
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __SUSECONDS64_T_TYPE = __SQUAD_TYPE;
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __TIMER_T_TYPE = ?*anyopaque;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __FSID_T_TYPE = @compileError("unable to translate macro: undefined identifier `__val`"); // /usr/include/bits/typesizes.h:73:9
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __OFF_T_MATCHES_OFF64_T = @as(c_int, 1);
pub const __INO_T_MATCHES_INO64_T = @as(c_int, 1);
pub const __RLIM_T_MATCHES_RLIM64_T = @as(c_int, 1);
pub const __STATFS_MATCHES_STATFS64 = @as(c_int, 1);
pub const __KERNEL_OLD_TIMEVAL_MATCHES_TIMEVAL64 = @as(c_int, 1);
pub const __FD_SETSIZE = @as(c_int, 1024);
pub const _BITS_TIME64_H = @as(c_int, 1);
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub const _____fpos_t_defined = @as(c_int, 1);
pub const ____mbstate_t_defined = @as(c_int, 1);
pub const __WINT_TYPE__ = c_uint;
pub const _____fpos64_t_defined = @as(c_int, 1);
pub const ____FILE_defined = @as(c_int, 1);
pub const __FILE_defined = @as(c_int, 1);
pub const __struct_FILE_defined = @as(c_int, 1);
pub const __getc_unlocked_body = @compileError("TODO postfix inc/dec expr"); // /usr/include/bits/types/struct_FILE.h:113:9
pub const __putc_unlocked_body = @compileError("TODO postfix inc/dec expr"); // /usr/include/bits/types/struct_FILE.h:117:9
pub const _IO_EOF_SEEN = @as(c_int, 0x0010);
pub inline fn __feof_unlocked_body(_fp: anytype) @TypeOf((_fp.*._flags & _IO_EOF_SEEN) != @as(c_int, 0)) {
    _ = &_fp;
    return (_fp.*._flags & _IO_EOF_SEEN) != @as(c_int, 0);
}
pub const _IO_ERR_SEEN = @as(c_int, 0x0020);
pub inline fn __ferror_unlocked_body(_fp: anytype) @TypeOf((_fp.*._flags & _IO_ERR_SEEN) != @as(c_int, 0)) {
    _ = &_fp;
    return (_fp.*._flags & _IO_ERR_SEEN) != @as(c_int, 0);
}
pub const _IO_USER_LOCK = __helpers.promoteIntLiteral(c_int, 0x8000, .hex);
pub const __cookie_io_functions_t_defined = @as(c_int, 1);
pub const _VA_LIST_DEFINED = "";
pub const __off_t_defined = "";
pub const __ssize_t_defined = "";
pub const _IOFBF = @as(c_int, 0);
pub const _IOLBF = @as(c_int, 1);
pub const _IONBF = @as(c_int, 2);
pub const BUFSIZ = @as(c_int, 8192);
pub const EOF = -@as(c_int, 1);
pub const SEEK_SET = @as(c_int, 0);
pub const SEEK_CUR = @as(c_int, 1);
pub const SEEK_END = @as(c_int, 2);
pub const P_tmpdir = "/tmp";
pub const L_tmpnam = @as(c_int, 20);
pub const TMP_MAX = __helpers.promoteIntLiteral(c_int, 238328, .decimal);
pub const _BITS_STDIO_LIM_H = @as(c_int, 1);
pub const FILENAME_MAX = @as(c_int, 4096);
pub const L_ctermid = @as(c_int, 9);
pub const FOPEN_MAX = @as(c_int, 16);
pub const __attr_dealloc_fclose = __attr_dealloc(fclose, @as(c_int, 1));
pub const _BITS_FLOATN_H = "";
pub const __HAVE_FLOAT128 = @as(c_int, 1);
pub const __HAVE_DISTINCT_FLOAT128 = @as(c_int, 1);
pub const __HAVE_FLOAT64X = @as(c_int, 1);
pub const __HAVE_FLOAT64X_LONG_DOUBLE = @as(c_int, 1);
pub const __f128 = @compileError("unable to translate macro: undefined identifier `f128`"); // /usr/include/bits/floatn.h:72:12
pub const __CFLOAT128 = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn.h:86:12
pub const _BITS_FLOATN_COMMON_H = "";
pub const __HAVE_FLOAT16 = @as(c_int, 0);
pub const __HAVE_FLOAT32 = @as(c_int, 1);
pub const __HAVE_FLOAT64 = @as(c_int, 1);
pub const __HAVE_FLOAT32X = @as(c_int, 1);
pub const __HAVE_FLOAT128X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT16 = __HAVE_FLOAT16;
pub const __HAVE_DISTINCT_FLOAT32 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT32X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT128X = __HAVE_FLOAT128X;
pub const __HAVE_FLOAT128_UNLIKE_LDBL = (__HAVE_DISTINCT_FLOAT128 != 0) and (__LDBL_MANT_DIG__ != @as(c_int, 113));
pub const __HAVE_FLOATN_NOT_TYPEDEF = @as(c_int, 1);
pub const __f32 = @compileError("unable to translate macro: undefined identifier `f32`"); // /usr/include/bits/floatn-common.h:93:12
pub const __f64 = @compileError("unable to translate macro: undefined identifier `f64`"); // /usr/include/bits/floatn-common.h:105:12
pub const __f32x = @compileError("unable to translate macro: undefined identifier `f32x`"); // /usr/include/bits/floatn-common.h:113:12
pub const __f64x = @compileError("unable to translate macro: undefined identifier `f64x`"); // /usr/include/bits/floatn-common.h:125:12
pub const __CFLOAT32 = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:151:12
pub const __CFLOAT64 = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:163:12
pub const __CFLOAT32X = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:171:12
pub const __CFLOAT64X = @compileError("unable to translate: invalid numeric type"); // /usr/include/bits/floatn-common.h:183:12
pub const ZMQ_DEFINED_STDINT = @as(c_int, 1);
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H = @as(c_int, 1);
pub const __GLIBC_USE_LIB_EXT2 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = @as(c_int, 0);
pub const _BITS_WCHAR_H = @as(c_int, 1);
pub const __WCHAR_MAX = __WCHAR_MAX__;
pub const __WCHAR_MIN = -__WCHAR_MAX - @as(c_int, 1);
pub const _BITS_STDINT_INTN_H = @as(c_int, 1);
pub const _BITS_STDINT_UINTN_H = @as(c_int, 1);
pub const _BITS_STDINT_LEAST_H = @as(c_int, 1);
pub const __intptr_t_defined = "";
pub const __INT64_C = __helpers.L_SUFFIX;
pub const __UINT64_C = __helpers.UL_SUFFIX;
pub const INT8_MIN = -@as(c_int, 128);
pub const INT16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const INT32_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT64_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT8_MAX = @as(c_int, 127);
pub const INT16_MAX = @as(c_int, 32767);
pub const INT32_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT64_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT8_MAX = @as(c_int, 255);
pub const UINT16_MAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT32_MAX = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT64_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INT_LEAST8_MIN = -@as(c_int, 128);
pub const INT_LEAST16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const INT_LEAST32_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT_LEAST64_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT_LEAST8_MAX = @as(c_int, 127);
pub const INT_LEAST16_MAX = @as(c_int, 32767);
pub const INT_LEAST32_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT_LEAST64_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT_LEAST8_MAX = @as(c_int, 255);
pub const UINT_LEAST16_MAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST32_MAX = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST64_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INT_FAST8_MIN = -@as(c_int, 128);
pub const INT_FAST16_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INT_FAST32_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INT_FAST64_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INT_FAST8_MAX = @as(c_int, 127);
pub const INT_FAST16_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INT_FAST32_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INT_FAST64_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINT_FAST8_MAX = @as(c_int, 255);
pub const UINT_FAST16_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST32_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INTPTR_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const INTPTR_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const UINTPTR_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const INTMAX_MIN = -__INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal)) - @as(c_int, 1);
pub const INTMAX_MAX = __INT64_C(__helpers.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINTMAX_MAX = __UINT64_C(__helpers.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const PTRDIFF_MIN = -__helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal) - @as(c_int, 1);
pub const PTRDIFF_MAX = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const SIG_ATOMIC_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const SIG_ATOMIC_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const SIZE_MAX = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const WCHAR_MIN = __WCHAR_MIN;
pub const WCHAR_MAX = __WCHAR_MAX;
pub const WINT_MIN = @as(c_uint, 0);
pub const WINT_MAX = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub inline fn INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub inline fn INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub inline fn INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const INT64_C = __helpers.L_SUFFIX;
pub inline fn UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub inline fn UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const UINT32_C = __helpers.U_SUFFIX;
pub const UINT64_C = __helpers.UL_SUFFIX;
pub const INTMAX_C = __helpers.L_SUFFIX;
pub const UINTMAX_C = __helpers.UL_SUFFIX;
pub const _SIGNAL_H = "";
pub const _BITS_SIGNUM_GENERIC_H = @as(c_int, 1);
pub const SIG_ERR = __helpers.cast(__sighandler_t, -@as(c_int, 1));
pub const SIG_DFL = __helpers.cast(__sighandler_t, @as(c_int, 0));
pub const SIG_IGN = __helpers.cast(__sighandler_t, @as(c_int, 1));
pub const SIGINT = @as(c_int, 2);
pub const SIGILL = @as(c_int, 4);
pub const SIGABRT = @as(c_int, 6);
pub const SIGFPE = @as(c_int, 8);
pub const SIGSEGV = @as(c_int, 11);
pub const SIGTERM = @as(c_int, 15);
pub const SIGHUP = @as(c_int, 1);
pub const SIGQUIT = @as(c_int, 3);
pub const SIGTRAP = @as(c_int, 5);
pub const SIGKILL = @as(c_int, 9);
pub const SIGPIPE = @as(c_int, 13);
pub const SIGALRM = @as(c_int, 14);
pub const SIGIO = SIGPOLL;
pub const SIGIOT = SIGABRT;
pub const SIGCLD = SIGCHLD;
pub const _BITS_SIGNUM_ARCH_H = @as(c_int, 1);
pub const SIGSTKFLT = @as(c_int, 16);
pub const SIGPWR = @as(c_int, 30);
pub const SIGBUS = @as(c_int, 7);
pub const SIGSYS = @as(c_int, 31);
pub const SIGURG = @as(c_int, 23);
pub const SIGSTOP = @as(c_int, 19);
pub const SIGTSTP = @as(c_int, 20);
pub const SIGCONT = @as(c_int, 18);
pub const SIGCHLD = @as(c_int, 17);
pub const SIGTTIN = @as(c_int, 21);
pub const SIGTTOU = @as(c_int, 22);
pub const SIGPOLL = @as(c_int, 29);
pub const SIGXFSZ = @as(c_int, 25);
pub const SIGXCPU = @as(c_int, 24);
pub const SIGVTALRM = @as(c_int, 26);
pub const SIGPROF = @as(c_int, 27);
pub const SIGUSR1 = @as(c_int, 10);
pub const SIGUSR2 = @as(c_int, 12);
pub const SIGWINCH = @as(c_int, 28);
pub const __SIGRTMIN = @as(c_int, 32);
pub const __SIGRTMAX = @as(c_int, 64);
pub const _NSIG = __SIGRTMAX + @as(c_int, 1);
pub const __sig_atomic_t_defined = @as(c_int, 1);
pub const __sigset_t_defined = @as(c_int, 1);
pub const ____sigset_t_defined = "";
pub const _SIGSET_NWORDS = __helpers.div(@as(c_int, 1024), @as(c_int, 8) * __helpers.sizeof(c_ulong));
pub const __pid_t_defined = "";
pub const __uid_t_defined = "";
pub const _STRUCT_TIMESPEC = @as(c_int, 1);
pub const _BITS_ENDIAN_H = @as(c_int, 1);
pub const __LITTLE_ENDIAN = @as(c_int, 1234);
pub const __BIG_ENDIAN = @as(c_int, 4321);
pub const __PDP_ENDIAN = @as(c_int, 3412);
pub const _BITS_ENDIANNESS_H = @as(c_int, 1);
pub const __BYTE_ORDER = __LITTLE_ENDIAN;
pub const __FLOAT_WORD_ORDER = __BYTE_ORDER;
pub inline fn __LONG_LONG_PAIR(HI: anytype, LO: anytype) @TypeOf(HI) {
    _ = &HI;
    _ = &LO;
    return blk: {
        _ = &LO;
        break :blk HI;
    };
}
pub const __time_t_defined = @as(c_int, 1);
pub const __siginfo_t_defined = @as(c_int, 1);
pub const ____sigval_t_defined = "";
pub const __SI_MAX_SIZE = @as(c_int, 128);
pub const __SI_PAD_SIZE = __helpers.div(__SI_MAX_SIZE, __helpers.sizeof(c_int)) - @as(c_int, 4);
pub const _BITS_SIGINFO_ARCH_H = @as(c_int, 1);
pub const __SI_ALIGNMENT = "";
pub const __SI_BAND_TYPE = c_long;
pub const __SI_CLOCK_T = __clock_t;
pub const __SI_ERRNO_THEN_CODE = @as(c_int, 1);
pub const __SI_HAVE_SIGSYS = @as(c_int, 1);
pub const __SI_SIGFAULT_ADDL = "";
pub const si_pid = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:128:9
pub const si_uid = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:129:9
pub const si_timerid = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:130:9
pub const si_overrun = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:131:9
pub const si_status = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:132:9
pub const si_utime = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:133:9
pub const si_stime = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:134:9
pub const si_value = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:135:9
pub const si_int = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:136:9
pub const si_ptr = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:137:9
pub const si_addr = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:138:9
pub const si_addr_lsb = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:139:9
pub const si_lower = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:140:9
pub const si_upper = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:141:9
pub const si_pkey = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:142:9
pub const si_band = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:143:9
pub const si_fd = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:144:9
pub const si_call_addr = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:146:10
pub const si_syscall = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:147:10
pub const si_arch = @compileError("unable to translate macro: undefined identifier `_sifields`"); // /usr/include/bits/types/siginfo_t.h:148:10
pub const _BITS_SIGINFO_CONSTS_H = @as(c_int, 1);
pub const __SI_ASYNCIO_AFTER_SIGIO = @as(c_int, 1);
pub const __sigval_t_defined = "";
pub const __sigevent_t_defined = @as(c_int, 1);
pub const __SIGEV_MAX_SIZE = @as(c_int, 64);
pub const __SIGEV_PAD_SIZE = __helpers.div(__SIGEV_MAX_SIZE, __helpers.sizeof(c_int)) - @as(c_int, 4);
pub const __have_pthread_attr_t = @as(c_int, 1);
pub const sigev_notify_function = @compileError("unable to translate macro: undefined identifier `_sigev_un`"); // /usr/include/bits/types/sigevent_t.h:45:9
pub const sigev_notify_attributes = @compileError("unable to translate macro: undefined identifier `_sigev_un`"); // /usr/include/bits/types/sigevent_t.h:46:9
pub const _BITS_SIGEVENT_CONSTS_H = @as(c_int, 1);
pub inline fn sigmask(sig: anytype) @TypeOf(__glibc_macro_warning("sigmask is deprecated")(__helpers.cast(c_int, @as(c_uint, 1) << (sig - @as(c_int, 1))))) {
    _ = &sig;
    return __glibc_macro_warning("sigmask is deprecated")(__helpers.cast(c_int, @as(c_uint, 1) << (sig - @as(c_int, 1))));
}
pub const NSIG = _NSIG;
pub const _BITS_SIGACTION_H = @as(c_int, 1);
pub const sa_handler = @compileError("unable to translate macro: undefined identifier `__sigaction_handler`"); // /usr/include/bits/sigaction.h:39:10
pub const sa_sigaction = @compileError("unable to translate macro: undefined identifier `__sigaction_handler`"); // /usr/include/bits/sigaction.h:40:10
pub const SA_NOCLDSTOP = @as(c_int, 1);
pub const SA_NOCLDWAIT = @as(c_int, 2);
pub const SA_SIGINFO = @as(c_int, 4);
pub const SA_ONSTACK = __helpers.promoteIntLiteral(c_int, 0x08000000, .hex);
pub const SA_RESTART = __helpers.promoteIntLiteral(c_int, 0x10000000, .hex);
pub const SA_NODEFER = __helpers.promoteIntLiteral(c_int, 0x40000000, .hex);
pub const SA_RESETHAND = __helpers.promoteIntLiteral(c_int, 0x80000000, .hex);
pub const SA_INTERRUPT = __helpers.promoteIntLiteral(c_int, 0x20000000, .hex);
pub const SA_NOMASK = SA_NODEFER;
pub const SA_ONESHOT = SA_RESETHAND;
pub const SA_STACK = SA_ONSTACK;
pub const SIG_BLOCK = @as(c_int, 0);
pub const SIG_UNBLOCK = @as(c_int, 1);
pub const SIG_SETMASK = @as(c_int, 2);
pub const _BITS_SIGCONTEXT_H = @as(c_int, 1);
pub const FP_XSTATE_MAGIC1 = __helpers.promoteIntLiteral(c_uint, 0x46505853, .hex);
pub const FP_XSTATE_MAGIC2 = __helpers.promoteIntLiteral(c_uint, 0x46505845, .hex);
pub const FP_XSTATE_MAGIC2_SIZE = __helpers.sizeof(FP_XSTATE_MAGIC2);
pub const __stack_t_defined = @as(c_int, 1);
pub const _SYS_UCONTEXT_H = @as(c_int, 1);
pub const __NGREG = @as(c_int, 23);
pub const NGREG = __NGREG;
pub const _BITS_SIGSTACK_H = @as(c_int, 1);
pub const MINSIGSTKSZ = @as(c_int, 2048);
pub const SIGSTKSZ = @as(c_int, 8192);
pub const _BITS_SS_FLAGS_H = @as(c_int, 1);
pub const __sigstack_defined = @as(c_int, 1);
pub const _BITS_PTHREADTYPES_COMMON_H = @as(c_int, 1);
pub const _THREAD_SHARED_TYPES_H = @as(c_int, 1);
pub const _BITS_PTHREADTYPES_ARCH_H = @as(c_int, 1);
pub const __SIZEOF_PTHREAD_MUTEX_T = @as(c_int, 40);
pub const __SIZEOF_PTHREAD_ATTR_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_RWLOCK_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_BARRIER_T = @as(c_int, 32);
pub const __SIZEOF_PTHREAD_MUTEXATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_COND_T = @as(c_int, 48);
pub const __SIZEOF_PTHREAD_CONDATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_RWLOCKATTR_T = @as(c_int, 8);
pub const __SIZEOF_PTHREAD_BARRIERATTR_T = @as(c_int, 4);
pub const __LOCK_ALIGNMENT = "";
pub const __ONCE_ALIGNMENT = "";
pub const _BITS_ATOMIC_WIDE_COUNTER_H = "";
pub const _THREAD_MUTEX_INTERNAL_H = @as(c_int, 1);
pub const __PTHREAD_MUTEX_HAVE_PREV = @as(c_int, 1);
pub const __PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/bits/struct_mutex.h:56:10
pub const _RWLOCK_INTERNAL_H = "";
pub const __PTHREAD_RWLOCK_ELISION_EXTRA = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/bits/struct_rwlock.h:40:11
pub inline fn __PTHREAD_RWLOCK_INITIALIZER(__flags: anytype) @TypeOf(__flags) {
    _ = &__flags;
    return blk: {
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = &__PTHREAD_RWLOCK_ELISION_EXTRA;
        _ = @as(c_int, 0);
        break :blk __flags;
    };
}
pub const __ONCE_FLAG_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/bits/thread-shared-types.h:114:9
pub const _BITS_SIGTHREAD_H = @as(c_int, 1);
pub const SIGRTMIN = __libc_current_sigrtmin();
pub const SIGRTMAX = __libc_current_sigrtmax();
pub const ZMQ_HAUSNUMERO = __helpers.promoteIntLiteral(c_int, 156384712, .decimal);
pub const EFSM = ZMQ_HAUSNUMERO + @as(c_int, 51);
pub const ENOCOMPATPROTO = ZMQ_HAUSNUMERO + @as(c_int, 52);
pub const ETERM = ZMQ_HAUSNUMERO + @as(c_int, 53);
pub const EMTHREAD = ZMQ_HAUSNUMERO + @as(c_int, 54);
pub const ZMQ_IO_THREADS = @as(c_int, 1);
pub const ZMQ_MAX_SOCKETS = @as(c_int, 2);
pub const ZMQ_SOCKET_LIMIT = @as(c_int, 3);
pub const ZMQ_THREAD_PRIORITY = @as(c_int, 3);
pub const ZMQ_THREAD_SCHED_POLICY = @as(c_int, 4);
pub const ZMQ_MAX_MSGSZ = @as(c_int, 5);
pub const ZMQ_MSG_T_SIZE = @as(c_int, 6);
pub const ZMQ_THREAD_AFFINITY_CPU_ADD = @as(c_int, 7);
pub const ZMQ_THREAD_AFFINITY_CPU_REMOVE = @as(c_int, 8);
pub const ZMQ_THREAD_NAME_PREFIX = @as(c_int, 9);
pub const ZMQ_IO_THREADS_DFLT = @as(c_int, 1);
pub const ZMQ_MAX_SOCKETS_DFLT = @as(c_int, 1023);
pub const ZMQ_THREAD_PRIORITY_DFLT = -@as(c_int, 1);
pub const ZMQ_THREAD_SCHED_POLICY_DFLT = -@as(c_int, 1);
pub const ZMQ_PAIR = @as(c_int, 0);
pub const ZMQ_PUB = @as(c_int, 1);
pub const ZMQ_SUB = @as(c_int, 2);
pub const ZMQ_REQ = @as(c_int, 3);
pub const ZMQ_REP = @as(c_int, 4);
pub const ZMQ_DEALER = @as(c_int, 5);
pub const ZMQ_ROUTER = @as(c_int, 6);
pub const ZMQ_PULL = @as(c_int, 7);
pub const ZMQ_PUSH = @as(c_int, 8);
pub const ZMQ_XPUB = @as(c_int, 9);
pub const ZMQ_XSUB = @as(c_int, 10);
pub const ZMQ_STREAM = @as(c_int, 11);
pub const ZMQ_XREQ = ZMQ_DEALER;
pub const ZMQ_XREP = ZMQ_ROUTER;
pub const ZMQ_AFFINITY = @as(c_int, 4);
pub const ZMQ_ROUTING_ID = @as(c_int, 5);
pub const ZMQ_SUBSCRIBE = @as(c_int, 6);
pub const ZMQ_UNSUBSCRIBE = @as(c_int, 7);
pub const ZMQ_RATE = @as(c_int, 8);
pub const ZMQ_RECOVERY_IVL = @as(c_int, 9);
pub const ZMQ_SNDBUF = @as(c_int, 11);
pub const ZMQ_RCVBUF = @as(c_int, 12);
pub const ZMQ_RCVMORE = @as(c_int, 13);
pub const ZMQ_FD = @as(c_int, 14);
pub const ZMQ_EVENTS = @as(c_int, 15);
pub const ZMQ_TYPE = @as(c_int, 16);
pub const ZMQ_LINGER = @as(c_int, 17);
pub const ZMQ_RECONNECT_IVL = @as(c_int, 18);
pub const ZMQ_BACKLOG = @as(c_int, 19);
pub const ZMQ_RECONNECT_IVL_MAX = @as(c_int, 21);
pub const ZMQ_MAXMSGSIZE = @as(c_int, 22);
pub const ZMQ_SNDHWM = @as(c_int, 23);
pub const ZMQ_RCVHWM = @as(c_int, 24);
pub const ZMQ_MULTICAST_HOPS = @as(c_int, 25);
pub const ZMQ_RCVTIMEO = @as(c_int, 27);
pub const ZMQ_SNDTIMEO = @as(c_int, 28);
pub const ZMQ_LAST_ENDPOINT = @as(c_int, 32);
pub const ZMQ_ROUTER_MANDATORY = @as(c_int, 33);
pub const ZMQ_TCP_KEEPALIVE = @as(c_int, 34);
pub const ZMQ_TCP_KEEPALIVE_CNT = @as(c_int, 35);
pub const ZMQ_TCP_KEEPALIVE_IDLE = @as(c_int, 36);
pub const ZMQ_TCP_KEEPALIVE_INTVL = @as(c_int, 37);
pub const ZMQ_IMMEDIATE = @as(c_int, 39);
pub const ZMQ_XPUB_VERBOSE = @as(c_int, 40);
pub const ZMQ_ROUTER_RAW = @as(c_int, 41);
pub const ZMQ_IPV6 = @as(c_int, 42);
pub const ZMQ_MECHANISM = @as(c_int, 43);
pub const ZMQ_PLAIN_SERVER = @as(c_int, 44);
pub const ZMQ_PLAIN_USERNAME = @as(c_int, 45);
pub const ZMQ_PLAIN_PASSWORD = @as(c_int, 46);
pub const ZMQ_CURVE_SERVER = @as(c_int, 47);
pub const ZMQ_CURVE_PUBLICKEY = @as(c_int, 48);
pub const ZMQ_CURVE_SECRETKEY = @as(c_int, 49);
pub const ZMQ_CURVE_SERVERKEY = @as(c_int, 50);
pub const ZMQ_PROBE_ROUTER = @as(c_int, 51);
pub const ZMQ_REQ_CORRELATE = @as(c_int, 52);
pub const ZMQ_REQ_RELAXED = @as(c_int, 53);
pub const ZMQ_CONFLATE = @as(c_int, 54);
pub const ZMQ_ZAP_DOMAIN = @as(c_int, 55);
pub const ZMQ_ROUTER_HANDOVER = @as(c_int, 56);
pub const ZMQ_TOS = @as(c_int, 57);
pub const ZMQ_CONNECT_ROUTING_ID = @as(c_int, 61);
pub const ZMQ_GSSAPI_SERVER = @as(c_int, 62);
pub const ZMQ_GSSAPI_PRINCIPAL = @as(c_int, 63);
pub const ZMQ_GSSAPI_SERVICE_PRINCIPAL = @as(c_int, 64);
pub const ZMQ_GSSAPI_PLAINTEXT = @as(c_int, 65);
pub const ZMQ_HANDSHAKE_IVL = @as(c_int, 66);
pub const ZMQ_SOCKS_PROXY = @as(c_int, 68);
pub const ZMQ_XPUB_NODROP = @as(c_int, 69);
pub const ZMQ_BLOCKY = @as(c_int, 70);
pub const ZMQ_XPUB_MANUAL = @as(c_int, 71);
pub const ZMQ_XPUB_WELCOME_MSG = @as(c_int, 72);
pub const ZMQ_STREAM_NOTIFY = @as(c_int, 73);
pub const ZMQ_INVERT_MATCHING = @as(c_int, 74);
pub const ZMQ_HEARTBEAT_IVL = @as(c_int, 75);
pub const ZMQ_HEARTBEAT_TTL = @as(c_int, 76);
pub const ZMQ_HEARTBEAT_TIMEOUT = @as(c_int, 77);
pub const ZMQ_XPUB_VERBOSER = @as(c_int, 78);
pub const ZMQ_CONNECT_TIMEOUT = @as(c_int, 79);
pub const ZMQ_TCP_MAXRT = @as(c_int, 80);
pub const ZMQ_THREAD_SAFE = @as(c_int, 81);
pub const ZMQ_MULTICAST_MAXTPDU = @as(c_int, 84);
pub const ZMQ_VMCI_BUFFER_SIZE = @as(c_int, 85);
pub const ZMQ_VMCI_BUFFER_MIN_SIZE = @as(c_int, 86);
pub const ZMQ_VMCI_BUFFER_MAX_SIZE = @as(c_int, 87);
pub const ZMQ_VMCI_CONNECT_TIMEOUT = @as(c_int, 88);
pub const ZMQ_USE_FD = @as(c_int, 89);
pub const ZMQ_GSSAPI_PRINCIPAL_NAMETYPE = @as(c_int, 90);
pub const ZMQ_GSSAPI_SERVICE_PRINCIPAL_NAMETYPE = @as(c_int, 91);
pub const ZMQ_BINDTODEVICE = @as(c_int, 92);
pub const ZMQ_MORE = @as(c_int, 1);
pub const ZMQ_SHARED = @as(c_int, 3);
pub const ZMQ_DONTWAIT = @as(c_int, 1);
pub const ZMQ_SNDMORE = @as(c_int, 2);
pub const ZMQ_NULL = @as(c_int, 0);
pub const ZMQ_PLAIN = @as(c_int, 1);
pub const ZMQ_CURVE = @as(c_int, 2);
pub const ZMQ_GSSAPI = @as(c_int, 3);
pub const ZMQ_GROUP_MAX_LENGTH = @as(c_int, 255);
pub const ZMQ_IDENTITY = ZMQ_ROUTING_ID;
pub const ZMQ_CONNECT_RID = ZMQ_CONNECT_ROUTING_ID;
pub const ZMQ_TCP_ACCEPT_FILTER = @as(c_int, 38);
pub const ZMQ_IPC_FILTER_PID = @as(c_int, 58);
pub const ZMQ_IPC_FILTER_UID = @as(c_int, 59);
pub const ZMQ_IPC_FILTER_GID = @as(c_int, 60);
pub const ZMQ_IPV4ONLY = @as(c_int, 31);
pub const ZMQ_DELAY_ATTACH_ON_CONNECT = ZMQ_IMMEDIATE;
pub const ZMQ_NOBLOCK = ZMQ_DONTWAIT;
pub const ZMQ_FAIL_UNROUTABLE = ZMQ_ROUTER_MANDATORY;
pub const ZMQ_ROUTER_BEHAVIOR = ZMQ_ROUTER_MANDATORY;
pub const ZMQ_SRCFD = @as(c_int, 2);
pub const ZMQ_GSSAPI_NT_HOSTBASED = @as(c_int, 0);
pub const ZMQ_GSSAPI_NT_USER_NAME = @as(c_int, 1);
pub const ZMQ_GSSAPI_NT_KRB5_PRINCIPAL = @as(c_int, 2);
pub const ZMQ_EVENT_CONNECTED = @as(c_int, 0x0001);
pub const ZMQ_EVENT_CONNECT_DELAYED = @as(c_int, 0x0002);
pub const ZMQ_EVENT_CONNECT_RETRIED = @as(c_int, 0x0004);
pub const ZMQ_EVENT_LISTENING = @as(c_int, 0x0008);
pub const ZMQ_EVENT_BIND_FAILED = @as(c_int, 0x0010);
pub const ZMQ_EVENT_ACCEPTED = @as(c_int, 0x0020);
pub const ZMQ_EVENT_ACCEPT_FAILED = @as(c_int, 0x0040);
pub const ZMQ_EVENT_CLOSED = @as(c_int, 0x0080);
pub const ZMQ_EVENT_CLOSE_FAILED = @as(c_int, 0x0100);
pub const ZMQ_EVENT_DISCONNECTED = @as(c_int, 0x0200);
pub const ZMQ_EVENT_MONITOR_STOPPED = @as(c_int, 0x0400);
pub const ZMQ_EVENT_ALL = __helpers.promoteIntLiteral(c_int, 0xFFFF, .hex);
pub const ZMQ_EVENT_HANDSHAKE_FAILED_NO_DETAIL = @as(c_int, 0x0800);
pub const ZMQ_EVENT_HANDSHAKE_SUCCEEDED = @as(c_int, 0x1000);
pub const ZMQ_EVENT_HANDSHAKE_FAILED_PROTOCOL = @as(c_int, 0x2000);
pub const ZMQ_EVENT_HANDSHAKE_FAILED_AUTH = @as(c_int, 0x4000);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_UNSPECIFIED = __helpers.promoteIntLiteral(c_int, 0x10000000, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_UNEXPECTED_COMMAND = __helpers.promoteIntLiteral(c_int, 0x10000001, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_INVALID_SEQUENCE = __helpers.promoteIntLiteral(c_int, 0x10000002, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_KEY_EXCHANGE = __helpers.promoteIntLiteral(c_int, 0x10000003, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_UNSPECIFIED = __helpers.promoteIntLiteral(c_int, 0x10000011, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_MESSAGE = __helpers.promoteIntLiteral(c_int, 0x10000012, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_HELLO = __helpers.promoteIntLiteral(c_int, 0x10000013, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_INITIATE = __helpers.promoteIntLiteral(c_int, 0x10000014, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_ERROR = __helpers.promoteIntLiteral(c_int, 0x10000015, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_READY = __helpers.promoteIntLiteral(c_int, 0x10000016, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MALFORMED_COMMAND_WELCOME = __helpers.promoteIntLiteral(c_int, 0x10000017, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_INVALID_METADATA = __helpers.promoteIntLiteral(c_int, 0x10000018, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_CRYPTOGRAPHIC = __helpers.promoteIntLiteral(c_int, 0x11000001, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZMTP_MECHANISM_MISMATCH = __helpers.promoteIntLiteral(c_int, 0x11000002, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZAP_UNSPECIFIED = __helpers.promoteIntLiteral(c_int, 0x20000000, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZAP_MALFORMED_REPLY = __helpers.promoteIntLiteral(c_int, 0x20000001, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZAP_BAD_REQUEST_ID = __helpers.promoteIntLiteral(c_int, 0x20000002, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZAP_BAD_VERSION = __helpers.promoteIntLiteral(c_int, 0x20000003, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZAP_INVALID_STATUS_CODE = __helpers.promoteIntLiteral(c_int, 0x20000004, .hex);
pub const ZMQ_PROTOCOL_ERROR_ZAP_INVALID_METADATA = __helpers.promoteIntLiteral(c_int, 0x20000005, .hex);
pub const ZMQ_PROTOCOL_ERROR_WS_UNSPECIFIED = __helpers.promoteIntLiteral(c_int, 0x30000000, .hex);
pub const ZMQ_POLLIN = @as(c_int, 1);
pub const ZMQ_POLLOUT = @as(c_int, 2);
pub const ZMQ_POLLERR = @as(c_int, 4);
pub const ZMQ_POLLPRI = @as(c_int, 8);
pub const ZMQ_POLLITEMS_DFLT = @as(c_int, 16);
pub const ZMQ_HAS_CAPABILITIES = @as(c_int, 1);
pub const ZMQ_STREAMER = @as(c_int, 1);
pub const ZMQ_FORWARDER = @as(c_int, 2);
pub const ZMQ_QUEUE = @as(c_int, 3);
pub const ZMQ_HAVE_TIMERS = "";
pub const ZMQ_SERVER = @as(c_int, 12);
pub const ZMQ_CLIENT = @as(c_int, 13);
pub const ZMQ_RADIO = @as(c_int, 14);
pub const ZMQ_DISH = @as(c_int, 15);
pub const ZMQ_GATHER = @as(c_int, 16);
pub const ZMQ_SCATTER = @as(c_int, 17);
pub const ZMQ_DGRAM = @as(c_int, 18);
pub const ZMQ_PEER = @as(c_int, 19);
pub const ZMQ_CHANNEL = @as(c_int, 20);
pub const ZMQ_ZAP_ENFORCE_DOMAIN = @as(c_int, 93);
pub const ZMQ_LOOPBACK_FASTPATH = @as(c_int, 94);
pub const ZMQ_METADATA = @as(c_int, 95);
pub const ZMQ_MULTICAST_LOOP = @as(c_int, 96);
pub const ZMQ_ROUTER_NOTIFY = @as(c_int, 97);
pub const ZMQ_XPUB_MANUAL_LAST_VALUE = @as(c_int, 98);
pub const ZMQ_SOCKS_USERNAME = @as(c_int, 99);
pub const ZMQ_SOCKS_PASSWORD = @as(c_int, 100);
pub const ZMQ_IN_BATCH_SIZE = @as(c_int, 101);
pub const ZMQ_OUT_BATCH_SIZE = @as(c_int, 102);
pub const ZMQ_WSS_KEY_PEM = @as(c_int, 103);
pub const ZMQ_WSS_CERT_PEM = @as(c_int, 104);
pub const ZMQ_WSS_TRUST_PEM = @as(c_int, 105);
pub const ZMQ_WSS_HOSTNAME = @as(c_int, 106);
pub const ZMQ_WSS_TRUST_SYSTEM = @as(c_int, 107);
pub const ZMQ_ONLY_FIRST_SUBSCRIBE = @as(c_int, 108);
pub const ZMQ_RECONNECT_STOP = @as(c_int, 109);
pub const ZMQ_HELLO_MSG = @as(c_int, 110);
pub const ZMQ_DISCONNECT_MSG = @as(c_int, 111);
pub const ZMQ_PRIORITY = @as(c_int, 112);
pub const ZMQ_BUSY_POLL = @as(c_int, 113);
pub const ZMQ_HICCUP_MSG = @as(c_int, 114);
pub const ZMQ_XSUB_VERBOSE_UNSUBSCRIBE = @as(c_int, 115);
pub const ZMQ_TOPICS_COUNT = @as(c_int, 116);
pub const ZMQ_NORM_MODE = @as(c_int, 117);
pub const ZMQ_NORM_UNICAST_NACK = @as(c_int, 118);
pub const ZMQ_NORM_BUFFER_SIZE = @as(c_int, 119);
pub const ZMQ_NORM_SEGMENT_SIZE = @as(c_int, 120);
pub const ZMQ_NORM_BLOCK_SIZE = @as(c_int, 121);
pub const ZMQ_NORM_NUM_PARITY = @as(c_int, 122);
pub const ZMQ_NORM_NUM_AUTOPARITY = @as(c_int, 123);
pub const ZMQ_NORM_PUSH = @as(c_int, 124);
pub const ZMQ_NORM_FIXED = @as(c_int, 0);
pub const ZMQ_NORM_CC = @as(c_int, 1);
pub const ZMQ_NORM_CCL = @as(c_int, 2);
pub const ZMQ_NORM_CCE = @as(c_int, 3);
pub const ZMQ_NORM_CCE_ECNONLY = @as(c_int, 4);
pub const ZMQ_RECONNECT_STOP_CONN_REFUSED = @as(c_int, 0x1);
pub const ZMQ_RECONNECT_STOP_HANDSHAKE_FAILED = @as(c_int, 0x2);
pub const ZMQ_RECONNECT_STOP_AFTER_DISCONNECT = @as(c_int, 0x4);
pub const ZMQ_ZERO_COPY_RECV = @as(c_int, 10);
pub const ZMQ_MSG_PROPERTY_ROUTING_ID = "Routing-Id";
pub const ZMQ_MSG_PROPERTY_SOCKET_TYPE = "Socket-Type";
pub const ZMQ_MSG_PROPERTY_USER_ID = "User-Id";
pub const ZMQ_MSG_PROPERTY_PEER_ADDRESS = "Peer-Address";
pub const ZMQ_NOTIFY_CONNECT = @as(c_int, 1);
pub const ZMQ_NOTIFY_DISCONNECT = @as(c_int, 2);
pub const ZMQ_HAVE_POLLER = "";
pub const ZMQ_EVENT_PIPES_STATS = __helpers.promoteIntLiteral(c_int, 0x10000, .hex);
pub const ZMQ_CURRENT_EVENT_VERSION = @as(c_int, 1);
pub const ZMQ_CURRENT_EVENT_VERSION_DRAFT = @as(c_int, 2);
pub const ZMQ_EVENT_ALL_V1 = ZMQ_EVENT_ALL;
pub const ZMQ_EVENT_ALL_V2 = ZMQ_EVENT_ALL_V1 | ZMQ_EVENT_PIPES_STATS;
pub const _G_fpos_t = struct__G_fpos_t;
pub const _G_fpos64_t = struct__G_fpos64_t;
pub const _IO_marker = struct__IO_marker;
pub const _IO_FILE = struct__IO_FILE;
pub const _IO_cookie_io_functions_t = struct__IO_cookie_io_functions_t;
pub const timespec = struct_timespec;
pub const sigval = union_sigval;
pub const sigevent = struct_sigevent;
pub const _fpx_sw_bytes = struct__fpx_sw_bytes;
pub const _fpreg = struct__fpreg;
pub const _fpxreg = struct__fpxreg;
pub const _xmmreg = struct__xmmreg;
pub const _fpstate = struct__fpstate;
pub const sigcontext = struct_sigcontext;
pub const _xsave_hdr = struct__xsave_hdr;
pub const _ymmh_state = struct__ymmh_state;
pub const _xstate = struct__xstate;
pub const _libc_fpxreg = struct__libc_fpxreg;
pub const _libc_xmmreg = struct__libc_xmmreg;
pub const _libc_fpstate = struct__libc_fpstate;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const iovec = struct_iovec;
