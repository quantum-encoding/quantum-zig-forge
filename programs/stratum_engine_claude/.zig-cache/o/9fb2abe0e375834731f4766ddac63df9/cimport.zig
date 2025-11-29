const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;

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
pub const mbedtls_iso_c_forbids_empty_translation_units = c_int;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __aro_max_align_ll: c_longlong = 0,
    __aro_max_align_ld: c_longdouble = 0,
};
pub const clock_t = __clock_t;
pub const time_t = __time_t;
pub const struct_tm = extern struct {
    tm_sec: c_int = 0,
    tm_min: c_int = 0,
    tm_hour: c_int = 0,
    tm_mday: c_int = 0,
    tm_mon: c_int = 0,
    tm_year: c_int = 0,
    tm_wday: c_int = 0,
    tm_yday: c_int = 0,
    tm_isdst: c_int = 0,
    tm_gmtoff: c_long = 0,
    tm_zone: [*c]const u8 = null,
    pub const mktime = __root.mktime;
    pub const timegm = __root.timegm;
    pub const timelocal = __root.timelocal;
};
pub const struct_timespec = extern struct {
    tv_sec: __time_t = 0,
    tv_nsec: __syscall_slong_t = 0,
    pub const timespec_get = __root.timespec_get;
    pub const get = __root.timespec_get;
};
pub const clockid_t = __clockid_t;
pub const timer_t = __timer_t;
pub const struct_itimerspec = extern struct {
    it_interval: struct_timespec = @import("std").mem.zeroes(struct_timespec),
    it_value: struct_timespec = @import("std").mem.zeroes(struct_timespec),
};
pub const pid_t = __pid_t;
pub const struct___locale_data_1 = opaque {};
pub const struct___locale_struct = extern struct {
    __locales: [13]?*struct___locale_data_1 = @import("std").mem.zeroes([13]?*struct___locale_data_1),
    __ctype_b: [*c]const c_ushort = null,
    __ctype_tolower: [*c]const c_int = null,
    __ctype_toupper: [*c]const c_int = null,
    __names: [13][*c]const u8 = @import("std").mem.zeroes([13][*c]const u8),
};
pub const __locale_t = [*c]struct___locale_struct;
pub const locale_t = __locale_t;
pub extern fn clock() clock_t;
pub extern fn time(__timer: [*c]time_t) time_t;
pub extern fn difftime(__time1: time_t, __time0: time_t) f64;
pub extern fn mktime(__tp: [*c]struct_tm) time_t;
pub extern fn strftime(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm) usize;
pub extern fn strftime_l(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm, __loc: locale_t) usize;
pub extern fn gmtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn localtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn gmtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn localtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn asctime(__tp: [*c]const struct_tm) [*c]u8;
pub extern fn ctime(__timer: [*c]const time_t) [*c]u8;
pub extern fn asctime_r(noalias __tp: [*c]const struct_tm, noalias __buf: [*c]u8) [*c]u8;
pub extern fn ctime_r(noalias __timer: [*c]const time_t, noalias __buf: [*c]u8) [*c]u8;
pub extern var __tzname: [2][*c]u8;
pub extern var __daylight: c_int;
pub extern var __timezone: c_long;
pub extern var tzname: [2][*c]u8;
pub extern fn tzset() void;
pub extern var daylight: c_int;
pub extern var timezone: c_long;
pub extern fn timegm(__tp: [*c]struct_tm) time_t;
pub extern fn timelocal(__tp: [*c]struct_tm) time_t;
pub extern fn dysize(__year: c_int) c_int;
pub extern fn nanosleep(__requested_time: [*c]const struct_timespec, __remaining: [*c]struct_timespec) c_int;
pub extern fn clock_getres(__clock_id: clockid_t, __res: [*c]struct_timespec) c_int;
pub extern fn clock_gettime(__clock_id: clockid_t, __tp: [*c]struct_timespec) c_int;
pub extern fn clock_settime(__clock_id: clockid_t, __tp: [*c]const struct_timespec) c_int;
pub extern fn clock_nanosleep(__clock_id: clockid_t, __flags: c_int, __req: [*c]const struct_timespec, __rem: [*c]struct_timespec) c_int;
pub extern fn clock_getcpuclockid(__pid: pid_t, __clock_id: [*c]clockid_t) c_int;
pub const struct_sigevent = opaque {};
pub extern fn timer_create(__clock_id: clockid_t, noalias __evp: ?*struct_sigevent, noalias __timerid: [*c]timer_t) c_int;
pub extern fn timer_delete(__timerid: timer_t) c_int;
pub extern fn timer_settime(__timerid: timer_t, __flags: c_int, noalias __value: [*c]const struct_itimerspec, noalias __ovalue: [*c]struct_itimerspec) c_int;
pub extern fn timer_gettime(__timerid: timer_t, __value: [*c]struct_itimerspec) c_int;
pub extern fn timer_getoverrun(__timerid: timer_t) c_int;
pub extern fn timespec_get(__ts: [*c]struct_timespec, __base: c_int) c_int;
pub const mbedtls_time_t = time_t;
pub const __gwchar_t = c_int;
pub const imaxdiv_t = extern struct {
    quot: c_long = 0,
    rem: c_long = 0,
};
pub extern fn imaxabs(__n: intmax_t) intmax_t;
pub extern fn imaxdiv(__numer: intmax_t, __denom: intmax_t) imaxdiv_t;
pub extern fn strtoimax(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) intmax_t;
pub extern fn strtoumax(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) uintmax_t;
pub extern fn wcstoimax(noalias __nptr: [*c]const __gwchar_t, noalias __endptr: [*c][*c]__gwchar_t, __base: c_int) intmax_t;
pub extern fn wcstoumax(noalias __nptr: [*c]const __gwchar_t, noalias __endptr: [*c][*c]__gwchar_t, __base: c_int) uintmax_t;
pub const mbedtls_ms_time_t = i64;
pub extern fn mbedtls_ms_time() mbedtls_ms_time_t;
pub extern fn mbedtls_platform_zeroize(buf: ?*anyopaque, len: usize) void;
pub const mbedtls_f_rng_t = fn (p_rng: ?*anyopaque, output: [*c]u8, output_size: usize) callconv(.c) c_int;
pub extern fn mbedtls_platform_gmtime_r(tt: [*c]const mbedtls_time_t, tm_buf: [*c]struct_tm) [*c]struct_tm;
pub const struct___va_list_tag_2 = extern struct {
    unnamed_0: c_uint = 0,
    unnamed_1: c_uint = 0,
    unnamed_2: ?*anyopaque = null,
    unnamed_3: ?*anyopaque = null,
};
pub const __builtin_va_list = [1]struct___va_list_tag_2;
pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
const union_unnamed_3 = extern union {
    __wch: c_uint,
    __wchb: [4]u8,
};
pub const __mbstate_t = extern struct {
    __count: c_int = 0,
    __value: union_unnamed_3 = @import("std").mem.zeroes(union_unnamed_3),
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
pub extern fn vfprintf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn vprintf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn vsprintf(noalias __s: [*c]u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn snprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vsnprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn vasprintf(noalias __ptr: [*c][*c]u8, noalias __f: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn __asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn vdprintf(__fd: c_int, noalias __fmt: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn dprintf(__fd: c_int, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn fscanf(noalias __stream: ?*FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn scanf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfscanf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn vscanf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
pub extern fn vsscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_2) c_int;
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
pub const mbedtls_mpi_sint = i64;
pub const mbedtls_mpi_uint = u64;
pub const mbedtls_t_udbl = c_uint;
pub const struct_mbedtls_mpi = extern struct {
    private_p: [*c]mbedtls_mpi_uint = null,
    private_s: c_short = 0,
    private_n: c_ushort = 0,
    pub const mbedtls_mpi_init = __root.mbedtls_mpi_init;
    pub const mbedtls_mpi_free = __root.mbedtls_mpi_free;
    pub const mbedtls_mpi_grow = __root.mbedtls_mpi_grow;
    pub const mbedtls_mpi_shrink = __root.mbedtls_mpi_shrink;
    pub const mbedtls_mpi_copy = __root.mbedtls_mpi_copy;
    pub const mbedtls_mpi_swap = __root.mbedtls_mpi_swap;
    pub const mbedtls_mpi_safe_cond_assign = __root.mbedtls_mpi_safe_cond_assign;
    pub const mbedtls_mpi_safe_cond_swap = __root.mbedtls_mpi_safe_cond_swap;
    pub const mbedtls_mpi_lset = __root.mbedtls_mpi_lset;
    pub const mbedtls_mpi_get_bit = __root.mbedtls_mpi_get_bit;
    pub const mbedtls_mpi_set_bit = __root.mbedtls_mpi_set_bit;
    pub const mbedtls_mpi_lsb = __root.mbedtls_mpi_lsb;
    pub const mbedtls_mpi_bitlen = __root.mbedtls_mpi_bitlen;
    pub const mbedtls_mpi_size = __root.mbedtls_mpi_size;
    pub const mbedtls_mpi_read_string = __root.mbedtls_mpi_read_string;
    pub const mbedtls_mpi_write_string = __root.mbedtls_mpi_write_string;
    pub const mbedtls_mpi_read_file = __root.mbedtls_mpi_read_file;
    pub const mbedtls_mpi_read_binary = __root.mbedtls_mpi_read_binary;
    pub const mbedtls_mpi_read_binary_le = __root.mbedtls_mpi_read_binary_le;
    pub const mbedtls_mpi_write_binary = __root.mbedtls_mpi_write_binary;
    pub const mbedtls_mpi_write_binary_le = __root.mbedtls_mpi_write_binary_le;
    pub const mbedtls_mpi_shift_l = __root.mbedtls_mpi_shift_l;
    pub const mbedtls_mpi_shift_r = __root.mbedtls_mpi_shift_r;
    pub const mbedtls_mpi_cmp_abs = __root.mbedtls_mpi_cmp_abs;
    pub const mbedtls_mpi_cmp_mpi = __root.mbedtls_mpi_cmp_mpi;
    pub const mbedtls_mpi_lt_mpi_ct = __root.mbedtls_mpi_lt_mpi_ct;
    pub const mbedtls_mpi_cmp_int = __root.mbedtls_mpi_cmp_int;
    pub const mbedtls_mpi_add_abs = __root.mbedtls_mpi_add_abs;
    pub const mbedtls_mpi_sub_abs = __root.mbedtls_mpi_sub_abs;
    pub const mbedtls_mpi_add_mpi = __root.mbedtls_mpi_add_mpi;
    pub const mbedtls_mpi_sub_mpi = __root.mbedtls_mpi_sub_mpi;
    pub const mbedtls_mpi_add_int = __root.mbedtls_mpi_add_int;
    pub const mbedtls_mpi_sub_int = __root.mbedtls_mpi_sub_int;
    pub const mbedtls_mpi_mul_mpi = __root.mbedtls_mpi_mul_mpi;
    pub const mbedtls_mpi_mul_int = __root.mbedtls_mpi_mul_int;
    pub const mbedtls_mpi_div_mpi = __root.mbedtls_mpi_div_mpi;
    pub const mbedtls_mpi_div_int = __root.mbedtls_mpi_div_int;
    pub const mbedtls_mpi_mod_mpi = __root.mbedtls_mpi_mod_mpi;
    pub const mbedtls_mpi_exp_mod = __root.mbedtls_mpi_exp_mod;
    pub const mbedtls_mpi_fill_random = __root.mbedtls_mpi_fill_random;
    pub const mbedtls_mpi_random = __root.mbedtls_mpi_random;
    pub const mbedtls_mpi_gcd = __root.mbedtls_mpi_gcd;
    pub const mbedtls_mpi_inv_mod = __root.mbedtls_mpi_inv_mod;
    pub const mbedtls_mpi_is_prime_ext = __root.mbedtls_mpi_is_prime_ext;
    pub const mbedtls_mpi_gen_prime = __root.mbedtls_mpi_gen_prime;
    pub const init = __root.mbedtls_mpi_init;
    pub const free = __root.mbedtls_mpi_free;
    pub const grow = __root.mbedtls_mpi_grow;
    pub const shrink = __root.mbedtls_mpi_shrink;
    pub const copy = __root.mbedtls_mpi_copy;
    pub const swap = __root.mbedtls_mpi_swap;
    pub const assign = __root.mbedtls_mpi_safe_cond_assign;
    pub const lset = __root.mbedtls_mpi_lset;
    pub const bit = __root.mbedtls_mpi_get_bit;
    pub const lsb = __root.mbedtls_mpi_lsb;
    pub const bitlen = __root.mbedtls_mpi_bitlen;
    pub const size = __root.mbedtls_mpi_size;
    pub const string = __root.mbedtls_mpi_read_string;
    pub const file = __root.mbedtls_mpi_read_file;
    pub const binary = __root.mbedtls_mpi_read_binary;
    pub const le = __root.mbedtls_mpi_read_binary_le;
    pub const l = __root.mbedtls_mpi_shift_l;
    pub const r = __root.mbedtls_mpi_shift_r;
    pub const abs = __root.mbedtls_mpi_cmp_abs;
    pub const mpi = __root.mbedtls_mpi_cmp_mpi;
    pub const ct = __root.mbedtls_mpi_lt_mpi_ct;
    pub const int = __root.mbedtls_mpi_cmp_int;
    pub const mod = __root.mbedtls_mpi_exp_mod;
    pub const random = __root.mbedtls_mpi_fill_random;
    pub const gcd = __root.mbedtls_mpi_gcd;
    pub const ext = __root.mbedtls_mpi_is_prime_ext;
    pub const prime = __root.mbedtls_mpi_gen_prime;
};
pub const mbedtls_mpi = struct_mbedtls_mpi;
pub extern fn mbedtls_mpi_init(X: [*c]mbedtls_mpi) void;
pub extern fn mbedtls_mpi_free(X: [*c]mbedtls_mpi) void;
pub extern fn mbedtls_mpi_grow(X: [*c]mbedtls_mpi, nblimbs: usize) c_int;
pub extern fn mbedtls_mpi_shrink(X: [*c]mbedtls_mpi, nblimbs: usize) c_int;
pub extern fn mbedtls_mpi_copy(X: [*c]mbedtls_mpi, Y: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_swap(X: [*c]mbedtls_mpi, Y: [*c]mbedtls_mpi) void;
pub extern fn mbedtls_mpi_safe_cond_assign(X: [*c]mbedtls_mpi, Y: [*c]const mbedtls_mpi, assign: u8) c_int;
pub extern fn mbedtls_mpi_safe_cond_swap(X: [*c]mbedtls_mpi, Y: [*c]mbedtls_mpi, swap: u8) c_int;
pub extern fn mbedtls_mpi_lset(X: [*c]mbedtls_mpi, z: mbedtls_mpi_sint) c_int;
pub extern fn mbedtls_mpi_get_bit(X: [*c]const mbedtls_mpi, pos: usize) c_int;
pub extern fn mbedtls_mpi_set_bit(X: [*c]mbedtls_mpi, pos: usize, val: u8) c_int;
pub extern fn mbedtls_mpi_lsb(X: [*c]const mbedtls_mpi) usize;
pub extern fn mbedtls_mpi_bitlen(X: [*c]const mbedtls_mpi) usize;
pub extern fn mbedtls_mpi_size(X: [*c]const mbedtls_mpi) usize;
pub extern fn mbedtls_mpi_read_string(X: [*c]mbedtls_mpi, radix: c_int, s: [*c]const u8) c_int;
pub extern fn mbedtls_mpi_write_string(X: [*c]const mbedtls_mpi, radix: c_int, buf: [*c]u8, buflen: usize, olen: [*c]usize) c_int;
pub extern fn mbedtls_mpi_read_file(X: [*c]mbedtls_mpi, radix: c_int, fin: ?*FILE) c_int;
pub extern fn mbedtls_mpi_write_file(p: [*c]const u8, X: [*c]const mbedtls_mpi, radix: c_int, fout: ?*FILE) c_int;
pub extern fn mbedtls_mpi_read_binary(X: [*c]mbedtls_mpi, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_mpi_read_binary_le(X: [*c]mbedtls_mpi, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_mpi_write_binary(X: [*c]const mbedtls_mpi, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_mpi_write_binary_le(X: [*c]const mbedtls_mpi, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_mpi_shift_l(X: [*c]mbedtls_mpi, count: usize) c_int;
pub extern fn mbedtls_mpi_shift_r(X: [*c]mbedtls_mpi, count: usize) c_int;
pub extern fn mbedtls_mpi_cmp_abs(X: [*c]const mbedtls_mpi, Y: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_cmp_mpi(X: [*c]const mbedtls_mpi, Y: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_lt_mpi_ct(X: [*c]const mbedtls_mpi, Y: [*c]const mbedtls_mpi, ret: [*c]c_uint) c_int;
pub extern fn mbedtls_mpi_cmp_int(X: [*c]const mbedtls_mpi, z: mbedtls_mpi_sint) c_int;
pub extern fn mbedtls_mpi_add_abs(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_sub_abs(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_add_mpi(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_sub_mpi(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_add_int(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, b: mbedtls_mpi_sint) c_int;
pub extern fn mbedtls_mpi_sub_int(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, b: mbedtls_mpi_sint) c_int;
pub extern fn mbedtls_mpi_mul_mpi(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_mul_int(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, b: mbedtls_mpi_uint) c_int;
pub extern fn mbedtls_mpi_div_mpi(Q: [*c]mbedtls_mpi, R: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_div_int(Q: [*c]mbedtls_mpi, R: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, b: mbedtls_mpi_sint) c_int;
pub extern fn mbedtls_mpi_mod_mpi(R: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_mod_int(r: [*c]mbedtls_mpi_uint, A: [*c]const mbedtls_mpi, b: mbedtls_mpi_sint) c_int;
pub extern fn mbedtls_mpi_exp_mod(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, E: [*c]const mbedtls_mpi, N: [*c]const mbedtls_mpi, prec_RR: [*c]mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_fill_random(X: [*c]mbedtls_mpi, size: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_mpi_random(X: [*c]mbedtls_mpi, min: mbedtls_mpi_sint, N: [*c]const mbedtls_mpi, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_mpi_gcd(G: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, B: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_inv_mod(X: [*c]mbedtls_mpi, A: [*c]const mbedtls_mpi, N: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_mpi_is_prime_ext(X: [*c]const mbedtls_mpi, rounds: c_int, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub const MBEDTLS_MPI_GEN_PRIME_FLAG_DH: c_int = 1;
pub const MBEDTLS_MPI_GEN_PRIME_FLAG_LOW_ERR: c_int = 2;
pub const mbedtls_mpi_gen_prime_flag_t = c_uint;
pub extern fn mbedtls_mpi_gen_prime(X: [*c]mbedtls_mpi, nbits: usize, flags: c_int, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_mpi_self_test(verbose: c_int) c_int;
pub const MBEDTLS_ECP_DP_NONE: c_int = 0;
pub const MBEDTLS_ECP_DP_SECP192R1: c_int = 1;
pub const MBEDTLS_ECP_DP_SECP224R1: c_int = 2;
pub const MBEDTLS_ECP_DP_SECP256R1: c_int = 3;
pub const MBEDTLS_ECP_DP_SECP384R1: c_int = 4;
pub const MBEDTLS_ECP_DP_SECP521R1: c_int = 5;
pub const MBEDTLS_ECP_DP_BP256R1: c_int = 6;
pub const MBEDTLS_ECP_DP_BP384R1: c_int = 7;
pub const MBEDTLS_ECP_DP_BP512R1: c_int = 8;
pub const MBEDTLS_ECP_DP_CURVE25519: c_int = 9;
pub const MBEDTLS_ECP_DP_SECP192K1: c_int = 10;
pub const MBEDTLS_ECP_DP_SECP224K1: c_int = 11;
pub const MBEDTLS_ECP_DP_SECP256K1: c_int = 12;
pub const MBEDTLS_ECP_DP_CURVE448: c_int = 13;
pub const mbedtls_ecp_group_id = c_uint;
pub const MBEDTLS_ECP_TYPE_NONE: c_int = 0;
pub const MBEDTLS_ECP_TYPE_SHORT_WEIERSTRASS: c_int = 1;
pub const MBEDTLS_ECP_TYPE_MONTGOMERY: c_int = 2;
pub const mbedtls_ecp_curve_type = c_uint;
pub const struct_mbedtls_ecp_curve_info = extern struct {
    grp_id: mbedtls_ecp_group_id = @import("std").mem.zeroes(mbedtls_ecp_group_id),
    tls_id: u16 = 0,
    bit_size: u16 = 0,
    name: [*c]const u8 = null,
};
pub const mbedtls_ecp_curve_info = struct_mbedtls_ecp_curve_info;
pub const struct_mbedtls_ecp_point = extern struct {
    private_X: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Y: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Z: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    pub const mbedtls_ecp_point_init = __root.mbedtls_ecp_point_init;
    pub const mbedtls_ecp_point_free = __root.mbedtls_ecp_point_free;
    pub const mbedtls_ecp_copy = __root.mbedtls_ecp_copy;
    pub const mbedtls_ecp_set_zero = __root.mbedtls_ecp_set_zero;
    pub const mbedtls_ecp_is_zero = __root.mbedtls_ecp_is_zero;
    pub const mbedtls_ecp_point_cmp = __root.mbedtls_ecp_point_cmp;
    pub const mbedtls_ecp_point_read_string = __root.mbedtls_ecp_point_read_string;
    pub const init = __root.mbedtls_ecp_point_init;
    pub const free = __root.mbedtls_ecp_point_free;
    pub const copy = __root.mbedtls_ecp_copy;
    pub const zero = __root.mbedtls_ecp_set_zero;
    pub const cmp = __root.mbedtls_ecp_point_cmp;
    pub const string = __root.mbedtls_ecp_point_read_string;
};
pub const mbedtls_ecp_point = struct_mbedtls_ecp_point;
pub const struct_mbedtls_ecp_group = extern struct {
    id: mbedtls_ecp_group_id = @import("std").mem.zeroes(mbedtls_ecp_group_id),
    P: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    A: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    B: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    G: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    N: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    pbits: usize = 0,
    nbits: usize = 0,
    private_h: c_uint = 0,
    private_modp: ?*const fn ([*c]mbedtls_mpi) callconv(.c) c_int = null,
    private_t_pre: ?*const fn ([*c]mbedtls_ecp_point, ?*anyopaque) callconv(.c) c_int = null,
    private_t_post: ?*const fn ([*c]mbedtls_ecp_point, ?*anyopaque) callconv(.c) c_int = null,
    private_t_data: ?*anyopaque = null,
    private_T: [*c]mbedtls_ecp_point = null,
    private_T_size: usize = 0,
    pub const mbedtls_ecp_get_type = __root.mbedtls_ecp_get_type;
    pub const mbedtls_ecp_group_init = __root.mbedtls_ecp_group_init;
    pub const mbedtls_ecp_group_free = __root.mbedtls_ecp_group_free;
    pub const mbedtls_ecp_group_copy = __root.mbedtls_ecp_group_copy;
    pub const mbedtls_ecp_point_write_binary = __root.mbedtls_ecp_point_write_binary;
    pub const mbedtls_ecp_point_read_binary = __root.mbedtls_ecp_point_read_binary;
    pub const mbedtls_ecp_tls_read_point = __root.mbedtls_ecp_tls_read_point;
    pub const mbedtls_ecp_tls_write_point = __root.mbedtls_ecp_tls_write_point;
    pub const mbedtls_ecp_group_load = __root.mbedtls_ecp_group_load;
    pub const mbedtls_ecp_tls_read_group = __root.mbedtls_ecp_tls_read_group;
    pub const mbedtls_ecp_tls_write_group = __root.mbedtls_ecp_tls_write_group;
    pub const mbedtls_ecp_mul = __root.mbedtls_ecp_mul;
    pub const mbedtls_ecp_mul_restartable = __root.mbedtls_ecp_mul_restartable;
    pub const mbedtls_ecp_group_a_is_minus_3 = __root.mbedtls_ecp_group_a_is_minus_3;
    pub const mbedtls_ecp_muladd = __root.mbedtls_ecp_muladd;
    pub const mbedtls_ecp_muladd_restartable = __root.mbedtls_ecp_muladd_restartable;
    pub const mbedtls_ecp_check_pubkey = __root.mbedtls_ecp_check_pubkey;
    pub const mbedtls_ecp_check_privkey = __root.mbedtls_ecp_check_privkey;
    pub const mbedtls_ecp_gen_privkey = __root.mbedtls_ecp_gen_privkey;
    pub const mbedtls_ecp_gen_keypair_base = __root.mbedtls_ecp_gen_keypair_base;
    pub const mbedtls_ecp_gen_keypair = __root.mbedtls_ecp_gen_keypair;
    pub const mbedtls_ecdsa_sign = __root.mbedtls_ecdsa_sign;
    pub const mbedtls_ecdsa_sign_det_ext = __root.mbedtls_ecdsa_sign_det_ext;
    pub const mbedtls_ecdsa_sign_restartable = __root.mbedtls_ecdsa_sign_restartable;
    pub const mbedtls_ecdsa_sign_det_restartable = __root.mbedtls_ecdsa_sign_det_restartable;
    pub const mbedtls_ecdsa_verify = __root.mbedtls_ecdsa_verify;
    pub const mbedtls_ecdsa_verify_restartable = __root.mbedtls_ecdsa_verify_restartable;
    pub const mbedtls_ecdh_gen_public = __root.mbedtls_ecdh_gen_public;
    pub const mbedtls_ecdh_compute_shared = __root.mbedtls_ecdh_compute_shared;
    pub const @"type" = __root.mbedtls_ecp_get_type;
    pub const init = __root.mbedtls_ecp_group_init;
    pub const free = __root.mbedtls_ecp_group_free;
    pub const copy = __root.mbedtls_ecp_group_copy;
    pub const binary = __root.mbedtls_ecp_point_write_binary;
    pub const point = __root.mbedtls_ecp_tls_read_point;
    pub const load = __root.mbedtls_ecp_group_load;
    pub const group = __root.mbedtls_ecp_tls_read_group;
    pub const mul = __root.mbedtls_ecp_mul;
    pub const restartable = __root.mbedtls_ecp_mul_restartable;
    pub const @"3" = __root.mbedtls_ecp_group_a_is_minus_3;
    pub const muladd = __root.mbedtls_ecp_muladd;
    pub const pubkey = __root.mbedtls_ecp_check_pubkey;
    pub const privkey = __root.mbedtls_ecp_check_privkey;
    pub const base = __root.mbedtls_ecp_gen_keypair_base;
    pub const keypair = __root.mbedtls_ecp_gen_keypair;
    pub const sign = __root.mbedtls_ecdsa_sign;
    pub const ext = __root.mbedtls_ecdsa_sign_det_ext;
    pub const verify = __root.mbedtls_ecdsa_verify;
    pub const public = __root.mbedtls_ecdh_gen_public;
    pub const shared = __root.mbedtls_ecdh_compute_shared;
};
pub const mbedtls_ecp_group = struct_mbedtls_ecp_group;
pub const mbedtls_ecp_restart_ctx = anyopaque;
pub const struct_mbedtls_ecp_keypair = extern struct {
    private_grp: mbedtls_ecp_group = @import("std").mem.zeroes(mbedtls_ecp_group),
    private_d: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Q: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    pub const mbedtls_ecp_keypair_init = __root.mbedtls_ecp_keypair_init;
    pub const mbedtls_ecp_keypair_free = __root.mbedtls_ecp_keypair_free;
    pub const mbedtls_ecp_write_key = __root.mbedtls_ecp_write_key;
    pub const mbedtls_ecp_write_key_ext = __root.mbedtls_ecp_write_key_ext;
    pub const mbedtls_ecp_write_public_key = __root.mbedtls_ecp_write_public_key;
    pub const mbedtls_ecp_check_pub_priv = __root.mbedtls_ecp_check_pub_priv;
    pub const mbedtls_ecp_keypair_calc_public = __root.mbedtls_ecp_keypair_calc_public;
    pub const mbedtls_ecp_keypair_get_group_id = __root.mbedtls_ecp_keypair_get_group_id;
    pub const mbedtls_ecp_export = __root.mbedtls_ecp_export;
    pub const mbedtls_ecdsa_write_signature = __root.mbedtls_ecdsa_write_signature;
    pub const mbedtls_ecdsa_write_signature_restartable = __root.mbedtls_ecdsa_write_signature_restartable;
    pub const mbedtls_ecdsa_read_signature = __root.mbedtls_ecdsa_read_signature;
    pub const mbedtls_ecdsa_read_signature_restartable = __root.mbedtls_ecdsa_read_signature_restartable;
    pub const mbedtls_ecdsa_genkey = __root.mbedtls_ecdsa_genkey;
    pub const mbedtls_ecdsa_from_keypair = __root.mbedtls_ecdsa_from_keypair;
    pub const mbedtls_ecdsa_init = __root.mbedtls_ecdsa_init;
    pub const mbedtls_ecdsa_free = __root.mbedtls_ecdsa_free;
    pub const init = __root.mbedtls_ecp_keypair_init;
    pub const free = __root.mbedtls_ecp_keypair_free;
    pub const key = __root.mbedtls_ecp_write_key;
    pub const ext = __root.mbedtls_ecp_write_key_ext;
    pub const priv = __root.mbedtls_ecp_check_pub_priv;
    pub const public = __root.mbedtls_ecp_keypair_calc_public;
    pub const id = __root.mbedtls_ecp_keypair_get_group_id;
    pub const @"export" = __root.mbedtls_ecp_export;
    pub const signature = __root.mbedtls_ecdsa_write_signature;
    pub const restartable = __root.mbedtls_ecdsa_write_signature_restartable;
    pub const genkey = __root.mbedtls_ecdsa_genkey;
    pub const keypair = __root.mbedtls_ecdsa_from_keypair;
};
pub const mbedtls_ecp_keypair = struct_mbedtls_ecp_keypair;
pub extern fn mbedtls_ecp_get_type(grp: [*c]const mbedtls_ecp_group) mbedtls_ecp_curve_type;
pub extern fn mbedtls_ecp_curve_list() [*c]const mbedtls_ecp_curve_info;
pub extern fn mbedtls_ecp_grp_id_list() [*c]const mbedtls_ecp_group_id;
pub extern fn mbedtls_ecp_curve_info_from_grp_id(grp_id: mbedtls_ecp_group_id) [*c]const mbedtls_ecp_curve_info;
pub extern fn mbedtls_ecp_curve_info_from_tls_id(tls_id: u16) [*c]const mbedtls_ecp_curve_info;
pub extern fn mbedtls_ecp_curve_info_from_name(name: [*c]const u8) [*c]const mbedtls_ecp_curve_info;
pub extern fn mbedtls_ecp_point_init(pt: [*c]mbedtls_ecp_point) void;
pub extern fn mbedtls_ecp_group_init(grp: [*c]mbedtls_ecp_group) void;
pub extern fn mbedtls_ecp_keypair_init(key: [*c]mbedtls_ecp_keypair) void;
pub extern fn mbedtls_ecp_point_free(pt: [*c]mbedtls_ecp_point) void;
pub extern fn mbedtls_ecp_group_free(grp: [*c]mbedtls_ecp_group) void;
pub extern fn mbedtls_ecp_keypair_free(key: [*c]mbedtls_ecp_keypair) void;
pub extern fn mbedtls_ecp_copy(P: [*c]mbedtls_ecp_point, Q: [*c]const mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_group_copy(dst: [*c]mbedtls_ecp_group, src: [*c]const mbedtls_ecp_group) c_int;
pub extern fn mbedtls_ecp_set_zero(pt: [*c]mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_is_zero(pt: [*c]mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_point_cmp(P: [*c]const mbedtls_ecp_point, Q: [*c]const mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_point_read_string(P: [*c]mbedtls_ecp_point, radix: c_int, x: [*c]const u8, y: [*c]const u8) c_int;
pub extern fn mbedtls_ecp_point_write_binary(grp: [*c]const mbedtls_ecp_group, P: [*c]const mbedtls_ecp_point, format: c_int, olen: [*c]usize, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_ecp_point_read_binary(grp: [*c]const mbedtls_ecp_group, P: [*c]mbedtls_ecp_point, buf: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_ecp_tls_read_point(grp: [*c]const mbedtls_ecp_group, pt: [*c]mbedtls_ecp_point, buf: [*c][*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ecp_tls_write_point(grp: [*c]const mbedtls_ecp_group, pt: [*c]const mbedtls_ecp_point, format: c_int, olen: [*c]usize, buf: [*c]u8, blen: usize) c_int;
pub extern fn mbedtls_ecp_group_load(grp: [*c]mbedtls_ecp_group, id: mbedtls_ecp_group_id) c_int;
pub extern fn mbedtls_ecp_tls_read_group(grp: [*c]mbedtls_ecp_group, buf: [*c][*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ecp_tls_read_group_id(grp: [*c]mbedtls_ecp_group_id, buf: [*c][*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ecp_tls_write_group(grp: [*c]const mbedtls_ecp_group, olen: [*c]usize, buf: [*c]u8, blen: usize) c_int;
pub extern fn mbedtls_ecp_mul(grp: [*c]mbedtls_ecp_group, R: [*c]mbedtls_ecp_point, m: [*c]const mbedtls_mpi, P: [*c]const mbedtls_ecp_point, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_mul_restartable(grp: [*c]mbedtls_ecp_group, R: [*c]mbedtls_ecp_point, m: [*c]const mbedtls_mpi, P: [*c]const mbedtls_ecp_point, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, rs_ctx: ?*mbedtls_ecp_restart_ctx) c_int;
pub fn mbedtls_ecp_group_a_is_minus_3(arg_grp: [*c]const mbedtls_ecp_group) callconv(.c) c_int {
    var grp = arg_grp;
    _ = &grp;
    return @intFromBool(@as(?*anyopaque, @ptrCast(@alignCast(grp.*.A.private_p))) == @as(?*anyopaque, null));
}
pub extern fn mbedtls_ecp_muladd(grp: [*c]mbedtls_ecp_group, R: [*c]mbedtls_ecp_point, m: [*c]const mbedtls_mpi, P: [*c]const mbedtls_ecp_point, n: [*c]const mbedtls_mpi, Q: [*c]const mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_muladd_restartable(grp: [*c]mbedtls_ecp_group, R: [*c]mbedtls_ecp_point, m: [*c]const mbedtls_mpi, P: [*c]const mbedtls_ecp_point, n: [*c]const mbedtls_mpi, Q: [*c]const mbedtls_ecp_point, rs_ctx: ?*mbedtls_ecp_restart_ctx) c_int;
pub extern fn mbedtls_ecp_check_pubkey(grp: [*c]const mbedtls_ecp_group, pt: [*c]const mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_check_privkey(grp: [*c]const mbedtls_ecp_group, d: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_ecp_gen_privkey(grp: [*c]const mbedtls_ecp_group, d: [*c]mbedtls_mpi, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_gen_keypair_base(grp: [*c]mbedtls_ecp_group, G: [*c]const mbedtls_ecp_point, d: [*c]mbedtls_mpi, Q: [*c]mbedtls_ecp_point, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_gen_keypair(grp: [*c]mbedtls_ecp_group, d: [*c]mbedtls_mpi, Q: [*c]mbedtls_ecp_point, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_gen_key(grp_id: mbedtls_ecp_group_id, key: [*c]mbedtls_ecp_keypair, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_set_public_key(grp_id: mbedtls_ecp_group_id, key: [*c]mbedtls_ecp_keypair, Q: [*c]const mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_read_key(grp_id: mbedtls_ecp_group_id, key: [*c]mbedtls_ecp_keypair, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_ecp_write_key(key: [*c]mbedtls_ecp_keypair, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_ecp_write_key_ext(key: [*c]const mbedtls_ecp_keypair, olen: [*c]usize, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_ecp_write_public_key(key: [*c]const mbedtls_ecp_keypair, format: c_int, olen: [*c]usize, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_ecp_check_pub_priv(@"pub": [*c]const mbedtls_ecp_keypair, prv: [*c]const mbedtls_ecp_keypair, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_keypair_calc_public(key: [*c]mbedtls_ecp_keypair, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecp_keypair_get_group_id(key: [*c]const mbedtls_ecp_keypair) mbedtls_ecp_group_id;
pub extern fn mbedtls_ecp_export(key: [*c]const mbedtls_ecp_keypair, grp: [*c]mbedtls_ecp_group, d: [*c]mbedtls_mpi, Q: [*c]mbedtls_ecp_point) c_int;
pub extern fn mbedtls_ecp_self_test(verbose: c_int) c_int;
pub const MBEDTLS_MD_NONE: c_int = 0;
pub const MBEDTLS_MD_MD5: c_int = 3;
pub const MBEDTLS_MD_RIPEMD160: c_int = 4;
pub const MBEDTLS_MD_SHA1: c_int = 5;
pub const MBEDTLS_MD_SHA224: c_int = 8;
pub const MBEDTLS_MD_SHA256: c_int = 9;
pub const MBEDTLS_MD_SHA384: c_int = 10;
pub const MBEDTLS_MD_SHA512: c_int = 11;
pub const MBEDTLS_MD_SHA3_224: c_int = 16;
pub const MBEDTLS_MD_SHA3_256: c_int = 17;
pub const MBEDTLS_MD_SHA3_384: c_int = 18;
pub const MBEDTLS_MD_SHA3_512: c_int = 19;
pub const mbedtls_md_type_t = c_uint;
pub const struct_mbedtls_md_info_t = opaque {
    pub const mbedtls_md_get_size = __root.mbedtls_md_get_size;
    pub const mbedtls_md_get_type = __root.mbedtls_md_get_type;
    pub const mbedtls_md = __root.mbedtls_md;
    pub const mbedtls_md_get_name = __root.mbedtls_md_get_name;
    pub const mbedtls_md_file = __root.mbedtls_md_file;
    pub const mbedtls_md_hmac = __root.mbedtls_md_hmac;
    pub const size = __root.mbedtls_md_get_size;
    pub const @"type" = __root.mbedtls_md_get_type;
    pub const md = __root.mbedtls_md;
    pub const name = __root.mbedtls_md_get_name;
    pub const file = __root.mbedtls_md_file;
    pub const hmac = __root.mbedtls_md_hmac;
};
pub const mbedtls_md_info_t = struct_mbedtls_md_info_t;
pub const MBEDTLS_MD_ENGINE_LEGACY: c_int = 0;
pub const MBEDTLS_MD_ENGINE_PSA: c_int = 1;
pub const mbedtls_md_engine_t = c_uint;
pub const struct_mbedtls_md_context_t = extern struct {
    private_md_info: ?*const mbedtls_md_info_t = null,
    private_md_ctx: ?*anyopaque = null,
    private_hmac_ctx: ?*anyopaque = null,
    pub const mbedtls_md_init = __root.mbedtls_md_init;
    pub const mbedtls_md_free = __root.mbedtls_md_free;
    pub const mbedtls_md_setup = __root.mbedtls_md_setup;
    pub const mbedtls_md_clone = __root.mbedtls_md_clone;
    pub const mbedtls_md_starts = __root.mbedtls_md_starts;
    pub const mbedtls_md_update = __root.mbedtls_md_update;
    pub const mbedtls_md_finish = __root.mbedtls_md_finish;
    pub const mbedtls_md_info_from_ctx = __root.mbedtls_md_info_from_ctx;
    pub const mbedtls_md_hmac_starts = __root.mbedtls_md_hmac_starts;
    pub const mbedtls_md_hmac_update = __root.mbedtls_md_hmac_update;
    pub const mbedtls_md_hmac_finish = __root.mbedtls_md_hmac_finish;
    pub const mbedtls_md_hmac_reset = __root.mbedtls_md_hmac_reset;
    pub const init = __root.mbedtls_md_init;
    pub const free = __root.mbedtls_md_free;
    pub const setup = __root.mbedtls_md_setup;
    pub const clone = __root.mbedtls_md_clone;
    pub const starts = __root.mbedtls_md_starts;
    pub const update = __root.mbedtls_md_update;
    pub const finish = __root.mbedtls_md_finish;
    pub const ctx = __root.mbedtls_md_info_from_ctx;
    pub const reset = __root.mbedtls_md_hmac_reset;
};
pub const mbedtls_md_context_t = struct_mbedtls_md_context_t;
pub extern fn mbedtls_md_info_from_type(md_type: mbedtls_md_type_t) ?*const mbedtls_md_info_t;
pub extern fn mbedtls_md_init(ctx: [*c]mbedtls_md_context_t) void;
pub extern fn mbedtls_md_free(ctx: [*c]mbedtls_md_context_t) void;
pub extern fn mbedtls_md_setup(ctx: [*c]mbedtls_md_context_t, md_info: ?*const mbedtls_md_info_t, hmac: c_int) c_int;
pub extern fn mbedtls_md_clone(dst: [*c]mbedtls_md_context_t, src: [*c]const mbedtls_md_context_t) c_int;
pub extern fn mbedtls_md_get_size(md_info: ?*const mbedtls_md_info_t) u8;
pub fn mbedtls_md_get_size_from_type(arg_md_type: mbedtls_md_type_t) callconv(.c) u8 {
    var md_type = arg_md_type;
    _ = &md_type;
    return mbedtls_md_get_size(mbedtls_md_info_from_type(md_type));
}
pub extern fn mbedtls_md_get_type(md_info: ?*const mbedtls_md_info_t) mbedtls_md_type_t;
pub extern fn mbedtls_md_starts(ctx: [*c]mbedtls_md_context_t) c_int;
pub extern fn mbedtls_md_update(ctx: [*c]mbedtls_md_context_t, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_md_finish(ctx: [*c]mbedtls_md_context_t, output: [*c]u8) c_int;
pub extern fn mbedtls_md(md_info: ?*const mbedtls_md_info_t, input: [*c]const u8, ilen: usize, output: [*c]u8) c_int;
pub extern fn mbedtls_md_list() [*c]const c_int;
pub extern fn mbedtls_md_info_from_string(md_name: [*c]const u8) ?*const mbedtls_md_info_t;
pub extern fn mbedtls_md_get_name(md_info: ?*const mbedtls_md_info_t) [*c]const u8;
pub extern fn mbedtls_md_info_from_ctx(ctx: [*c]const mbedtls_md_context_t) ?*const mbedtls_md_info_t;
pub extern fn mbedtls_md_file(md_info: ?*const mbedtls_md_info_t, path: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_md_hmac_starts(ctx: [*c]mbedtls_md_context_t, key: [*c]const u8, keylen: usize) c_int;
pub extern fn mbedtls_md_hmac_update(ctx: [*c]mbedtls_md_context_t, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_md_hmac_finish(ctx: [*c]mbedtls_md_context_t, output: [*c]u8) c_int;
pub extern fn mbedtls_md_hmac_reset(ctx: [*c]mbedtls_md_context_t) c_int;
pub extern fn mbedtls_md_hmac(md_info: ?*const mbedtls_md_info_t, key: [*c]const u8, keylen: usize, input: [*c]const u8, ilen: usize, output: [*c]u8) c_int;
pub const div_t = extern struct {
    quot: c_int = 0,
    rem: c_int = 0,
};
pub const ldiv_t = extern struct {
    quot: c_long = 0,
    rem: c_long = 0,
};
pub const lldiv_t = extern struct {
    quot: c_longlong = 0,
    rem: c_longlong = 0,
};
pub extern fn __ctype_get_mb_cur_max() usize;
pub extern fn atof(__nptr: [*c]const u8) f64;
pub extern fn atoi(__nptr: [*c]const u8) c_int;
pub extern fn atol(__nptr: [*c]const u8) c_long;
pub extern fn atoll(__nptr: [*c]const u8) c_longlong;
pub extern fn strtod(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8) f64;
pub extern fn strtof(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8) f32;
pub extern fn strtold(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8) c_longdouble;
pub extern fn strtol(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_long;
pub extern fn strtoul(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_ulong;
pub extern fn strtoq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtouq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn strtoll(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtoull(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn l64a(__n: c_long) [*c]u8;
pub extern fn a64l(__s: [*c]const u8) c_long;
pub const u_char = __u_char;
pub const u_short = __u_short;
pub const u_int = __u_int;
pub const u_long = __u_long;
pub const quad_t = __quad_t;
pub const u_quad_t = __u_quad_t;
pub const fsid_t = __fsid_t;
pub const loff_t = __loff_t;
pub const ino_t = __ino_t;
pub const dev_t = __dev_t;
pub const gid_t = __gid_t;
pub const mode_t = __mode_t;
pub const nlink_t = __nlink_t;
pub const uid_t = __uid_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const ulong = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_int8_t = __uint8_t;
pub const u_int16_t = __uint16_t;
pub const u_int32_t = __uint32_t;
pub const u_int64_t = __uint64_t;
pub const register_t = c_int;
pub fn __bswap_16(arg___bsx: __uint16_t) callconv(.c) __uint16_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @byteSwap(@as(__uint16_t, __bsx));
}
pub fn __bswap_32(arg___bsx: __uint32_t) callconv(.c) __uint32_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @bitCast(@as(c_int, @byteSwap(@as(c_int, @bitCast(@as(c_uint, @truncate(__bsx)))))));
}
pub fn __bswap_64(arg___bsx: __uint64_t) callconv(.c) __uint64_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @bitCast(@as(c_long, @byteSwap(@as(c_long, @bitCast(@as(c_ulong, @truncate(__bsx)))))));
}
pub fn __uint16_identity(arg___x: __uint16_t) callconv(.c) __uint16_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub fn __uint32_identity(arg___x: __uint32_t) callconv(.c) __uint32_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub fn __uint64_identity(arg___x: __uint64_t) callconv(.c) __uint64_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub const __sigset_t = extern struct {
    __val: [16]c_ulong = @import("std").mem.zeroes([16]c_ulong),
};
pub const sigset_t = __sigset_t;
pub const struct_timeval = extern struct {
    tv_sec: __time_t = 0,
    tv_usec: __suseconds_t = 0,
};
pub const suseconds_t = __suseconds_t;
pub const __fd_mask = c_long;
pub const fd_set = extern struct {
    __fds_bits: [16]__fd_mask = @import("std").mem.zeroes([16]__fd_mask),
};
pub const fd_mask = __fd_mask;
pub extern fn select(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]struct_timeval) c_int;
pub extern fn pselect(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]const struct_timespec, noalias __sigmask: [*c]const __sigset_t) c_int;
pub const blksize_t = __blksize_t;
pub const blkcnt_t = __blkcnt_t;
pub const fsblkcnt_t = __fsblkcnt_t;
pub const fsfilcnt_t = __fsfilcnt_t;
const struct_unnamed_4 = extern struct {
    __low: c_uint = 0,
    __high: c_uint = 0,
};
pub const __atomic_wide_counter = extern union {
    __value64: c_ulonglong,
    __value32: struct_unnamed_4,
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
    pub const pthread_mutexattr_init = __root.pthread_mutexattr_init;
    pub const pthread_mutexattr_destroy = __root.pthread_mutexattr_destroy;
    pub const pthread_mutexattr_getpshared = __root.pthread_mutexattr_getpshared;
    pub const pthread_mutexattr_setpshared = __root.pthread_mutexattr_setpshared;
    pub const pthread_mutexattr_gettype = __root.pthread_mutexattr_gettype;
    pub const pthread_mutexattr_settype = __root.pthread_mutexattr_settype;
    pub const pthread_mutexattr_getprotocol = __root.pthread_mutexattr_getprotocol;
    pub const pthread_mutexattr_setprotocol = __root.pthread_mutexattr_setprotocol;
    pub const pthread_mutexattr_getprioceiling = __root.pthread_mutexattr_getprioceiling;
    pub const pthread_mutexattr_setprioceiling = __root.pthread_mutexattr_setprioceiling;
    pub const pthread_mutexattr_getrobust = __root.pthread_mutexattr_getrobust;
    pub const pthread_mutexattr_setrobust = __root.pthread_mutexattr_setrobust;
    pub const init = __root.pthread_mutexattr_init;
    pub const destroy = __root.pthread_mutexattr_destroy;
    pub const getpshared = __root.pthread_mutexattr_getpshared;
    pub const setpshared = __root.pthread_mutexattr_setpshared;
    pub const gettype = __root.pthread_mutexattr_gettype;
    pub const settype = __root.pthread_mutexattr_settype;
    pub const getprotocol = __root.pthread_mutexattr_getprotocol;
    pub const setprotocol = __root.pthread_mutexattr_setprotocol;
    pub const getprioceiling = __root.pthread_mutexattr_getprioceiling;
    pub const setprioceiling = __root.pthread_mutexattr_setprioceiling;
    pub const getrobust = __root.pthread_mutexattr_getrobust;
    pub const setrobust = __root.pthread_mutexattr_setrobust;
};
pub const pthread_condattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
    pub const pthread_condattr_init = __root.pthread_condattr_init;
    pub const pthread_condattr_destroy = __root.pthread_condattr_destroy;
    pub const pthread_condattr_getpshared = __root.pthread_condattr_getpshared;
    pub const pthread_condattr_setpshared = __root.pthread_condattr_setpshared;
    pub const pthread_condattr_getclock = __root.pthread_condattr_getclock;
    pub const pthread_condattr_setclock = __root.pthread_condattr_setclock;
    pub const init = __root.pthread_condattr_init;
    pub const destroy = __root.pthread_condattr_destroy;
    pub const getpshared = __root.pthread_condattr_getpshared;
    pub const setpshared = __root.pthread_condattr_setpshared;
    pub const getclock = __root.pthread_condattr_getclock;
    pub const setclock = __root.pthread_condattr_setclock;
};
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
    pub const pthread_attr_init = __root.pthread_attr_init;
    pub const pthread_attr_destroy = __root.pthread_attr_destroy;
    pub const pthread_attr_getdetachstate = __root.pthread_attr_getdetachstate;
    pub const pthread_attr_setdetachstate = __root.pthread_attr_setdetachstate;
    pub const pthread_attr_getguardsize = __root.pthread_attr_getguardsize;
    pub const pthread_attr_setguardsize = __root.pthread_attr_setguardsize;
    pub const pthread_attr_getschedparam = __root.pthread_attr_getschedparam;
    pub const pthread_attr_setschedparam = __root.pthread_attr_setschedparam;
    pub const pthread_attr_getschedpolicy = __root.pthread_attr_getschedpolicy;
    pub const pthread_attr_setschedpolicy = __root.pthread_attr_setschedpolicy;
    pub const pthread_attr_getinheritsched = __root.pthread_attr_getinheritsched;
    pub const pthread_attr_setinheritsched = __root.pthread_attr_setinheritsched;
    pub const pthread_attr_getscope = __root.pthread_attr_getscope;
    pub const pthread_attr_setscope = __root.pthread_attr_setscope;
    pub const pthread_attr_getstackaddr = __root.pthread_attr_getstackaddr;
    pub const pthread_attr_setstackaddr = __root.pthread_attr_setstackaddr;
    pub const pthread_attr_getstacksize = __root.pthread_attr_getstacksize;
    pub const pthread_attr_setstacksize = __root.pthread_attr_setstacksize;
    pub const pthread_attr_getstack = __root.pthread_attr_getstack;
    pub const pthread_attr_setstack = __root.pthread_attr_setstack;
    pub const init = __root.pthread_attr_init;
    pub const destroy = __root.pthread_attr_destroy;
    pub const getdetachstate = __root.pthread_attr_getdetachstate;
    pub const setdetachstate = __root.pthread_attr_setdetachstate;
    pub const getguardsize = __root.pthread_attr_getguardsize;
    pub const setguardsize = __root.pthread_attr_setguardsize;
    pub const getschedparam = __root.pthread_attr_getschedparam;
    pub const setschedparam = __root.pthread_attr_setschedparam;
    pub const getschedpolicy = __root.pthread_attr_getschedpolicy;
    pub const setschedpolicy = __root.pthread_attr_setschedpolicy;
    pub const getinheritsched = __root.pthread_attr_getinheritsched;
    pub const setinheritsched = __root.pthread_attr_setinheritsched;
    pub const getscope = __root.pthread_attr_getscope;
    pub const setscope = __root.pthread_attr_setscope;
    pub const getstackaddr = __root.pthread_attr_getstackaddr;
    pub const setstackaddr = __root.pthread_attr_setstackaddr;
    pub const getstacksize = __root.pthread_attr_getstacksize;
    pub const setstacksize = __root.pthread_attr_setstacksize;
    pub const getstack = __root.pthread_attr_getstack;
    pub const setstack = __root.pthread_attr_setstack;
};
pub const pthread_attr_t = union_pthread_attr_t;
pub const pthread_mutex_t = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
    pub const pthread_mutex_init = __root.pthread_mutex_init;
    pub const pthread_mutex_destroy = __root.pthread_mutex_destroy;
    pub const pthread_mutex_trylock = __root.pthread_mutex_trylock;
    pub const pthread_mutex_lock = __root.pthread_mutex_lock;
    pub const pthread_mutex_timedlock = __root.pthread_mutex_timedlock;
    pub const pthread_mutex_unlock = __root.pthread_mutex_unlock;
    pub const pthread_mutex_getprioceiling = __root.pthread_mutex_getprioceiling;
    pub const pthread_mutex_setprioceiling = __root.pthread_mutex_setprioceiling;
    pub const pthread_mutex_consistent = __root.pthread_mutex_consistent;
    pub const init = __root.pthread_mutex_init;
    pub const destroy = __root.pthread_mutex_destroy;
    pub const trylock = __root.pthread_mutex_trylock;
    pub const lock = __root.pthread_mutex_lock;
    pub const timedlock = __root.pthread_mutex_timedlock;
    pub const unlock = __root.pthread_mutex_unlock;
    pub const getprioceiling = __root.pthread_mutex_getprioceiling;
    pub const setprioceiling = __root.pthread_mutex_setprioceiling;
    pub const consistent = __root.pthread_mutex_consistent;
};
pub const pthread_cond_t = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
    pub const pthread_cond_init = __root.pthread_cond_init;
    pub const pthread_cond_destroy = __root.pthread_cond_destroy;
    pub const pthread_cond_signal = __root.pthread_cond_signal;
    pub const pthread_cond_broadcast = __root.pthread_cond_broadcast;
    pub const pthread_cond_wait = __root.pthread_cond_wait;
    pub const pthread_cond_timedwait = __root.pthread_cond_timedwait;
    pub const init = __root.pthread_cond_init;
    pub const destroy = __root.pthread_cond_destroy;
    pub const signal = __root.pthread_cond_signal;
    pub const broadcast = __root.pthread_cond_broadcast;
    pub const wait = __root.pthread_cond_wait;
    pub const timedwait = __root.pthread_cond_timedwait;
};
pub const pthread_rwlock_t = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
    pub const pthread_rwlock_init = __root.pthread_rwlock_init;
    pub const pthread_rwlock_destroy = __root.pthread_rwlock_destroy;
    pub const pthread_rwlock_rdlock = __root.pthread_rwlock_rdlock;
    pub const pthread_rwlock_tryrdlock = __root.pthread_rwlock_tryrdlock;
    pub const pthread_rwlock_timedrdlock = __root.pthread_rwlock_timedrdlock;
    pub const pthread_rwlock_wrlock = __root.pthread_rwlock_wrlock;
    pub const pthread_rwlock_trywrlock = __root.pthread_rwlock_trywrlock;
    pub const pthread_rwlock_timedwrlock = __root.pthread_rwlock_timedwrlock;
    pub const pthread_rwlock_unlock = __root.pthread_rwlock_unlock;
    pub const init = __root.pthread_rwlock_init;
    pub const destroy = __root.pthread_rwlock_destroy;
    pub const rdlock = __root.pthread_rwlock_rdlock;
    pub const tryrdlock = __root.pthread_rwlock_tryrdlock;
    pub const timedrdlock = __root.pthread_rwlock_timedrdlock;
    pub const wrlock = __root.pthread_rwlock_wrlock;
    pub const trywrlock = __root.pthread_rwlock_trywrlock;
    pub const timedwrlock = __root.pthread_rwlock_timedwrlock;
    pub const unlock = __root.pthread_rwlock_unlock;
};
pub const pthread_rwlockattr_t = extern union {
    __size: [8]u8,
    __align: c_long,
    pub const pthread_rwlockattr_init = __root.pthread_rwlockattr_init;
    pub const pthread_rwlockattr_destroy = __root.pthread_rwlockattr_destroy;
    pub const pthread_rwlockattr_getpshared = __root.pthread_rwlockattr_getpshared;
    pub const pthread_rwlockattr_setpshared = __root.pthread_rwlockattr_setpshared;
    pub const pthread_rwlockattr_getkind_np = __root.pthread_rwlockattr_getkind_np;
    pub const pthread_rwlockattr_setkind_np = __root.pthread_rwlockattr_setkind_np;
    pub const init = __root.pthread_rwlockattr_init;
    pub const destroy = __root.pthread_rwlockattr_destroy;
    pub const getpshared = __root.pthread_rwlockattr_getpshared;
    pub const setpshared = __root.pthread_rwlockattr_setpshared;
    pub const np = __root.pthread_rwlockattr_getkind_np;
};
pub const pthread_spinlock_t = c_int;
pub const pthread_barrier_t = extern union {
    __size: [32]u8,
    __align: c_long,
    pub const pthread_barrier_init = __root.pthread_barrier_init;
    pub const pthread_barrier_destroy = __root.pthread_barrier_destroy;
    pub const pthread_barrier_wait = __root.pthread_barrier_wait;
    pub const init = __root.pthread_barrier_init;
    pub const destroy = __root.pthread_barrier_destroy;
    pub const wait = __root.pthread_barrier_wait;
};
pub const pthread_barrierattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
    pub const pthread_barrierattr_init = __root.pthread_barrierattr_init;
    pub const pthread_barrierattr_destroy = __root.pthread_barrierattr_destroy;
    pub const pthread_barrierattr_getpshared = __root.pthread_barrierattr_getpshared;
    pub const pthread_barrierattr_setpshared = __root.pthread_barrierattr_setpshared;
    pub const init = __root.pthread_barrierattr_init;
    pub const destroy = __root.pthread_barrierattr_destroy;
    pub const getpshared = __root.pthread_barrierattr_getpshared;
    pub const setpshared = __root.pthread_barrierattr_setpshared;
};
pub extern fn random() c_long;
pub extern fn srandom(__seed: c_uint) void;
pub extern fn initstate(__seed: c_uint, __statebuf: [*c]u8, __statelen: usize) [*c]u8;
pub extern fn setstate(__statebuf: [*c]u8) [*c]u8;
pub const struct_random_data = extern struct {
    fptr: [*c]i32 = null,
    rptr: [*c]i32 = null,
    state: [*c]i32 = null,
    rand_type: c_int = 0,
    rand_deg: c_int = 0,
    rand_sep: c_int = 0,
    end_ptr: [*c]i32 = null,
    pub const random_r = __root.random_r;
    pub const r = __root.random_r;
};
pub extern fn random_r(noalias __buf: [*c]struct_random_data, noalias __result: [*c]i32) c_int;
pub extern fn srandom_r(__seed: c_uint, __buf: [*c]struct_random_data) c_int;
pub extern fn initstate_r(__seed: c_uint, noalias __statebuf: [*c]u8, __statelen: usize, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn setstate_r(noalias __statebuf: [*c]u8, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn rand() c_int;
pub extern fn srand(__seed: c_uint) void;
pub extern fn rand_r(__seed: [*c]c_uint) c_int;
pub extern fn drand48() f64;
pub extern fn erand48(__xsubi: [*c]c_ushort) f64;
pub extern fn lrand48() c_long;
pub extern fn nrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn mrand48() c_long;
pub extern fn jrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn srand48(__seedval: c_long) void;
pub extern fn seed48(__seed16v: [*c]c_ushort) [*c]c_ushort;
pub extern fn lcong48(__param: [*c]c_ushort) void;
pub const struct_drand48_data = extern struct {
    __x: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
    __old_x: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
    __c: c_ushort = 0,
    __init: c_ushort = 0,
    __a: c_ulonglong = 0,
    pub const drand48_r = __root.drand48_r;
    pub const lrand48_r = __root.lrand48_r;
    pub const mrand48_r = __root.mrand48_r;
    pub const r = __root.drand48_r;
};
pub extern fn drand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn erand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn lrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn nrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn mrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn jrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn srand48_r(__seedval: c_long, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn seed48_r(__seed16v: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn lcong48_r(__param: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn arc4random() __uint32_t;
pub extern fn arc4random_buf(__buf: ?*anyopaque, __size: usize) void;
pub extern fn arc4random_uniform(__upper_bound: __uint32_t) __uint32_t;
pub extern fn malloc(__size: usize) ?*anyopaque;
pub extern fn calloc(__nmemb: usize, __size: usize) ?*anyopaque;
pub extern fn realloc(__ptr: ?*anyopaque, __size: usize) ?*anyopaque;
pub extern fn free(__ptr: ?*anyopaque) void;
pub extern fn reallocarray(__ptr: ?*anyopaque, __nmemb: usize, __size: usize) ?*anyopaque;
pub extern fn alloca(__size: usize) ?*anyopaque;
pub extern fn valloc(__size: usize) ?*anyopaque;
pub extern fn posix_memalign(__memptr: [*c]?*anyopaque, __alignment: usize, __size: usize) c_int;
pub extern fn aligned_alloc(__alignment: usize, __size: usize) ?*anyopaque;
pub extern fn abort() noreturn;
pub extern fn atexit(__func: ?*const fn () callconv(.c) void) c_int;
pub extern fn at_quick_exit(__func: ?*const fn () callconv(.c) void) c_int;
pub extern fn on_exit(__func: ?*const fn (__status: c_int, __arg: ?*anyopaque) callconv(.c) void, __arg: ?*anyopaque) c_int;
pub extern fn exit(__status: c_int) noreturn;
pub extern fn quick_exit(__status: c_int) noreturn;
pub extern fn _Exit(__status: c_int) noreturn;
pub extern fn getenv(__name: [*c]const u8) [*c]u8;
pub extern fn putenv(__string: [*c]u8) c_int;
pub extern fn setenv(__name: [*c]const u8, __value: [*c]const u8, __replace: c_int) c_int;
pub extern fn unsetenv(__name: [*c]const u8) c_int;
pub extern fn clearenv() c_int;
pub extern fn mktemp(__template: [*c]u8) [*c]u8;
pub extern fn mkstemp(__template: [*c]u8) c_int;
pub extern fn mkstemps(__template: [*c]u8, __suffixlen: c_int) c_int;
pub extern fn mkdtemp(__template: [*c]u8) [*c]u8;
pub extern fn system(__command: [*c]const u8) c_int;
pub extern fn realpath(noalias __name: [*c]const u8, noalias __resolved: [*c]u8) [*c]u8;
pub const __compar_fn_t = ?*const fn (?*const anyopaque, ?*const anyopaque) callconv(.c) c_int;
pub extern fn bsearch(__key: ?*const anyopaque, __base: ?*const anyopaque, __nmemb: usize, __size: usize, __compar: __compar_fn_t) ?*anyopaque;
pub extern fn qsort(__base: ?*anyopaque, __nmemb: usize, __size: usize, __compar: __compar_fn_t) void;
pub extern fn abs(__x: c_int) c_int;
pub extern fn labs(__x: c_long) c_long;
pub extern fn llabs(__x: c_longlong) c_longlong;
pub extern fn div(__numer: c_int, __denom: c_int) div_t;
pub extern fn ldiv(__numer: c_long, __denom: c_long) ldiv_t;
pub extern fn lldiv(__numer: c_longlong, __denom: c_longlong) lldiv_t;
pub extern fn ecvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn fcvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn gcvt(__value: f64, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn qecvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qfcvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qgcvt(__value: c_longdouble, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn ecvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn fcvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qecvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qfcvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn mblen(__s: [*c]const u8, __n: usize) c_int;
pub extern fn mbtowc(noalias __pwc: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) c_int;
pub extern fn wctomb(__s: [*c]u8, __wchar: wchar_t) c_int;
pub extern fn mbstowcs(noalias __pwcs: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) usize;
pub extern fn wcstombs(noalias __s: [*c]u8, noalias __pwcs: [*c]const wchar_t, __n: usize) usize;
pub extern fn rpmatch(__response: [*c]const u8) c_int;
pub extern fn getsubopt(noalias __optionp: [*c][*c]u8, noalias __tokens: [*c]const [*c]u8, noalias __valuep: [*c][*c]u8) c_int;
pub extern fn getloadavg(__loadavg: [*c]f64, __nelem: c_int) c_int;
pub const struct_sched_param = extern struct {
    sched_priority: c_int = 0,
};
pub const __cpu_mask = c_ulong;
pub const cpu_set_t = extern struct {
    __bits: [16]__cpu_mask = @import("std").mem.zeroes([16]__cpu_mask),
    pub const __sched_cpufree = __root.__sched_cpufree;
    pub const cpufree = __root.__sched_cpufree;
};
pub extern fn __sched_cpucount(__setsize: usize, __setp: [*c]const cpu_set_t) c_int;
pub extern fn __sched_cpualloc(__count: usize) [*c]cpu_set_t;
pub extern fn __sched_cpufree(__set: [*c]cpu_set_t) void;
pub extern fn sched_setparam(__pid: __pid_t, __param: [*c]const struct_sched_param) c_int;
pub extern fn sched_getparam(__pid: __pid_t, __param: [*c]struct_sched_param) c_int;
pub extern fn sched_setscheduler(__pid: __pid_t, __policy: c_int, __param: [*c]const struct_sched_param) c_int;
pub extern fn sched_getscheduler(__pid: __pid_t) c_int;
pub extern fn sched_yield() c_int;
pub extern fn sched_get_priority_max(__algorithm: c_int) c_int;
pub extern fn sched_get_priority_min(__algorithm: c_int) c_int;
pub extern fn sched_rr_get_interval(__pid: __pid_t, __t: [*c]struct_timespec) c_int;
pub const __jmp_buf = [8]c_long;
pub const struct___jmp_buf_tag = extern struct {
    __jmpbuf: __jmp_buf = @import("std").mem.zeroes(__jmp_buf),
    __mask_was_saved: c_int = 0,
    __saved_mask: __sigset_t = @import("std").mem.zeroes(__sigset_t),
    pub const __sigsetjmp = __root.__sigsetjmp;
    pub const sigsetjmp = __root.__sigsetjmp;
};
pub const PTHREAD_CREATE_JOINABLE: c_int = 0;
pub const PTHREAD_CREATE_DETACHED: c_int = 1;
const enum_unnamed_5 = c_uint;
pub const PTHREAD_MUTEX_TIMED_NP: c_int = 0;
pub const PTHREAD_MUTEX_RECURSIVE_NP: c_int = 1;
pub const PTHREAD_MUTEX_ERRORCHECK_NP: c_int = 2;
pub const PTHREAD_MUTEX_ADAPTIVE_NP: c_int = 3;
pub const PTHREAD_MUTEX_NORMAL: c_int = 0;
pub const PTHREAD_MUTEX_RECURSIVE: c_int = 1;
pub const PTHREAD_MUTEX_ERRORCHECK: c_int = 2;
pub const PTHREAD_MUTEX_DEFAULT: c_int = 0;
const enum_unnamed_6 = c_uint;
pub const PTHREAD_MUTEX_STALLED: c_int = 0;
pub const PTHREAD_MUTEX_STALLED_NP: c_int = 0;
pub const PTHREAD_MUTEX_ROBUST: c_int = 1;
pub const PTHREAD_MUTEX_ROBUST_NP: c_int = 1;
const enum_unnamed_7 = c_uint;
pub const PTHREAD_PRIO_NONE: c_int = 0;
pub const PTHREAD_PRIO_INHERIT: c_int = 1;
pub const PTHREAD_PRIO_PROTECT: c_int = 2;
const enum_unnamed_8 = c_uint;
pub const PTHREAD_RWLOCK_PREFER_READER_NP: c_int = 0;
pub const PTHREAD_RWLOCK_PREFER_WRITER_NP: c_int = 1;
pub const PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP: c_int = 2;
pub const PTHREAD_RWLOCK_DEFAULT_NP: c_int = 0;
const enum_unnamed_9 = c_uint;
pub const PTHREAD_INHERIT_SCHED: c_int = 0;
pub const PTHREAD_EXPLICIT_SCHED: c_int = 1;
const enum_unnamed_10 = c_uint;
pub const PTHREAD_SCOPE_SYSTEM: c_int = 0;
pub const PTHREAD_SCOPE_PROCESS: c_int = 1;
const enum_unnamed_11 = c_uint;
pub const PTHREAD_PROCESS_PRIVATE: c_int = 0;
pub const PTHREAD_PROCESS_SHARED: c_int = 1;
const enum_unnamed_12 = c_uint;
pub const struct__pthread_cleanup_buffer = extern struct {
    __routine: ?*const fn (?*anyopaque) callconv(.c) void = null,
    __arg: ?*anyopaque = null,
    __canceltype: c_int = 0,
    __prev: [*c]struct__pthread_cleanup_buffer = null,
};
pub const PTHREAD_CANCEL_ENABLE: c_int = 0;
pub const PTHREAD_CANCEL_DISABLE: c_int = 1;
const enum_unnamed_13 = c_uint;
pub const PTHREAD_CANCEL_DEFERRED: c_int = 0;
pub const PTHREAD_CANCEL_ASYNCHRONOUS: c_int = 1;
const enum_unnamed_14 = c_uint;
pub extern fn pthread_create(noalias __newthread: [*c]pthread_t, noalias __attr: [*c]const pthread_attr_t, __start_routine: ?*const fn (?*anyopaque) callconv(.c) ?*anyopaque, noalias __arg: ?*anyopaque) c_int;
pub extern fn pthread_exit(__retval: ?*anyopaque) noreturn;
pub extern fn pthread_join(__th: pthread_t, __thread_return: [*c]?*anyopaque) c_int;
pub extern fn pthread_detach(__th: pthread_t) c_int;
pub extern fn pthread_self() pthread_t;
pub extern fn pthread_equal(__thread1: pthread_t, __thread2: pthread_t) c_int;
pub extern fn pthread_attr_init(__attr: [*c]pthread_attr_t) c_int;
pub extern fn pthread_attr_destroy(__attr: [*c]pthread_attr_t) c_int;
pub extern fn pthread_attr_getdetachstate(__attr: [*c]const pthread_attr_t, __detachstate: [*c]c_int) c_int;
pub extern fn pthread_attr_setdetachstate(__attr: [*c]pthread_attr_t, __detachstate: c_int) c_int;
pub extern fn pthread_attr_getguardsize(__attr: [*c]const pthread_attr_t, __guardsize: [*c]usize) c_int;
pub extern fn pthread_attr_setguardsize(__attr: [*c]pthread_attr_t, __guardsize: usize) c_int;
pub extern fn pthread_attr_getschedparam(noalias __attr: [*c]const pthread_attr_t, noalias __param: [*c]struct_sched_param) c_int;
pub extern fn pthread_attr_setschedparam(noalias __attr: [*c]pthread_attr_t, noalias __param: [*c]const struct_sched_param) c_int;
pub extern fn pthread_attr_getschedpolicy(noalias __attr: [*c]const pthread_attr_t, noalias __policy: [*c]c_int) c_int;
pub extern fn pthread_attr_setschedpolicy(__attr: [*c]pthread_attr_t, __policy: c_int) c_int;
pub extern fn pthread_attr_getinheritsched(noalias __attr: [*c]const pthread_attr_t, noalias __inherit: [*c]c_int) c_int;
pub extern fn pthread_attr_setinheritsched(__attr: [*c]pthread_attr_t, __inherit: c_int) c_int;
pub extern fn pthread_attr_getscope(noalias __attr: [*c]const pthread_attr_t, noalias __scope: [*c]c_int) c_int;
pub extern fn pthread_attr_setscope(__attr: [*c]pthread_attr_t, __scope: c_int) c_int;
pub extern fn pthread_attr_getstackaddr(noalias __attr: [*c]const pthread_attr_t, noalias __stackaddr: [*c]?*anyopaque) c_int;
pub extern fn pthread_attr_setstackaddr(__attr: [*c]pthread_attr_t, __stackaddr: ?*anyopaque) c_int;
pub extern fn pthread_attr_getstacksize(noalias __attr: [*c]const pthread_attr_t, noalias __stacksize: [*c]usize) c_int;
pub extern fn pthread_attr_setstacksize(__attr: [*c]pthread_attr_t, __stacksize: usize) c_int;
pub extern fn pthread_attr_getstack(noalias __attr: [*c]const pthread_attr_t, noalias __stackaddr: [*c]?*anyopaque, noalias __stacksize: [*c]usize) c_int;
pub extern fn pthread_attr_setstack(__attr: [*c]pthread_attr_t, __stackaddr: ?*anyopaque, __stacksize: usize) c_int;
pub extern fn pthread_setschedparam(__target_thread: pthread_t, __policy: c_int, __param: [*c]const struct_sched_param) c_int;
pub extern fn pthread_getschedparam(__target_thread: pthread_t, noalias __policy: [*c]c_int, noalias __param: [*c]struct_sched_param) c_int;
pub extern fn pthread_setschedprio(__target_thread: pthread_t, __prio: c_int) c_int;
pub extern fn pthread_once(__once_control: [*c]pthread_once_t, __init_routine: ?*const fn () callconv(.c) void) c_int;
pub extern fn pthread_setcancelstate(__state: c_int, __oldstate: [*c]c_int) c_int;
pub extern fn pthread_setcanceltype(__type: c_int, __oldtype: [*c]c_int) c_int;
pub extern fn pthread_cancel(__th: pthread_t) c_int;
pub extern fn pthread_testcancel() void;
pub const struct___cancel_jmp_buf_tag = extern struct {
    __cancel_jmp_buf: __jmp_buf = @import("std").mem.zeroes(__jmp_buf),
    __mask_was_saved: c_int = 0,
};
pub const __pthread_unwind_buf_t = extern struct {
    __cancel_jmp_buf: [1]struct___cancel_jmp_buf_tag = @import("std").mem.zeroes([1]struct___cancel_jmp_buf_tag),
    __pad: [4]?*anyopaque = @import("std").mem.zeroes([4]?*anyopaque),
    pub const __pthread_register_cancel = __root.__pthread_register_cancel;
    pub const __pthread_unregister_cancel = __root.__pthread_unregister_cancel;
    pub const __pthread_unwind_next = __root.__pthread_unwind_next;
    pub const cancel = __root.__pthread_register_cancel;
    pub const next = __root.__pthread_unwind_next;
};
pub const struct___pthread_cleanup_frame = extern struct {
    __cancel_routine: ?*const fn (?*anyopaque) callconv(.c) void = null,
    __cancel_arg: ?*anyopaque = null,
    __do_it: c_int = 0,
    __cancel_type: c_int = 0,
};
pub extern fn __pthread_register_cancel(__buf: [*c]__pthread_unwind_buf_t) void;
pub extern fn __pthread_unregister_cancel(__buf: [*c]__pthread_unwind_buf_t) void; // /usr/include/pthread.h:750:13: warning: TODO weak linkage ignored
pub extern fn __pthread_unwind_next(__buf: [*c]__pthread_unwind_buf_t) noreturn;
pub extern fn __sigsetjmp(__env: [*c]struct___jmp_buf_tag, __savemask: c_int) c_int;
pub extern fn pthread_mutex_init(__mutex: [*c]pthread_mutex_t, __mutexattr: [*c]const pthread_mutexattr_t) c_int;
pub extern fn pthread_mutex_destroy(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_trylock(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_lock(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_timedlock(noalias __mutex: [*c]pthread_mutex_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_mutex_unlock(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_getprioceiling(noalias __mutex: [*c]const pthread_mutex_t, noalias __prioceiling: [*c]c_int) c_int;
pub extern fn pthread_mutex_setprioceiling(noalias __mutex: [*c]pthread_mutex_t, __prioceiling: c_int, noalias __old_ceiling: [*c]c_int) c_int;
pub extern fn pthread_mutex_consistent(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutexattr_init(__attr: [*c]pthread_mutexattr_t) c_int;
pub extern fn pthread_mutexattr_destroy(__attr: [*c]pthread_mutexattr_t) c_int;
pub extern fn pthread_mutexattr_getpshared(noalias __attr: [*c]const pthread_mutexattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setpshared(__attr: [*c]pthread_mutexattr_t, __pshared: c_int) c_int;
pub extern fn pthread_mutexattr_gettype(noalias __attr: [*c]const pthread_mutexattr_t, noalias __kind: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_settype(__attr: [*c]pthread_mutexattr_t, __kind: c_int) c_int;
pub extern fn pthread_mutexattr_getprotocol(noalias __attr: [*c]const pthread_mutexattr_t, noalias __protocol: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setprotocol(__attr: [*c]pthread_mutexattr_t, __protocol: c_int) c_int;
pub extern fn pthread_mutexattr_getprioceiling(noalias __attr: [*c]const pthread_mutexattr_t, noalias __prioceiling: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setprioceiling(__attr: [*c]pthread_mutexattr_t, __prioceiling: c_int) c_int;
pub extern fn pthread_mutexattr_getrobust(__attr: [*c]const pthread_mutexattr_t, __robustness: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setrobust(__attr: [*c]pthread_mutexattr_t, __robustness: c_int) c_int;
pub extern fn pthread_rwlock_init(noalias __rwlock: [*c]pthread_rwlock_t, noalias __attr: [*c]const pthread_rwlockattr_t) c_int;
pub extern fn pthread_rwlock_destroy(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_rdlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_tryrdlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_timedrdlock(noalias __rwlock: [*c]pthread_rwlock_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_rwlock_wrlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_trywrlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_timedwrlock(noalias __rwlock: [*c]pthread_rwlock_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_rwlock_unlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlockattr_init(__attr: [*c]pthread_rwlockattr_t) c_int;
pub extern fn pthread_rwlockattr_destroy(__attr: [*c]pthread_rwlockattr_t) c_int;
pub extern fn pthread_rwlockattr_getpshared(noalias __attr: [*c]const pthread_rwlockattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_rwlockattr_setpshared(__attr: [*c]pthread_rwlockattr_t, __pshared: c_int) c_int;
pub extern fn pthread_rwlockattr_getkind_np(noalias __attr: [*c]const pthread_rwlockattr_t, noalias __pref: [*c]c_int) c_int;
pub extern fn pthread_rwlockattr_setkind_np(__attr: [*c]pthread_rwlockattr_t, __pref: c_int) c_int;
pub extern fn pthread_cond_init(noalias __cond: [*c]pthread_cond_t, noalias __cond_attr: [*c]const pthread_condattr_t) c_int;
pub extern fn pthread_cond_destroy(__cond: [*c]pthread_cond_t) c_int;
pub extern fn pthread_cond_signal(__cond: [*c]pthread_cond_t) c_int;
pub extern fn pthread_cond_broadcast(__cond: [*c]pthread_cond_t) c_int;
pub extern fn pthread_cond_wait(noalias __cond: [*c]pthread_cond_t, noalias __mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_cond_timedwait(noalias __cond: [*c]pthread_cond_t, noalias __mutex: [*c]pthread_mutex_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_condattr_init(__attr: [*c]pthread_condattr_t) c_int;
pub extern fn pthread_condattr_destroy(__attr: [*c]pthread_condattr_t) c_int;
pub extern fn pthread_condattr_getpshared(noalias __attr: [*c]const pthread_condattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_condattr_setpshared(__attr: [*c]pthread_condattr_t, __pshared: c_int) c_int;
pub extern fn pthread_condattr_getclock(noalias __attr: [*c]const pthread_condattr_t, noalias __clock_id: [*c]__clockid_t) c_int;
pub extern fn pthread_condattr_setclock(__attr: [*c]pthread_condattr_t, __clock_id: __clockid_t) c_int;
pub extern fn pthread_spin_init(__lock: [*c]volatile pthread_spinlock_t, __pshared: c_int) c_int;
pub extern fn pthread_spin_destroy(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_spin_lock(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_spin_trylock(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_spin_unlock(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_barrier_init(noalias __barrier: [*c]pthread_barrier_t, noalias __attr: [*c]const pthread_barrierattr_t, __count: c_uint) c_int;
pub extern fn pthread_barrier_destroy(__barrier: [*c]pthread_barrier_t) c_int;
pub extern fn pthread_barrier_wait(__barrier: [*c]pthread_barrier_t) c_int;
pub extern fn pthread_barrierattr_init(__attr: [*c]pthread_barrierattr_t) c_int;
pub extern fn pthread_barrierattr_destroy(__attr: [*c]pthread_barrierattr_t) c_int;
pub extern fn pthread_barrierattr_getpshared(noalias __attr: [*c]const pthread_barrierattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_barrierattr_setpshared(__attr: [*c]pthread_barrierattr_t, __pshared: c_int) c_int;
pub extern fn pthread_key_create(__key: [*c]pthread_key_t, __destr_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int;
pub extern fn pthread_key_delete(__key: pthread_key_t) c_int;
pub extern fn pthread_getspecific(__key: pthread_key_t) ?*anyopaque;
pub extern fn pthread_setspecific(__key: pthread_key_t, __pointer: ?*const anyopaque) c_int;
pub extern fn pthread_getcpuclockid(__thread_id: pthread_t, __clock_id: [*c]__clockid_t) c_int;
pub extern fn pthread_atfork(__prepare: ?*const fn () callconv(.c) void, __parent: ?*const fn () callconv(.c) void, __child: ?*const fn () callconv(.c) void) c_int;
pub const struct_mbedtls_threading_mutex_t = extern struct {
    private_mutex: pthread_mutex_t = @import("std").mem.zeroes(pthread_mutex_t),
    private_state: u8 = 0,
};
pub const mbedtls_threading_mutex_t = struct_mbedtls_threading_mutex_t;
pub extern var mbedtls_mutex_init: ?*const fn (mutex: [*c]mbedtls_threading_mutex_t) callconv(.c) void;
pub extern var mbedtls_mutex_free: ?*const fn (mutex: [*c]mbedtls_threading_mutex_t) callconv(.c) void;
pub extern var mbedtls_mutex_lock: ?*const fn (mutex: [*c]mbedtls_threading_mutex_t) callconv(.c) c_int;
pub extern var mbedtls_mutex_unlock: ?*const fn (mutex: [*c]mbedtls_threading_mutex_t) callconv(.c) c_int;
pub extern var mbedtls_threading_readdir_mutex: mbedtls_threading_mutex_t;
pub extern var mbedtls_threading_gmtime_mutex: mbedtls_threading_mutex_t;
pub extern var mbedtls_threading_key_slot_mutex: mbedtls_threading_mutex_t;
pub extern var mbedtls_threading_psa_globaldata_mutex: mbedtls_threading_mutex_t;
pub extern var mbedtls_threading_psa_rngdata_mutex: mbedtls_threading_mutex_t;
pub const struct_mbedtls_rsa_context = extern struct {
    private_ver: c_int = 0,
    private_len: usize = 0,
    private_N: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_E: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_D: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_P: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Q: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_DP: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_DQ: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_QP: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_RN: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_RP: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_RQ: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Vi: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Vf: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_padding: c_int = 0,
    private_hash_id: c_int = 0,
    private_mutex: mbedtls_threading_mutex_t = @import("std").mem.zeroes(mbedtls_threading_mutex_t),
    pub const mbedtls_rsa_init = __root.mbedtls_rsa_init;
    pub const mbedtls_rsa_set_padding = __root.mbedtls_rsa_set_padding;
    pub const mbedtls_rsa_get_padding_mode = __root.mbedtls_rsa_get_padding_mode;
    pub const mbedtls_rsa_get_md_alg = __root.mbedtls_rsa_get_md_alg;
    pub const mbedtls_rsa_import = __root.mbedtls_rsa_import;
    pub const mbedtls_rsa_import_raw = __root.mbedtls_rsa_import_raw;
    pub const mbedtls_rsa_complete = __root.mbedtls_rsa_complete;
    pub const mbedtls_rsa_export = __root.mbedtls_rsa_export;
    pub const mbedtls_rsa_export_raw = __root.mbedtls_rsa_export_raw;
    pub const mbedtls_rsa_export_crt = __root.mbedtls_rsa_export_crt;
    pub const mbedtls_rsa_get_bitlen = __root.mbedtls_rsa_get_bitlen;
    pub const mbedtls_rsa_get_len = __root.mbedtls_rsa_get_len;
    pub const mbedtls_rsa_gen_key = __root.mbedtls_rsa_gen_key;
    pub const mbedtls_rsa_check_pubkey = __root.mbedtls_rsa_check_pubkey;
    pub const mbedtls_rsa_check_privkey = __root.mbedtls_rsa_check_privkey;
    pub const mbedtls_rsa_check_pub_priv = __root.mbedtls_rsa_check_pub_priv;
    pub const mbedtls_rsa_public = __root.mbedtls_rsa_public;
    pub const mbedtls_rsa_private = __root.mbedtls_rsa_private;
    pub const mbedtls_rsa_pkcs1_encrypt = __root.mbedtls_rsa_pkcs1_encrypt;
    pub const mbedtls_rsa_rsaes_pkcs1_v15_encrypt = __root.mbedtls_rsa_rsaes_pkcs1_v15_encrypt;
    pub const mbedtls_rsa_rsaes_oaep_encrypt = __root.mbedtls_rsa_rsaes_oaep_encrypt;
    pub const mbedtls_rsa_pkcs1_decrypt = __root.mbedtls_rsa_pkcs1_decrypt;
    pub const mbedtls_rsa_rsaes_pkcs1_v15_decrypt = __root.mbedtls_rsa_rsaes_pkcs1_v15_decrypt;
    pub const mbedtls_rsa_rsaes_oaep_decrypt = __root.mbedtls_rsa_rsaes_oaep_decrypt;
    pub const mbedtls_rsa_pkcs1_sign = __root.mbedtls_rsa_pkcs1_sign;
    pub const mbedtls_rsa_rsassa_pkcs1_v15_sign = __root.mbedtls_rsa_rsassa_pkcs1_v15_sign;
    pub const mbedtls_rsa_rsassa_pss_sign_ext = __root.mbedtls_rsa_rsassa_pss_sign_ext;
    pub const mbedtls_rsa_rsassa_pss_sign = __root.mbedtls_rsa_rsassa_pss_sign;
    pub const mbedtls_rsa_pkcs1_verify = __root.mbedtls_rsa_pkcs1_verify;
    pub const mbedtls_rsa_rsassa_pkcs1_v15_verify = __root.mbedtls_rsa_rsassa_pkcs1_v15_verify;
    pub const mbedtls_rsa_rsassa_pss_verify = __root.mbedtls_rsa_rsassa_pss_verify;
    pub const mbedtls_rsa_rsassa_pss_verify_ext = __root.mbedtls_rsa_rsassa_pss_verify_ext;
    pub const mbedtls_rsa_copy = __root.mbedtls_rsa_copy;
    pub const mbedtls_rsa_free = __root.mbedtls_rsa_free;
    pub const init = __root.mbedtls_rsa_init;
    pub const padding = __root.mbedtls_rsa_set_padding;
    pub const mode = __root.mbedtls_rsa_get_padding_mode;
    pub const alg = __root.mbedtls_rsa_get_md_alg;
    pub const import = __root.mbedtls_rsa_import;
    pub const raw = __root.mbedtls_rsa_import_raw;
    pub const complete = __root.mbedtls_rsa_complete;
    pub const @"export" = __root.mbedtls_rsa_export;
    pub const crt = __root.mbedtls_rsa_export_crt;
    pub const bitlen = __root.mbedtls_rsa_get_bitlen;
    pub const len = __root.mbedtls_rsa_get_len;
    pub const key = __root.mbedtls_rsa_gen_key;
    pub const pubkey = __root.mbedtls_rsa_check_pubkey;
    pub const privkey = __root.mbedtls_rsa_check_privkey;
    pub const priv = __root.mbedtls_rsa_check_pub_priv;
    pub const public = __root.mbedtls_rsa_public;
    pub const private = __root.mbedtls_rsa_private;
    pub const encrypt = __root.mbedtls_rsa_pkcs1_encrypt;
    pub const decrypt = __root.mbedtls_rsa_pkcs1_decrypt;
    pub const sign = __root.mbedtls_rsa_pkcs1_sign;
    pub const ext = __root.mbedtls_rsa_rsassa_pss_sign_ext;
    pub const verify = __root.mbedtls_rsa_pkcs1_verify;
    pub const copy = __root.mbedtls_rsa_copy;
    pub const free = __root.mbedtls_rsa_free;
};
pub const mbedtls_rsa_context = struct_mbedtls_rsa_context;
pub extern fn mbedtls_rsa_init(ctx: [*c]mbedtls_rsa_context) void;
pub extern fn mbedtls_rsa_set_padding(ctx: [*c]mbedtls_rsa_context, padding: c_int, hash_id: mbedtls_md_type_t) c_int;
pub extern fn mbedtls_rsa_get_padding_mode(ctx: [*c]const mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_get_md_alg(ctx: [*c]const mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_import(ctx: [*c]mbedtls_rsa_context, N: [*c]const mbedtls_mpi, P: [*c]const mbedtls_mpi, Q: [*c]const mbedtls_mpi, D: [*c]const mbedtls_mpi, E: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_rsa_import_raw(ctx: [*c]mbedtls_rsa_context, N: [*c]const u8, N_len: usize, P: [*c]const u8, P_len: usize, Q: [*c]const u8, Q_len: usize, D: [*c]const u8, D_len: usize, E: [*c]const u8, E_len: usize) c_int;
pub extern fn mbedtls_rsa_complete(ctx: [*c]mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_export(ctx: [*c]const mbedtls_rsa_context, N: [*c]mbedtls_mpi, P: [*c]mbedtls_mpi, Q: [*c]mbedtls_mpi, D: [*c]mbedtls_mpi, E: [*c]mbedtls_mpi) c_int;
pub extern fn mbedtls_rsa_export_raw(ctx: [*c]const mbedtls_rsa_context, N: [*c]u8, N_len: usize, P: [*c]u8, P_len: usize, Q: [*c]u8, Q_len: usize, D: [*c]u8, D_len: usize, E: [*c]u8, E_len: usize) c_int;
pub extern fn mbedtls_rsa_export_crt(ctx: [*c]const mbedtls_rsa_context, DP: [*c]mbedtls_mpi, DQ: [*c]mbedtls_mpi, QP: [*c]mbedtls_mpi) c_int;
pub extern fn mbedtls_rsa_get_bitlen(ctx: [*c]const mbedtls_rsa_context) usize;
pub extern fn mbedtls_rsa_get_len(ctx: [*c]const mbedtls_rsa_context) usize;
pub extern fn mbedtls_rsa_gen_key(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, nbits: c_uint, exponent: c_int) c_int;
pub extern fn mbedtls_rsa_check_pubkey(ctx: [*c]const mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_check_privkey(ctx: [*c]const mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_check_pub_priv(@"pub": [*c]const mbedtls_rsa_context, prv: [*c]const mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_public(ctx: [*c]mbedtls_rsa_context, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_rsa_private(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_rsa_pkcs1_encrypt(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, ilen: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_rsa_rsaes_pkcs1_v15_encrypt(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, ilen: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_rsa_rsaes_oaep_encrypt(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, label: [*c]const u8, label_len: usize, ilen: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_rsa_pkcs1_decrypt(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, olen: [*c]usize, input: [*c]const u8, output: [*c]u8, output_max_len: usize) c_int;
pub extern fn mbedtls_rsa_rsaes_pkcs1_v15_decrypt(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, olen: [*c]usize, input: [*c]const u8, output: [*c]u8, output_max_len: usize) c_int;
pub extern fn mbedtls_rsa_rsaes_oaep_decrypt(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, label: [*c]const u8, label_len: usize, olen: [*c]usize, input: [*c]const u8, output: [*c]u8, output_max_len: usize) c_int;
pub extern fn mbedtls_rsa_pkcs1_sign(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]u8) c_int;
pub extern fn mbedtls_rsa_rsassa_pkcs1_v15_sign(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]u8) c_int;
pub extern fn mbedtls_rsa_rsassa_pss_sign_ext(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, saltlen: c_int, sig: [*c]u8) c_int;
pub extern fn mbedtls_rsa_rsassa_pss_sign(ctx: [*c]mbedtls_rsa_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]u8) c_int;
pub extern fn mbedtls_rsa_pkcs1_verify(ctx: [*c]mbedtls_rsa_context, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]const u8) c_int;
pub extern fn mbedtls_rsa_rsassa_pkcs1_v15_verify(ctx: [*c]mbedtls_rsa_context, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]const u8) c_int;
pub extern fn mbedtls_rsa_rsassa_pss_verify(ctx: [*c]mbedtls_rsa_context, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]const u8) c_int;
pub extern fn mbedtls_rsa_rsassa_pss_verify_ext(ctx: [*c]mbedtls_rsa_context, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, mgf1_hash_id: mbedtls_md_type_t, expected_salt_len: c_int, sig: [*c]const u8) c_int;
pub extern fn mbedtls_rsa_copy(dst: [*c]mbedtls_rsa_context, src: [*c]const mbedtls_rsa_context) c_int;
pub extern fn mbedtls_rsa_free(ctx: [*c]mbedtls_rsa_context) void;
pub extern fn mbedtls_rsa_self_test(verbose: c_int) c_int;
pub const mbedtls_ecdsa_context = mbedtls_ecp_keypair;
pub const mbedtls_ecdsa_restart_ctx = anyopaque;
pub extern fn mbedtls_ecdsa_can_do(gid: mbedtls_ecp_group_id) c_int;
pub extern fn mbedtls_ecdsa_sign(grp: [*c]mbedtls_ecp_group, r: [*c]mbedtls_mpi, s: [*c]mbedtls_mpi, d: [*c]const mbedtls_mpi, buf: [*c]const u8, blen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdsa_sign_det_ext(grp: [*c]mbedtls_ecp_group, r: [*c]mbedtls_mpi, s: [*c]mbedtls_mpi, d: [*c]const mbedtls_mpi, buf: [*c]const u8, blen: usize, md_alg: mbedtls_md_type_t, f_rng_blind: ?*const mbedtls_f_rng_t, p_rng_blind: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdsa_sign_restartable(grp: [*c]mbedtls_ecp_group, r: [*c]mbedtls_mpi, s: [*c]mbedtls_mpi, d: [*c]const mbedtls_mpi, buf: [*c]const u8, blen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, f_rng_blind: ?*const mbedtls_f_rng_t, p_rng_blind: ?*anyopaque, rs_ctx: ?*mbedtls_ecdsa_restart_ctx) c_int;
pub extern fn mbedtls_ecdsa_sign_det_restartable(grp: [*c]mbedtls_ecp_group, r: [*c]mbedtls_mpi, s: [*c]mbedtls_mpi, d: [*c]const mbedtls_mpi, buf: [*c]const u8, blen: usize, md_alg: mbedtls_md_type_t, f_rng_blind: ?*const mbedtls_f_rng_t, p_rng_blind: ?*anyopaque, rs_ctx: ?*mbedtls_ecdsa_restart_ctx) c_int;
pub extern fn mbedtls_ecdsa_verify(grp: [*c]mbedtls_ecp_group, buf: [*c]const u8, blen: usize, Q: [*c]const mbedtls_ecp_point, r: [*c]const mbedtls_mpi, s: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_ecdsa_verify_restartable(grp: [*c]mbedtls_ecp_group, buf: [*c]const u8, blen: usize, Q: [*c]const mbedtls_ecp_point, r: [*c]const mbedtls_mpi, s: [*c]const mbedtls_mpi, rs_ctx: ?*mbedtls_ecdsa_restart_ctx) c_int;
pub extern fn mbedtls_ecdsa_write_signature(ctx: [*c]mbedtls_ecdsa_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hlen: usize, sig: [*c]u8, sig_size: usize, slen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdsa_write_signature_restartable(ctx: [*c]mbedtls_ecdsa_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hlen: usize, sig: [*c]u8, sig_size: usize, slen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, rs_ctx: ?*mbedtls_ecdsa_restart_ctx) c_int;
pub extern fn mbedtls_ecdsa_read_signature(ctx: [*c]mbedtls_ecdsa_context, hash: [*c]const u8, hlen: usize, sig: [*c]const u8, slen: usize) c_int;
pub extern fn mbedtls_ecdsa_read_signature_restartable(ctx: [*c]mbedtls_ecdsa_context, hash: [*c]const u8, hlen: usize, sig: [*c]const u8, slen: usize, rs_ctx: ?*mbedtls_ecdsa_restart_ctx) c_int;
pub extern fn mbedtls_ecdsa_genkey(ctx: [*c]mbedtls_ecdsa_context, gid: mbedtls_ecp_group_id, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdsa_from_keypair(ctx: [*c]mbedtls_ecdsa_context, key: [*c]const mbedtls_ecp_keypair) c_int;
pub extern fn mbedtls_ecdsa_init(ctx: [*c]mbedtls_ecdsa_context) void;
pub extern fn mbedtls_ecdsa_free(ctx: [*c]mbedtls_ecdsa_context) void;
pub const psa_status_t = i32;
pub const psa_key_type_t = u16;
pub const psa_ecc_family_t = u8;
pub const psa_dh_family_t = u8;
pub const psa_algorithm_t = u32;
pub const psa_key_lifetime_t = u32;
pub const psa_key_persistence_t = u8;
pub const psa_key_location_t = u32;
pub const psa_key_id_t = u32;
pub const mbedtls_svc_key_id_t = psa_key_id_t;
pub const psa_key_usage_t = u32;
pub const psa_key_bits_t = u16;
pub const struct_psa_key_policy_s = extern struct {
    private_usage: psa_key_usage_t = 0,
    private_alg: psa_algorithm_t = 0,
    private_alg2: psa_algorithm_t = 0,
};
pub const psa_key_policy_t = struct_psa_key_policy_s;
pub const struct_psa_key_attributes_s = extern struct {
    private_type: psa_key_type_t = 0,
    private_bits: psa_key_bits_t = 0,
    private_lifetime: psa_key_lifetime_t = 0,
    private_policy: psa_key_policy_t = @import("std").mem.zeroes(psa_key_policy_t),
    private_id: mbedtls_svc_key_id_t = 0,
    pub const psa_set_key_id = __root.psa_set_key_id;
    pub const psa_get_key_id = __root.psa_get_key_id;
    pub const psa_set_key_lifetime = __root.psa_set_key_lifetime;
    pub const psa_get_key_lifetime = __root.psa_get_key_lifetime;
    pub const psa_set_key_usage_flags = __root.psa_set_key_usage_flags;
    pub const psa_get_key_usage_flags = __root.psa_get_key_usage_flags;
    pub const psa_set_key_algorithm = __root.psa_set_key_algorithm;
    pub const psa_get_key_algorithm = __root.psa_get_key_algorithm;
    pub const psa_set_key_type = __root.psa_set_key_type;
    pub const psa_get_key_type = __root.psa_get_key_type;
    pub const psa_set_key_bits = __root.psa_set_key_bits;
    pub const psa_get_key_bits = __root.psa_get_key_bits;
    pub const psa_reset_key_attributes = __root.psa_reset_key_attributes;
    pub const psa_import_key = __root.psa_import_key;
    pub const psa_key_derivation_output_key = __root.psa_key_derivation_output_key;
    pub const psa_key_derivation_output_key_custom = __root.psa_key_derivation_output_key_custom;
    pub const psa_key_derivation_output_key_ext = __root.psa_key_derivation_output_key_ext;
    pub const psa_generate_key = __root.psa_generate_key;
    pub const psa_generate_key_custom = __root.psa_generate_key_custom;
    pub const psa_generate_key_ext = __root.psa_generate_key_ext;
    pub const psa_set_key_domain_parameters = __root.psa_set_key_domain_parameters;
    pub const psa_get_key_domain_parameters = __root.psa_get_key_domain_parameters;
    pub const psa_set_key_enrollment_algorithm = __root.psa_set_key_enrollment_algorithm;
    pub const psa_get_key_enrollment_algorithm = __root.psa_get_key_enrollment_algorithm;
    pub const id = __root.psa_set_key_id;
    pub const lifetime = __root.psa_set_key_lifetime;
    pub const flags = __root.psa_set_key_usage_flags;
    pub const algorithm = __root.psa_set_key_algorithm;
    pub const @"type" = __root.psa_set_key_type;
    pub const bits = __root.psa_set_key_bits;
    pub const attributes = __root.psa_reset_key_attributes;
    pub const key = __root.psa_import_key;
    pub const custom = __root.psa_key_derivation_output_key_custom;
    pub const ext = __root.psa_key_derivation_output_key_ext;
    pub const parameters = __root.psa_set_key_domain_parameters;
};
pub const psa_key_attributes_t = struct_psa_key_attributes_s;
pub const psa_key_derivation_step_t = u16;
pub const struct_psa_custom_key_parameters_s = extern struct {
    flags: u32 = 0,
};
pub const psa_custom_key_parameters_t = struct_psa_custom_key_parameters_s;
pub const struct_psa_key_production_parameters_s = extern struct {
    flags: u32 = 0,
    _data: [0]u8 = @import("std").mem.zeroes([0]u8),
    pub fn data(self: anytype) __helpers.FlexibleArrayType(@TypeOf(self), @typeInfo(@TypeOf(self.*._data)).array.child) {
        return @ptrCast(@alignCast(&self.*._data));
    }
};
pub const psa_key_production_parameters_t = struct_psa_key_production_parameters_s;
pub fn mbedtls_svc_key_id_make(arg_unused: c_uint, arg_key_id: psa_key_id_t) callconv(.c) mbedtls_svc_key_id_t {
    var unused = arg_unused;
    _ = &unused;
    var key_id = arg_key_id;
    _ = &key_id;
    _ = &unused;
    return key_id;
}
pub fn mbedtls_svc_key_id_equal(arg_id1: mbedtls_svc_key_id_t, arg_id2: mbedtls_svc_key_id_t) callconv(.c) c_int {
    var id1 = arg_id1;
    _ = &id1;
    var id2 = arg_id2;
    _ = &id2;
    return @intFromBool(id1 == id2);
}
pub fn mbedtls_svc_key_id_is_null(arg_key: mbedtls_svc_key_id_t) callconv(.c) c_int {
    var key = arg_key;
    _ = &key;
    return @intFromBool(key == @as(mbedtls_svc_key_id_t, 0));
}
pub const PSA_CRYPTO_DRIVER_DECRYPT: c_int = 0;
pub const PSA_CRYPTO_DRIVER_ENCRYPT: c_int = 1;
pub const psa_encrypt_or_decrypt_t = c_uint;
pub const struct_mbedtls_md5_context = extern struct {
    private_total: [2]u32 = @import("std").mem.zeroes([2]u32),
    private_state: [4]u32 = @import("std").mem.zeroes([4]u32),
    private_buffer: [64]u8 = @import("std").mem.zeroes([64]u8),
    pub const mbedtls_md5_init = __root.mbedtls_md5_init;
    pub const mbedtls_md5_free = __root.mbedtls_md5_free;
    pub const mbedtls_md5_clone = __root.mbedtls_md5_clone;
    pub const mbedtls_md5_starts = __root.mbedtls_md5_starts;
    pub const mbedtls_md5_update = __root.mbedtls_md5_update;
    pub const mbedtls_md5_finish = __root.mbedtls_md5_finish;
    pub const mbedtls_internal_md5_process = __root.mbedtls_internal_md5_process;
    pub const init = __root.mbedtls_md5_init;
    pub const free = __root.mbedtls_md5_free;
    pub const clone = __root.mbedtls_md5_clone;
    pub const starts = __root.mbedtls_md5_starts;
    pub const update = __root.mbedtls_md5_update;
    pub const finish = __root.mbedtls_md5_finish;
    pub const process = __root.mbedtls_internal_md5_process;
};
pub const mbedtls_md5_context = struct_mbedtls_md5_context;
pub extern fn mbedtls_md5_init(ctx: [*c]mbedtls_md5_context) void;
pub extern fn mbedtls_md5_free(ctx: [*c]mbedtls_md5_context) void;
pub extern fn mbedtls_md5_clone(dst: [*c]mbedtls_md5_context, src: [*c]const mbedtls_md5_context) void;
pub extern fn mbedtls_md5_starts(ctx: [*c]mbedtls_md5_context) c_int;
pub extern fn mbedtls_md5_update(ctx: [*c]mbedtls_md5_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_md5_finish(ctx: [*c]mbedtls_md5_context, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_md5_process(ctx: [*c]mbedtls_md5_context, data: [*c]const u8) c_int;
pub extern fn mbedtls_md5(input: [*c]const u8, ilen: usize, output: [*c]u8) c_int;
pub extern fn mbedtls_md5_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_ripemd160_context = extern struct {
    private_total: [2]u32 = @import("std").mem.zeroes([2]u32),
    private_state: [5]u32 = @import("std").mem.zeroes([5]u32),
    private_buffer: [64]u8 = @import("std").mem.zeroes([64]u8),
    pub const mbedtls_ripemd160_init = __root.mbedtls_ripemd160_init;
    pub const mbedtls_ripemd160_free = __root.mbedtls_ripemd160_free;
    pub const mbedtls_ripemd160_clone = __root.mbedtls_ripemd160_clone;
    pub const mbedtls_ripemd160_starts = __root.mbedtls_ripemd160_starts;
    pub const mbedtls_ripemd160_update = __root.mbedtls_ripemd160_update;
    pub const mbedtls_ripemd160_finish = __root.mbedtls_ripemd160_finish;
    pub const mbedtls_internal_ripemd160_process = __root.mbedtls_internal_ripemd160_process;
    pub const init = __root.mbedtls_ripemd160_init;
    pub const free = __root.mbedtls_ripemd160_free;
    pub const clone = __root.mbedtls_ripemd160_clone;
    pub const starts = __root.mbedtls_ripemd160_starts;
    pub const update = __root.mbedtls_ripemd160_update;
    pub const finish = __root.mbedtls_ripemd160_finish;
    pub const process = __root.mbedtls_internal_ripemd160_process;
};
pub const mbedtls_ripemd160_context = struct_mbedtls_ripemd160_context;
pub extern fn mbedtls_ripemd160_init(ctx: [*c]mbedtls_ripemd160_context) void;
pub extern fn mbedtls_ripemd160_free(ctx: [*c]mbedtls_ripemd160_context) void;
pub extern fn mbedtls_ripemd160_clone(dst: [*c]mbedtls_ripemd160_context, src: [*c]const mbedtls_ripemd160_context) void;
pub extern fn mbedtls_ripemd160_starts(ctx: [*c]mbedtls_ripemd160_context) c_int;
pub extern fn mbedtls_ripemd160_update(ctx: [*c]mbedtls_ripemd160_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_ripemd160_finish(ctx: [*c]mbedtls_ripemd160_context, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_ripemd160_process(ctx: [*c]mbedtls_ripemd160_context, data: [*c]const u8) c_int;
pub extern fn mbedtls_ripemd160(input: [*c]const u8, ilen: usize, output: [*c]u8) c_int;
pub extern fn mbedtls_ripemd160_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_sha1_context = extern struct {
    private_total: [2]u32 = @import("std").mem.zeroes([2]u32),
    private_state: [5]u32 = @import("std").mem.zeroes([5]u32),
    private_buffer: [64]u8 = @import("std").mem.zeroes([64]u8),
    pub const mbedtls_sha1_init = __root.mbedtls_sha1_init;
    pub const mbedtls_sha1_free = __root.mbedtls_sha1_free;
    pub const mbedtls_sha1_clone = __root.mbedtls_sha1_clone;
    pub const mbedtls_sha1_starts = __root.mbedtls_sha1_starts;
    pub const mbedtls_sha1_update = __root.mbedtls_sha1_update;
    pub const mbedtls_sha1_finish = __root.mbedtls_sha1_finish;
    pub const mbedtls_internal_sha1_process = __root.mbedtls_internal_sha1_process;
    pub const init = __root.mbedtls_sha1_init;
    pub const free = __root.mbedtls_sha1_free;
    pub const clone = __root.mbedtls_sha1_clone;
    pub const starts = __root.mbedtls_sha1_starts;
    pub const update = __root.mbedtls_sha1_update;
    pub const finish = __root.mbedtls_sha1_finish;
    pub const process = __root.mbedtls_internal_sha1_process;
};
pub const mbedtls_sha1_context = struct_mbedtls_sha1_context;
pub extern fn mbedtls_sha1_init(ctx: [*c]mbedtls_sha1_context) void;
pub extern fn mbedtls_sha1_free(ctx: [*c]mbedtls_sha1_context) void;
pub extern fn mbedtls_sha1_clone(dst: [*c]mbedtls_sha1_context, src: [*c]const mbedtls_sha1_context) void;
pub extern fn mbedtls_sha1_starts(ctx: [*c]mbedtls_sha1_context) c_int;
pub extern fn mbedtls_sha1_update(ctx: [*c]mbedtls_sha1_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_sha1_finish(ctx: [*c]mbedtls_sha1_context, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_sha1_process(ctx: [*c]mbedtls_sha1_context, data: [*c]const u8) c_int;
pub extern fn mbedtls_sha1(input: [*c]const u8, ilen: usize, output: [*c]u8) c_int;
pub extern fn mbedtls_sha1_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_sha256_context = extern struct {
    private_buffer: [64]u8 = @import("std").mem.zeroes([64]u8),
    private_total: [2]u32 = @import("std").mem.zeroes([2]u32),
    private_state: [8]u32 = @import("std").mem.zeroes([8]u32),
    private_is224: c_int = 0,
    pub const mbedtls_sha256_init = __root.mbedtls_sha256_init;
    pub const mbedtls_sha256_free = __root.mbedtls_sha256_free;
    pub const mbedtls_sha256_clone = __root.mbedtls_sha256_clone;
    pub const mbedtls_sha256_starts = __root.mbedtls_sha256_starts;
    pub const mbedtls_sha256_update = __root.mbedtls_sha256_update;
    pub const mbedtls_sha256_finish = __root.mbedtls_sha256_finish;
    pub const mbedtls_internal_sha256_process = __root.mbedtls_internal_sha256_process;
    pub const init = __root.mbedtls_sha256_init;
    pub const free = __root.mbedtls_sha256_free;
    pub const clone = __root.mbedtls_sha256_clone;
    pub const starts = __root.mbedtls_sha256_starts;
    pub const update = __root.mbedtls_sha256_update;
    pub const finish = __root.mbedtls_sha256_finish;
    pub const process = __root.mbedtls_internal_sha256_process;
};
pub const mbedtls_sha256_context = struct_mbedtls_sha256_context;
pub extern fn mbedtls_sha256_init(ctx: [*c]mbedtls_sha256_context) void;
pub extern fn mbedtls_sha256_free(ctx: [*c]mbedtls_sha256_context) void;
pub extern fn mbedtls_sha256_clone(dst: [*c]mbedtls_sha256_context, src: [*c]const mbedtls_sha256_context) void;
pub extern fn mbedtls_sha256_starts(ctx: [*c]mbedtls_sha256_context, is224: c_int) c_int;
pub extern fn mbedtls_sha256_update(ctx: [*c]mbedtls_sha256_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_sha256_finish(ctx: [*c]mbedtls_sha256_context, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_sha256_process(ctx: [*c]mbedtls_sha256_context, data: [*c]const u8) c_int;
pub extern fn mbedtls_sha256(input: [*c]const u8, ilen: usize, output: [*c]u8, is224: c_int) c_int;
pub extern fn mbedtls_sha224_self_test(verbose: c_int) c_int;
pub extern fn mbedtls_sha256_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_sha512_context = extern struct {
    private_total: [2]u64 = @import("std").mem.zeroes([2]u64),
    private_state: [8]u64 = @import("std").mem.zeroes([8]u64),
    private_buffer: [128]u8 = @import("std").mem.zeroes([128]u8),
    private_is384: c_int = 0,
    pub const mbedtls_sha512_init = __root.mbedtls_sha512_init;
    pub const mbedtls_sha512_free = __root.mbedtls_sha512_free;
    pub const mbedtls_sha512_clone = __root.mbedtls_sha512_clone;
    pub const mbedtls_sha512_starts = __root.mbedtls_sha512_starts;
    pub const mbedtls_sha512_update = __root.mbedtls_sha512_update;
    pub const mbedtls_sha512_finish = __root.mbedtls_sha512_finish;
    pub const mbedtls_internal_sha512_process = __root.mbedtls_internal_sha512_process;
    pub const init = __root.mbedtls_sha512_init;
    pub const free = __root.mbedtls_sha512_free;
    pub const clone = __root.mbedtls_sha512_clone;
    pub const starts = __root.mbedtls_sha512_starts;
    pub const update = __root.mbedtls_sha512_update;
    pub const finish = __root.mbedtls_sha512_finish;
    pub const process = __root.mbedtls_internal_sha512_process;
};
pub const mbedtls_sha512_context = struct_mbedtls_sha512_context;
pub extern fn mbedtls_sha512_init(ctx: [*c]mbedtls_sha512_context) void;
pub extern fn mbedtls_sha512_free(ctx: [*c]mbedtls_sha512_context) void;
pub extern fn mbedtls_sha512_clone(dst: [*c]mbedtls_sha512_context, src: [*c]const mbedtls_sha512_context) void;
pub extern fn mbedtls_sha512_starts(ctx: [*c]mbedtls_sha512_context, is384: c_int) c_int;
pub extern fn mbedtls_sha512_update(ctx: [*c]mbedtls_sha512_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_sha512_finish(ctx: [*c]mbedtls_sha512_context, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_sha512_process(ctx: [*c]mbedtls_sha512_context, data: [*c]const u8) c_int;
pub extern fn mbedtls_sha512(input: [*c]const u8, ilen: usize, output: [*c]u8, is384: c_int) c_int;
pub extern fn mbedtls_sha384_self_test(verbose: c_int) c_int;
pub extern fn mbedtls_sha512_self_test(verbose: c_int) c_int;
pub const MBEDTLS_SHA3_NONE: c_int = 0;
pub const MBEDTLS_SHA3_224: c_int = 1;
pub const MBEDTLS_SHA3_256: c_int = 2;
pub const MBEDTLS_SHA3_384: c_int = 3;
pub const MBEDTLS_SHA3_512: c_int = 4;
pub const mbedtls_sha3_id = c_uint;
pub const mbedtls_sha3_context = extern struct {
    private_state: [25]u64 = @import("std").mem.zeroes([25]u64),
    private_index: u32 = 0,
    private_olen: u16 = 0,
    private_max_block_size: u16 = 0,
    pub const mbedtls_sha3_init = __root.mbedtls_sha3_init;
    pub const mbedtls_sha3_free = __root.mbedtls_sha3_free;
    pub const mbedtls_sha3_clone = __root.mbedtls_sha3_clone;
    pub const mbedtls_sha3_starts = __root.mbedtls_sha3_starts;
    pub const mbedtls_sha3_update = __root.mbedtls_sha3_update;
    pub const mbedtls_sha3_finish = __root.mbedtls_sha3_finish;
    pub const init = __root.mbedtls_sha3_init;
    pub const free = __root.mbedtls_sha3_free;
    pub const clone = __root.mbedtls_sha3_clone;
    pub const starts = __root.mbedtls_sha3_starts;
    pub const update = __root.mbedtls_sha3_update;
    pub const finish = __root.mbedtls_sha3_finish;
};
pub extern fn mbedtls_sha3_init(ctx: [*c]mbedtls_sha3_context) void;
pub extern fn mbedtls_sha3_free(ctx: [*c]mbedtls_sha3_context) void;
pub extern fn mbedtls_sha3_clone(dst: [*c]mbedtls_sha3_context, src: [*c]const mbedtls_sha3_context) void;
pub extern fn mbedtls_sha3_starts(ctx: [*c]mbedtls_sha3_context, id: mbedtls_sha3_id) c_int;
pub extern fn mbedtls_sha3_update(ctx: [*c]mbedtls_sha3_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_sha3_finish(ctx: [*c]mbedtls_sha3_context, output: [*c]u8, olen: usize) c_int;
pub extern fn mbedtls_sha3(id: mbedtls_sha3_id, input: [*c]const u8, ilen: usize, output: [*c]u8, olen: usize) c_int;
pub extern fn mbedtls_sha3_self_test(verbose: c_int) c_int;
const union_unnamed_15 = extern union {
    dummy: c_uint,
    md5: mbedtls_md5_context,
    ripemd160: mbedtls_ripemd160_context,
    sha1: mbedtls_sha1_context,
    sha256: mbedtls_sha256_context,
    sha512: mbedtls_sha512_context,
    sha3: mbedtls_sha3_context,
};
pub const mbedtls_psa_hash_operation_t = extern struct {
    private_alg: psa_algorithm_t = 0,
    private_ctx: union_unnamed_15 = @import("std").mem.zeroes(union_unnamed_15),
};
pub const MBEDTLS_CIPHER_ID_NONE: c_int = 0;
pub const MBEDTLS_CIPHER_ID_NULL: c_int = 1;
pub const MBEDTLS_CIPHER_ID_AES: c_int = 2;
pub const MBEDTLS_CIPHER_ID_DES: c_int = 3;
pub const MBEDTLS_CIPHER_ID_3DES: c_int = 4;
pub const MBEDTLS_CIPHER_ID_CAMELLIA: c_int = 5;
pub const MBEDTLS_CIPHER_ID_ARIA: c_int = 6;
pub const MBEDTLS_CIPHER_ID_CHACHA20: c_int = 7;
pub const mbedtls_cipher_id_t = c_uint;
pub const MBEDTLS_CIPHER_NONE: c_int = 0;
pub const MBEDTLS_CIPHER_NULL: c_int = 1;
pub const MBEDTLS_CIPHER_AES_128_ECB: c_int = 2;
pub const MBEDTLS_CIPHER_AES_192_ECB: c_int = 3;
pub const MBEDTLS_CIPHER_AES_256_ECB: c_int = 4;
pub const MBEDTLS_CIPHER_AES_128_CBC: c_int = 5;
pub const MBEDTLS_CIPHER_AES_192_CBC: c_int = 6;
pub const MBEDTLS_CIPHER_AES_256_CBC: c_int = 7;
pub const MBEDTLS_CIPHER_AES_128_CFB128: c_int = 8;
pub const MBEDTLS_CIPHER_AES_192_CFB128: c_int = 9;
pub const MBEDTLS_CIPHER_AES_256_CFB128: c_int = 10;
pub const MBEDTLS_CIPHER_AES_128_CTR: c_int = 11;
pub const MBEDTLS_CIPHER_AES_192_CTR: c_int = 12;
pub const MBEDTLS_CIPHER_AES_256_CTR: c_int = 13;
pub const MBEDTLS_CIPHER_AES_128_GCM: c_int = 14;
pub const MBEDTLS_CIPHER_AES_192_GCM: c_int = 15;
pub const MBEDTLS_CIPHER_AES_256_GCM: c_int = 16;
pub const MBEDTLS_CIPHER_CAMELLIA_128_ECB: c_int = 17;
pub const MBEDTLS_CIPHER_CAMELLIA_192_ECB: c_int = 18;
pub const MBEDTLS_CIPHER_CAMELLIA_256_ECB: c_int = 19;
pub const MBEDTLS_CIPHER_CAMELLIA_128_CBC: c_int = 20;
pub const MBEDTLS_CIPHER_CAMELLIA_192_CBC: c_int = 21;
pub const MBEDTLS_CIPHER_CAMELLIA_256_CBC: c_int = 22;
pub const MBEDTLS_CIPHER_CAMELLIA_128_CFB128: c_int = 23;
pub const MBEDTLS_CIPHER_CAMELLIA_192_CFB128: c_int = 24;
pub const MBEDTLS_CIPHER_CAMELLIA_256_CFB128: c_int = 25;
pub const MBEDTLS_CIPHER_CAMELLIA_128_CTR: c_int = 26;
pub const MBEDTLS_CIPHER_CAMELLIA_192_CTR: c_int = 27;
pub const MBEDTLS_CIPHER_CAMELLIA_256_CTR: c_int = 28;
pub const MBEDTLS_CIPHER_CAMELLIA_128_GCM: c_int = 29;
pub const MBEDTLS_CIPHER_CAMELLIA_192_GCM: c_int = 30;
pub const MBEDTLS_CIPHER_CAMELLIA_256_GCM: c_int = 31;
pub const MBEDTLS_CIPHER_DES_ECB: c_int = 32;
pub const MBEDTLS_CIPHER_DES_CBC: c_int = 33;
pub const MBEDTLS_CIPHER_DES_EDE_ECB: c_int = 34;
pub const MBEDTLS_CIPHER_DES_EDE_CBC: c_int = 35;
pub const MBEDTLS_CIPHER_DES_EDE3_ECB: c_int = 36;
pub const MBEDTLS_CIPHER_DES_EDE3_CBC: c_int = 37;
pub const MBEDTLS_CIPHER_AES_128_CCM: c_int = 38;
pub const MBEDTLS_CIPHER_AES_192_CCM: c_int = 39;
pub const MBEDTLS_CIPHER_AES_256_CCM: c_int = 40;
pub const MBEDTLS_CIPHER_AES_128_CCM_STAR_NO_TAG: c_int = 41;
pub const MBEDTLS_CIPHER_AES_192_CCM_STAR_NO_TAG: c_int = 42;
pub const MBEDTLS_CIPHER_AES_256_CCM_STAR_NO_TAG: c_int = 43;
pub const MBEDTLS_CIPHER_CAMELLIA_128_CCM: c_int = 44;
pub const MBEDTLS_CIPHER_CAMELLIA_192_CCM: c_int = 45;
pub const MBEDTLS_CIPHER_CAMELLIA_256_CCM: c_int = 46;
pub const MBEDTLS_CIPHER_CAMELLIA_128_CCM_STAR_NO_TAG: c_int = 47;
pub const MBEDTLS_CIPHER_CAMELLIA_192_CCM_STAR_NO_TAG: c_int = 48;
pub const MBEDTLS_CIPHER_CAMELLIA_256_CCM_STAR_NO_TAG: c_int = 49;
pub const MBEDTLS_CIPHER_ARIA_128_ECB: c_int = 50;
pub const MBEDTLS_CIPHER_ARIA_192_ECB: c_int = 51;
pub const MBEDTLS_CIPHER_ARIA_256_ECB: c_int = 52;
pub const MBEDTLS_CIPHER_ARIA_128_CBC: c_int = 53;
pub const MBEDTLS_CIPHER_ARIA_192_CBC: c_int = 54;
pub const MBEDTLS_CIPHER_ARIA_256_CBC: c_int = 55;
pub const MBEDTLS_CIPHER_ARIA_128_CFB128: c_int = 56;
pub const MBEDTLS_CIPHER_ARIA_192_CFB128: c_int = 57;
pub const MBEDTLS_CIPHER_ARIA_256_CFB128: c_int = 58;
pub const MBEDTLS_CIPHER_ARIA_128_CTR: c_int = 59;
pub const MBEDTLS_CIPHER_ARIA_192_CTR: c_int = 60;
pub const MBEDTLS_CIPHER_ARIA_256_CTR: c_int = 61;
pub const MBEDTLS_CIPHER_ARIA_128_GCM: c_int = 62;
pub const MBEDTLS_CIPHER_ARIA_192_GCM: c_int = 63;
pub const MBEDTLS_CIPHER_ARIA_256_GCM: c_int = 64;
pub const MBEDTLS_CIPHER_ARIA_128_CCM: c_int = 65;
pub const MBEDTLS_CIPHER_ARIA_192_CCM: c_int = 66;
pub const MBEDTLS_CIPHER_ARIA_256_CCM: c_int = 67;
pub const MBEDTLS_CIPHER_ARIA_128_CCM_STAR_NO_TAG: c_int = 68;
pub const MBEDTLS_CIPHER_ARIA_192_CCM_STAR_NO_TAG: c_int = 69;
pub const MBEDTLS_CIPHER_ARIA_256_CCM_STAR_NO_TAG: c_int = 70;
pub const MBEDTLS_CIPHER_AES_128_OFB: c_int = 71;
pub const MBEDTLS_CIPHER_AES_192_OFB: c_int = 72;
pub const MBEDTLS_CIPHER_AES_256_OFB: c_int = 73;
pub const MBEDTLS_CIPHER_AES_128_XTS: c_int = 74;
pub const MBEDTLS_CIPHER_AES_256_XTS: c_int = 75;
pub const MBEDTLS_CIPHER_CHACHA20: c_int = 76;
pub const MBEDTLS_CIPHER_CHACHA20_POLY1305: c_int = 77;
pub const MBEDTLS_CIPHER_AES_128_KW: c_int = 78;
pub const MBEDTLS_CIPHER_AES_192_KW: c_int = 79;
pub const MBEDTLS_CIPHER_AES_256_KW: c_int = 80;
pub const MBEDTLS_CIPHER_AES_128_KWP: c_int = 81;
pub const MBEDTLS_CIPHER_AES_192_KWP: c_int = 82;
pub const MBEDTLS_CIPHER_AES_256_KWP: c_int = 83;
pub const mbedtls_cipher_type_t = c_uint;
pub const MBEDTLS_MODE_NONE: c_int = 0;
pub const MBEDTLS_MODE_ECB: c_int = 1;
pub const MBEDTLS_MODE_CBC: c_int = 2;
pub const MBEDTLS_MODE_CFB: c_int = 3;
pub const MBEDTLS_MODE_OFB: c_int = 4;
pub const MBEDTLS_MODE_CTR: c_int = 5;
pub const MBEDTLS_MODE_GCM: c_int = 6;
pub const MBEDTLS_MODE_STREAM: c_int = 7;
pub const MBEDTLS_MODE_CCM: c_int = 8;
pub const MBEDTLS_MODE_CCM_STAR_NO_TAG: c_int = 9;
pub const MBEDTLS_MODE_XTS: c_int = 10;
pub const MBEDTLS_MODE_CHACHAPOLY: c_int = 11;
pub const MBEDTLS_MODE_KW: c_int = 12;
pub const MBEDTLS_MODE_KWP: c_int = 13;
pub const mbedtls_cipher_mode_t = c_uint;
pub const MBEDTLS_PADDING_PKCS7: c_int = 0;
pub const MBEDTLS_PADDING_ONE_AND_ZEROS: c_int = 1;
pub const MBEDTLS_PADDING_ZEROS_AND_LEN: c_int = 2;
pub const MBEDTLS_PADDING_ZEROS: c_int = 3;
pub const MBEDTLS_PADDING_NONE: c_int = 4;
pub const mbedtls_cipher_padding_t = c_uint;
pub const MBEDTLS_OPERATION_NONE: c_int = -1;
pub const MBEDTLS_DECRYPT: c_int = 0;
pub const MBEDTLS_ENCRYPT: c_int = 1;
pub const mbedtls_operation_t = c_int;
pub const MBEDTLS_KEY_LENGTH_NONE: c_int = 0;
pub const MBEDTLS_KEY_LENGTH_DES: c_int = 64;
pub const MBEDTLS_KEY_LENGTH_DES_EDE: c_int = 128;
pub const MBEDTLS_KEY_LENGTH_DES_EDE3: c_int = 192;
const enum_unnamed_16 = c_uint;
pub const struct_mbedtls_cipher_base_t = opaque {};
pub const mbedtls_cipher_base_t = struct_mbedtls_cipher_base_t;
pub const struct_mbedtls_cmac_context_t = extern struct {
    private_state: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_unprocessed_block: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_unprocessed_len: usize = 0,
};
pub const mbedtls_cmac_context_t = struct_mbedtls_cmac_context_t; // <scratch space>:161:1: warning: struct demoted to opaque type - has bitfield
pub const struct_mbedtls_cipher_info_t = opaque {
    pub const mbedtls_cipher_info_get_type = __root.mbedtls_cipher_info_get_type;
    pub const mbedtls_cipher_info_get_mode = __root.mbedtls_cipher_info_get_mode;
    pub const mbedtls_cipher_info_get_key_bitlen = __root.mbedtls_cipher_info_get_key_bitlen;
    pub const mbedtls_cipher_info_get_name = __root.mbedtls_cipher_info_get_name;
    pub const mbedtls_cipher_info_get_iv_size = __root.mbedtls_cipher_info_get_iv_size;
    pub const mbedtls_cipher_info_get_block_size = __root.mbedtls_cipher_info_get_block_size;
    pub const mbedtls_cipher_info_has_variable_key_bitlen = __root.mbedtls_cipher_info_has_variable_key_bitlen;
    pub const mbedtls_cipher_info_has_variable_iv_size = __root.mbedtls_cipher_info_has_variable_iv_size;
    pub const mbedtls_cipher_cmac = __root.mbedtls_cipher_cmac;
    pub const @"type" = __root.mbedtls_cipher_info_get_type;
    pub const mode = __root.mbedtls_cipher_info_get_mode;
    pub const bitlen = __root.mbedtls_cipher_info_get_key_bitlen;
    pub const name = __root.mbedtls_cipher_info_get_name;
    pub const size = __root.mbedtls_cipher_info_get_iv_size;
    pub const cmac = __root.mbedtls_cipher_cmac;
};
pub const mbedtls_cipher_info_t = struct_mbedtls_cipher_info_t;
pub const struct_mbedtls_cipher_context_t = extern struct {
    private_cipher_info: ?*const mbedtls_cipher_info_t = null,
    private_key_bitlen: c_int = 0,
    private_operation: mbedtls_operation_t = @import("std").mem.zeroes(mbedtls_operation_t),
    private_add_padding: ?*const fn (output: [*c]u8, olen: usize, data_len: usize) callconv(.c) void = null,
    private_get_padding: ?*const fn (input: [*c]u8, ilen: usize, data_len: [*c]usize) callconv(.c) c_int = null,
    private_unprocessed_data: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_unprocessed_len: usize = 0,
    private_iv: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_iv_size: usize = 0,
    private_cipher_ctx: ?*anyopaque = null,
    private_cmac_ctx: [*c]mbedtls_cmac_context_t = null,
    pub const mbedtls_cipher_init = __root.mbedtls_cipher_init;
    pub const mbedtls_cipher_free = __root.mbedtls_cipher_free;
    pub const mbedtls_cipher_setup = __root.mbedtls_cipher_setup;
    pub const mbedtls_cipher_get_block_size = __root.mbedtls_cipher_get_block_size;
    pub const mbedtls_cipher_get_cipher_mode = __root.mbedtls_cipher_get_cipher_mode;
    pub const mbedtls_cipher_get_iv_size = __root.mbedtls_cipher_get_iv_size;
    pub const mbedtls_cipher_get_type = __root.mbedtls_cipher_get_type;
    pub const mbedtls_cipher_get_name = __root.mbedtls_cipher_get_name;
    pub const mbedtls_cipher_get_key_bitlen = __root.mbedtls_cipher_get_key_bitlen;
    pub const mbedtls_cipher_get_operation = __root.mbedtls_cipher_get_operation;
    pub const mbedtls_cipher_setkey = __root.mbedtls_cipher_setkey;
    pub const mbedtls_cipher_set_padding_mode = __root.mbedtls_cipher_set_padding_mode;
    pub const mbedtls_cipher_set_iv = __root.mbedtls_cipher_set_iv;
    pub const mbedtls_cipher_reset = __root.mbedtls_cipher_reset;
    pub const mbedtls_cipher_update_ad = __root.mbedtls_cipher_update_ad;
    pub const mbedtls_cipher_update = __root.mbedtls_cipher_update;
    pub const mbedtls_cipher_finish = __root.mbedtls_cipher_finish;
    pub const mbedtls_cipher_write_tag = __root.mbedtls_cipher_write_tag;
    pub const mbedtls_cipher_check_tag = __root.mbedtls_cipher_check_tag;
    pub const mbedtls_cipher_crypt = __root.mbedtls_cipher_crypt;
    pub const mbedtls_cipher_auth_encrypt_ext = __root.mbedtls_cipher_auth_encrypt_ext;
    pub const mbedtls_cipher_auth_decrypt_ext = __root.mbedtls_cipher_auth_decrypt_ext;
    pub const mbedtls_cipher_cmac_starts = __root.mbedtls_cipher_cmac_starts;
    pub const mbedtls_cipher_cmac_update = __root.mbedtls_cipher_cmac_update;
    pub const mbedtls_cipher_cmac_finish = __root.mbedtls_cipher_cmac_finish;
    pub const mbedtls_cipher_cmac_reset = __root.mbedtls_cipher_cmac_reset;
    pub const init = __root.mbedtls_cipher_init;
    pub const free = __root.mbedtls_cipher_free;
    pub const setup = __root.mbedtls_cipher_setup;
    pub const size = __root.mbedtls_cipher_get_block_size;
    pub const mode = __root.mbedtls_cipher_get_cipher_mode;
    pub const @"type" = __root.mbedtls_cipher_get_type;
    pub const name = __root.mbedtls_cipher_get_name;
    pub const bitlen = __root.mbedtls_cipher_get_key_bitlen;
    pub const operation = __root.mbedtls_cipher_get_operation;
    pub const setkey = __root.mbedtls_cipher_setkey;
    pub const iv = __root.mbedtls_cipher_set_iv;
    pub const reset = __root.mbedtls_cipher_reset;
    pub const ad = __root.mbedtls_cipher_update_ad;
    pub const update = __root.mbedtls_cipher_update;
    pub const finish = __root.mbedtls_cipher_finish;
    pub const tag = __root.mbedtls_cipher_write_tag;
    pub const crypt = __root.mbedtls_cipher_crypt;
    pub const ext = __root.mbedtls_cipher_auth_encrypt_ext;
    pub const starts = __root.mbedtls_cipher_cmac_starts;
};
pub const mbedtls_cipher_context_t = struct_mbedtls_cipher_context_t;
pub extern fn mbedtls_cipher_list() [*c]const c_int;
pub extern fn mbedtls_cipher_info_from_string(cipher_name: [*c]const u8) ?*const mbedtls_cipher_info_t;
pub extern fn mbedtls_cipher_info_from_type(cipher_type: mbedtls_cipher_type_t) ?*const mbedtls_cipher_info_t;
pub extern fn mbedtls_cipher_info_from_values(cipher_id: mbedtls_cipher_id_t, key_bitlen: c_int, mode: mbedtls_cipher_mode_t) ?*const mbedtls_cipher_info_t;
pub fn mbedtls_cipher_info_get_type(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) mbedtls_cipher_type_t {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return MBEDTLS_CIPHER_NONE;
    } else {
        return info.*.private_type;
    }
}
pub fn mbedtls_cipher_info_get_mode(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) mbedtls_cipher_mode_t {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return MBEDTLS_MODE_NONE;
    } else {
        return info.*.private_mode;
    }
}
pub fn mbedtls_cipher_info_get_key_bitlen(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) usize {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return 0;
    } else {
        return @as(usize, info.*.private_key_bitlen) << @intCast(6);
    }
}
pub fn mbedtls_cipher_info_get_name(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) [*c]const u8 {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return null;
    } else {
        return info.*.private_name;
    }
}
pub fn mbedtls_cipher_info_get_iv_size(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) usize {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return 0;
    }
    return @as(usize, info.*.private_iv_size) << @intCast(2);
}
pub fn mbedtls_cipher_info_get_block_size(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) usize {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return 0;
    }
    return info.*.private_block_size;
}
pub fn mbedtls_cipher_info_has_variable_key_bitlen(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) c_int {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return 0;
    }
    return @as(c_int, @bitCast(@as(c_uint, @truncate(info.*.private_flags)))) & @as(c_int, 2);
}
pub fn mbedtls_cipher_info_has_variable_iv_size(arg_info: ?*const mbedtls_cipher_info_t) callconv(.c) c_int {
    var info = arg_info;
    _ = &info;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(info)))) == @as(?*anyopaque, null)) {
        return 0;
    }
    return @as(c_int, @bitCast(@as(c_uint, @truncate(info.*.private_flags)))) & @as(c_int, 1);
}
pub extern fn mbedtls_cipher_init(ctx: [*c]mbedtls_cipher_context_t) void;
pub extern fn mbedtls_cipher_free(ctx: [*c]mbedtls_cipher_context_t) void;
pub extern fn mbedtls_cipher_setup(ctx: [*c]mbedtls_cipher_context_t, cipher_info: ?*const mbedtls_cipher_info_t) c_int;
pub fn mbedtls_cipher_get_block_size(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) c_uint {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return 0;
    }
    return ctx.*.private_cipher_info.*.private_block_size;
}
pub fn mbedtls_cipher_get_cipher_mode(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) mbedtls_cipher_mode_t {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return MBEDTLS_MODE_NONE;
    }
    return ctx.*.private_cipher_info.*.private_mode;
}
pub fn mbedtls_cipher_get_iv_size(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) c_int {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return 0;
    }
    if (ctx.*.private_iv_size != @as(usize, 0)) {
        return @bitCast(@as(c_uint, @truncate(ctx.*.private_iv_size)));
    }
    return @as(c_int, @bitCast(@as(c_uint, @truncate(ctx.*.private_cipher_info.*.private_iv_size)))) << @intCast(2);
}
pub fn mbedtls_cipher_get_type(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) mbedtls_cipher_type_t {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return MBEDTLS_CIPHER_NONE;
    }
    return ctx.*.private_cipher_info.*.private_type;
}
pub fn mbedtls_cipher_get_name(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) [*c]const u8 {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return null;
    }
    return ctx.*.private_cipher_info.*.private_name;
}
pub fn mbedtls_cipher_get_key_bitlen(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) c_int {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return MBEDTLS_KEY_LENGTH_NONE;
    }
    return @as(c_int, @bitCast(@as(c_uint, @truncate(ctx.*.private_cipher_info.*.private_key_bitlen)))) << @intCast(6);
}
pub fn mbedtls_cipher_get_operation(arg_ctx: [*c]const mbedtls_cipher_context_t) callconv(.c) mbedtls_operation_t {
    var ctx = arg_ctx;
    _ = &ctx;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(ctx.*.private_cipher_info)))) == @as(?*anyopaque, null)) {
        return MBEDTLS_OPERATION_NONE;
    }
    return ctx.*.private_operation;
}
pub extern fn mbedtls_cipher_setkey(ctx: [*c]mbedtls_cipher_context_t, key: [*c]const u8, key_bitlen: c_int, operation: mbedtls_operation_t) c_int;
pub extern fn mbedtls_cipher_set_padding_mode(ctx: [*c]mbedtls_cipher_context_t, mode: mbedtls_cipher_padding_t) c_int;
pub extern fn mbedtls_cipher_set_iv(ctx: [*c]mbedtls_cipher_context_t, iv: [*c]const u8, iv_len: usize) c_int;
pub extern fn mbedtls_cipher_reset(ctx: [*c]mbedtls_cipher_context_t) c_int;
pub extern fn mbedtls_cipher_update_ad(ctx: [*c]mbedtls_cipher_context_t, ad: [*c]const u8, ad_len: usize) c_int;
pub extern fn mbedtls_cipher_update(ctx: [*c]mbedtls_cipher_context_t, input: [*c]const u8, ilen: usize, output: [*c]u8, olen: [*c]usize) c_int;
pub extern fn mbedtls_cipher_finish(ctx: [*c]mbedtls_cipher_context_t, output: [*c]u8, olen: [*c]usize) c_int;
pub extern fn mbedtls_cipher_write_tag(ctx: [*c]mbedtls_cipher_context_t, tag: [*c]u8, tag_len: usize) c_int;
pub extern fn mbedtls_cipher_check_tag(ctx: [*c]mbedtls_cipher_context_t, tag: [*c]const u8, tag_len: usize) c_int;
pub extern fn mbedtls_cipher_crypt(ctx: [*c]mbedtls_cipher_context_t, iv: [*c]const u8, iv_len: usize, input: [*c]const u8, ilen: usize, output: [*c]u8, olen: [*c]usize) c_int;
pub extern fn mbedtls_cipher_auth_encrypt_ext(ctx: [*c]mbedtls_cipher_context_t, iv: [*c]const u8, iv_len: usize, ad: [*c]const u8, ad_len: usize, input: [*c]const u8, ilen: usize, output: [*c]u8, output_len: usize, olen: [*c]usize, tag_len: usize) c_int;
pub extern fn mbedtls_cipher_auth_decrypt_ext(ctx: [*c]mbedtls_cipher_context_t, iv: [*c]const u8, iv_len: usize, ad: [*c]const u8, ad_len: usize, input: [*c]const u8, ilen: usize, output: [*c]u8, output_len: usize, olen: [*c]usize, tag_len: usize) c_int;
const union_unnamed_17 = extern union {
    private_dummy: c_uint,
    private_cipher: mbedtls_cipher_context_t,
};
pub const mbedtls_psa_cipher_operation_t = extern struct {
    private_alg: psa_algorithm_t = 0,
    private_iv_length: u8 = 0,
    private_block_length: u8 = 0,
    private_ctx: union_unnamed_17 = @import("std").mem.zeroes(union_unnamed_17),
};
pub const psa_driver_hash_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_hash_operation_t,
};
pub const psa_driver_cipher_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_cipher_operation_t,
};
pub const struct_psa_hash_operation_s = extern struct {
    private_id: c_uint = 0,
    private_ctx: psa_driver_hash_context_t = @import("std").mem.zeroes(psa_driver_hash_context_t),
    pub const psa_hash_setup = __root.psa_hash_setup;
    pub const psa_hash_update = __root.psa_hash_update;
    pub const psa_hash_finish = __root.psa_hash_finish;
    pub const psa_hash_verify = __root.psa_hash_verify;
    pub const psa_hash_abort = __root.psa_hash_abort;
    pub const psa_hash_clone = __root.psa_hash_clone;
    pub const setup = __root.psa_hash_setup;
    pub const update = __root.psa_hash_update;
    pub const finish = __root.psa_hash_finish;
    pub const verify = __root.psa_hash_verify;
    pub const abort = __root.psa_hash_abort;
    pub const clone = __root.psa_hash_clone;
};
pub fn psa_hash_operation_init() callconv(.c) struct_psa_hash_operation_s {
    const v: struct_psa_hash_operation_s = struct_psa_hash_operation_s{
        .private_id = 0,
        .private_ctx = psa_driver_hash_context_t{
            .dummy = 0,
        },
    };
    _ = &v;
    return v;
} // <scratch space>:218:1: warning: struct demoted to opaque type - has bitfield
pub const struct_psa_cipher_operation_s = opaque {
    pub const psa_cipher_encrypt_setup = __root.psa_cipher_encrypt_setup;
    pub const psa_cipher_decrypt_setup = __root.psa_cipher_decrypt_setup;
    pub const psa_cipher_generate_iv = __root.psa_cipher_generate_iv;
    pub const psa_cipher_set_iv = __root.psa_cipher_set_iv;
    pub const psa_cipher_update = __root.psa_cipher_update;
    pub const psa_cipher_finish = __root.psa_cipher_finish;
    pub const psa_cipher_abort = __root.psa_cipher_abort;
    pub const setup = __root.psa_cipher_encrypt_setup;
    pub const iv = __root.psa_cipher_generate_iv;
    pub const update = __root.psa_cipher_update;
    pub const finish = __root.psa_cipher_finish;
    pub const abort = __root.psa_cipher_abort;
};
pub fn psa_cipher_operation_init() callconv(.c) struct_psa_cipher_operation_s {
    const v: struct_psa_cipher_operation_s = struct_psa_cipher_operation_s{
        .private_id = 0,
        .private_iv_required = 0,
        .private_iv_set = 0,
        .private_default_iv_length = 0,
        .private_ctx = psa_driver_cipher_context_t{
            .dummy = 0,
        },
    };
    _ = &v;
    return v;
}
pub extern fn mbedtls_cipher_cmac_starts(ctx: [*c]mbedtls_cipher_context_t, key: [*c]const u8, keybits: usize) c_int;
pub extern fn mbedtls_cipher_cmac_update(ctx: [*c]mbedtls_cipher_context_t, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_cipher_cmac_finish(ctx: [*c]mbedtls_cipher_context_t, output: [*c]u8) c_int;
pub extern fn mbedtls_cipher_cmac_reset(ctx: [*c]mbedtls_cipher_context_t) c_int;
pub extern fn mbedtls_cipher_cmac(cipher_info: ?*const mbedtls_cipher_info_t, key: [*c]const u8, keylen: usize, input: [*c]const u8, ilen: usize, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_cmac_prf_128(key: [*c]const u8, key_len: usize, input: [*c]const u8, in_len: usize, output: [*c]u8) c_int;
pub extern fn mbedtls_cmac_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_gcm_context = extern struct {
    private_cipher_ctx: mbedtls_cipher_context_t = @import("std").mem.zeroes(mbedtls_cipher_context_t),
    private_H: [16][2]u64 = @import("std").mem.zeroes([16][2]u64),
    private_len: u64 = 0,
    private_add_len: u64 = 0,
    private_base_ectr: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_y: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_buf: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_mode: u8 = 0,
    private_acceleration: u8 = 0,
    pub const mbedtls_gcm_init = __root.mbedtls_gcm_init;
    pub const mbedtls_gcm_setkey = __root.mbedtls_gcm_setkey;
    pub const mbedtls_gcm_crypt_and_tag = __root.mbedtls_gcm_crypt_and_tag;
    pub const mbedtls_gcm_auth_decrypt = __root.mbedtls_gcm_auth_decrypt;
    pub const mbedtls_gcm_starts = __root.mbedtls_gcm_starts;
    pub const mbedtls_gcm_update_ad = __root.mbedtls_gcm_update_ad;
    pub const mbedtls_gcm_update = __root.mbedtls_gcm_update;
    pub const mbedtls_gcm_finish = __root.mbedtls_gcm_finish;
    pub const mbedtls_gcm_free = __root.mbedtls_gcm_free;
    pub const init = __root.mbedtls_gcm_init;
    pub const setkey = __root.mbedtls_gcm_setkey;
    pub const tag = __root.mbedtls_gcm_crypt_and_tag;
    pub const decrypt = __root.mbedtls_gcm_auth_decrypt;
    pub const starts = __root.mbedtls_gcm_starts;
    pub const ad = __root.mbedtls_gcm_update_ad;
    pub const update = __root.mbedtls_gcm_update;
    pub const finish = __root.mbedtls_gcm_finish;
    pub const free = __root.mbedtls_gcm_free;
};
pub const mbedtls_gcm_context = struct_mbedtls_gcm_context;
pub extern fn mbedtls_gcm_init(ctx: [*c]mbedtls_gcm_context) void;
pub extern fn mbedtls_gcm_setkey(ctx: [*c]mbedtls_gcm_context, cipher: mbedtls_cipher_id_t, key: [*c]const u8, keybits: c_uint) c_int;
pub extern fn mbedtls_gcm_crypt_and_tag(ctx: [*c]mbedtls_gcm_context, mode: c_int, length: usize, iv: [*c]const u8, iv_len: usize, add: [*c]const u8, add_len: usize, input: [*c]const u8, output: [*c]u8, tag_len: usize, tag: [*c]u8) c_int;
pub extern fn mbedtls_gcm_auth_decrypt(ctx: [*c]mbedtls_gcm_context, length: usize, iv: [*c]const u8, iv_len: usize, add: [*c]const u8, add_len: usize, tag: [*c]const u8, tag_len: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_gcm_starts(ctx: [*c]mbedtls_gcm_context, mode: c_int, iv: [*c]const u8, iv_len: usize) c_int;
pub extern fn mbedtls_gcm_update_ad(ctx: [*c]mbedtls_gcm_context, add: [*c]const u8, add_len: usize) c_int;
pub extern fn mbedtls_gcm_update(ctx: [*c]mbedtls_gcm_context, input: [*c]const u8, input_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) c_int;
pub extern fn mbedtls_gcm_finish(ctx: [*c]mbedtls_gcm_context, output: [*c]u8, output_size: usize, output_length: [*c]usize, tag: [*c]u8, tag_len: usize) c_int;
pub extern fn mbedtls_gcm_free(ctx: [*c]mbedtls_gcm_context) void;
pub extern fn mbedtls_gcm_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_ccm_context = extern struct {
    private_y: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_ctr: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_plaintext_len: usize = 0,
    private_add_len: usize = 0,
    private_tag_len: usize = 0,
    private_processed: usize = 0,
    private_q: c_uint = 0,
    private_mode: c_uint = 0,
    private_cipher_ctx: mbedtls_cipher_context_t = @import("std").mem.zeroes(mbedtls_cipher_context_t),
    private_state: c_int = 0,
    pub const mbedtls_ccm_init = __root.mbedtls_ccm_init;
    pub const mbedtls_ccm_setkey = __root.mbedtls_ccm_setkey;
    pub const mbedtls_ccm_free = __root.mbedtls_ccm_free;
    pub const mbedtls_ccm_encrypt_and_tag = __root.mbedtls_ccm_encrypt_and_tag;
    pub const mbedtls_ccm_star_encrypt_and_tag = __root.mbedtls_ccm_star_encrypt_and_tag;
    pub const mbedtls_ccm_auth_decrypt = __root.mbedtls_ccm_auth_decrypt;
    pub const mbedtls_ccm_star_auth_decrypt = __root.mbedtls_ccm_star_auth_decrypt;
    pub const mbedtls_ccm_starts = __root.mbedtls_ccm_starts;
    pub const mbedtls_ccm_set_lengths = __root.mbedtls_ccm_set_lengths;
    pub const mbedtls_ccm_update_ad = __root.mbedtls_ccm_update_ad;
    pub const mbedtls_ccm_update = __root.mbedtls_ccm_update;
    pub const mbedtls_ccm_finish = __root.mbedtls_ccm_finish;
    pub const init = __root.mbedtls_ccm_init;
    pub const setkey = __root.mbedtls_ccm_setkey;
    pub const free = __root.mbedtls_ccm_free;
    pub const tag = __root.mbedtls_ccm_encrypt_and_tag;
    pub const decrypt = __root.mbedtls_ccm_auth_decrypt;
    pub const starts = __root.mbedtls_ccm_starts;
    pub const lengths = __root.mbedtls_ccm_set_lengths;
    pub const ad = __root.mbedtls_ccm_update_ad;
    pub const update = __root.mbedtls_ccm_update;
    pub const finish = __root.mbedtls_ccm_finish;
};
pub const mbedtls_ccm_context = struct_mbedtls_ccm_context;
pub extern fn mbedtls_ccm_init(ctx: [*c]mbedtls_ccm_context) void;
pub extern fn mbedtls_ccm_setkey(ctx: [*c]mbedtls_ccm_context, cipher: mbedtls_cipher_id_t, key: [*c]const u8, keybits: c_uint) c_int;
pub extern fn mbedtls_ccm_free(ctx: [*c]mbedtls_ccm_context) void;
pub extern fn mbedtls_ccm_encrypt_and_tag(ctx: [*c]mbedtls_ccm_context, length: usize, iv: [*c]const u8, iv_len: usize, ad: [*c]const u8, ad_len: usize, input: [*c]const u8, output: [*c]u8, tag: [*c]u8, tag_len: usize) c_int;
pub extern fn mbedtls_ccm_star_encrypt_and_tag(ctx: [*c]mbedtls_ccm_context, length: usize, iv: [*c]const u8, iv_len: usize, ad: [*c]const u8, ad_len: usize, input: [*c]const u8, output: [*c]u8, tag: [*c]u8, tag_len: usize) c_int;
pub extern fn mbedtls_ccm_auth_decrypt(ctx: [*c]mbedtls_ccm_context, length: usize, iv: [*c]const u8, iv_len: usize, ad: [*c]const u8, ad_len: usize, input: [*c]const u8, output: [*c]u8, tag: [*c]const u8, tag_len: usize) c_int;
pub extern fn mbedtls_ccm_star_auth_decrypt(ctx: [*c]mbedtls_ccm_context, length: usize, iv: [*c]const u8, iv_len: usize, ad: [*c]const u8, ad_len: usize, input: [*c]const u8, output: [*c]u8, tag: [*c]const u8, tag_len: usize) c_int;
pub extern fn mbedtls_ccm_starts(ctx: [*c]mbedtls_ccm_context, mode: c_int, iv: [*c]const u8, iv_len: usize) c_int;
pub extern fn mbedtls_ccm_set_lengths(ctx: [*c]mbedtls_ccm_context, total_ad_len: usize, plaintext_len: usize, tag_len: usize) c_int;
pub extern fn mbedtls_ccm_update_ad(ctx: [*c]mbedtls_ccm_context, ad: [*c]const u8, ad_len: usize) c_int;
pub extern fn mbedtls_ccm_update(ctx: [*c]mbedtls_ccm_context, input: [*c]const u8, input_len: usize, output: [*c]u8, output_size: usize, output_len: [*c]usize) c_int;
pub extern fn mbedtls_ccm_finish(ctx: [*c]mbedtls_ccm_context, tag: [*c]u8, tag_len: usize) c_int;
pub extern fn mbedtls_ccm_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_poly1305_context = extern struct {
    private_r: [4]u32 = @import("std").mem.zeroes([4]u32),
    private_s: [4]u32 = @import("std").mem.zeroes([4]u32),
    private_acc: [5]u32 = @import("std").mem.zeroes([5]u32),
    private_queue: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_queue_len: usize = 0,
    pub const mbedtls_poly1305_init = __root.mbedtls_poly1305_init;
    pub const mbedtls_poly1305_free = __root.mbedtls_poly1305_free;
    pub const mbedtls_poly1305_starts = __root.mbedtls_poly1305_starts;
    pub const mbedtls_poly1305_update = __root.mbedtls_poly1305_update;
    pub const mbedtls_poly1305_finish = __root.mbedtls_poly1305_finish;
    pub const init = __root.mbedtls_poly1305_init;
    pub const free = __root.mbedtls_poly1305_free;
    pub const starts = __root.mbedtls_poly1305_starts;
    pub const update = __root.mbedtls_poly1305_update;
    pub const finish = __root.mbedtls_poly1305_finish;
};
pub const mbedtls_poly1305_context = struct_mbedtls_poly1305_context;
pub extern fn mbedtls_poly1305_init(ctx: [*c]mbedtls_poly1305_context) void;
pub extern fn mbedtls_poly1305_free(ctx: [*c]mbedtls_poly1305_context) void;
pub extern fn mbedtls_poly1305_starts(ctx: [*c]mbedtls_poly1305_context, key: [*c]const u8) c_int;
pub extern fn mbedtls_poly1305_update(ctx: [*c]mbedtls_poly1305_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_poly1305_finish(ctx: [*c]mbedtls_poly1305_context, mac: [*c]u8) c_int;
pub extern fn mbedtls_poly1305_mac(key: [*c]const u8, input: [*c]const u8, ilen: usize, mac: [*c]u8) c_int;
pub extern fn mbedtls_poly1305_self_test(verbose: c_int) c_int;
pub const MBEDTLS_CHACHAPOLY_ENCRYPT: c_int = 0;
pub const MBEDTLS_CHACHAPOLY_DECRYPT: c_int = 1;
pub const mbedtls_chachapoly_mode_t = c_uint;
pub const struct_mbedtls_chacha20_context = extern struct {
    private_state: [16]u32 = @import("std").mem.zeroes([16]u32),
    private_keystream8: [64]u8 = @import("std").mem.zeroes([64]u8),
    private_keystream_bytes_used: usize = 0,
    pub const mbedtls_chacha20_init = __root.mbedtls_chacha20_init;
    pub const mbedtls_chacha20_free = __root.mbedtls_chacha20_free;
    pub const mbedtls_chacha20_setkey = __root.mbedtls_chacha20_setkey;
    pub const mbedtls_chacha20_starts = __root.mbedtls_chacha20_starts;
    pub const mbedtls_chacha20_update = __root.mbedtls_chacha20_update;
    pub const init = __root.mbedtls_chacha20_init;
    pub const free = __root.mbedtls_chacha20_free;
    pub const setkey = __root.mbedtls_chacha20_setkey;
    pub const starts = __root.mbedtls_chacha20_starts;
    pub const update = __root.mbedtls_chacha20_update;
};
pub const mbedtls_chacha20_context = struct_mbedtls_chacha20_context;
pub extern fn mbedtls_chacha20_init(ctx: [*c]mbedtls_chacha20_context) void;
pub extern fn mbedtls_chacha20_free(ctx: [*c]mbedtls_chacha20_context) void;
pub extern fn mbedtls_chacha20_setkey(ctx: [*c]mbedtls_chacha20_context, key: [*c]const u8) c_int;
pub extern fn mbedtls_chacha20_starts(ctx: [*c]mbedtls_chacha20_context, nonce: [*c]const u8, counter: u32) c_int;
pub extern fn mbedtls_chacha20_update(ctx: [*c]mbedtls_chacha20_context, size: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_chacha20_crypt(key: [*c]const u8, nonce: [*c]const u8, counter: u32, size: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_chacha20_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_chachapoly_context = extern struct {
    private_chacha20_ctx: mbedtls_chacha20_context = @import("std").mem.zeroes(mbedtls_chacha20_context),
    private_poly1305_ctx: mbedtls_poly1305_context = @import("std").mem.zeroes(mbedtls_poly1305_context),
    private_aad_len: u64 = 0,
    private_ciphertext_len: u64 = 0,
    private_state: c_int = 0,
    private_mode: mbedtls_chachapoly_mode_t = @import("std").mem.zeroes(mbedtls_chachapoly_mode_t),
    pub const mbedtls_chachapoly_init = __root.mbedtls_chachapoly_init;
    pub const mbedtls_chachapoly_free = __root.mbedtls_chachapoly_free;
    pub const mbedtls_chachapoly_setkey = __root.mbedtls_chachapoly_setkey;
    pub const mbedtls_chachapoly_starts = __root.mbedtls_chachapoly_starts;
    pub const mbedtls_chachapoly_update_aad = __root.mbedtls_chachapoly_update_aad;
    pub const mbedtls_chachapoly_update = __root.mbedtls_chachapoly_update;
    pub const mbedtls_chachapoly_finish = __root.mbedtls_chachapoly_finish;
    pub const mbedtls_chachapoly_encrypt_and_tag = __root.mbedtls_chachapoly_encrypt_and_tag;
    pub const mbedtls_chachapoly_auth_decrypt = __root.mbedtls_chachapoly_auth_decrypt;
    pub const init = __root.mbedtls_chachapoly_init;
    pub const free = __root.mbedtls_chachapoly_free;
    pub const setkey = __root.mbedtls_chachapoly_setkey;
    pub const starts = __root.mbedtls_chachapoly_starts;
    pub const aad = __root.mbedtls_chachapoly_update_aad;
    pub const update = __root.mbedtls_chachapoly_update;
    pub const finish = __root.mbedtls_chachapoly_finish;
    pub const tag = __root.mbedtls_chachapoly_encrypt_and_tag;
    pub const decrypt = __root.mbedtls_chachapoly_auth_decrypt;
};
pub const mbedtls_chachapoly_context = struct_mbedtls_chachapoly_context;
pub extern fn mbedtls_chachapoly_init(ctx: [*c]mbedtls_chachapoly_context) void;
pub extern fn mbedtls_chachapoly_free(ctx: [*c]mbedtls_chachapoly_context) void;
pub extern fn mbedtls_chachapoly_setkey(ctx: [*c]mbedtls_chachapoly_context, key: [*c]const u8) c_int;
pub extern fn mbedtls_chachapoly_starts(ctx: [*c]mbedtls_chachapoly_context, nonce: [*c]const u8, mode: mbedtls_chachapoly_mode_t) c_int;
pub extern fn mbedtls_chachapoly_update_aad(ctx: [*c]mbedtls_chachapoly_context, aad: [*c]const u8, aad_len: usize) c_int;
pub extern fn mbedtls_chachapoly_update(ctx: [*c]mbedtls_chachapoly_context, len: usize, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_chachapoly_finish(ctx: [*c]mbedtls_chachapoly_context, mac: [*c]u8) c_int;
pub extern fn mbedtls_chachapoly_encrypt_and_tag(ctx: [*c]mbedtls_chachapoly_context, length: usize, nonce: [*c]const u8, aad: [*c]const u8, aad_len: usize, input: [*c]const u8, output: [*c]u8, tag: [*c]u8) c_int;
pub extern fn mbedtls_chachapoly_auth_decrypt(ctx: [*c]mbedtls_chachapoly_context, length: usize, nonce: [*c]const u8, aad: [*c]const u8, aad_len: usize, tag: [*c]const u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_chachapoly_self_test(verbose: c_int) c_int;
pub const mbedtls_psa_hmac_operation_t = extern struct {
    private_alg: psa_algorithm_t = 0,
    hash_ctx: struct_psa_hash_operation_s = @import("std").mem.zeroes(struct_psa_hash_operation_s),
    private_opad: [144]u8 = @import("std").mem.zeroes([144]u8),
};
const union_unnamed_18 = extern union {
    private_dummy: c_uint,
    private_hmac: mbedtls_psa_hmac_operation_t,
    private_cmac: mbedtls_cipher_context_t,
};
pub const mbedtls_psa_mac_operation_t = extern struct {
    private_alg: psa_algorithm_t = 0,
    private_ctx: union_unnamed_18 = @import("std").mem.zeroes(union_unnamed_18),
}; // <scratch space>:267:1: warning: struct demoted to opaque type - has bitfield
pub const mbedtls_psa_aead_operation_t = opaque {};
pub const mbedtls_psa_sign_hash_interruptible_operation_t = extern struct {
    private_dummy: c_uint = 0,
};
pub const mbedtls_psa_verify_hash_interruptible_operation_t = extern struct {
    private_dummy: c_uint = 0,
};
pub const MBEDTLS_ECJPAKE_CLIENT: c_int = 0;
pub const MBEDTLS_ECJPAKE_SERVER: c_int = 1;
pub const MBEDTLS_ECJPAKE_NONE: c_int = 2;
pub const mbedtls_ecjpake_role = c_uint;
pub const struct_mbedtls_ecjpake_context = extern struct {
    private_md_type: mbedtls_md_type_t = @import("std").mem.zeroes(mbedtls_md_type_t),
    private_grp: mbedtls_ecp_group = @import("std").mem.zeroes(mbedtls_ecp_group),
    private_role: mbedtls_ecjpake_role = @import("std").mem.zeroes(mbedtls_ecjpake_role),
    private_point_format: c_int = 0,
    private_Xm1: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_Xm2: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_Xp1: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_Xp2: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_Xp: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_xm1: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_xm2: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_s: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    pub const mbedtls_ecjpake_init = __root.mbedtls_ecjpake_init;
    pub const mbedtls_ecjpake_setup = __root.mbedtls_ecjpake_setup;
    pub const mbedtls_ecjpake_set_point_format = __root.mbedtls_ecjpake_set_point_format;
    pub const mbedtls_ecjpake_check = __root.mbedtls_ecjpake_check;
    pub const mbedtls_ecjpake_write_round_one = __root.mbedtls_ecjpake_write_round_one;
    pub const mbedtls_ecjpake_read_round_one = __root.mbedtls_ecjpake_read_round_one;
    pub const mbedtls_ecjpake_write_round_two = __root.mbedtls_ecjpake_write_round_two;
    pub const mbedtls_ecjpake_read_round_two = __root.mbedtls_ecjpake_read_round_two;
    pub const mbedtls_ecjpake_derive_secret = __root.mbedtls_ecjpake_derive_secret;
    pub const mbedtls_ecjpake_write_shared_key = __root.mbedtls_ecjpake_write_shared_key;
    pub const mbedtls_ecjpake_free = __root.mbedtls_ecjpake_free;
    pub const init = __root.mbedtls_ecjpake_init;
    pub const setup = __root.mbedtls_ecjpake_setup;
    pub const format = __root.mbedtls_ecjpake_set_point_format;
    pub const check = __root.mbedtls_ecjpake_check;
    pub const one = __root.mbedtls_ecjpake_write_round_one;
    pub const two = __root.mbedtls_ecjpake_write_round_two;
    pub const secret = __root.mbedtls_ecjpake_derive_secret;
    pub const key = __root.mbedtls_ecjpake_write_shared_key;
    pub const free = __root.mbedtls_ecjpake_free;
};
pub const mbedtls_ecjpake_context = struct_mbedtls_ecjpake_context;
pub extern fn mbedtls_ecjpake_init(ctx: [*c]mbedtls_ecjpake_context) void;
pub extern fn mbedtls_ecjpake_setup(ctx: [*c]mbedtls_ecjpake_context, role: mbedtls_ecjpake_role, hash: mbedtls_md_type_t, curve: mbedtls_ecp_group_id, secret: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ecjpake_set_point_format(ctx: [*c]mbedtls_ecjpake_context, point_format: c_int) c_int;
pub extern fn mbedtls_ecjpake_check(ctx: [*c]const mbedtls_ecjpake_context) c_int;
pub extern fn mbedtls_ecjpake_write_round_one(ctx: [*c]mbedtls_ecjpake_context, buf: [*c]u8, len: usize, olen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecjpake_read_round_one(ctx: [*c]mbedtls_ecjpake_context, buf: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ecjpake_write_round_two(ctx: [*c]mbedtls_ecjpake_context, buf: [*c]u8, len: usize, olen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecjpake_read_round_two(ctx: [*c]mbedtls_ecjpake_context, buf: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ecjpake_derive_secret(ctx: [*c]mbedtls_ecjpake_context, buf: [*c]u8, len: usize, olen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecjpake_write_shared_key(ctx: [*c]mbedtls_ecjpake_context, buf: [*c]u8, len: usize, olen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecjpake_free(ctx: [*c]mbedtls_ecjpake_context) void;
pub extern fn mbedtls_ecjpake_self_test(verbose: c_int) c_int;
const union_unnamed_19 = extern union {
    private_dummy: c_uint,
    private_jpake: mbedtls_ecjpake_context,
};
pub const mbedtls_psa_pake_operation_t = extern struct {
    private_alg: psa_algorithm_t = 0,
    private_password: [*c]u8 = null,
    private_password_len: usize = 0,
    private_role: mbedtls_ecjpake_role = @import("std").mem.zeroes(mbedtls_ecjpake_role),
    private_buffer: [336]u8 = @import("std").mem.zeroes([336]u8),
    private_buffer_length: usize = 0,
    private_buffer_offset: usize = 0,
    private_ctx: union_unnamed_19 = @import("std").mem.zeroes(union_unnamed_19),
};
pub const psa_driver_mac_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_mac_operation_t,
};
pub const psa_driver_aead_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_aead_operation_t,
};
pub const psa_driver_sign_hash_interruptible_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_sign_hash_interruptible_operation_t,
};
pub const psa_driver_verify_hash_interruptible_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_verify_hash_interruptible_operation_t,
};
pub const psa_driver_pake_context_t = extern union {
    dummy: c_uint,
    mbedtls_ctx: mbedtls_psa_pake_operation_t,
}; // <scratch space>:298:1: warning: struct demoted to opaque type - has bitfield
pub const struct_psa_mac_operation_s = opaque {
    pub const psa_mac_sign_setup = __root.psa_mac_sign_setup;
    pub const psa_mac_verify_setup = __root.psa_mac_verify_setup;
    pub const psa_mac_update = __root.psa_mac_update;
    pub const psa_mac_sign_finish = __root.psa_mac_sign_finish;
    pub const psa_mac_verify_finish = __root.psa_mac_verify_finish;
    pub const psa_mac_abort = __root.psa_mac_abort;
    pub const setup = __root.psa_mac_sign_setup;
    pub const update = __root.psa_mac_update;
    pub const finish = __root.psa_mac_sign_finish;
    pub const abort = __root.psa_mac_abort;
};
pub fn psa_mac_operation_init() callconv(.c) struct_psa_mac_operation_s {
    const v: struct_psa_mac_operation_s = struct_psa_mac_operation_s{
        .private_id = 0,
        .private_mac_size = 0,
        .private_is_sign = 0,
        .private_ctx = psa_driver_mac_context_t{
            .dummy = 0,
        },
    };
    _ = &v;
    return v;
} // <scratch space>:305:1: warning: struct demoted to opaque type - has bitfield
pub const struct_psa_aead_operation_s = opaque {
    pub const psa_aead_encrypt_setup = __root.psa_aead_encrypt_setup;
    pub const psa_aead_decrypt_setup = __root.psa_aead_decrypt_setup;
    pub const psa_aead_generate_nonce = __root.psa_aead_generate_nonce;
    pub const psa_aead_set_nonce = __root.psa_aead_set_nonce;
    pub const psa_aead_set_lengths = __root.psa_aead_set_lengths;
    pub const psa_aead_update_ad = __root.psa_aead_update_ad;
    pub const psa_aead_update = __root.psa_aead_update;
    pub const psa_aead_finish = __root.psa_aead_finish;
    pub const psa_aead_verify = __root.psa_aead_verify;
    pub const psa_aead_abort = __root.psa_aead_abort;
    pub const setup = __root.psa_aead_encrypt_setup;
    pub const nonce = __root.psa_aead_generate_nonce;
    pub const lengths = __root.psa_aead_set_lengths;
    pub const ad = __root.psa_aead_update_ad;
    pub const update = __root.psa_aead_update;
    pub const finish = __root.psa_aead_finish;
    pub const verify = __root.psa_aead_verify;
    pub const abort = __root.psa_aead_abort;
};
pub fn psa_aead_operation_init() callconv(.c) struct_psa_aead_operation_s {
    const v: struct_psa_aead_operation_s = struct_psa_aead_operation_s{
        .private_id = 0,
        .private_alg = 0,
        .private_key_type = 0,
        .private_ad_remaining = 0,
        .private_body_remaining = 0,
        .private_nonce_set = 0,
        .private_lengths_set = 0,
        .private_ad_started = 0,
        .private_body_started = 0,
        .private_is_encrypt = 0,
        .private_ctx = psa_driver_aead_context_t{
            .dummy = 0,
        },
    };
    _ = &v;
    return v;
} // <scratch space>:315:1: warning: struct demoted to opaque type - has bitfield
pub const psa_hkdf_key_derivation_t = opaque {};
pub const psa_tls12_ecjpake_to_pms_t = extern struct {
    private_data: [32]u8 = @import("std").mem.zeroes([32]u8),
};
pub const PSA_TLS12_PRF_STATE_INIT: c_int = 0;
pub const PSA_TLS12_PRF_STATE_SEED_SET: c_int = 1;
pub const PSA_TLS12_PRF_STATE_OTHER_KEY_SET: c_int = 2;
pub const PSA_TLS12_PRF_STATE_KEY_SET: c_int = 3;
pub const PSA_TLS12_PRF_STATE_LABEL_SET: c_int = 4;
pub const PSA_TLS12_PRF_STATE_OUTPUT: c_int = 5;
pub const psa_tls12_prf_key_derivation_state_t = c_uint;
pub const struct_psa_tls12_prf_key_derivation_s = extern struct {
    private_left_in_block: u8 = 0,
    private_block_number: u8 = 0,
    private_state: psa_tls12_prf_key_derivation_state_t = @import("std").mem.zeroes(psa_tls12_prf_key_derivation_state_t),
    private_secret: [*c]u8 = null,
    private_secret_length: usize = 0,
    private_seed: [*c]u8 = null,
    private_seed_length: usize = 0,
    private_label: [*c]u8 = null,
    private_label_length: usize = 0,
    private_other_secret: [*c]u8 = null,
    private_other_secret_length: usize = 0,
    private_Ai: [64]u8 = @import("std").mem.zeroes([64]u8),
    private_output_block: [64]u8 = @import("std").mem.zeroes([64]u8),
};
pub const psa_tls12_prf_key_derivation_t = struct_psa_tls12_prf_key_derivation_s;
pub const psa_driver_key_derivation_context_t = extern union {
    dummy: c_uint,
    private_hkdf: psa_hkdf_key_derivation_t,
    private_tls12_prf: psa_tls12_prf_key_derivation_t,
    private_tls12_ecjpake_to_pms: psa_tls12_ecjpake_to_pms_t,
}; // <scratch space>:338:1: warning: struct demoted to opaque type - has bitfield
pub const struct_psa_key_derivation_s = opaque {
    pub const psa_key_derivation_setup = __root.psa_key_derivation_setup;
    pub const psa_key_derivation_get_capacity = __root.psa_key_derivation_get_capacity;
    pub const psa_key_derivation_set_capacity = __root.psa_key_derivation_set_capacity;
    pub const psa_key_derivation_input_bytes = __root.psa_key_derivation_input_bytes;
    pub const psa_key_derivation_input_integer = __root.psa_key_derivation_input_integer;
    pub const psa_key_derivation_input_key = __root.psa_key_derivation_input_key;
    pub const psa_key_derivation_key_agreement = __root.psa_key_derivation_key_agreement;
    pub const psa_key_derivation_output_bytes = __root.psa_key_derivation_output_bytes;
    pub const psa_key_derivation_verify_bytes = __root.psa_key_derivation_verify_bytes;
    pub const psa_key_derivation_verify_key = __root.psa_key_derivation_verify_key;
    pub const psa_key_derivation_abort = __root.psa_key_derivation_abort;
    pub const setup = __root.psa_key_derivation_setup;
    pub const capacity = __root.psa_key_derivation_get_capacity;
    pub const bytes = __root.psa_key_derivation_input_bytes;
    pub const integer = __root.psa_key_derivation_input_integer;
    pub const key = __root.psa_key_derivation_input_key;
    pub const agreement = __root.psa_key_derivation_key_agreement;
    pub const abort = __root.psa_key_derivation_abort;
};
pub fn psa_key_derivation_operation_init() callconv(.c) struct_psa_key_derivation_s {
    const v: struct_psa_key_derivation_s = struct_psa_key_derivation_s{
        .private_alg = 0,
        .private_can_output_key = 0,
        .private_capacity = 0,
        .private_ctx = psa_driver_key_derivation_context_t{
            .dummy = 0,
        },
    };
    _ = &v;
    return v;
}
pub fn psa_key_policy_init() callconv(.c) struct_psa_key_policy_s {
    const v: struct_psa_key_policy_s = struct_psa_key_policy_s{
        .private_usage = 0,
        .private_alg = 0,
        .private_alg2 = 0,
    };
    _ = &v;
    return v;
}
pub fn psa_key_attributes_init() callconv(.c) struct_psa_key_attributes_s {
    const v: struct_psa_key_attributes_s = struct_psa_key_attributes_s{
        .private_type = @as(psa_key_type_t, @bitCast(@as(c_short, @truncate(@as(c_int, 0))))),
        .private_bits = 0,
        .private_lifetime = @as(psa_key_lifetime_t, @bitCast(@as(c_int, @as(c_int, 0)))),
        .private_policy = psa_key_policy_t{
            .private_usage = 0,
            .private_alg = 0,
            .private_alg2 = 0,
        },
        .private_id = @as(psa_key_id_t, @bitCast(@as(c_int, @as(c_int, 0)))),
    };
    _ = &v;
    return v;
}
pub fn psa_set_key_id(arg_attributes: [*c]psa_key_attributes_t, arg_key: mbedtls_svc_key_id_t) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var key = arg_key;
    _ = &key;
    var lifetime: psa_key_lifetime_t = attributes.*.private_lifetime;
    _ = &lifetime;
    attributes.*.private_id = key;
    if (@as(c_int, @as(psa_key_persistence_t, @truncate(lifetime & @as(psa_key_lifetime_t, 255)))) == @as(c_int, @as(psa_key_persistence_t, @bitCast(@as(i8, @truncate(@as(c_int, 0))))))) {
        attributes.*.private_lifetime = ((lifetime >> @intCast(8)) << @intCast(8)) | @as(psa_key_lifetime_t, @bitCast(@as(c_int, @as(c_int, 1))));
    }
}
pub fn psa_get_key_id(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) mbedtls_svc_key_id_t {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_id;
}
pub fn psa_set_key_lifetime(arg_attributes: [*c]psa_key_attributes_t, arg_lifetime: psa_key_lifetime_t) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var lifetime = arg_lifetime;
    _ = &lifetime;
    attributes.*.private_lifetime = lifetime;
    if (@as(c_int, @as(psa_key_persistence_t, @truncate(lifetime & @as(psa_key_lifetime_t, 255)))) == @as(c_int, @as(psa_key_persistence_t, @bitCast(@as(i8, @truncate(@as(c_int, 0))))))) {
        attributes.*.private_id = 0;
    }
}
pub fn psa_get_key_lifetime(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) psa_key_lifetime_t {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_lifetime;
}
pub fn psa_extend_key_usage_flags(arg_usage_flags: [*c]psa_key_usage_t) callconv(.c) void {
    var usage_flags = arg_usage_flags;
    _ = &usage_flags;
    if ((usage_flags.* & @as(psa_key_usage_t, @bitCast(@as(c_int, @as(c_int, 4096))))) != 0) {
        usage_flags.* |= @as(psa_key_usage_t, @bitCast(@as(c_int, @as(c_int, 1024))));
    }
    if ((usage_flags.* & @as(psa_key_usage_t, @bitCast(@as(c_int, @as(c_int, 8192))))) != 0) {
        usage_flags.* |= @as(psa_key_usage_t, @bitCast(@as(c_int, @as(c_int, 2048))));
    }
}
pub fn psa_set_key_usage_flags(arg_attributes: [*c]psa_key_attributes_t, arg_usage_flags: psa_key_usage_t) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var usage_flags = arg_usage_flags;
    _ = &usage_flags;
    psa_extend_key_usage_flags(&usage_flags);
    attributes.*.private_policy.private_usage = usage_flags;
}
pub fn psa_get_key_usage_flags(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) psa_key_usage_t {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_policy.private_usage;
}
pub fn psa_set_key_algorithm(arg_attributes: [*c]psa_key_attributes_t, arg_alg: psa_algorithm_t) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var alg = arg_alg;
    _ = &alg;
    attributes.*.private_policy.private_alg = alg;
}
pub fn psa_get_key_algorithm(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) psa_algorithm_t {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_policy.private_alg;
}
pub fn psa_set_key_type(arg_attributes: [*c]psa_key_attributes_t, arg_type: psa_key_type_t) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var @"type" = arg_type;
    _ = &@"type";
    attributes.*.private_type = @"type";
}
pub fn psa_get_key_type(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) psa_key_type_t {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_type;
}
pub fn psa_set_key_bits(arg_attributes: [*c]psa_key_attributes_t, arg_bits: usize) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var bits = arg_bits;
    _ = &bits;
    if (bits > @as(usize, 65528)) {
        attributes.*.private_bits = @as(psa_key_bits_t, @bitCast(@as(c_short, @truncate(-@as(c_int, 1)))));
    } else {
        attributes.*.private_bits = @truncate(bits);
    }
}
pub fn psa_get_key_bits(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) usize {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_bits;
} // <scratch space>:371:1: warning: struct demoted to opaque type - has bitfield
pub const struct_psa_sign_hash_interruptible_operation_s = opaque {
    pub const psa_sign_hash_get_num_ops = __root.psa_sign_hash_get_num_ops;
    pub const psa_sign_hash_start = __root.psa_sign_hash_start;
    pub const psa_sign_hash_complete = __root.psa_sign_hash_complete;
    pub const psa_sign_hash_abort = __root.psa_sign_hash_abort;
    pub const ops = __root.psa_sign_hash_get_num_ops;
    pub const start = __root.psa_sign_hash_start;
    pub const complete = __root.psa_sign_hash_complete;
    pub const abort = __root.psa_sign_hash_abort;
};
pub fn psa_sign_hash_interruptible_operation_init() callconv(.c) struct_psa_sign_hash_interruptible_operation_s {
    const v: struct_psa_sign_hash_interruptible_operation_s = struct_psa_sign_hash_interruptible_operation_s{
        .private_id = 0,
        .private_ctx = psa_driver_sign_hash_interruptible_context_t{
            .dummy = 0,
        },
        .private_error_occurred = 0,
        .private_num_ops = 0,
    };
    _ = &v;
    return v;
} // <scratch space>:375:1: warning: struct demoted to opaque type - has bitfield
pub const struct_psa_verify_hash_interruptible_operation_s = opaque {
    pub const psa_verify_hash_get_num_ops = __root.psa_verify_hash_get_num_ops;
    pub const psa_verify_hash_start = __root.psa_verify_hash_start;
    pub const psa_verify_hash_complete = __root.psa_verify_hash_complete;
    pub const psa_verify_hash_abort = __root.psa_verify_hash_abort;
    pub const ops = __root.psa_verify_hash_get_num_ops;
    pub const start = __root.psa_verify_hash_start;
    pub const complete = __root.psa_verify_hash_complete;
    pub const abort = __root.psa_verify_hash_abort;
};
pub fn psa_verify_hash_interruptible_operation_init() callconv(.c) struct_psa_verify_hash_interruptible_operation_s {
    const v: struct_psa_verify_hash_interruptible_operation_s = struct_psa_verify_hash_interruptible_operation_s{
        .private_id = 0,
        .private_ctx = psa_driver_verify_hash_interruptible_context_t{
            .dummy = 0,
        },
        .private_error_occurred = 0,
        .private_num_ops = 0,
    };
    _ = &v;
    return v;
}
pub extern fn psa_crypto_init() psa_status_t;
pub extern fn psa_get_key_attributes(key: mbedtls_svc_key_id_t, attributes: [*c]psa_key_attributes_t) psa_status_t;
pub extern fn psa_reset_key_attributes(attributes: [*c]psa_key_attributes_t) void;
pub extern fn psa_purge_key(key: mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_copy_key(source_key: mbedtls_svc_key_id_t, attributes: [*c]const psa_key_attributes_t, target_key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_destroy_key(key: mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_import_key(attributes: [*c]const psa_key_attributes_t, data: [*c]const u8, data_length: usize, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_export_key(key: mbedtls_svc_key_id_t, data: [*c]u8, data_size: usize, data_length: [*c]usize) psa_status_t;
pub extern fn psa_export_public_key(key: mbedtls_svc_key_id_t, data: [*c]u8, data_size: usize, data_length: [*c]usize) psa_status_t;
pub extern fn psa_hash_compute(alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, hash: [*c]u8, hash_size: usize, hash_length: [*c]usize) psa_status_t;
pub extern fn psa_hash_compare(alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, hash: [*c]const u8, hash_length: usize) psa_status_t;
pub const psa_hash_operation_t = struct_psa_hash_operation_s;
pub extern fn psa_hash_setup(operation: [*c]psa_hash_operation_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_hash_update(operation: [*c]psa_hash_operation_t, input: [*c]const u8, input_length: usize) psa_status_t;
pub extern fn psa_hash_finish(operation: [*c]psa_hash_operation_t, hash: [*c]u8, hash_size: usize, hash_length: [*c]usize) psa_status_t;
pub extern fn psa_hash_verify(operation: [*c]psa_hash_operation_t, hash: [*c]const u8, hash_length: usize) psa_status_t;
pub extern fn psa_hash_abort(operation: [*c]psa_hash_operation_t) psa_status_t;
pub extern fn psa_hash_clone(source_operation: [*c]const psa_hash_operation_t, target_operation: [*c]psa_hash_operation_t) psa_status_t;
pub extern fn psa_mac_compute(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, mac: [*c]u8, mac_size: usize, mac_length: [*c]usize) psa_status_t;
pub extern fn psa_mac_verify(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, mac: [*c]const u8, mac_length: usize) psa_status_t;
pub const psa_mac_operation_t = struct_psa_mac_operation_s;
pub extern fn psa_mac_sign_setup(operation: ?*psa_mac_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_mac_verify_setup(operation: ?*psa_mac_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_mac_update(operation: ?*psa_mac_operation_t, input: [*c]const u8, input_length: usize) psa_status_t;
pub extern fn psa_mac_sign_finish(operation: ?*psa_mac_operation_t, mac: [*c]u8, mac_size: usize, mac_length: [*c]usize) psa_status_t;
pub extern fn psa_mac_verify_finish(operation: ?*psa_mac_operation_t, mac: [*c]const u8, mac_length: usize) psa_status_t;
pub extern fn psa_mac_abort(operation: ?*psa_mac_operation_t) psa_status_t;
pub extern fn psa_cipher_encrypt(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_cipher_decrypt(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub const psa_cipher_operation_t = struct_psa_cipher_operation_s;
pub extern fn psa_cipher_encrypt_setup(operation: ?*psa_cipher_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_cipher_decrypt_setup(operation: ?*psa_cipher_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_cipher_generate_iv(operation: ?*psa_cipher_operation_t, iv: [*c]u8, iv_size: usize, iv_length: [*c]usize) psa_status_t;
pub extern fn psa_cipher_set_iv(operation: ?*psa_cipher_operation_t, iv: [*c]const u8, iv_length: usize) psa_status_t;
pub extern fn psa_cipher_update(operation: ?*psa_cipher_operation_t, input: [*c]const u8, input_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_cipher_finish(operation: ?*psa_cipher_operation_t, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_cipher_abort(operation: ?*psa_cipher_operation_t) psa_status_t;
pub extern fn psa_aead_encrypt(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, nonce: [*c]const u8, nonce_length: usize, additional_data: [*c]const u8, additional_data_length: usize, plaintext: [*c]const u8, plaintext_length: usize, ciphertext: [*c]u8, ciphertext_size: usize, ciphertext_length: [*c]usize) psa_status_t;
pub extern fn psa_aead_decrypt(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, nonce: [*c]const u8, nonce_length: usize, additional_data: [*c]const u8, additional_data_length: usize, ciphertext: [*c]const u8, ciphertext_length: usize, plaintext: [*c]u8, plaintext_size: usize, plaintext_length: [*c]usize) psa_status_t;
pub const psa_aead_operation_t = struct_psa_aead_operation_s;
pub extern fn psa_aead_encrypt_setup(operation: ?*psa_aead_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_aead_decrypt_setup(operation: ?*psa_aead_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_aead_generate_nonce(operation: ?*psa_aead_operation_t, nonce: [*c]u8, nonce_size: usize, nonce_length: [*c]usize) psa_status_t;
pub extern fn psa_aead_set_nonce(operation: ?*psa_aead_operation_t, nonce: [*c]const u8, nonce_length: usize) psa_status_t;
pub extern fn psa_aead_set_lengths(operation: ?*psa_aead_operation_t, ad_length: usize, plaintext_length: usize) psa_status_t;
pub extern fn psa_aead_update_ad(operation: ?*psa_aead_operation_t, input: [*c]const u8, input_length: usize) psa_status_t;
pub extern fn psa_aead_update(operation: ?*psa_aead_operation_t, input: [*c]const u8, input_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_aead_finish(operation: ?*psa_aead_operation_t, ciphertext: [*c]u8, ciphertext_size: usize, ciphertext_length: [*c]usize, tag: [*c]u8, tag_size: usize, tag_length: [*c]usize) psa_status_t;
pub extern fn psa_aead_verify(operation: ?*psa_aead_operation_t, plaintext: [*c]u8, plaintext_size: usize, plaintext_length: [*c]usize, tag: [*c]const u8, tag_length: usize) psa_status_t;
pub extern fn psa_aead_abort(operation: ?*psa_aead_operation_t) psa_status_t;
pub extern fn psa_sign_message(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, signature: [*c]u8, signature_size: usize, signature_length: [*c]usize) psa_status_t;
pub extern fn psa_verify_message(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, signature: [*c]const u8, signature_length: usize) psa_status_t;
pub extern fn psa_sign_hash(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, hash: [*c]const u8, hash_length: usize, signature: [*c]u8, signature_size: usize, signature_length: [*c]usize) psa_status_t;
pub extern fn psa_verify_hash(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, hash: [*c]const u8, hash_length: usize, signature: [*c]const u8, signature_length: usize) psa_status_t;
pub extern fn psa_asymmetric_encrypt(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, salt: [*c]const u8, salt_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_asymmetric_decrypt(key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, input: [*c]const u8, input_length: usize, salt: [*c]const u8, salt_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub const psa_key_derivation_operation_t = struct_psa_key_derivation_s;
pub extern fn psa_key_derivation_setup(operation: ?*psa_key_derivation_operation_t, alg: psa_algorithm_t) psa_status_t;
pub extern fn psa_key_derivation_get_capacity(operation: ?*const psa_key_derivation_operation_t, capacity: [*c]usize) psa_status_t;
pub extern fn psa_key_derivation_set_capacity(operation: ?*psa_key_derivation_operation_t, capacity: usize) psa_status_t;
pub extern fn psa_key_derivation_input_bytes(operation: ?*psa_key_derivation_operation_t, step: psa_key_derivation_step_t, data: [*c]const u8, data_length: usize) psa_status_t;
pub extern fn psa_key_derivation_input_integer(operation: ?*psa_key_derivation_operation_t, step: psa_key_derivation_step_t, value: u64) psa_status_t;
pub extern fn psa_key_derivation_input_key(operation: ?*psa_key_derivation_operation_t, step: psa_key_derivation_step_t, key: mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_key_derivation_key_agreement(operation: ?*psa_key_derivation_operation_t, step: psa_key_derivation_step_t, private_key: mbedtls_svc_key_id_t, peer_key: [*c]const u8, peer_key_length: usize) psa_status_t;
pub extern fn psa_key_derivation_output_bytes(operation: ?*psa_key_derivation_operation_t, output: [*c]u8, output_length: usize) psa_status_t;
pub extern fn psa_key_derivation_output_key(attributes: [*c]const psa_key_attributes_t, operation: ?*psa_key_derivation_operation_t, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_key_derivation_output_key_custom(attributes: [*c]const psa_key_attributes_t, operation: ?*psa_key_derivation_operation_t, custom: [*c]const psa_custom_key_parameters_t, custom_data: [*c]const u8, custom_data_length: usize, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_key_derivation_output_key_ext(attributes: [*c]const psa_key_attributes_t, operation: ?*psa_key_derivation_operation_t, params: [*c]const psa_key_production_parameters_t, params_data_length: usize, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_key_derivation_verify_bytes(operation: ?*psa_key_derivation_operation_t, expected: [*c]const u8, expected_length: usize) psa_status_t;
pub extern fn psa_key_derivation_verify_key(operation: ?*psa_key_derivation_operation_t, expected: psa_key_id_t) psa_status_t;
pub extern fn psa_key_derivation_abort(operation: ?*psa_key_derivation_operation_t) psa_status_t;
pub extern fn psa_raw_key_agreement(alg: psa_algorithm_t, private_key: mbedtls_svc_key_id_t, peer_key: [*c]const u8, peer_key_length: usize, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_generate_random(output: [*c]u8, output_size: usize) psa_status_t;
pub extern fn psa_generate_key(attributes: [*c]const psa_key_attributes_t, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_generate_key_custom(attributes: [*c]const psa_key_attributes_t, custom: [*c]const psa_custom_key_parameters_t, custom_data: [*c]const u8, custom_data_length: usize, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_generate_key_ext(attributes: [*c]const psa_key_attributes_t, params: [*c]const psa_key_production_parameters_t, params_data_length: usize, key: [*c]mbedtls_svc_key_id_t) psa_status_t;
pub const psa_sign_hash_interruptible_operation_t = struct_psa_sign_hash_interruptible_operation_s;
pub const psa_verify_hash_interruptible_operation_t = struct_psa_verify_hash_interruptible_operation_s;
pub extern fn psa_interruptible_set_max_ops(max_ops: u32) void;
pub extern fn psa_interruptible_get_max_ops() u32;
pub extern fn psa_sign_hash_get_num_ops(operation: ?*const psa_sign_hash_interruptible_operation_t) u32;
pub extern fn psa_verify_hash_get_num_ops(operation: ?*const psa_verify_hash_interruptible_operation_t) u32;
pub extern fn psa_sign_hash_start(operation: ?*psa_sign_hash_interruptible_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, hash: [*c]const u8, hash_length: usize) psa_status_t;
pub extern fn psa_sign_hash_complete(operation: ?*psa_sign_hash_interruptible_operation_t, signature: [*c]u8, signature_size: usize, signature_length: [*c]usize) psa_status_t;
pub extern fn psa_sign_hash_abort(operation: ?*psa_sign_hash_interruptible_operation_t) psa_status_t;
pub extern fn psa_verify_hash_start(operation: ?*psa_verify_hash_interruptible_operation_t, key: mbedtls_svc_key_id_t, alg: psa_algorithm_t, hash: [*c]const u8, hash_length: usize, signature: [*c]const u8, signature_length: usize) psa_status_t;
pub extern fn psa_verify_hash_complete(operation: ?*psa_verify_hash_interruptible_operation_t) psa_status_t;
pub extern fn psa_verify_hash_abort(operation: ?*psa_verify_hash_interruptible_operation_t) psa_status_t;
pub const psa_key_handle_t = mbedtls_svc_key_id_t;
pub fn psa_key_handle_is_null(arg_handle: psa_key_handle_t) callconv(.c) c_int {
    var handle = arg_handle;
    _ = &handle;
    return mbedtls_svc_key_id_is_null(handle);
}
pub extern fn psa_open_key(key: mbedtls_svc_key_id_t, handle: [*c]psa_key_handle_t) psa_status_t;
pub extern fn psa_close_key(handle: psa_key_handle_t) psa_status_t;
pub fn psa_set_key_domain_parameters(arg_attributes: [*c]psa_key_attributes_t, arg_type: psa_key_type_t, arg_data: [*c]const u8, arg_data_length: usize) callconv(.c) psa_status_t {
    var attributes = arg_attributes;
    _ = &attributes;
    var @"type" = arg_type;
    _ = &@"type";
    var data = arg_data;
    _ = &data;
    var data_length = arg_data_length;
    _ = &data_length;
    _ = &data;
    if (data_length != @as(usize, 0)) {
        return -@as(c_int, 134);
    }
    psa_set_key_type(attributes, @"type");
    return @as(c_int, 0);
}
pub fn psa_get_key_domain_parameters(arg_attributes: [*c]const psa_key_attributes_t, arg_data: [*c]u8, arg_data_size: usize, arg_data_length: [*c]usize) callconv(.c) psa_status_t {
    var attributes = arg_attributes;
    _ = &attributes;
    var data = arg_data;
    _ = &data;
    var data_size = arg_data_size;
    _ = &data_size;
    var data_length = arg_data_length;
    _ = &data_length;
    _ = &attributes;
    _ = &data;
    _ = &data_size;
    data_length.* = 0;
    return @as(c_int, 0);
}
pub fn psa_set_key_enrollment_algorithm(arg_attributes: [*c]psa_key_attributes_t, arg_alg2: psa_algorithm_t) callconv(.c) void {
    var attributes = arg_attributes;
    _ = &attributes;
    var alg2 = arg_alg2;
    _ = &alg2;
    attributes.*.private_policy.private_alg2 = alg2;
}
pub fn psa_get_key_enrollment_algorithm(arg_attributes: [*c]const psa_key_attributes_t) callconv(.c) psa_algorithm_t {
    var attributes = arg_attributes;
    _ = &attributes;
    return attributes.*.private_policy.private_alg2;
}
pub extern fn mbedtls_psa_crypto_free() void;
pub const struct_mbedtls_psa_stats_s = extern struct {
    private_volatile_slots: usize = 0,
    private_persistent_slots: usize = 0,
    private_external_slots: usize = 0,
    private_half_filled_slots: usize = 0,
    private_cache_slots: usize = 0,
    private_empty_slots: usize = 0,
    private_locked_slots: usize = 0,
    private_max_open_internal_key_id: psa_key_id_t = 0,
    private_max_open_external_key_id: psa_key_id_t = 0,
    pub const mbedtls_psa_get_stats = __root.mbedtls_psa_get_stats;
    pub const stats = __root.mbedtls_psa_get_stats;
};
pub const mbedtls_psa_stats_t = struct_mbedtls_psa_stats_s;
pub extern fn mbedtls_psa_get_stats(stats: [*c]mbedtls_psa_stats_t) void;
pub extern fn mbedtls_psa_inject_entropy(seed: [*c]const u8, seed_size: usize) psa_status_t;
pub const psa_drv_slot_number_t = u64;
pub extern fn psa_can_do_hash(hash_alg: psa_algorithm_t) c_int;
pub const psa_pake_role_t = u8;
pub const psa_pake_step_t = u8;
pub const psa_pake_primitive_type_t = u8;
pub const psa_pake_family_t = u8;
pub const psa_pake_primitive_t = u32;
pub const struct_psa_pake_cipher_suite_s = extern struct {
    algorithm: psa_algorithm_t = 0,
    type: psa_pake_primitive_type_t = 0,
    family: psa_pake_family_t = 0,
    bits: u16 = 0,
    hash: psa_algorithm_t = 0,
    pub const psa_pake_cs_get_algorithm = __root.psa_pake_cs_get_algorithm;
    pub const psa_pake_cs_set_algorithm = __root.psa_pake_cs_set_algorithm;
    pub const psa_pake_cs_get_primitive = __root.psa_pake_cs_get_primitive;
    pub const psa_pake_cs_set_primitive = __root.psa_pake_cs_set_primitive;
    pub const psa_pake_cs_get_family = __root.psa_pake_cs_get_family;
    pub const psa_pake_cs_get_bits = __root.psa_pake_cs_get_bits;
    pub const psa_pake_cs_get_hash = __root.psa_pake_cs_get_hash;
    pub const psa_pake_cs_set_hash = __root.psa_pake_cs_set_hash;
    pub const primitive = __root.psa_pake_cs_get_primitive;
};
pub const struct_psa_crypto_driver_pake_inputs_s = extern struct {
    private_password: [*c]u8 = null,
    private_password_len: usize = 0,
    private_user: [*c]u8 = null,
    private_user_len: usize = 0,
    private_peer: [*c]u8 = null,
    private_peer_len: usize = 0,
    private_attributes: psa_key_attributes_t = @import("std").mem.zeroes(psa_key_attributes_t),
    private_cipher_suite: struct_psa_pake_cipher_suite_s = @import("std").mem.zeroes(struct_psa_pake_cipher_suite_s),
    pub const psa_crypto_driver_pake_get_password_len = __root.psa_crypto_driver_pake_get_password_len;
    pub const psa_crypto_driver_pake_get_password = __root.psa_crypto_driver_pake_get_password;
    pub const psa_crypto_driver_pake_get_user_len = __root.psa_crypto_driver_pake_get_user_len;
    pub const psa_crypto_driver_pake_get_peer_len = __root.psa_crypto_driver_pake_get_peer_len;
    pub const psa_crypto_driver_pake_get_user = __root.psa_crypto_driver_pake_get_user;
    pub const psa_crypto_driver_pake_get_peer = __root.psa_crypto_driver_pake_get_peer;
    pub const psa_crypto_driver_pake_get_cipher_suite = __root.psa_crypto_driver_pake_get_cipher_suite;
    pub const len = __root.psa_crypto_driver_pake_get_password_len;
    pub const password = __root.psa_crypto_driver_pake_get_password;
    pub const user = __root.psa_crypto_driver_pake_get_user;
    pub const peer = __root.psa_crypto_driver_pake_get_peer;
    pub const suite = __root.psa_crypto_driver_pake_get_cipher_suite;
};
pub const PSA_JPAKE_STEP_INVALID: c_int = 0;
pub const PSA_JPAKE_X1_STEP_KEY_SHARE: c_int = 1;
pub const PSA_JPAKE_X1_STEP_ZK_PUBLIC: c_int = 2;
pub const PSA_JPAKE_X1_STEP_ZK_PROOF: c_int = 3;
pub const PSA_JPAKE_X2_STEP_KEY_SHARE: c_int = 4;
pub const PSA_JPAKE_X2_STEP_ZK_PUBLIC: c_int = 5;
pub const PSA_JPAKE_X2_STEP_ZK_PROOF: c_int = 6;
pub const PSA_JPAKE_X2S_STEP_KEY_SHARE: c_int = 7;
pub const PSA_JPAKE_X2S_STEP_ZK_PUBLIC: c_int = 8;
pub const PSA_JPAKE_X2S_STEP_ZK_PROOF: c_int = 9;
pub const PSA_JPAKE_X4S_STEP_KEY_SHARE: c_int = 10;
pub const PSA_JPAKE_X4S_STEP_ZK_PUBLIC: c_int = 11;
pub const PSA_JPAKE_X4S_STEP_ZK_PROOF: c_int = 12;
pub const enum_psa_crypto_driver_pake_step = c_uint;
pub const psa_crypto_driver_pake_step_t = enum_psa_crypto_driver_pake_step;
pub const PSA_JPAKE_FIRST: c_int = 0;
pub const PSA_JPAKE_SECOND: c_int = 1;
pub const PSA_JPAKE_FINISHED: c_int = 2;
pub const enum_psa_jpake_round = c_uint;
pub const psa_jpake_round_t = enum_psa_jpake_round;
pub const PSA_JPAKE_INPUT: c_int = 0;
pub const PSA_JPAKE_OUTPUT: c_int = 1;
pub const enum_psa_jpake_io_mode = c_uint;
pub const psa_jpake_io_mode_t = enum_psa_jpake_io_mode;
pub const struct_psa_jpake_computation_stage_s = extern struct {
    private_round: psa_jpake_round_t = @import("std").mem.zeroes(psa_jpake_round_t),
    private_io_mode: psa_jpake_io_mode_t = @import("std").mem.zeroes(psa_jpake_io_mode_t),
    private_inputs: u8 = 0,
    private_outputs: u8 = 0,
    private_step: psa_pake_step_t = 0,
};
const union_unnamed_20 = extern union {
    private_dummy: u8,
    private_jpake: struct_psa_jpake_computation_stage_s,
};
const union_unnamed_21 = extern union {
    private_ctx: psa_driver_pake_context_t,
    private_inputs: struct_psa_crypto_driver_pake_inputs_s,
};
pub const struct_psa_pake_operation_s = extern struct {
    private_id: c_uint = 0,
    private_alg: psa_algorithm_t = 0,
    private_primitive: psa_pake_primitive_t = 0,
    private_stage: u8 = 0,
    private_computation_stage: union_unnamed_20 = @import("std").mem.zeroes(union_unnamed_20),
    private_data: union_unnamed_21 = @import("std").mem.zeroes(union_unnamed_21),
    pub const psa_pake_setup = __root.psa_pake_setup;
    pub const psa_pake_set_password_key = __root.psa_pake_set_password_key;
    pub const psa_pake_set_user = __root.psa_pake_set_user;
    pub const psa_pake_set_peer = __root.psa_pake_set_peer;
    pub const psa_pake_set_role = __root.psa_pake_set_role;
    pub const psa_pake_output = __root.psa_pake_output;
    pub const psa_pake_input = __root.psa_pake_input;
    pub const psa_pake_get_implicit_key = __root.psa_pake_get_implicit_key;
    pub const psa_pake_abort = __root.psa_pake_abort;
    pub const setup = __root.psa_pake_setup;
    pub const key = __root.psa_pake_set_password_key;
    pub const user = __root.psa_pake_set_user;
    pub const peer = __root.psa_pake_set_peer;
    pub const role = __root.psa_pake_set_role;
    pub const output = __root.psa_pake_output;
    pub const input = __root.psa_pake_input;
    pub const abort = __root.psa_pake_abort;
};
pub const psa_pake_cipher_suite_t = struct_psa_pake_cipher_suite_s;
pub fn psa_pake_cipher_suite_init() callconv(.c) struct_psa_pake_cipher_suite_s {
    const v: struct_psa_pake_cipher_suite_s = struct_psa_pake_cipher_suite_s{
        .algorithm = @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 0)))),
        .type = 0,
        .family = 0,
        .bits = 0,
        .hash = @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 0)))),
    };
    _ = &v;
    return v;
}
pub fn psa_pake_cs_get_algorithm(arg_cipher_suite: [*c]const psa_pake_cipher_suite_t) callconv(.c) psa_algorithm_t {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    return cipher_suite.*.algorithm;
}
pub fn psa_pake_cs_set_algorithm(arg_cipher_suite: [*c]psa_pake_cipher_suite_t, arg_algorithm: psa_algorithm_t) callconv(.c) void {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    var algorithm = arg_algorithm;
    _ = &algorithm;
    if (!((algorithm & @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 2130706432))))) == @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 167772160)))))) {
        cipher_suite.*.algorithm = 0;
    } else {
        cipher_suite.*.algorithm = algorithm;
    }
}
pub fn psa_pake_cs_get_primitive(arg_cipher_suite: [*c]const psa_pake_cipher_suite_t) callconv(.c) psa_pake_primitive_t {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    return if ((@as(c_int, cipher_suite.*.bits) & @as(c_int, 65535)) != @as(c_int, cipher_suite.*.bits)) @as(psa_pake_primitive_t, 0) else @as(psa_pake_primitive_t, @bitCast(@as(c_int, ((@as(c_int, cipher_suite.*.type) << @intCast(24)) | (@as(c_int, cipher_suite.*.family) << @intCast(16))) | @as(c_int, cipher_suite.*.bits))));
}
pub fn psa_pake_cs_set_primitive(arg_cipher_suite: [*c]psa_pake_cipher_suite_t, arg_primitive: psa_pake_primitive_t) callconv(.c) void {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    var primitive = arg_primitive;
    _ = &primitive;
    cipher_suite.*.type = @truncate(primitive >> @intCast(24));
    cipher_suite.*.family = @truncate(@as(psa_pake_primitive_t, 255) & (primitive >> @intCast(16)));
    cipher_suite.*.bits = @truncate(@as(psa_pake_primitive_t, 65535) & primitive);
}
pub fn psa_pake_cs_get_family(arg_cipher_suite: [*c]const psa_pake_cipher_suite_t) callconv(.c) psa_pake_family_t {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    return cipher_suite.*.family;
}
pub fn psa_pake_cs_get_bits(arg_cipher_suite: [*c]const psa_pake_cipher_suite_t) callconv(.c) u16 {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    return cipher_suite.*.bits;
}
pub fn psa_pake_cs_get_hash(arg_cipher_suite: [*c]const psa_pake_cipher_suite_t) callconv(.c) psa_algorithm_t {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    return cipher_suite.*.hash;
}
pub fn psa_pake_cs_set_hash(arg_cipher_suite: [*c]psa_pake_cipher_suite_t, arg_hash: psa_algorithm_t) callconv(.c) void {
    var cipher_suite = arg_cipher_suite;
    _ = &cipher_suite;
    var hash = arg_hash;
    _ = &hash;
    if (!((hash & @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 2130706432))))) == @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 33554432)))))) {
        cipher_suite.*.hash = 0;
    } else {
        cipher_suite.*.hash = hash;
    }
}
pub const psa_pake_operation_t = struct_psa_pake_operation_s;
pub const psa_crypto_driver_pake_inputs_t = struct_psa_crypto_driver_pake_inputs_s;
pub const psa_jpake_computation_stage_t = struct_psa_jpake_computation_stage_s;
pub fn psa_pake_operation_init() callconv(.c) struct_psa_pake_operation_s {
    const v: struct_psa_pake_operation_s = struct_psa_pake_operation_s{
        .private_id = 0,
        .private_alg = @as(psa_algorithm_t, @bitCast(@as(c_int, @as(c_int, 0)))),
        .private_primitive = 0,
        .private_stage = 0,
        .private_computation_stage = union_unnamed_20{
            .private_dummy = 0,
        },
        .private_data = union_unnamed_21{
            .private_ctx = psa_driver_pake_context_t{
                .dummy = 0,
            },
        },
    };
    _ = &v;
    return v;
}
pub extern fn psa_crypto_driver_pake_get_password_len(inputs: [*c]const psa_crypto_driver_pake_inputs_t, password_len: [*c]usize) psa_status_t;
pub extern fn psa_crypto_driver_pake_get_password(inputs: [*c]const psa_crypto_driver_pake_inputs_t, buffer: [*c]u8, buffer_size: usize, buffer_length: [*c]usize) psa_status_t;
pub extern fn psa_crypto_driver_pake_get_user_len(inputs: [*c]const psa_crypto_driver_pake_inputs_t, user_len: [*c]usize) psa_status_t;
pub extern fn psa_crypto_driver_pake_get_peer_len(inputs: [*c]const psa_crypto_driver_pake_inputs_t, peer_len: [*c]usize) psa_status_t;
pub extern fn psa_crypto_driver_pake_get_user(inputs: [*c]const psa_crypto_driver_pake_inputs_t, user_id: [*c]u8, user_id_size: usize, user_id_len: [*c]usize) psa_status_t;
pub extern fn psa_crypto_driver_pake_get_peer(inputs: [*c]const psa_crypto_driver_pake_inputs_t, peer_id: [*c]u8, peer_id_size: usize, peer_id_length: [*c]usize) psa_status_t;
pub extern fn psa_crypto_driver_pake_get_cipher_suite(inputs: [*c]const psa_crypto_driver_pake_inputs_t, cipher_suite: [*c]psa_pake_cipher_suite_t) psa_status_t;
pub extern fn psa_pake_setup(operation: [*c]psa_pake_operation_t, cipher_suite: [*c]const psa_pake_cipher_suite_t) psa_status_t;
pub extern fn psa_pake_set_password_key(operation: [*c]psa_pake_operation_t, password: mbedtls_svc_key_id_t) psa_status_t;
pub extern fn psa_pake_set_user(operation: [*c]psa_pake_operation_t, user_id: [*c]const u8, user_id_len: usize) psa_status_t;
pub extern fn psa_pake_set_peer(operation: [*c]psa_pake_operation_t, peer_id: [*c]const u8, peer_id_len: usize) psa_status_t;
pub extern fn psa_pake_set_role(operation: [*c]psa_pake_operation_t, role: psa_pake_role_t) psa_status_t;
pub extern fn psa_pake_output(operation: [*c]psa_pake_operation_t, step: psa_pake_step_t, output: [*c]u8, output_size: usize, output_length: [*c]usize) psa_status_t;
pub extern fn psa_pake_input(operation: [*c]psa_pake_operation_t, step: psa_pake_step_t, input: [*c]const u8, input_length: usize) psa_status_t;
pub extern fn psa_pake_get_implicit_key(operation: [*c]psa_pake_operation_t, output: ?*psa_key_derivation_operation_t) psa_status_t;
pub extern fn psa_pake_abort(operation: [*c]psa_pake_operation_t) psa_status_t;
pub const MBEDTLS_PK_NONE: c_int = 0;
pub const MBEDTLS_PK_RSA: c_int = 1;
pub const MBEDTLS_PK_ECKEY: c_int = 2;
pub const MBEDTLS_PK_ECKEY_DH: c_int = 3;
pub const MBEDTLS_PK_ECDSA: c_int = 4;
pub const MBEDTLS_PK_RSA_ALT: c_int = 5;
pub const MBEDTLS_PK_RSASSA_PSS: c_int = 6;
pub const MBEDTLS_PK_OPAQUE: c_int = 7;
pub const mbedtls_pk_type_t = c_uint;
pub const struct_mbedtls_pk_rsassa_pss_options = extern struct {
    mgf1_hash_id: mbedtls_md_type_t = @import("std").mem.zeroes(mbedtls_md_type_t),
    expected_salt_len: c_int = 0,
};
pub const mbedtls_pk_rsassa_pss_options = struct_mbedtls_pk_rsassa_pss_options;
pub const MBEDTLS_PK_DEBUG_NONE: c_int = 0;
pub const MBEDTLS_PK_DEBUG_MPI: c_int = 1;
pub const MBEDTLS_PK_DEBUG_ECP: c_int = 2;
pub const MBEDTLS_PK_DEBUG_PSA_EC: c_int = 3;
pub const mbedtls_pk_debug_type = c_uint;
pub const struct_mbedtls_pk_debug_item = extern struct {
    private_type: mbedtls_pk_debug_type = @import("std").mem.zeroes(mbedtls_pk_debug_type),
    private_name: [*c]const u8 = null,
    private_value: ?*anyopaque = null,
};
pub const mbedtls_pk_debug_item = struct_mbedtls_pk_debug_item;
pub const struct_mbedtls_pk_info_t = opaque {};
pub const mbedtls_pk_info_t = struct_mbedtls_pk_info_t;
pub const struct_mbedtls_pk_context = extern struct {
    private_pk_info: ?*const mbedtls_pk_info_t = null,
    private_pk_ctx: ?*anyopaque = null,
    pub const mbedtls_pk_init = __root.mbedtls_pk_init;
    pub const mbedtls_pk_free = __root.mbedtls_pk_free;
    pub const mbedtls_pk_setup = __root.mbedtls_pk_setup;
    pub const mbedtls_pk_setup_rsa_alt = __root.mbedtls_pk_setup_rsa_alt;
    pub const mbedtls_pk_get_bitlen = __root.mbedtls_pk_get_bitlen;
    pub const mbedtls_pk_get_len = __root.mbedtls_pk_get_len;
    pub const mbedtls_pk_can_do = __root.mbedtls_pk_can_do;
    pub const mbedtls_pk_get_psa_attributes = __root.mbedtls_pk_get_psa_attributes;
    pub const mbedtls_pk_import_into_psa = __root.mbedtls_pk_import_into_psa;
    pub const mbedtls_pk_verify = __root.mbedtls_pk_verify;
    pub const mbedtls_pk_verify_restartable = __root.mbedtls_pk_verify_restartable;
    pub const mbedtls_pk_sign = __root.mbedtls_pk_sign;
    pub const mbedtls_pk_sign_restartable = __root.mbedtls_pk_sign_restartable;
    pub const mbedtls_pk_decrypt = __root.mbedtls_pk_decrypt;
    pub const mbedtls_pk_encrypt = __root.mbedtls_pk_encrypt;
    pub const mbedtls_pk_check_pair = __root.mbedtls_pk_check_pair;
    pub const mbedtls_pk_debug = __root.mbedtls_pk_debug;
    pub const mbedtls_pk_get_name = __root.mbedtls_pk_get_name;
    pub const mbedtls_pk_get_type = __root.mbedtls_pk_get_type;
    pub const mbedtls_pk_rsa = __root.mbedtls_pk_rsa;
    pub const mbedtls_pk_ec = __root.mbedtls_pk_ec;
    pub const mbedtls_pk_parse_key = __root.mbedtls_pk_parse_key;
    pub const mbedtls_pk_parse_public_key = __root.mbedtls_pk_parse_public_key;
    pub const mbedtls_pk_parse_keyfile = __root.mbedtls_pk_parse_keyfile;
    pub const mbedtls_pk_parse_public_keyfile = __root.mbedtls_pk_parse_public_keyfile;
    pub const mbedtls_pk_write_key_der = __root.mbedtls_pk_write_key_der;
    pub const mbedtls_pk_write_pubkey_der = __root.mbedtls_pk_write_pubkey_der;
    pub const mbedtls_pk_write_pubkey_pem = __root.mbedtls_pk_write_pubkey_pem;
    pub const mbedtls_pk_write_key_pem = __root.mbedtls_pk_write_key_pem;
    pub const init = __root.mbedtls_pk_init;
    pub const free = __root.mbedtls_pk_free;
    pub const setup = __root.mbedtls_pk_setup;
    pub const alt = __root.mbedtls_pk_setup_rsa_alt;
    pub const bitlen = __root.mbedtls_pk_get_bitlen;
    pub const len = __root.mbedtls_pk_get_len;
    pub const do = __root.mbedtls_pk_can_do;
    pub const attributes = __root.mbedtls_pk_get_psa_attributes;
    pub const psa = __root.mbedtls_pk_import_into_psa;
    pub const verify = __root.mbedtls_pk_verify;
    pub const restartable = __root.mbedtls_pk_verify_restartable;
    pub const sign = __root.mbedtls_pk_sign;
    pub const decrypt = __root.mbedtls_pk_decrypt;
    pub const encrypt = __root.mbedtls_pk_encrypt;
    pub const pair = __root.mbedtls_pk_check_pair;
    pub const debug = __root.mbedtls_pk_debug;
    pub const name = __root.mbedtls_pk_get_name;
    pub const @"type" = __root.mbedtls_pk_get_type;
    pub const rsa = __root.mbedtls_pk_rsa;
    pub const ec = __root.mbedtls_pk_ec;
    pub const key = __root.mbedtls_pk_parse_key;
    pub const keyfile = __root.mbedtls_pk_parse_keyfile;
    pub const der = __root.mbedtls_pk_write_key_der;
    pub const pem = __root.mbedtls_pk_write_pubkey_pem;
};
pub const mbedtls_pk_context = struct_mbedtls_pk_context;
pub const mbedtls_pk_restart_ctx = anyopaque;
pub const mbedtls_pk_rsa_alt_decrypt_func = ?*const fn (ctx: ?*anyopaque, olen: [*c]usize, input: [*c]const u8, output: [*c]u8, output_max_len: usize) callconv(.c) c_int;
pub const mbedtls_pk_rsa_alt_sign_func = ?*const fn (ctx: ?*anyopaque, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, md_alg: mbedtls_md_type_t, hashlen: c_uint, hash: [*c]const u8, sig: [*c]u8) callconv(.c) c_int;
pub const mbedtls_pk_rsa_alt_key_len_func = ?*const fn (ctx: ?*anyopaque) callconv(.c) usize;
pub extern fn mbedtls_pk_info_from_type(pk_type: mbedtls_pk_type_t) ?*const mbedtls_pk_info_t;
pub extern fn mbedtls_pk_init(ctx: [*c]mbedtls_pk_context) void;
pub extern fn mbedtls_pk_free(ctx: [*c]mbedtls_pk_context) void;
pub extern fn mbedtls_pk_setup(ctx: [*c]mbedtls_pk_context, info: ?*const mbedtls_pk_info_t) c_int;
pub extern fn mbedtls_pk_setup_rsa_alt(ctx: [*c]mbedtls_pk_context, key: ?*anyopaque, decrypt_func: mbedtls_pk_rsa_alt_decrypt_func, sign_func: mbedtls_pk_rsa_alt_sign_func, key_len_func: mbedtls_pk_rsa_alt_key_len_func) c_int;
pub extern fn mbedtls_pk_get_bitlen(ctx: [*c]const mbedtls_pk_context) usize;
pub fn mbedtls_pk_get_len(arg_ctx: [*c]const mbedtls_pk_context) callconv(.c) usize {
    var ctx = arg_ctx;
    _ = &ctx;
    return (mbedtls_pk_get_bitlen(ctx) +% @as(usize, 7)) / @as(usize, 8);
}
pub extern fn mbedtls_pk_can_do(ctx: [*c]const mbedtls_pk_context, @"type": mbedtls_pk_type_t) c_int;
pub extern fn mbedtls_pk_get_psa_attributes(pk: [*c]const mbedtls_pk_context, usage: psa_key_usage_t, attributes: [*c]psa_key_attributes_t) c_int;
pub extern fn mbedtls_pk_import_into_psa(pk: [*c]const mbedtls_pk_context, attributes: [*c]const psa_key_attributes_t, key_id: [*c]mbedtls_svc_key_id_t) c_int;
pub extern fn mbedtls_pk_copy_from_psa(key_id: mbedtls_svc_key_id_t, pk: [*c]mbedtls_pk_context) c_int;
pub extern fn mbedtls_pk_copy_public_from_psa(key_id: mbedtls_svc_key_id_t, pk: [*c]mbedtls_pk_context) c_int;
pub extern fn mbedtls_pk_verify(ctx: [*c]mbedtls_pk_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hash_len: usize, sig: [*c]const u8, sig_len: usize) c_int;
pub extern fn mbedtls_pk_verify_restartable(ctx: [*c]mbedtls_pk_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hash_len: usize, sig: [*c]const u8, sig_len: usize, rs_ctx: ?*mbedtls_pk_restart_ctx) c_int;
pub extern fn mbedtls_pk_verify_ext(@"type": mbedtls_pk_type_t, options: ?*const anyopaque, ctx: [*c]mbedtls_pk_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hash_len: usize, sig: [*c]const u8, sig_len: usize) c_int;
pub extern fn mbedtls_pk_sign(ctx: [*c]mbedtls_pk_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hash_len: usize, sig: [*c]u8, sig_size: usize, sig_len: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_sign_ext(pk_type: mbedtls_pk_type_t, ctx: [*c]mbedtls_pk_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hash_len: usize, sig: [*c]u8, sig_size: usize, sig_len: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_sign_restartable(ctx: [*c]mbedtls_pk_context, md_alg: mbedtls_md_type_t, hash: [*c]const u8, hash_len: usize, sig: [*c]u8, sig_size: usize, sig_len: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque, rs_ctx: ?*mbedtls_pk_restart_ctx) c_int;
pub extern fn mbedtls_pk_decrypt(ctx: [*c]mbedtls_pk_context, input: [*c]const u8, ilen: usize, output: [*c]u8, olen: [*c]usize, osize: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_encrypt(ctx: [*c]mbedtls_pk_context, input: [*c]const u8, ilen: usize, output: [*c]u8, olen: [*c]usize, osize: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_check_pair(@"pub": [*c]const mbedtls_pk_context, prv: [*c]const mbedtls_pk_context, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_debug(ctx: [*c]const mbedtls_pk_context, items: [*c]mbedtls_pk_debug_item) c_int;
pub extern fn mbedtls_pk_get_name(ctx: [*c]const mbedtls_pk_context) [*c]const u8;
pub extern fn mbedtls_pk_get_type(ctx: [*c]const mbedtls_pk_context) mbedtls_pk_type_t;
pub fn mbedtls_pk_rsa(pk: mbedtls_pk_context) callconv(.c) [*c]mbedtls_rsa_context {
    _ = &pk;
    while (true) {
        switch (mbedtls_pk_get_type(&pk)) {
            @as(mbedtls_pk_type_t, MBEDTLS_PK_RSA) => return @ptrCast(@alignCast(pk.private_pk_ctx)),
            else => return null,
        }
        break;
    }
    return undefined;
}
pub fn mbedtls_pk_ec(pk: mbedtls_pk_context) callconv(.c) [*c]mbedtls_ecp_keypair {
    _ = &pk;
    while (true) {
        switch (mbedtls_pk_get_type(&pk)) {
            @as(mbedtls_pk_type_t, MBEDTLS_PK_ECKEY), @as(mbedtls_pk_type_t, MBEDTLS_PK_ECKEY_DH), @as(mbedtls_pk_type_t, MBEDTLS_PK_ECDSA) => return @ptrCast(@alignCast(pk.private_pk_ctx)),
            else => return null,
        }
        break;
    }
    return undefined;
}
pub extern fn mbedtls_pk_parse_key(ctx: [*c]mbedtls_pk_context, key: [*c]const u8, keylen: usize, pwd: [*c]const u8, pwdlen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_parse_public_key(ctx: [*c]mbedtls_pk_context, key: [*c]const u8, keylen: usize) c_int;
pub extern fn mbedtls_pk_parse_keyfile(ctx: [*c]mbedtls_pk_context, path: [*c]const u8, password: [*c]const u8, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_pk_parse_public_keyfile(ctx: [*c]mbedtls_pk_context, path: [*c]const u8) c_int;
pub extern fn mbedtls_pk_write_key_der(ctx: [*c]const mbedtls_pk_context, buf: [*c]u8, size: usize) c_int;
pub extern fn mbedtls_pk_write_pubkey_der(ctx: [*c]const mbedtls_pk_context, buf: [*c]u8, size: usize) c_int;
pub extern fn mbedtls_pk_write_pubkey_pem(ctx: [*c]const mbedtls_pk_context, buf: [*c]u8, size: usize) c_int;
pub extern fn mbedtls_pk_write_key_pem(ctx: [*c]const mbedtls_pk_context, buf: [*c]u8, size: usize) c_int;
pub extern fn mbedtls_pk_parse_subpubkey(p: [*c][*c]u8, end: [*c]const u8, pk: [*c]mbedtls_pk_context) c_int;
pub extern fn mbedtls_pk_write_pubkey(p: [*c][*c]u8, start: [*c]u8, key: [*c]const mbedtls_pk_context) c_int;
pub const MBEDTLS_KEY_EXCHANGE_NONE: c_int = 0;
pub const MBEDTLS_KEY_EXCHANGE_RSA: c_int = 1;
pub const MBEDTLS_KEY_EXCHANGE_DHE_RSA: c_int = 2;
pub const MBEDTLS_KEY_EXCHANGE_ECDHE_RSA: c_int = 3;
pub const MBEDTLS_KEY_EXCHANGE_ECDHE_ECDSA: c_int = 4;
pub const MBEDTLS_KEY_EXCHANGE_PSK: c_int = 5;
pub const MBEDTLS_KEY_EXCHANGE_DHE_PSK: c_int = 6;
pub const MBEDTLS_KEY_EXCHANGE_RSA_PSK: c_int = 7;
pub const MBEDTLS_KEY_EXCHANGE_ECDHE_PSK: c_int = 8;
pub const MBEDTLS_KEY_EXCHANGE_ECDH_RSA: c_int = 9;
pub const MBEDTLS_KEY_EXCHANGE_ECDH_ECDSA: c_int = 10;
pub const MBEDTLS_KEY_EXCHANGE_ECJPAKE: c_int = 11;
pub const mbedtls_key_exchange_type_t = c_uint;
pub const struct_mbedtls_ssl_ciphersuite_t = extern struct {
    private_id: c_int = 0,
    private_name: [*c]const u8 = null,
    private_cipher: u8 = 0,
    private_mac: u8 = 0,
    private_key_exchange: u8 = 0,
    private_flags: u8 = 0,
    private_min_tls_version: u16 = 0,
    private_max_tls_version: u16 = 0,
    pub const mbedtls_ssl_ciphersuite_get_name = __root.mbedtls_ssl_ciphersuite_get_name;
    pub const mbedtls_ssl_ciphersuite_get_id = __root.mbedtls_ssl_ciphersuite_get_id;
    pub const mbedtls_ssl_ciphersuite_get_cipher_key_bitlen = __root.mbedtls_ssl_ciphersuite_get_cipher_key_bitlen;
    pub const name = __root.mbedtls_ssl_ciphersuite_get_name;
    pub const id = __root.mbedtls_ssl_ciphersuite_get_id;
    pub const bitlen = __root.mbedtls_ssl_ciphersuite_get_cipher_key_bitlen;
};
pub const mbedtls_ssl_ciphersuite_t = struct_mbedtls_ssl_ciphersuite_t;
pub extern fn mbedtls_ssl_list_ciphersuites() [*c]const c_int;
pub extern fn mbedtls_ssl_ciphersuite_from_string(ciphersuite_name: [*c]const u8) [*c]const mbedtls_ssl_ciphersuite_t;
pub extern fn mbedtls_ssl_ciphersuite_from_id(ciphersuite_id: c_int) [*c]const mbedtls_ssl_ciphersuite_t;
pub fn mbedtls_ssl_ciphersuite_get_name(arg_info: [*c]const mbedtls_ssl_ciphersuite_t) callconv(.c) [*c]const u8 {
    var info = arg_info;
    _ = &info;
    return info.*.private_name;
}
pub fn mbedtls_ssl_ciphersuite_get_id(arg_info: [*c]const mbedtls_ssl_ciphersuite_t) callconv(.c) c_int {
    var info = arg_info;
    _ = &info;
    return info.*.private_id;
}
pub extern fn mbedtls_ssl_ciphersuite_get_cipher_key_bitlen(info: [*c]const mbedtls_ssl_ciphersuite_t) usize;
pub const struct_mbedtls_asn1_buf = extern struct {
    tag: c_int = 0,
    len: usize = 0,
    p: [*c]u8 = null,
    pub const mbedtls_x509_parse_subject_alt_name = __root.mbedtls_x509_parse_subject_alt_name;
    pub const name = __root.mbedtls_x509_parse_subject_alt_name;
};
pub const mbedtls_asn1_buf = struct_mbedtls_asn1_buf;
pub const struct_mbedtls_asn1_bitstring = extern struct {
    len: usize = 0,
    unused_bits: u8 = 0,
    p: [*c]u8 = null,
};
pub const mbedtls_asn1_bitstring = struct_mbedtls_asn1_bitstring;
pub const struct_mbedtls_asn1_sequence = extern struct {
    buf: mbedtls_asn1_buf = @import("std").mem.zeroes(mbedtls_asn1_buf),
    next: [*c]struct_mbedtls_asn1_sequence = null,
    pub const mbedtls_asn1_sequence_free = __root.mbedtls_asn1_sequence_free;
    pub const free = __root.mbedtls_asn1_sequence_free;
};
pub const mbedtls_asn1_sequence = struct_mbedtls_asn1_sequence;
pub const struct_mbedtls_asn1_named_data = extern struct {
    oid: mbedtls_asn1_buf = @import("std").mem.zeroes(mbedtls_asn1_buf),
    val: mbedtls_asn1_buf = @import("std").mem.zeroes(mbedtls_asn1_buf),
    next: [*c]struct_mbedtls_asn1_named_data = null,
    private_next_merged: u8 = 0,
    pub const mbedtls_asn1_find_named_data = __root.mbedtls_asn1_find_named_data;
    pub const mbedtls_asn1_free_named_data = __root.mbedtls_asn1_free_named_data;
    pub const mbedtls_asn1_free_named_data_list_shallow = __root.mbedtls_asn1_free_named_data_list_shallow;
    pub const mbedtls_x509_dn_get_next = __root.mbedtls_x509_dn_get_next;
    pub const data = __root.mbedtls_asn1_find_named_data;
    pub const shallow = __root.mbedtls_asn1_free_named_data_list_shallow;
};
pub const mbedtls_asn1_named_data = struct_mbedtls_asn1_named_data;
pub extern fn mbedtls_asn1_get_len(p: [*c][*c]u8, end: [*c]const u8, len: [*c]usize) c_int;
pub extern fn mbedtls_asn1_get_tag(p: [*c][*c]u8, end: [*c]const u8, len: [*c]usize, tag: c_int) c_int;
pub extern fn mbedtls_asn1_get_bool(p: [*c][*c]u8, end: [*c]const u8, val: [*c]c_int) c_int;
pub extern fn mbedtls_asn1_get_int(p: [*c][*c]u8, end: [*c]const u8, val: [*c]c_int) c_int;
pub extern fn mbedtls_asn1_get_enum(p: [*c][*c]u8, end: [*c]const u8, val: [*c]c_int) c_int;
pub extern fn mbedtls_asn1_get_bitstring(p: [*c][*c]u8, end: [*c]const u8, bs: [*c]mbedtls_asn1_bitstring) c_int;
pub extern fn mbedtls_asn1_get_bitstring_null(p: [*c][*c]u8, end: [*c]const u8, len: [*c]usize) c_int;
pub extern fn mbedtls_asn1_get_sequence_of(p: [*c][*c]u8, end: [*c]const u8, cur: [*c]mbedtls_asn1_sequence, tag: c_int) c_int;
pub extern fn mbedtls_asn1_sequence_free(seq: [*c]mbedtls_asn1_sequence) void;
pub extern fn mbedtls_asn1_traverse_sequence_of(p: [*c][*c]u8, end: [*c]const u8, tag_must_mask: u8, tag_must_val: u8, tag_may_mask: u8, tag_may_val: u8, cb: ?*const fn (ctx: ?*anyopaque, tag: c_int, start: [*c]u8, len: usize) callconv(.c) c_int, ctx: ?*anyopaque) c_int;
pub extern fn mbedtls_asn1_get_mpi(p: [*c][*c]u8, end: [*c]const u8, X: [*c]mbedtls_mpi) c_int;
pub extern fn mbedtls_asn1_get_alg(p: [*c][*c]u8, end: [*c]const u8, alg: [*c]mbedtls_asn1_buf, params: [*c]mbedtls_asn1_buf) c_int;
pub extern fn mbedtls_asn1_get_alg_null(p: [*c][*c]u8, end: [*c]const u8, alg: [*c]mbedtls_asn1_buf) c_int;
pub extern fn mbedtls_asn1_find_named_data(list: [*c]const mbedtls_asn1_named_data, oid: [*c]const u8, len: usize) [*c]const mbedtls_asn1_named_data;
pub extern fn mbedtls_asn1_free_named_data(entry: [*c]mbedtls_asn1_named_data) void;
pub extern fn mbedtls_asn1_free_named_data_list(head: [*c][*c]mbedtls_asn1_named_data) void;
pub extern fn mbedtls_asn1_free_named_data_list_shallow(name: [*c]mbedtls_asn1_named_data) void;
pub const mbedtls_x509_buf = mbedtls_asn1_buf;
pub const mbedtls_x509_bitstring = mbedtls_asn1_bitstring;
pub const mbedtls_x509_name = mbedtls_asn1_named_data;
pub const mbedtls_x509_sequence = mbedtls_asn1_sequence;
pub const struct_mbedtls_x509_authority = extern struct {
    keyIdentifier: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    authorityCertIssuer: mbedtls_x509_sequence = @import("std").mem.zeroes(mbedtls_x509_sequence),
    authorityCertSerialNumber: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
};
pub const mbedtls_x509_authority = struct_mbedtls_x509_authority;
pub const struct_mbedtls_x509_time = extern struct {
    year: c_int = 0,
    mon: c_int = 0,
    day: c_int = 0,
    hour: c_int = 0,
    min: c_int = 0,
    sec: c_int = 0,
    pub const mbedtls_x509_time_cmp = __root.mbedtls_x509_time_cmp;
    pub const mbedtls_x509_time_is_past = __root.mbedtls_x509_time_is_past;
    pub const mbedtls_x509_time_is_future = __root.mbedtls_x509_time_is_future;
    pub const cmp = __root.mbedtls_x509_time_cmp;
    pub const past = __root.mbedtls_x509_time_is_past;
    pub const future = __root.mbedtls_x509_time_is_future;
};
pub const mbedtls_x509_time = struct_mbedtls_x509_time;
const struct_unnamed_23 = extern struct {
    oid: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    val: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
};
const union_unnamed_22 = extern union {
    hardware_module_name: struct_unnamed_23,
};
pub const struct_mbedtls_x509_san_other_name = extern struct {
    type_id: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    value: union_unnamed_22 = @import("std").mem.zeroes(union_unnamed_22),
};
pub const mbedtls_x509_san_other_name = struct_mbedtls_x509_san_other_name;
const union_unnamed_24 = extern union {
    other_name: mbedtls_x509_san_other_name,
    directory_name: mbedtls_x509_name,
    unstructured_name: mbedtls_x509_buf,
};
pub const struct_mbedtls_x509_subject_alternative_name = extern struct {
    type: c_int = 0,
    san: union_unnamed_24 = @import("std").mem.zeroes(union_unnamed_24),
    pub const mbedtls_x509_free_subject_alt_name = __root.mbedtls_x509_free_subject_alt_name;
    pub const name = __root.mbedtls_x509_free_subject_alt_name;
};
pub const mbedtls_x509_subject_alternative_name = struct_mbedtls_x509_subject_alternative_name;
pub const struct_mbedtls_x509_san_list = extern struct {
    node: mbedtls_x509_subject_alternative_name = @import("std").mem.zeroes(mbedtls_x509_subject_alternative_name),
    next: [*c]struct_mbedtls_x509_san_list = null,
};
pub const mbedtls_x509_san_list = struct_mbedtls_x509_san_list;
pub extern fn mbedtls_x509_dn_gets(buf: [*c]u8, size: usize, dn: [*c]const mbedtls_x509_name) c_int;
pub extern fn mbedtls_x509_string_to_names(head: [*c][*c]mbedtls_asn1_named_data, name: [*c]const u8) c_int;
pub fn mbedtls_x509_dn_get_next(arg_dn: [*c]mbedtls_x509_name) callconv(.c) [*c]mbedtls_x509_name {
    var dn = arg_dn;
    _ = &dn;
    while ((@as(c_int, dn.*.private_next_merged) != 0) and (@as(?*anyopaque, @ptrCast(@alignCast(dn.*.next))) != @as(?*anyopaque, null))) {
        dn = dn.*.next;
    }
    return dn.*.next;
}
pub extern fn mbedtls_x509_serial_gets(buf: [*c]u8, size: usize, serial: [*c]const mbedtls_x509_buf) c_int;
pub extern fn mbedtls_x509_time_cmp(t1: [*c]const mbedtls_x509_time, t2: [*c]const mbedtls_x509_time) c_int;
pub extern fn mbedtls_x509_time_gmtime(tt: mbedtls_time_t, now: [*c]mbedtls_x509_time) c_int;
pub extern fn mbedtls_x509_time_is_past(to: [*c]const mbedtls_x509_time) c_int;
pub extern fn mbedtls_x509_time_is_future(from: [*c]const mbedtls_x509_time) c_int;
pub extern fn mbedtls_x509_parse_subject_alt_name(san_buf: [*c]const mbedtls_x509_buf, san: [*c]mbedtls_x509_subject_alternative_name) c_int;
pub extern fn mbedtls_x509_free_subject_alt_name(san: [*c]mbedtls_x509_subject_alternative_name) void;
pub extern fn mbedtls_x509_crt_parse_cn_inet_pton(cn: [*c]const u8, dst: ?*anyopaque) usize;
pub const struct_mbedtls_x509_crl_entry = extern struct {
    raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    serial: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    revocation_date: mbedtls_x509_time = @import("std").mem.zeroes(mbedtls_x509_time),
    entry_ext: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    next: [*c]struct_mbedtls_x509_crl_entry = null,
};
pub const mbedtls_x509_crl_entry = struct_mbedtls_x509_crl_entry;
pub const struct_mbedtls_x509_crl = extern struct {
    raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    tbs: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    version: c_int = 0,
    sig_oid: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    issuer_raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    issuer: mbedtls_x509_name = @import("std").mem.zeroes(mbedtls_x509_name),
    this_update: mbedtls_x509_time = @import("std").mem.zeroes(mbedtls_x509_time),
    next_update: mbedtls_x509_time = @import("std").mem.zeroes(mbedtls_x509_time),
    entry: mbedtls_x509_crl_entry = @import("std").mem.zeroes(mbedtls_x509_crl_entry),
    crl_ext: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    private_sig_oid2: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    private_sig: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    private_sig_md: mbedtls_md_type_t = @import("std").mem.zeroes(mbedtls_md_type_t),
    private_sig_pk: mbedtls_pk_type_t = @import("std").mem.zeroes(mbedtls_pk_type_t),
    private_sig_opts: ?*anyopaque = null,
    next: [*c]struct_mbedtls_x509_crl = null,
    pub const mbedtls_x509_crl_parse_der = __root.mbedtls_x509_crl_parse_der;
    pub const mbedtls_x509_crl_parse = __root.mbedtls_x509_crl_parse;
    pub const mbedtls_x509_crl_parse_file = __root.mbedtls_x509_crl_parse_file;
    pub const mbedtls_x509_crl_init = __root.mbedtls_x509_crl_init;
    pub const mbedtls_x509_crl_free = __root.mbedtls_x509_crl_free;
    pub const der = __root.mbedtls_x509_crl_parse_der;
    pub const parse = __root.mbedtls_x509_crl_parse;
    pub const file = __root.mbedtls_x509_crl_parse_file;
    pub const init = __root.mbedtls_x509_crl_init;
    pub const free = __root.mbedtls_x509_crl_free;
};
pub const mbedtls_x509_crl = struct_mbedtls_x509_crl;
pub extern fn mbedtls_x509_crl_parse_der(chain: [*c]mbedtls_x509_crl, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_x509_crl_parse(chain: [*c]mbedtls_x509_crl, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_x509_crl_parse_file(chain: [*c]mbedtls_x509_crl, path: [*c]const u8) c_int;
pub extern fn mbedtls_x509_crl_info(buf: [*c]u8, size: usize, prefix: [*c]const u8, crl: [*c]const mbedtls_x509_crl) c_int;
pub extern fn mbedtls_x509_crl_init(crl: [*c]mbedtls_x509_crl) void;
pub extern fn mbedtls_x509_crl_free(crl: [*c]mbedtls_x509_crl) void;
pub const struct_mbedtls_x509_crt = extern struct {
    private_own_buffer: c_int = 0,
    raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    tbs: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    version: c_int = 0,
    serial: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    sig_oid: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    issuer_raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    subject_raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    issuer: mbedtls_x509_name = @import("std").mem.zeroes(mbedtls_x509_name),
    subject: mbedtls_x509_name = @import("std").mem.zeroes(mbedtls_x509_name),
    valid_from: mbedtls_x509_time = @import("std").mem.zeroes(mbedtls_x509_time),
    valid_to: mbedtls_x509_time = @import("std").mem.zeroes(mbedtls_x509_time),
    pk_raw: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    pk: mbedtls_pk_context = @import("std").mem.zeroes(mbedtls_pk_context),
    issuer_id: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    subject_id: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    v3_ext: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    subject_alt_names: mbedtls_x509_sequence = @import("std").mem.zeroes(mbedtls_x509_sequence),
    subject_key_id: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    authority_key_id: mbedtls_x509_authority = @import("std").mem.zeroes(mbedtls_x509_authority),
    certificate_policies: mbedtls_x509_sequence = @import("std").mem.zeroes(mbedtls_x509_sequence),
    private_ext_types: c_int = 0,
    private_ca_istrue: c_int = 0,
    private_max_pathlen: c_int = 0,
    private_key_usage: c_uint = 0,
    ext_key_usage: mbedtls_x509_sequence = @import("std").mem.zeroes(mbedtls_x509_sequence),
    private_ns_cert_type: u8 = 0,
    private_sig: mbedtls_x509_buf = @import("std").mem.zeroes(mbedtls_x509_buf),
    private_sig_md: mbedtls_md_type_t = @import("std").mem.zeroes(mbedtls_md_type_t),
    private_sig_pk: mbedtls_pk_type_t = @import("std").mem.zeroes(mbedtls_pk_type_t),
    private_sig_opts: ?*anyopaque = null,
    next: [*c]struct_mbedtls_x509_crt = null,
    pub const mbedtls_x509_crt_parse_der = __root.mbedtls_x509_crt_parse_der;
    pub const mbedtls_x509_crt_parse_der_with_ext_cb = __root.mbedtls_x509_crt_parse_der_with_ext_cb;
    pub const mbedtls_x509_crt_parse_der_nocopy = __root.mbedtls_x509_crt_parse_der_nocopy;
    pub const mbedtls_x509_crt_parse = __root.mbedtls_x509_crt_parse;
    pub const mbedtls_x509_crt_parse_file = __root.mbedtls_x509_crt_parse_file;
    pub const mbedtls_x509_crt_parse_path = __root.mbedtls_x509_crt_parse_path;
    pub const mbedtls_x509_crt_verify = __root.mbedtls_x509_crt_verify;
    pub const mbedtls_x509_crt_verify_with_profile = __root.mbedtls_x509_crt_verify_with_profile;
    pub const mbedtls_x509_crt_verify_restartable = __root.mbedtls_x509_crt_verify_restartable;
    pub const mbedtls_x509_crt_check_key_usage = __root.mbedtls_x509_crt_check_key_usage;
    pub const mbedtls_x509_crt_check_extended_key_usage = __root.mbedtls_x509_crt_check_extended_key_usage;
    pub const mbedtls_x509_crt_is_revoked = __root.mbedtls_x509_crt_is_revoked;
    pub const mbedtls_x509_crt_init = __root.mbedtls_x509_crt_init;
    pub const mbedtls_x509_crt_free = __root.mbedtls_x509_crt_free;
    pub const mbedtls_x509_crt_has_ext_type = __root.mbedtls_x509_crt_has_ext_type;
    pub const mbedtls_x509_crt_get_ca_istrue = __root.mbedtls_x509_crt_get_ca_istrue;
    pub const der = __root.mbedtls_x509_crt_parse_der;
    pub const cb = __root.mbedtls_x509_crt_parse_der_with_ext_cb;
    pub const nocopy = __root.mbedtls_x509_crt_parse_der_nocopy;
    pub const parse = __root.mbedtls_x509_crt_parse;
    pub const file = __root.mbedtls_x509_crt_parse_file;
    pub const path = __root.mbedtls_x509_crt_parse_path;
    pub const verify = __root.mbedtls_x509_crt_verify;
    pub const profile = __root.mbedtls_x509_crt_verify_with_profile;
    pub const restartable = __root.mbedtls_x509_crt_verify_restartable;
    pub const usage = __root.mbedtls_x509_crt_check_key_usage;
    pub const revoked = __root.mbedtls_x509_crt_is_revoked;
    pub const init = __root.mbedtls_x509_crt_init;
    pub const free = __root.mbedtls_x509_crt_free;
    pub const @"type" = __root.mbedtls_x509_crt_has_ext_type;
    pub const istrue = __root.mbedtls_x509_crt_get_ca_istrue;
};
pub const mbedtls_x509_crt = struct_mbedtls_x509_crt;
pub const struct_mbedtls_x509_crt_profile = extern struct {
    allowed_mds: u32 = 0,
    allowed_pks: u32 = 0,
    allowed_curves: u32 = 0,
    rsa_min_bitlen: u32 = 0,
};
pub const mbedtls_x509_crt_profile = struct_mbedtls_x509_crt_profile;
pub const struct_mbedtls_x509write_cert = extern struct {
    private_version: c_int = 0,
    private_serial: [20]u8 = @import("std").mem.zeroes([20]u8),
    private_serial_len: usize = 0,
    private_subject_key: [*c]mbedtls_pk_context = null,
    private_issuer_key: [*c]mbedtls_pk_context = null,
    private_subject: [*c]mbedtls_asn1_named_data = null,
    private_issuer: [*c]mbedtls_asn1_named_data = null,
    private_md_alg: mbedtls_md_type_t = @import("std").mem.zeroes(mbedtls_md_type_t),
    private_not_before: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_not_after: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_extensions: [*c]mbedtls_asn1_named_data = null,
    pub const mbedtls_x509write_crt_set_subject_alternative_name = __root.mbedtls_x509write_crt_set_subject_alternative_name;
    pub const mbedtls_x509write_crt_init = __root.mbedtls_x509write_crt_init;
    pub const mbedtls_x509write_crt_set_version = __root.mbedtls_x509write_crt_set_version;
    pub const mbedtls_x509write_crt_set_serial = __root.mbedtls_x509write_crt_set_serial;
    pub const mbedtls_x509write_crt_set_serial_raw = __root.mbedtls_x509write_crt_set_serial_raw;
    pub const mbedtls_x509write_crt_set_validity = __root.mbedtls_x509write_crt_set_validity;
    pub const mbedtls_x509write_crt_set_issuer_name = __root.mbedtls_x509write_crt_set_issuer_name;
    pub const mbedtls_x509write_crt_set_subject_name = __root.mbedtls_x509write_crt_set_subject_name;
    pub const mbedtls_x509write_crt_set_subject_key = __root.mbedtls_x509write_crt_set_subject_key;
    pub const mbedtls_x509write_crt_set_issuer_key = __root.mbedtls_x509write_crt_set_issuer_key;
    pub const mbedtls_x509write_crt_set_md_alg = __root.mbedtls_x509write_crt_set_md_alg;
    pub const mbedtls_x509write_crt_set_extension = __root.mbedtls_x509write_crt_set_extension;
    pub const mbedtls_x509write_crt_set_basic_constraints = __root.mbedtls_x509write_crt_set_basic_constraints;
    pub const mbedtls_x509write_crt_set_subject_key_identifier = __root.mbedtls_x509write_crt_set_subject_key_identifier;
    pub const mbedtls_x509write_crt_set_authority_key_identifier = __root.mbedtls_x509write_crt_set_authority_key_identifier;
    pub const mbedtls_x509write_crt_set_key_usage = __root.mbedtls_x509write_crt_set_key_usage;
    pub const mbedtls_x509write_crt_set_ext_key_usage = __root.mbedtls_x509write_crt_set_ext_key_usage;
    pub const mbedtls_x509write_crt_set_ns_cert_type = __root.mbedtls_x509write_crt_set_ns_cert_type;
    pub const mbedtls_x509write_crt_free = __root.mbedtls_x509write_crt_free;
    pub const mbedtls_x509write_crt_der = __root.mbedtls_x509write_crt_der;
    pub const mbedtls_x509write_crt_pem = __root.mbedtls_x509write_crt_pem;
    pub const name = __root.mbedtls_x509write_crt_set_subject_alternative_name;
    pub const init = __root.mbedtls_x509write_crt_init;
    pub const version = __root.mbedtls_x509write_crt_set_version;
    pub const serial = __root.mbedtls_x509write_crt_set_serial;
    pub const raw = __root.mbedtls_x509write_crt_set_serial_raw;
    pub const validity = __root.mbedtls_x509write_crt_set_validity;
    pub const key = __root.mbedtls_x509write_crt_set_subject_key;
    pub const alg = __root.mbedtls_x509write_crt_set_md_alg;
    pub const extension = __root.mbedtls_x509write_crt_set_extension;
    pub const constraints = __root.mbedtls_x509write_crt_set_basic_constraints;
    pub const identifier = __root.mbedtls_x509write_crt_set_subject_key_identifier;
    pub const usage = __root.mbedtls_x509write_crt_set_key_usage;
    pub const @"type" = __root.mbedtls_x509write_crt_set_ns_cert_type;
    pub const free = __root.mbedtls_x509write_crt_free;
    pub const der = __root.mbedtls_x509write_crt_der;
    pub const pem = __root.mbedtls_x509write_crt_pem;
};
pub const mbedtls_x509write_cert = struct_mbedtls_x509write_cert;
pub extern fn mbedtls_x509write_crt_set_subject_alternative_name(ctx: [*c]mbedtls_x509write_cert, san_list: [*c]const mbedtls_x509_san_list) c_int;
pub const mbedtls_x509_crt_verify_chain_item = extern struct {
    private_crt: [*c]mbedtls_x509_crt = null,
    private_flags: u32 = 0,
};
pub const mbedtls_x509_crt_verify_chain = extern struct {
    private_items: [10]mbedtls_x509_crt_verify_chain_item = @import("std").mem.zeroes([10]mbedtls_x509_crt_verify_chain_item),
    private_len: c_uint = 0,
};
pub const mbedtls_x509_crt_restart_ctx = anyopaque;
pub extern const mbedtls_x509_crt_profile_default: mbedtls_x509_crt_profile;
pub extern const mbedtls_x509_crt_profile_next: mbedtls_x509_crt_profile;
pub extern const mbedtls_x509_crt_profile_suiteb: mbedtls_x509_crt_profile;
pub extern const mbedtls_x509_crt_profile_none: mbedtls_x509_crt_profile;
pub extern fn mbedtls_x509_crt_parse_der(chain: [*c]mbedtls_x509_crt, buf: [*c]const u8, buflen: usize) c_int;
pub const mbedtls_x509_crt_ext_cb_t = ?*const fn (p_ctx: ?*anyopaque, crt: [*c]const mbedtls_x509_crt, oid: [*c]const mbedtls_x509_buf, critical: c_int, p: [*c]const u8, end: [*c]const u8) callconv(.c) c_int;
pub extern fn mbedtls_x509_crt_parse_der_with_ext_cb(chain: [*c]mbedtls_x509_crt, buf: [*c]const u8, buflen: usize, make_copy: c_int, cb: mbedtls_x509_crt_ext_cb_t, p_ctx: ?*anyopaque) c_int;
pub extern fn mbedtls_x509_crt_parse_der_nocopy(chain: [*c]mbedtls_x509_crt, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_x509_crt_parse(chain: [*c]mbedtls_x509_crt, buf: [*c]const u8, buflen: usize) c_int;
pub extern fn mbedtls_x509_crt_parse_file(chain: [*c]mbedtls_x509_crt, path: [*c]const u8) c_int;
pub extern fn mbedtls_x509_crt_parse_path(chain: [*c]mbedtls_x509_crt, path: [*c]const u8) c_int;
pub extern fn mbedtls_x509_crt_info(buf: [*c]u8, size: usize, prefix: [*c]const u8, crt: [*c]const mbedtls_x509_crt) c_int;
pub extern fn mbedtls_x509_crt_verify_info(buf: [*c]u8, size: usize, prefix: [*c]const u8, flags: u32) c_int;
pub extern fn mbedtls_x509_crt_verify(crt: [*c]mbedtls_x509_crt, trust_ca: [*c]mbedtls_x509_crt, ca_crl: [*c]mbedtls_x509_crl, cn: [*c]const u8, flags: [*c]u32, f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int, p_vrfy: ?*anyopaque) c_int;
pub extern fn mbedtls_x509_crt_verify_with_profile(crt: [*c]mbedtls_x509_crt, trust_ca: [*c]mbedtls_x509_crt, ca_crl: [*c]mbedtls_x509_crl, profile: [*c]const mbedtls_x509_crt_profile, cn: [*c]const u8, flags: [*c]u32, f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int, p_vrfy: ?*anyopaque) c_int;
pub extern fn mbedtls_x509_crt_verify_restartable(crt: [*c]mbedtls_x509_crt, trust_ca: [*c]mbedtls_x509_crt, ca_crl: [*c]mbedtls_x509_crl, profile: [*c]const mbedtls_x509_crt_profile, cn: [*c]const u8, flags: [*c]u32, f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int, p_vrfy: ?*anyopaque, rs_ctx: ?*mbedtls_x509_crt_restart_ctx) c_int;
pub const mbedtls_x509_crt_ca_cb_t = ?*const fn (p_ctx: ?*anyopaque, child: [*c]const mbedtls_x509_crt, candidate_cas: [*c][*c]mbedtls_x509_crt) callconv(.c) c_int;
pub extern fn mbedtls_x509_crt_check_key_usage(crt: [*c]const mbedtls_x509_crt, usage: c_uint) c_int;
pub extern fn mbedtls_x509_crt_check_extended_key_usage(crt: [*c]const mbedtls_x509_crt, usage_oid: [*c]const u8, usage_len: usize) c_int;
pub extern fn mbedtls_x509_crt_is_revoked(crt: [*c]const mbedtls_x509_crt, crl: [*c]const mbedtls_x509_crl) c_int;
pub extern fn mbedtls_x509_crt_init(crt: [*c]mbedtls_x509_crt) void;
pub extern fn mbedtls_x509_crt_free(crt: [*c]mbedtls_x509_crt) void;
pub fn mbedtls_x509_crt_has_ext_type(arg_ctx: [*c]const mbedtls_x509_crt, arg_ext_type: c_int) callconv(.c) c_int {
    var ctx = arg_ctx;
    _ = &ctx;
    var ext_type = arg_ext_type;
    _ = &ext_type;
    return ctx.*.private_ext_types & ext_type;
}
pub extern fn mbedtls_x509_crt_get_ca_istrue(crt: [*c]const mbedtls_x509_crt) c_int;
pub extern fn mbedtls_x509write_crt_init(ctx: [*c]mbedtls_x509write_cert) void;
pub extern fn mbedtls_x509write_crt_set_version(ctx: [*c]mbedtls_x509write_cert, version: c_int) void;
pub extern fn mbedtls_x509write_crt_set_serial(ctx: [*c]mbedtls_x509write_cert, serial: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_x509write_crt_set_serial_raw(ctx: [*c]mbedtls_x509write_cert, serial: [*c]u8, serial_len: usize) c_int;
pub extern fn mbedtls_x509write_crt_set_validity(ctx: [*c]mbedtls_x509write_cert, not_before: [*c]const u8, not_after: [*c]const u8) c_int;
pub extern fn mbedtls_x509write_crt_set_issuer_name(ctx: [*c]mbedtls_x509write_cert, issuer_name: [*c]const u8) c_int;
pub extern fn mbedtls_x509write_crt_set_subject_name(ctx: [*c]mbedtls_x509write_cert, subject_name: [*c]const u8) c_int;
pub extern fn mbedtls_x509write_crt_set_subject_key(ctx: [*c]mbedtls_x509write_cert, key: [*c]mbedtls_pk_context) void;
pub extern fn mbedtls_x509write_crt_set_issuer_key(ctx: [*c]mbedtls_x509write_cert, key: [*c]mbedtls_pk_context) void;
pub extern fn mbedtls_x509write_crt_set_md_alg(ctx: [*c]mbedtls_x509write_cert, md_alg: mbedtls_md_type_t) void;
pub extern fn mbedtls_x509write_crt_set_extension(ctx: [*c]mbedtls_x509write_cert, oid: [*c]const u8, oid_len: usize, critical: c_int, val: [*c]const u8, val_len: usize) c_int;
pub extern fn mbedtls_x509write_crt_set_basic_constraints(ctx: [*c]mbedtls_x509write_cert, is_ca: c_int, max_pathlen: c_int) c_int;
pub extern fn mbedtls_x509write_crt_set_subject_key_identifier(ctx: [*c]mbedtls_x509write_cert) c_int;
pub extern fn mbedtls_x509write_crt_set_authority_key_identifier(ctx: [*c]mbedtls_x509write_cert) c_int;
pub extern fn mbedtls_x509write_crt_set_key_usage(ctx: [*c]mbedtls_x509write_cert, key_usage: c_uint) c_int;
pub extern fn mbedtls_x509write_crt_set_ext_key_usage(ctx: [*c]mbedtls_x509write_cert, exts: [*c]const mbedtls_asn1_sequence) c_int;
pub extern fn mbedtls_x509write_crt_set_ns_cert_type(ctx: [*c]mbedtls_x509write_cert, ns_cert_type: u8) c_int;
pub extern fn mbedtls_x509write_crt_free(ctx: [*c]mbedtls_x509write_cert) void;
pub extern fn mbedtls_x509write_crt_der(ctx: [*c]mbedtls_x509write_cert, buf: [*c]u8, size: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_x509write_crt_pem(ctx: [*c]mbedtls_x509write_cert, buf: [*c]u8, size: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub const MBEDTLS_DHM_PARAM_P: c_int = 0;
pub const MBEDTLS_DHM_PARAM_G: c_int = 1;
pub const MBEDTLS_DHM_PARAM_X: c_int = 2;
pub const MBEDTLS_DHM_PARAM_GX: c_int = 3;
pub const MBEDTLS_DHM_PARAM_GY: c_int = 4;
pub const MBEDTLS_DHM_PARAM_K: c_int = 5;
pub const mbedtls_dhm_parameter = c_uint;
pub const struct_mbedtls_dhm_context = extern struct {
    private_P: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_G: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_X: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_GX: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_GY: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_K: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_RP: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Vi: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Vf: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_pX: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    pub const mbedtls_dhm_init = __root.mbedtls_dhm_init;
    pub const mbedtls_dhm_read_params = __root.mbedtls_dhm_read_params;
    pub const mbedtls_dhm_make_params = __root.mbedtls_dhm_make_params;
    pub const mbedtls_dhm_set_group = __root.mbedtls_dhm_set_group;
    pub const mbedtls_dhm_read_public = __root.mbedtls_dhm_read_public;
    pub const mbedtls_dhm_make_public = __root.mbedtls_dhm_make_public;
    pub const mbedtls_dhm_calc_secret = __root.mbedtls_dhm_calc_secret;
    pub const mbedtls_dhm_get_bitlen = __root.mbedtls_dhm_get_bitlen;
    pub const mbedtls_dhm_get_len = __root.mbedtls_dhm_get_len;
    pub const mbedtls_dhm_get_value = __root.mbedtls_dhm_get_value;
    pub const mbedtls_dhm_free = __root.mbedtls_dhm_free;
    pub const mbedtls_dhm_parse_dhm = __root.mbedtls_dhm_parse_dhm;
    pub const mbedtls_dhm_parse_dhmfile = __root.mbedtls_dhm_parse_dhmfile;
    pub const init = __root.mbedtls_dhm_init;
    pub const params = __root.mbedtls_dhm_read_params;
    pub const group = __root.mbedtls_dhm_set_group;
    pub const public = __root.mbedtls_dhm_read_public;
    pub const secret = __root.mbedtls_dhm_calc_secret;
    pub const bitlen = __root.mbedtls_dhm_get_bitlen;
    pub const len = __root.mbedtls_dhm_get_len;
    pub const value = __root.mbedtls_dhm_get_value;
    pub const free = __root.mbedtls_dhm_free;
    pub const dhm = __root.mbedtls_dhm_parse_dhm;
    pub const dhmfile = __root.mbedtls_dhm_parse_dhmfile;
};
pub const mbedtls_dhm_context = struct_mbedtls_dhm_context;
pub extern fn mbedtls_dhm_init(ctx: [*c]mbedtls_dhm_context) void;
pub extern fn mbedtls_dhm_read_params(ctx: [*c]mbedtls_dhm_context, p: [*c][*c]u8, end: [*c]const u8) c_int;
pub extern fn mbedtls_dhm_make_params(ctx: [*c]mbedtls_dhm_context, x_size: c_int, output: [*c]u8, olen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_dhm_set_group(ctx: [*c]mbedtls_dhm_context, P: [*c]const mbedtls_mpi, G: [*c]const mbedtls_mpi) c_int;
pub extern fn mbedtls_dhm_read_public(ctx: [*c]mbedtls_dhm_context, input: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_dhm_make_public(ctx: [*c]mbedtls_dhm_context, x_size: c_int, output: [*c]u8, olen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_dhm_calc_secret(ctx: [*c]mbedtls_dhm_context, output: [*c]u8, output_size: usize, olen: [*c]usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_dhm_get_bitlen(ctx: [*c]const mbedtls_dhm_context) usize;
pub extern fn mbedtls_dhm_get_len(ctx: [*c]const mbedtls_dhm_context) usize;
pub extern fn mbedtls_dhm_get_value(ctx: [*c]const mbedtls_dhm_context, param: mbedtls_dhm_parameter, dest: [*c]mbedtls_mpi) c_int;
pub extern fn mbedtls_dhm_free(ctx: [*c]mbedtls_dhm_context) void;
pub extern fn mbedtls_dhm_parse_dhm(dhm: [*c]mbedtls_dhm_context, dhmin: [*c]const u8, dhminlen: usize) c_int;
pub extern fn mbedtls_dhm_parse_dhmfile(dhm: [*c]mbedtls_dhm_context, path: [*c]const u8) c_int;
pub extern fn mbedtls_dhm_self_test(verbose: c_int) c_int;
pub const MBEDTLS_ECDH_OURS: c_int = 0;
pub const MBEDTLS_ECDH_THEIRS: c_int = 1;
pub const mbedtls_ecdh_side = c_uint;
pub const MBEDTLS_ECDH_VARIANT_NONE: c_int = 0;
pub const MBEDTLS_ECDH_VARIANT_MBEDTLS_2_0: c_int = 1;
pub const mbedtls_ecdh_variant = c_uint;
pub const struct_mbedtls_ecdh_context_mbed = extern struct {
    private_grp: mbedtls_ecp_group = @import("std").mem.zeroes(mbedtls_ecp_group),
    private_d: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_Q: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_Qp: mbedtls_ecp_point = @import("std").mem.zeroes(mbedtls_ecp_point),
    private_z: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
};
pub const mbedtls_ecdh_context_mbed = struct_mbedtls_ecdh_context_mbed;
const union_unnamed_25 = extern union {
    private_mbed_ecdh: mbedtls_ecdh_context_mbed,
};
pub const struct_mbedtls_ecdh_context = extern struct {
    private_point_format: u8 = 0,
    private_grp_id: mbedtls_ecp_group_id = @import("std").mem.zeroes(mbedtls_ecp_group_id),
    private_var: mbedtls_ecdh_variant = @import("std").mem.zeroes(mbedtls_ecdh_variant),
    private_ctx: union_unnamed_25 = @import("std").mem.zeroes(union_unnamed_25),
    pub const mbedtls_ecdh_get_grp_id = __root.mbedtls_ecdh_get_grp_id;
    pub const mbedtls_ecdh_init = __root.mbedtls_ecdh_init;
    pub const mbedtls_ecdh_setup = __root.mbedtls_ecdh_setup;
    pub const mbedtls_ecdh_free = __root.mbedtls_ecdh_free;
    pub const mbedtls_ecdh_make_params = __root.mbedtls_ecdh_make_params;
    pub const mbedtls_ecdh_read_params = __root.mbedtls_ecdh_read_params;
    pub const mbedtls_ecdh_get_params = __root.mbedtls_ecdh_get_params;
    pub const mbedtls_ecdh_make_public = __root.mbedtls_ecdh_make_public;
    pub const mbedtls_ecdh_read_public = __root.mbedtls_ecdh_read_public;
    pub const mbedtls_ecdh_calc_secret = __root.mbedtls_ecdh_calc_secret;
    pub const id = __root.mbedtls_ecdh_get_grp_id;
    pub const init = __root.mbedtls_ecdh_init;
    pub const setup = __root.mbedtls_ecdh_setup;
    pub const free = __root.mbedtls_ecdh_free;
    pub const params = __root.mbedtls_ecdh_make_params;
    pub const public = __root.mbedtls_ecdh_make_public;
    pub const secret = __root.mbedtls_ecdh_calc_secret;
};
pub const mbedtls_ecdh_context = struct_mbedtls_ecdh_context;
pub extern fn mbedtls_ecdh_get_grp_id(ctx: [*c]mbedtls_ecdh_context) mbedtls_ecp_group_id;
pub extern fn mbedtls_ecdh_can_do(gid: mbedtls_ecp_group_id) c_int;
pub extern fn mbedtls_ecdh_gen_public(grp: [*c]mbedtls_ecp_group, d: [*c]mbedtls_mpi, Q: [*c]mbedtls_ecp_point, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdh_compute_shared(grp: [*c]mbedtls_ecp_group, z: [*c]mbedtls_mpi, Q: [*c]const mbedtls_ecp_point, d: [*c]const mbedtls_mpi, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdh_init(ctx: [*c]mbedtls_ecdh_context) void;
pub extern fn mbedtls_ecdh_setup(ctx: [*c]mbedtls_ecdh_context, grp_id: mbedtls_ecp_group_id) c_int;
pub extern fn mbedtls_ecdh_free(ctx: [*c]mbedtls_ecdh_context) void;
pub extern fn mbedtls_ecdh_make_params(ctx: [*c]mbedtls_ecdh_context, olen: [*c]usize, buf: [*c]u8, blen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdh_read_params(ctx: [*c]mbedtls_ecdh_context, buf: [*c][*c]const u8, end: [*c]const u8) c_int;
pub extern fn mbedtls_ecdh_get_params(ctx: [*c]mbedtls_ecdh_context, key: [*c]const mbedtls_ecp_keypair, side: mbedtls_ecdh_side) c_int;
pub extern fn mbedtls_ecdh_make_public(ctx: [*c]mbedtls_ecdh_context, olen: [*c]usize, buf: [*c]u8, blen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub extern fn mbedtls_ecdh_read_public(ctx: [*c]mbedtls_ecdh_context, buf: [*c]const u8, blen: usize) c_int;
pub extern fn mbedtls_ecdh_calc_secret(ctx: [*c]mbedtls_ecdh_context, olen: [*c]usize, buf: [*c]u8, blen: usize, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) c_int;
pub const union_mbedtls_ssl_premaster_secret = extern union {
    dummy: u8,
    _pms_rsa: [48]u8,
    _pms_dhm: [1024]u8,
    _pms_ecdh: [66]u8,
    _pms_psk: [100]u8,
    _pms_dhe_psk: [1076]u8,
    _pms_rsa_psk: [100]u8,
    _pms_ecdhe_psk: [118]u8,
};
pub const MBEDTLS_SSL_HELLO_REQUEST: c_int = 0;
pub const MBEDTLS_SSL_CLIENT_HELLO: c_int = 1;
pub const MBEDTLS_SSL_SERVER_HELLO: c_int = 2;
pub const MBEDTLS_SSL_SERVER_CERTIFICATE: c_int = 3;
pub const MBEDTLS_SSL_SERVER_KEY_EXCHANGE: c_int = 4;
pub const MBEDTLS_SSL_CERTIFICATE_REQUEST: c_int = 5;
pub const MBEDTLS_SSL_SERVER_HELLO_DONE: c_int = 6;
pub const MBEDTLS_SSL_CLIENT_CERTIFICATE: c_int = 7;
pub const MBEDTLS_SSL_CLIENT_KEY_EXCHANGE: c_int = 8;
pub const MBEDTLS_SSL_CERTIFICATE_VERIFY: c_int = 9;
pub const MBEDTLS_SSL_CLIENT_CHANGE_CIPHER_SPEC: c_int = 10;
pub const MBEDTLS_SSL_CLIENT_FINISHED: c_int = 11;
pub const MBEDTLS_SSL_SERVER_CHANGE_CIPHER_SPEC: c_int = 12;
pub const MBEDTLS_SSL_SERVER_FINISHED: c_int = 13;
pub const MBEDTLS_SSL_FLUSH_BUFFERS: c_int = 14;
pub const MBEDTLS_SSL_HANDSHAKE_WRAPUP: c_int = 15;
pub const MBEDTLS_SSL_NEW_SESSION_TICKET: c_int = 16;
pub const MBEDTLS_SSL_SERVER_HELLO_VERIFY_REQUEST_SENT: c_int = 17;
pub const MBEDTLS_SSL_HELLO_RETRY_REQUEST: c_int = 18;
pub const MBEDTLS_SSL_ENCRYPTED_EXTENSIONS: c_int = 19;
pub const MBEDTLS_SSL_END_OF_EARLY_DATA: c_int = 20;
pub const MBEDTLS_SSL_CLIENT_CERTIFICATE_VERIFY: c_int = 21;
pub const MBEDTLS_SSL_CLIENT_CCS_AFTER_SERVER_FINISHED: c_int = 22;
pub const MBEDTLS_SSL_CLIENT_CCS_BEFORE_2ND_CLIENT_HELLO: c_int = 23;
pub const MBEDTLS_SSL_SERVER_CCS_AFTER_SERVER_HELLO: c_int = 24;
pub const MBEDTLS_SSL_CLIENT_CCS_AFTER_CLIENT_HELLO: c_int = 25;
pub const MBEDTLS_SSL_SERVER_CCS_AFTER_HELLO_RETRY_REQUEST: c_int = 26;
pub const MBEDTLS_SSL_HANDSHAKE_OVER: c_int = 27;
pub const MBEDTLS_SSL_TLS1_3_NEW_SESSION_TICKET: c_int = 28;
pub const MBEDTLS_SSL_TLS1_3_NEW_SESSION_TICKET_FLUSH: c_int = 29;
pub const mbedtls_ssl_states = c_uint;
pub const mbedtls_ssl_send_t = fn (ctx: ?*anyopaque, buf: [*c]const u8, len: usize) callconv(.c) c_int;
pub const mbedtls_ssl_recv_t = fn (ctx: ?*anyopaque, buf: [*c]u8, len: usize) callconv(.c) c_int;
pub const mbedtls_ssl_recv_timeout_t = fn (ctx: ?*anyopaque, buf: [*c]u8, len: usize, timeout: u32) callconv(.c) c_int;
pub const mbedtls_ssl_set_timer_t = fn (ctx: ?*anyopaque, int_ms: u32, fin_ms: u32) callconv(.c) void;
pub const mbedtls_ssl_get_timer_t = fn (ctx: ?*anyopaque) callconv(.c) c_int;
pub const MBEDTLS_SSL_VERSION_UNKNOWN: c_int = 0;
pub const MBEDTLS_SSL_VERSION_TLS1_2: c_int = 771;
pub const MBEDTLS_SSL_VERSION_TLS1_3: c_int = 772;
pub const mbedtls_ssl_protocol_version = c_uint;
pub const mbedtls_ssl_tls13_application_secrets = extern struct {
    client_application_traffic_secret_N: [64]u8 = @import("std").mem.zeroes([64]u8),
    server_application_traffic_secret_N: [64]u8 = @import("std").mem.zeroes([64]u8),
    exporter_master_secret: [64]u8 = @import("std").mem.zeroes([64]u8),
    resumption_master_secret: [64]u8 = @import("std").mem.zeroes([64]u8),
};
pub const struct_mbedtls_ssl_session = extern struct {
    private_mfl_code: u8 = 0,
    private_exported: u8 = 0,
    private_endpoint: u8 = 0,
    private_tls_version: mbedtls_ssl_protocol_version = @import("std").mem.zeroes(mbedtls_ssl_protocol_version),
    private_start: mbedtls_time_t = 0,
    private_ciphersuite: c_int = 0,
    private_id_len: usize = 0,
    private_id: [32]u8 = @import("std").mem.zeroes([32]u8),
    private_master: [48]u8 = @import("std").mem.zeroes([48]u8),
    private_peer_cert: [*c]mbedtls_x509_crt = null,
    private_verify_result: u32 = 0,
    private_ticket: [*c]u8 = null,
    private_ticket_len: usize = 0,
    private_ticket_lifetime: u32 = 0,
    private_ticket_creation_time: mbedtls_ms_time_t = 0,
    private_ticket_age_add: u32 = 0,
    private_ticket_flags: u8 = 0,
    private_resumption_key_len: u8 = 0,
    private_resumption_key: [48]u8 = @import("std").mem.zeroes([48]u8),
    private_hostname: [*c]u8 = null,
    private_ticket_reception_time: mbedtls_ms_time_t = 0,
    private_encrypt_then_mac: c_int = 0,
    private_app_secrets: mbedtls_ssl_tls13_application_secrets = @import("std").mem.zeroes(mbedtls_ssl_tls13_application_secrets),
    pub const mbedtls_ssl_session_get_ticket_creation_time = __root.mbedtls_ssl_session_get_ticket_creation_time;
    pub const mbedtls_ssl_session_get_id = __root.mbedtls_ssl_session_get_id;
    pub const mbedtls_ssl_session_get_id_len = __root.mbedtls_ssl_session_get_id_len;
    pub const mbedtls_ssl_session_get_ciphersuite_id = __root.mbedtls_ssl_session_get_ciphersuite_id;
    pub const mbedtls_ssl_session_load = __root.mbedtls_ssl_session_load;
    pub const mbedtls_ssl_session_save = __root.mbedtls_ssl_session_save;
    pub const mbedtls_ssl_session_init = __root.mbedtls_ssl_session_init;
    pub const mbedtls_ssl_session_free = __root.mbedtls_ssl_session_free;
    pub const time = __root.mbedtls_ssl_session_get_ticket_creation_time;
    pub const id = __root.mbedtls_ssl_session_get_id;
    pub const len = __root.mbedtls_ssl_session_get_id_len;
    pub const load = __root.mbedtls_ssl_session_load;
    pub const save = __root.mbedtls_ssl_session_save;
    pub const init = __root.mbedtls_ssl_session_init;
    pub const free = __root.mbedtls_ssl_session_free;
};
pub const mbedtls_ssl_session = struct_mbedtls_ssl_session;
pub const mbedtls_ssl_cache_get_t = fn (data: ?*anyopaque, session_id: [*c]const u8, session_id_len: usize, session: [*c]mbedtls_ssl_session) callconv(.c) c_int;
pub const mbedtls_ssl_cache_set_t = fn (data: ?*anyopaque, session_id: [*c]const u8, session_id_len: usize, session: [*c]const mbedtls_ssl_session) callconv(.c) c_int;
pub const struct_mbedtls_ssl_key_cert = opaque {};
pub const mbedtls_ssl_key_cert = struct_mbedtls_ssl_key_cert;
pub const mbedtls_ssl_user_data_t = extern union {
    n: usize,
    p: ?*anyopaque,
};
pub const mbedtls_ssl_hs_cb_t = ?*const fn (ssl: [*c]mbedtls_ssl_context) callconv(.c) c_int;
pub const struct_mbedtls_ssl_config = extern struct {
    private_max_tls_version: mbedtls_ssl_protocol_version = @import("std").mem.zeroes(mbedtls_ssl_protocol_version),
    private_min_tls_version: mbedtls_ssl_protocol_version = @import("std").mem.zeroes(mbedtls_ssl_protocol_version),
    private_endpoint: u8 = 0,
    private_transport: u8 = 0,
    private_authmode: u8 = 0,
    private_allow_legacy_renegotiation: u8 = 0,
    private_mfl_code: u8 = 0,
    private_encrypt_then_mac: u8 = 0,
    private_extended_ms: u8 = 0,
    private_anti_replay: u8 = 0,
    private_disable_renegotiation: u8 = 0,
    private_session_tickets: u8 = 0,
    private_new_session_tickets_count: u16 = 0,
    private_cert_req_ca_list: u8 = 0,
    private_respect_cli_pref: u8 = 0,
    private_ignore_unexpected_cid: u8 = 0,
    private_ciphersuite_list: [*c]const c_int = null,
    private_tls13_kex_modes: c_int = 0,
    private_f_dbg: ?*const fn (?*anyopaque, c_int, [*c]const u8, c_int, [*c]const u8) callconv(.c) void = null,
    private_p_dbg: ?*anyopaque = null,
    private_f_rng: ?*const fn (?*anyopaque, [*c]u8, usize) callconv(.c) c_int = null,
    private_p_rng: ?*anyopaque = null,
    private_f_get_cache: ?*const mbedtls_ssl_cache_get_t = null,
    private_f_set_cache: ?*const mbedtls_ssl_cache_set_t = null,
    private_p_cache: ?*anyopaque = null,
    private_f_sni: ?*const fn (?*anyopaque, [*c]mbedtls_ssl_context, [*c]const u8, usize) callconv(.c) c_int = null,
    private_p_sni: ?*anyopaque = null,
    private_f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int = null,
    private_p_vrfy: ?*anyopaque = null,
    private_f_psk: ?*const fn (?*anyopaque, [*c]mbedtls_ssl_context, [*c]const u8, usize) callconv(.c) c_int = null,
    private_p_psk: ?*anyopaque = null,
    private_f_cookie_write: ?*const fn (?*anyopaque, [*c][*c]u8, [*c]u8, [*c]const u8, usize) callconv(.c) c_int = null,
    private_f_cookie_check: ?*const fn (?*anyopaque, [*c]const u8, usize, [*c]const u8, usize) callconv(.c) c_int = null,
    private_p_cookie: ?*anyopaque = null,
    private_f_ticket_write: ?*const fn (?*anyopaque, [*c]const mbedtls_ssl_session, [*c]u8, [*c]const u8, [*c]usize, [*c]u32) callconv(.c) c_int = null,
    private_f_ticket_parse: ?*const fn (?*anyopaque, [*c]mbedtls_ssl_session, [*c]u8, usize) callconv(.c) c_int = null,
    private_p_ticket: ?*anyopaque = null,
    private_cid_len: usize = 0,
    private_cert_profile: [*c]const mbedtls_x509_crt_profile = null,
    private_key_cert: ?*mbedtls_ssl_key_cert = null,
    private_ca_chain: [*c]mbedtls_x509_crt = null,
    private_ca_crl: [*c]mbedtls_x509_crl = null,
    private_sig_hashes: [*c]const c_int = null,
    private_sig_algs: [*c]const u16 = null,
    private_curve_list: [*c]const mbedtls_ecp_group_id = null,
    private_group_list: [*c]const u16 = null,
    private_dhm_P: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_dhm_G: mbedtls_mpi = @import("std").mem.zeroes(mbedtls_mpi),
    private_psk: [*c]u8 = null,
    private_psk_len: usize = 0,
    private_psk_identity: [*c]u8 = null,
    private_psk_identity_len: usize = 0,
    private_alpn_list: [*c][*c]const u8 = null,
    private_read_timeout: u32 = 0,
    private_hs_timeout_min: u32 = 0,
    private_hs_timeout_max: u32 = 0,
    private_renego_max_records: c_int = 0,
    private_renego_period: [8]u8 = @import("std").mem.zeroes([8]u8),
    private_badmac_limit: c_uint = 0,
    private_dhm_min_bitlen: c_uint = 0,
    private_user_data: mbedtls_ssl_user_data_t = @import("std").mem.zeroes(mbedtls_ssl_user_data_t),
    private_f_cert_cb: mbedtls_ssl_hs_cb_t = null,
    private_dn_hints: [*c]const mbedtls_x509_crt = null,
    pub const mbedtls_ssl_conf_endpoint = __root.mbedtls_ssl_conf_endpoint;
    pub const mbedtls_ssl_conf_get_endpoint = __root.mbedtls_ssl_conf_get_endpoint;
    pub const mbedtls_ssl_conf_transport = __root.mbedtls_ssl_conf_transport;
    pub const mbedtls_ssl_conf_authmode = __root.mbedtls_ssl_conf_authmode;
    pub const mbedtls_ssl_conf_verify = __root.mbedtls_ssl_conf_verify;
    pub const mbedtls_ssl_conf_rng = __root.mbedtls_ssl_conf_rng;
    pub const mbedtls_ssl_conf_dbg = __root.mbedtls_ssl_conf_dbg;
    pub const mbedtls_ssl_conf_read_timeout = __root.mbedtls_ssl_conf_read_timeout;
    pub const mbedtls_ssl_conf_cert_cb = __root.mbedtls_ssl_conf_cert_cb;
    pub const mbedtls_ssl_conf_session_tickets_cb = __root.mbedtls_ssl_conf_session_tickets_cb;
    pub const mbedtls_ssl_conf_set_user_data_p = __root.mbedtls_ssl_conf_set_user_data_p;
    pub const mbedtls_ssl_conf_set_user_data_n = __root.mbedtls_ssl_conf_set_user_data_n;
    pub const mbedtls_ssl_conf_get_user_data_p = __root.mbedtls_ssl_conf_get_user_data_p;
    pub const mbedtls_ssl_conf_get_user_data_n = __root.mbedtls_ssl_conf_get_user_data_n;
    pub const mbedtls_ssl_conf_dtls_cookies = __root.mbedtls_ssl_conf_dtls_cookies;
    pub const mbedtls_ssl_conf_dtls_anti_replay = __root.mbedtls_ssl_conf_dtls_anti_replay;
    pub const mbedtls_ssl_conf_dtls_badmac_limit = __root.mbedtls_ssl_conf_dtls_badmac_limit;
    pub const mbedtls_ssl_conf_handshake_timeout = __root.mbedtls_ssl_conf_handshake_timeout;
    pub const mbedtls_ssl_conf_session_cache = __root.mbedtls_ssl_conf_session_cache;
    pub const mbedtls_ssl_conf_ciphersuites = __root.mbedtls_ssl_conf_ciphersuites;
    pub const mbedtls_ssl_conf_tls13_key_exchange_modes = __root.mbedtls_ssl_conf_tls13_key_exchange_modes;
    pub const mbedtls_ssl_conf_cid = __root.mbedtls_ssl_conf_cid;
    pub const mbedtls_ssl_conf_cert_profile = __root.mbedtls_ssl_conf_cert_profile;
    pub const mbedtls_ssl_conf_ca_chain = __root.mbedtls_ssl_conf_ca_chain;
    pub const mbedtls_ssl_conf_dn_hints = __root.mbedtls_ssl_conf_dn_hints;
    pub const mbedtls_ssl_conf_own_cert = __root.mbedtls_ssl_conf_own_cert;
    pub const mbedtls_ssl_conf_psk = __root.mbedtls_ssl_conf_psk;
    pub const mbedtls_ssl_conf_psk_cb = __root.mbedtls_ssl_conf_psk_cb;
    pub const mbedtls_ssl_conf_dh_param_bin = __root.mbedtls_ssl_conf_dh_param_bin;
    pub const mbedtls_ssl_conf_dh_param_ctx = __root.mbedtls_ssl_conf_dh_param_ctx;
    pub const mbedtls_ssl_conf_dhm_min_bitlen = __root.mbedtls_ssl_conf_dhm_min_bitlen;
    pub const mbedtls_ssl_conf_curves = __root.mbedtls_ssl_conf_curves;
    pub const mbedtls_ssl_conf_groups = __root.mbedtls_ssl_conf_groups;
    pub const mbedtls_ssl_conf_sig_hashes = __root.mbedtls_ssl_conf_sig_hashes;
    pub const mbedtls_ssl_conf_sig_algs = __root.mbedtls_ssl_conf_sig_algs;
    pub const mbedtls_ssl_conf_sni = __root.mbedtls_ssl_conf_sni;
    pub const mbedtls_ssl_conf_alpn_protocols = __root.mbedtls_ssl_conf_alpn_protocols;
    pub const mbedtls_ssl_conf_max_version = __root.mbedtls_ssl_conf_max_version;
    pub const mbedtls_ssl_conf_max_tls_version = __root.mbedtls_ssl_conf_max_tls_version;
    pub const mbedtls_ssl_conf_min_version = __root.mbedtls_ssl_conf_min_version;
    pub const mbedtls_ssl_conf_min_tls_version = __root.mbedtls_ssl_conf_min_tls_version;
    pub const mbedtls_ssl_conf_encrypt_then_mac = __root.mbedtls_ssl_conf_encrypt_then_mac;
    pub const mbedtls_ssl_conf_extended_master_secret = __root.mbedtls_ssl_conf_extended_master_secret;
    pub const mbedtls_ssl_conf_cert_req_ca_list = __root.mbedtls_ssl_conf_cert_req_ca_list;
    pub const mbedtls_ssl_conf_max_frag_len = __root.mbedtls_ssl_conf_max_frag_len;
    pub const mbedtls_ssl_conf_preference_order = __root.mbedtls_ssl_conf_preference_order;
    pub const mbedtls_ssl_conf_session_tickets = __root.mbedtls_ssl_conf_session_tickets;
    pub const mbedtls_ssl_conf_tls13_enable_signal_new_session_tickets = __root.mbedtls_ssl_conf_tls13_enable_signal_new_session_tickets;
    pub const mbedtls_ssl_conf_new_session_tickets = __root.mbedtls_ssl_conf_new_session_tickets;
    pub const mbedtls_ssl_conf_renegotiation = __root.mbedtls_ssl_conf_renegotiation;
    pub const mbedtls_ssl_conf_legacy_renegotiation = __root.mbedtls_ssl_conf_legacy_renegotiation;
    pub const mbedtls_ssl_conf_renegotiation_enforced = __root.mbedtls_ssl_conf_renegotiation_enforced;
    pub const mbedtls_ssl_conf_renegotiation_period = __root.mbedtls_ssl_conf_renegotiation_period;
    pub const mbedtls_ssl_config_init = __root.mbedtls_ssl_config_init;
    pub const mbedtls_ssl_config_defaults = __root.mbedtls_ssl_config_defaults;
    pub const mbedtls_ssl_config_free = __root.mbedtls_ssl_config_free;
    pub const endpoint = __root.mbedtls_ssl_conf_endpoint;
    pub const transport = __root.mbedtls_ssl_conf_transport;
    pub const authmode = __root.mbedtls_ssl_conf_authmode;
    pub const verify = __root.mbedtls_ssl_conf_verify;
    pub const rng = __root.mbedtls_ssl_conf_rng;
    pub const dbg = __root.mbedtls_ssl_conf_dbg;
    pub const timeout = __root.mbedtls_ssl_conf_read_timeout;
    pub const cb = __root.mbedtls_ssl_conf_cert_cb;
    pub const p = __root.mbedtls_ssl_conf_set_user_data_p;
    pub const n = __root.mbedtls_ssl_conf_set_user_data_n;
    pub const cookies = __root.mbedtls_ssl_conf_dtls_cookies;
    pub const replay = __root.mbedtls_ssl_conf_dtls_anti_replay;
    pub const limit = __root.mbedtls_ssl_conf_dtls_badmac_limit;
    pub const cache = __root.mbedtls_ssl_conf_session_cache;
    pub const ciphersuites = __root.mbedtls_ssl_conf_ciphersuites;
    pub const modes = __root.mbedtls_ssl_conf_tls13_key_exchange_modes;
    pub const cid = __root.mbedtls_ssl_conf_cid;
    pub const profile = __root.mbedtls_ssl_conf_cert_profile;
    pub const chain = __root.mbedtls_ssl_conf_ca_chain;
    pub const hints = __root.mbedtls_ssl_conf_dn_hints;
    pub const cert = __root.mbedtls_ssl_conf_own_cert;
    pub const psk = __root.mbedtls_ssl_conf_psk;
    pub const bin = __root.mbedtls_ssl_conf_dh_param_bin;
    pub const ctx = __root.mbedtls_ssl_conf_dh_param_ctx;
    pub const bitlen = __root.mbedtls_ssl_conf_dhm_min_bitlen;
    pub const curves = __root.mbedtls_ssl_conf_curves;
    pub const groups = __root.mbedtls_ssl_conf_groups;
    pub const hashes = __root.mbedtls_ssl_conf_sig_hashes;
    pub const algs = __root.mbedtls_ssl_conf_sig_algs;
    pub const sni = __root.mbedtls_ssl_conf_sni;
    pub const protocols = __root.mbedtls_ssl_conf_alpn_protocols;
    pub const version = __root.mbedtls_ssl_conf_max_version;
    pub const mac = __root.mbedtls_ssl_conf_encrypt_then_mac;
    pub const secret = __root.mbedtls_ssl_conf_extended_master_secret;
    pub const list = __root.mbedtls_ssl_conf_cert_req_ca_list;
    pub const len = __root.mbedtls_ssl_conf_max_frag_len;
    pub const order = __root.mbedtls_ssl_conf_preference_order;
    pub const tickets = __root.mbedtls_ssl_conf_session_tickets;
    pub const renegotiation = __root.mbedtls_ssl_conf_renegotiation;
    pub const enforced = __root.mbedtls_ssl_conf_renegotiation_enforced;
    pub const period = __root.mbedtls_ssl_conf_renegotiation_period;
    pub const init = __root.mbedtls_ssl_config_init;
    pub const defaults = __root.mbedtls_ssl_config_defaults;
    pub const free = __root.mbedtls_ssl_config_free;
};
pub const mbedtls_ssl_config = struct_mbedtls_ssl_config;
pub const struct_mbedtls_ssl_handshake_params = opaque {};
pub const mbedtls_ssl_handshake_params = struct_mbedtls_ssl_handshake_params;
pub const struct_mbedtls_ssl_transform = opaque {};
pub const mbedtls_ssl_transform = struct_mbedtls_ssl_transform;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS12_MASTER_SECRET: c_int = 0;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS1_3_CLIENT_EARLY_SECRET: c_int = 1;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS1_3_EARLY_EXPORTER_SECRET: c_int = 2;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS1_3_CLIENT_HANDSHAKE_TRAFFIC_SECRET: c_int = 3;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS1_3_SERVER_HANDSHAKE_TRAFFIC_SECRET: c_int = 4;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS1_3_CLIENT_APPLICATION_TRAFFIC_SECRET: c_int = 5;
pub const MBEDTLS_SSL_KEY_EXPORT_TLS1_3_SERVER_APPLICATION_TRAFFIC_SECRET: c_int = 6;
pub const mbedtls_ssl_key_export_type = c_uint;
pub const MBEDTLS_SSL_TLS_PRF_NONE: c_int = 0;
pub const MBEDTLS_SSL_TLS_PRF_SHA384: c_int = 1;
pub const MBEDTLS_SSL_TLS_PRF_SHA256: c_int = 2;
pub const MBEDTLS_SSL_HKDF_EXPAND_SHA384: c_int = 3;
pub const MBEDTLS_SSL_HKDF_EXPAND_SHA256: c_int = 4;
pub const mbedtls_tls_prf_types = c_uint;
pub const mbedtls_ssl_export_keys_t = fn (p_expkey: ?*anyopaque, @"type": mbedtls_ssl_key_export_type, secret: [*c]const u8, secret_len: usize, client_random: [*c]const u8, server_random: [*c]const u8, tls_prf_type: mbedtls_tls_prf_types) callconv(.c) void;
pub const struct_mbedtls_ssl_context = extern struct {
    private_conf: [*c]const mbedtls_ssl_config = null,
    private_state: c_int = 0,
    private_renego_status: c_int = 0,
    private_renego_records_seen: c_int = 0,
    private_tls_version: mbedtls_ssl_protocol_version = @import("std").mem.zeroes(mbedtls_ssl_protocol_version),
    private_badmac_seen_or_in_hsfraglen: c_uint = 0,
    private_f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int = null,
    private_p_vrfy: ?*anyopaque = null,
    private_f_send: ?*const mbedtls_ssl_send_t = null,
    private_f_recv: ?*const mbedtls_ssl_recv_t = null,
    private_f_recv_timeout: ?*const mbedtls_ssl_recv_timeout_t = null,
    private_p_bio: ?*anyopaque = null,
    private_session_in: [*c]mbedtls_ssl_session = null,
    private_session_out: [*c]mbedtls_ssl_session = null,
    private_session: [*c]mbedtls_ssl_session = null,
    private_session_negotiate: [*c]mbedtls_ssl_session = null,
    private_handshake: ?*mbedtls_ssl_handshake_params = null,
    private_transform_in: ?*mbedtls_ssl_transform = null,
    private_transform_out: ?*mbedtls_ssl_transform = null,
    private_transform: ?*mbedtls_ssl_transform = null,
    private_transform_negotiate: ?*mbedtls_ssl_transform = null,
    private_transform_application: ?*mbedtls_ssl_transform = null,
    private_p_timer: ?*anyopaque = null,
    private_f_set_timer: ?*const mbedtls_ssl_set_timer_t = null,
    private_f_get_timer: ?*const mbedtls_ssl_get_timer_t = null,
    private_in_buf: [*c]u8 = null,
    private_in_ctr: [*c]u8 = null,
    private_in_hdr: [*c]u8 = null,
    private_in_cid: [*c]u8 = null,
    private_in_len: [*c]u8 = null,
    private_in_iv: [*c]u8 = null,
    private_in_msg: [*c]u8 = null,
    private_in_offt: [*c]u8 = null,
    private_in_msgtype: c_int = 0,
    private_in_msglen: usize = 0,
    private_in_left: usize = 0,
    private_in_epoch: u16 = 0,
    private_next_record_offset: usize = 0,
    private_in_window_top: u64 = 0,
    private_in_window: u64 = 0,
    private_in_hslen: usize = 0,
    private_nb_zero: c_int = 0,
    private_keep_current_message: c_int = 0,
    private_send_alert: u8 = 0,
    private_alert_type: u8 = 0,
    private_alert_reason: c_int = 0,
    private_disable_datagram_packing: u8 = 0,
    private_out_buf: [*c]u8 = null,
    private_out_ctr: [*c]u8 = null,
    private_out_hdr: [*c]u8 = null,
    private_out_cid: [*c]u8 = null,
    private_out_len: [*c]u8 = null,
    private_out_iv: [*c]u8 = null,
    private_out_msg: [*c]u8 = null,
    private_out_msgtype: c_int = 0,
    private_out_msglen: usize = 0,
    private_out_left: usize = 0,
    private_cur_out_ctr: [8]u8 = @import("std").mem.zeroes([8]u8),
    private_mtu: u16 = 0,
    private_hostname: [*c]u8 = null,
    private_alpn_chosen: [*c]const u8 = null,
    private_cli_id: [*c]u8 = null,
    private_cli_id_len: usize = 0,
    private_secure_renegotiation: c_int = 0,
    private_verify_data_len: usize = 0,
    private_own_verify_data: [12]u8 = @import("std").mem.zeroes([12]u8),
    private_peer_verify_data: [12]u8 = @import("std").mem.zeroes([12]u8),
    private_own_cid: [32]u8 = @import("std").mem.zeroes([32]u8),
    private_own_cid_len: u8 = 0,
    private_negotiate_cid: u8 = 0,
    private_f_export_keys: ?*const mbedtls_ssl_export_keys_t = null,
    private_p_export_keys: ?*anyopaque = null,
    private_user_data: mbedtls_ssl_user_data_t = @import("std").mem.zeroes(mbedtls_ssl_user_data_t),
    pub const mbedtls_ssl_init = __root.mbedtls_ssl_init;
    pub const mbedtls_ssl_setup = __root.mbedtls_ssl_setup;
    pub const mbedtls_ssl_session_reset = __root.mbedtls_ssl_session_reset;
    pub const mbedtls_ssl_context_get_config = __root.mbedtls_ssl_context_get_config;
    pub const mbedtls_ssl_set_bio = __root.mbedtls_ssl_set_bio;
    pub const mbedtls_ssl_set_cid = __root.mbedtls_ssl_set_cid;
    pub const mbedtls_ssl_get_own_cid = __root.mbedtls_ssl_get_own_cid;
    pub const mbedtls_ssl_get_peer_cid = __root.mbedtls_ssl_get_peer_cid;
    pub const mbedtls_ssl_set_mtu = __root.mbedtls_ssl_set_mtu;
    pub const mbedtls_ssl_set_verify = __root.mbedtls_ssl_set_verify;
    pub const mbedtls_ssl_check_record = __root.mbedtls_ssl_check_record;
    pub const mbedtls_ssl_set_timer_cb = __root.mbedtls_ssl_set_timer_cb;
    pub const mbedtls_ssl_set_export_keys_cb = __root.mbedtls_ssl_set_export_keys_cb;
    pub const mbedtls_ssl_set_user_data_p = __root.mbedtls_ssl_set_user_data_p;
    pub const mbedtls_ssl_set_user_data_n = __root.mbedtls_ssl_set_user_data_n;
    pub const mbedtls_ssl_get_user_data_p = __root.mbedtls_ssl_get_user_data_p;
    pub const mbedtls_ssl_get_user_data_n = __root.mbedtls_ssl_get_user_data_n;
    pub const mbedtls_ssl_set_client_transport_id = __root.mbedtls_ssl_set_client_transport_id;
    pub const mbedtls_ssl_set_datagram_packing = __root.mbedtls_ssl_set_datagram_packing;
    pub const mbedtls_ssl_set_session = __root.mbedtls_ssl_set_session;
    pub const mbedtls_ssl_set_hs_psk = __root.mbedtls_ssl_set_hs_psk;
    pub const mbedtls_ssl_set_hostname = __root.mbedtls_ssl_set_hostname;
    pub const mbedtls_ssl_get_hostname = __root.mbedtls_ssl_get_hostname;
    pub const mbedtls_ssl_get_hs_sni = __root.mbedtls_ssl_get_hs_sni;
    pub const mbedtls_ssl_set_hs_own_cert = __root.mbedtls_ssl_set_hs_own_cert;
    pub const mbedtls_ssl_set_hs_ca_chain = __root.mbedtls_ssl_set_hs_ca_chain;
    pub const mbedtls_ssl_set_hs_dn_hints = __root.mbedtls_ssl_set_hs_dn_hints;
    pub const mbedtls_ssl_set_hs_authmode = __root.mbedtls_ssl_set_hs_authmode;
    pub const mbedtls_ssl_get_alpn_protocol = __root.mbedtls_ssl_get_alpn_protocol;
    pub const mbedtls_ssl_check_pending = __root.mbedtls_ssl_check_pending;
    pub const mbedtls_ssl_get_bytes_avail = __root.mbedtls_ssl_get_bytes_avail;
    pub const mbedtls_ssl_get_verify_result = __root.mbedtls_ssl_get_verify_result;
    pub const mbedtls_ssl_get_ciphersuite_id_from_ssl = __root.mbedtls_ssl_get_ciphersuite_id_from_ssl;
    pub const mbedtls_ssl_get_ciphersuite = __root.mbedtls_ssl_get_ciphersuite;
    pub const mbedtls_ssl_get_version_number = __root.mbedtls_ssl_get_version_number;
    pub const mbedtls_ssl_get_version = __root.mbedtls_ssl_get_version;
    pub const mbedtls_ssl_get_record_expansion = __root.mbedtls_ssl_get_record_expansion;
    pub const mbedtls_ssl_get_max_out_record_payload = __root.mbedtls_ssl_get_max_out_record_payload;
    pub const mbedtls_ssl_get_max_in_record_payload = __root.mbedtls_ssl_get_max_in_record_payload;
    pub const mbedtls_ssl_get_peer_cert = __root.mbedtls_ssl_get_peer_cert;
    pub const mbedtls_ssl_get_session = __root.mbedtls_ssl_get_session;
    pub const mbedtls_ssl_handshake = __root.mbedtls_ssl_handshake;
    pub const mbedtls_ssl_is_handshake_over = __root.mbedtls_ssl_is_handshake_over;
    pub const mbedtls_ssl_handshake_step = __root.mbedtls_ssl_handshake_step;
    pub const mbedtls_ssl_renegotiate = __root.mbedtls_ssl_renegotiate;
    pub const mbedtls_ssl_read = __root.mbedtls_ssl_read;
    pub const mbedtls_ssl_write = __root.mbedtls_ssl_write;
    pub const mbedtls_ssl_send_alert_message = __root.mbedtls_ssl_send_alert_message;
    pub const mbedtls_ssl_close_notify = __root.mbedtls_ssl_close_notify;
    pub const mbedtls_ssl_free = __root.mbedtls_ssl_free;
    pub const mbedtls_ssl_context_save = __root.mbedtls_ssl_context_save;
    pub const mbedtls_ssl_context_load = __root.mbedtls_ssl_context_load;
    pub const mbedtls_ssl_export_keying_material = __root.mbedtls_ssl_export_keying_material;
    pub const init = __root.mbedtls_ssl_init;
    pub const setup = __root.mbedtls_ssl_setup;
    pub const reset = __root.mbedtls_ssl_session_reset;
    pub const config = __root.mbedtls_ssl_context_get_config;
    pub const bio = __root.mbedtls_ssl_set_bio;
    pub const cid = __root.mbedtls_ssl_set_cid;
    pub const mtu = __root.mbedtls_ssl_set_mtu;
    pub const verify = __root.mbedtls_ssl_set_verify;
    pub const record = __root.mbedtls_ssl_check_record;
    pub const cb = __root.mbedtls_ssl_set_timer_cb;
    pub const p = __root.mbedtls_ssl_set_user_data_p;
    pub const n = __root.mbedtls_ssl_set_user_data_n;
    pub const id = __root.mbedtls_ssl_set_client_transport_id;
    pub const packing = __root.mbedtls_ssl_set_datagram_packing;
    pub const session = __root.mbedtls_ssl_set_session;
    pub const psk = __root.mbedtls_ssl_set_hs_psk;
    pub const hostname = __root.mbedtls_ssl_set_hostname;
    pub const sni = __root.mbedtls_ssl_get_hs_sni;
    pub const cert = __root.mbedtls_ssl_set_hs_own_cert;
    pub const chain = __root.mbedtls_ssl_set_hs_ca_chain;
    pub const hints = __root.mbedtls_ssl_set_hs_dn_hints;
    pub const authmode = __root.mbedtls_ssl_set_hs_authmode;
    pub const protocol = __root.mbedtls_ssl_get_alpn_protocol;
    pub const pending = __root.mbedtls_ssl_check_pending;
    pub const avail = __root.mbedtls_ssl_get_bytes_avail;
    pub const result = __root.mbedtls_ssl_get_verify_result;
    pub const ssl = __root.mbedtls_ssl_get_ciphersuite_id_from_ssl;
    pub const ciphersuite = __root.mbedtls_ssl_get_ciphersuite;
    pub const number = __root.mbedtls_ssl_get_version_number;
    pub const version = __root.mbedtls_ssl_get_version;
    pub const expansion = __root.mbedtls_ssl_get_record_expansion;
    pub const payload = __root.mbedtls_ssl_get_max_out_record_payload;
    pub const handshake = __root.mbedtls_ssl_handshake;
    pub const over = __root.mbedtls_ssl_is_handshake_over;
    pub const step = __root.mbedtls_ssl_handshake_step;
    pub const renegotiate = __root.mbedtls_ssl_renegotiate;
    pub const read = __root.mbedtls_ssl_read;
    pub const write = __root.mbedtls_ssl_write;
    pub const message = __root.mbedtls_ssl_send_alert_message;
    pub const notify = __root.mbedtls_ssl_close_notify;
    pub const free = __root.mbedtls_ssl_free;
    pub const save = __root.mbedtls_ssl_context_save;
    pub const load = __root.mbedtls_ssl_context_load;
    pub const material = __root.mbedtls_ssl_export_keying_material;
};
pub const mbedtls_ssl_context = struct_mbedtls_ssl_context;
pub const struct_mbedtls_ssl_sig_hash_set_t = opaque {};
pub const mbedtls_ssl_sig_hash_set_t = struct_mbedtls_ssl_sig_hash_set_t;
pub const struct_mbedtls_ssl_flight_item = opaque {};
pub const mbedtls_ssl_flight_item = struct_mbedtls_ssl_flight_item;
pub extern fn mbedtls_ssl_get_ciphersuite_name(ciphersuite_id: c_int) [*c]const u8;
pub extern fn mbedtls_ssl_get_ciphersuite_id(ciphersuite_name: [*c]const u8) c_int;
pub extern fn mbedtls_ssl_init(ssl: [*c]mbedtls_ssl_context) void;
pub extern fn mbedtls_ssl_setup(ssl: [*c]mbedtls_ssl_context, conf: [*c]const mbedtls_ssl_config) c_int;
pub extern fn mbedtls_ssl_session_reset(ssl: [*c]mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_conf_endpoint(conf: [*c]mbedtls_ssl_config, endpoint: c_int) void;
pub fn mbedtls_ssl_conf_get_endpoint(arg_conf: [*c]const mbedtls_ssl_config) callconv(.c) c_int {
    var conf = arg_conf;
    _ = &conf;
    return conf.*.private_endpoint;
}
pub extern fn mbedtls_ssl_conf_transport(conf: [*c]mbedtls_ssl_config, transport: c_int) void;
pub extern fn mbedtls_ssl_conf_authmode(conf: [*c]mbedtls_ssl_config, authmode: c_int) void;
pub extern fn mbedtls_ssl_conf_verify(conf: [*c]mbedtls_ssl_config, f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int, p_vrfy: ?*anyopaque) void;
pub extern fn mbedtls_ssl_conf_rng(conf: [*c]mbedtls_ssl_config, f_rng: ?*const mbedtls_f_rng_t, p_rng: ?*anyopaque) void;
pub extern fn mbedtls_ssl_conf_dbg(conf: [*c]mbedtls_ssl_config, f_dbg: ?*const fn (?*anyopaque, c_int, [*c]const u8, c_int, [*c]const u8) callconv(.c) void, p_dbg: ?*anyopaque) void;
pub fn mbedtls_ssl_context_get_config(arg_ssl: [*c]const mbedtls_ssl_context) callconv(.c) [*c]const mbedtls_ssl_config {
    var ssl = arg_ssl;
    _ = &ssl;
    return ssl.*.private_conf;
}
pub extern fn mbedtls_ssl_set_bio(ssl: [*c]mbedtls_ssl_context, p_bio: ?*anyopaque, f_send: ?*const mbedtls_ssl_send_t, f_recv: ?*const mbedtls_ssl_recv_t, f_recv_timeout: ?*const mbedtls_ssl_recv_timeout_t) void;
pub extern fn mbedtls_ssl_set_cid(ssl: [*c]mbedtls_ssl_context, enable: c_int, own_cid: [*c]const u8, own_cid_len: usize) c_int;
pub extern fn mbedtls_ssl_get_own_cid(ssl: [*c]mbedtls_ssl_context, enabled: [*c]c_int, own_cid: [*c]u8, own_cid_len: [*c]usize) c_int;
pub extern fn mbedtls_ssl_get_peer_cid(ssl: [*c]mbedtls_ssl_context, enabled: [*c]c_int, peer_cid: [*c]u8, peer_cid_len: [*c]usize) c_int;
pub extern fn mbedtls_ssl_set_mtu(ssl: [*c]mbedtls_ssl_context, mtu: u16) void;
pub extern fn mbedtls_ssl_set_verify(ssl: [*c]mbedtls_ssl_context, f_vrfy: ?*const fn (?*anyopaque, [*c]mbedtls_x509_crt, c_int, [*c]u32) callconv(.c) c_int, p_vrfy: ?*anyopaque) void;
pub extern fn mbedtls_ssl_conf_read_timeout(conf: [*c]mbedtls_ssl_config, timeout: u32) void;
pub extern fn mbedtls_ssl_check_record(ssl: [*c]const mbedtls_ssl_context, buf: [*c]u8, buflen: usize) c_int;
pub extern fn mbedtls_ssl_set_timer_cb(ssl: [*c]mbedtls_ssl_context, p_timer: ?*anyopaque, f_set_timer: ?*const mbedtls_ssl_set_timer_t, f_get_timer: ?*const mbedtls_ssl_get_timer_t) void;
pub fn mbedtls_ssl_conf_cert_cb(arg_conf: [*c]mbedtls_ssl_config, arg_f_cert_cb: mbedtls_ssl_hs_cb_t) callconv(.c) void {
    var conf = arg_conf;
    _ = &conf;
    var f_cert_cb = arg_f_cert_cb;
    _ = &f_cert_cb;
    conf.*.private_f_cert_cb = f_cert_cb;
}
pub const mbedtls_ssl_ticket_write_t = fn (p_ticket: ?*anyopaque, session: [*c]const mbedtls_ssl_session, start: [*c]u8, end: [*c]const u8, tlen: [*c]usize, lifetime: [*c]u32) callconv(.c) c_int;
pub const mbedtls_ssl_ticket_parse_t = fn (p_ticket: ?*anyopaque, session: [*c]mbedtls_ssl_session, buf: [*c]u8, len: usize) callconv(.c) c_int;
pub extern fn mbedtls_ssl_conf_session_tickets_cb(conf: [*c]mbedtls_ssl_config, f_ticket_write: ?*const mbedtls_ssl_ticket_write_t, f_ticket_parse: ?*const mbedtls_ssl_ticket_parse_t, p_ticket: ?*anyopaque) void;
pub fn mbedtls_ssl_session_get_ticket_creation_time(arg_session: [*c]mbedtls_ssl_session, arg_ticket_creation_time: [*c]mbedtls_ms_time_t) callconv(.c) c_int {
    var session = arg_session;
    _ = &session;
    var ticket_creation_time = arg_ticket_creation_time;
    _ = &ticket_creation_time;
    if (((@as(?*anyopaque, @ptrCast(@alignCast(session))) == @as(?*anyopaque, null)) or (@as(?*anyopaque, @ptrCast(@alignCast(ticket_creation_time))) == @as(?*anyopaque, null))) or (@as(c_int, session.*.private_endpoint) != @as(c_int, 1))) {
        return -@as(c_int, 28928);
    }
    ticket_creation_time.* = session.*.private_ticket_creation_time;
    return 0;
}
pub fn mbedtls_ssl_session_get_id(arg_session: [*c]const mbedtls_ssl_session) callconv(.c) [*c][32]u8 {
    var session = arg_session;
    _ = &session;
    return &session.*.private_id;
}
pub fn mbedtls_ssl_session_get_id_len(arg_session: [*c]const mbedtls_ssl_session) callconv(.c) usize {
    var session = arg_session;
    _ = &session;
    return session.*.private_id_len;
}
pub fn mbedtls_ssl_session_get_ciphersuite_id(arg_session: [*c]const mbedtls_ssl_session) callconv(.c) c_int {
    var session = arg_session;
    _ = &session;
    return session.*.private_ciphersuite;
}
pub extern fn mbedtls_ssl_set_export_keys_cb(ssl: [*c]mbedtls_ssl_context, f_export_keys: ?*const mbedtls_ssl_export_keys_t, p_export_keys: ?*anyopaque) void;
pub fn mbedtls_ssl_conf_set_user_data_p(arg_conf: [*c]mbedtls_ssl_config, arg_p: ?*anyopaque) callconv(.c) void {
    var conf = arg_conf;
    _ = &conf;
    var p = arg_p;
    _ = &p;
    conf.*.private_user_data.p = p;
}
pub fn mbedtls_ssl_conf_set_user_data_n(arg_conf: [*c]mbedtls_ssl_config, arg_n: usize) callconv(.c) void {
    var conf = arg_conf;
    _ = &conf;
    var n = arg_n;
    _ = &n;
    conf.*.private_user_data.n = n;
}
pub fn mbedtls_ssl_conf_get_user_data_p(arg_conf: [*c]mbedtls_ssl_config) callconv(.c) ?*anyopaque {
    var conf = arg_conf;
    _ = &conf;
    return conf.*.private_user_data.p;
}
pub fn mbedtls_ssl_conf_get_user_data_n(arg_conf: [*c]mbedtls_ssl_config) callconv(.c) usize {
    var conf = arg_conf;
    _ = &conf;
    return conf.*.private_user_data.n;
}
pub fn mbedtls_ssl_set_user_data_p(arg_ssl: [*c]mbedtls_ssl_context, arg_p: ?*anyopaque) callconv(.c) void {
    var ssl = arg_ssl;
    _ = &ssl;
    var p = arg_p;
    _ = &p;
    ssl.*.private_user_data.p = p;
}
pub fn mbedtls_ssl_set_user_data_n(arg_ssl: [*c]mbedtls_ssl_context, arg_n: usize) callconv(.c) void {
    var ssl = arg_ssl;
    _ = &ssl;
    var n = arg_n;
    _ = &n;
    ssl.*.private_user_data.n = n;
}
pub fn mbedtls_ssl_get_user_data_p(arg_ssl: [*c]mbedtls_ssl_context) callconv(.c) ?*anyopaque {
    var ssl = arg_ssl;
    _ = &ssl;
    return ssl.*.private_user_data.p;
}
pub fn mbedtls_ssl_get_user_data_n(arg_ssl: [*c]mbedtls_ssl_context) callconv(.c) usize {
    var ssl = arg_ssl;
    _ = &ssl;
    return ssl.*.private_user_data.n;
}
pub const mbedtls_ssl_cookie_write_t = fn (ctx: ?*anyopaque, p: [*c][*c]u8, end: [*c]u8, info: [*c]const u8, ilen: usize) callconv(.c) c_int;
pub const mbedtls_ssl_cookie_check_t = fn (ctx: ?*anyopaque, cookie: [*c]const u8, clen: usize, info: [*c]const u8, ilen: usize) callconv(.c) c_int;
pub extern fn mbedtls_ssl_conf_dtls_cookies(conf: [*c]mbedtls_ssl_config, f_cookie_write: ?*const mbedtls_ssl_cookie_write_t, f_cookie_check: ?*const mbedtls_ssl_cookie_check_t, p_cookie: ?*anyopaque) void;
pub extern fn mbedtls_ssl_set_client_transport_id(ssl: [*c]mbedtls_ssl_context, info: [*c]const u8, ilen: usize) c_int;
pub extern fn mbedtls_ssl_conf_dtls_anti_replay(conf: [*c]mbedtls_ssl_config, mode: u8) void;
pub extern fn mbedtls_ssl_conf_dtls_badmac_limit(conf: [*c]mbedtls_ssl_config, limit: c_uint) void;
pub extern fn mbedtls_ssl_set_datagram_packing(ssl: [*c]mbedtls_ssl_context, allow_packing: c_uint) void;
pub extern fn mbedtls_ssl_conf_handshake_timeout(conf: [*c]mbedtls_ssl_config, min: u32, max: u32) void;
pub extern fn mbedtls_ssl_conf_session_cache(conf: [*c]mbedtls_ssl_config, p_cache: ?*anyopaque, f_get_cache: ?*const mbedtls_ssl_cache_get_t, f_set_cache: ?*const mbedtls_ssl_cache_set_t) void;
pub extern fn mbedtls_ssl_set_session(ssl: [*c]mbedtls_ssl_context, session: [*c]const mbedtls_ssl_session) c_int;
pub extern fn mbedtls_ssl_session_load(session: [*c]mbedtls_ssl_session, buf: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ssl_session_save(session: [*c]const mbedtls_ssl_session, buf: [*c]u8, buf_len: usize, olen: [*c]usize) c_int;
pub extern fn mbedtls_ssl_conf_ciphersuites(conf: [*c]mbedtls_ssl_config, ciphersuites: [*c]const c_int) void;
pub extern fn mbedtls_ssl_conf_tls13_key_exchange_modes(conf: [*c]mbedtls_ssl_config, kex_modes: c_int) void;
pub extern fn mbedtls_ssl_conf_cid(conf: [*c]mbedtls_ssl_config, len: usize, ignore_other_cids: c_int) c_int;
pub extern fn mbedtls_ssl_conf_cert_profile(conf: [*c]mbedtls_ssl_config, profile: [*c]const mbedtls_x509_crt_profile) void;
pub extern fn mbedtls_ssl_conf_ca_chain(conf: [*c]mbedtls_ssl_config, ca_chain: [*c]mbedtls_x509_crt, ca_crl: [*c]mbedtls_x509_crl) void;
pub fn mbedtls_ssl_conf_dn_hints(arg_conf: [*c]mbedtls_ssl_config, arg_crt: [*c]const mbedtls_x509_crt) callconv(.c) void {
    var conf = arg_conf;
    _ = &conf;
    var crt = arg_crt;
    _ = &crt;
    conf.*.private_dn_hints = crt;
}
pub extern fn mbedtls_ssl_conf_own_cert(conf: [*c]mbedtls_ssl_config, own_cert: [*c]mbedtls_x509_crt, pk_key: [*c]mbedtls_pk_context) c_int;
pub extern fn mbedtls_ssl_conf_psk(conf: [*c]mbedtls_ssl_config, psk: [*c]const u8, psk_len: usize, psk_identity: [*c]const u8, psk_identity_len: usize) c_int;
pub extern fn mbedtls_ssl_set_hs_psk(ssl: [*c]mbedtls_ssl_context, psk: [*c]const u8, psk_len: usize) c_int;
pub extern fn mbedtls_ssl_conf_psk_cb(conf: [*c]mbedtls_ssl_config, f_psk: ?*const fn (?*anyopaque, [*c]mbedtls_ssl_context, [*c]const u8, usize) callconv(.c) c_int, p_psk: ?*anyopaque) void;
pub extern fn mbedtls_ssl_conf_dh_param_bin(conf: [*c]mbedtls_ssl_config, dhm_P: [*c]const u8, P_len: usize, dhm_G: [*c]const u8, G_len: usize) c_int;
pub extern fn mbedtls_ssl_conf_dh_param_ctx(conf: [*c]mbedtls_ssl_config, dhm_ctx: [*c]mbedtls_dhm_context) c_int;
pub extern fn mbedtls_ssl_conf_dhm_min_bitlen(conf: [*c]mbedtls_ssl_config, bitlen: c_uint) void;
pub extern fn mbedtls_ssl_conf_curves(conf: [*c]mbedtls_ssl_config, curves: [*c]const mbedtls_ecp_group_id) void;
pub extern fn mbedtls_ssl_conf_groups(conf: [*c]mbedtls_ssl_config, groups: [*c]const u16) void;
pub extern fn mbedtls_ssl_conf_sig_hashes(conf: [*c]mbedtls_ssl_config, hashes: [*c]const c_int) void;
pub extern fn mbedtls_ssl_conf_sig_algs(conf: [*c]mbedtls_ssl_config, sig_algs: [*c]const u16) void;
pub extern fn mbedtls_ssl_set_hostname(ssl: [*c]mbedtls_ssl_context, hostname: [*c]const u8) c_int;
pub fn mbedtls_ssl_get_hostname(arg_ssl: [*c]mbedtls_ssl_context) callconv(.c) [*c]const u8 {
    var ssl = arg_ssl;
    _ = &ssl;
    return ssl.*.private_hostname;
}
pub extern fn mbedtls_ssl_get_hs_sni(ssl: [*c]mbedtls_ssl_context, name_len: [*c]usize) [*c]const u8;
pub extern fn mbedtls_ssl_set_hs_own_cert(ssl: [*c]mbedtls_ssl_context, own_cert: [*c]mbedtls_x509_crt, pk_key: [*c]mbedtls_pk_context) c_int;
pub extern fn mbedtls_ssl_set_hs_ca_chain(ssl: [*c]mbedtls_ssl_context, ca_chain: [*c]mbedtls_x509_crt, ca_crl: [*c]mbedtls_x509_crl) void;
pub extern fn mbedtls_ssl_set_hs_dn_hints(ssl: [*c]mbedtls_ssl_context, crt: [*c]const mbedtls_x509_crt) void;
pub extern fn mbedtls_ssl_set_hs_authmode(ssl: [*c]mbedtls_ssl_context, authmode: c_int) void;
pub extern fn mbedtls_ssl_conf_sni(conf: [*c]mbedtls_ssl_config, f_sni: ?*const fn (?*anyopaque, [*c]mbedtls_ssl_context, [*c]const u8, usize) callconv(.c) c_int, p_sni: ?*anyopaque) void;
pub extern fn mbedtls_ssl_conf_alpn_protocols(conf: [*c]mbedtls_ssl_config, protos: [*c][*c]const u8) c_int;
pub extern fn mbedtls_ssl_get_alpn_protocol(ssl: [*c]const mbedtls_ssl_context) [*c]const u8;
pub extern fn mbedtls_ssl_conf_max_version(conf: [*c]mbedtls_ssl_config, major: c_int, minor: c_int) void;
pub fn mbedtls_ssl_conf_max_tls_version(arg_conf: [*c]mbedtls_ssl_config, arg_tls_version: mbedtls_ssl_protocol_version) callconv(.c) void {
    var conf = arg_conf;
    _ = &conf;
    var tls_version = arg_tls_version;
    _ = &tls_version;
    conf.*.private_max_tls_version = tls_version;
}
pub extern fn mbedtls_ssl_conf_min_version(conf: [*c]mbedtls_ssl_config, major: c_int, minor: c_int) void;
pub fn mbedtls_ssl_conf_min_tls_version(arg_conf: [*c]mbedtls_ssl_config, arg_tls_version: mbedtls_ssl_protocol_version) callconv(.c) void {
    var conf = arg_conf;
    _ = &conf;
    var tls_version = arg_tls_version;
    _ = &tls_version;
    conf.*.private_min_tls_version = tls_version;
}
pub extern fn mbedtls_ssl_conf_encrypt_then_mac(conf: [*c]mbedtls_ssl_config, etm: u8) void;
pub extern fn mbedtls_ssl_conf_extended_master_secret(conf: [*c]mbedtls_ssl_config, ems: u8) void;
pub extern fn mbedtls_ssl_conf_cert_req_ca_list(conf: [*c]mbedtls_ssl_config, cert_req_ca_list: u8) void;
pub extern fn mbedtls_ssl_conf_max_frag_len(conf: [*c]mbedtls_ssl_config, mfl_code: u8) c_int;
pub extern fn mbedtls_ssl_conf_preference_order(conf: [*c]mbedtls_ssl_config, order: c_int) void;
pub extern fn mbedtls_ssl_conf_session_tickets(conf: [*c]mbedtls_ssl_config, use_tickets: c_int) void;
pub extern fn mbedtls_ssl_conf_tls13_enable_signal_new_session_tickets(conf: [*c]mbedtls_ssl_config, signal_new_session_tickets: c_int) void;
pub extern fn mbedtls_ssl_conf_new_session_tickets(conf: [*c]mbedtls_ssl_config, num_tickets: u16) void;
pub extern fn mbedtls_ssl_conf_renegotiation(conf: [*c]mbedtls_ssl_config, renegotiation: c_int) void;
pub extern fn mbedtls_ssl_conf_legacy_renegotiation(conf: [*c]mbedtls_ssl_config, allow_legacy: c_int) void;
pub extern fn mbedtls_ssl_conf_renegotiation_enforced(conf: [*c]mbedtls_ssl_config, max_records: c_int) void;
pub extern fn mbedtls_ssl_conf_renegotiation_period(conf: [*c]mbedtls_ssl_config, period: [*c]const u8) void;
pub extern fn mbedtls_ssl_check_pending(ssl: [*c]const mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_get_bytes_avail(ssl: [*c]const mbedtls_ssl_context) usize;
pub extern fn mbedtls_ssl_get_verify_result(ssl: [*c]const mbedtls_ssl_context) u32;
pub extern fn mbedtls_ssl_get_ciphersuite_id_from_ssl(ssl: [*c]const mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_get_ciphersuite(ssl: [*c]const mbedtls_ssl_context) [*c]const u8;
pub fn mbedtls_ssl_get_version_number(arg_ssl: [*c]const mbedtls_ssl_context) callconv(.c) mbedtls_ssl_protocol_version {
    var ssl = arg_ssl;
    _ = &ssl;
    return ssl.*.private_tls_version;
}
pub extern fn mbedtls_ssl_get_version(ssl: [*c]const mbedtls_ssl_context) [*c]const u8;
pub extern fn mbedtls_ssl_get_record_expansion(ssl: [*c]const mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_get_max_out_record_payload(ssl: [*c]const mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_get_max_in_record_payload(ssl: [*c]const mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_get_peer_cert(ssl: [*c]const mbedtls_ssl_context) [*c]const mbedtls_x509_crt;
pub extern fn mbedtls_ssl_get_session(ssl: [*c]const mbedtls_ssl_context, session: [*c]mbedtls_ssl_session) c_int;
pub extern fn mbedtls_ssl_handshake(ssl: [*c]mbedtls_ssl_context) c_int;
pub fn mbedtls_ssl_is_handshake_over(arg_ssl: [*c]mbedtls_ssl_context) callconv(.c) c_int {
    var ssl = arg_ssl;
    _ = &ssl;
    return @intFromBool(ssl.*.private_state >= MBEDTLS_SSL_HANDSHAKE_OVER);
}
pub extern fn mbedtls_ssl_handshake_step(ssl: [*c]mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_renegotiate(ssl: [*c]mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_read(ssl: [*c]mbedtls_ssl_context, buf: [*c]u8, len: usize) c_int;
pub extern fn mbedtls_ssl_write(ssl: [*c]mbedtls_ssl_context, buf: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ssl_send_alert_message(ssl: [*c]mbedtls_ssl_context, level: u8, message: u8) c_int;
pub extern fn mbedtls_ssl_close_notify(ssl: [*c]mbedtls_ssl_context) c_int;
pub extern fn mbedtls_ssl_free(ssl: [*c]mbedtls_ssl_context) void;
pub extern fn mbedtls_ssl_context_save(ssl: [*c]mbedtls_ssl_context, buf: [*c]u8, buf_len: usize, olen: [*c]usize) c_int;
pub extern fn mbedtls_ssl_context_load(ssl: [*c]mbedtls_ssl_context, buf: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ssl_config_init(conf: [*c]mbedtls_ssl_config) void;
pub extern fn mbedtls_ssl_config_defaults(conf: [*c]mbedtls_ssl_config, endpoint: c_int, transport: c_int, preset: c_int) c_int;
pub extern fn mbedtls_ssl_config_free(conf: [*c]mbedtls_ssl_config) void;
pub extern fn mbedtls_ssl_session_init(session: [*c]mbedtls_ssl_session) void;
pub extern fn mbedtls_ssl_session_free(session: [*c]mbedtls_ssl_session) void;
pub extern fn mbedtls_ssl_tls_prf(prf: mbedtls_tls_prf_types, secret: [*c]const u8, slen: usize, label: [*c]const u8, random: [*c]const u8, rlen: usize, dstbuf: [*c]u8, dlen: usize) c_int;
pub extern fn mbedtls_ssl_export_keying_material(ssl: [*c]mbedtls_ssl_context, out: [*c]u8, key_len: usize, label: [*c]const u8, label_len: usize, context: [*c]const u8, context_len: usize, use_context: c_int) c_int;
pub const struct_mbedtls_net_context = extern struct {
    fd: c_int = 0,
    pub const mbedtls_net_init = __root.mbedtls_net_init;
    pub const mbedtls_net_connect = __root.mbedtls_net_connect;
    pub const mbedtls_net_bind = __root.mbedtls_net_bind;
    pub const mbedtls_net_accept = __root.mbedtls_net_accept;
    pub const mbedtls_net_poll = __root.mbedtls_net_poll;
    pub const mbedtls_net_set_block = __root.mbedtls_net_set_block;
    pub const mbedtls_net_set_nonblock = __root.mbedtls_net_set_nonblock;
    pub const mbedtls_net_close = __root.mbedtls_net_close;
    pub const mbedtls_net_free = __root.mbedtls_net_free;
    pub const init = __root.mbedtls_net_init;
    pub const connect = __root.mbedtls_net_connect;
    pub const bind = __root.mbedtls_net_bind;
    pub const accept = __root.mbedtls_net_accept;
    pub const poll = __root.mbedtls_net_poll;
    pub const block = __root.mbedtls_net_set_block;
    pub const nonblock = __root.mbedtls_net_set_nonblock;
    pub const close = __root.mbedtls_net_close;
    pub const free = __root.mbedtls_net_free;
};
pub const mbedtls_net_context = struct_mbedtls_net_context;
pub extern fn mbedtls_net_init(ctx: [*c]mbedtls_net_context) void;
pub extern fn mbedtls_net_connect(ctx: [*c]mbedtls_net_context, host: [*c]const u8, port: [*c]const u8, proto: c_int) c_int;
pub extern fn mbedtls_net_bind(ctx: [*c]mbedtls_net_context, bind_ip: [*c]const u8, port: [*c]const u8, proto: c_int) c_int;
pub extern fn mbedtls_net_accept(bind_ctx: [*c]mbedtls_net_context, client_ctx: [*c]mbedtls_net_context, client_ip: ?*anyopaque, buf_size: usize, cip_len: [*c]usize) c_int;
pub extern fn mbedtls_net_poll(ctx: [*c]mbedtls_net_context, rw: u32, timeout: u32) c_int;
pub extern fn mbedtls_net_set_block(ctx: [*c]mbedtls_net_context) c_int;
pub extern fn mbedtls_net_set_nonblock(ctx: [*c]mbedtls_net_context) c_int;
pub extern fn mbedtls_net_usleep(usec: c_ulong) void;
pub extern fn mbedtls_net_recv(ctx: ?*anyopaque, buf: [*c]u8, len: usize) c_int;
pub extern fn mbedtls_net_send(ctx: ?*anyopaque, buf: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_net_recv_timeout(ctx: ?*anyopaque, buf: [*c]u8, len: usize, timeout: u32) c_int;
pub extern fn mbedtls_net_close(ctx: [*c]mbedtls_net_context) void;
pub extern fn mbedtls_net_free(ctx: [*c]mbedtls_net_context) void;
pub const mbedtls_entropy_f_source_ptr = ?*const fn (data: ?*anyopaque, output: [*c]u8, len: usize, olen: [*c]usize) callconv(.c) c_int;
pub const struct_mbedtls_entropy_source_state = extern struct {
    private_f_source: mbedtls_entropy_f_source_ptr = null,
    private_p_source: ?*anyopaque = null,
    private_size: usize = 0,
    private_threshold: usize = 0,
    private_strong: c_int = 0,
};
pub const mbedtls_entropy_source_state = struct_mbedtls_entropy_source_state;
pub const struct_mbedtls_entropy_context = extern struct {
    private_accumulator: mbedtls_md_context_t = @import("std").mem.zeroes(mbedtls_md_context_t),
    private_accumulator_started: c_int = 0,
    private_source_count: c_int = 0,
    private_source: [20]mbedtls_entropy_source_state = @import("std").mem.zeroes([20]mbedtls_entropy_source_state),
    private_mutex: mbedtls_threading_mutex_t = @import("std").mem.zeroes(mbedtls_threading_mutex_t),
    pub const mbedtls_entropy_init = __root.mbedtls_entropy_init;
    pub const mbedtls_entropy_free = __root.mbedtls_entropy_free;
    pub const mbedtls_entropy_add_source = __root.mbedtls_entropy_add_source;
    pub const mbedtls_entropy_gather = __root.mbedtls_entropy_gather;
    pub const mbedtls_entropy_update_manual = __root.mbedtls_entropy_update_manual;
    pub const mbedtls_entropy_write_seed_file = __root.mbedtls_entropy_write_seed_file;
    pub const mbedtls_entropy_update_seed_file = __root.mbedtls_entropy_update_seed_file;
    pub const init = __root.mbedtls_entropy_init;
    pub const free = __root.mbedtls_entropy_free;
    pub const source = __root.mbedtls_entropy_add_source;
    pub const gather = __root.mbedtls_entropy_gather;
    pub const manual = __root.mbedtls_entropy_update_manual;
    pub const file = __root.mbedtls_entropy_write_seed_file;
};
pub const mbedtls_entropy_context = struct_mbedtls_entropy_context;
pub extern fn mbedtls_platform_entropy_poll(data: ?*anyopaque, output: [*c]u8, len: usize, olen: [*c]usize) c_int;
pub extern fn mbedtls_entropy_init(ctx: [*c]mbedtls_entropy_context) void;
pub extern fn mbedtls_entropy_free(ctx: [*c]mbedtls_entropy_context) void;
pub extern fn mbedtls_entropy_add_source(ctx: [*c]mbedtls_entropy_context, f_source: mbedtls_entropy_f_source_ptr, p_source: ?*anyopaque, threshold: usize, strong: c_int) c_int;
pub extern fn mbedtls_entropy_gather(ctx: [*c]mbedtls_entropy_context) c_int;
pub extern fn mbedtls_entropy_func(data: ?*anyopaque, output: [*c]u8, len: usize) c_int;
pub extern fn mbedtls_entropy_update_manual(ctx: [*c]mbedtls_entropy_context, data: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_entropy_write_seed_file(ctx: [*c]mbedtls_entropy_context, path: [*c]const u8) c_int;
pub extern fn mbedtls_entropy_update_seed_file(ctx: [*c]mbedtls_entropy_context, path: [*c]const u8) c_int;
pub extern fn mbedtls_entropy_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_aes_context = extern struct {
    private_nr: c_int = 0,
    private_rk_offset: usize = 0,
    private_buf: [68]u32 = @import("std").mem.zeroes([68]u32),
    pub const mbedtls_aes_init = __root.mbedtls_aes_init;
    pub const mbedtls_aes_free = __root.mbedtls_aes_free;
    pub const mbedtls_aes_setkey_enc = __root.mbedtls_aes_setkey_enc;
    pub const mbedtls_aes_setkey_dec = __root.mbedtls_aes_setkey_dec;
    pub const mbedtls_aes_crypt_ecb = __root.mbedtls_aes_crypt_ecb;
    pub const mbedtls_aes_crypt_cbc = __root.mbedtls_aes_crypt_cbc;
    pub const mbedtls_aes_crypt_cfb128 = __root.mbedtls_aes_crypt_cfb128;
    pub const mbedtls_aes_crypt_cfb8 = __root.mbedtls_aes_crypt_cfb8;
    pub const mbedtls_aes_crypt_ofb = __root.mbedtls_aes_crypt_ofb;
    pub const mbedtls_aes_crypt_ctr = __root.mbedtls_aes_crypt_ctr;
    pub const mbedtls_internal_aes_encrypt = __root.mbedtls_internal_aes_encrypt;
    pub const mbedtls_internal_aes_decrypt = __root.mbedtls_internal_aes_decrypt;
    pub const init = __root.mbedtls_aes_init;
    pub const free = __root.mbedtls_aes_free;
    pub const enc = __root.mbedtls_aes_setkey_enc;
    pub const dec = __root.mbedtls_aes_setkey_dec;
    pub const ecb = __root.mbedtls_aes_crypt_ecb;
    pub const cbc = __root.mbedtls_aes_crypt_cbc;
    pub const cfb128 = __root.mbedtls_aes_crypt_cfb128;
    pub const cfb8 = __root.mbedtls_aes_crypt_cfb8;
    pub const ofb = __root.mbedtls_aes_crypt_ofb;
    pub const ctr = __root.mbedtls_aes_crypt_ctr;
    pub const encrypt = __root.mbedtls_internal_aes_encrypt;
    pub const decrypt = __root.mbedtls_internal_aes_decrypt;
};
pub const mbedtls_aes_context = struct_mbedtls_aes_context;
pub const struct_mbedtls_aes_xts_context = extern struct {
    private_crypt: mbedtls_aes_context = @import("std").mem.zeroes(mbedtls_aes_context),
    private_tweak: mbedtls_aes_context = @import("std").mem.zeroes(mbedtls_aes_context),
    pub const mbedtls_aes_xts_init = __root.mbedtls_aes_xts_init;
    pub const mbedtls_aes_xts_free = __root.mbedtls_aes_xts_free;
    pub const mbedtls_aes_xts_setkey_enc = __root.mbedtls_aes_xts_setkey_enc;
    pub const mbedtls_aes_xts_setkey_dec = __root.mbedtls_aes_xts_setkey_dec;
    pub const mbedtls_aes_crypt_xts = __root.mbedtls_aes_crypt_xts;
    pub const init = __root.mbedtls_aes_xts_init;
    pub const free = __root.mbedtls_aes_xts_free;
    pub const enc = __root.mbedtls_aes_xts_setkey_enc;
    pub const dec = __root.mbedtls_aes_xts_setkey_dec;
    pub const xts = __root.mbedtls_aes_crypt_xts;
};
pub const mbedtls_aes_xts_context = struct_mbedtls_aes_xts_context;
pub extern fn mbedtls_aes_init(ctx: [*c]mbedtls_aes_context) void;
pub extern fn mbedtls_aes_free(ctx: [*c]mbedtls_aes_context) void;
pub extern fn mbedtls_aes_xts_init(ctx: [*c]mbedtls_aes_xts_context) void;
pub extern fn mbedtls_aes_xts_free(ctx: [*c]mbedtls_aes_xts_context) void;
pub extern fn mbedtls_aes_setkey_enc(ctx: [*c]mbedtls_aes_context, key: [*c]const u8, keybits: c_uint) c_int;
pub extern fn mbedtls_aes_setkey_dec(ctx: [*c]mbedtls_aes_context, key: [*c]const u8, keybits: c_uint) c_int;
pub extern fn mbedtls_aes_xts_setkey_enc(ctx: [*c]mbedtls_aes_xts_context, key: [*c]const u8, keybits: c_uint) c_int;
pub extern fn mbedtls_aes_xts_setkey_dec(ctx: [*c]mbedtls_aes_xts_context, key: [*c]const u8, keybits: c_uint) c_int;
pub extern fn mbedtls_aes_crypt_ecb(ctx: [*c]mbedtls_aes_context, mode: c_int, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_crypt_cbc(ctx: [*c]mbedtls_aes_context, mode: c_int, length: usize, iv: [*c]u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_crypt_xts(ctx: [*c]mbedtls_aes_xts_context, mode: c_int, length: usize, data_unit: [*c]const u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_crypt_cfb128(ctx: [*c]mbedtls_aes_context, mode: c_int, length: usize, iv_off: [*c]usize, iv: [*c]u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_crypt_cfb8(ctx: [*c]mbedtls_aes_context, mode: c_int, length: usize, iv: [*c]u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_crypt_ofb(ctx: [*c]mbedtls_aes_context, length: usize, iv_off: [*c]usize, iv: [*c]u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_crypt_ctr(ctx: [*c]mbedtls_aes_context, length: usize, nc_off: [*c]usize, nonce_counter: [*c]u8, stream_block: [*c]u8, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_aes_encrypt(ctx: [*c]mbedtls_aes_context, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_internal_aes_decrypt(ctx: [*c]mbedtls_aes_context, input: [*c]const u8, output: [*c]u8) c_int;
pub extern fn mbedtls_aes_self_test(verbose: c_int) c_int;
pub const struct_mbedtls_ctr_drbg_context = extern struct {
    private_counter: [16]u8 = @import("std").mem.zeroes([16]u8),
    private_reseed_counter: c_int = 0,
    private_prediction_resistance: c_int = 0,
    private_entropy_len: usize = 0,
    private_reseed_interval: c_int = 0,
    private_aes_ctx: mbedtls_aes_context = @import("std").mem.zeroes(mbedtls_aes_context),
    private_f_entropy: ?*const fn (?*anyopaque, [*c]u8, usize) callconv(.c) c_int = null,
    private_p_entropy: ?*anyopaque = null,
    private_mutex: mbedtls_threading_mutex_t = @import("std").mem.zeroes(mbedtls_threading_mutex_t),
    pub const mbedtls_ctr_drbg_init = __root.mbedtls_ctr_drbg_init;
    pub const mbedtls_ctr_drbg_seed = __root.mbedtls_ctr_drbg_seed;
    pub const mbedtls_ctr_drbg_free = __root.mbedtls_ctr_drbg_free;
    pub const mbedtls_ctr_drbg_set_prediction_resistance = __root.mbedtls_ctr_drbg_set_prediction_resistance;
    pub const mbedtls_ctr_drbg_set_entropy_len = __root.mbedtls_ctr_drbg_set_entropy_len;
    pub const mbedtls_ctr_drbg_set_nonce_len = __root.mbedtls_ctr_drbg_set_nonce_len;
    pub const mbedtls_ctr_drbg_set_reseed_interval = __root.mbedtls_ctr_drbg_set_reseed_interval;
    pub const mbedtls_ctr_drbg_reseed = __root.mbedtls_ctr_drbg_reseed;
    pub const mbedtls_ctr_drbg_update = __root.mbedtls_ctr_drbg_update;
    pub const mbedtls_ctr_drbg_write_seed_file = __root.mbedtls_ctr_drbg_write_seed_file;
    pub const mbedtls_ctr_drbg_update_seed_file = __root.mbedtls_ctr_drbg_update_seed_file;
    pub const init = __root.mbedtls_ctr_drbg_init;
    pub const seed = __root.mbedtls_ctr_drbg_seed;
    pub const free = __root.mbedtls_ctr_drbg_free;
    pub const resistance = __root.mbedtls_ctr_drbg_set_prediction_resistance;
    pub const len = __root.mbedtls_ctr_drbg_set_entropy_len;
    pub const interval = __root.mbedtls_ctr_drbg_set_reseed_interval;
    pub const reseed = __root.mbedtls_ctr_drbg_reseed;
    pub const update = __root.mbedtls_ctr_drbg_update;
    pub const file = __root.mbedtls_ctr_drbg_write_seed_file;
};
pub const mbedtls_ctr_drbg_context = struct_mbedtls_ctr_drbg_context;
pub extern fn mbedtls_ctr_drbg_init(ctx: [*c]mbedtls_ctr_drbg_context) void;
pub extern fn mbedtls_ctr_drbg_seed(ctx: [*c]mbedtls_ctr_drbg_context, f_entropy: ?*const fn (?*anyopaque, [*c]u8, usize) callconv(.c) c_int, p_entropy: ?*anyopaque, custom: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ctr_drbg_free(ctx: [*c]mbedtls_ctr_drbg_context) void;
pub extern fn mbedtls_ctr_drbg_set_prediction_resistance(ctx: [*c]mbedtls_ctr_drbg_context, resistance: c_int) void;
pub extern fn mbedtls_ctr_drbg_set_entropy_len(ctx: [*c]mbedtls_ctr_drbg_context, len: usize) void;
pub extern fn mbedtls_ctr_drbg_set_nonce_len(ctx: [*c]mbedtls_ctr_drbg_context, len: usize) c_int;
pub extern fn mbedtls_ctr_drbg_set_reseed_interval(ctx: [*c]mbedtls_ctr_drbg_context, interval: c_int) void;
pub extern fn mbedtls_ctr_drbg_reseed(ctx: [*c]mbedtls_ctr_drbg_context, additional: [*c]const u8, len: usize) c_int;
pub extern fn mbedtls_ctr_drbg_update(ctx: [*c]mbedtls_ctr_drbg_context, additional: [*c]const u8, add_len: usize) c_int;
pub extern fn mbedtls_ctr_drbg_random_with_add(p_rng: ?*anyopaque, output: [*c]u8, output_len: usize, additional: [*c]const u8, add_len: usize) c_int;
pub extern fn mbedtls_ctr_drbg_random(p_rng: ?*anyopaque, output: [*c]u8, output_len: usize) c_int;
pub extern fn mbedtls_ctr_drbg_write_seed_file(ctx: [*c]mbedtls_ctr_drbg_context, path: [*c]const u8) c_int;
pub extern fn mbedtls_ctr_drbg_update_seed_file(ctx: [*c]mbedtls_ctr_drbg_context, path: [*c]const u8) c_int;
pub extern fn mbedtls_ctr_drbg_self_test(verbose: c_int) c_int;
pub fn mbedtls_error_add(arg_high: c_int, arg_low: c_int, arg_file: [*c]const u8, arg_line: c_int) callconv(.c) c_int {
    var high = arg_high;
    _ = &high;
    var low = arg_low;
    _ = &low;
    var file = arg_file;
    _ = &file;
    var line = arg_line;
    _ = &line;
    _ = &file;
    _ = &line;
    return high + low;
}
pub extern fn mbedtls_strerror(errnum: c_int, buffer: [*c]u8, buflen: usize) void;
pub extern fn mbedtls_high_level_strerr(error_code: c_int) [*c]const u8;
pub extern fn mbedtls_low_level_strerr(error_code: c_int) [*c]const u8;

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
pub const MBEDTLS_NET_SOCKETS_H = "";
pub const MBEDTLS_PRIVATE_ACCESS_H = "";
pub const MBEDTLS_PRIVATE = @compileError("unable to translate macro: undefined identifier `private_`"); // /usr/include/mbedtls/private_access.h:15:9
pub const MBEDTLS_BUILD_INFO_H = "";
pub const MBEDTLS_VERSION_MAJOR = @as(c_int, 3);
pub const MBEDTLS_VERSION_MINOR = @as(c_int, 6);
pub const MBEDTLS_VERSION_PATCH = @as(c_int, 4);
pub const MBEDTLS_VERSION_NUMBER = __helpers.promoteIntLiteral(c_int, 0x03060400, .hex);
pub const MBEDTLS_VERSION_STRING = "3.6.4";
pub const MBEDTLS_VERSION_STRING_FULL = "Mbed TLS 3.6.4";
pub const MBEDTLS_ARCH_IS_X64 = "";
pub const MBEDTLS_COMPILER_IS_GCC = "";
pub const MBEDTLS_GCC_VERSION = ((__GNUC__ * @as(c_int, 10000)) + (__GNUC_MINOR__ * @as(c_int, 100))) + __GNUC_PATCHLEVEL__;
pub const MBEDTLS_HAVE_ASM = "";
pub const MBEDTLS_HAVE_SSE2 = "";
pub const MBEDTLS_HAVE_TIME = "";
pub const MBEDTLS_HAVE_TIME_DATE = "";
pub const MBEDTLS_CIPHER_MODE_CBC = "";
pub const MBEDTLS_CIPHER_MODE_CFB = "";
pub const MBEDTLS_CIPHER_MODE_CTR = "";
pub const MBEDTLS_CIPHER_MODE_OFB = "";
pub const MBEDTLS_CIPHER_MODE_XTS = "";
pub const MBEDTLS_CIPHER_PADDING_PKCS7 = "";
pub const MBEDTLS_CIPHER_PADDING_ONE_AND_ZEROS = "";
pub const MBEDTLS_CIPHER_PADDING_ZEROS_AND_LEN = "";
pub const MBEDTLS_CIPHER_PADDING_ZEROS = "";
pub const MBEDTLS_ECP_DP_SECP192R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP224R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP256R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP384R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP521R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP192K1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP224K1_ENABLED = "";
pub const MBEDTLS_ECP_DP_SECP256K1_ENABLED = "";
pub const MBEDTLS_ECP_DP_BP256R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_BP384R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_BP512R1_ENABLED = "";
pub const MBEDTLS_ECP_DP_CURVE25519_ENABLED = "";
pub const MBEDTLS_ECP_DP_CURVE448_ENABLED = "";
pub const MBEDTLS_ECP_NIST_OPTIM = "";
pub const MBEDTLS_ECDSA_DETERMINISTIC = "";
pub const MBEDTLS_KEY_EXCHANGE_PSK_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_DHE_PSK_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDHE_PSK_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_RSA_PSK_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_RSA_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_DHE_RSA_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDHE_RSA_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDHE_ECDSA_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDH_ECDSA_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDH_RSA_ENABLED = "";
pub const MBEDTLS_PK_PARSE_EC_EXTENDED = "";
pub const MBEDTLS_PK_PARSE_EC_COMPRESSED = "";
pub const MBEDTLS_ERROR_STRERROR_DUMMY = "";
pub const MBEDTLS_GENPRIME = "";
pub const MBEDTLS_FS_IO = "";
pub const MBEDTLS_PK_RSA_ALT_SUPPORT = "";
pub const MBEDTLS_PKCS1_V15 = "";
pub const MBEDTLS_PKCS1_V21 = "";
pub const MBEDTLS_PSA_KEY_STORE_DYNAMIC = "";
pub const MBEDTLS_SELF_TEST = "";
pub const MBEDTLS_SSL_ALL_ALERT_MESSAGES = "";
pub const MBEDTLS_SSL_DTLS_CONNECTION_ID = "";
pub const MBEDTLS_SSL_DTLS_CONNECTION_ID_COMPAT = @as(c_int, 0);
pub const MBEDTLS_SSL_CONTEXT_SERIALIZATION = "";
pub const MBEDTLS_SSL_ENCRYPT_THEN_MAC = "";
pub const MBEDTLS_SSL_EXTENDED_MASTER_SECRET = "";
pub const MBEDTLS_SSL_KEEP_PEER_CERTIFICATE = "";
pub const MBEDTLS_SSL_KEYING_MATERIAL_EXPORT = "";
pub const MBEDTLS_SSL_RENEGOTIATION = "";
pub const MBEDTLS_SSL_MAX_FRAGMENT_LENGTH = "";
pub const MBEDTLS_SSL_PROTO_TLS1_2 = "";
pub const MBEDTLS_SSL_PROTO_TLS1_3 = "";
pub const MBEDTLS_SSL_TLS1_3_COMPATIBILITY_MODE = "";
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_ENABLED = "";
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_EPHEMERAL_ENABLED = "";
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_EPHEMERAL_ENABLED = "";
pub const MBEDTLS_SSL_PROTO_DTLS = "";
pub const MBEDTLS_SSL_ALPN = "";
pub const MBEDTLS_SSL_DTLS_ANTI_REPLAY = "";
pub const MBEDTLS_SSL_DTLS_HELLO_VERIFY = "";
pub const MBEDTLS_SSL_DTLS_CLIENT_PORT_REUSE = "";
pub const MBEDTLS_SSL_SESSION_TICKETS = "";
pub const MBEDTLS_SSL_SERVER_NAME_INDICATION = "";
pub const MBEDTLS_THREADING_PTHREAD = "";
pub const MBEDTLS_VERSION_FEATURES = "";
pub const MBEDTLS_X509_RSASSA_PSS_SUPPORT = "";
pub const MBEDTLS_AESNI_C = "";
pub const MBEDTLS_AESCE_C = "";
pub const MBEDTLS_AES_C = "";
pub const MBEDTLS_ASN1_PARSE_C = "";
pub const MBEDTLS_ASN1_WRITE_C = "";
pub const MBEDTLS_BASE64_C = "";
pub const MBEDTLS_BIGNUM_C = "";
pub const MBEDTLS_CAMELLIA_C = "";
pub const MBEDTLS_ARIA_C = "";
pub const MBEDTLS_CCM_C = "";
pub const MBEDTLS_CHACHA20_C = "";
pub const MBEDTLS_CHACHAPOLY_C = "";
pub const MBEDTLS_CIPHER_C = "";
pub const MBEDTLS_CMAC_C = "";
pub const MBEDTLS_CTR_DRBG_C = "";
pub const MBEDTLS_DEBUG_C = "";
pub const MBEDTLS_DES_C = "";
pub const MBEDTLS_DHM_C = "";
pub const MBEDTLS_ECDH_C = "";
pub const MBEDTLS_ECDSA_C = "";
pub const MBEDTLS_ECJPAKE_C = "";
pub const MBEDTLS_ECP_C = "";
pub const MBEDTLS_ENTROPY_C = "";
pub const MBEDTLS_ERROR_C = "";
pub const MBEDTLS_GCM_C = "";
pub const MBEDTLS_HKDF_C = "";
pub const MBEDTLS_HMAC_DRBG_C = "";
pub const MBEDTLS_LMS_C = "";
pub const MBEDTLS_NIST_KW_C = "";
pub const MBEDTLS_MD_C = "";
pub const MBEDTLS_MD5_C = "";
pub const MBEDTLS_NET_C = "";
pub const MBEDTLS_OID_C = "";
pub const MBEDTLS_PADLOCK_C = "";
pub const MBEDTLS_PEM_PARSE_C = "";
pub const MBEDTLS_PEM_WRITE_C = "";
pub const MBEDTLS_PK_C = "";
pub const MBEDTLS_PK_PARSE_C = "";
pub const MBEDTLS_PK_WRITE_C = "";
pub const MBEDTLS_PKCS5_C = "";
pub const MBEDTLS_PKCS7_C = "";
pub const MBEDTLS_PKCS12_C = "";
pub const MBEDTLS_PLATFORM_C = "";
pub const MBEDTLS_POLY1305_C = "";
pub const MBEDTLS_PSA_CRYPTO_C = "";
pub const MBEDTLS_PSA_CRYPTO_STORAGE_C = "";
pub const MBEDTLS_PSA_ITS_FILE_C = "";
pub const MBEDTLS_RIPEMD160_C = "";
pub const MBEDTLS_RSA_C = "";
pub const MBEDTLS_SHA1_C = "";
pub const MBEDTLS_SHA224_C = "";
pub const MBEDTLS_SHA256_C = "";
pub const MBEDTLS_SHA384_C = "";
pub const MBEDTLS_SHA512_C = "";
pub const MBEDTLS_SHA3_C = "";
pub const MBEDTLS_SSL_CACHE_C = "";
pub const MBEDTLS_SSL_COOKIE_C = "";
pub const MBEDTLS_SSL_TICKET_C = "";
pub const MBEDTLS_SSL_CLI_C = "";
pub const MBEDTLS_SSL_SRV_C = "";
pub const MBEDTLS_SSL_TLS_C = "";
pub const MBEDTLS_THREADING_C = "";
pub const MBEDTLS_TIMING_C = "";
pub const MBEDTLS_VERSION_C = "";
pub const MBEDTLS_X509_USE_C = "";
pub const MBEDTLS_X509_CRT_PARSE_C = "";
pub const MBEDTLS_X509_CRL_PARSE_C = "";
pub const MBEDTLS_X509_CSR_PARSE_C = "";
pub const MBEDTLS_X509_CREATE_C = "";
pub const MBEDTLS_X509_CRT_WRITE_C = "";
pub const MBEDTLS_X509_CSR_WRITE_C = "";
pub const MBEDTLS_CONFIG_FILES_READ = "";
pub const MBEDTLS_CONFIG_PSA_H = "";
pub const MBEDTLS_PSA_CRYPTO_LEGACY_H = "";
pub const PSA_CRYPTO_ADJUST_CONFIG_SYNONYMS_H = "";
pub const PSA_CRYPTO_ADJUST_CONFIG_DEPENDENCIES_H = "";
pub const MBEDTLS_CONFIG_ADJUST_PSA_SUPERSET_LEGACY_H = "";
pub const PSA_WANT_ALG_MD5 = @as(c_int, 1);
pub const PSA_WANT_ALG_RIPEMD160 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA_1 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA_224 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA_256 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA_384 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA_512 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA3_224 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA3_256 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA3_384 = @as(c_int, 1);
pub const PSA_WANT_ALG_SHA3_512 = @as(c_int, 1);
pub const PSA_WANT_ECC_BRAINPOOL_P_R1_256 = @as(c_int, 1);
pub const PSA_WANT_ECC_BRAINPOOL_P_R1_384 = @as(c_int, 1);
pub const PSA_WANT_ECC_BRAINPOOL_P_R1_512 = @as(c_int, 1);
pub const PSA_WANT_ECC_MONTGOMERY_255 = @as(c_int, 1);
pub const PSA_WANT_ECC_MONTGOMERY_448 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_R1_192 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_R1_224 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_R1_256 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_R1_384 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_R1_521 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_K1_192 = @as(c_int, 1);
pub const PSA_WANT_ECC_SECP_K1_256 = @as(c_int, 1);
pub const MBEDTLS_CONFIG_ADJUST_PSA_FROM_LEGACY_H = "";
pub const MBEDTLS_PSA_BUILTIN_ALG_CCM = @as(c_int, 1);
pub const PSA_WANT_ALG_CCM = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CCM_STAR_NO_TAG = @as(c_int, 1);
pub const PSA_WANT_ALG_CCM_STAR_NO_TAG = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CMAC = @as(c_int, 1);
pub const PSA_WANT_ALG_CMAC = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_ECDH = @as(c_int, 1);
pub const PSA_WANT_ALG_ECDH = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_ECDSA = @as(c_int, 1);
pub const PSA_WANT_ALG_ECDSA = @as(c_int, 1);
pub const PSA_WANT_ALG_ECDSA_ANY = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_DETERMINISTIC_ECDSA = @as(c_int, 1);
pub const PSA_WANT_ALG_DETERMINISTIC_ECDSA = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ECC_KEY_PAIR_BASIC = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ECC_KEY_PAIR_IMPORT = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ECC_KEY_PAIR_EXPORT = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ECC_KEY_PAIR_GENERATE = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ECC_KEY_PAIR_DERIVE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ECC_KEY_PAIR_BASIC = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ECC_KEY_PAIR_IMPORT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ECC_KEY_PAIR_EXPORT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ECC_KEY_PAIR_GENERATE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ECC_KEY_PAIR_DERIVE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ECC_PUBLIC_KEY = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ECC_PUBLIC_KEY = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_DH_KEY_PAIR_BASIC = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_DH_KEY_PAIR_IMPORT = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_DH_KEY_PAIR_EXPORT = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_DH_KEY_PAIR_GENERATE = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_DH_PUBLIC_KEY = @as(c_int, 1);
pub const PSA_WANT_ALG_FFDH = @as(c_int, 1);
pub const PSA_WANT_DH_RFC7919_2048 = @as(c_int, 1);
pub const PSA_WANT_DH_RFC7919_3072 = @as(c_int, 1);
pub const PSA_WANT_DH_RFC7919_4096 = @as(c_int, 1);
pub const PSA_WANT_DH_RFC7919_6144 = @as(c_int, 1);
pub const PSA_WANT_DH_RFC7919_8192 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_FFDH = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_DH_KEY_PAIR_BASIC = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_DH_KEY_PAIR_IMPORT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_DH_KEY_PAIR_EXPORT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_DH_KEY_PAIR_GENERATE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_DH_PUBLIC_KEY = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_DH_RFC7919_2048 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_DH_RFC7919_3072 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_DH_RFC7919_4096 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_DH_RFC7919_6144 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_DH_RFC7919_8192 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_GCM = @as(c_int, 1);
pub const PSA_WANT_ALG_GCM = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_HMAC = @as(c_int, 1);
pub const PSA_WANT_ALG_HMAC = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_HKDF = @as(c_int, 1);
pub const PSA_WANT_ALG_HKDF = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_HKDF_EXTRACT = @as(c_int, 1);
pub const PSA_WANT_ALG_HKDF_EXTRACT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_HKDF_EXPAND = @as(c_int, 1);
pub const PSA_WANT_ALG_HKDF_EXPAND = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_HMAC = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_TLS12_PRF = @as(c_int, 1);
pub const PSA_WANT_ALG_TLS12_PRF = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_TLS12_PSK_TO_MS = @as(c_int, 1);
pub const PSA_WANT_ALG_TLS12_PSK_TO_MS = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_MD5 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_PAKE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_JPAKE = @as(c_int, 1);
pub const PSA_WANT_ALG_JPAKE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_RIPEMD160 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_RSA_PKCS1V15_CRYPT = @as(c_int, 1);
pub const PSA_WANT_ALG_RSA_PKCS1V15_CRYPT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_RSA_PKCS1V15_SIGN = @as(c_int, 1);
pub const PSA_WANT_ALG_RSA_PKCS1V15_SIGN = @as(c_int, 1);
pub const PSA_WANT_ALG_RSA_PKCS1V15_SIGN_RAW = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_RSA_OAEP = @as(c_int, 1);
pub const PSA_WANT_ALG_RSA_OAEP = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_RSA_PSS = @as(c_int, 1);
pub const PSA_WANT_ALG_RSA_PSS = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_RSA_KEY_PAIR_GENERATE = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_RSA_KEY_PAIR_GENERATE = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_RSA_KEY_PAIR_BASIC = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_RSA_KEY_PAIR_IMPORT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_RSA_KEY_PAIR_EXPORT = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_RSA_KEY_PAIR_BASIC = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_RSA_KEY_PAIR_IMPORT = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_RSA_KEY_PAIR_EXPORT = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_RSA_PUBLIC_KEY = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_RSA_PUBLIC_KEY = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA_1 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA_224 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA_256 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA_384 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA_512 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA3_224 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA3_256 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA3_384 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_SHA3_512 = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_AES = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_AES = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_ARIA = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_ARIA = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_CAMELLIA = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_CAMELLIA = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_DES = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_DES = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_TLS12_ECJPAKE_TO_PMS = @as(c_int, 1);
pub const PSA_WANT_ALG_TLS12_ECJPAKE_TO_PMS = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_CHACHA20 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_KEY_TYPE_CHACHA20 = @as(c_int, 1);
pub const PSA_WANT_ALG_STREAM_CIPHER = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_STREAM_CIPHER = @as(c_int, 1);
pub const PSA_WANT_ALG_CHACHA20_POLY1305 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CHACHA20_POLY1305 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CBC_NO_PADDING = @as(c_int, 1);
pub const PSA_WANT_ALG_CBC_NO_PADDING = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CBC_PKCS7 = @as(c_int, 1);
pub const PSA_WANT_ALG_CBC_PKCS7 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_ECB_NO_PADDING = @as(c_int, 1);
pub const PSA_WANT_ALG_ECB_NO_PADDING = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CFB = @as(c_int, 1);
pub const PSA_WANT_ALG_CFB = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_CTR = @as(c_int, 1);
pub const PSA_WANT_ALG_CTR = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ALG_OFB = @as(c_int, 1);
pub const PSA_WANT_ALG_OFB = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_BRAINPOOL_P_R1_256 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_BRAINPOOL_P_R1_384 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_BRAINPOOL_P_R1_512 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_MONTGOMERY_255 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_MONTGOMERY_448 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_R1_192 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_R1_224 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_R1_256 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_R1_384 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_R1_521 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_K1_192 = @as(c_int, 1);
pub const MBEDTLS_PSA_BUILTIN_ECC_SECP_K1_256 = @as(c_int, 1);
pub const PSA_CRYPTO_ADJUST_KEYPAIR_TYPES_H = "";
pub const PSA_WANT_ALG_SOME_PAKE = @as(c_int, 1);
pub const PSA_CRYPTO_ADJUST_AUTO_ENABLED_H = "";
pub const PSA_WANT_KEY_TYPE_DERIVE = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_PASSWORD = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_PASSWORD_HASH = @as(c_int, 1);
pub const PSA_WANT_KEY_TYPE_RAW_DATA = @as(c_int, 1);
pub const MBEDTLS_CONFIG_ADJUST_LEGACY_CRYPTO_H = "";
pub const MBEDTLS_PSA_CRYPTO_CLIENT = "";
pub const MBEDTLS_MD_LIGHT = "";
pub const MBEDTLS_MD_CAN_MD5 = "";
pub const MBEDTLS_MD_SOME_LEGACY = "";
pub const MBEDTLS_MD_CAN_SHA1 = "";
pub const MBEDTLS_MD_CAN_SHA224 = "";
pub const MBEDTLS_MD_CAN_SHA256 = "";
pub const MBEDTLS_MD_CAN_SHA384 = "";
pub const MBEDTLS_MD_CAN_SHA512 = "";
pub const MBEDTLS_MD_CAN_SHA3_224 = "";
pub const MBEDTLS_MD_CAN_SHA3_256 = "";
pub const MBEDTLS_MD_CAN_SHA3_384 = "";
pub const MBEDTLS_MD_CAN_SHA3_512 = "";
pub const MBEDTLS_MD_CAN_RIPEMD160 = "";
pub const MBEDTLS_BLOCK_CIPHER_AES_VIA_LEGACY = "";
pub const MBEDTLS_BLOCK_CIPHER_ARIA_VIA_LEGACY = "";
pub const MBEDTLS_BLOCK_CIPHER_CAMELLIA_VIA_LEGACY = "";
pub const MBEDTLS_BLOCK_CIPHER_CAN_AES = "";
pub const MBEDTLS_BLOCK_CIPHER_CAN_ARIA = "";
pub const MBEDTLS_BLOCK_CIPHER_CAN_CAMELLIA = "";
pub const MBEDTLS_CCM_GCM_CAN_AES = "";
pub const MBEDTLS_CCM_GCM_CAN_ARIA = "";
pub const MBEDTLS_CCM_GCM_CAN_CAMELLIA = "";
pub const MBEDTLS_ECP_LIGHT = "";
pub const MBEDTLS_CAN_ECDH = "";
pub const MBEDTLS_PK_CAN_ECDSA_SIGN = "";
pub const MBEDTLS_PK_CAN_ECDSA_VERIFY = "";
pub const MBEDTLS_PK_CAN_ECDSA_SOME = "";
pub const MBEDTLS_ECP_HAVE_SECP521R1 = "";
pub const MBEDTLS_ECP_HAVE_BP512R1 = "";
pub const MBEDTLS_ECP_HAVE_CURVE448 = "";
pub const MBEDTLS_ECP_HAVE_BP384R1 = "";
pub const MBEDTLS_ECP_HAVE_SECP384R1 = "";
pub const MBEDTLS_ECP_HAVE_BP256R1 = "";
pub const MBEDTLS_ECP_HAVE_SECP256K1 = "";
pub const MBEDTLS_ECP_HAVE_SECP256R1 = "";
pub const MBEDTLS_ECP_HAVE_CURVE25519 = "";
pub const MBEDTLS_ECP_HAVE_SECP224K1 = "";
pub const MBEDTLS_ECP_HAVE_SECP224R1 = "";
pub const MBEDTLS_ECP_HAVE_SECP192K1 = "";
pub const MBEDTLS_ECP_HAVE_SECP192R1 = "";
pub const MBEDTLS_PK_HAVE_ECC_KEYS = "";
pub const MBEDTLS_PSA_UTIL_HAVE_ECDSA = "";
pub const MBEDTLS_SSL_HAVE_AES = "";
pub const MBEDTLS_SSL_HAVE_ARIA = "";
pub const MBEDTLS_SSL_HAVE_CAMELLIA = "";
pub const MBEDTLS_SSL_HAVE_CBC = "";
pub const MBEDTLS_SSL_HAVE_GCM = "";
pub const MBEDTLS_SSL_HAVE_CCM = "";
pub const MBEDTLS_SSL_HAVE_CHACHAPOLY = "";
pub const MBEDTLS_SSL_HAVE_AEAD = "";
pub const MBEDTLS_CONFIG_ADJUST_X509_H = "";
pub const MBEDTLS_CONFIG_ADJUST_SSL_H = "";
pub const MBEDTLS_SSL_TLS1_2_SOME_ECC = "";
pub const MBEDTLS_CONFIG_IS_FINALIZED = "";
pub const MBEDTLS_CHECK_CONFIG_H = "";
pub const _GCC_LIMITS_H_ = "";
pub const __CLANG_LIMITS_H = "";
pub const _LIBC_LIMITS_H_ = @as(c_int, 1);
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
pub const MB_LEN_MAX = @as(c_int, 16);
pub const _BITS_POSIX1_LIM_H = @as(c_int, 1);
pub const _POSIX_AIO_LISTIO_MAX = @as(c_int, 2);
pub const _POSIX_AIO_MAX = @as(c_int, 1);
pub const _POSIX_ARG_MAX = @as(c_int, 4096);
pub const _POSIX_CHILD_MAX = @as(c_int, 25);
pub const _POSIX_DELAYTIMER_MAX = @as(c_int, 32);
pub const _POSIX_HOST_NAME_MAX = @as(c_int, 255);
pub const _POSIX_LINK_MAX = @as(c_int, 8);
pub const _POSIX_LOGIN_NAME_MAX = @as(c_int, 9);
pub const _POSIX_MAX_CANON = @as(c_int, 255);
pub const _POSIX_MAX_INPUT = @as(c_int, 255);
pub const _POSIX_MQ_OPEN_MAX = @as(c_int, 8);
pub const _POSIX_MQ_PRIO_MAX = @as(c_int, 32);
pub const _POSIX_NAME_MAX = @as(c_int, 14);
pub const _POSIX_NGROUPS_MAX = @as(c_int, 8);
pub const _POSIX_OPEN_MAX = @as(c_int, 20);
pub const _POSIX_PATH_MAX = @as(c_int, 256);
pub const _POSIX_PIPE_BUF = @as(c_int, 512);
pub const _POSIX_RE_DUP_MAX = @as(c_int, 255);
pub const _POSIX_RTSIG_MAX = @as(c_int, 8);
pub const _POSIX_SEM_NSEMS_MAX = @as(c_int, 256);
pub const _POSIX_SEM_VALUE_MAX = @as(c_int, 32767);
pub const _POSIX_SIGQUEUE_MAX = @as(c_int, 32);
pub const _POSIX_SSIZE_MAX = @as(c_int, 32767);
pub const _POSIX_STREAM_MAX = @as(c_int, 8);
pub const _POSIX_SYMLINK_MAX = @as(c_int, 255);
pub const _POSIX_SYMLOOP_MAX = @as(c_int, 8);
pub const _POSIX_TIMER_MAX = @as(c_int, 32);
pub const _POSIX_TTY_NAME_MAX = @as(c_int, 9);
pub const _POSIX_TZNAME_MAX = @as(c_int, 6);
pub const _POSIX_CLOCKRES_MIN = __helpers.promoteIntLiteral(c_int, 20000000, .decimal);
pub const _LINUX_LIMITS_H = "";
pub const NGROUPS_MAX = __helpers.promoteIntLiteral(c_int, 65536, .decimal);
pub const MAX_CANON = @as(c_int, 255);
pub const MAX_INPUT = @as(c_int, 255);
pub const NAME_MAX = @as(c_int, 255);
pub const PATH_MAX = @as(c_int, 4096);
pub const PIPE_BUF = @as(c_int, 4096);
pub const XATTR_NAME_MAX = @as(c_int, 255);
pub const XATTR_SIZE_MAX = __helpers.promoteIntLiteral(c_int, 65536, .decimal);
pub const XATTR_LIST_MAX = __helpers.promoteIntLiteral(c_int, 65536, .decimal);
pub const RTSIG_MAX = @as(c_int, 32);
pub const _POSIX_THREAD_KEYS_MAX = @as(c_int, 128);
pub const PTHREAD_KEYS_MAX = @as(c_int, 1024);
pub const _POSIX_THREAD_DESTRUCTOR_ITERATIONS = @as(c_int, 4);
pub const PTHREAD_DESTRUCTOR_ITERATIONS = _POSIX_THREAD_DESTRUCTOR_ITERATIONS;
pub const _POSIX_THREAD_THREADS_MAX = @as(c_int, 64);
pub const AIO_PRIO_DELTA_MAX = @as(c_int, 20);
pub const PTHREAD_STACK_MIN = @as(c_int, 16384);
pub const DELAYTIMER_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const TTY_NAME_MAX = @as(c_int, 32);
pub const LOGIN_NAME_MAX = @as(c_int, 256);
pub const HOST_NAME_MAX = @as(c_int, 64);
pub const MQ_PRIO_MAX = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const SEM_VALUE_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const SSIZE_MAX = LONG_MAX;
pub const _BITS_POSIX2_LIM_H = @as(c_int, 1);
pub const _POSIX2_BC_BASE_MAX = @as(c_int, 99);
pub const _POSIX2_BC_DIM_MAX = @as(c_int, 2048);
pub const _POSIX2_BC_SCALE_MAX = @as(c_int, 99);
pub const _POSIX2_BC_STRING_MAX = @as(c_int, 1000);
pub const _POSIX2_COLL_WEIGHTS_MAX = @as(c_int, 2);
pub const _POSIX2_EXPR_NEST_MAX = @as(c_int, 32);
pub const _POSIX2_LINE_MAX = @as(c_int, 2048);
pub const _POSIX2_RE_DUP_MAX = @as(c_int, 255);
pub const _POSIX2_CHARCLASS_NAME_MAX = @as(c_int, 14);
pub const BC_BASE_MAX = _POSIX2_BC_BASE_MAX;
pub const BC_DIM_MAX = _POSIX2_BC_DIM_MAX;
pub const BC_SCALE_MAX = _POSIX2_BC_SCALE_MAX;
pub const BC_STRING_MAX = _POSIX2_BC_STRING_MAX;
pub const COLL_WEIGHTS_MAX = @as(c_int, 255);
pub const EXPR_NEST_MAX = _POSIX2_EXPR_NEST_MAX;
pub const LINE_MAX = _POSIX2_LINE_MAX;
pub const CHARCLASS_NAME_MAX = @as(c_int, 2048);
pub const RE_DUP_MAX = @as(c_int, 0x7fff);
pub const SCHAR_MAX = __SCHAR_MAX__;
pub const SHRT_MAX = __SHRT_MAX__;
pub const INT_MAX = __INT_MAX__;
pub const LONG_MAX = __LONG_MAX__;
pub const SCHAR_MIN = -__SCHAR_MAX__ - @as(c_int, 1);
pub const SHRT_MIN = -__SHRT_MAX__ - @as(c_int, 1);
pub const INT_MIN = -__INT_MAX__ - @as(c_int, 1);
pub const LONG_MIN = -__LONG_MAX__ - @as(c_long, 1);
pub const UCHAR_MAX = (__SCHAR_MAX__ * @as(c_int, 2)) + @as(c_int, 1);
pub const USHRT_MAX = (__SHRT_MAX__ * @as(c_int, 2)) + @as(c_int, 1);
pub const UINT_MAX = (__INT_MAX__ * @as(c_uint, 2)) + @as(c_uint, 1);
pub const ULONG_MAX = (__LONG_MAX__ * @as(c_ulong, 2)) + @as(c_ulong, 1);
pub const CHAR_BIT = __CHAR_BIT__;
pub const CHAR_MIN = SCHAR_MIN;
pub const CHAR_MAX = __SCHAR_MAX__;
pub const LLONG_MIN = -__LONG_LONG_MAX__ - @as(c_longlong, 1);
pub const LLONG_MAX = __LONG_LONG_MAX__;
pub const ULLONG_MAX = (__LONG_LONG_MAX__ * @as(c_ulonglong, 2)) + @as(c_ulonglong, 1);
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H = @as(c_int, 1);
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
pub const MBEDTLS_SSL_H = "";
pub const MBEDTLS_PLATFORM_UTIL_H = "";
pub const __STDC_VERSION_STDDEF_H__ = @as(c_long, 202311);
pub const NULL = __helpers.cast(?*anyopaque, @as(c_int, 0));
pub const offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // /usr/local/zig/lib/compiler/aro/include/stddef.h:18:9
pub const MBEDTLS_PLATFORM_TIME_H = "";
pub const _TIME_H = @as(c_int, 1);
pub const __need_size_t = "";
pub const __need_NULL = "";
pub const _BITS_TIME_H = @as(c_int, 1);
pub const CLOCKS_PER_SEC = __helpers.cast(__clock_t, __helpers.promoteIntLiteral(c_int, 1000000, .decimal));
pub const CLOCK_REALTIME = @as(c_int, 0);
pub const CLOCK_MONOTONIC = @as(c_int, 1);
pub const CLOCK_PROCESS_CPUTIME_ID = @as(c_int, 2);
pub const CLOCK_THREAD_CPUTIME_ID = @as(c_int, 3);
pub const CLOCK_MONOTONIC_RAW = @as(c_int, 4);
pub const CLOCK_REALTIME_COARSE = @as(c_int, 5);
pub const CLOCK_MONOTONIC_COARSE = @as(c_int, 6);
pub const CLOCK_BOOTTIME = @as(c_int, 7);
pub const CLOCK_REALTIME_ALARM = @as(c_int, 8);
pub const CLOCK_BOOTTIME_ALARM = @as(c_int, 9);
pub const CLOCK_TAI = @as(c_int, 11);
pub const TIMER_ABSTIME = @as(c_int, 1);
pub const __clock_t_defined = @as(c_int, 1);
pub const __time_t_defined = @as(c_int, 1);
pub const __struct_tm_defined = @as(c_int, 1);
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
pub const __clockid_t_defined = @as(c_int, 1);
pub const __timer_t_defined = @as(c_int, 1);
pub const __itimerspec_defined = @as(c_int, 1);
pub const __pid_t_defined = "";
pub const _BITS_TYPES_LOCALE_T_H = @as(c_int, 1);
pub const _BITS_TYPES___LOCALE_T_H = @as(c_int, 1);
pub const TIME_UTC = @as(c_int, 1);
pub inline fn __isleap(year: anytype) @TypeOf((__helpers.rem(year, @as(c_int, 4)) == @as(c_int, 0)) and ((__helpers.rem(year, @as(c_int, 100)) != @as(c_int, 0)) or (__helpers.rem(year, @as(c_int, 400)) == @as(c_int, 0)))) {
    _ = &year;
    return (__helpers.rem(year, @as(c_int, 4)) == @as(c_int, 0)) and ((__helpers.rem(year, @as(c_int, 100)) != @as(c_int, 0)) or (__helpers.rem(year, @as(c_int, 400)) == @as(c_int, 0)));
}
pub const __CLANG_INTTYPES_H = "";
pub const _INTTYPES_H = @as(c_int, 1);
pub const ____gwchar_t_defined = @as(c_int, 1);
pub const __PRI64_PREFIX = "l";
pub const __PRIPTR_PREFIX = "l";
pub const PRId8 = "d";
pub const PRId16 = "d";
pub const PRId32 = "d";
pub const PRId64 = __PRI64_PREFIX ++ "d";
pub const PRIdLEAST8 = "d";
pub const PRIdLEAST16 = "d";
pub const PRIdLEAST32 = "d";
pub const PRIdLEAST64 = __PRI64_PREFIX ++ "d";
pub const PRIdFAST8 = "d";
pub const PRIdFAST16 = __PRIPTR_PREFIX ++ "d";
pub const PRIdFAST32 = __PRIPTR_PREFIX ++ "d";
pub const PRIdFAST64 = __PRI64_PREFIX ++ "d";
pub const PRIi8 = "i";
pub const PRIi16 = "i";
pub const PRIi32 = "i";
pub const PRIi64 = __PRI64_PREFIX ++ "i";
pub const PRIiLEAST8 = "i";
pub const PRIiLEAST16 = "i";
pub const PRIiLEAST32 = "i";
pub const PRIiLEAST64 = __PRI64_PREFIX ++ "i";
pub const PRIiFAST8 = "i";
pub const PRIiFAST16 = __PRIPTR_PREFIX ++ "i";
pub const PRIiFAST32 = __PRIPTR_PREFIX ++ "i";
pub const PRIiFAST64 = __PRI64_PREFIX ++ "i";
pub const PRIo8 = "o";
pub const PRIo16 = "o";
pub const PRIo32 = "o";
pub const PRIo64 = __PRI64_PREFIX ++ "o";
pub const PRIoLEAST8 = "o";
pub const PRIoLEAST16 = "o";
pub const PRIoLEAST32 = "o";
pub const PRIoLEAST64 = __PRI64_PREFIX ++ "o";
pub const PRIoFAST8 = "o";
pub const PRIoFAST16 = __PRIPTR_PREFIX ++ "o";
pub const PRIoFAST32 = __PRIPTR_PREFIX ++ "o";
pub const PRIoFAST64 = __PRI64_PREFIX ++ "o";
pub const PRIu8 = "u";
pub const PRIu16 = "u";
pub const PRIu32 = "u";
pub const PRIu64 = __PRI64_PREFIX ++ "u";
pub const PRIuLEAST8 = "u";
pub const PRIuLEAST16 = "u";
pub const PRIuLEAST32 = "u";
pub const PRIuLEAST64 = __PRI64_PREFIX ++ "u";
pub const PRIuFAST8 = "u";
pub const PRIuFAST16 = __PRIPTR_PREFIX ++ "u";
pub const PRIuFAST32 = __PRIPTR_PREFIX ++ "u";
pub const PRIuFAST64 = __PRI64_PREFIX ++ "u";
pub const PRIx8 = "x";
pub const PRIx16 = "x";
pub const PRIx32 = "x";
pub const PRIx64 = __PRI64_PREFIX ++ "x";
pub const PRIxLEAST8 = "x";
pub const PRIxLEAST16 = "x";
pub const PRIxLEAST32 = "x";
pub const PRIxLEAST64 = __PRI64_PREFIX ++ "x";
pub const PRIxFAST8 = "x";
pub const PRIxFAST16 = __PRIPTR_PREFIX ++ "x";
pub const PRIxFAST32 = __PRIPTR_PREFIX ++ "x";
pub const PRIxFAST64 = __PRI64_PREFIX ++ "x";
pub const PRIX8 = "X";
pub const PRIX16 = "X";
pub const PRIX32 = "X";
pub const PRIX64 = __PRI64_PREFIX ++ "X";
pub const PRIXLEAST8 = "X";
pub const PRIXLEAST16 = "X";
pub const PRIXLEAST32 = "X";
pub const PRIXLEAST64 = __PRI64_PREFIX ++ "X";
pub const PRIXFAST8 = "X";
pub const PRIXFAST16 = __PRIPTR_PREFIX ++ "X";
pub const PRIXFAST32 = __PRIPTR_PREFIX ++ "X";
pub const PRIXFAST64 = __PRI64_PREFIX ++ "X";
pub const PRIdMAX = __PRI64_PREFIX ++ "d";
pub const PRIiMAX = __PRI64_PREFIX ++ "i";
pub const PRIoMAX = __PRI64_PREFIX ++ "o";
pub const PRIuMAX = __PRI64_PREFIX ++ "u";
pub const PRIxMAX = __PRI64_PREFIX ++ "x";
pub const PRIXMAX = __PRI64_PREFIX ++ "X";
pub const PRIdPTR = __PRIPTR_PREFIX ++ "d";
pub const PRIiPTR = __PRIPTR_PREFIX ++ "i";
pub const PRIoPTR = __PRIPTR_PREFIX ++ "o";
pub const PRIuPTR = __PRIPTR_PREFIX ++ "u";
pub const PRIxPTR = __PRIPTR_PREFIX ++ "x";
pub const PRIXPTR = __PRIPTR_PREFIX ++ "X";
pub const SCNd8 = "hhd";
pub const SCNd16 = "hd";
pub const SCNd32 = "d";
pub const SCNd64 = __PRI64_PREFIX ++ "d";
pub const SCNdLEAST8 = "hhd";
pub const SCNdLEAST16 = "hd";
pub const SCNdLEAST32 = "d";
pub const SCNdLEAST64 = __PRI64_PREFIX ++ "d";
pub const SCNdFAST8 = "hhd";
pub const SCNdFAST16 = __PRIPTR_PREFIX ++ "d";
pub const SCNdFAST32 = __PRIPTR_PREFIX ++ "d";
pub const SCNdFAST64 = __PRI64_PREFIX ++ "d";
pub const SCNi8 = "hhi";
pub const SCNi16 = "hi";
pub const SCNi32 = "i";
pub const SCNi64 = __PRI64_PREFIX ++ "i";
pub const SCNiLEAST8 = "hhi";
pub const SCNiLEAST16 = "hi";
pub const SCNiLEAST32 = "i";
pub const SCNiLEAST64 = __PRI64_PREFIX ++ "i";
pub const SCNiFAST8 = "hhi";
pub const SCNiFAST16 = __PRIPTR_PREFIX ++ "i";
pub const SCNiFAST32 = __PRIPTR_PREFIX ++ "i";
pub const SCNiFAST64 = __PRI64_PREFIX ++ "i";
pub const SCNu8 = "hhu";
pub const SCNu16 = "hu";
pub const SCNu32 = "u";
pub const SCNu64 = __PRI64_PREFIX ++ "u";
pub const SCNuLEAST8 = "hhu";
pub const SCNuLEAST16 = "hu";
pub const SCNuLEAST32 = "u";
pub const SCNuLEAST64 = __PRI64_PREFIX ++ "u";
pub const SCNuFAST8 = "hhu";
pub const SCNuFAST16 = __PRIPTR_PREFIX ++ "u";
pub const SCNuFAST32 = __PRIPTR_PREFIX ++ "u";
pub const SCNuFAST64 = __PRI64_PREFIX ++ "u";
pub const SCNo8 = "hho";
pub const SCNo16 = "ho";
pub const SCNo32 = "o";
pub const SCNo64 = __PRI64_PREFIX ++ "o";
pub const SCNoLEAST8 = "hho";
pub const SCNoLEAST16 = "ho";
pub const SCNoLEAST32 = "o";
pub const SCNoLEAST64 = __PRI64_PREFIX ++ "o";
pub const SCNoFAST8 = "hho";
pub const SCNoFAST16 = __PRIPTR_PREFIX ++ "o";
pub const SCNoFAST32 = __PRIPTR_PREFIX ++ "o";
pub const SCNoFAST64 = __PRI64_PREFIX ++ "o";
pub const SCNx8 = "hhx";
pub const SCNx16 = "hx";
pub const SCNx32 = "x";
pub const SCNx64 = __PRI64_PREFIX ++ "x";
pub const SCNxLEAST8 = "hhx";
pub const SCNxLEAST16 = "hx";
pub const SCNxLEAST32 = "x";
pub const SCNxLEAST64 = __PRI64_PREFIX ++ "x";
pub const SCNxFAST8 = "hhx";
pub const SCNxFAST16 = __PRIPTR_PREFIX ++ "x";
pub const SCNxFAST32 = __PRIPTR_PREFIX ++ "x";
pub const SCNxFAST64 = __PRI64_PREFIX ++ "x";
pub const SCNdMAX = __PRI64_PREFIX ++ "d";
pub const SCNiMAX = __PRI64_PREFIX ++ "i";
pub const SCNoMAX = __PRI64_PREFIX ++ "o";
pub const SCNuMAX = __PRI64_PREFIX ++ "u";
pub const SCNxMAX = __PRI64_PREFIX ++ "x";
pub const SCNdPTR = __PRIPTR_PREFIX ++ "d";
pub const SCNiPTR = __PRIPTR_PREFIX ++ "i";
pub const SCNoPTR = __PRIPTR_PREFIX ++ "o";
pub const SCNuPTR = __PRIPTR_PREFIX ++ "u";
pub const SCNxPTR = __PRIPTR_PREFIX ++ "x";
pub const mbedtls_time = time;
pub const MBEDTLS_DEPRECATED = "";
pub inline fn MBEDTLS_DEPRECATED_STRING_CONSTANT(VAL: anytype) @TypeOf(VAL) {
    _ = &VAL;
    return VAL;
}
pub inline fn MBEDTLS_DEPRECATED_NUMERIC_CONSTANT(VAL: anytype) @TypeOf(VAL) {
    _ = &VAL;
    return VAL;
}
pub const MBEDTLS_CHECK_RETURN = @compileError("unable to translate macro: undefined identifier `__warn_unused_result__`"); // /usr/include/mbedtls/platform_util.h:52:9
pub const MBEDTLS_CHECK_RETURN_CRITICAL = MBEDTLS_CHECK_RETURN;
pub const MBEDTLS_CHECK_RETURN_TYPICAL = "";
pub const MBEDTLS_CHECK_RETURN_OPTIONAL = "";
pub inline fn MBEDTLS_IGNORE_RETURN(result: anytype) anyopaque {
    _ = &result;
    return __helpers.cast(anyopaque, !(result != 0));
}
pub const MBEDTLS_BIGNUM_H = "";
pub const _STDIO_H = @as(c_int, 1);
pub const __need___va_list = "";
pub const __STDC_VERSION_STDARG_H__ = @as(c_int, 0);
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:12:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:14:9
pub const va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:15:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:18:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:22:9
pub const __GNUC_VA_LIST = @as(c_int, 1);
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
pub const MBEDTLS_ERR_MPI_FILE_IO_ERROR = -@as(c_int, 0x0002);
pub const MBEDTLS_ERR_MPI_BAD_INPUT_DATA = -@as(c_int, 0x0004);
pub const MBEDTLS_ERR_MPI_INVALID_CHARACTER = -@as(c_int, 0x0006);
pub const MBEDTLS_ERR_MPI_BUFFER_TOO_SMALL = -@as(c_int, 0x0008);
pub const MBEDTLS_ERR_MPI_NEGATIVE_VALUE = -@as(c_int, 0x000A);
pub const MBEDTLS_ERR_MPI_DIVISION_BY_ZERO = -@as(c_int, 0x000C);
pub const MBEDTLS_ERR_MPI_NOT_ACCEPTABLE = -@as(c_int, 0x000E);
pub const MBEDTLS_ERR_MPI_ALLOC_FAILED = -@as(c_int, 0x0010);
pub const MBEDTLS_MPI_CHK = @compileError("unable to translate macro: undefined identifier `ret`"); // /usr/include/mbedtls/bignum.h:41:9
pub const MBEDTLS_MPI_MAX_LIMBS = @as(c_int, 10000);
pub const MBEDTLS_MPI_WINDOW_SIZE = @as(c_int, 3);
pub const MBEDTLS_MPI_MAX_SIZE = @as(c_int, 1024);
pub const MBEDTLS_MPI_MAX_BITS = @as(c_int, 8) * MBEDTLS_MPI_MAX_SIZE;
pub const MBEDTLS_MPI_MAX_BITS_SCALE100 = @as(c_int, 100) * MBEDTLS_MPI_MAX_BITS;
pub const MBEDTLS_LN_2_DIV_LN_10_SCALE100 = @as(c_int, 332);
pub const MBEDTLS_MPI_RW_BUFFER_SIZE = (__helpers.div((MBEDTLS_MPI_MAX_BITS_SCALE100 + MBEDTLS_LN_2_DIV_LN_10_SCALE100) - @as(c_int, 1), MBEDTLS_LN_2_DIV_LN_10_SCALE100) + @as(c_int, 10)) + @as(c_int, 6);
pub const MBEDTLS_HAVE_INT64 = "";
pub const MBEDTLS_MPI_UINT_MAX = UINT64_MAX;
pub const MBEDTLS_HAVE_UDBL = "";
pub const MBEDTLS_ECP_H = "";
pub const MBEDTLS_ERR_ECP_BAD_INPUT_DATA = -@as(c_int, 0x4F80);
pub const MBEDTLS_ERR_ECP_BUFFER_TOO_SMALL = -@as(c_int, 0x4F00);
pub const MBEDTLS_ERR_ECP_FEATURE_UNAVAILABLE = -@as(c_int, 0x4E80);
pub const MBEDTLS_ERR_ECP_VERIFY_FAILED = -@as(c_int, 0x4E00);
pub const MBEDTLS_ERR_ECP_ALLOC_FAILED = -@as(c_int, 0x4D80);
pub const MBEDTLS_ERR_ECP_RANDOM_FAILED = -@as(c_int, 0x4D00);
pub const MBEDTLS_ERR_ECP_INVALID_KEY = -@as(c_int, 0x4C80);
pub const MBEDTLS_ERR_ECP_SIG_LEN_MISMATCH = -@as(c_int, 0x4C00);
pub const MBEDTLS_ERR_ECP_IN_PROGRESS = -@as(c_int, 0x4B00);
pub const MBEDTLS_ECP_SHORT_WEIERSTRASS_ENABLED = "";
pub const MBEDTLS_ECP_MONTGOMERY_ENABLED = "";
pub const MBEDTLS_ECP_DP_MAX = @as(c_int, 14);
pub const MBEDTLS_ECP_WINDOW_SIZE = @as(c_int, 4);
pub const MBEDTLS_ECP_FIXED_POINT_OPTIM = @as(c_int, 1);
pub const MBEDTLS_ECP_MAX_BITS = @as(c_int, 521);
pub const MBEDTLS_ECP_MAX_BYTES = __helpers.div(MBEDTLS_ECP_MAX_BITS + @as(c_int, 7), @as(c_int, 8));
pub const MBEDTLS_ECP_MAX_PT_LEN = (@as(c_int, 2) * MBEDTLS_ECP_MAX_BYTES) + @as(c_int, 1);
pub inline fn MBEDTLS_ECP_BUDGET(ops: anytype) void {
    _ = &ops;
    return;
}
pub const MBEDTLS_ECP_PF_UNCOMPRESSED = @as(c_int, 0);
pub const MBEDTLS_ECP_PF_COMPRESSED = @as(c_int, 1);
pub const MBEDTLS_ECP_TLS_NAMED_CURVE = @as(c_int, 3);
pub const MBEDTLS_SSL_CIPHERSUITES_H = "";
pub const MBEDTLS_PK_H = "";
pub const MBEDTLS_MD_H = "";
pub const MBEDTLS_ERR_MD_FEATURE_UNAVAILABLE = -@as(c_int, 0x5080);
pub const MBEDTLS_ERR_MD_BAD_INPUT_DATA = -@as(c_int, 0x5100);
pub const MBEDTLS_ERR_MD_ALLOC_FAILED = -@as(c_int, 0x5180);
pub const MBEDTLS_ERR_MD_FILE_IO_ERROR = -@as(c_int, 0x5200);
pub const MBEDTLS_MD_MAX_SIZE = @as(c_int, 64);
pub const MBEDTLS_MD_MAX_BLOCK_SIZE = @as(c_int, 144);
pub const MBEDTLS_RSA_H = "";
pub const MBEDTLS_THREADING_H = "";
pub const __GLIBC_USE_LIB_EXT2 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = @as(c_int, 0);
pub const __need_wchar_t = "";
pub const _STDLIB_H = @as(c_int, 1);
pub const WNOHANG = @as(c_int, 1);
pub const WUNTRACED = @as(c_int, 2);
pub const WSTOPPED = @as(c_int, 2);
pub const WEXITED = @as(c_int, 4);
pub const WCONTINUED = @as(c_int, 8);
pub const WNOWAIT = __helpers.promoteIntLiteral(c_int, 0x01000000, .hex);
pub const __WNOTHREAD = __helpers.promoteIntLiteral(c_int, 0x20000000, .hex);
pub const __WALL = __helpers.promoteIntLiteral(c_int, 0x40000000, .hex);
pub const __WCLONE = __helpers.promoteIntLiteral(c_int, 0x80000000, .hex);
pub inline fn __WEXITSTATUS(status: anytype) @TypeOf((status & __helpers.promoteIntLiteral(c_int, 0xff00, .hex)) >> @as(c_int, 8)) {
    _ = &status;
    return (status & __helpers.promoteIntLiteral(c_int, 0xff00, .hex)) >> @as(c_int, 8);
}
pub inline fn __WTERMSIG(status: anytype) @TypeOf(status & @as(c_int, 0x7f)) {
    _ = &status;
    return status & @as(c_int, 0x7f);
}
pub inline fn __WSTOPSIG(status: anytype) @TypeOf(__WEXITSTATUS(status)) {
    _ = &status;
    return __WEXITSTATUS(status);
}
pub inline fn __WIFEXITED(status: anytype) @TypeOf(__WTERMSIG(status) == @as(c_int, 0)) {
    _ = &status;
    return __WTERMSIG(status) == @as(c_int, 0);
}
pub inline fn __WIFSIGNALED(status: anytype) @TypeOf((__helpers.cast(i8, (status & @as(c_int, 0x7f)) + @as(c_int, 1)) >> @as(c_int, 1)) > @as(c_int, 0)) {
    _ = &status;
    return (__helpers.cast(i8, (status & @as(c_int, 0x7f)) + @as(c_int, 1)) >> @as(c_int, 1)) > @as(c_int, 0);
}
pub inline fn __WIFSTOPPED(status: anytype) @TypeOf((status & @as(c_int, 0xff)) == @as(c_int, 0x7f)) {
    _ = &status;
    return (status & @as(c_int, 0xff)) == @as(c_int, 0x7f);
}
pub inline fn __WIFCONTINUED(status: anytype) @TypeOf(status == __W_CONTINUED) {
    _ = &status;
    return status == __W_CONTINUED;
}
pub inline fn __WCOREDUMP(status: anytype) @TypeOf(status & __WCOREFLAG) {
    _ = &status;
    return status & __WCOREFLAG;
}
pub inline fn __W_EXITCODE(ret: anytype, sig: anytype) @TypeOf((ret << @as(c_int, 8)) | sig) {
    _ = &ret;
    _ = &sig;
    return (ret << @as(c_int, 8)) | sig;
}
pub inline fn __W_STOPCODE(sig: anytype) @TypeOf((sig << @as(c_int, 8)) | @as(c_int, 0x7f)) {
    _ = &sig;
    return (sig << @as(c_int, 8)) | @as(c_int, 0x7f);
}
pub const __W_CONTINUED = __helpers.promoteIntLiteral(c_int, 0xffff, .hex);
pub const __WCOREFLAG = @as(c_int, 0x80);
pub inline fn WEXITSTATUS(status: anytype) @TypeOf(__WEXITSTATUS(status)) {
    _ = &status;
    return __WEXITSTATUS(status);
}
pub inline fn WTERMSIG(status: anytype) @TypeOf(__WTERMSIG(status)) {
    _ = &status;
    return __WTERMSIG(status);
}
pub inline fn WSTOPSIG(status: anytype) @TypeOf(__WSTOPSIG(status)) {
    _ = &status;
    return __WSTOPSIG(status);
}
pub inline fn WIFEXITED(status: anytype) @TypeOf(__WIFEXITED(status)) {
    _ = &status;
    return __WIFEXITED(status);
}
pub inline fn WIFSIGNALED(status: anytype) @TypeOf(__WIFSIGNALED(status)) {
    _ = &status;
    return __WIFSIGNALED(status);
}
pub inline fn WIFSTOPPED(status: anytype) @TypeOf(__WIFSTOPPED(status)) {
    _ = &status;
    return __WIFSTOPPED(status);
}
pub inline fn WIFCONTINUED(status: anytype) @TypeOf(__WIFCONTINUED(status)) {
    _ = &status;
    return __WIFCONTINUED(status);
}
pub const __ldiv_t_defined = @as(c_int, 1);
pub const __lldiv_t_defined = @as(c_int, 1);
pub const RAND_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const EXIT_FAILURE = @as(c_int, 1);
pub const EXIT_SUCCESS = @as(c_int, 0);
pub const MB_CUR_MAX = __ctype_get_mb_cur_max();
pub const _SYS_TYPES_H = @as(c_int, 1);
pub const __u_char_defined = "";
pub const __ino_t_defined = "";
pub const __dev_t_defined = "";
pub const __gid_t_defined = "";
pub const __mode_t_defined = "";
pub const __nlink_t_defined = "";
pub const __uid_t_defined = "";
pub const __id_t_defined = "";
pub const __daddr_t_defined = "";
pub const __key_t_defined = "";
pub const __BIT_TYPES_DEFINED__ = @as(c_int, 1);
pub const _ENDIAN_H = @as(c_int, 1);
pub const LITTLE_ENDIAN = __LITTLE_ENDIAN;
pub const BIG_ENDIAN = __BIG_ENDIAN;
pub const PDP_ENDIAN = __PDP_ENDIAN;
pub const BYTE_ORDER = __BYTE_ORDER;
pub const _BITS_BYTESWAP_H = @as(c_int, 1);
pub inline fn __bswap_constant_16(x: anytype) __uint16_t {
    _ = &x;
    return __helpers.cast(__uint16_t, ((x >> @as(c_int, 8)) & @as(c_int, 0xff)) | ((x & @as(c_int, 0xff)) << @as(c_int, 8)));
}
pub inline fn __bswap_constant_32(x: anytype) @TypeOf(((((x & __helpers.promoteIntLiteral(c_uint, 0xff000000, .hex)) >> @as(c_int, 24)) | ((x & __helpers.promoteIntLiteral(c_uint, 0x00ff0000, .hex)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24))) {
    _ = &x;
    return ((((x & __helpers.promoteIntLiteral(c_uint, 0xff000000, .hex)) >> @as(c_int, 24)) | ((x & __helpers.promoteIntLiteral(c_uint, 0x00ff0000, .hex)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24));
}
pub inline fn __bswap_constant_64(x: anytype) @TypeOf(((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56))) {
    _ = &x;
    return ((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56));
}
pub const _BITS_UINTN_IDENTITY_H = @as(c_int, 1);
pub inline fn htobe16(x: anytype) @TypeOf(__bswap_16(x)) {
    _ = &x;
    return __bswap_16(x);
}
pub inline fn htole16(x: anytype) @TypeOf(__uint16_identity(x)) {
    _ = &x;
    return __uint16_identity(x);
}
pub inline fn be16toh(x: anytype) @TypeOf(__bswap_16(x)) {
    _ = &x;
    return __bswap_16(x);
}
pub inline fn le16toh(x: anytype) @TypeOf(__uint16_identity(x)) {
    _ = &x;
    return __uint16_identity(x);
}
pub inline fn htobe32(x: anytype) @TypeOf(__bswap_32(x)) {
    _ = &x;
    return __bswap_32(x);
}
pub inline fn htole32(x: anytype) @TypeOf(__uint32_identity(x)) {
    _ = &x;
    return __uint32_identity(x);
}
pub inline fn be32toh(x: anytype) @TypeOf(__bswap_32(x)) {
    _ = &x;
    return __bswap_32(x);
}
pub inline fn le32toh(x: anytype) @TypeOf(__uint32_identity(x)) {
    _ = &x;
    return __uint32_identity(x);
}
pub inline fn htobe64(x: anytype) @TypeOf(__bswap_64(x)) {
    _ = &x;
    return __bswap_64(x);
}
pub inline fn htole64(x: anytype) @TypeOf(__uint64_identity(x)) {
    _ = &x;
    return __uint64_identity(x);
}
pub inline fn be64toh(x: anytype) @TypeOf(__bswap_64(x)) {
    _ = &x;
    return __bswap_64(x);
}
pub inline fn le64toh(x: anytype) @TypeOf(__uint64_identity(x)) {
    _ = &x;
    return __uint64_identity(x);
}
pub const _SYS_SELECT_H = @as(c_int, 1);
pub const __FD_ZERO = @compileError("unable to translate macro: undefined identifier `__i`"); // /usr/include/bits/select.h:25:9
pub const __FD_SET = @compileError("unable to translate C expr: expected ')' instead got '|='"); // /usr/include/bits/select.h:32:9
pub const __FD_CLR = @compileError("unable to translate C expr: expected ')' instead got '&='"); // /usr/include/bits/select.h:34:9
pub inline fn __FD_ISSET(d: anytype, s: anytype) @TypeOf((__FDS_BITS(s)[@as(usize, @intCast(__FD_ELT(d)))] & __FD_MASK(d)) != @as(c_int, 0)) {
    _ = &d;
    _ = &s;
    return (__FDS_BITS(s)[@as(usize, @intCast(__FD_ELT(d)))] & __FD_MASK(d)) != @as(c_int, 0);
}
pub const __sigset_t_defined = @as(c_int, 1);
pub const ____sigset_t_defined = "";
pub const _SIGSET_NWORDS = __helpers.div(@as(c_int, 1024), @as(c_int, 8) * __helpers.sizeof(c_ulong));
pub const __timeval_defined = @as(c_int, 1);
pub const __suseconds_t_defined = "";
pub const __NFDBITS = @as(c_int, 8) * __helpers.cast(c_int, __helpers.sizeof(__fd_mask));
pub inline fn __FD_ELT(d: anytype) @TypeOf(__helpers.div(d, __NFDBITS)) {
    _ = &d;
    return __helpers.div(d, __NFDBITS);
}
pub inline fn __FD_MASK(d: anytype) __fd_mask {
    _ = &d;
    return __helpers.cast(__fd_mask, @as(c_ulong, 1) << __helpers.rem(d, __NFDBITS));
}
pub inline fn __FDS_BITS(set: anytype) @TypeOf(set.*.__fds_bits) {
    _ = &set;
    return set.*.__fds_bits;
}
pub const FD_SETSIZE = __FD_SETSIZE;
pub const NFDBITS = __NFDBITS;
pub inline fn FD_SET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_SET(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_SET(fd, fdsetp);
}
pub inline fn FD_CLR(fd: anytype, fdsetp: anytype) @TypeOf(__FD_CLR(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_CLR(fd, fdsetp);
}
pub inline fn FD_ISSET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_ISSET(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_ISSET(fd, fdsetp);
}
pub inline fn FD_ZERO(fdsetp: anytype) @TypeOf(__FD_ZERO(fdsetp)) {
    _ = &fdsetp;
    return __FD_ZERO(fdsetp);
}
pub const __blksize_t_defined = "";
pub const __blkcnt_t_defined = "";
pub const __fsblkcnt_t_defined = "";
pub const __fsfilcnt_t_defined = "";
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
pub const __have_pthread_attr_t = @as(c_int, 1);
pub const _ALLOCA_H = @as(c_int, 1);
pub const __COMPAR_FN_T = "";
pub const MBEDTLS_ERR_THREADING_BAD_INPUT_DATA = -@as(c_int, 0x001C);
pub const MBEDTLS_ERR_THREADING_MUTEX_ERROR = -@as(c_int, 0x001E);
pub const _PTHREAD_H = @as(c_int, 1);
pub const _SCHED_H = @as(c_int, 1);
pub const _BITS_SCHED_H = @as(c_int, 1);
pub const SCHED_OTHER = @as(c_int, 0);
pub const SCHED_FIFO = @as(c_int, 1);
pub const SCHED_RR = @as(c_int, 2);
pub const _BITS_TYPES_STRUCT_SCHED_PARAM = @as(c_int, 1);
pub const _BITS_CPU_SET_H = @as(c_int, 1);
pub const __CPU_SETSIZE = @as(c_int, 1024);
pub const __NCPUBITS = @as(c_int, 8) * __helpers.sizeof(__cpu_mask);
pub inline fn __CPUELT(cpu: anytype) @TypeOf(__helpers.div(cpu, __NCPUBITS)) {
    _ = &cpu;
    return __helpers.div(cpu, __NCPUBITS);
}
pub inline fn __CPUMASK(cpu: anytype) @TypeOf(__helpers.cast(__cpu_mask, @as(c_int, 1)) << __helpers.rem(cpu, __NCPUBITS)) {
    _ = &cpu;
    return __helpers.cast(__cpu_mask, @as(c_int, 1)) << __helpers.rem(cpu, __NCPUBITS);
}
pub const __CPU_ZERO_S = @compileError("unable to translate C expr: unexpected token 'do'"); // /usr/include/bits/cpu-set.h:46:10
pub const __CPU_SET_S = @compileError("unable to translate macro: undefined identifier `__cpu`"); // /usr/include/bits/cpu-set.h:58:9
pub const __CPU_CLR_S = @compileError("unable to translate macro: undefined identifier `__cpu`"); // /usr/include/bits/cpu-set.h:65:9
pub const __CPU_ISSET_S = @compileError("unable to translate macro: undefined identifier `__cpu`"); // /usr/include/bits/cpu-set.h:72:9
pub inline fn __CPU_COUNT_S(setsize: anytype, cpusetp: anytype) @TypeOf(__sched_cpucount(setsize, cpusetp)) {
    _ = &setsize;
    _ = &cpusetp;
    return __sched_cpucount(setsize, cpusetp);
}
pub const __CPU_EQUAL_S = @compileError("unable to translate macro: undefined identifier `__builtin_memcmp`"); // /usr/include/bits/cpu-set.h:84:10
pub const __CPU_OP_S = @compileError("unable to translate macro: undefined identifier `__dest`"); // /usr/include/bits/cpu-set.h:99:9
pub inline fn __CPU_ALLOC_SIZE(count: anytype) @TypeOf(__helpers.div((count + __NCPUBITS) - @as(c_int, 1), __NCPUBITS) * __helpers.sizeof(__cpu_mask)) {
    _ = &count;
    return __helpers.div((count + __NCPUBITS) - @as(c_int, 1), __NCPUBITS) * __helpers.sizeof(__cpu_mask);
}
pub inline fn __CPU_ALLOC(count: anytype) @TypeOf(__sched_cpualloc(count)) {
    _ = &count;
    return __sched_cpualloc(count);
}
pub inline fn __CPU_FREE(cpuset: anytype) @TypeOf(__sched_cpufree(cpuset)) {
    _ = &cpuset;
    return __sched_cpufree(cpuset);
}
pub const sched_priority = @compileError("unable to translate macro: undefined identifier `sched_priority`"); // /usr/include/sched.h:47:9
pub const __sched_priority = sched_priority;
pub const _BITS_SETJMP_H = @as(c_int, 1);
pub const __jmp_buf_tag_defined = @as(c_int, 1);
pub const PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/pthread.h:90:9
pub const PTHREAD_RWLOCK_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/pthread.h:114:10
pub const PTHREAD_COND_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/pthread.h:155:9
pub const PTHREAD_CANCELED = __helpers.cast(?*anyopaque, -@as(c_int, 1));
pub const PTHREAD_ONCE_INIT = @as(c_int, 0);
pub const PTHREAD_BARRIER_SERIAL_THREAD = -@as(c_int, 1);
pub const __cleanup_fct_attribute = "";
pub const pthread_cleanup_push = @compileError("unable to translate macro: undefined identifier `__cancel_buf`"); // /usr/include/pthread.h:681:10
pub const pthread_cleanup_pop = @compileError("unable to translate macro: undefined identifier `__cancel_buf`"); // /usr/include/pthread.h:702:10
pub inline fn __sigsetjmp_cancel(env: anytype, savemask: anytype) @TypeOf(__sigsetjmp(__helpers.cast([*c]struct___jmp_buf_tag, __helpers.cast(?*anyopaque, env)), savemask)) {
    _ = &env;
    _ = &savemask;
    return __sigsetjmp(__helpers.cast([*c]struct___jmp_buf_tag, __helpers.cast(?*anyopaque, env)), savemask);
}
pub const MBEDTLS_ERR_RSA_BAD_INPUT_DATA = -@as(c_int, 0x4080);
pub const MBEDTLS_ERR_RSA_INVALID_PADDING = -@as(c_int, 0x4100);
pub const MBEDTLS_ERR_RSA_KEY_GEN_FAILED = -@as(c_int, 0x4180);
pub const MBEDTLS_ERR_RSA_KEY_CHECK_FAILED = -@as(c_int, 0x4200);
pub const MBEDTLS_ERR_RSA_PUBLIC_FAILED = -@as(c_int, 0x4280);
pub const MBEDTLS_ERR_RSA_PRIVATE_FAILED = -@as(c_int, 0x4300);
pub const MBEDTLS_ERR_RSA_VERIFY_FAILED = -@as(c_int, 0x4380);
pub const MBEDTLS_ERR_RSA_OUTPUT_TOO_LARGE = -@as(c_int, 0x4400);
pub const MBEDTLS_ERR_RSA_RNG_FAILED = -@as(c_int, 0x4480);
pub const MBEDTLS_RSA_PKCS_V15 = @as(c_int, 0);
pub const MBEDTLS_RSA_PKCS_V21 = @as(c_int, 1);
pub const MBEDTLS_RSA_SIGN = @as(c_int, 1);
pub const MBEDTLS_RSA_CRYPT = @as(c_int, 2);
pub const MBEDTLS_RSA_SALT_LEN_ANY = -@as(c_int, 1);
pub const MBEDTLS_RSA_GEN_KEY_MIN_BITS = @as(c_int, 1024);
pub const MBEDTLS_ECDSA_H = "";
pub inline fn MBEDTLS_ECDSA_MAX_SIG_LEN(bits: anytype) @TypeOf((if (bits >= (@as(c_int, 61) * @as(c_int, 8))) @as(c_int, 3) else @as(c_int, 2)) + (@as(c_int, 2) * ((if (bits >= (@as(c_int, 127) * @as(c_int, 8))) @as(c_int, 3) else @as(c_int, 2)) + __helpers.div(bits + @as(c_int, 8), @as(c_int, 8))))) {
    _ = &bits;
    return (if (bits >= (@as(c_int, 61) * @as(c_int, 8))) @as(c_int, 3) else @as(c_int, 2)) + (@as(c_int, 2) * ((if (bits >= (@as(c_int, 127) * @as(c_int, 8))) @as(c_int, 3) else @as(c_int, 2)) + __helpers.div(bits + @as(c_int, 8), @as(c_int, 8))));
}
pub const MBEDTLS_ECDSA_MAX_LEN = MBEDTLS_ECDSA_MAX_SIG_LEN(MBEDTLS_ECP_MAX_BITS);
pub const PSA_CRYPTO_H = "";
pub const PSA_CRYPTO_PLATFORM_H = "";
pub const PSA_CRYPTO_BUILD_INFO_H = "";
pub const PSA_CRYPTO_TYPES_H = "";
pub const PSA_CRYPTO_API_VERSION_MAJOR = @as(c_int, 1);
pub const PSA_CRYPTO_API_VERSION_MINOR = @as(c_int, 0);
pub const PSA_CRYPTO_VALUES_H = "";
pub const PSA_SUCCESS = __helpers.cast(psa_status_t, @as(c_int, 0));
pub const PSA_ERROR_GENERIC_ERROR = __helpers.cast(psa_status_t, -@as(c_int, 132));
pub const PSA_ERROR_NOT_SUPPORTED = __helpers.cast(psa_status_t, -@as(c_int, 134));
pub const PSA_ERROR_NOT_PERMITTED = __helpers.cast(psa_status_t, -@as(c_int, 133));
pub const PSA_ERROR_BUFFER_TOO_SMALL = __helpers.cast(psa_status_t, -@as(c_int, 138));
pub const PSA_ERROR_ALREADY_EXISTS = __helpers.cast(psa_status_t, -@as(c_int, 139));
pub const PSA_ERROR_DOES_NOT_EXIST = __helpers.cast(psa_status_t, -@as(c_int, 140));
pub const PSA_ERROR_BAD_STATE = __helpers.cast(psa_status_t, -@as(c_int, 137));
pub const PSA_ERROR_INVALID_ARGUMENT = __helpers.cast(psa_status_t, -@as(c_int, 135));
pub const PSA_ERROR_INSUFFICIENT_MEMORY = __helpers.cast(psa_status_t, -@as(c_int, 141));
pub const PSA_ERROR_INSUFFICIENT_STORAGE = __helpers.cast(psa_status_t, -@as(c_int, 142));
pub const PSA_ERROR_COMMUNICATION_FAILURE = __helpers.cast(psa_status_t, -@as(c_int, 145));
pub const PSA_ERROR_STORAGE_FAILURE = __helpers.cast(psa_status_t, -@as(c_int, 146));
pub const PSA_ERROR_HARDWARE_FAILURE = __helpers.cast(psa_status_t, -@as(c_int, 147));
pub const PSA_ERROR_CORRUPTION_DETECTED = __helpers.cast(psa_status_t, -@as(c_int, 151));
pub const PSA_ERROR_INSUFFICIENT_ENTROPY = __helpers.cast(psa_status_t, -@as(c_int, 148));
pub const PSA_ERROR_INVALID_SIGNATURE = __helpers.cast(psa_status_t, -@as(c_int, 149));
pub const PSA_ERROR_INVALID_PADDING = __helpers.cast(psa_status_t, -@as(c_int, 150));
pub const PSA_ERROR_INSUFFICIENT_DATA = __helpers.cast(psa_status_t, -@as(c_int, 143));
pub const PSA_ERROR_SERVICE_FAILURE = __helpers.cast(psa_status_t, -@as(c_int, 144));
pub const PSA_ERROR_INVALID_HANDLE = __helpers.cast(psa_status_t, -@as(c_int, 136));
pub const PSA_ERROR_DATA_CORRUPT = __helpers.cast(psa_status_t, -@as(c_int, 152));
pub const PSA_ERROR_DATA_INVALID = __helpers.cast(psa_status_t, -@as(c_int, 153));
pub const PSA_OPERATION_INCOMPLETE = __helpers.cast(psa_status_t, -@as(c_int, 248));
pub const PSA_KEY_TYPE_NONE = __helpers.cast(psa_key_type_t, @as(c_int, 0x0000));
pub const PSA_KEY_TYPE_VENDOR_FLAG = __helpers.cast(psa_key_type_t, __helpers.promoteIntLiteral(c_int, 0x8000, .hex));
pub const PSA_KEY_TYPE_CATEGORY_MASK = __helpers.cast(psa_key_type_t, @as(c_int, 0x7000));
pub const PSA_KEY_TYPE_CATEGORY_RAW = __helpers.cast(psa_key_type_t, @as(c_int, 0x1000));
pub const PSA_KEY_TYPE_CATEGORY_SYMMETRIC = __helpers.cast(psa_key_type_t, @as(c_int, 0x2000));
pub const PSA_KEY_TYPE_CATEGORY_PUBLIC_KEY = __helpers.cast(psa_key_type_t, @as(c_int, 0x4000));
pub const PSA_KEY_TYPE_CATEGORY_KEY_PAIR = __helpers.cast(psa_key_type_t, @as(c_int, 0x7000));
pub const PSA_KEY_TYPE_CATEGORY_FLAG_PAIR = __helpers.cast(psa_key_type_t, @as(c_int, 0x3000));
pub inline fn PSA_KEY_TYPE_IS_VENDOR_DEFINED(@"type": anytype) @TypeOf((@"type" & PSA_KEY_TYPE_VENDOR_FLAG) != @as(c_int, 0)) {
    _ = &@"type";
    return (@"type" & PSA_KEY_TYPE_VENDOR_FLAG) != @as(c_int, 0);
}
pub inline fn PSA_KEY_TYPE_IS_UNSTRUCTURED(@"type": anytype) @TypeOf(((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_RAW) or ((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_SYMMETRIC)) {
    _ = &@"type";
    return ((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_RAW) or ((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_SYMMETRIC);
}
pub inline fn PSA_KEY_TYPE_IS_ASYMMETRIC(@"type": anytype) @TypeOf(((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) & ~PSA_KEY_TYPE_CATEGORY_FLAG_PAIR) == PSA_KEY_TYPE_CATEGORY_PUBLIC_KEY) {
    _ = &@"type";
    return ((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) & ~PSA_KEY_TYPE_CATEGORY_FLAG_PAIR) == PSA_KEY_TYPE_CATEGORY_PUBLIC_KEY;
}
pub inline fn PSA_KEY_TYPE_IS_PUBLIC_KEY(@"type": anytype) @TypeOf((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_PUBLIC_KEY) {
    _ = &@"type";
    return (@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_PUBLIC_KEY;
}
pub inline fn PSA_KEY_TYPE_IS_KEY_PAIR(@"type": anytype) @TypeOf((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_KEY_PAIR) {
    _ = &@"type";
    return (@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_KEY_PAIR;
}
pub inline fn PSA_KEY_TYPE_KEY_PAIR_OF_PUBLIC_KEY(@"type": anytype) @TypeOf(@"type" | PSA_KEY_TYPE_CATEGORY_FLAG_PAIR) {
    _ = &@"type";
    return @"type" | PSA_KEY_TYPE_CATEGORY_FLAG_PAIR;
}
pub inline fn PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type": anytype) @TypeOf(@"type" & ~PSA_KEY_TYPE_CATEGORY_FLAG_PAIR) {
    _ = &@"type";
    return @"type" & ~PSA_KEY_TYPE_CATEGORY_FLAG_PAIR;
}
pub const PSA_KEY_TYPE_RAW_DATA = __helpers.cast(psa_key_type_t, @as(c_int, 0x1001));
pub const PSA_KEY_TYPE_HMAC = __helpers.cast(psa_key_type_t, @as(c_int, 0x1100));
pub const PSA_KEY_TYPE_DERIVE = __helpers.cast(psa_key_type_t, @as(c_int, 0x1200));
pub const PSA_KEY_TYPE_PASSWORD = __helpers.cast(psa_key_type_t, @as(c_int, 0x1203));
pub const PSA_KEY_TYPE_PASSWORD_HASH = __helpers.cast(psa_key_type_t, @as(c_int, 0x1205));
pub const PSA_KEY_TYPE_PEPPER = __helpers.cast(psa_key_type_t, @as(c_int, 0x1206));
pub const PSA_KEY_TYPE_AES = __helpers.cast(psa_key_type_t, @as(c_int, 0x2400));
pub const PSA_KEY_TYPE_ARIA = __helpers.cast(psa_key_type_t, @as(c_int, 0x2406));
pub const PSA_KEY_TYPE_DES = __helpers.cast(psa_key_type_t, @as(c_int, 0x2301));
pub const PSA_KEY_TYPE_CAMELLIA = __helpers.cast(psa_key_type_t, @as(c_int, 0x2403));
pub const PSA_KEY_TYPE_CHACHA20 = __helpers.cast(psa_key_type_t, @as(c_int, 0x2004));
pub const PSA_KEY_TYPE_RSA_PUBLIC_KEY = __helpers.cast(psa_key_type_t, @as(c_int, 0x4001));
pub const PSA_KEY_TYPE_RSA_KEY_PAIR = __helpers.cast(psa_key_type_t, @as(c_int, 0x7001));
pub inline fn PSA_KEY_TYPE_IS_RSA(@"type": anytype) @TypeOf(PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") == PSA_KEY_TYPE_RSA_PUBLIC_KEY) {
    _ = &@"type";
    return PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") == PSA_KEY_TYPE_RSA_PUBLIC_KEY;
}
pub const PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE = __helpers.cast(psa_key_type_t, @as(c_int, 0x4100));
pub const PSA_KEY_TYPE_ECC_KEY_PAIR_BASE = __helpers.cast(psa_key_type_t, @as(c_int, 0x7100));
pub const PSA_KEY_TYPE_ECC_CURVE_MASK = __helpers.cast(psa_key_type_t, @as(c_int, 0x00ff));
pub inline fn PSA_KEY_TYPE_ECC_KEY_PAIR(curve: anytype) @TypeOf(PSA_KEY_TYPE_ECC_KEY_PAIR_BASE | curve) {
    _ = &curve;
    return PSA_KEY_TYPE_ECC_KEY_PAIR_BASE | curve;
}
pub inline fn PSA_KEY_TYPE_ECC_PUBLIC_KEY(curve: anytype) @TypeOf(PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE | curve) {
    _ = &curve;
    return PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE | curve;
}
pub inline fn PSA_KEY_TYPE_IS_ECC(@"type": anytype) @TypeOf((PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") & ~PSA_KEY_TYPE_ECC_CURVE_MASK) == PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE) {
    _ = &@"type";
    return (PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") & ~PSA_KEY_TYPE_ECC_CURVE_MASK) == PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE;
}
pub inline fn PSA_KEY_TYPE_IS_ECC_KEY_PAIR(@"type": anytype) @TypeOf((@"type" & ~PSA_KEY_TYPE_ECC_CURVE_MASK) == PSA_KEY_TYPE_ECC_KEY_PAIR_BASE) {
    _ = &@"type";
    return (@"type" & ~PSA_KEY_TYPE_ECC_CURVE_MASK) == PSA_KEY_TYPE_ECC_KEY_PAIR_BASE;
}
pub inline fn PSA_KEY_TYPE_IS_ECC_PUBLIC_KEY(@"type": anytype) @TypeOf((@"type" & ~PSA_KEY_TYPE_ECC_CURVE_MASK) == PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE) {
    _ = &@"type";
    return (@"type" & ~PSA_KEY_TYPE_ECC_CURVE_MASK) == PSA_KEY_TYPE_ECC_PUBLIC_KEY_BASE;
}
pub inline fn PSA_KEY_TYPE_ECC_GET_FAMILY(@"type": anytype) psa_ecc_family_t {
    _ = &@"type";
    return __helpers.cast(psa_ecc_family_t, if (PSA_KEY_TYPE_IS_ECC(@"type")) @"type" & PSA_KEY_TYPE_ECC_CURVE_MASK else @as(c_int, 0));
}
pub inline fn PSA_ECC_FAMILY_IS_WEIERSTRASS(family: anytype) @TypeOf((family & @as(c_int, 0xc0)) == @as(c_int, 0)) {
    _ = &family;
    return (family & @as(c_int, 0xc0)) == @as(c_int, 0);
}
pub const PSA_ECC_FAMILY_SECP_K1 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x17));
pub const PSA_ECC_FAMILY_SECP_R1 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x12));
pub const PSA_ECC_FAMILY_SECP_R2 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x1b));
pub const PSA_ECC_FAMILY_SECT_K1 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x27));
pub const PSA_ECC_FAMILY_SECT_R1 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x22));
pub const PSA_ECC_FAMILY_SECT_R2 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x2b));
pub const PSA_ECC_FAMILY_BRAINPOOL_P_R1 = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x30));
pub const PSA_ECC_FAMILY_MONTGOMERY = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x41));
pub const PSA_ECC_FAMILY_TWISTED_EDWARDS = __helpers.cast(psa_ecc_family_t, @as(c_int, 0x42));
pub const PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE = __helpers.cast(psa_key_type_t, @as(c_int, 0x4200));
pub const PSA_KEY_TYPE_DH_KEY_PAIR_BASE = __helpers.cast(psa_key_type_t, @as(c_int, 0x7200));
pub const PSA_KEY_TYPE_DH_GROUP_MASK = __helpers.cast(psa_key_type_t, @as(c_int, 0x00ff));
pub inline fn PSA_KEY_TYPE_DH_KEY_PAIR(group: anytype) @TypeOf(PSA_KEY_TYPE_DH_KEY_PAIR_BASE | group) {
    _ = &group;
    return PSA_KEY_TYPE_DH_KEY_PAIR_BASE | group;
}
pub inline fn PSA_KEY_TYPE_DH_PUBLIC_KEY(group: anytype) @TypeOf(PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE | group) {
    _ = &group;
    return PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE | group;
}
pub inline fn PSA_KEY_TYPE_IS_DH(@"type": anytype) @TypeOf((PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") & ~PSA_KEY_TYPE_DH_GROUP_MASK) == PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE) {
    _ = &@"type";
    return (PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") & ~PSA_KEY_TYPE_DH_GROUP_MASK) == PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE;
}
pub inline fn PSA_KEY_TYPE_IS_DH_KEY_PAIR(@"type": anytype) @TypeOf((@"type" & ~PSA_KEY_TYPE_DH_GROUP_MASK) == PSA_KEY_TYPE_DH_KEY_PAIR_BASE) {
    _ = &@"type";
    return (@"type" & ~PSA_KEY_TYPE_DH_GROUP_MASK) == PSA_KEY_TYPE_DH_KEY_PAIR_BASE;
}
pub inline fn PSA_KEY_TYPE_IS_DH_PUBLIC_KEY(@"type": anytype) @TypeOf((@"type" & ~PSA_KEY_TYPE_DH_GROUP_MASK) == PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE) {
    _ = &@"type";
    return (@"type" & ~PSA_KEY_TYPE_DH_GROUP_MASK) == PSA_KEY_TYPE_DH_PUBLIC_KEY_BASE;
}
pub inline fn PSA_KEY_TYPE_DH_GET_FAMILY(@"type": anytype) psa_dh_family_t {
    _ = &@"type";
    return __helpers.cast(psa_dh_family_t, if (PSA_KEY_TYPE_IS_DH(@"type")) @"type" & PSA_KEY_TYPE_DH_GROUP_MASK else @as(c_int, 0));
}
pub const PSA_DH_FAMILY_RFC7919 = __helpers.cast(psa_dh_family_t, @as(c_int, 0x03));
pub inline fn PSA_GET_KEY_TYPE_BLOCK_SIZE_EXPONENT(@"type": anytype) @TypeOf((@"type" >> @as(c_int, 8)) & @as(c_int, 7)) {
    _ = &@"type";
    return (@"type" >> @as(c_int, 8)) & @as(c_int, 7);
}
pub inline fn PSA_BLOCK_CIPHER_BLOCK_LENGTH(@"type": anytype) @TypeOf(if ((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_SYMMETRIC) @as(c_uint, 1) << PSA_GET_KEY_TYPE_BLOCK_SIZE_EXPONENT(@"type") else @as(c_uint, 0)) {
    _ = &@"type";
    return if ((@"type" & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_SYMMETRIC) @as(c_uint, 1) << PSA_GET_KEY_TYPE_BLOCK_SIZE_EXPONENT(@"type") else @as(c_uint, 0);
}
pub const PSA_ALG_VENDOR_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x80000000, .hex));
pub const PSA_ALG_CATEGORY_MASK = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x7f000000, .hex));
pub const PSA_ALG_CATEGORY_HASH = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000000, .hex));
pub const PSA_ALG_CATEGORY_MAC = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x03000000, .hex));
pub const PSA_ALG_CATEGORY_CIPHER = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04000000, .hex));
pub const PSA_ALG_CATEGORY_AEAD = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x05000000, .hex));
pub const PSA_ALG_CATEGORY_SIGN = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000000, .hex));
pub const PSA_ALG_CATEGORY_ASYMMETRIC_ENCRYPTION = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x07000000, .hex));
pub const PSA_ALG_CATEGORY_KEY_DERIVATION = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000000, .hex));
pub const PSA_ALG_CATEGORY_KEY_AGREEMENT = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x09000000, .hex));
pub inline fn PSA_ALG_IS_VENDOR_DEFINED(alg: anytype) @TypeOf((alg & PSA_ALG_VENDOR_FLAG) != @as(c_int, 0)) {
    _ = &alg;
    return (alg & PSA_ALG_VENDOR_FLAG) != @as(c_int, 0);
}
pub inline fn PSA_ALG_IS_HASH(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_HASH) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_HASH;
}
pub inline fn PSA_ALG_IS_MAC(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_MAC) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_MAC;
}
pub inline fn PSA_ALG_IS_CIPHER(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_CIPHER) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_CIPHER;
}
pub inline fn PSA_ALG_IS_AEAD(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_AEAD) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_AEAD;
}
pub inline fn PSA_ALG_IS_SIGN(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_SIGN) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_SIGN;
}
pub inline fn PSA_ALG_IS_ASYMMETRIC_ENCRYPTION(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_ASYMMETRIC_ENCRYPTION) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_ASYMMETRIC_ENCRYPTION;
}
pub inline fn PSA_ALG_IS_KEY_AGREEMENT(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_KEY_AGREEMENT) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_KEY_AGREEMENT;
}
pub inline fn PSA_ALG_IS_KEY_DERIVATION(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_KEY_DERIVATION) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_KEY_DERIVATION;
}
pub inline fn PSA_ALG_IS_KEY_DERIVATION_STRETCHING(alg: anytype) @TypeOf((PSA_ALG_IS_KEY_DERIVATION(alg) != 0) and ((alg & PSA_ALG_KEY_DERIVATION_STRETCHING_FLAG) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_KEY_DERIVATION(alg) != 0) and ((alg & PSA_ALG_KEY_DERIVATION_STRETCHING_FLAG) != 0);
}
pub const PSA_ALG_NONE = __helpers.cast(psa_algorithm_t, @as(c_int, 0));
pub const PSA_ALG_HASH_MASK = __helpers.cast(psa_algorithm_t, @as(c_int, 0x000000ff));
pub const PSA_ALG_MD5 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000003, .hex));
pub const PSA_ALG_RIPEMD160 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000004, .hex));
pub const PSA_ALG_SHA_1 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000005, .hex));
pub const PSA_ALG_SHA_224 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000008, .hex));
pub const PSA_ALG_SHA_256 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000009, .hex));
pub const PSA_ALG_SHA_384 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0200000a, .hex));
pub const PSA_ALG_SHA_512 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0200000b, .hex));
pub const PSA_ALG_SHA_512_224 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0200000c, .hex));
pub const PSA_ALG_SHA_512_256 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0200000d, .hex));
pub const PSA_ALG_SHA3_224 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000010, .hex));
pub const PSA_ALG_SHA3_256 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000011, .hex));
pub const PSA_ALG_SHA3_384 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000012, .hex));
pub const PSA_ALG_SHA3_512 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000013, .hex));
pub const PSA_ALG_SHAKE256_512 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x02000015, .hex));
pub const PSA_ALG_ANY_HASH = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x020000ff, .hex));
pub const PSA_ALG_MAC_SUBCATEGORY_MASK = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00c00000, .hex));
pub const PSA_ALG_HMAC_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x03800000, .hex));
pub inline fn PSA_ALG_HMAC(hash_alg: anytype) @TypeOf(PSA_ALG_HMAC_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_HMAC_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_HMAC_GET_HASH(hmac_alg: anytype) @TypeOf(PSA_ALG_CATEGORY_HASH | (hmac_alg & PSA_ALG_HASH_MASK)) {
    _ = &hmac_alg;
    return PSA_ALG_CATEGORY_HASH | (hmac_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_HMAC(alg: anytype) @TypeOf((alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_MAC_SUBCATEGORY_MASK)) == PSA_ALG_HMAC_BASE) {
    _ = &alg;
    return (alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_MAC_SUBCATEGORY_MASK)) == PSA_ALG_HMAC_BASE;
}
pub const PSA_ALG_MAC_TRUNCATION_MASK = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x003f0000, .hex));
pub const PSA_MAC_TRUNCATION_OFFSET = @as(c_int, 16);
pub const PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00008000, .hex));
pub inline fn PSA_ALG_TRUNCATED_MAC(mac_alg: anytype, mac_length: anytype) @TypeOf((mac_alg & ~(PSA_ALG_MAC_TRUNCATION_MASK | PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG)) | ((mac_length << PSA_MAC_TRUNCATION_OFFSET) & PSA_ALG_MAC_TRUNCATION_MASK)) {
    _ = &mac_alg;
    _ = &mac_length;
    return (mac_alg & ~(PSA_ALG_MAC_TRUNCATION_MASK | PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG)) | ((mac_length << PSA_MAC_TRUNCATION_OFFSET) & PSA_ALG_MAC_TRUNCATION_MASK);
}
pub inline fn PSA_ALG_FULL_LENGTH_MAC(mac_alg: anytype) @TypeOf(mac_alg & ~(PSA_ALG_MAC_TRUNCATION_MASK | PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG)) {
    _ = &mac_alg;
    return mac_alg & ~(PSA_ALG_MAC_TRUNCATION_MASK | PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG);
}
pub inline fn PSA_MAC_TRUNCATED_LENGTH(mac_alg: anytype) @TypeOf((mac_alg & PSA_ALG_MAC_TRUNCATION_MASK) >> PSA_MAC_TRUNCATION_OFFSET) {
    _ = &mac_alg;
    return (mac_alg & PSA_ALG_MAC_TRUNCATION_MASK) >> PSA_MAC_TRUNCATION_OFFSET;
}
pub inline fn PSA_ALG_AT_LEAST_THIS_LENGTH_MAC(mac_alg: anytype, min_mac_length: anytype) @TypeOf(PSA_ALG_TRUNCATED_MAC(mac_alg, min_mac_length) | PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG) {
    _ = &mac_alg;
    _ = &min_mac_length;
    return PSA_ALG_TRUNCATED_MAC(mac_alg, min_mac_length) | PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG;
}
pub const PSA_ALG_CIPHER_MAC_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x03c00000, .hex));
pub const PSA_ALG_CBC_MAC = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x03c00100, .hex));
pub const PSA_ALG_CMAC = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x03c00200, .hex));
pub inline fn PSA_ALG_IS_BLOCK_CIPHER_MAC(alg: anytype) @TypeOf((alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_MAC_SUBCATEGORY_MASK)) == PSA_ALG_CIPHER_MAC_BASE) {
    _ = &alg;
    return (alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_MAC_SUBCATEGORY_MASK)) == PSA_ALG_CIPHER_MAC_BASE;
}
pub const PSA_ALG_CIPHER_STREAM_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00800000, .hex));
pub const PSA_ALG_CIPHER_FROM_BLOCK_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00400000, .hex));
pub inline fn PSA_ALG_IS_STREAM_CIPHER(alg: anytype) @TypeOf((alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_CIPHER_STREAM_FLAG)) == (PSA_ALG_CATEGORY_CIPHER | PSA_ALG_CIPHER_STREAM_FLAG)) {
    _ = &alg;
    return (alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_CIPHER_STREAM_FLAG)) == (PSA_ALG_CATEGORY_CIPHER | PSA_ALG_CIPHER_STREAM_FLAG);
}
pub const PSA_ALG_STREAM_CIPHER = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04800100, .hex));
pub const PSA_ALG_CTR = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04c01000, .hex));
pub const PSA_ALG_CFB = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04c01100, .hex));
pub const PSA_ALG_OFB = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04c01200, .hex));
pub const PSA_ALG_XTS = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0440ff00, .hex));
pub const PSA_ALG_ECB_NO_PADDING = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04404400, .hex));
pub const PSA_ALG_CBC_NO_PADDING = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04404000, .hex));
pub const PSA_ALG_CBC_PKCS7 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04404100, .hex));
pub const PSA_ALG_AEAD_FROM_BLOCK_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00400000, .hex));
pub inline fn PSA_ALG_IS_AEAD_ON_BLOCK_CIPHER(alg: anytype) @TypeOf((alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_AEAD_FROM_BLOCK_FLAG)) == (PSA_ALG_CATEGORY_AEAD | PSA_ALG_AEAD_FROM_BLOCK_FLAG)) {
    _ = &alg;
    return (alg & (PSA_ALG_CATEGORY_MASK | PSA_ALG_AEAD_FROM_BLOCK_FLAG)) == (PSA_ALG_CATEGORY_AEAD | PSA_ALG_AEAD_FROM_BLOCK_FLAG);
}
pub const PSA_ALG_CCM = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x05500100, .hex));
pub const PSA_ALG_CCM_STAR_NO_TAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x04c01300, .hex));
pub const PSA_ALG_GCM = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x05500200, .hex));
pub const PSA_ALG_CHACHA20_POLY1305 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x05100500, .hex));
pub const PSA_ALG_AEAD_TAG_LENGTH_MASK = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x003f0000, .hex));
pub const PSA_AEAD_TAG_LENGTH_OFFSET = @as(c_int, 16);
pub const PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00008000, .hex));
pub inline fn PSA_ALG_AEAD_WITH_SHORTENED_TAG(aead_alg: anytype, tag_length: anytype) @TypeOf((aead_alg & ~(PSA_ALG_AEAD_TAG_LENGTH_MASK | PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG)) | ((tag_length << PSA_AEAD_TAG_LENGTH_OFFSET) & PSA_ALG_AEAD_TAG_LENGTH_MASK)) {
    _ = &aead_alg;
    _ = &tag_length;
    return (aead_alg & ~(PSA_ALG_AEAD_TAG_LENGTH_MASK | PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG)) | ((tag_length << PSA_AEAD_TAG_LENGTH_OFFSET) & PSA_ALG_AEAD_TAG_LENGTH_MASK);
}
pub inline fn PSA_ALG_AEAD_GET_TAG_LENGTH(aead_alg: anytype) @TypeOf((aead_alg & PSA_ALG_AEAD_TAG_LENGTH_MASK) >> PSA_AEAD_TAG_LENGTH_OFFSET) {
    _ = &aead_alg;
    return (aead_alg & PSA_ALG_AEAD_TAG_LENGTH_MASK) >> PSA_AEAD_TAG_LENGTH_OFFSET;
}
pub const PSA_ALG_AEAD_WITH_DEFAULT_LENGTH_TAG = @compileError("unable to translate C expr: expected ')' instead got 'a number'"); // /usr/include/psa/crypto_values.h:1355:9
pub const PSA_ALG_AEAD_WITH_DEFAULT_LENGTH_TAG_CASE = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/psa/crypto_values.h:1361:9
pub inline fn PSA_ALG_AEAD_WITH_AT_LEAST_THIS_LENGTH_TAG(aead_alg: anytype, min_tag_length: anytype) @TypeOf(PSA_ALG_AEAD_WITH_SHORTENED_TAG(aead_alg, min_tag_length) | PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG) {
    _ = &aead_alg;
    _ = &min_tag_length;
    return PSA_ALG_AEAD_WITH_SHORTENED_TAG(aead_alg, min_tag_length) | PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG;
}
pub const PSA_ALG_RSA_PKCS1V15_SIGN_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000200, .hex));
pub inline fn PSA_ALG_RSA_PKCS1V15_SIGN(hash_alg: anytype) @TypeOf(PSA_ALG_RSA_PKCS1V15_SIGN_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_RSA_PKCS1V15_SIGN_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_RSA_PKCS1V15_SIGN_RAW = PSA_ALG_RSA_PKCS1V15_SIGN_BASE;
pub inline fn PSA_ALG_IS_RSA_PKCS1V15_SIGN(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_PKCS1V15_SIGN_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_PKCS1V15_SIGN_BASE;
}
pub const PSA_ALG_RSA_PSS_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000300, .hex));
pub const PSA_ALG_RSA_PSS_ANY_SALT_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06001300, .hex));
pub inline fn PSA_ALG_RSA_PSS(hash_alg: anytype) @TypeOf(PSA_ALG_RSA_PSS_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_RSA_PSS_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_RSA_PSS_ANY_SALT(hash_alg: anytype) @TypeOf(PSA_ALG_RSA_PSS_ANY_SALT_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_RSA_PSS_ANY_SALT_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_RSA_PSS_STANDARD_SALT(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_PSS_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_PSS_BASE;
}
pub inline fn PSA_ALG_IS_RSA_PSS_ANY_SALT(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_PSS_ANY_SALT_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_PSS_ANY_SALT_BASE;
}
pub inline fn PSA_ALG_IS_RSA_PSS(alg: anytype) @TypeOf((PSA_ALG_IS_RSA_PSS_STANDARD_SALT(alg) != 0) or (PSA_ALG_IS_RSA_PSS_ANY_SALT(alg) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_RSA_PSS_STANDARD_SALT(alg) != 0) or (PSA_ALG_IS_RSA_PSS_ANY_SALT(alg) != 0);
}
pub const PSA_ALG_ECDSA_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000600, .hex));
pub inline fn PSA_ALG_ECDSA(hash_alg: anytype) @TypeOf(PSA_ALG_ECDSA_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_ECDSA_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_ECDSA_ANY = PSA_ALG_ECDSA_BASE;
pub const PSA_ALG_DETERMINISTIC_ECDSA_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000700, .hex));
pub inline fn PSA_ALG_DETERMINISTIC_ECDSA(hash_alg: anytype) @TypeOf(PSA_ALG_DETERMINISTIC_ECDSA_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_DETERMINISTIC_ECDSA_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_ECDSA_DETERMINISTIC_FLAG = __helpers.cast(psa_algorithm_t, @as(c_int, 0x00000100));
pub inline fn PSA_ALG_IS_ECDSA(alg: anytype) @TypeOf(((alg & ~PSA_ALG_HASH_MASK) & ~PSA_ALG_ECDSA_DETERMINISTIC_FLAG) == PSA_ALG_ECDSA_BASE) {
    _ = &alg;
    return ((alg & ~PSA_ALG_HASH_MASK) & ~PSA_ALG_ECDSA_DETERMINISTIC_FLAG) == PSA_ALG_ECDSA_BASE;
}
pub inline fn PSA_ALG_ECDSA_IS_DETERMINISTIC(alg: anytype) @TypeOf((alg & PSA_ALG_ECDSA_DETERMINISTIC_FLAG) != @as(c_int, 0)) {
    _ = &alg;
    return (alg & PSA_ALG_ECDSA_DETERMINISTIC_FLAG) != @as(c_int, 0);
}
pub inline fn PSA_ALG_IS_DETERMINISTIC_ECDSA(alg: anytype) @TypeOf((PSA_ALG_IS_ECDSA(alg) != 0) and (PSA_ALG_ECDSA_IS_DETERMINISTIC(alg) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_ECDSA(alg) != 0) and (PSA_ALG_ECDSA_IS_DETERMINISTIC(alg) != 0);
}
pub inline fn PSA_ALG_IS_RANDOMIZED_ECDSA(alg: anytype) @TypeOf((PSA_ALG_IS_ECDSA(alg) != 0) and !(PSA_ALG_ECDSA_IS_DETERMINISTIC(alg) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_ECDSA(alg) != 0) and !(PSA_ALG_ECDSA_IS_DETERMINISTIC(alg) != 0);
}
pub const PSA_ALG_PURE_EDDSA = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000800, .hex));
pub const PSA_ALG_HASH_EDDSA_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000900, .hex));
pub inline fn PSA_ALG_IS_HASH_EDDSA(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HASH_EDDSA_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HASH_EDDSA_BASE;
}
pub const PSA_ALG_ED25519PH = PSA_ALG_HASH_EDDSA_BASE | (PSA_ALG_SHA_512 & PSA_ALG_HASH_MASK);
pub const PSA_ALG_ED448PH = PSA_ALG_HASH_EDDSA_BASE | (PSA_ALG_SHAKE256_512 & PSA_ALG_HASH_MASK);
pub inline fn PSA_ALG_IS_SIGN_HASH(alg: anytype) @TypeOf(((((PSA_ALG_IS_RSA_PSS(alg) != 0) or (PSA_ALG_IS_RSA_PKCS1V15_SIGN(alg) != 0)) or (PSA_ALG_IS_ECDSA(alg) != 0)) or (PSA_ALG_IS_HASH_EDDSA(alg) != 0)) or (PSA_ALG_IS_VENDOR_HASH_AND_SIGN(alg) != 0)) {
    _ = &alg;
    return ((((PSA_ALG_IS_RSA_PSS(alg) != 0) or (PSA_ALG_IS_RSA_PKCS1V15_SIGN(alg) != 0)) or (PSA_ALG_IS_ECDSA(alg) != 0)) or (PSA_ALG_IS_HASH_EDDSA(alg) != 0)) or (PSA_ALG_IS_VENDOR_HASH_AND_SIGN(alg) != 0);
}
pub inline fn PSA_ALG_IS_SIGN_MESSAGE(alg: anytype) @TypeOf((PSA_ALG_IS_SIGN_HASH(alg) != 0) or (alg == PSA_ALG_PURE_EDDSA)) {
    _ = &alg;
    return (PSA_ALG_IS_SIGN_HASH(alg) != 0) or (alg == PSA_ALG_PURE_EDDSA);
}
pub inline fn PSA_ALG_IS_HASH_AND_SIGN(alg: anytype) @TypeOf((PSA_ALG_IS_SIGN_HASH(alg) != 0) and ((alg & PSA_ALG_HASH_MASK) != @as(c_int, 0))) {
    _ = &alg;
    return (PSA_ALG_IS_SIGN_HASH(alg) != 0) and ((alg & PSA_ALG_HASH_MASK) != @as(c_int, 0));
}
pub inline fn PSA_ALG_SIGN_GET_HASH(alg: anytype) @TypeOf(if (PSA_ALG_IS_HASH_AND_SIGN(alg)) (alg & PSA_ALG_HASH_MASK) | PSA_ALG_CATEGORY_HASH else @as(c_int, 0)) {
    _ = &alg;
    return if (PSA_ALG_IS_HASH_AND_SIGN(alg)) (alg & PSA_ALG_HASH_MASK) | PSA_ALG_CATEGORY_HASH else @as(c_int, 0);
}
pub const PSA_ALG_RSA_PKCS1V15_CRYPT = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x07000200, .hex));
pub const PSA_ALG_RSA_OAEP_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x07000300, .hex));
pub inline fn PSA_ALG_RSA_OAEP(hash_alg: anytype) @TypeOf(PSA_ALG_RSA_OAEP_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_RSA_OAEP_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_RSA_OAEP(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_OAEP_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_RSA_OAEP_BASE;
}
pub inline fn PSA_ALG_RSA_OAEP_GET_HASH(alg: anytype) @TypeOf(if (PSA_ALG_IS_RSA_OAEP(alg)) (alg & PSA_ALG_HASH_MASK) | PSA_ALG_CATEGORY_HASH else @as(c_int, 0)) {
    _ = &alg;
    return if (PSA_ALG_IS_RSA_OAEP(alg)) (alg & PSA_ALG_HASH_MASK) | PSA_ALG_CATEGORY_HASH else @as(c_int, 0);
}
pub const PSA_ALG_HKDF_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000100, .hex));
pub inline fn PSA_ALG_HKDF(hash_alg: anytype) @TypeOf(PSA_ALG_HKDF_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_HKDF_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_HKDF(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_BASE;
}
pub inline fn PSA_ALG_HKDF_GET_HASH(hkdf_alg: anytype) @TypeOf(PSA_ALG_CATEGORY_HASH | (hkdf_alg & PSA_ALG_HASH_MASK)) {
    _ = &hkdf_alg;
    return PSA_ALG_CATEGORY_HASH | (hkdf_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_HKDF_EXTRACT_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000400, .hex));
pub inline fn PSA_ALG_HKDF_EXTRACT(hash_alg: anytype) @TypeOf(PSA_ALG_HKDF_EXTRACT_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_HKDF_EXTRACT_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_HKDF_EXTRACT(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXTRACT_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXTRACT_BASE;
}
pub const PSA_ALG_HKDF_EXPAND_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000500, .hex));
pub inline fn PSA_ALG_HKDF_EXPAND(hash_alg: anytype) @TypeOf(PSA_ALG_HKDF_EXPAND_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_HKDF_EXPAND_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_HKDF_EXPAND(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXPAND_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXPAND_BASE;
}
pub inline fn PSA_ALG_IS_ANY_HKDF(alg: anytype) @TypeOf((((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_BASE) or ((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXTRACT_BASE)) or ((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXPAND_BASE)) {
    _ = &alg;
    return (((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_BASE) or ((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXTRACT_BASE)) or ((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_HKDF_EXPAND_BASE);
}
pub const PSA_ALG_TLS12_PRF_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000200, .hex));
pub inline fn PSA_ALG_TLS12_PRF(hash_alg: anytype) @TypeOf(PSA_ALG_TLS12_PRF_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_TLS12_PRF_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_TLS12_PRF(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_TLS12_PRF_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_TLS12_PRF_BASE;
}
pub inline fn PSA_ALG_TLS12_PRF_GET_HASH(hkdf_alg: anytype) @TypeOf(PSA_ALG_CATEGORY_HASH | (hkdf_alg & PSA_ALG_HASH_MASK)) {
    _ = &hkdf_alg;
    return PSA_ALG_CATEGORY_HASH | (hkdf_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_TLS12_PSK_TO_MS_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000300, .hex));
pub inline fn PSA_ALG_TLS12_PSK_TO_MS(hash_alg: anytype) @TypeOf(PSA_ALG_TLS12_PSK_TO_MS_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_TLS12_PSK_TO_MS_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_TLS12_PSK_TO_MS(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_TLS12_PSK_TO_MS_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_TLS12_PSK_TO_MS_BASE;
}
pub inline fn PSA_ALG_TLS12_PSK_TO_MS_GET_HASH(hkdf_alg: anytype) @TypeOf(PSA_ALG_CATEGORY_HASH | (hkdf_alg & PSA_ALG_HASH_MASK)) {
    _ = &hkdf_alg;
    return PSA_ALG_CATEGORY_HASH | (hkdf_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_TLS12_ECJPAKE_TO_PMS = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08000609, .hex));
pub const PSA_ALG_KEY_DERIVATION_STRETCHING_FLAG = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x00800000, .hex));
pub const PSA_ALG_PBKDF2_HMAC_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08800100, .hex));
pub inline fn PSA_ALG_PBKDF2_HMAC(hash_alg: anytype) @TypeOf(PSA_ALG_PBKDF2_HMAC_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_PBKDF2_HMAC_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_PBKDF2_HMAC(alg: anytype) @TypeOf((alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_PBKDF2_HMAC_BASE) {
    _ = &alg;
    return (alg & ~PSA_ALG_HASH_MASK) == PSA_ALG_PBKDF2_HMAC_BASE;
}
pub inline fn PSA_ALG_PBKDF2_HMAC_GET_HASH(pbkdf2_alg: anytype) @TypeOf(PSA_ALG_CATEGORY_HASH | (pbkdf2_alg & PSA_ALG_HASH_MASK)) {
    _ = &pbkdf2_alg;
    return PSA_ALG_CATEGORY_HASH | (pbkdf2_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_PBKDF2_AES_CMAC_PRF_128 = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x08800200, .hex));
pub inline fn PSA_ALG_IS_PBKDF2(kdf_alg: anytype) @TypeOf((PSA_ALG_IS_PBKDF2_HMAC(kdf_alg) != 0) or (kdf_alg == PSA_ALG_PBKDF2_AES_CMAC_PRF_128)) {
    _ = &kdf_alg;
    return (PSA_ALG_IS_PBKDF2_HMAC(kdf_alg) != 0) or (kdf_alg == PSA_ALG_PBKDF2_AES_CMAC_PRF_128);
}
pub const PSA_ALG_KEY_DERIVATION_MASK = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0xfe00ffff, .hex));
pub const PSA_ALG_KEY_AGREEMENT_MASK = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0xffff0000, .hex));
pub inline fn PSA_ALG_KEY_AGREEMENT(ka_alg: anytype, kdf_alg: anytype) @TypeOf(ka_alg | kdf_alg) {
    _ = &ka_alg;
    _ = &kdf_alg;
    return ka_alg | kdf_alg;
}
pub inline fn PSA_ALG_KEY_AGREEMENT_GET_KDF(alg: anytype) @TypeOf((alg & PSA_ALG_KEY_DERIVATION_MASK) | PSA_ALG_CATEGORY_KEY_DERIVATION) {
    _ = &alg;
    return (alg & PSA_ALG_KEY_DERIVATION_MASK) | PSA_ALG_CATEGORY_KEY_DERIVATION;
}
pub inline fn PSA_ALG_KEY_AGREEMENT_GET_BASE(alg: anytype) @TypeOf((alg & PSA_ALG_KEY_AGREEMENT_MASK) | PSA_ALG_CATEGORY_KEY_AGREEMENT) {
    _ = &alg;
    return (alg & PSA_ALG_KEY_AGREEMENT_MASK) | PSA_ALG_CATEGORY_KEY_AGREEMENT;
}
pub inline fn PSA_ALG_IS_RAW_KEY_AGREEMENT(alg: anytype) @TypeOf((PSA_ALG_IS_KEY_AGREEMENT(alg) != 0) and (PSA_ALG_KEY_AGREEMENT_GET_KDF(alg) == PSA_ALG_CATEGORY_KEY_DERIVATION)) {
    _ = &alg;
    return (PSA_ALG_IS_KEY_AGREEMENT(alg) != 0) and (PSA_ALG_KEY_AGREEMENT_GET_KDF(alg) == PSA_ALG_CATEGORY_KEY_DERIVATION);
}
pub inline fn PSA_ALG_IS_KEY_DERIVATION_OR_AGREEMENT(alg: anytype) @TypeOf((PSA_ALG_IS_KEY_DERIVATION(alg) != 0) or (PSA_ALG_IS_KEY_AGREEMENT(alg) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_KEY_DERIVATION(alg) != 0) or (PSA_ALG_IS_KEY_AGREEMENT(alg) != 0);
}
pub const PSA_ALG_FFDH = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x09010000, .hex));
pub inline fn PSA_ALG_IS_FFDH(alg: anytype) @TypeOf(PSA_ALG_KEY_AGREEMENT_GET_BASE(alg) == PSA_ALG_FFDH) {
    _ = &alg;
    return PSA_ALG_KEY_AGREEMENT_GET_BASE(alg) == PSA_ALG_FFDH;
}
pub const PSA_ALG_ECDH = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x09020000, .hex));
pub inline fn PSA_ALG_IS_ECDH(alg: anytype) @TypeOf(PSA_ALG_KEY_AGREEMENT_GET_BASE(alg) == PSA_ALG_ECDH) {
    _ = &alg;
    return PSA_ALG_KEY_AGREEMENT_GET_BASE(alg) == PSA_ALG_ECDH;
}
pub inline fn PSA_ALG_IS_WILDCARD(alg: anytype) @TypeOf(if (PSA_ALG_IS_HASH_AND_SIGN(alg)) PSA_ALG_SIGN_GET_HASH(alg) == PSA_ALG_ANY_HASH else if (PSA_ALG_IS_MAC(alg)) (alg & PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG) != @as(c_int, 0) else if (PSA_ALG_IS_AEAD(alg)) (alg & PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG) != @as(c_int, 0) else alg == PSA_ALG_ANY_HASH) {
    _ = &alg;
    return if (PSA_ALG_IS_HASH_AND_SIGN(alg)) PSA_ALG_SIGN_GET_HASH(alg) == PSA_ALG_ANY_HASH else if (PSA_ALG_IS_MAC(alg)) (alg & PSA_ALG_MAC_AT_LEAST_THIS_LENGTH_FLAG) != @as(c_int, 0) else if (PSA_ALG_IS_AEAD(alg)) (alg & PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG) != @as(c_int, 0) else alg == PSA_ALG_ANY_HASH;
}
pub inline fn PSA_ALG_GET_HASH(alg: anytype) @TypeOf(if ((alg & @as(c_int, 0x000000ff)) == @as(c_int, 0)) __helpers.cast(psa_algorithm_t, @as(c_int, 0)) else __helpers.promoteIntLiteral(c_int, 0x02000000, .hex) | (alg & @as(c_int, 0x000000ff))) {
    _ = &alg;
    return if ((alg & @as(c_int, 0x000000ff)) == @as(c_int, 0)) __helpers.cast(psa_algorithm_t, @as(c_int, 0)) else __helpers.promoteIntLiteral(c_int, 0x02000000, .hex) | (alg & @as(c_int, 0x000000ff));
}
pub const PSA_KEY_LIFETIME_VOLATILE = __helpers.cast(psa_key_lifetime_t, @as(c_int, 0x00000000));
pub const PSA_KEY_LIFETIME_PERSISTENT = __helpers.cast(psa_key_lifetime_t, @as(c_int, 0x00000001));
pub const PSA_KEY_PERSISTENCE_VOLATILE = __helpers.cast(psa_key_persistence_t, @as(c_int, 0x00));
pub const PSA_KEY_PERSISTENCE_DEFAULT = __helpers.cast(psa_key_persistence_t, @as(c_int, 0x01));
pub const PSA_KEY_PERSISTENCE_READ_ONLY = __helpers.cast(psa_key_persistence_t, @as(c_int, 0xff));
pub inline fn PSA_KEY_LIFETIME_GET_PERSISTENCE(lifetime: anytype) psa_key_persistence_t {
    _ = &lifetime;
    return __helpers.cast(psa_key_persistence_t, lifetime & @as(c_int, 0x000000ff));
}
pub inline fn PSA_KEY_LIFETIME_GET_LOCATION(lifetime: anytype) psa_key_location_t {
    _ = &lifetime;
    return __helpers.cast(psa_key_location_t, lifetime >> @as(c_int, 8));
}
pub inline fn PSA_KEY_LIFETIME_IS_VOLATILE(lifetime: anytype) @TypeOf(PSA_KEY_LIFETIME_GET_PERSISTENCE(lifetime) == PSA_KEY_PERSISTENCE_VOLATILE) {
    _ = &lifetime;
    return PSA_KEY_LIFETIME_GET_PERSISTENCE(lifetime) == PSA_KEY_PERSISTENCE_VOLATILE;
}
pub inline fn PSA_KEY_LIFETIME_IS_READ_ONLY(lifetime: anytype) @TypeOf(PSA_KEY_LIFETIME_GET_PERSISTENCE(lifetime) == PSA_KEY_PERSISTENCE_READ_ONLY) {
    _ = &lifetime;
    return PSA_KEY_LIFETIME_GET_PERSISTENCE(lifetime) == PSA_KEY_PERSISTENCE_READ_ONLY;
}
pub inline fn PSA_KEY_LIFETIME_FROM_PERSISTENCE_AND_LOCATION(persistence: anytype, location: anytype) @TypeOf((location << @as(c_int, 8)) | persistence) {
    _ = &persistence;
    _ = &location;
    return (location << @as(c_int, 8)) | persistence;
}
pub const PSA_KEY_LOCATION_LOCAL_STORAGE = __helpers.cast(psa_key_location_t, @as(c_int, 0x000000));
pub const PSA_KEY_LOCATION_VENDOR_FLAG = __helpers.cast(psa_key_location_t, __helpers.promoteIntLiteral(c_int, 0x800000, .hex));
pub const PSA_KEY_ID_NULL = __helpers.cast(psa_key_id_t, @as(c_int, 0));
pub const PSA_KEY_ID_USER_MIN = __helpers.cast(psa_key_id_t, @as(c_int, 0x00000001));
pub const PSA_KEY_ID_USER_MAX = __helpers.cast(psa_key_id_t, __helpers.promoteIntLiteral(c_int, 0x3fffffff, .hex));
pub const PSA_KEY_ID_VENDOR_MIN = __helpers.cast(psa_key_id_t, __helpers.promoteIntLiteral(c_int, 0x40000000, .hex));
pub const PSA_KEY_ID_VENDOR_MAX = __helpers.cast(psa_key_id_t, __helpers.promoteIntLiteral(c_int, 0x7fffffff, .hex));
pub const MBEDTLS_SVC_KEY_ID_INIT = __helpers.cast(psa_key_id_t, @as(c_int, 0));
pub inline fn MBEDTLS_SVC_KEY_ID_GET_KEY_ID(id: anytype) @TypeOf(id) {
    _ = &id;
    return id;
}
pub inline fn MBEDTLS_SVC_KEY_ID_GET_OWNER_ID(id: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &id;
    return @as(c_int, 0);
}
pub const PSA_KEY_USAGE_EXPORT = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00000001));
pub const PSA_KEY_USAGE_COPY = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00000002));
pub const PSA_KEY_USAGE_ENCRYPT = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00000100));
pub const PSA_KEY_USAGE_DECRYPT = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00000200));
pub const PSA_KEY_USAGE_SIGN_MESSAGE = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00000400));
pub const PSA_KEY_USAGE_VERIFY_MESSAGE = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00000800));
pub const PSA_KEY_USAGE_SIGN_HASH = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00001000));
pub const PSA_KEY_USAGE_VERIFY_HASH = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00002000));
pub const PSA_KEY_USAGE_DERIVE = __helpers.cast(psa_key_usage_t, @as(c_int, 0x00004000));
pub const PSA_KEY_USAGE_VERIFY_DERIVATION = __helpers.cast(psa_key_usage_t, __helpers.promoteIntLiteral(c_int, 0x00008000, .hex));
pub const PSA_KEY_DERIVATION_INPUT_SECRET = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0101));
pub const PSA_KEY_DERIVATION_INPUT_PASSWORD = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0102));
pub const PSA_KEY_DERIVATION_INPUT_OTHER_SECRET = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0103));
pub const PSA_KEY_DERIVATION_INPUT_LABEL = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0201));
pub const PSA_KEY_DERIVATION_INPUT_SALT = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0202));
pub const PSA_KEY_DERIVATION_INPUT_INFO = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0203));
pub const PSA_KEY_DERIVATION_INPUT_SEED = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0204));
pub const PSA_KEY_DERIVATION_INPUT_COST = __helpers.cast(psa_key_derivation_step_t, @as(c_int, 0x0205));
pub inline fn MBEDTLS_PSA_ALG_AEAD_EQUAL(aead_alg_1: anytype, aead_alg_2: anytype) @TypeOf(!(((aead_alg_1 ^ aead_alg_2) & ~(PSA_ALG_AEAD_TAG_LENGTH_MASK | PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG)) != 0)) {
    _ = &aead_alg_1;
    _ = &aead_alg_2;
    return !(((aead_alg_1 ^ aead_alg_2) & ~(PSA_ALG_AEAD_TAG_LENGTH_MASK | PSA_ALG_AEAD_AT_LEAST_THIS_LENGTH_FLAG)) != 0);
}
pub const PSA_INTERRUPTIBLE_MAX_OPS_UNLIMITED = UINT32_MAX;
pub const PSA_CRYPTO_SIZES_H = "";
pub inline fn PSA_BITS_TO_BYTES(bits: anytype) @TypeOf(__helpers.div(bits + @as(c_uint, 7), @as(c_uint, 8))) {
    _ = &bits;
    return __helpers.div(bits + @as(c_uint, 7), @as(c_uint, 8));
}
pub inline fn PSA_BYTES_TO_BITS(bytes: anytype) @TypeOf(bytes * @as(c_uint, 8)) {
    _ = &bytes;
    return bytes * @as(c_uint, 8);
}
pub const PSA_MAX_OF_THREE = @compileError("unable to translate C expr: expected ':' instead got '?'"); // /usr/include/psa/crypto_sizes.h:42:9
pub inline fn PSA_ROUND_UP_TO_MULTIPLE(block_size: anytype, length: anytype) @TypeOf(__helpers.div((length + block_size) - @as(c_int, 1), block_size) * block_size) {
    _ = &block_size;
    _ = &length;
    return __helpers.div((length + block_size) - @as(c_int, 1), block_size) * block_size;
}
pub inline fn PSA_HASH_LENGTH(alg: anytype) @TypeOf(if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_MD5) @as(c_uint, 16) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_RIPEMD160) @as(c_uint, 20) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_1) @as(c_uint, 20) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_224) @as(c_uint, 28) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_256) @as(c_uint, 32) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_384) @as(c_uint, 48) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_224) @as(c_uint, 28) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_256) @as(c_uint, 32) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_224) @as(c_uint, 28) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_256) @as(c_uint, 32) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_384) @as(c_uint, 48) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_512) @as(c_uint, 64) else @as(c_uint, 0)) {
    _ = &alg;
    return if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_MD5) @as(c_uint, 16) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_RIPEMD160) @as(c_uint, 20) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_1) @as(c_uint, 20) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_224) @as(c_uint, 28) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_256) @as(c_uint, 32) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_384) @as(c_uint, 48) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_224) @as(c_uint, 28) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_256) @as(c_uint, 32) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_224) @as(c_uint, 28) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_256) @as(c_uint, 32) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_384) @as(c_uint, 48) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_512) @as(c_uint, 64) else @as(c_uint, 0);
}
pub inline fn PSA_HASH_BLOCK_LENGTH(alg: anytype) @TypeOf(if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_MD5) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_RIPEMD160) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_1) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_224) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_256) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_384) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_224) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_256) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_224) @as(c_uint, 144) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_256) @as(c_uint, 136) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_384) @as(c_uint, 104) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_512) @as(c_uint, 72) else @as(c_uint, 0)) {
    _ = &alg;
    return if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_MD5) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_RIPEMD160) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_1) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_224) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_256) @as(c_uint, 64) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_384) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_224) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA_512_256) @as(c_uint, 128) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_224) @as(c_uint, 144) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_256) @as(c_uint, 136) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_384) @as(c_uint, 104) else if (PSA_ALG_HMAC_GET_HASH(alg) == PSA_ALG_SHA3_512) @as(c_uint, 72) else @as(c_uint, 0);
}
pub const PSA_HMAC_MAX_HASH_BLOCK_SIZE = @as(c_uint, 144);
pub const PSA_HASH_MAX_SIZE = @as(c_uint, 64);
pub const PSA_MAC_MAX_SIZE = PSA_HASH_MAX_SIZE;
pub inline fn PSA_AEAD_TAG_LENGTH(key_type: anytype, key_bits: anytype, alg: anytype) @TypeOf(if (PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) PSA_ALG_AEAD_GET_TAG_LENGTH(alg) else blk_2: {
    _ = __helpers.cast(anyopaque, key_bits);
    break :blk_2 @as(c_uint, 0);
}) {
    _ = &key_type;
    _ = &key_bits;
    _ = &alg;
    return if (PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) PSA_ALG_AEAD_GET_TAG_LENGTH(alg) else blk_2: {
        _ = __helpers.cast(anyopaque, key_bits);
        break :blk_2 @as(c_uint, 0);
    };
}
pub const PSA_AEAD_TAG_MAX_SIZE = @as(c_uint, 16);
pub const PSA_VENDOR_RSA_MAX_KEY_BITS = @as(c_uint, 4096);
pub const PSA_VENDOR_RSA_GENERATE_MIN_KEY_BITS = MBEDTLS_RSA_GEN_KEY_MIN_BITS;
pub const PSA_VENDOR_FFDH_MAX_KEY_BITS = @as(c_uint, 8192);
pub const PSA_VENDOR_ECC_MAX_CURVE_BITS = @as(c_uint, 521);
pub const PSA_TLS12_PSK_TO_MS_PSK_MAX_SIZE = @as(c_uint, 128);
pub const PSA_TLS12_ECJPAKE_TO_PMS_INPUT_SIZE = @as(c_uint, 65);
pub const PSA_TLS12_ECJPAKE_TO_PMS_DATA_SIZE = @as(c_uint, 32);
pub const PSA_VENDOR_PBKDF2_MAX_ITERATIONS = __helpers.promoteIntLiteral(c_uint, 0xffffffff, .hex);
pub const PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE = @as(c_uint, 16);
pub inline fn PSA_MAC_LENGTH(key_type: anytype, key_bits: anytype, alg: anytype) @TypeOf(if (alg & PSA_ALG_MAC_TRUNCATION_MASK) PSA_MAC_TRUNCATED_LENGTH(alg) else if (PSA_ALG_IS_HMAC(alg)) PSA_HASH_LENGTH(PSA_ALG_HMAC_GET_HASH(alg)) else if (PSA_ALG_IS_BLOCK_CIPHER_MAC(alg)) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else blk_2: {
    _ = __helpers.cast(anyopaque, key_type);
    _ = __helpers.cast(anyopaque, key_bits);
    break :blk_2 @as(c_uint, 0);
}) {
    _ = &key_type;
    _ = &key_bits;
    _ = &alg;
    return if (alg & PSA_ALG_MAC_TRUNCATION_MASK) PSA_MAC_TRUNCATED_LENGTH(alg) else if (PSA_ALG_IS_HMAC(alg)) PSA_HASH_LENGTH(PSA_ALG_HMAC_GET_HASH(alg)) else if (PSA_ALG_IS_BLOCK_CIPHER_MAC(alg)) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else blk_2: {
        _ = __helpers.cast(anyopaque, key_type);
        _ = __helpers.cast(anyopaque, key_bits);
        break :blk_2 @as(c_uint, 0);
    };
}
pub inline fn PSA_AEAD_ENCRYPT_OUTPUT_SIZE(key_type: anytype, alg: anytype, plaintext_length: anytype) @TypeOf(if (PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) plaintext_length + PSA_ALG_AEAD_GET_TAG_LENGTH(alg) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    _ = &plaintext_length;
    return if (PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) plaintext_length + PSA_ALG_AEAD_GET_TAG_LENGTH(alg) else @as(c_uint, 0);
}
pub inline fn PSA_AEAD_ENCRYPT_OUTPUT_MAX_SIZE(plaintext_length: anytype) @TypeOf(plaintext_length + PSA_AEAD_TAG_MAX_SIZE) {
    _ = &plaintext_length;
    return plaintext_length + PSA_AEAD_TAG_MAX_SIZE;
}
pub inline fn PSA_AEAD_DECRYPT_OUTPUT_SIZE(key_type: anytype, alg: anytype, ciphertext_length: anytype) @TypeOf(if ((PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) and (ciphertext_length > PSA_ALG_AEAD_GET_TAG_LENGTH(alg))) ciphertext_length - PSA_ALG_AEAD_GET_TAG_LENGTH(alg) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    _ = &ciphertext_length;
    return if ((PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) and (ciphertext_length > PSA_ALG_AEAD_GET_TAG_LENGTH(alg))) ciphertext_length - PSA_ALG_AEAD_GET_TAG_LENGTH(alg) else @as(c_uint, 0);
}
pub inline fn PSA_AEAD_DECRYPT_OUTPUT_MAX_SIZE(ciphertext_length: anytype) @TypeOf(ciphertext_length) {
    _ = &ciphertext_length;
    return ciphertext_length;
}
pub const PSA_AEAD_NONCE_LENGTH = @compileError("unable to translate C expr: expected ':' instead got '?'"); // /usr/include/psa/crypto_sizes.h:465:9
pub const PSA_AEAD_NONCE_MAX_SIZE = @as(c_uint, 13);
pub const PSA_AEAD_UPDATE_OUTPUT_SIZE = @compileError("unable to translate C expr: expected ':' instead got '?'"); // /usr/include/psa/crypto_sizes.h:517:9
pub inline fn PSA_AEAD_UPDATE_OUTPUT_MAX_SIZE(input_length: anytype) @TypeOf(PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE, input_length)) {
    _ = &input_length;
    return PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE, input_length);
}
pub inline fn PSA_AEAD_FINISH_OUTPUT_SIZE(key_type: anytype, alg: anytype) @TypeOf(if ((PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) and (PSA_ALG_IS_AEAD_ON_BLOCK_CIPHER(alg) != 0)) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    return if ((PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) and (PSA_ALG_IS_AEAD_ON_BLOCK_CIPHER(alg) != 0)) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else @as(c_uint, 0);
}
pub const PSA_AEAD_FINISH_OUTPUT_MAX_SIZE = PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE;
pub inline fn PSA_AEAD_VERIFY_OUTPUT_SIZE(key_type: anytype, alg: anytype) @TypeOf(if ((PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) and (PSA_ALG_IS_AEAD_ON_BLOCK_CIPHER(alg) != 0)) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    return if ((PSA_AEAD_NONCE_LENGTH(key_type, alg) != @as(c_int, 0)) and (PSA_ALG_IS_AEAD_ON_BLOCK_CIPHER(alg) != 0)) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else @as(c_uint, 0);
}
pub const PSA_AEAD_VERIFY_OUTPUT_MAX_SIZE = PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE;
pub inline fn PSA_RSA_MINIMUM_PADDING_SIZE(alg: anytype) @TypeOf(if (PSA_ALG_IS_RSA_OAEP(alg)) (@as(c_uint, 2) * PSA_HASH_LENGTH(PSA_ALG_RSA_OAEP_GET_HASH(alg))) + @as(c_uint, 1) else @as(c_uint, 11)) {
    _ = &alg;
    return if (PSA_ALG_IS_RSA_OAEP(alg)) (@as(c_uint, 2) * PSA_HASH_LENGTH(PSA_ALG_RSA_OAEP_GET_HASH(alg))) + @as(c_uint, 1) else @as(c_uint, 11);
}
pub inline fn PSA_ECDSA_SIGNATURE_SIZE(curve_bits: anytype) @TypeOf(PSA_BITS_TO_BYTES(curve_bits) * @as(c_uint, 2)) {
    _ = &curve_bits;
    return PSA_BITS_TO_BYTES(curve_bits) * @as(c_uint, 2);
}
pub inline fn PSA_SIGN_OUTPUT_SIZE(key_type: anytype, key_bits: anytype, alg: anytype) @TypeOf(if (PSA_KEY_TYPE_IS_RSA(key_type))
blk_2: {
    _ = __helpers.cast(anyopaque, alg);
    break :blk_2 PSA_BITS_TO_BYTES(key_bits);
} else if (PSA_KEY_TYPE_IS_ECC(key_type)) PSA_ECDSA_SIGNATURE_SIZE(key_bits) else blk_2: {
    _ = __helpers.cast(anyopaque, alg);
    break :blk_2 @as(c_uint, 0);
}) {
    _ = &key_type;
    _ = &key_bits;
    _ = &alg;
    return if (PSA_KEY_TYPE_IS_RSA(key_type)) blk_2: {
        _ = __helpers.cast(anyopaque, alg);
        break :blk_2 PSA_BITS_TO_BYTES(key_bits);
    } else if (PSA_KEY_TYPE_IS_ECC(key_type)) PSA_ECDSA_SIGNATURE_SIZE(key_bits) else blk_2: {
        _ = __helpers.cast(anyopaque, alg);
        break :blk_2 @as(c_uint, 0);
    };
}
pub const PSA_VENDOR_ECDSA_SIGNATURE_MAX_SIZE = PSA_ECDSA_SIGNATURE_SIZE(PSA_VENDOR_ECC_MAX_CURVE_BITS);
pub const PSA_SIGNATURE_MAX_SIZE = PSA_BITS_TO_BYTES(PSA_VENDOR_RSA_MAX_KEY_BITS);
pub inline fn PSA_ASYMMETRIC_ENCRYPT_OUTPUT_SIZE(key_type: anytype, key_bits: anytype, alg: anytype) @TypeOf(if (PSA_KEY_TYPE_IS_RSA(key_type))
blk_2: {
    _ = __helpers.cast(anyopaque, alg);
    break :blk_2 PSA_BITS_TO_BYTES(key_bits);
} else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &key_bits;
    _ = &alg;
    return if (PSA_KEY_TYPE_IS_RSA(key_type)) blk_2: {
        _ = __helpers.cast(anyopaque, alg);
        break :blk_2 PSA_BITS_TO_BYTES(key_bits);
    } else @as(c_uint, 0);
}
pub const PSA_ASYMMETRIC_ENCRYPT_OUTPUT_MAX_SIZE = PSA_BITS_TO_BYTES(PSA_VENDOR_RSA_MAX_KEY_BITS);
pub inline fn PSA_ASYMMETRIC_DECRYPT_OUTPUT_SIZE(key_type: anytype, key_bits: anytype, alg: anytype) @TypeOf(if (PSA_KEY_TYPE_IS_RSA(key_type)) PSA_BITS_TO_BYTES(key_bits) - PSA_RSA_MINIMUM_PADDING_SIZE(alg) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &key_bits;
    _ = &alg;
    return if (PSA_KEY_TYPE_IS_RSA(key_type)) PSA_BITS_TO_BYTES(key_bits) - PSA_RSA_MINIMUM_PADDING_SIZE(alg) else @as(c_uint, 0);
}
pub const PSA_ASYMMETRIC_DECRYPT_OUTPUT_MAX_SIZE = PSA_BITS_TO_BYTES(PSA_VENDOR_RSA_MAX_KEY_BITS);
pub inline fn PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(bits: anytype) @TypeOf(__helpers.div(bits, @as(c_uint, 8)) + @as(c_uint, 5)) {
    _ = &bits;
    return __helpers.div(bits, @as(c_uint, 8)) + @as(c_uint, 5);
}
pub inline fn PSA_KEY_EXPORT_RSA_PUBLIC_KEY_MAX_SIZE(key_bits: anytype) @TypeOf(PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(key_bits) + @as(c_uint, 11)) {
    _ = &key_bits;
    return PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(key_bits) + @as(c_uint, 11);
}
pub inline fn PSA_KEY_EXPORT_RSA_KEY_PAIR_MAX_SIZE(key_bits: anytype) @TypeOf((@as(c_uint, 9) * PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(__helpers.div(key_bits, @as(c_uint, 2)) + @as(c_uint, 1))) + @as(c_uint, 14)) {
    _ = &key_bits;
    return (@as(c_uint, 9) * PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(__helpers.div(key_bits, @as(c_uint, 2)) + @as(c_uint, 1))) + @as(c_uint, 14);
}
pub inline fn PSA_KEY_EXPORT_DSA_PUBLIC_KEY_MAX_SIZE(key_bits: anytype) @TypeOf((PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(key_bits) * @as(c_uint, 3)) + @as(c_uint, 59)) {
    _ = &key_bits;
    return (PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(key_bits) * @as(c_uint, 3)) + @as(c_uint, 59);
}
pub inline fn PSA_KEY_EXPORT_DSA_KEY_PAIR_MAX_SIZE(key_bits: anytype) @TypeOf((PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(key_bits) * @as(c_uint, 3)) + @as(c_uint, 75)) {
    _ = &key_bits;
    return (PSA_KEY_EXPORT_ASN1_INTEGER_MAX_SIZE(key_bits) * @as(c_uint, 3)) + @as(c_uint, 75);
}
pub inline fn PSA_KEY_EXPORT_ECC_PUBLIC_KEY_MAX_SIZE(key_bits: anytype) @TypeOf((@as(c_uint, 2) * PSA_BITS_TO_BYTES(key_bits)) + @as(c_uint, 1)) {
    _ = &key_bits;
    return (@as(c_uint, 2) * PSA_BITS_TO_BYTES(key_bits)) + @as(c_uint, 1);
}
pub inline fn PSA_KEY_EXPORT_ECC_KEY_PAIR_MAX_SIZE(key_bits: anytype) @TypeOf(PSA_BITS_TO_BYTES(key_bits)) {
    _ = &key_bits;
    return PSA_BITS_TO_BYTES(key_bits);
}
pub inline fn PSA_KEY_EXPORT_FFDH_KEY_PAIR_MAX_SIZE(key_bits: anytype) @TypeOf(PSA_BITS_TO_BYTES(key_bits)) {
    _ = &key_bits;
    return PSA_BITS_TO_BYTES(key_bits);
}
pub inline fn PSA_KEY_EXPORT_FFDH_PUBLIC_KEY_MAX_SIZE(key_bits: anytype) @TypeOf(PSA_BITS_TO_BYTES(key_bits)) {
    _ = &key_bits;
    return PSA_BITS_TO_BYTES(key_bits);
}
pub inline fn PSA_EXPORT_KEY_OUTPUT_SIZE(key_type: anytype, key_bits: anytype) @TypeOf(if (PSA_KEY_TYPE_IS_UNSTRUCTURED(key_type)) PSA_BITS_TO_BYTES(key_bits) else if (PSA_KEY_TYPE_IS_DH(key_type)) PSA_BITS_TO_BYTES(key_bits) else if (key_type == PSA_KEY_TYPE_RSA_KEY_PAIR) PSA_KEY_EXPORT_RSA_KEY_PAIR_MAX_SIZE(key_bits) else if (key_type == PSA_KEY_TYPE_RSA_PUBLIC_KEY) PSA_KEY_EXPORT_RSA_PUBLIC_KEY_MAX_SIZE(key_bits) else if (key_type == PSA_KEY_TYPE_DSA_KEY_PAIR) PSA_KEY_EXPORT_DSA_KEY_PAIR_MAX_SIZE(key_bits) else if (key_type == PSA_KEY_TYPE_DSA_PUBLIC_KEY) PSA_KEY_EXPORT_DSA_PUBLIC_KEY_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_ECC_KEY_PAIR(key_type)) PSA_KEY_EXPORT_ECC_KEY_PAIR_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_ECC_PUBLIC_KEY(key_type)) PSA_KEY_EXPORT_ECC_PUBLIC_KEY_MAX_SIZE(key_bits) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &key_bits;
    return if (PSA_KEY_TYPE_IS_UNSTRUCTURED(key_type)) PSA_BITS_TO_BYTES(key_bits) else if (PSA_KEY_TYPE_IS_DH(key_type)) PSA_BITS_TO_BYTES(key_bits) else if (key_type == PSA_KEY_TYPE_RSA_KEY_PAIR) PSA_KEY_EXPORT_RSA_KEY_PAIR_MAX_SIZE(key_bits) else if (key_type == PSA_KEY_TYPE_RSA_PUBLIC_KEY) PSA_KEY_EXPORT_RSA_PUBLIC_KEY_MAX_SIZE(key_bits) else if (key_type == PSA_KEY_TYPE_DSA_KEY_PAIR) PSA_KEY_EXPORT_DSA_KEY_PAIR_MAX_SIZE(key_bits) else if (key_type == PSA_KEY_TYPE_DSA_PUBLIC_KEY) PSA_KEY_EXPORT_DSA_PUBLIC_KEY_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_ECC_KEY_PAIR(key_type)) PSA_KEY_EXPORT_ECC_KEY_PAIR_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_ECC_PUBLIC_KEY(key_type)) PSA_KEY_EXPORT_ECC_PUBLIC_KEY_MAX_SIZE(key_bits) else @as(c_uint, 0);
}
pub inline fn PSA_EXPORT_PUBLIC_KEY_OUTPUT_SIZE(key_type: anytype, key_bits: anytype) @TypeOf(if (PSA_KEY_TYPE_IS_RSA(key_type)) PSA_KEY_EXPORT_RSA_PUBLIC_KEY_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_ECC(key_type)) PSA_KEY_EXPORT_ECC_PUBLIC_KEY_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_DH(key_type)) PSA_BITS_TO_BYTES(key_bits) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &key_bits;
    return if (PSA_KEY_TYPE_IS_RSA(key_type)) PSA_KEY_EXPORT_RSA_PUBLIC_KEY_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_ECC(key_type)) PSA_KEY_EXPORT_ECC_PUBLIC_KEY_MAX_SIZE(key_bits) else if (PSA_KEY_TYPE_IS_DH(key_type)) PSA_BITS_TO_BYTES(key_bits) else @as(c_uint, 0);
}
pub const PSA_EXPORT_KEY_PAIR_MAX_SIZE = PSA_KEY_EXPORT_RSA_KEY_PAIR_MAX_SIZE(PSA_VENDOR_RSA_MAX_KEY_BITS);
pub const PSA_EXPORT_PUBLIC_KEY_MAX_SIZE = PSA_KEY_EXPORT_FFDH_PUBLIC_KEY_MAX_SIZE(PSA_VENDOR_FFDH_MAX_KEY_BITS);
pub const PSA_EXPORT_KEY_PAIR_OR_PUBLIC_MAX_SIZE = if (PSA_EXPORT_KEY_PAIR_MAX_SIZE > PSA_EXPORT_PUBLIC_KEY_MAX_SIZE) PSA_EXPORT_KEY_PAIR_MAX_SIZE else PSA_EXPORT_PUBLIC_KEY_MAX_SIZE;
pub inline fn PSA_RAW_KEY_AGREEMENT_OUTPUT_SIZE(key_type: anytype, key_bits: anytype) @TypeOf(if ((PSA_KEY_TYPE_IS_ECC_KEY_PAIR(key_type) != 0) or (PSA_KEY_TYPE_IS_DH_KEY_PAIR(key_type) != 0)) PSA_BITS_TO_BYTES(key_bits) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &key_bits;
    return if ((PSA_KEY_TYPE_IS_ECC_KEY_PAIR(key_type) != 0) or (PSA_KEY_TYPE_IS_DH_KEY_PAIR(key_type) != 0)) PSA_BITS_TO_BYTES(key_bits) else @as(c_uint, 0);
}
pub const PSA_RAW_KEY_AGREEMENT_OUTPUT_MAX_SIZE = PSA_BITS_TO_BYTES(PSA_VENDOR_FFDH_MAX_KEY_BITS);
pub const PSA_CIPHER_MAX_KEY_LENGTH = @as(c_uint, 32);
pub inline fn PSA_CIPHER_IV_LENGTH(key_type: anytype, alg: anytype) @TypeOf(if ((PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) > @as(c_int, 1)) and ((((((alg == PSA_ALG_CTR) or (alg == PSA_ALG_CFB)) or (alg == PSA_ALG_OFB)) or (alg == PSA_ALG_XTS)) or (alg == PSA_ALG_CBC_NO_PADDING)) or (alg == PSA_ALG_CBC_PKCS7))) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else if ((key_type == PSA_KEY_TYPE_CHACHA20) and (alg == PSA_ALG_STREAM_CIPHER)) @as(c_uint, 12) else if (alg == PSA_ALG_CCM_STAR_NO_TAG) @as(c_uint, 13) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    return if ((PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) > @as(c_int, 1)) and ((((((alg == PSA_ALG_CTR) or (alg == PSA_ALG_CFB)) or (alg == PSA_ALG_OFB)) or (alg == PSA_ALG_XTS)) or (alg == PSA_ALG_CBC_NO_PADDING)) or (alg == PSA_ALG_CBC_PKCS7))) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else if ((key_type == PSA_KEY_TYPE_CHACHA20) and (alg == PSA_ALG_STREAM_CIPHER)) @as(c_uint, 12) else if (alg == PSA_ALG_CCM_STAR_NO_TAG) @as(c_uint, 13) else @as(c_uint, 0);
}
pub const PSA_CIPHER_IV_MAX_SIZE = @as(c_uint, 16);
pub inline fn PSA_CIPHER_ENCRYPT_OUTPUT_SIZE(key_type: anytype, alg: anytype, input_length: anytype) @TypeOf(if (alg == PSA_ALG_CBC_PKCS7) if (PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) != @as(c_int, 0)) PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type), input_length + @as(c_uint, 1)) + PSA_CIPHER_IV_LENGTH(key_type, alg) else @as(c_uint, 0) else if (PSA_ALG_IS_CIPHER(alg)) input_length + PSA_CIPHER_IV_LENGTH(key_type, alg) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    _ = &input_length;
    return if (alg == PSA_ALG_CBC_PKCS7) if (PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) != @as(c_int, 0)) PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type), input_length + @as(c_uint, 1)) + PSA_CIPHER_IV_LENGTH(key_type, alg) else @as(c_uint, 0) else if (PSA_ALG_IS_CIPHER(alg)) input_length + PSA_CIPHER_IV_LENGTH(key_type, alg) else @as(c_uint, 0);
}
pub inline fn PSA_CIPHER_ENCRYPT_OUTPUT_MAX_SIZE(input_length: anytype) @TypeOf(PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE, input_length + @as(c_uint, 1)) + PSA_CIPHER_IV_MAX_SIZE) {
    _ = &input_length;
    return PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE, input_length + @as(c_uint, 1)) + PSA_CIPHER_IV_MAX_SIZE;
}
pub inline fn PSA_CIPHER_DECRYPT_OUTPUT_SIZE(key_type: anytype, alg: anytype, input_length: anytype) @TypeOf(if ((PSA_ALG_IS_CIPHER(alg) != 0) and ((key_type & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_SYMMETRIC)) input_length else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    _ = &input_length;
    return if ((PSA_ALG_IS_CIPHER(alg) != 0) and ((key_type & PSA_KEY_TYPE_CATEGORY_MASK) == PSA_KEY_TYPE_CATEGORY_SYMMETRIC)) input_length else @as(c_uint, 0);
}
pub inline fn PSA_CIPHER_DECRYPT_OUTPUT_MAX_SIZE(input_length: anytype) @TypeOf(input_length) {
    _ = &input_length;
    return input_length;
}
pub inline fn PSA_CIPHER_UPDATE_OUTPUT_SIZE(key_type: anytype, alg: anytype, input_length: anytype) @TypeOf(if (PSA_ALG_IS_CIPHER(alg)) if (PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) != @as(c_int, 0)) if (((alg == PSA_ALG_CBC_PKCS7) or (alg == PSA_ALG_CBC_NO_PADDING)) or (alg == PSA_ALG_ECB_NO_PADDING)) PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type), input_length) else input_length else @as(c_uint, 0) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    _ = &input_length;
    return if (PSA_ALG_IS_CIPHER(alg)) if (PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) != @as(c_int, 0)) if (((alg == PSA_ALG_CBC_PKCS7) or (alg == PSA_ALG_CBC_NO_PADDING)) or (alg == PSA_ALG_ECB_NO_PADDING)) PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type), input_length) else input_length else @as(c_uint, 0) else @as(c_uint, 0);
}
pub inline fn PSA_CIPHER_UPDATE_OUTPUT_MAX_SIZE(input_length: anytype) @TypeOf(PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE, input_length)) {
    _ = &input_length;
    return PSA_ROUND_UP_TO_MULTIPLE(PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE, input_length);
}
pub inline fn PSA_CIPHER_FINISH_OUTPUT_SIZE(key_type: anytype, alg: anytype) @TypeOf(if (PSA_ALG_IS_CIPHER(alg)) if (alg == PSA_ALG_CBC_PKCS7) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else @as(c_uint, 0) else @as(c_uint, 0)) {
    _ = &key_type;
    _ = &alg;
    return if (PSA_ALG_IS_CIPHER(alg)) if (alg == PSA_ALG_CBC_PKCS7) PSA_BLOCK_CIPHER_BLOCK_LENGTH(key_type) else @as(c_uint, 0) else @as(c_uint, 0);
}
pub const PSA_CIPHER_FINISH_OUTPUT_MAX_SIZE = PSA_BLOCK_CIPHER_BLOCK_MAX_SIZE;
pub const PSA_CRYPTO_STRUCT_H = "";
pub const PSA_CRYPTO_DRIVER_CONTEXTS_PRIMITIVES_H = "";
pub const PSA_CRYPTO_DRIVER_COMMON_H = "";
pub const PSA_CRYPTO_BUILTIN_PRIMITIVES_H = "";
pub const MBEDTLS_MD5_H = "";
pub const MBEDTLS_RIPEMD160_H = "";
pub const MBEDTLS_SHA1_H = "";
pub const MBEDTLS_ERR_SHA1_BAD_INPUT_DATA = -@as(c_int, 0x0073);
pub const MBEDTLS_SHA256_H = "";
pub const MBEDTLS_ERR_SHA256_BAD_INPUT_DATA = -@as(c_int, 0x0074);
pub const MBEDTLS_SHA512_H = "";
pub const MBEDTLS_ERR_SHA512_BAD_INPUT_DATA = -@as(c_int, 0x0075);
pub const MBEDTLS_SHA3_H = "";
pub const MBEDTLS_ERR_SHA3_BAD_INPUT_DATA = -@as(c_int, 0x0076);
pub const MBEDTLS_PSA_BUILTIN_HASH = "";
pub const MBEDTLS_PSA_HASH_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_primitives.h:82:9
pub const MBEDTLS_CIPHER_H = "";
pub const MBEDTLS_CIPHER_MODE_AEAD = "";
pub const MBEDTLS_CIPHER_MODE_WITH_PADDING = "";
pub const MBEDTLS_CIPHER_MODE_STREAM = "";
pub const MBEDTLS_ERR_CIPHER_FEATURE_UNAVAILABLE = -@as(c_int, 0x6080);
pub const MBEDTLS_ERR_CIPHER_BAD_INPUT_DATA = -@as(c_int, 0x6100);
pub const MBEDTLS_ERR_CIPHER_ALLOC_FAILED = -@as(c_int, 0x6180);
pub const MBEDTLS_ERR_CIPHER_INVALID_PADDING = -@as(c_int, 0x6200);
pub const MBEDTLS_ERR_CIPHER_FULL_BLOCK_EXPECTED = -@as(c_int, 0x6280);
pub const MBEDTLS_ERR_CIPHER_AUTH_FAILED = -@as(c_int, 0x6300);
pub const MBEDTLS_ERR_CIPHER_INVALID_CONTEXT = -@as(c_int, 0x6380);
pub const MBEDTLS_CIPHER_VARIABLE_IV_LEN = @as(c_int, 0x01);
pub const MBEDTLS_CIPHER_VARIABLE_KEY_LEN = @as(c_int, 0x02);
pub const MBEDTLS_MAX_IV_LENGTH = @as(c_int, 16);
pub const MBEDTLS_MAX_BLOCK_LENGTH = @as(c_int, 16);
pub const MBEDTLS_MAX_KEY_LENGTH = @as(c_int, 64);
pub const MBEDTLS_KEY_BITLEN_SHIFT = @as(c_int, 6);
pub const MBEDTLS_IV_SIZE_SHIFT = @as(c_int, 2);
pub const MBEDTLS_PSA_BUILTIN_CIPHER = @as(c_int, 1);
pub const MBEDTLS_PSA_CIPHER_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_primitives.h:112:9
pub const PSA_HASH_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:87:9
pub const PSA_CIPHER_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:119:9
pub const PSA_CRYPTO_DRIVER_CONTEXTS_COMPOSITES_H = "";
pub const PSA_CRYPTO_BUILTIN_COMPOSITES_H = "";
pub const MBEDTLS_CMAC_H = "";
pub const MBEDTLS_AES_BLOCK_SIZE = @as(c_int, 16);
pub const MBEDTLS_DES3_BLOCK_SIZE = @as(c_int, 8);
pub const MBEDTLS_CMAC_MAX_BLOCK_SIZE = @as(c_int, 16);
pub const MBEDTLS_CIPHER_BLKSIZE_MAX = MBEDTLS_MAX_BLOCK_LENGTH;
pub const MBEDTLS_GCM_H = "";
pub const MBEDTLS_GCM_ENCRYPT = @as(c_int, 1);
pub const MBEDTLS_GCM_DECRYPT = @as(c_int, 0);
pub const MBEDTLS_ERR_GCM_AUTH_FAILED = -@as(c_int, 0x0012);
pub const MBEDTLS_ERR_GCM_BAD_INPUT = -@as(c_int, 0x0014);
pub const MBEDTLS_ERR_GCM_BUFFER_TOO_SMALL = -@as(c_int, 0x0016);
pub const MBEDTLS_GCM_HTABLE_SIZE = @as(c_int, 16);
pub const MBEDTLS_CCM_H = "";
pub const MBEDTLS_CCM_DECRYPT = @as(c_int, 0);
pub const MBEDTLS_CCM_ENCRYPT = @as(c_int, 1);
pub const MBEDTLS_CCM_STAR_DECRYPT = @as(c_int, 2);
pub const MBEDTLS_CCM_STAR_ENCRYPT = @as(c_int, 3);
pub const MBEDTLS_ERR_CCM_BAD_INPUT = -@as(c_int, 0x000D);
pub const MBEDTLS_ERR_CCM_AUTH_FAILED = -@as(c_int, 0x000F);
pub const MBEDTLS_CHACHAPOLY_H = "";
pub const MBEDTLS_POLY1305_H = "";
pub const MBEDTLS_ERR_POLY1305_BAD_INPUT_DATA = -@as(c_int, 0x0057);
pub const MBEDTLS_ERR_CHACHAPOLY_BAD_STATE = -@as(c_int, 0x0054);
pub const MBEDTLS_ERR_CHACHAPOLY_AUTH_FAILED = -@as(c_int, 0x0056);
pub const MBEDTLS_CHACHA20_H = "";
pub const MBEDTLS_ERR_CHACHA20_BAD_INPUT_DATA = -@as(c_int, 0x0051);
pub const MBEDTLS_PSA_BUILTIN_MAC = "";
pub const MBEDTLS_PSA_HMAC_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_composites.h:54:9
pub const MBEDTLS_PSA_MAC_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_composites.h:70:9
pub const MBEDTLS_PSA_BUILTIN_AEAD = @as(c_int, 1);
pub const MBEDTLS_PSA_AEAD_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_composites.h:103:9
pub const MBEDTLS_PSA_SIGN_HASH_INTERRUPTIBLE_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_composites.h:137:9
pub const MBEDTLS_VERIFY_SIGN_HASH_INTERRUPTIBLE_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_composites.h:174:9
pub const MBEDTLS_ECJPAKE_H = "";
pub const MBEDTLS_PSA_JPAKE_BUFFER_SIZE = ((((((@as(c_int, 3) + @as(c_int, 1)) + @as(c_int, 65)) + @as(c_int, 1)) + @as(c_int, 65)) + @as(c_int, 1)) + @as(c_int, 32)) * @as(c_int, 2);
pub const MBEDTLS_PSA_PAKE_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_builtin_composites.h:212:9
pub const PSA_MAC_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:151:9
pub const PSA_AEAD_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:190:9
pub const PSA_CRYPTO_DRIVER_CONTEXTS_KEY_DERIVATION_H = "";
pub const PSA_CRYPTO_BUILTIN_KEY_DERIVATION_H = "";
pub const PSA_KEY_DERIVATION_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:217:9
pub const PSA_CUSTOM_KEY_PARAMETERS_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:238:9
pub const PSA_KEY_PRODUCTION_PARAMETERS_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:265:9
pub const PSA_KEY_POLICY_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:275:9
pub const PSA_KEY_BITS_TOO_LARGE = __helpers.cast(psa_key_bits_t, -@as(c_int, 1));
pub const PSA_MAX_KEY_BITS = __helpers.promoteIntLiteral(c_int, 0xfff8, .hex);
pub const PSA_KEY_ATTRIBUTES_MAYBE_SLOT_NUMBER = "";
pub const PSA_KEY_ATTRIBUTES_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:323:9
pub const PSA_SIGN_HASH_INTERRUPTIBLE_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:473:9
pub const PSA_VERIFY_HASH_INTERRUPTIBLE_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_struct.h:511:9
pub const PSA_KEY_DERIVATION_UNLIMITED_CAPACITY = __helpers.cast(usize, -@as(c_int, 1));
pub const PSA_CRYPTO_EXTRA_H = "";
pub const PSA_CRYPTO_COMPAT_H = "";
pub const PSA_KEY_HANDLE_INIT = MBEDTLS_SVC_KEY_ID_INIT;
pub const PSA_DH_FAMILY_CUSTOM = __helpers.cast(psa_dh_family_t, MBEDTLS_DEPRECATED_NUMERIC_CONSTANT(@as(c_int, 0x7e)));
pub inline fn PSA_KEY_DOMAIN_PARAMETERS_SIZE(key_type: anytype, key_bits: anytype) @TypeOf(MBEDTLS_DEPRECATED_NUMERIC_CONSTANT(@as(c_uint, 1))) {
    _ = &key_type;
    _ = &key_bits;
    return MBEDTLS_DEPRECATED_NUMERIC_CONSTANT(@as(c_uint, 1));
}
pub const PSA_CRYPTO_ITS_RANDOM_SEED_UID = __helpers.promoteIntLiteral(c_int, 0xFFFFFF52, .hex);
pub const MBEDTLS_PSA_KEY_SLOT_COUNT = @as(c_int, 32);
pub const MBEDTLS_PSA_STATIC_KEY_SLOT_BUFFER_SIZE = if (PSA_EXPORT_KEY_PAIR_OR_PUBLIC_MAX_SIZE > PSA_CIPHER_MAX_KEY_LENGTH) PSA_EXPORT_KEY_PAIR_OR_PUBLIC_MAX_SIZE else PSA_CIPHER_MAX_KEY_LENGTH;
pub const PSA_KEY_TYPE_DSA_PUBLIC_KEY = __helpers.cast(psa_key_type_t, @as(c_int, 0x4002));
pub const PSA_KEY_TYPE_DSA_KEY_PAIR = __helpers.cast(psa_key_type_t, @as(c_int, 0x7002));
pub inline fn PSA_KEY_TYPE_IS_DSA(@"type": anytype) @TypeOf(PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") == PSA_KEY_TYPE_DSA_PUBLIC_KEY) {
    _ = &@"type";
    return PSA_KEY_TYPE_PUBLIC_KEY_OF_KEY_PAIR(@"type") == PSA_KEY_TYPE_DSA_PUBLIC_KEY;
}
pub const PSA_ALG_DSA_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000400, .hex));
pub inline fn PSA_ALG_DSA(hash_alg: anytype) @TypeOf(PSA_ALG_DSA_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_DSA_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub const PSA_ALG_DETERMINISTIC_DSA_BASE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x06000500, .hex));
pub const PSA_ALG_DSA_DETERMINISTIC_FLAG = PSA_ALG_ECDSA_DETERMINISTIC_FLAG;
pub inline fn PSA_ALG_DETERMINISTIC_DSA(hash_alg: anytype) @TypeOf(PSA_ALG_DETERMINISTIC_DSA_BASE | (hash_alg & PSA_ALG_HASH_MASK)) {
    _ = &hash_alg;
    return PSA_ALG_DETERMINISTIC_DSA_BASE | (hash_alg & PSA_ALG_HASH_MASK);
}
pub inline fn PSA_ALG_IS_DSA(alg: anytype) @TypeOf(((alg & ~PSA_ALG_HASH_MASK) & ~PSA_ALG_DSA_DETERMINISTIC_FLAG) == PSA_ALG_DSA_BASE) {
    _ = &alg;
    return ((alg & ~PSA_ALG_HASH_MASK) & ~PSA_ALG_DSA_DETERMINISTIC_FLAG) == PSA_ALG_DSA_BASE;
}
pub inline fn PSA_ALG_DSA_IS_DETERMINISTIC(alg: anytype) @TypeOf((alg & PSA_ALG_DSA_DETERMINISTIC_FLAG) != @as(c_int, 0)) {
    _ = &alg;
    return (alg & PSA_ALG_DSA_DETERMINISTIC_FLAG) != @as(c_int, 0);
}
pub inline fn PSA_ALG_IS_DETERMINISTIC_DSA(alg: anytype) @TypeOf((PSA_ALG_IS_DSA(alg) != 0) and (PSA_ALG_DSA_IS_DETERMINISTIC(alg) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_DSA(alg) != 0) and (PSA_ALG_DSA_IS_DETERMINISTIC(alg) != 0);
}
pub inline fn PSA_ALG_IS_RANDOMIZED_DSA(alg: anytype) @TypeOf((PSA_ALG_IS_DSA(alg) != 0) and !(PSA_ALG_DSA_IS_DETERMINISTIC(alg) != 0)) {
    _ = &alg;
    return (PSA_ALG_IS_DSA(alg) != 0) and !(PSA_ALG_DSA_IS_DETERMINISTIC(alg) != 0);
}
pub inline fn PSA_ALG_IS_VENDOR_HASH_AND_SIGN(alg: anytype) @TypeOf(PSA_ALG_IS_DSA(alg)) {
    _ = &alg;
    return PSA_ALG_IS_DSA(alg);
}
pub const PSA_PAKE_OPERATION_STAGE_SETUP = @as(c_int, 0);
pub const PSA_PAKE_OPERATION_STAGE_COLLECT_INPUTS = @as(c_int, 1);
pub const PSA_PAKE_OPERATION_STAGE_COMPUTATION = @as(c_int, 2);
pub const MBEDTLS_PSA_KEY_ID_BUILTIN_MIN = __helpers.cast(psa_key_id_t, __helpers.promoteIntLiteral(c_int, 0x7fff0000, .hex));
pub const MBEDTLS_PSA_KEY_ID_BUILTIN_MAX = __helpers.cast(psa_key_id_t, __helpers.promoteIntLiteral(c_int, 0x7fffefff, .hex));
pub const PSA_ALG_CATEGORY_PAKE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0a000000, .hex));
pub inline fn PSA_ALG_IS_PAKE(alg: anytype) @TypeOf((alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_PAKE) {
    _ = &alg;
    return (alg & PSA_ALG_CATEGORY_MASK) == PSA_ALG_CATEGORY_PAKE;
}
pub const PSA_ALG_JPAKE = __helpers.cast(psa_algorithm_t, __helpers.promoteIntLiteral(c_int, 0x0a000100, .hex));
pub const PSA_PAKE_ROLE_NONE = __helpers.cast(psa_pake_role_t, @as(c_int, 0x00));
pub const PSA_PAKE_ROLE_FIRST = __helpers.cast(psa_pake_role_t, @as(c_int, 0x01));
pub const PSA_PAKE_ROLE_SECOND = __helpers.cast(psa_pake_role_t, @as(c_int, 0x02));
pub const PSA_PAKE_ROLE_CLIENT = __helpers.cast(psa_pake_role_t, @as(c_int, 0x11));
pub const PSA_PAKE_ROLE_SERVER = __helpers.cast(psa_pake_role_t, @as(c_int, 0x12));
pub const PSA_PAKE_PRIMITIVE_TYPE_ECC = __helpers.cast(psa_pake_primitive_type_t, @as(c_int, 0x01));
pub const PSA_PAKE_PRIMITIVE_TYPE_DH = __helpers.cast(psa_pake_primitive_type_t, @as(c_int, 0x02));
pub inline fn PSA_PAKE_PRIMITIVE(pake_type: anytype, pake_family: anytype, pake_bits: anytype) @TypeOf(if ((pake_bits & __helpers.promoteIntLiteral(c_int, 0xFFFF, .hex)) != pake_bits) @as(c_int, 0) else __helpers.cast(psa_pake_primitive_t, ((pake_type << @as(c_int, 24)) | (pake_family << @as(c_int, 16))) | pake_bits)) {
    _ = &pake_type;
    _ = &pake_family;
    _ = &pake_bits;
    return if ((pake_bits & __helpers.promoteIntLiteral(c_int, 0xFFFF, .hex)) != pake_bits) @as(c_int, 0) else __helpers.cast(psa_pake_primitive_t, ((pake_type << @as(c_int, 24)) | (pake_family << @as(c_int, 16))) | pake_bits);
}
pub const PSA_PAKE_STEP_KEY_SHARE = __helpers.cast(psa_pake_step_t, @as(c_int, 0x01));
pub const PSA_PAKE_STEP_ZK_PUBLIC = __helpers.cast(psa_pake_step_t, @as(c_int, 0x02));
pub const PSA_PAKE_STEP_ZK_PROOF = __helpers.cast(psa_pake_step_t, @as(c_int, 0x03));
pub inline fn PSA_PAKE_OUTPUT_SIZE(alg: anytype, primitive: anytype, output_step: anytype) @TypeOf(if ((alg == PSA_ALG_JPAKE) and (primitive == PSA_PAKE_PRIMITIVE(PSA_PAKE_PRIMITIVE_TYPE_ECC, PSA_ECC_FAMILY_SECP_R1, @as(c_int, 256)))) if (output_step == PSA_PAKE_STEP_KEY_SHARE) @as(c_int, 65) else if (output_step == PSA_PAKE_STEP_ZK_PUBLIC) @as(c_int, 65) else @as(c_int, 32) else @as(c_int, 0)) {
    _ = &alg;
    _ = &primitive;
    _ = &output_step;
    return if ((alg == PSA_ALG_JPAKE) and (primitive == PSA_PAKE_PRIMITIVE(PSA_PAKE_PRIMITIVE_TYPE_ECC, PSA_ECC_FAMILY_SECP_R1, @as(c_int, 256)))) if (output_step == PSA_PAKE_STEP_KEY_SHARE) @as(c_int, 65) else if (output_step == PSA_PAKE_STEP_ZK_PUBLIC) @as(c_int, 65) else @as(c_int, 32) else @as(c_int, 0);
}
pub inline fn PSA_PAKE_INPUT_SIZE(alg: anytype, primitive: anytype, input_step: anytype) @TypeOf(if ((alg == PSA_ALG_JPAKE) and (primitive == PSA_PAKE_PRIMITIVE(PSA_PAKE_PRIMITIVE_TYPE_ECC, PSA_ECC_FAMILY_SECP_R1, @as(c_int, 256)))) if (input_step == PSA_PAKE_STEP_KEY_SHARE) @as(c_int, 65) else if (input_step == PSA_PAKE_STEP_ZK_PUBLIC) @as(c_int, 65) else @as(c_int, 32) else @as(c_int, 0)) {
    _ = &alg;
    _ = &primitive;
    _ = &input_step;
    return if ((alg == PSA_ALG_JPAKE) and (primitive == PSA_PAKE_PRIMITIVE(PSA_PAKE_PRIMITIVE_TYPE_ECC, PSA_ECC_FAMILY_SECP_R1, @as(c_int, 256)))) if (input_step == PSA_PAKE_STEP_KEY_SHARE) @as(c_int, 65) else if (input_step == PSA_PAKE_STEP_ZK_PUBLIC) @as(c_int, 65) else @as(c_int, 32) else @as(c_int, 0);
}
pub const PSA_PAKE_OUTPUT_MAX_SIZE = @as(c_int, 65);
pub const PSA_PAKE_INPUT_MAX_SIZE = @as(c_int, 65);
pub const PSA_PAKE_CIPHER_SUITE_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_extra.h:1045:9
pub const PSA_PAKE_OPERATION_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/psa/crypto_extra.h:1053:9
pub inline fn PSA_JPAKE_EXPECTED_INPUTS(round: anytype) @TypeOf(if (round == PSA_JPAKE_FINISHED) @as(c_int, 0) else if (round == PSA_JPAKE_FIRST) @as(c_int, 2) else @as(c_int, 1)) {
    _ = &round;
    return if (round == PSA_JPAKE_FINISHED) @as(c_int, 0) else if (round == PSA_JPAKE_FIRST) @as(c_int, 2) else @as(c_int, 1);
}
pub inline fn PSA_JPAKE_EXPECTED_OUTPUTS(round: anytype) @TypeOf(if (round == PSA_JPAKE_FINISHED) @as(c_int, 0) else if (round == PSA_JPAKE_FIRST) @as(c_int, 2) else @as(c_int, 1)) {
    _ = &round;
    return if (round == PSA_JPAKE_FINISHED) @as(c_int, 0) else if (round == PSA_JPAKE_FIRST) @as(c_int, 2) else @as(c_int, 1);
}
pub const MBEDTLS_ERR_PK_ALLOC_FAILED = -@as(c_int, 0x3F80);
pub const MBEDTLS_ERR_PK_TYPE_MISMATCH = -@as(c_int, 0x3F00);
pub const MBEDTLS_ERR_PK_BAD_INPUT_DATA = -@as(c_int, 0x3E80);
pub const MBEDTLS_ERR_PK_FILE_IO_ERROR = -@as(c_int, 0x3E00);
pub const MBEDTLS_ERR_PK_KEY_INVALID_VERSION = -@as(c_int, 0x3D80);
pub const MBEDTLS_ERR_PK_KEY_INVALID_FORMAT = -@as(c_int, 0x3D00);
pub const MBEDTLS_ERR_PK_UNKNOWN_PK_ALG = -@as(c_int, 0x3C80);
pub const MBEDTLS_ERR_PK_PASSWORD_REQUIRED = -@as(c_int, 0x3C00);
pub const MBEDTLS_ERR_PK_PASSWORD_MISMATCH = -@as(c_int, 0x3B80);
pub const MBEDTLS_ERR_PK_INVALID_PUBKEY = -@as(c_int, 0x3B00);
pub const MBEDTLS_ERR_PK_INVALID_ALG = -@as(c_int, 0x3A80);
pub const MBEDTLS_ERR_PK_UNKNOWN_NAMED_CURVE = -@as(c_int, 0x3A00);
pub const MBEDTLS_ERR_PK_FEATURE_UNAVAILABLE = -@as(c_int, 0x3980);
pub const MBEDTLS_ERR_PK_SIG_LEN_MISMATCH = -@as(c_int, 0x3900);
pub const MBEDTLS_ERR_PK_BUFFER_TOO_SMALL = -@as(c_int, 0x3880);
pub const MBEDTLS_PK_SIGNATURE_MAX_SIZE = MBEDTLS_MPI_MAX_SIZE;
pub const MBEDTLS_PK_DEBUG_MAX_ITEMS = @as(c_int, 3);
pub const MBEDTLS_PK_MAX_EC_PUBKEY_RAW_LEN = PSA_KEY_EXPORT_ECC_PUBLIC_KEY_MAX_SIZE(PSA_VENDOR_ECC_MAX_CURVE_BITS);
pub const MBEDTLS_TLS_RSA_WITH_NULL_MD5 = @as(c_int, 0x01);
pub const MBEDTLS_TLS_RSA_WITH_NULL_SHA = @as(c_int, 0x02);
pub const MBEDTLS_TLS_PSK_WITH_NULL_SHA = @as(c_int, 0x2C);
pub const MBEDTLS_TLS_DHE_PSK_WITH_NULL_SHA = @as(c_int, 0x2D);
pub const MBEDTLS_TLS_RSA_PSK_WITH_NULL_SHA = @as(c_int, 0x2E);
pub const MBEDTLS_TLS_RSA_WITH_AES_128_CBC_SHA = @as(c_int, 0x2F);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_128_CBC_SHA = @as(c_int, 0x33);
pub const MBEDTLS_TLS_RSA_WITH_AES_256_CBC_SHA = @as(c_int, 0x35);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_256_CBC_SHA = @as(c_int, 0x39);
pub const MBEDTLS_TLS_RSA_WITH_NULL_SHA256 = @as(c_int, 0x3B);
pub const MBEDTLS_TLS_RSA_WITH_AES_128_CBC_SHA256 = @as(c_int, 0x3C);
pub const MBEDTLS_TLS_RSA_WITH_AES_256_CBC_SHA256 = @as(c_int, 0x3D);
pub const MBEDTLS_TLS_RSA_WITH_CAMELLIA_128_CBC_SHA = @as(c_int, 0x41);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA = @as(c_int, 0x45);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 = @as(c_int, 0x67);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 = @as(c_int, 0x6B);
pub const MBEDTLS_TLS_RSA_WITH_CAMELLIA_256_CBC_SHA = @as(c_int, 0x84);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA = @as(c_int, 0x88);
pub const MBEDTLS_TLS_PSK_WITH_AES_128_CBC_SHA = @as(c_int, 0x8C);
pub const MBEDTLS_TLS_PSK_WITH_AES_256_CBC_SHA = @as(c_int, 0x8D);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_128_CBC_SHA = @as(c_int, 0x90);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_256_CBC_SHA = @as(c_int, 0x91);
pub const MBEDTLS_TLS_RSA_PSK_WITH_AES_128_CBC_SHA = @as(c_int, 0x94);
pub const MBEDTLS_TLS_RSA_PSK_WITH_AES_256_CBC_SHA = @as(c_int, 0x95);
pub const MBEDTLS_TLS_RSA_WITH_AES_128_GCM_SHA256 = @as(c_int, 0x9C);
pub const MBEDTLS_TLS_RSA_WITH_AES_256_GCM_SHA384 = @as(c_int, 0x9D);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 = @as(c_int, 0x9E);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 = @as(c_int, 0x9F);
pub const MBEDTLS_TLS_PSK_WITH_AES_128_GCM_SHA256 = @as(c_int, 0xA8);
pub const MBEDTLS_TLS_PSK_WITH_AES_256_GCM_SHA384 = @as(c_int, 0xA9);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_128_GCM_SHA256 = @as(c_int, 0xAA);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_256_GCM_SHA384 = @as(c_int, 0xAB);
pub const MBEDTLS_TLS_RSA_PSK_WITH_AES_128_GCM_SHA256 = @as(c_int, 0xAC);
pub const MBEDTLS_TLS_RSA_PSK_WITH_AES_256_GCM_SHA384 = @as(c_int, 0xAD);
pub const MBEDTLS_TLS_PSK_WITH_AES_128_CBC_SHA256 = @as(c_int, 0xAE);
pub const MBEDTLS_TLS_PSK_WITH_AES_256_CBC_SHA384 = @as(c_int, 0xAF);
pub const MBEDTLS_TLS_PSK_WITH_NULL_SHA256 = @as(c_int, 0xB0);
pub const MBEDTLS_TLS_PSK_WITH_NULL_SHA384 = @as(c_int, 0xB1);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_128_CBC_SHA256 = @as(c_int, 0xB2);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_256_CBC_SHA384 = @as(c_int, 0xB3);
pub const MBEDTLS_TLS_DHE_PSK_WITH_NULL_SHA256 = @as(c_int, 0xB4);
pub const MBEDTLS_TLS_DHE_PSK_WITH_NULL_SHA384 = @as(c_int, 0xB5);
pub const MBEDTLS_TLS_RSA_PSK_WITH_AES_128_CBC_SHA256 = @as(c_int, 0xB6);
pub const MBEDTLS_TLS_RSA_PSK_WITH_AES_256_CBC_SHA384 = @as(c_int, 0xB7);
pub const MBEDTLS_TLS_RSA_PSK_WITH_NULL_SHA256 = @as(c_int, 0xB8);
pub const MBEDTLS_TLS_RSA_PSK_WITH_NULL_SHA384 = @as(c_int, 0xB9);
pub const MBEDTLS_TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256 = @as(c_int, 0xBA);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256 = @as(c_int, 0xBE);
pub const MBEDTLS_TLS_RSA_WITH_CAMELLIA_256_CBC_SHA256 = @as(c_int, 0xC0);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256 = @as(c_int, 0xC4);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_NULL_SHA = __helpers.promoteIntLiteral(c_int, 0xC001, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC004, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC005, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_NULL_SHA = __helpers.promoteIntLiteral(c_int, 0xC006, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC009, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC00A, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_NULL_SHA = __helpers.promoteIntLiteral(c_int, 0xC00B, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_AES_128_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC00E, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_AES_256_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC00F, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_NULL_SHA = __helpers.promoteIntLiteral(c_int, 0xC010, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC013, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC014, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC023, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC024, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC025, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC026, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC027, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC028, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC029, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC02A, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC02B, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC02C, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC02D, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC02E, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC02F, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC030, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC031, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC032, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC035, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA = __helpers.promoteIntLiteral(c_int, 0xC036, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC037, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC038, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_NULL_SHA = __helpers.promoteIntLiteral(c_int, 0xC039, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_NULL_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC03A, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_NULL_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC03B, .hex);
pub const MBEDTLS_TLS_RSA_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC03C, .hex);
pub const MBEDTLS_TLS_RSA_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC03D, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC044, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC045, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC048, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC049, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC04A, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC04B, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC04C, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC04D, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC04E, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC04F, .hex);
pub const MBEDTLS_TLS_RSA_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC050, .hex);
pub const MBEDTLS_TLS_RSA_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC051, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC052, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC053, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC05C, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC05D, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC05E, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC05F, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC060, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC061, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC062, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC063, .hex);
pub const MBEDTLS_TLS_PSK_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC064, .hex);
pub const MBEDTLS_TLS_PSK_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC065, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC066, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC067, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC068, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC069, .hex);
pub const MBEDTLS_TLS_PSK_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC06A, .hex);
pub const MBEDTLS_TLS_PSK_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC06B, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC06C, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC06D, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_ARIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC06E, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_ARIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC06F, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_ARIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC070, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_ARIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC071, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC072, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC073, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC074, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC075, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC076, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC077, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC078, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC079, .hex);
pub const MBEDTLS_TLS_RSA_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC07A, .hex);
pub const MBEDTLS_TLS_RSA_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC07B, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC07C, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC07D, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC086, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC087, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC088, .hex);
pub const MBEDTLS_TLS_ECDH_ECDSA_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC089, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC08A, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC08B, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC08C, .hex);
pub const MBEDTLS_TLS_ECDH_RSA_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC08D, .hex);
pub const MBEDTLS_TLS_PSK_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC08E, .hex);
pub const MBEDTLS_TLS_PSK_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC08F, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC090, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC091, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_CAMELLIA_128_GCM_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC092, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_CAMELLIA_256_GCM_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC093, .hex);
pub const MBEDTLS_TLS_PSK_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC094, .hex);
pub const MBEDTLS_TLS_PSK_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC095, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC096, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC097, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC098, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC099, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_CAMELLIA_128_CBC_SHA256 = __helpers.promoteIntLiteral(c_int, 0xC09A, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_CAMELLIA_256_CBC_SHA384 = __helpers.promoteIntLiteral(c_int, 0xC09B, .hex);
pub const MBEDTLS_TLS_RSA_WITH_AES_128_CCM = __helpers.promoteIntLiteral(c_int, 0xC09C, .hex);
pub const MBEDTLS_TLS_RSA_WITH_AES_256_CCM = __helpers.promoteIntLiteral(c_int, 0xC09D, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_128_CCM = __helpers.promoteIntLiteral(c_int, 0xC09E, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_256_CCM = __helpers.promoteIntLiteral(c_int, 0xC09F, .hex);
pub const MBEDTLS_TLS_RSA_WITH_AES_128_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0A0, .hex);
pub const MBEDTLS_TLS_RSA_WITH_AES_256_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0A1, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_128_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0A2, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_AES_256_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0A3, .hex);
pub const MBEDTLS_TLS_PSK_WITH_AES_128_CCM = __helpers.promoteIntLiteral(c_int, 0xC0A4, .hex);
pub const MBEDTLS_TLS_PSK_WITH_AES_256_CCM = __helpers.promoteIntLiteral(c_int, 0xC0A5, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_128_CCM = __helpers.promoteIntLiteral(c_int, 0xC0A6, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_256_CCM = __helpers.promoteIntLiteral(c_int, 0xC0A7, .hex);
pub const MBEDTLS_TLS_PSK_WITH_AES_128_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0A8, .hex);
pub const MBEDTLS_TLS_PSK_WITH_AES_256_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0A9, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_128_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0AA, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_AES_256_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0AB, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_128_CCM = __helpers.promoteIntLiteral(c_int, 0xC0AC, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_256_CCM = __helpers.promoteIntLiteral(c_int, 0xC0AD, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0AE, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0AF, .hex);
pub const MBEDTLS_TLS_ECJPAKE_WITH_AES_128_CCM_8 = __helpers.promoteIntLiteral(c_int, 0xC0FF, .hex);
pub const MBEDTLS_TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCA8, .hex);
pub const MBEDTLS_TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCA9, .hex);
pub const MBEDTLS_TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCAA, .hex);
pub const MBEDTLS_TLS_PSK_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCAB, .hex);
pub const MBEDTLS_TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCAC, .hex);
pub const MBEDTLS_TLS_DHE_PSK_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCAD, .hex);
pub const MBEDTLS_TLS_RSA_PSK_WITH_CHACHA20_POLY1305_SHA256 = __helpers.promoteIntLiteral(c_int, 0xCCAE, .hex);
pub const MBEDTLS_TLS1_3_AES_128_GCM_SHA256 = @as(c_int, 0x1301);
pub const MBEDTLS_TLS1_3_AES_256_GCM_SHA384 = @as(c_int, 0x1302);
pub const MBEDTLS_TLS1_3_CHACHA20_POLY1305_SHA256 = @as(c_int, 0x1303);
pub const MBEDTLS_TLS1_3_AES_128_CCM_SHA256 = @as(c_int, 0x1304);
pub const MBEDTLS_TLS1_3_AES_128_CCM_8_SHA256 = @as(c_int, 0x1305);
pub const MBEDTLS_KEY_EXCHANGE_WITH_CERT_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_WITH_ECDSA_ANY_ENABLED = "";
pub const MBEDTLS_SSL_HANDSHAKE_WITH_CERT_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_CERT_REQ_ALLOWED_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDSA_CERT_REQ_ALLOWED_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_ECDSA_CERT_REQ_ANY_ALLOWED_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_WITH_SERVER_SIGNATURE_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_ECDH_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_NON_PFS_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_PFS_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_PSK_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_DHE_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_ECDHE_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_ECDH_OR_ECDHE_1_2_ENABLED = "";
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_SOME_PSK_ENABLED = "";
pub const MBEDTLS_SSL_HANDSHAKE_WITH_PSK_ENABLED = "";
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_SOME_EPHEMERAL_ENABLED = "";
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_SOME_ECDHE_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_ECDH_OR_ECDHE_ANY_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_XXDH_1_2_ENABLED = "";
pub const MBEDTLS_KEY_EXCHANGE_SOME_XXDH_PSA_ANY_ENABLED = "";
pub const MBEDTLS_CIPHERSUITE_WEAK = @as(c_int, 0x01);
pub const MBEDTLS_CIPHERSUITE_SHORT_TAG = @as(c_int, 0x02);
pub const MBEDTLS_CIPHERSUITE_NODTLS = @as(c_int, 0x04);
pub const MBEDTLS_X509_CRT_H = "";
pub const MBEDTLS_X509_H = "";
pub const MBEDTLS_ASN1_H = "";
pub const MBEDTLS_ERR_ASN1_OUT_OF_DATA = -@as(c_int, 0x0060);
pub const MBEDTLS_ERR_ASN1_UNEXPECTED_TAG = -@as(c_int, 0x0062);
pub const MBEDTLS_ERR_ASN1_INVALID_LENGTH = -@as(c_int, 0x0064);
pub const MBEDTLS_ERR_ASN1_LENGTH_MISMATCH = -@as(c_int, 0x0066);
pub const MBEDTLS_ERR_ASN1_INVALID_DATA = -@as(c_int, 0x0068);
pub const MBEDTLS_ERR_ASN1_ALLOC_FAILED = -@as(c_int, 0x006A);
pub const MBEDTLS_ERR_ASN1_BUF_TOO_SMALL = -@as(c_int, 0x006C);
pub const MBEDTLS_ASN1_BOOLEAN = @as(c_int, 0x01);
pub const MBEDTLS_ASN1_INTEGER = @as(c_int, 0x02);
pub const MBEDTLS_ASN1_BIT_STRING = @as(c_int, 0x03);
pub const MBEDTLS_ASN1_OCTET_STRING = @as(c_int, 0x04);
pub const MBEDTLS_ASN1_NULL = @as(c_int, 0x05);
pub const MBEDTLS_ASN1_OID = @as(c_int, 0x06);
pub const MBEDTLS_ASN1_ENUMERATED = @as(c_int, 0x0A);
pub const MBEDTLS_ASN1_UTF8_STRING = @as(c_int, 0x0C);
pub const MBEDTLS_ASN1_SEQUENCE = @as(c_int, 0x10);
pub const MBEDTLS_ASN1_SET = @as(c_int, 0x11);
pub const MBEDTLS_ASN1_PRINTABLE_STRING = @as(c_int, 0x13);
pub const MBEDTLS_ASN1_T61_STRING = @as(c_int, 0x14);
pub const MBEDTLS_ASN1_IA5_STRING = @as(c_int, 0x16);
pub const MBEDTLS_ASN1_UTC_TIME = @as(c_int, 0x17);
pub const MBEDTLS_ASN1_GENERALIZED_TIME = @as(c_int, 0x18);
pub const MBEDTLS_ASN1_UNIVERSAL_STRING = @as(c_int, 0x1C);
pub const MBEDTLS_ASN1_BMP_STRING = @as(c_int, 0x1E);
pub const MBEDTLS_ASN1_PRIMITIVE = @as(c_int, 0x00);
pub const MBEDTLS_ASN1_CONSTRUCTED = @as(c_int, 0x20);
pub const MBEDTLS_ASN1_CONTEXT_SPECIFIC = @as(c_int, 0x80);
pub inline fn MBEDTLS_ASN1_IS_STRING_TAG(tag: anytype) @TypeOf((__helpers.cast(c_uint, tag) < @as(c_uint, 32)) and (((@as(c_uint, 1) << tag) & ((((((@as(c_uint, 1) << MBEDTLS_ASN1_BMP_STRING) | (@as(c_uint, 1) << MBEDTLS_ASN1_UTF8_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_T61_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_IA5_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_UNIVERSAL_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_PRINTABLE_STRING))) != @as(c_int, 0))) {
    _ = &tag;
    return (__helpers.cast(c_uint, tag) < @as(c_uint, 32)) and (((@as(c_uint, 1) << tag) & ((((((@as(c_uint, 1) << MBEDTLS_ASN1_BMP_STRING) | (@as(c_uint, 1) << MBEDTLS_ASN1_UTF8_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_T61_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_IA5_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_UNIVERSAL_STRING)) | (@as(c_uint, 1) << MBEDTLS_ASN1_PRINTABLE_STRING))) != @as(c_int, 0));
}
pub const MBEDTLS_ASN1_TAG_CLASS_MASK = @as(c_int, 0xC0);
pub const MBEDTLS_ASN1_TAG_PC_MASK = @as(c_int, 0x20);
pub const MBEDTLS_ASN1_TAG_VALUE_MASK = @as(c_int, 0x1F);
pub inline fn MBEDTLS_OID_SIZE(x: anytype) @TypeOf(__helpers.sizeof(x) - @as(c_int, 1)) {
    _ = &x;
    return __helpers.sizeof(x) - @as(c_int, 1);
}
pub const MBEDTLS_OID_CMP = @compileError("unable to translate macro: undefined identifier `memcmp`"); // /usr/include/mbedtls/asn1.h:121:9
pub const MBEDTLS_OID_CMP_RAW = @compileError("unable to translate macro: undefined identifier `memcmp`"); // /usr/include/mbedtls/asn1.h:125:9
pub const MBEDTLS_X509_MAX_INTERMEDIATE_CA = @as(c_int, 8);
pub const MBEDTLS_ERR_X509_FEATURE_UNAVAILABLE = -@as(c_int, 0x2080);
pub const MBEDTLS_ERR_X509_UNKNOWN_OID = -@as(c_int, 0x2100);
pub const MBEDTLS_ERR_X509_INVALID_FORMAT = -@as(c_int, 0x2180);
pub const MBEDTLS_ERR_X509_INVALID_VERSION = -@as(c_int, 0x2200);
pub const MBEDTLS_ERR_X509_INVALID_SERIAL = -@as(c_int, 0x2280);
pub const MBEDTLS_ERR_X509_INVALID_ALG = -@as(c_int, 0x2300);
pub const MBEDTLS_ERR_X509_INVALID_NAME = -@as(c_int, 0x2380);
pub const MBEDTLS_ERR_X509_INVALID_DATE = -@as(c_int, 0x2400);
pub const MBEDTLS_ERR_X509_INVALID_SIGNATURE = -@as(c_int, 0x2480);
pub const MBEDTLS_ERR_X509_INVALID_EXTENSIONS = -@as(c_int, 0x2500);
pub const MBEDTLS_ERR_X509_UNKNOWN_VERSION = -@as(c_int, 0x2580);
pub const MBEDTLS_ERR_X509_UNKNOWN_SIG_ALG = -@as(c_int, 0x2600);
pub const MBEDTLS_ERR_X509_SIG_MISMATCH = -@as(c_int, 0x2680);
pub const MBEDTLS_ERR_X509_CERT_VERIFY_FAILED = -@as(c_int, 0x2700);
pub const MBEDTLS_ERR_X509_CERT_UNKNOWN_FORMAT = -@as(c_int, 0x2780);
pub const MBEDTLS_ERR_X509_BAD_INPUT_DATA = -@as(c_int, 0x2800);
pub const MBEDTLS_ERR_X509_ALLOC_FAILED = -@as(c_int, 0x2880);
pub const MBEDTLS_ERR_X509_FILE_IO_ERROR = -@as(c_int, 0x2900);
pub const MBEDTLS_ERR_X509_BUFFER_TOO_SMALL = -@as(c_int, 0x2980);
pub const MBEDTLS_ERR_X509_FATAL_ERROR = -@as(c_int, 0x3000);
pub const MBEDTLS_X509_BADCERT_EXPIRED = @as(c_int, 0x01);
pub const MBEDTLS_X509_BADCERT_REVOKED = @as(c_int, 0x02);
pub const MBEDTLS_X509_BADCERT_CN_MISMATCH = @as(c_int, 0x04);
pub const MBEDTLS_X509_BADCERT_NOT_TRUSTED = @as(c_int, 0x08);
pub const MBEDTLS_X509_BADCRL_NOT_TRUSTED = @as(c_int, 0x10);
pub const MBEDTLS_X509_BADCRL_EXPIRED = @as(c_int, 0x20);
pub const MBEDTLS_X509_BADCERT_MISSING = @as(c_int, 0x40);
pub const MBEDTLS_X509_BADCERT_SKIP_VERIFY = @as(c_int, 0x80);
pub const MBEDTLS_X509_BADCERT_OTHER = @as(c_int, 0x0100);
pub const MBEDTLS_X509_BADCERT_FUTURE = @as(c_int, 0x0200);
pub const MBEDTLS_X509_BADCRL_FUTURE = @as(c_int, 0x0400);
pub const MBEDTLS_X509_BADCERT_KEY_USAGE = @as(c_int, 0x0800);
pub const MBEDTLS_X509_BADCERT_EXT_KEY_USAGE = @as(c_int, 0x1000);
pub const MBEDTLS_X509_BADCERT_NS_CERT_TYPE = @as(c_int, 0x2000);
pub const MBEDTLS_X509_BADCERT_BAD_MD = @as(c_int, 0x4000);
pub const MBEDTLS_X509_BADCERT_BAD_PK = __helpers.promoteIntLiteral(c_int, 0x8000, .hex);
pub const MBEDTLS_X509_BADCERT_BAD_KEY = __helpers.promoteIntLiteral(c_int, 0x010000, .hex);
pub const MBEDTLS_X509_BADCRL_BAD_MD = __helpers.promoteIntLiteral(c_int, 0x020000, .hex);
pub const MBEDTLS_X509_BADCRL_BAD_PK = __helpers.promoteIntLiteral(c_int, 0x040000, .hex);
pub const MBEDTLS_X509_BADCRL_BAD_KEY = __helpers.promoteIntLiteral(c_int, 0x080000, .hex);
pub const MBEDTLS_X509_SAN_OTHER_NAME = @as(c_int, 0);
pub const MBEDTLS_X509_SAN_RFC822_NAME = @as(c_int, 1);
pub const MBEDTLS_X509_SAN_DNS_NAME = @as(c_int, 2);
pub const MBEDTLS_X509_SAN_X400_ADDRESS_NAME = @as(c_int, 3);
pub const MBEDTLS_X509_SAN_DIRECTORY_NAME = @as(c_int, 4);
pub const MBEDTLS_X509_SAN_EDI_PARTY_NAME = @as(c_int, 5);
pub const MBEDTLS_X509_SAN_UNIFORM_RESOURCE_IDENTIFIER = @as(c_int, 6);
pub const MBEDTLS_X509_SAN_IP_ADDRESS = @as(c_int, 7);
pub const MBEDTLS_X509_SAN_REGISTERED_ID = @as(c_int, 8);
pub const MBEDTLS_X509_KU_DIGITAL_SIGNATURE = @as(c_int, 0x80);
pub const MBEDTLS_X509_KU_NON_REPUDIATION = @as(c_int, 0x40);
pub const MBEDTLS_X509_KU_KEY_ENCIPHERMENT = @as(c_int, 0x20);
pub const MBEDTLS_X509_KU_DATA_ENCIPHERMENT = @as(c_int, 0x10);
pub const MBEDTLS_X509_KU_KEY_AGREEMENT = @as(c_int, 0x08);
pub const MBEDTLS_X509_KU_KEY_CERT_SIGN = @as(c_int, 0x04);
pub const MBEDTLS_X509_KU_CRL_SIGN = @as(c_int, 0x02);
pub const MBEDTLS_X509_KU_ENCIPHER_ONLY = @as(c_int, 0x01);
pub const MBEDTLS_X509_KU_DECIPHER_ONLY = __helpers.promoteIntLiteral(c_int, 0x8000, .hex);
pub const MBEDTLS_X509_NS_CERT_TYPE_SSL_CLIENT = @as(c_int, 0x80);
pub const MBEDTLS_X509_NS_CERT_TYPE_SSL_SERVER = @as(c_int, 0x40);
pub const MBEDTLS_X509_NS_CERT_TYPE_EMAIL = @as(c_int, 0x20);
pub const MBEDTLS_X509_NS_CERT_TYPE_OBJECT_SIGNING = @as(c_int, 0x10);
pub const MBEDTLS_X509_NS_CERT_TYPE_RESERVED = @as(c_int, 0x08);
pub const MBEDTLS_X509_NS_CERT_TYPE_SSL_CA = @as(c_int, 0x04);
pub const MBEDTLS_X509_NS_CERT_TYPE_EMAIL_CA = @as(c_int, 0x02);
pub const MBEDTLS_X509_NS_CERT_TYPE_OBJECT_SIGNING_CA = @as(c_int, 0x01);
pub const MBEDTLS_X509_EXT_AUTHORITY_KEY_IDENTIFIER = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_AUTHORITY_KEY_IDENTIFIER`"); // /usr/include/mbedtls/x509.h:174:9
pub const MBEDTLS_X509_EXT_SUBJECT_KEY_IDENTIFIER = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_SUBJECT_KEY_IDENTIFIER`"); // /usr/include/mbedtls/x509.h:175:9
pub const MBEDTLS_X509_EXT_KEY_USAGE = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_KEY_USAGE`"); // /usr/include/mbedtls/x509.h:176:9
pub const MBEDTLS_X509_EXT_CERTIFICATE_POLICIES = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_CERTIFICATE_POLICIES`"); // /usr/include/mbedtls/x509.h:177:9
pub const MBEDTLS_X509_EXT_POLICY_MAPPINGS = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_POLICY_MAPPINGS`"); // /usr/include/mbedtls/x509.h:178:9
pub const MBEDTLS_X509_EXT_SUBJECT_ALT_NAME = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_SUBJECT_ALT_NAME`"); // /usr/include/mbedtls/x509.h:179:9
pub const MBEDTLS_X509_EXT_ISSUER_ALT_NAME = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_ISSUER_ALT_NAME`"); // /usr/include/mbedtls/x509.h:180:9
pub const MBEDTLS_X509_EXT_SUBJECT_DIRECTORY_ATTRS = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_SUBJECT_DIRECTORY_ATTRS`"); // /usr/include/mbedtls/x509.h:181:9
pub const MBEDTLS_X509_EXT_BASIC_CONSTRAINTS = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_BASIC_CONSTRAINTS`"); // /usr/include/mbedtls/x509.h:182:9
pub const MBEDTLS_X509_EXT_NAME_CONSTRAINTS = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_NAME_CONSTRAINTS`"); // /usr/include/mbedtls/x509.h:183:9
pub const MBEDTLS_X509_EXT_POLICY_CONSTRAINTS = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_POLICY_CONSTRAINTS`"); // /usr/include/mbedtls/x509.h:184:9
pub const MBEDTLS_X509_EXT_EXTENDED_KEY_USAGE = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_EXTENDED_KEY_USAGE`"); // /usr/include/mbedtls/x509.h:185:9
pub const MBEDTLS_X509_EXT_CRL_DISTRIBUTION_POINTS = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_CRL_DISTRIBUTION_POINTS`"); // /usr/include/mbedtls/x509.h:186:9
pub const MBEDTLS_X509_EXT_INIHIBIT_ANYPOLICY = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_INIHIBIT_ANYPOLICY`"); // /usr/include/mbedtls/x509.h:187:9
pub const MBEDTLS_X509_EXT_FRESHEST_CRL = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_FRESHEST_CRL`"); // /usr/include/mbedtls/x509.h:188:9
pub const MBEDTLS_X509_EXT_NS_CERT_TYPE = @compileError("unable to translate macro: undefined identifier `MBEDTLS_OID_X509_EXT_NS_CERT_TYPE`"); // /usr/include/mbedtls/x509.h:189:9
pub const MBEDTLS_X509_FORMAT_DER = @as(c_int, 1);
pub const MBEDTLS_X509_FORMAT_PEM = @as(c_int, 2);
pub const MBEDTLS_X509_MAX_DN_NAME_SIZE = @as(c_int, 256);
pub const MBEDTLS_X509_SAFE_SNPRINTF = @compileError("unable to translate macro: undefined identifier `ret`"); // /usr/include/mbedtls/x509.h:487:9
pub const MBEDTLS_X509_CRL_H = "";
pub inline fn MBEDTLS_X509_ID_FLAG(id: anytype) @TypeOf(@as(c_int, 1) << (id - @as(c_int, 1))) {
    _ = &id;
    return @as(c_int, 1) << (id - @as(c_int, 1));
}
pub const MBEDTLS_X509_CRT_VERSION_1 = @as(c_int, 0);
pub const MBEDTLS_X509_CRT_VERSION_2 = @as(c_int, 1);
pub const MBEDTLS_X509_CRT_VERSION_3 = @as(c_int, 2);
pub const MBEDTLS_X509_RFC5280_MAX_SERIAL_LEN = @as(c_int, 20);
pub const MBEDTLS_X509_RFC5280_UTC_TIME_LEN = @as(c_int, 15);
pub const MBEDTLS_X509_MAX_FILE_PATH_LEN = @as(c_int, 512);
pub const MBEDTLS_X509_CRT_ERROR_INFO_LIST = @compileError("unable to translate macro: undefined identifier `X509_CRT_ERROR_INFO`"); // /usr/include/mbedtls/x509_crt.h:152:9
pub const MBEDTLS_X509_MAX_VERIFY_CHAIN_SIZE = MBEDTLS_X509_MAX_INTERMEDIATE_CA + @as(c_int, 2);
pub const MBEDTLS_DHM_H = "";
pub const MBEDTLS_ERR_DHM_BAD_INPUT_DATA = -@as(c_int, 0x3080);
pub const MBEDTLS_ERR_DHM_READ_PARAMS_FAILED = -@as(c_int, 0x3100);
pub const MBEDTLS_ERR_DHM_MAKE_PARAMS_FAILED = -@as(c_int, 0x3180);
pub const MBEDTLS_ERR_DHM_READ_PUBLIC_FAILED = -@as(c_int, 0x3200);
pub const MBEDTLS_ERR_DHM_MAKE_PUBLIC_FAILED = -@as(c_int, 0x3280);
pub const MBEDTLS_ERR_DHM_CALC_SECRET_FAILED = -@as(c_int, 0x3300);
pub const MBEDTLS_ERR_DHM_INVALID_FORMAT = -@as(c_int, 0x3380);
pub const MBEDTLS_ERR_DHM_ALLOC_FAILED = -@as(c_int, 0x3400);
pub const MBEDTLS_ERR_DHM_FILE_IO_ERROR = -@as(c_int, 0x3480);
pub const MBEDTLS_ERR_DHM_SET_GROUP_FAILED = -@as(c_int, 0x3580);
pub const MBEDTLS_DHM_RFC3526_MODP_2048_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:428:9
pub const MBEDTLS_DHM_RFC3526_MODP_2048_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:462:9
pub const MBEDTLS_DHM_RFC3526_MODP_3072_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:464:9
pub const MBEDTLS_DHM_RFC3526_MODP_3072_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:514:9
pub const MBEDTLS_DHM_RFC3526_MODP_4096_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:516:9
pub const MBEDTLS_DHM_RFC3526_MODP_4096_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:582:9
pub const MBEDTLS_DHM_RFC7919_FFDHE2048_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:584:9
pub const MBEDTLS_DHM_RFC7919_FFDHE2048_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:618:9
pub const MBEDTLS_DHM_RFC7919_FFDHE3072_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:620:9
pub const MBEDTLS_DHM_RFC7919_FFDHE3072_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:670:9
pub const MBEDTLS_DHM_RFC7919_FFDHE4096_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:672:9
pub const MBEDTLS_DHM_RFC7919_FFDHE4096_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:738:9
pub const MBEDTLS_DHM_RFC7919_FFDHE6144_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:740:9
pub const MBEDTLS_DHM_RFC7919_FFDHE6144_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:838:9
pub const MBEDTLS_DHM_RFC7919_FFDHE8192_P_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:840:9
pub const MBEDTLS_DHM_RFC7919_FFDHE8192_G_BIN = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/mbedtls/dhm.h:970:9
pub const MBEDTLS_ECDH_H = "";
pub const MBEDTLS_ERR_SSL_CRYPTO_IN_PROGRESS = -@as(c_int, 0x7000);
pub const MBEDTLS_ERR_SSL_FEATURE_UNAVAILABLE = -@as(c_int, 0x7080);
pub const MBEDTLS_ERR_SSL_BAD_INPUT_DATA = -@as(c_int, 0x7100);
pub const MBEDTLS_ERR_SSL_INVALID_MAC = -@as(c_int, 0x7180);
pub const MBEDTLS_ERR_SSL_INVALID_RECORD = -@as(c_int, 0x7200);
pub const MBEDTLS_ERR_SSL_CONN_EOF = -@as(c_int, 0x7280);
pub const MBEDTLS_ERR_SSL_DECODE_ERROR = -@as(c_int, 0x7300);
pub const MBEDTLS_ERR_SSL_NO_RNG = -@as(c_int, 0x7400);
pub const MBEDTLS_ERR_SSL_NO_CLIENT_CERTIFICATE = -@as(c_int, 0x7480);
pub const MBEDTLS_ERR_SSL_UNSUPPORTED_EXTENSION = -@as(c_int, 0x7500);
pub const MBEDTLS_ERR_SSL_NO_APPLICATION_PROTOCOL = -@as(c_int, 0x7580);
pub const MBEDTLS_ERR_SSL_PRIVATE_KEY_REQUIRED = -@as(c_int, 0x7600);
pub const MBEDTLS_ERR_SSL_CA_CHAIN_REQUIRED = -@as(c_int, 0x7680);
pub const MBEDTLS_ERR_SSL_UNEXPECTED_MESSAGE = -@as(c_int, 0x7700);
pub const MBEDTLS_ERR_SSL_FATAL_ALERT_MESSAGE = -@as(c_int, 0x7780);
pub const MBEDTLS_ERR_SSL_UNRECOGNIZED_NAME = -@as(c_int, 0x7800);
pub const MBEDTLS_ERR_SSL_PEER_CLOSE_NOTIFY = -@as(c_int, 0x7880);
pub const MBEDTLS_ERR_SSL_BAD_CERTIFICATE = -@as(c_int, 0x7A00);
pub const MBEDTLS_ERR_SSL_RECEIVED_NEW_SESSION_TICKET = -@as(c_int, 0x7B00);
pub const MBEDTLS_ERR_SSL_CANNOT_READ_EARLY_DATA = -@as(c_int, 0x7B80);
pub const MBEDTLS_ERR_SSL_RECEIVED_EARLY_DATA = -@as(c_int, 0x7C00);
pub const MBEDTLS_ERR_SSL_CANNOT_WRITE_EARLY_DATA = -@as(c_int, 0x7C80);
pub const MBEDTLS_ERR_SSL_CACHE_ENTRY_NOT_FOUND = -@as(c_int, 0x7E80);
pub const MBEDTLS_ERR_SSL_ALLOC_FAILED = -@as(c_int, 0x7F00);
pub const MBEDTLS_ERR_SSL_HW_ACCEL_FAILED = -@as(c_int, 0x7F80);
pub const MBEDTLS_ERR_SSL_HW_ACCEL_FALLTHROUGH = -@as(c_int, 0x6F80);
pub const MBEDTLS_ERR_SSL_BAD_PROTOCOL_VERSION = -@as(c_int, 0x6E80);
pub const MBEDTLS_ERR_SSL_HANDSHAKE_FAILURE = -@as(c_int, 0x6E00);
pub const MBEDTLS_ERR_SSL_SESSION_TICKET_EXPIRED = -@as(c_int, 0x6D80);
pub const MBEDTLS_ERR_SSL_PK_TYPE_MISMATCH = -@as(c_int, 0x6D00);
pub const MBEDTLS_ERR_SSL_UNKNOWN_IDENTITY = -@as(c_int, 0x6C80);
pub const MBEDTLS_ERR_SSL_INTERNAL_ERROR = -@as(c_int, 0x6C00);
pub const MBEDTLS_ERR_SSL_COUNTER_WRAPPING = -@as(c_int, 0x6B80);
pub const MBEDTLS_ERR_SSL_WAITING_SERVER_HELLO_RENEGO = -@as(c_int, 0x6B00);
pub const MBEDTLS_ERR_SSL_HELLO_VERIFY_REQUIRED = -@as(c_int, 0x6A80);
pub const MBEDTLS_ERR_SSL_BUFFER_TOO_SMALL = -@as(c_int, 0x6A00);
pub const MBEDTLS_ERR_SSL_WANT_READ = -@as(c_int, 0x6900);
pub const MBEDTLS_ERR_SSL_WANT_WRITE = -@as(c_int, 0x6880);
pub const MBEDTLS_ERR_SSL_TIMEOUT = -@as(c_int, 0x6800);
pub const MBEDTLS_ERR_SSL_CLIENT_RECONNECT = -@as(c_int, 0x6780);
pub const MBEDTLS_ERR_SSL_UNEXPECTED_RECORD = -@as(c_int, 0x6700);
pub const MBEDTLS_ERR_SSL_NON_FATAL = -@as(c_int, 0x6680);
pub const MBEDTLS_ERR_SSL_ILLEGAL_PARAMETER = -@as(c_int, 0x6600);
pub const MBEDTLS_ERR_SSL_CONTINUE_PROCESSING = -@as(c_int, 0x6580);
pub const MBEDTLS_ERR_SSL_ASYNC_IN_PROGRESS = -@as(c_int, 0x6500);
pub const MBEDTLS_ERR_SSL_EARLY_MESSAGE = -@as(c_int, 0x6480);
pub const MBEDTLS_ERR_SSL_UNEXPECTED_CID = -@as(c_int, 0x6000);
pub const MBEDTLS_ERR_SSL_VERSION_MISMATCH = -@as(c_int, 0x5F00);
pub const MBEDTLS_ERR_SSL_BAD_CONFIG = -@as(c_int, 0x5E80);
pub const MBEDTLS_ERR_SSL_CERTIFICATE_VERIFICATION_WITHOUT_HOSTNAME = -@as(c_int, 0x5D80);
pub const MBEDTLS_SSL_TLS1_3_PSK_MODE_PURE = @as(c_int, 0);
pub const MBEDTLS_SSL_TLS1_3_PSK_MODE_ECDHE = @as(c_int, 1);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_NONE = @as(c_int, 0);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP192K1 = @as(c_int, 0x0012);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP192R1 = @as(c_int, 0x0013);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP224K1 = @as(c_int, 0x0014);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP224R1 = @as(c_int, 0x0015);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP256K1 = @as(c_int, 0x0016);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP256R1 = @as(c_int, 0x0017);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP384R1 = @as(c_int, 0x0018);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_SECP521R1 = @as(c_int, 0x0019);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_BP256R1 = @as(c_int, 0x001A);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_BP384R1 = @as(c_int, 0x001B);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_BP512R1 = @as(c_int, 0x001C);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_X25519 = @as(c_int, 0x001D);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_X448 = @as(c_int, 0x001E);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_FFDHE2048 = @as(c_int, 0x0100);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_FFDHE3072 = @as(c_int, 0x0101);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_FFDHE4096 = @as(c_int, 0x0102);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_FFDHE6144 = @as(c_int, 0x0103);
pub const MBEDTLS_SSL_IANA_TLS_GROUP_FFDHE8192 = @as(c_int, 0x0104);
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK = @as(c_uint, 1) << @as(c_int, 0);
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_EPHEMERAL = @as(c_uint, 1) << @as(c_int, 1);
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_EPHEMERAL = @as(c_uint, 1) << @as(c_int, 2);
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_ALL = (MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK | MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_EPHEMERAL) | MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_EPHEMERAL;
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_ALL = MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK | MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_EPHEMERAL;
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_EPHEMERAL_ALL = MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_EPHEMERAL | MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_EPHEMERAL;
pub const MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_NONE = @as(c_int, 0);
pub const MBEDTLS_SSL_MAJOR_VERSION_3 = @as(c_int, 3);
pub const MBEDTLS_SSL_MINOR_VERSION_3 = @as(c_int, 3);
pub const MBEDTLS_SSL_MINOR_VERSION_4 = @as(c_int, 4);
pub const MBEDTLS_SSL_TRANSPORT_STREAM = @as(c_int, 0);
pub const MBEDTLS_SSL_TRANSPORT_DATAGRAM = @as(c_int, 1);
pub const MBEDTLS_SSL_MAX_HOST_NAME_LEN = @as(c_int, 255);
pub const MBEDTLS_SSL_MAX_ALPN_NAME_LEN = @as(c_int, 255);
pub const MBEDTLS_SSL_MAX_ALPN_LIST_LEN = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const MBEDTLS_SSL_MAX_FRAG_LEN_NONE = @as(c_int, 0);
pub const MBEDTLS_SSL_MAX_FRAG_LEN_512 = @as(c_int, 1);
pub const MBEDTLS_SSL_MAX_FRAG_LEN_1024 = @as(c_int, 2);
pub const MBEDTLS_SSL_MAX_FRAG_LEN_2048 = @as(c_int, 3);
pub const MBEDTLS_SSL_MAX_FRAG_LEN_4096 = @as(c_int, 4);
pub const MBEDTLS_SSL_MAX_FRAG_LEN_INVALID = @as(c_int, 5);
pub const MBEDTLS_SSL_IS_CLIENT = @as(c_int, 0);
pub const MBEDTLS_SSL_IS_SERVER = @as(c_int, 1);
pub const MBEDTLS_SSL_EXTENDED_MS_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_EXTENDED_MS_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_CID_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_CID_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_ETM_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_ETM_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_COMPRESS_NULL = @as(c_int, 0);
pub const MBEDTLS_SSL_VERIFY_NONE = @as(c_int, 0);
pub const MBEDTLS_SSL_VERIFY_OPTIONAL = @as(c_int, 1);
pub const MBEDTLS_SSL_VERIFY_REQUIRED = @as(c_int, 2);
pub const MBEDTLS_SSL_VERIFY_UNSET = @as(c_int, 3);
pub const MBEDTLS_SSL_LEGACY_RENEGOTIATION = @as(c_int, 0);
pub const MBEDTLS_SSL_SECURE_RENEGOTIATION = @as(c_int, 1);
pub const MBEDTLS_SSL_RENEGOTIATION_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_RENEGOTIATION_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_ANTI_REPLAY_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_ANTI_REPLAY_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_RENEGOTIATION_NOT_ENFORCED = -@as(c_int, 1);
pub const MBEDTLS_SSL_RENEGO_MAX_RECORDS_DEFAULT = @as(c_int, 16);
pub const MBEDTLS_SSL_LEGACY_NO_RENEGOTIATION = @as(c_int, 0);
pub const MBEDTLS_SSL_LEGACY_ALLOW_RENEGOTIATION = @as(c_int, 1);
pub const MBEDTLS_SSL_LEGACY_BREAK_HANDSHAKE = @as(c_int, 2);
pub const MBEDTLS_SSL_TRUNC_HMAC_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_TRUNC_HMAC_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_TRUNCATED_HMAC_LEN = @as(c_int, 10);
pub const MBEDTLS_SSL_SESSION_TICKETS_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_SESSION_TICKETS_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_TLS1_3_SIGNAL_NEW_SESSION_TICKETS_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_TLS1_3_SIGNAL_NEW_SESSION_TICKETS_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_PRESET_DEFAULT = @as(c_int, 0);
pub const MBEDTLS_SSL_PRESET_SUITEB = @as(c_int, 2);
pub const MBEDTLS_SSL_CERT_REQ_CA_LIST_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_CERT_REQ_CA_LIST_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_EARLY_DATA_DISABLED = @as(c_int, 0);
pub const MBEDTLS_SSL_EARLY_DATA_ENABLED = @as(c_int, 1);
pub const MBEDTLS_SSL_DTLS_SRTP_MKI_UNSUPPORTED = @as(c_int, 0);
pub const MBEDTLS_SSL_DTLS_SRTP_MKI_SUPPORTED = @as(c_int, 1);
pub const MBEDTLS_SSL_SRV_CIPHERSUITE_ORDER_CLIENT = @as(c_int, 1);
pub const MBEDTLS_SSL_SRV_CIPHERSUITE_ORDER_SERVER = @as(c_int, 0);
pub const MBEDTLS_SSL_TLS1_3_TICKET_RESUMPTION_KEY_LEN = @as(c_int, 48);
pub const MBEDTLS_SSL_DTLS_TIMEOUT_DFL_MIN = @as(c_int, 1000);
pub const MBEDTLS_SSL_DTLS_TIMEOUT_DFL_MAX = __helpers.promoteIntLiteral(c_int, 60000, .decimal);
pub const MBEDTLS_SSL_EARLY_DATA_NO_DISCARD = @as(c_int, 0);
pub const MBEDTLS_SSL_EARLY_DATA_TRY_TO_DEPROTECT_AND_DISCARD = @as(c_int, 1);
pub const MBEDTLS_SSL_EARLY_DATA_DISCARD = @as(c_int, 2);
pub const MBEDTLS_SSL_IN_CONTENT_LEN = @as(c_int, 16384);
pub const MBEDTLS_SSL_OUT_CONTENT_LEN = @as(c_int, 16384);
pub const MBEDTLS_SSL_DTLS_MAX_BUFFERING = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const MBEDTLS_SSL_CID_IN_LEN_MAX = @as(c_int, 32);
pub const MBEDTLS_SSL_CID_OUT_LEN_MAX = @as(c_int, 32);
pub const MBEDTLS_SSL_CID_TLS1_3_PADDING_GRANULARITY = @as(c_int, 16);
pub const MBEDTLS_SSL_MAX_EARLY_DATA_SIZE = @as(c_int, 1024);
pub const MBEDTLS_SSL_TLS1_3_TICKET_AGE_TOLERANCE = @as(c_int, 6000);
pub const MBEDTLS_SSL_TLS1_3_TICKET_NONCE_LENGTH = @as(c_int, 32);
pub const MBEDTLS_SSL_TLS1_3_DEFAULT_NEW_SESSION_TICKETS = @as(c_int, 1);
pub const MBEDTLS_SSL_VERIFY_DATA_MAX_LEN = @as(c_int, 12);
pub const MBEDTLS_SSL_EMPTY_RENEGOTIATION_INFO = @as(c_int, 0xFF);
pub const MBEDTLS_SSL_HASH_NONE = @as(c_int, 0);
pub const MBEDTLS_SSL_HASH_MD5 = @as(c_int, 1);
pub const MBEDTLS_SSL_HASH_SHA1 = @as(c_int, 2);
pub const MBEDTLS_SSL_HASH_SHA224 = @as(c_int, 3);
pub const MBEDTLS_SSL_HASH_SHA256 = @as(c_int, 4);
pub const MBEDTLS_SSL_HASH_SHA384 = @as(c_int, 5);
pub const MBEDTLS_SSL_HASH_SHA512 = @as(c_int, 6);
pub const MBEDTLS_SSL_SIG_ANON = @as(c_int, 0);
pub const MBEDTLS_SSL_SIG_RSA = @as(c_int, 1);
pub const MBEDTLS_SSL_SIG_ECDSA = @as(c_int, 3);
pub const MBEDTLS_TLS1_3_SIG_RSA_PKCS1_SHA256 = @as(c_int, 0x0401);
pub const MBEDTLS_TLS1_3_SIG_RSA_PKCS1_SHA384 = @as(c_int, 0x0501);
pub const MBEDTLS_TLS1_3_SIG_RSA_PKCS1_SHA512 = @as(c_int, 0x0601);
pub const MBEDTLS_TLS1_3_SIG_ECDSA_SECP256R1_SHA256 = @as(c_int, 0x0403);
pub const MBEDTLS_TLS1_3_SIG_ECDSA_SECP384R1_SHA384 = @as(c_int, 0x0503);
pub const MBEDTLS_TLS1_3_SIG_ECDSA_SECP521R1_SHA512 = @as(c_int, 0x0603);
pub const MBEDTLS_TLS1_3_SIG_RSA_PSS_RSAE_SHA256 = @as(c_int, 0x0804);
pub const MBEDTLS_TLS1_3_SIG_RSA_PSS_RSAE_SHA384 = @as(c_int, 0x0805);
pub const MBEDTLS_TLS1_3_SIG_RSA_PSS_RSAE_SHA512 = @as(c_int, 0x0806);
pub const MBEDTLS_TLS1_3_SIG_ED25519 = @as(c_int, 0x0807);
pub const MBEDTLS_TLS1_3_SIG_ED448 = @as(c_int, 0x0808);
pub const MBEDTLS_TLS1_3_SIG_RSA_PSS_PSS_SHA256 = @as(c_int, 0x0809);
pub const MBEDTLS_TLS1_3_SIG_RSA_PSS_PSS_SHA384 = @as(c_int, 0x080A);
pub const MBEDTLS_TLS1_3_SIG_RSA_PSS_PSS_SHA512 = @as(c_int, 0x080B);
pub const MBEDTLS_TLS1_3_SIG_RSA_PKCS1_SHA1 = @as(c_int, 0x0201);
pub const MBEDTLS_TLS1_3_SIG_ECDSA_SHA1 = @as(c_int, 0x0203);
pub const MBEDTLS_TLS1_3_SIG_NONE = @as(c_int, 0x0);
pub const MBEDTLS_SSL_CERT_TYPE_RSA_SIGN = @as(c_int, 1);
pub const MBEDTLS_SSL_CERT_TYPE_ECDSA_SIGN = @as(c_int, 64);
pub const MBEDTLS_SSL_MSG_CHANGE_CIPHER_SPEC = @as(c_int, 20);
pub const MBEDTLS_SSL_MSG_ALERT = @as(c_int, 21);
pub const MBEDTLS_SSL_MSG_HANDSHAKE = @as(c_int, 22);
pub const MBEDTLS_SSL_MSG_APPLICATION_DATA = @as(c_int, 23);
pub const MBEDTLS_SSL_MSG_CID = @as(c_int, 25);
pub const MBEDTLS_SSL_ALERT_LEVEL_WARNING = @as(c_int, 1);
pub const MBEDTLS_SSL_ALERT_LEVEL_FATAL = @as(c_int, 2);
pub const MBEDTLS_SSL_ALERT_MSG_CLOSE_NOTIFY = @as(c_int, 0);
pub const MBEDTLS_SSL_ALERT_MSG_UNEXPECTED_MESSAGE = @as(c_int, 10);
pub const MBEDTLS_SSL_ALERT_MSG_BAD_RECORD_MAC = @as(c_int, 20);
pub const MBEDTLS_SSL_ALERT_MSG_DECRYPTION_FAILED = @as(c_int, 21);
pub const MBEDTLS_SSL_ALERT_MSG_RECORD_OVERFLOW = @as(c_int, 22);
pub const MBEDTLS_SSL_ALERT_MSG_DECOMPRESSION_FAILURE = @as(c_int, 30);
pub const MBEDTLS_SSL_ALERT_MSG_HANDSHAKE_FAILURE = @as(c_int, 40);
pub const MBEDTLS_SSL_ALERT_MSG_NO_CERT = @as(c_int, 41);
pub const MBEDTLS_SSL_ALERT_MSG_BAD_CERT = @as(c_int, 42);
pub const MBEDTLS_SSL_ALERT_MSG_UNSUPPORTED_CERT = @as(c_int, 43);
pub const MBEDTLS_SSL_ALERT_MSG_CERT_REVOKED = @as(c_int, 44);
pub const MBEDTLS_SSL_ALERT_MSG_CERT_EXPIRED = @as(c_int, 45);
pub const MBEDTLS_SSL_ALERT_MSG_CERT_UNKNOWN = @as(c_int, 46);
pub const MBEDTLS_SSL_ALERT_MSG_ILLEGAL_PARAMETER = @as(c_int, 47);
pub const MBEDTLS_SSL_ALERT_MSG_UNKNOWN_CA = @as(c_int, 48);
pub const MBEDTLS_SSL_ALERT_MSG_ACCESS_DENIED = @as(c_int, 49);
pub const MBEDTLS_SSL_ALERT_MSG_DECODE_ERROR = @as(c_int, 50);
pub const MBEDTLS_SSL_ALERT_MSG_DECRYPT_ERROR = @as(c_int, 51);
pub const MBEDTLS_SSL_ALERT_MSG_EXPORT_RESTRICTION = @as(c_int, 60);
pub const MBEDTLS_SSL_ALERT_MSG_PROTOCOL_VERSION = @as(c_int, 70);
pub const MBEDTLS_SSL_ALERT_MSG_INSUFFICIENT_SECURITY = @as(c_int, 71);
pub const MBEDTLS_SSL_ALERT_MSG_INTERNAL_ERROR = @as(c_int, 80);
pub const MBEDTLS_SSL_ALERT_MSG_INAPROPRIATE_FALLBACK = @as(c_int, 86);
pub const MBEDTLS_SSL_ALERT_MSG_USER_CANCELED = @as(c_int, 90);
pub const MBEDTLS_SSL_ALERT_MSG_NO_RENEGOTIATION = @as(c_int, 100);
pub const MBEDTLS_SSL_ALERT_MSG_MISSING_EXTENSION = @as(c_int, 109);
pub const MBEDTLS_SSL_ALERT_MSG_UNSUPPORTED_EXT = @as(c_int, 110);
pub const MBEDTLS_SSL_ALERT_MSG_UNRECOGNIZED_NAME = @as(c_int, 112);
pub const MBEDTLS_SSL_ALERT_MSG_UNKNOWN_PSK_IDENTITY = @as(c_int, 115);
pub const MBEDTLS_SSL_ALERT_MSG_CERT_REQUIRED = @as(c_int, 116);
pub const MBEDTLS_SSL_ALERT_MSG_NO_APPLICATION_PROTOCOL = @as(c_int, 120);
pub const MBEDTLS_SSL_HS_HELLO_REQUEST = @as(c_int, 0);
pub const MBEDTLS_SSL_HS_CLIENT_HELLO = @as(c_int, 1);
pub const MBEDTLS_SSL_HS_SERVER_HELLO = @as(c_int, 2);
pub const MBEDTLS_SSL_HS_HELLO_VERIFY_REQUEST = @as(c_int, 3);
pub const MBEDTLS_SSL_HS_NEW_SESSION_TICKET = @as(c_int, 4);
pub const MBEDTLS_SSL_HS_END_OF_EARLY_DATA = @as(c_int, 5);
pub const MBEDTLS_SSL_HS_ENCRYPTED_EXTENSIONS = @as(c_int, 8);
pub const MBEDTLS_SSL_HS_CERTIFICATE = @as(c_int, 11);
pub const MBEDTLS_SSL_HS_SERVER_KEY_EXCHANGE = @as(c_int, 12);
pub const MBEDTLS_SSL_HS_CERTIFICATE_REQUEST = @as(c_int, 13);
pub const MBEDTLS_SSL_HS_SERVER_HELLO_DONE = @as(c_int, 14);
pub const MBEDTLS_SSL_HS_CERTIFICATE_VERIFY = @as(c_int, 15);
pub const MBEDTLS_SSL_HS_CLIENT_KEY_EXCHANGE = @as(c_int, 16);
pub const MBEDTLS_SSL_HS_FINISHED = @as(c_int, 20);
pub const MBEDTLS_SSL_HS_MESSAGE_HASH = @as(c_int, 254);
pub const MBEDTLS_TLS_EXT_SERVERNAME = @as(c_int, 0);
pub const MBEDTLS_TLS_EXT_SERVERNAME_HOSTNAME = @as(c_int, 0);
pub const MBEDTLS_TLS_EXT_MAX_FRAGMENT_LENGTH = @as(c_int, 1);
pub const MBEDTLS_TLS_EXT_TRUNCATED_HMAC = @as(c_int, 4);
pub const MBEDTLS_TLS_EXT_STATUS_REQUEST = @as(c_int, 5);
pub const MBEDTLS_TLS_EXT_SUPPORTED_ELLIPTIC_CURVES = @as(c_int, 10);
pub const MBEDTLS_TLS_EXT_SUPPORTED_GROUPS = @as(c_int, 10);
pub const MBEDTLS_TLS_EXT_SUPPORTED_POINT_FORMATS = @as(c_int, 11);
pub const MBEDTLS_TLS_EXT_SIG_ALG = @as(c_int, 13);
pub const MBEDTLS_TLS_EXT_USE_SRTP = @as(c_int, 14);
pub const MBEDTLS_TLS_EXT_HEARTBEAT = @as(c_int, 15);
pub const MBEDTLS_TLS_EXT_ALPN = @as(c_int, 16);
pub const MBEDTLS_TLS_EXT_SCT = @as(c_int, 18);
pub const MBEDTLS_TLS_EXT_CLI_CERT_TYPE = @as(c_int, 19);
pub const MBEDTLS_TLS_EXT_SERV_CERT_TYPE = @as(c_int, 20);
pub const MBEDTLS_TLS_EXT_PADDING = @as(c_int, 21);
pub const MBEDTLS_TLS_EXT_ENCRYPT_THEN_MAC = @as(c_int, 22);
pub const MBEDTLS_TLS_EXT_EXTENDED_MASTER_SECRET = @as(c_int, 0x0017);
pub const MBEDTLS_TLS_EXT_RECORD_SIZE_LIMIT = @as(c_int, 28);
pub const MBEDTLS_TLS_EXT_SESSION_TICKET = @as(c_int, 35);
pub const MBEDTLS_TLS_EXT_PRE_SHARED_KEY = @as(c_int, 41);
pub const MBEDTLS_TLS_EXT_EARLY_DATA = @as(c_int, 42);
pub const MBEDTLS_TLS_EXT_SUPPORTED_VERSIONS = @as(c_int, 43);
pub const MBEDTLS_TLS_EXT_COOKIE = @as(c_int, 44);
pub const MBEDTLS_TLS_EXT_PSK_KEY_EXCHANGE_MODES = @as(c_int, 45);
pub const MBEDTLS_TLS_EXT_CERT_AUTH = @as(c_int, 47);
pub const MBEDTLS_TLS_EXT_OID_FILTERS = @as(c_int, 48);
pub const MBEDTLS_TLS_EXT_POST_HANDSHAKE_AUTH = @as(c_int, 49);
pub const MBEDTLS_TLS_EXT_SIG_ALG_CERT = @as(c_int, 50);
pub const MBEDTLS_TLS_EXT_KEY_SHARE = @as(c_int, 51);
pub const MBEDTLS_TLS_EXT_CID = @as(c_int, 54);
pub const MBEDTLS_TLS_EXT_ECJPAKE_KKPP = @as(c_int, 256);
pub const MBEDTLS_TLS_EXT_RENEGOTIATION_INFO = __helpers.promoteIntLiteral(c_int, 0xFF01, .hex);
pub const MBEDTLS_PSK_MAX_LEN = @as(c_int, 48);
pub const MBEDTLS_PREMASTER_SIZE = __helpers.sizeof(union_mbedtls_ssl_premaster_secret);
pub const MBEDTLS_TLS1_3_MD_MAX_SIZE = PSA_HASH_MAX_SIZE;
pub const MBEDTLS_SSL_SEQUENCE_NUMBER_LEN = @as(c_int, 8);
pub const MBEDTLS_SSL_KEEP_RANDBYTES = "";
pub const MBEDTLS_SSL_TLS1_3_TICKET_ALLOW_PSK_RESUMPTION = MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK;
pub const MBEDTLS_SSL_TLS1_3_TICKET_ALLOW_PSK_EPHEMERAL_RESUMPTION = MBEDTLS_SSL_TLS1_3_KEY_EXCHANGE_MODE_PSK_EPHEMERAL;
pub const MBEDTLS_SSL_TLS1_3_TICKET_ALLOW_EARLY_DATA = @as(c_uint, 1) << @as(c_int, 3);
pub const MBEDTLS_SSL_TLS1_3_TICKET_FLAGS_MASK = (MBEDTLS_SSL_TLS1_3_TICKET_ALLOW_PSK_RESUMPTION | MBEDTLS_SSL_TLS1_3_TICKET_ALLOW_PSK_EPHEMERAL_RESUMPTION) | MBEDTLS_SSL_TLS1_3_TICKET_ALLOW_EARLY_DATA;
pub const MBEDTLS_SSL_UNEXPECTED_CID_IGNORE = @as(c_int, 0);
pub const MBEDTLS_SSL_UNEXPECTED_CID_FAIL = @as(c_int, 1);
pub const MBEDTLS_SSL_EXPORT_MAX_KEY_LEN = @as(c_int, 8160);
pub const MBEDTLS_ERR_NET_SOCKET_FAILED = -@as(c_int, 0x0042);
pub const MBEDTLS_ERR_NET_CONNECT_FAILED = -@as(c_int, 0x0044);
pub const MBEDTLS_ERR_NET_BIND_FAILED = -@as(c_int, 0x0046);
pub const MBEDTLS_ERR_NET_LISTEN_FAILED = -@as(c_int, 0x0048);
pub const MBEDTLS_ERR_NET_ACCEPT_FAILED = -@as(c_int, 0x004A);
pub const MBEDTLS_ERR_NET_RECV_FAILED = -@as(c_int, 0x004C);
pub const MBEDTLS_ERR_NET_SEND_FAILED = -@as(c_int, 0x004E);
pub const MBEDTLS_ERR_NET_CONN_RESET = -@as(c_int, 0x0050);
pub const MBEDTLS_ERR_NET_UNKNOWN_HOST = -@as(c_int, 0x0052);
pub const MBEDTLS_ERR_NET_BUFFER_TOO_SMALL = -@as(c_int, 0x0043);
pub const MBEDTLS_ERR_NET_INVALID_CONTEXT = -@as(c_int, 0x0045);
pub const MBEDTLS_ERR_NET_POLL_FAILED = -@as(c_int, 0x0047);
pub const MBEDTLS_ERR_NET_BAD_INPUT_DATA = -@as(c_int, 0x0049);
pub const MBEDTLS_NET_LISTEN_BACKLOG = @as(c_int, 10);
pub const MBEDTLS_NET_PROTO_TCP = @as(c_int, 0);
pub const MBEDTLS_NET_PROTO_UDP = @as(c_int, 1);
pub const MBEDTLS_NET_POLL_READ = @as(c_int, 1);
pub const MBEDTLS_NET_POLL_WRITE = @as(c_int, 2);
pub const MBEDTLS_ENTROPY_H = "";
pub const MBEDTLS_ENTROPY_SHA512_ACCUMULATOR = "";
pub const MBEDTLS_ENTROPY_MD = MBEDTLS_MD_SHA512;
pub const MBEDTLS_ENTROPY_BLOCK_SIZE = @as(c_int, 64);
pub const MBEDTLS_ERR_ENTROPY_SOURCE_FAILED = -@as(c_int, 0x003C);
pub const MBEDTLS_ERR_ENTROPY_MAX_SOURCES = -@as(c_int, 0x003E);
pub const MBEDTLS_ERR_ENTROPY_NO_SOURCES_DEFINED = -@as(c_int, 0x0040);
pub const MBEDTLS_ERR_ENTROPY_NO_STRONG_SOURCE = -@as(c_int, 0x003D);
pub const MBEDTLS_ERR_ENTROPY_FILE_IO_ERROR = -@as(c_int, 0x003F);
pub const MBEDTLS_ENTROPY_MAX_SOURCES = @as(c_int, 20);
pub const MBEDTLS_ENTROPY_MAX_GATHER = @as(c_int, 128);
pub const MBEDTLS_ENTROPY_MAX_SEED_SIZE = @as(c_int, 1024);
pub const MBEDTLS_ENTROPY_SOURCE_MANUAL = MBEDTLS_ENTROPY_MAX_SOURCES;
pub const MBEDTLS_ENTROPY_SOURCE_STRONG = @as(c_int, 1);
pub const MBEDTLS_ENTROPY_SOURCE_WEAK = @as(c_int, 0);
pub const MBEDTLS_CTR_DRBG_H = "";
pub const MBEDTLS_AES_H = "";
pub const MBEDTLS_AES_ENCRYPT = @as(c_int, 1);
pub const MBEDTLS_AES_DECRYPT = @as(c_int, 0);
pub const MBEDTLS_ERR_AES_INVALID_KEY_LENGTH = -@as(c_int, 0x0020);
pub const MBEDTLS_ERR_AES_INVALID_INPUT_LENGTH = -@as(c_int, 0x0022);
pub const MBEDTLS_ERR_AES_BAD_INPUT_DATA = -@as(c_int, 0x0021);
pub const MBEDTLS_ERR_CTR_DRBG_ENTROPY_SOURCE_FAILED = -@as(c_int, 0x0034);
pub const MBEDTLS_ERR_CTR_DRBG_REQUEST_TOO_BIG = -@as(c_int, 0x0036);
pub const MBEDTLS_ERR_CTR_DRBG_INPUT_TOO_BIG = -@as(c_int, 0x0038);
pub const MBEDTLS_ERR_CTR_DRBG_FILE_IO_ERROR = -@as(c_int, 0x003A);
pub const MBEDTLS_CTR_DRBG_BLOCKSIZE = @as(c_int, 16);
pub const MBEDTLS_CTR_DRBG_KEYSIZE = @as(c_int, 32);
pub const MBEDTLS_CTR_DRBG_KEYBITS = MBEDTLS_CTR_DRBG_KEYSIZE * @as(c_int, 8);
pub const MBEDTLS_CTR_DRBG_SEEDLEN = MBEDTLS_CTR_DRBG_KEYSIZE + MBEDTLS_CTR_DRBG_BLOCKSIZE;
pub const MBEDTLS_CTR_DRBG_ENTROPY_LEN = @as(c_int, 48);
pub const MBEDTLS_CTR_DRBG_RESEED_INTERVAL = @as(c_int, 10000);
pub const MBEDTLS_CTR_DRBG_MAX_INPUT = @as(c_int, 256);
pub const MBEDTLS_CTR_DRBG_MAX_REQUEST = @as(c_int, 1024);
pub const MBEDTLS_CTR_DRBG_MAX_SEED_INPUT = @as(c_int, 384);
pub const MBEDTLS_CTR_DRBG_PR_OFF = @as(c_int, 0);
pub const MBEDTLS_CTR_DRBG_PR_ON = @as(c_int, 1);
pub const MBEDTLS_CTR_DRBG_ENTROPY_NONCE_LEN = @as(c_int, 0);
pub const MBEDTLS_ERROR_H = "";
pub const MBEDTLS_ERR_ERROR_GENERIC_ERROR = -@as(c_int, 0x0001);
pub const MBEDTLS_ERR_ERROR_CORRUPTION_DETECTED = -@as(c_int, 0x006E);
pub const MBEDTLS_ERR_PLATFORM_HW_ACCEL_FAILED = -@as(c_int, 0x0070);
pub const MBEDTLS_ERR_PLATFORM_FEATURE_UNSUPPORTED = -@as(c_int, 0x0072);
pub const MBEDTLS_ERROR_ADD = @compileError("unable to translate macro: undefined identifier `__FILE__`"); // /usr/include/mbedtls/error.h:113:9
pub const tm = struct_tm;
pub const timespec = struct_timespec;
pub const itimerspec = struct_itimerspec;
pub const __locale_struct = struct___locale_struct;
pub const sigevent = struct_sigevent;
pub const _G_fpos_t = struct__G_fpos_t;
pub const _G_fpos64_t = struct__G_fpos64_t;
pub const _IO_marker = struct__IO_marker;
pub const _IO_FILE = struct__IO_FILE;
pub const _IO_cookie_io_functions_t = struct__IO_cookie_io_functions_t;
pub const timeval = struct_timeval;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const random_data = struct_random_data;
pub const drand48_data = struct_drand48_data;
pub const sched_param = struct_sched_param;
pub const __jmp_buf_tag = struct___jmp_buf_tag;
pub const _pthread_cleanup_buffer = struct__pthread_cleanup_buffer;
pub const __cancel_jmp_buf_tag = struct___cancel_jmp_buf_tag;
pub const __pthread_cleanup_frame = struct___pthread_cleanup_frame;
pub const psa_key_policy_s = struct_psa_key_policy_s;
pub const psa_key_attributes_s = struct_psa_key_attributes_s;
pub const psa_custom_key_parameters_s = struct_psa_custom_key_parameters_s;
pub const psa_key_production_parameters_s = struct_psa_key_production_parameters_s;
pub const psa_hash_operation_s = struct_psa_hash_operation_s;
pub const psa_cipher_operation_s = struct_psa_cipher_operation_s;
pub const psa_mac_operation_s = struct_psa_mac_operation_s;
pub const psa_aead_operation_s = struct_psa_aead_operation_s;
pub const psa_tls12_prf_key_derivation_s = struct_psa_tls12_prf_key_derivation_s;
pub const psa_key_derivation_s = struct_psa_key_derivation_s;
pub const psa_sign_hash_interruptible_operation_s = struct_psa_sign_hash_interruptible_operation_s;
pub const psa_verify_hash_interruptible_operation_s = struct_psa_verify_hash_interruptible_operation_s;
pub const mbedtls_psa_stats_s = struct_mbedtls_psa_stats_s;
pub const psa_pake_cipher_suite_s = struct_psa_pake_cipher_suite_s;
pub const psa_crypto_driver_pake_inputs_s = struct_psa_crypto_driver_pake_inputs_s;
pub const psa_crypto_driver_pake_step = enum_psa_crypto_driver_pake_step;
pub const psa_jpake_round = enum_psa_jpake_round;
pub const psa_jpake_io_mode = enum_psa_jpake_io_mode;
pub const psa_jpake_computation_stage_s = struct_psa_jpake_computation_stage_s;
pub const psa_pake_operation_s = struct_psa_pake_operation_s;
pub const mbedtls_ssl_premaster_secret = union_mbedtls_ssl_premaster_secret;
