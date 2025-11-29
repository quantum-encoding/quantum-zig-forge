const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;

pub const __s8 = i8;
pub const __u8 = u8;
pub const __s16 = c_short;
pub const __u16 = c_ushort;
pub const __s32 = c_int;
pub const __u32 = c_uint;
pub const __s64 = c_longlong;
pub const __u64 = c_ulonglong;
pub const __kernel_fd_set = extern struct {
    fds_bits: [16]c_ulong = @import("std").mem.zeroes([16]c_ulong),
};
pub const __kernel_sighandler_t = ?*const fn (c_int) callconv(.c) void;
pub const __kernel_key_t = c_int;
pub const __kernel_mqd_t = c_int;
pub const __kernel_old_uid_t = c_ushort;
pub const __kernel_old_gid_t = c_ushort;
pub const __kernel_old_dev_t = c_ulong;
pub const __kernel_long_t = c_long;
pub const __kernel_ulong_t = c_ulong;
pub const __kernel_ino_t = __kernel_ulong_t;
pub const __kernel_mode_t = c_uint;
pub const __kernel_pid_t = c_int;
pub const __kernel_ipc_pid_t = c_int;
pub const __kernel_uid_t = c_uint;
pub const __kernel_gid_t = c_uint;
pub const __kernel_suseconds_t = __kernel_long_t;
pub const __kernel_daddr_t = c_int;
pub const __kernel_uid32_t = c_uint;
pub const __kernel_gid32_t = c_uint;
pub const __kernel_size_t = __kernel_ulong_t;
pub const __kernel_ssize_t = __kernel_long_t;
pub const __kernel_ptrdiff_t = __kernel_long_t;
pub const __kernel_fsid_t = extern struct {
    val: [2]c_int = @import("std").mem.zeroes([2]c_int),
};
pub const __kernel_off_t = __kernel_long_t;
pub const __kernel_loff_t = c_longlong;
pub const __kernel_old_time_t = __kernel_long_t;
pub const __kernel_time_t = __kernel_long_t;
pub const __kernel_time64_t = c_longlong;
pub const __kernel_clock_t = __kernel_long_t;
pub const __kernel_timer_t = c_int;
pub const __kernel_clockid_t = c_int;
pub const __kernel_caddr_t = [*c]u8;
pub const __kernel_uid16_t = c_ushort;
pub const __kernel_gid16_t = c_ushort;
pub const __s128 = i128;
pub const __u128 = u128;
pub const __le16 = __u16;
pub const __be16 = __u16;
pub const __le32 = __u32;
pub const __be32 = __u32;
pub const __le64 = __u64;
pub const __be64 = __u64;
pub const __sum16 = __u16;
pub const __wsum = __u32;
pub const __poll_t = c_uint;
pub const BPF_MAY_GOTO: c_int = 0;
pub const enum_bpf_cond_pseudo_jmp = c_uint;
pub const BPF_REG_0: c_int = 0;
pub const BPF_REG_1: c_int = 1;
pub const BPF_REG_2: c_int = 2;
pub const BPF_REG_3: c_int = 3;
pub const BPF_REG_4: c_int = 4;
pub const BPF_REG_5: c_int = 5;
pub const BPF_REG_6: c_int = 6;
pub const BPF_REG_7: c_int = 7;
pub const BPF_REG_8: c_int = 8;
pub const BPF_REG_9: c_int = 9;
pub const BPF_REG_10: c_int = 10;
pub const __MAX_BPF_REG: c_int = 11;
const enum_unnamed_1 = c_uint; // /usr/include/linux/bpf.h:82:7: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_insn = opaque {};
pub const struct_bpf_lpm_trie_key = extern struct {
    prefixlen: __u32 = 0,
    _data: [0]__u8 = @import("std").mem.zeroes([0]__u8),
    pub fn data(self: anytype) __helpers.FlexibleArrayType(@TypeOf(self), @typeInfo(@TypeOf(self.*._data)).array.child) {
        return @ptrCast(@alignCast(&self.*._data));
    }
};
pub const struct_bpf_lpm_trie_key_hdr = extern struct {
    prefixlen: __u32 = 0,
};
const union_unnamed_2 = extern union {
    hdr: struct_bpf_lpm_trie_key_hdr,
    prefixlen: __u32,
};
pub const struct_bpf_lpm_trie_key_u8 = extern struct {
    unnamed_0: union_unnamed_2 = @import("std").mem.zeroes(union_unnamed_2),
    _data: [0]__u8 = @import("std").mem.zeroes([0]__u8),
    pub fn data(self: anytype) __helpers.FlexibleArrayType(@TypeOf(self), @typeInfo(@TypeOf(self.*._data)).array.child) {
        return @ptrCast(@alignCast(&self.*._data));
    }
};
pub const struct_bpf_cgroup_storage_key = extern struct {
    cgroup_inode_id: __u64 = 0,
    attach_type: __u32 = 0,
};
pub const BPF_CGROUP_ITER_ORDER_UNSPEC: c_int = 0;
pub const BPF_CGROUP_ITER_SELF_ONLY: c_int = 1;
pub const BPF_CGROUP_ITER_DESCENDANTS_PRE: c_int = 2;
pub const BPF_CGROUP_ITER_DESCENDANTS_POST: c_int = 3;
pub const BPF_CGROUP_ITER_ANCESTORS_UP: c_int = 4;
pub const enum_bpf_cgroup_iter_order = c_uint;
const struct_unnamed_3 = extern struct {
    map_fd: __u32 = 0,
};
const struct_unnamed_4 = extern struct {
    order: enum_bpf_cgroup_iter_order = @import("std").mem.zeroes(enum_bpf_cgroup_iter_order),
    cgroup_fd: __u32 = 0,
    cgroup_id: __u64 = 0,
};
const struct_unnamed_5 = extern struct {
    tid: __u32 = 0,
    pid: __u32 = 0,
    pid_fd: __u32 = 0,
};
pub const union_bpf_iter_link_info = extern union {
    map: struct_unnamed_3,
    cgroup: struct_unnamed_4,
    task: struct_unnamed_5,
};
pub const BPF_MAP_CREATE: c_int = 0;
pub const BPF_MAP_LOOKUP_ELEM: c_int = 1;
pub const BPF_MAP_UPDATE_ELEM: c_int = 2;
pub const BPF_MAP_DELETE_ELEM: c_int = 3;
pub const BPF_MAP_GET_NEXT_KEY: c_int = 4;
pub const BPF_PROG_LOAD: c_int = 5;
pub const BPF_OBJ_PIN: c_int = 6;
pub const BPF_OBJ_GET: c_int = 7;
pub const BPF_PROG_ATTACH: c_int = 8;
pub const BPF_PROG_DETACH: c_int = 9;
pub const BPF_PROG_TEST_RUN: c_int = 10;
pub const BPF_PROG_RUN: c_int = 10;
pub const BPF_PROG_GET_NEXT_ID: c_int = 11;
pub const BPF_MAP_GET_NEXT_ID: c_int = 12;
pub const BPF_PROG_GET_FD_BY_ID: c_int = 13;
pub const BPF_MAP_GET_FD_BY_ID: c_int = 14;
pub const BPF_OBJ_GET_INFO_BY_FD: c_int = 15;
pub const BPF_PROG_QUERY: c_int = 16;
pub const BPF_RAW_TRACEPOINT_OPEN: c_int = 17;
pub const BPF_BTF_LOAD: c_int = 18;
pub const BPF_BTF_GET_FD_BY_ID: c_int = 19;
pub const BPF_TASK_FD_QUERY: c_int = 20;
pub const BPF_MAP_LOOKUP_AND_DELETE_ELEM: c_int = 21;
pub const BPF_MAP_FREEZE: c_int = 22;
pub const BPF_BTF_GET_NEXT_ID: c_int = 23;
pub const BPF_MAP_LOOKUP_BATCH: c_int = 24;
pub const BPF_MAP_LOOKUP_AND_DELETE_BATCH: c_int = 25;
pub const BPF_MAP_UPDATE_BATCH: c_int = 26;
pub const BPF_MAP_DELETE_BATCH: c_int = 27;
pub const BPF_LINK_CREATE: c_int = 28;
pub const BPF_LINK_UPDATE: c_int = 29;
pub const BPF_LINK_GET_FD_BY_ID: c_int = 30;
pub const BPF_LINK_GET_NEXT_ID: c_int = 31;
pub const BPF_ENABLE_STATS: c_int = 32;
pub const BPF_ITER_CREATE: c_int = 33;
pub const BPF_LINK_DETACH: c_int = 34;
pub const BPF_PROG_BIND_MAP: c_int = 35;
pub const BPF_TOKEN_CREATE: c_int = 36;
pub const BPF_PROG_STREAM_READ_BY_FD: c_int = 37;
pub const __MAX_BPF_CMD: c_int = 38;
pub const enum_bpf_cmd = c_uint;
pub const BPF_MAP_TYPE_UNSPEC: c_int = 0;
pub const BPF_MAP_TYPE_HASH: c_int = 1;
pub const BPF_MAP_TYPE_ARRAY: c_int = 2;
pub const BPF_MAP_TYPE_PROG_ARRAY: c_int = 3;
pub const BPF_MAP_TYPE_PERF_EVENT_ARRAY: c_int = 4;
pub const BPF_MAP_TYPE_PERCPU_HASH: c_int = 5;
pub const BPF_MAP_TYPE_PERCPU_ARRAY: c_int = 6;
pub const BPF_MAP_TYPE_STACK_TRACE: c_int = 7;
pub const BPF_MAP_TYPE_CGROUP_ARRAY: c_int = 8;
pub const BPF_MAP_TYPE_LRU_HASH: c_int = 9;
pub const BPF_MAP_TYPE_LRU_PERCPU_HASH: c_int = 10;
pub const BPF_MAP_TYPE_LPM_TRIE: c_int = 11;
pub const BPF_MAP_TYPE_ARRAY_OF_MAPS: c_int = 12;
pub const BPF_MAP_TYPE_HASH_OF_MAPS: c_int = 13;
pub const BPF_MAP_TYPE_DEVMAP: c_int = 14;
pub const BPF_MAP_TYPE_SOCKMAP: c_int = 15;
pub const BPF_MAP_TYPE_CPUMAP: c_int = 16;
pub const BPF_MAP_TYPE_XSKMAP: c_int = 17;
pub const BPF_MAP_TYPE_SOCKHASH: c_int = 18;
pub const BPF_MAP_TYPE_CGROUP_STORAGE_DEPRECATED: c_int = 19;
pub const BPF_MAP_TYPE_CGROUP_STORAGE: c_int = 19;
pub const BPF_MAP_TYPE_REUSEPORT_SOCKARRAY: c_int = 20;
pub const BPF_MAP_TYPE_PERCPU_CGROUP_STORAGE_DEPRECATED: c_int = 21;
pub const BPF_MAP_TYPE_PERCPU_CGROUP_STORAGE: c_int = 21;
pub const BPF_MAP_TYPE_QUEUE: c_int = 22;
pub const BPF_MAP_TYPE_STACK: c_int = 23;
pub const BPF_MAP_TYPE_SK_STORAGE: c_int = 24;
pub const BPF_MAP_TYPE_DEVMAP_HASH: c_int = 25;
pub const BPF_MAP_TYPE_STRUCT_OPS: c_int = 26;
pub const BPF_MAP_TYPE_RINGBUF: c_int = 27;
pub const BPF_MAP_TYPE_INODE_STORAGE: c_int = 28;
pub const BPF_MAP_TYPE_TASK_STORAGE: c_int = 29;
pub const BPF_MAP_TYPE_BLOOM_FILTER: c_int = 30;
pub const BPF_MAP_TYPE_USER_RINGBUF: c_int = 31;
pub const BPF_MAP_TYPE_CGRP_STORAGE: c_int = 32;
pub const BPF_MAP_TYPE_ARENA: c_int = 33;
pub const __MAX_BPF_MAP_TYPE: c_int = 34;
pub const enum_bpf_map_type = c_uint;
pub const BPF_PROG_TYPE_UNSPEC: c_int = 0;
pub const BPF_PROG_TYPE_SOCKET_FILTER: c_int = 1;
pub const BPF_PROG_TYPE_KPROBE: c_int = 2;
pub const BPF_PROG_TYPE_SCHED_CLS: c_int = 3;
pub const BPF_PROG_TYPE_SCHED_ACT: c_int = 4;
pub const BPF_PROG_TYPE_TRACEPOINT: c_int = 5;
pub const BPF_PROG_TYPE_XDP: c_int = 6;
pub const BPF_PROG_TYPE_PERF_EVENT: c_int = 7;
pub const BPF_PROG_TYPE_CGROUP_SKB: c_int = 8;
pub const BPF_PROG_TYPE_CGROUP_SOCK: c_int = 9;
pub const BPF_PROG_TYPE_LWT_IN: c_int = 10;
pub const BPF_PROG_TYPE_LWT_OUT: c_int = 11;
pub const BPF_PROG_TYPE_LWT_XMIT: c_int = 12;
pub const BPF_PROG_TYPE_SOCK_OPS: c_int = 13;
pub const BPF_PROG_TYPE_SK_SKB: c_int = 14;
pub const BPF_PROG_TYPE_CGROUP_DEVICE: c_int = 15;
pub const BPF_PROG_TYPE_SK_MSG: c_int = 16;
pub const BPF_PROG_TYPE_RAW_TRACEPOINT: c_int = 17;
pub const BPF_PROG_TYPE_CGROUP_SOCK_ADDR: c_int = 18;
pub const BPF_PROG_TYPE_LWT_SEG6LOCAL: c_int = 19;
pub const BPF_PROG_TYPE_LIRC_MODE2: c_int = 20;
pub const BPF_PROG_TYPE_SK_REUSEPORT: c_int = 21;
pub const BPF_PROG_TYPE_FLOW_DISSECTOR: c_int = 22;
pub const BPF_PROG_TYPE_CGROUP_SYSCTL: c_int = 23;
pub const BPF_PROG_TYPE_RAW_TRACEPOINT_WRITABLE: c_int = 24;
pub const BPF_PROG_TYPE_CGROUP_SOCKOPT: c_int = 25;
pub const BPF_PROG_TYPE_TRACING: c_int = 26;
pub const BPF_PROG_TYPE_STRUCT_OPS: c_int = 27;
pub const BPF_PROG_TYPE_EXT: c_int = 28;
pub const BPF_PROG_TYPE_LSM: c_int = 29;
pub const BPF_PROG_TYPE_SK_LOOKUP: c_int = 30;
pub const BPF_PROG_TYPE_SYSCALL: c_int = 31;
pub const BPF_PROG_TYPE_NETFILTER: c_int = 32;
pub const __MAX_BPF_PROG_TYPE: c_int = 33;
pub const enum_bpf_prog_type = c_uint;
pub const BPF_CGROUP_INET_INGRESS: c_int = 0;
pub const BPF_CGROUP_INET_EGRESS: c_int = 1;
pub const BPF_CGROUP_INET_SOCK_CREATE: c_int = 2;
pub const BPF_CGROUP_SOCK_OPS: c_int = 3;
pub const BPF_SK_SKB_STREAM_PARSER: c_int = 4;
pub const BPF_SK_SKB_STREAM_VERDICT: c_int = 5;
pub const BPF_CGROUP_DEVICE: c_int = 6;
pub const BPF_SK_MSG_VERDICT: c_int = 7;
pub const BPF_CGROUP_INET4_BIND: c_int = 8;
pub const BPF_CGROUP_INET6_BIND: c_int = 9;
pub const BPF_CGROUP_INET4_CONNECT: c_int = 10;
pub const BPF_CGROUP_INET6_CONNECT: c_int = 11;
pub const BPF_CGROUP_INET4_POST_BIND: c_int = 12;
pub const BPF_CGROUP_INET6_POST_BIND: c_int = 13;
pub const BPF_CGROUP_UDP4_SENDMSG: c_int = 14;
pub const BPF_CGROUP_UDP6_SENDMSG: c_int = 15;
pub const BPF_LIRC_MODE2: c_int = 16;
pub const BPF_FLOW_DISSECTOR: c_int = 17;
pub const BPF_CGROUP_SYSCTL: c_int = 18;
pub const BPF_CGROUP_UDP4_RECVMSG: c_int = 19;
pub const BPF_CGROUP_UDP6_RECVMSG: c_int = 20;
pub const BPF_CGROUP_GETSOCKOPT: c_int = 21;
pub const BPF_CGROUP_SETSOCKOPT: c_int = 22;
pub const BPF_TRACE_RAW_TP: c_int = 23;
pub const BPF_TRACE_FENTRY: c_int = 24;
pub const BPF_TRACE_FEXIT: c_int = 25;
pub const BPF_MODIFY_RETURN: c_int = 26;
pub const BPF_LSM_MAC: c_int = 27;
pub const BPF_TRACE_ITER: c_int = 28;
pub const BPF_CGROUP_INET4_GETPEERNAME: c_int = 29;
pub const BPF_CGROUP_INET6_GETPEERNAME: c_int = 30;
pub const BPF_CGROUP_INET4_GETSOCKNAME: c_int = 31;
pub const BPF_CGROUP_INET6_GETSOCKNAME: c_int = 32;
pub const BPF_XDP_DEVMAP: c_int = 33;
pub const BPF_CGROUP_INET_SOCK_RELEASE: c_int = 34;
pub const BPF_XDP_CPUMAP: c_int = 35;
pub const BPF_SK_LOOKUP: c_int = 36;
pub const BPF_XDP: c_int = 37;
pub const BPF_SK_SKB_VERDICT: c_int = 38;
pub const BPF_SK_REUSEPORT_SELECT: c_int = 39;
pub const BPF_SK_REUSEPORT_SELECT_OR_MIGRATE: c_int = 40;
pub const BPF_PERF_EVENT: c_int = 41;
pub const BPF_TRACE_KPROBE_MULTI: c_int = 42;
pub const BPF_LSM_CGROUP: c_int = 43;
pub const BPF_STRUCT_OPS: c_int = 44;
pub const BPF_NETFILTER: c_int = 45;
pub const BPF_TCX_INGRESS: c_int = 46;
pub const BPF_TCX_EGRESS: c_int = 47;
pub const BPF_TRACE_UPROBE_MULTI: c_int = 48;
pub const BPF_CGROUP_UNIX_CONNECT: c_int = 49;
pub const BPF_CGROUP_UNIX_SENDMSG: c_int = 50;
pub const BPF_CGROUP_UNIX_RECVMSG: c_int = 51;
pub const BPF_CGROUP_UNIX_GETPEERNAME: c_int = 52;
pub const BPF_CGROUP_UNIX_GETSOCKNAME: c_int = 53;
pub const BPF_NETKIT_PRIMARY: c_int = 54;
pub const BPF_NETKIT_PEER: c_int = 55;
pub const BPF_TRACE_KPROBE_SESSION: c_int = 56;
pub const BPF_TRACE_UPROBE_SESSION: c_int = 57;
pub const __MAX_BPF_ATTACH_TYPE: c_int = 58;
pub const enum_bpf_attach_type = c_uint;
pub const BPF_LINK_TYPE_UNSPEC: c_int = 0;
pub const BPF_LINK_TYPE_RAW_TRACEPOINT: c_int = 1;
pub const BPF_LINK_TYPE_TRACING: c_int = 2;
pub const BPF_LINK_TYPE_CGROUP: c_int = 3;
pub const BPF_LINK_TYPE_ITER: c_int = 4;
pub const BPF_LINK_TYPE_NETNS: c_int = 5;
pub const BPF_LINK_TYPE_XDP: c_int = 6;
pub const BPF_LINK_TYPE_PERF_EVENT: c_int = 7;
pub const BPF_LINK_TYPE_KPROBE_MULTI: c_int = 8;
pub const BPF_LINK_TYPE_STRUCT_OPS: c_int = 9;
pub const BPF_LINK_TYPE_NETFILTER: c_int = 10;
pub const BPF_LINK_TYPE_TCX: c_int = 11;
pub const BPF_LINK_TYPE_UPROBE_MULTI: c_int = 12;
pub const BPF_LINK_TYPE_NETKIT: c_int = 13;
pub const BPF_LINK_TYPE_SOCKMAP: c_int = 14;
pub const __MAX_BPF_LINK_TYPE: c_int = 15;
pub const enum_bpf_link_type = c_uint;
pub const BPF_PERF_EVENT_UNSPEC: c_int = 0;
pub const BPF_PERF_EVENT_UPROBE: c_int = 1;
pub const BPF_PERF_EVENT_URETPROBE: c_int = 2;
pub const BPF_PERF_EVENT_KPROBE: c_int = 3;
pub const BPF_PERF_EVENT_KRETPROBE: c_int = 4;
pub const BPF_PERF_EVENT_TRACEPOINT: c_int = 5;
pub const BPF_PERF_EVENT_EVENT: c_int = 6;
pub const enum_bpf_perf_event_type = c_uint;
pub const BPF_F_KPROBE_MULTI_RETURN: c_int = 1;
const enum_unnamed_6 = c_uint;
pub const BPF_F_UPROBE_MULTI_RETURN: c_int = 1;
const enum_unnamed_7 = c_uint;
pub const BPF_ADDR_SPACE_CAST: c_int = 1;
pub const enum_bpf_addr_space_cast = c_uint;
pub const BPF_ANY: c_int = 0;
pub const BPF_NOEXIST: c_int = 1;
pub const BPF_EXIST: c_int = 2;
pub const BPF_F_LOCK: c_int = 4;
const enum_unnamed_8 = c_uint;
pub const BPF_F_NO_PREALLOC: c_int = 1;
pub const BPF_F_NO_COMMON_LRU: c_int = 2;
pub const BPF_F_NUMA_NODE: c_int = 4;
pub const BPF_F_RDONLY: c_int = 8;
pub const BPF_F_WRONLY: c_int = 16;
pub const BPF_F_STACK_BUILD_ID: c_int = 32;
pub const BPF_F_ZERO_SEED: c_int = 64;
pub const BPF_F_RDONLY_PROG: c_int = 128;
pub const BPF_F_WRONLY_PROG: c_int = 256;
pub const BPF_F_CLONE: c_int = 512;
pub const BPF_F_MMAPABLE: c_int = 1024;
pub const BPF_F_PRESERVE_ELEMS: c_int = 2048;
pub const BPF_F_INNER_MAP: c_int = 4096;
pub const BPF_F_LINK: c_int = 8192;
pub const BPF_F_PATH_FD: c_int = 16384;
pub const BPF_F_VTYPE_BTF_OBJ_FD: c_int = 32768;
pub const BPF_F_TOKEN_FD: c_int = 65536;
pub const BPF_F_SEGV_ON_FAULT: c_int = 131072;
pub const BPF_F_NO_USER_CONV: c_int = 262144;
const enum_unnamed_9 = c_uint;
pub const BPF_STATS_RUN_TIME: c_int = 0;
pub const enum_bpf_stats_type = c_uint;
pub const BPF_STACK_BUILD_ID_EMPTY: c_int = 0;
pub const BPF_STACK_BUILD_ID_VALID: c_int = 1;
pub const BPF_STACK_BUILD_ID_IP: c_int = 2;
pub const enum_bpf_stack_build_id_status = c_uint;
const union_unnamed_10 = extern union {
    offset: __u64,
    ip: __u64,
};
pub const struct_bpf_stack_build_id = extern struct {
    status: __s32 = 0,
    build_id: [20]u8 = @import("std").mem.zeroes([20]u8),
    unnamed_0: union_unnamed_10 = @import("std").mem.zeroes(union_unnamed_10),
};
pub const BPF_STREAM_STDOUT: c_int = 1;
pub const BPF_STREAM_STDERR: c_int = 2;
const enum_unnamed_11 = c_uint;
const struct_unnamed_12 = extern struct {
    map_type: __u32 = 0,
    key_size: __u32 = 0,
    value_size: __u32 = 0,
    max_entries: __u32 = 0,
    map_flags: __u32 = 0,
    inner_map_fd: __u32 = 0,
    numa_node: __u32 = 0,
    map_name: [16]u8 = @import("std").mem.zeroes([16]u8),
    map_ifindex: __u32 = 0,
    btf_fd: __u32 = 0,
    btf_key_type_id: __u32 = 0,
    btf_value_type_id: __u32 = 0,
    btf_vmlinux_value_type_id: __u32 = 0,
    map_extra: __u64 = 0,
    value_type_btf_obj_fd: __s32 = 0,
    map_token_fd: __s32 = 0,
};
const union_unnamed_14 = extern union {
    value: __u64,
    next_key: __u64,
};
const struct_unnamed_13 = extern struct {
    map_fd: __u32 = 0,
    key: __u64 = 0,
    unnamed_0: union_unnamed_14 = @import("std").mem.zeroes(union_unnamed_14),
    flags: __u64 = 0,
};
const struct_unnamed_15 = extern struct {
    in_batch: __u64 = 0,
    out_batch: __u64 = 0,
    keys: __u64 = 0,
    values: __u64 = 0,
    count: __u32 = 0,
    map_fd: __u32 = 0,
    elem_flags: __u64 = 0,
    flags: __u64 = 0,
};
const union_unnamed_17 = extern union {
    attach_prog_fd: __u32,
    attach_btf_obj_fd: __u32,
};
const struct_unnamed_16 = extern struct {
    prog_type: __u32 = 0,
    insn_cnt: __u32 = 0,
    insns: __u64 = 0,
    license: __u64 = 0,
    log_level: __u32 = 0,
    log_size: __u32 = 0,
    log_buf: __u64 = 0,
    kern_version: __u32 = 0,
    prog_flags: __u32 = 0,
    prog_name: [16]u8 = @import("std").mem.zeroes([16]u8),
    prog_ifindex: __u32 = 0,
    expected_attach_type: __u32 = 0,
    prog_btf_fd: __u32 = 0,
    func_info_rec_size: __u32 = 0,
    func_info: __u64 = 0,
    func_info_cnt: __u32 = 0,
    line_info_rec_size: __u32 = 0,
    line_info: __u64 = 0,
    line_info_cnt: __u32 = 0,
    attach_btf_id: __u32 = 0,
    unnamed_0: union_unnamed_17 = @import("std").mem.zeroes(union_unnamed_17),
    core_relo_cnt: __u32 = 0,
    fd_array: __u64 = 0,
    core_relos: __u64 = 0,
    core_relo_rec_size: __u32 = 0,
    log_true_size: __u32 = 0,
    prog_token_fd: __s32 = 0,
    fd_array_cnt: __u32 = 0,
};
const struct_unnamed_18 = extern struct {
    pathname: __u64 = 0,
    bpf_fd: __u32 = 0,
    file_flags: __u32 = 0,
    path_fd: __s32 = 0,
};
const union_unnamed_20 = extern union {
    target_fd: __u32,
    target_ifindex: __u32,
};
const union_unnamed_21 = extern union {
    relative_fd: __u32,
    relative_id: __u32,
};
const struct_unnamed_19 = extern struct {
    unnamed_0: union_unnamed_20 = @import("std").mem.zeroes(union_unnamed_20),
    attach_bpf_fd: __u32 = 0,
    attach_type: __u32 = 0,
    attach_flags: __u32 = 0,
    replace_bpf_fd: __u32 = 0,
    unnamed_1: union_unnamed_21 = @import("std").mem.zeroes(union_unnamed_21),
    expected_revision: __u64 = 0,
};
const struct_unnamed_22 = extern struct {
    prog_fd: __u32 = 0,
    retval: __u32 = 0,
    data_size_in: __u32 = 0,
    data_size_out: __u32 = 0,
    data_in: __u64 = 0,
    data_out: __u64 = 0,
    repeat: __u32 = 0,
    duration: __u32 = 0,
    ctx_size_in: __u32 = 0,
    ctx_size_out: __u32 = 0,
    ctx_in: __u64 = 0,
    ctx_out: __u64 = 0,
    flags: __u32 = 0,
    cpu: __u32 = 0,
    batch_size: __u32 = 0,
};
const union_unnamed_24 = extern union {
    start_id: __u32,
    prog_id: __u32,
    map_id: __u32,
    btf_id: __u32,
    link_id: __u32,
};
const struct_unnamed_23 = extern struct {
    unnamed_0: union_unnamed_24 = @import("std").mem.zeroes(union_unnamed_24),
    next_id: __u32 = 0,
    open_flags: __u32 = 0,
    fd_by_id_token_fd: __s32 = 0,
};
const struct_unnamed_25 = extern struct {
    bpf_fd: __u32 = 0,
    info_len: __u32 = 0,
    info: __u64 = 0,
};
const union_unnamed_27 = extern union {
    target_fd: __u32,
    target_ifindex: __u32,
};
const union_unnamed_28 = extern union {
    prog_cnt: __u32,
    count: __u32,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_26 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_29 = opaque {};
const struct_unnamed_30 = extern struct {
    btf: __u64 = 0,
    btf_log_buf: __u64 = 0,
    btf_size: __u32 = 0,
    btf_log_size: __u32 = 0,
    btf_log_level: __u32 = 0,
    btf_log_true_size: __u32 = 0,
    btf_flags: __u32 = 0,
    btf_token_fd: __s32 = 0,
};
const struct_unnamed_31 = extern struct {
    pid: __u32 = 0,
    fd: __u32 = 0,
    flags: __u32 = 0,
    buf_len: __u32 = 0,
    buf: __u64 = 0,
    prog_id: __u32 = 0,
    fd_type: __u32 = 0,
    probe_offset: __u64 = 0,
    probe_addr: __u64 = 0,
};
const union_unnamed_33 = extern union {
    prog_fd: __u32,
    map_fd: __u32,
};
const union_unnamed_34 = extern union {
    target_fd: __u32,
    target_ifindex: __u32,
};
const struct_unnamed_36 = extern struct {
    iter_info: __u64 = 0,
    iter_info_len: __u32 = 0,
};
const struct_unnamed_37 = extern struct {
    bpf_cookie: __u64 = 0,
};
const struct_unnamed_38 = extern struct {
    flags: __u32 = 0,
    cnt: __u32 = 0,
    syms: __u64 = 0,
    addrs: __u64 = 0,
    cookies: __u64 = 0,
};
const struct_unnamed_39 = extern struct {
    target_btf_id: __u32 = 0,
    cookie: __u64 = 0,
};
const struct_unnamed_40 = extern struct {
    pf: __u32 = 0,
    hooknum: __u32 = 0,
    priority: __s32 = 0,
    flags: __u32 = 0,
};
const union_unnamed_42 = extern union {
    relative_fd: __u32,
    relative_id: __u32,
};
const struct_unnamed_41 = extern struct {
    unnamed_0: union_unnamed_42 = @import("std").mem.zeroes(union_unnamed_42),
    expected_revision: __u64 = 0,
};
const struct_unnamed_43 = extern struct {
    path: __u64 = 0,
    offsets: __u64 = 0,
    ref_ctr_offsets: __u64 = 0,
    cookies: __u64 = 0,
    cnt: __u32 = 0,
    flags: __u32 = 0,
    pid: __u32 = 0,
};
const union_unnamed_45 = extern union {
    relative_fd: __u32,
    relative_id: __u32,
};
const struct_unnamed_44 = extern struct {
    unnamed_0: union_unnamed_45 = @import("std").mem.zeroes(union_unnamed_45),
    expected_revision: __u64 = 0,
};
const union_unnamed_47 = extern union {
    relative_fd: __u32,
    relative_id: __u32,
};
const struct_unnamed_46 = extern struct {
    unnamed_0: union_unnamed_47 = @import("std").mem.zeroes(union_unnamed_47),
    expected_revision: __u64 = 0,
};
const union_unnamed_35 = extern union {
    target_btf_id: __u32,
    unnamed_0: struct_unnamed_36,
    perf_event: struct_unnamed_37,
    kprobe_multi: struct_unnamed_38,
    tracing: struct_unnamed_39,
    netfilter: struct_unnamed_40,
    tcx: struct_unnamed_41,
    uprobe_multi: struct_unnamed_43,
    netkit: struct_unnamed_44,
    cgroup: struct_unnamed_46,
};
const struct_unnamed_32 = extern struct {
    unnamed_0: union_unnamed_33 = @import("std").mem.zeroes(union_unnamed_33),
    unnamed_1: union_unnamed_34 = @import("std").mem.zeroes(union_unnamed_34),
    attach_type: __u32 = 0,
    flags: __u32 = 0,
    unnamed_2: union_unnamed_35 = @import("std").mem.zeroes(union_unnamed_35),
};
const union_unnamed_49 = extern union {
    new_prog_fd: __u32,
    new_map_fd: __u32,
};
const union_unnamed_50 = extern union {
    old_prog_fd: __u32,
    old_map_fd: __u32,
};
const struct_unnamed_48 = extern struct {
    link_fd: __u32 = 0,
    unnamed_0: union_unnamed_49 = @import("std").mem.zeroes(union_unnamed_49),
    flags: __u32 = 0,
    unnamed_1: union_unnamed_50 = @import("std").mem.zeroes(union_unnamed_50),
};
const struct_unnamed_51 = extern struct {
    link_fd: __u32 = 0,
};
const struct_unnamed_52 = extern struct {
    type: __u32 = 0,
};
const struct_unnamed_53 = extern struct {
    link_fd: __u32 = 0,
    flags: __u32 = 0,
};
const struct_unnamed_54 = extern struct {
    prog_fd: __u32 = 0,
    map_fd: __u32 = 0,
    flags: __u32 = 0,
};
const struct_unnamed_55 = extern struct {
    flags: __u32 = 0,
    bpffs_fd: __u32 = 0,
};
const struct_unnamed_56 = extern struct {
    stream_buf: __u64 = 0,
    stream_buf_len: __u32 = 0,
    stream_id: __u32 = 0,
    prog_fd: __u32 = 0,
};
pub const union_bpf_attr = extern union {
    unnamed_0: struct_unnamed_12,
    unnamed_1: struct_unnamed_13,
    batch: struct_unnamed_15,
    unnamed_2: struct_unnamed_16,
    unnamed_3: struct_unnamed_18,
    unnamed_4: struct_unnamed_19,
    @"test": struct_unnamed_22,
    unnamed_5: struct_unnamed_23,
    info: struct_unnamed_25,
    query: struct_unnamed_26,
    raw_tracepoint: struct_unnamed_29,
    unnamed_6: struct_unnamed_30,
    task_fd_query: struct_unnamed_31,
    link_create: struct_unnamed_32,
    link_update: struct_unnamed_48,
    link_detach: struct_unnamed_51,
    enable_stats: struct_unnamed_52,
    iter_create: struct_unnamed_53,
    prog_bind_map: struct_unnamed_54,
    token_create: struct_unnamed_55,
    prog_stream_read: struct_unnamed_56,
};
pub const BPF_FUNC_unspec: c_int = 0;
pub const BPF_FUNC_map_lookup_elem: c_int = 1;
pub const BPF_FUNC_map_update_elem: c_int = 2;
pub const BPF_FUNC_map_delete_elem: c_int = 3;
pub const BPF_FUNC_probe_read: c_int = 4;
pub const BPF_FUNC_ktime_get_ns: c_int = 5;
pub const BPF_FUNC_trace_printk: c_int = 6;
pub const BPF_FUNC_get_prandom_u32: c_int = 7;
pub const BPF_FUNC_get_smp_processor_id: c_int = 8;
pub const BPF_FUNC_skb_store_bytes: c_int = 9;
pub const BPF_FUNC_l3_csum_replace: c_int = 10;
pub const BPF_FUNC_l4_csum_replace: c_int = 11;
pub const BPF_FUNC_tail_call: c_int = 12;
pub const BPF_FUNC_clone_redirect: c_int = 13;
pub const BPF_FUNC_get_current_pid_tgid: c_int = 14;
pub const BPF_FUNC_get_current_uid_gid: c_int = 15;
pub const BPF_FUNC_get_current_comm: c_int = 16;
pub const BPF_FUNC_get_cgroup_classid: c_int = 17;
pub const BPF_FUNC_skb_vlan_push: c_int = 18;
pub const BPF_FUNC_skb_vlan_pop: c_int = 19;
pub const BPF_FUNC_skb_get_tunnel_key: c_int = 20;
pub const BPF_FUNC_skb_set_tunnel_key: c_int = 21;
pub const BPF_FUNC_perf_event_read: c_int = 22;
pub const BPF_FUNC_redirect: c_int = 23;
pub const BPF_FUNC_get_route_realm: c_int = 24;
pub const BPF_FUNC_perf_event_output: c_int = 25;
pub const BPF_FUNC_skb_load_bytes: c_int = 26;
pub const BPF_FUNC_get_stackid: c_int = 27;
pub const BPF_FUNC_csum_diff: c_int = 28;
pub const BPF_FUNC_skb_get_tunnel_opt: c_int = 29;
pub const BPF_FUNC_skb_set_tunnel_opt: c_int = 30;
pub const BPF_FUNC_skb_change_proto: c_int = 31;
pub const BPF_FUNC_skb_change_type: c_int = 32;
pub const BPF_FUNC_skb_under_cgroup: c_int = 33;
pub const BPF_FUNC_get_hash_recalc: c_int = 34;
pub const BPF_FUNC_get_current_task: c_int = 35;
pub const BPF_FUNC_probe_write_user: c_int = 36;
pub const BPF_FUNC_current_task_under_cgroup: c_int = 37;
pub const BPF_FUNC_skb_change_tail: c_int = 38;
pub const BPF_FUNC_skb_pull_data: c_int = 39;
pub const BPF_FUNC_csum_update: c_int = 40;
pub const BPF_FUNC_set_hash_invalid: c_int = 41;
pub const BPF_FUNC_get_numa_node_id: c_int = 42;
pub const BPF_FUNC_skb_change_head: c_int = 43;
pub const BPF_FUNC_xdp_adjust_head: c_int = 44;
pub const BPF_FUNC_probe_read_str: c_int = 45;
pub const BPF_FUNC_get_socket_cookie: c_int = 46;
pub const BPF_FUNC_get_socket_uid: c_int = 47;
pub const BPF_FUNC_set_hash: c_int = 48;
pub const BPF_FUNC_setsockopt: c_int = 49;
pub const BPF_FUNC_skb_adjust_room: c_int = 50;
pub const BPF_FUNC_redirect_map: c_int = 51;
pub const BPF_FUNC_sk_redirect_map: c_int = 52;
pub const BPF_FUNC_sock_map_update: c_int = 53;
pub const BPF_FUNC_xdp_adjust_meta: c_int = 54;
pub const BPF_FUNC_perf_event_read_value: c_int = 55;
pub const BPF_FUNC_perf_prog_read_value: c_int = 56;
pub const BPF_FUNC_getsockopt: c_int = 57;
pub const BPF_FUNC_override_return: c_int = 58;
pub const BPF_FUNC_sock_ops_cb_flags_set: c_int = 59;
pub const BPF_FUNC_msg_redirect_map: c_int = 60;
pub const BPF_FUNC_msg_apply_bytes: c_int = 61;
pub const BPF_FUNC_msg_cork_bytes: c_int = 62;
pub const BPF_FUNC_msg_pull_data: c_int = 63;
pub const BPF_FUNC_bind: c_int = 64;
pub const BPF_FUNC_xdp_adjust_tail: c_int = 65;
pub const BPF_FUNC_skb_get_xfrm_state: c_int = 66;
pub const BPF_FUNC_get_stack: c_int = 67;
pub const BPF_FUNC_skb_load_bytes_relative: c_int = 68;
pub const BPF_FUNC_fib_lookup: c_int = 69;
pub const BPF_FUNC_sock_hash_update: c_int = 70;
pub const BPF_FUNC_msg_redirect_hash: c_int = 71;
pub const BPF_FUNC_sk_redirect_hash: c_int = 72;
pub const BPF_FUNC_lwt_push_encap: c_int = 73;
pub const BPF_FUNC_lwt_seg6_store_bytes: c_int = 74;
pub const BPF_FUNC_lwt_seg6_adjust_srh: c_int = 75;
pub const BPF_FUNC_lwt_seg6_action: c_int = 76;
pub const BPF_FUNC_rc_repeat: c_int = 77;
pub const BPF_FUNC_rc_keydown: c_int = 78;
pub const BPF_FUNC_skb_cgroup_id: c_int = 79;
pub const BPF_FUNC_get_current_cgroup_id: c_int = 80;
pub const BPF_FUNC_get_local_storage: c_int = 81;
pub const BPF_FUNC_sk_select_reuseport: c_int = 82;
pub const BPF_FUNC_skb_ancestor_cgroup_id: c_int = 83;
pub const BPF_FUNC_sk_lookup_tcp: c_int = 84;
pub const BPF_FUNC_sk_lookup_udp: c_int = 85;
pub const BPF_FUNC_sk_release: c_int = 86;
pub const BPF_FUNC_map_push_elem: c_int = 87;
pub const BPF_FUNC_map_pop_elem: c_int = 88;
pub const BPF_FUNC_map_peek_elem: c_int = 89;
pub const BPF_FUNC_msg_push_data: c_int = 90;
pub const BPF_FUNC_msg_pop_data: c_int = 91;
pub const BPF_FUNC_rc_pointer_rel: c_int = 92;
pub const BPF_FUNC_spin_lock: c_int = 93;
pub const BPF_FUNC_spin_unlock: c_int = 94;
pub const BPF_FUNC_sk_fullsock: c_int = 95;
pub const BPF_FUNC_tcp_sock: c_int = 96;
pub const BPF_FUNC_skb_ecn_set_ce: c_int = 97;
pub const BPF_FUNC_get_listener_sock: c_int = 98;
pub const BPF_FUNC_skc_lookup_tcp: c_int = 99;
pub const BPF_FUNC_tcp_check_syncookie: c_int = 100;
pub const BPF_FUNC_sysctl_get_name: c_int = 101;
pub const BPF_FUNC_sysctl_get_current_value: c_int = 102;
pub const BPF_FUNC_sysctl_get_new_value: c_int = 103;
pub const BPF_FUNC_sysctl_set_new_value: c_int = 104;
pub const BPF_FUNC_strtol: c_int = 105;
pub const BPF_FUNC_strtoul: c_int = 106;
pub const BPF_FUNC_sk_storage_get: c_int = 107;
pub const BPF_FUNC_sk_storage_delete: c_int = 108;
pub const BPF_FUNC_send_signal: c_int = 109;
pub const BPF_FUNC_tcp_gen_syncookie: c_int = 110;
pub const BPF_FUNC_skb_output: c_int = 111;
pub const BPF_FUNC_probe_read_user: c_int = 112;
pub const BPF_FUNC_probe_read_kernel: c_int = 113;
pub const BPF_FUNC_probe_read_user_str: c_int = 114;
pub const BPF_FUNC_probe_read_kernel_str: c_int = 115;
pub const BPF_FUNC_tcp_send_ack: c_int = 116;
pub const BPF_FUNC_send_signal_thread: c_int = 117;
pub const BPF_FUNC_jiffies64: c_int = 118;
pub const BPF_FUNC_read_branch_records: c_int = 119;
pub const BPF_FUNC_get_ns_current_pid_tgid: c_int = 120;
pub const BPF_FUNC_xdp_output: c_int = 121;
pub const BPF_FUNC_get_netns_cookie: c_int = 122;
pub const BPF_FUNC_get_current_ancestor_cgroup_id: c_int = 123;
pub const BPF_FUNC_sk_assign: c_int = 124;
pub const BPF_FUNC_ktime_get_boot_ns: c_int = 125;
pub const BPF_FUNC_seq_printf: c_int = 126;
pub const BPF_FUNC_seq_write: c_int = 127;
pub const BPF_FUNC_sk_cgroup_id: c_int = 128;
pub const BPF_FUNC_sk_ancestor_cgroup_id: c_int = 129;
pub const BPF_FUNC_ringbuf_output: c_int = 130;
pub const BPF_FUNC_ringbuf_reserve: c_int = 131;
pub const BPF_FUNC_ringbuf_submit: c_int = 132;
pub const BPF_FUNC_ringbuf_discard: c_int = 133;
pub const BPF_FUNC_ringbuf_query: c_int = 134;
pub const BPF_FUNC_csum_level: c_int = 135;
pub const BPF_FUNC_skc_to_tcp6_sock: c_int = 136;
pub const BPF_FUNC_skc_to_tcp_sock: c_int = 137;
pub const BPF_FUNC_skc_to_tcp_timewait_sock: c_int = 138;
pub const BPF_FUNC_skc_to_tcp_request_sock: c_int = 139;
pub const BPF_FUNC_skc_to_udp6_sock: c_int = 140;
pub const BPF_FUNC_get_task_stack: c_int = 141;
pub const BPF_FUNC_load_hdr_opt: c_int = 142;
pub const BPF_FUNC_store_hdr_opt: c_int = 143;
pub const BPF_FUNC_reserve_hdr_opt: c_int = 144;
pub const BPF_FUNC_inode_storage_get: c_int = 145;
pub const BPF_FUNC_inode_storage_delete: c_int = 146;
pub const BPF_FUNC_d_path: c_int = 147;
pub const BPF_FUNC_copy_from_user: c_int = 148;
pub const BPF_FUNC_snprintf_btf: c_int = 149;
pub const BPF_FUNC_seq_printf_btf: c_int = 150;
pub const BPF_FUNC_skb_cgroup_classid: c_int = 151;
pub const BPF_FUNC_redirect_neigh: c_int = 152;
pub const BPF_FUNC_per_cpu_ptr: c_int = 153;
pub const BPF_FUNC_this_cpu_ptr: c_int = 154;
pub const BPF_FUNC_redirect_peer: c_int = 155;
pub const BPF_FUNC_task_storage_get: c_int = 156;
pub const BPF_FUNC_task_storage_delete: c_int = 157;
pub const BPF_FUNC_get_current_task_btf: c_int = 158;
pub const BPF_FUNC_bprm_opts_set: c_int = 159;
pub const BPF_FUNC_ktime_get_coarse_ns: c_int = 160;
pub const BPF_FUNC_ima_inode_hash: c_int = 161;
pub const BPF_FUNC_sock_from_file: c_int = 162;
pub const BPF_FUNC_check_mtu: c_int = 163;
pub const BPF_FUNC_for_each_map_elem: c_int = 164;
pub const BPF_FUNC_snprintf: c_int = 165;
pub const BPF_FUNC_sys_bpf: c_int = 166;
pub const BPF_FUNC_btf_find_by_name_kind: c_int = 167;
pub const BPF_FUNC_sys_close: c_int = 168;
pub const BPF_FUNC_timer_init: c_int = 169;
pub const BPF_FUNC_timer_set_callback: c_int = 170;
pub const BPF_FUNC_timer_start: c_int = 171;
pub const BPF_FUNC_timer_cancel: c_int = 172;
pub const BPF_FUNC_get_func_ip: c_int = 173;
pub const BPF_FUNC_get_attach_cookie: c_int = 174;
pub const BPF_FUNC_task_pt_regs: c_int = 175;
pub const BPF_FUNC_get_branch_snapshot: c_int = 176;
pub const BPF_FUNC_trace_vprintk: c_int = 177;
pub const BPF_FUNC_skc_to_unix_sock: c_int = 178;
pub const BPF_FUNC_kallsyms_lookup_name: c_int = 179;
pub const BPF_FUNC_find_vma: c_int = 180;
pub const BPF_FUNC_loop: c_int = 181;
pub const BPF_FUNC_strncmp: c_int = 182;
pub const BPF_FUNC_get_func_arg: c_int = 183;
pub const BPF_FUNC_get_func_ret: c_int = 184;
pub const BPF_FUNC_get_func_arg_cnt: c_int = 185;
pub const BPF_FUNC_get_retval: c_int = 186;
pub const BPF_FUNC_set_retval: c_int = 187;
pub const BPF_FUNC_xdp_get_buff_len: c_int = 188;
pub const BPF_FUNC_xdp_load_bytes: c_int = 189;
pub const BPF_FUNC_xdp_store_bytes: c_int = 190;
pub const BPF_FUNC_copy_from_user_task: c_int = 191;
pub const BPF_FUNC_skb_set_tstamp: c_int = 192;
pub const BPF_FUNC_ima_file_hash: c_int = 193;
pub const BPF_FUNC_kptr_xchg: c_int = 194;
pub const BPF_FUNC_map_lookup_percpu_elem: c_int = 195;
pub const BPF_FUNC_skc_to_mptcp_sock: c_int = 196;
pub const BPF_FUNC_dynptr_from_mem: c_int = 197;
pub const BPF_FUNC_ringbuf_reserve_dynptr: c_int = 198;
pub const BPF_FUNC_ringbuf_submit_dynptr: c_int = 199;
pub const BPF_FUNC_ringbuf_discard_dynptr: c_int = 200;
pub const BPF_FUNC_dynptr_read: c_int = 201;
pub const BPF_FUNC_dynptr_write: c_int = 202;
pub const BPF_FUNC_dynptr_data: c_int = 203;
pub const BPF_FUNC_tcp_raw_gen_syncookie_ipv4: c_int = 204;
pub const BPF_FUNC_tcp_raw_gen_syncookie_ipv6: c_int = 205;
pub const BPF_FUNC_tcp_raw_check_syncookie_ipv4: c_int = 206;
pub const BPF_FUNC_tcp_raw_check_syncookie_ipv6: c_int = 207;
pub const BPF_FUNC_ktime_get_tai_ns: c_int = 208;
pub const BPF_FUNC_user_ringbuf_drain: c_int = 209;
pub const BPF_FUNC_cgrp_storage_get: c_int = 210;
pub const BPF_FUNC_cgrp_storage_delete: c_int = 211;
pub const __BPF_FUNC_MAX_ID: c_int = 212;
pub const enum_bpf_func_id = c_uint;
pub const BPF_F_RECOMPUTE_CSUM: c_int = 1;
pub const BPF_F_INVALIDATE_HASH: c_int = 2;
const enum_unnamed_57 = c_uint;
pub const BPF_F_HDR_FIELD_MASK: c_int = 15;
const enum_unnamed_58 = c_uint;
pub const BPF_F_PSEUDO_HDR: c_int = 16;
pub const BPF_F_MARK_MANGLED_0: c_int = 32;
pub const BPF_F_MARK_ENFORCE: c_int = 64;
pub const BPF_F_IPV6: c_int = 128;
const enum_unnamed_59 = c_uint;
pub const BPF_F_TUNINFO_IPV6: c_int = 1;
const enum_unnamed_60 = c_uint;
pub const BPF_F_SKIP_FIELD_MASK: c_int = 255;
pub const BPF_F_USER_STACK: c_int = 256;
pub const BPF_F_FAST_STACK_CMP: c_int = 512;
pub const BPF_F_REUSE_STACKID: c_int = 1024;
pub const BPF_F_USER_BUILD_ID: c_int = 2048;
const enum_unnamed_61 = c_uint;
pub const BPF_F_ZERO_CSUM_TX: c_int = 2;
pub const BPF_F_DONT_FRAGMENT: c_int = 4;
pub const BPF_F_SEQ_NUMBER: c_int = 8;
pub const BPF_F_NO_TUNNEL_KEY: c_int = 16;
const enum_unnamed_62 = c_uint;
pub const BPF_F_TUNINFO_FLAGS: c_int = 16;
const enum_unnamed_63 = c_uint;
pub const BPF_F_INDEX_MASK: c_ulong = 4294967295;
pub const BPF_F_CURRENT_CPU: c_ulong = 4294967295;
pub const BPF_F_CTXLEN_MASK: c_ulong = 4503595332403200;
const enum_unnamed_64 = c_ulong;
pub const BPF_F_CURRENT_NETNS: c_int = -1;
const enum_unnamed_65 = c_int;
pub const BPF_CSUM_LEVEL_QUERY: c_int = 0;
pub const BPF_CSUM_LEVEL_INC: c_int = 1;
pub const BPF_CSUM_LEVEL_DEC: c_int = 2;
pub const BPF_CSUM_LEVEL_RESET: c_int = 3;
const enum_unnamed_66 = c_uint;
pub const BPF_F_ADJ_ROOM_FIXED_GSO: c_int = 1;
pub const BPF_F_ADJ_ROOM_ENCAP_L3_IPV4: c_int = 2;
pub const BPF_F_ADJ_ROOM_ENCAP_L3_IPV6: c_int = 4;
pub const BPF_F_ADJ_ROOM_ENCAP_L4_GRE: c_int = 8;
pub const BPF_F_ADJ_ROOM_ENCAP_L4_UDP: c_int = 16;
pub const BPF_F_ADJ_ROOM_NO_CSUM_RESET: c_int = 32;
pub const BPF_F_ADJ_ROOM_ENCAP_L2_ETH: c_int = 64;
pub const BPF_F_ADJ_ROOM_DECAP_L3_IPV4: c_int = 128;
pub const BPF_F_ADJ_ROOM_DECAP_L3_IPV6: c_int = 256;
const enum_unnamed_67 = c_uint;
pub const BPF_ADJ_ROOM_ENCAP_L2_MASK: c_int = 255;
pub const BPF_ADJ_ROOM_ENCAP_L2_SHIFT: c_int = 56;
const enum_unnamed_68 = c_uint;
pub const BPF_F_SYSCTL_BASE_NAME: c_int = 1;
const enum_unnamed_69 = c_uint;
pub const BPF_LOCAL_STORAGE_GET_F_CREATE: c_int = 1;
pub const BPF_SK_STORAGE_GET_F_CREATE: c_int = 1;
const enum_unnamed_70 = c_uint;
pub const BPF_F_GET_BRANCH_RECORDS_SIZE: c_int = 1;
const enum_unnamed_71 = c_uint;
pub const BPF_RB_NO_WAKEUP: c_int = 1;
pub const BPF_RB_FORCE_WAKEUP: c_int = 2;
const enum_unnamed_72 = c_uint;
pub const BPF_RB_AVAIL_DATA: c_int = 0;
pub const BPF_RB_RING_SIZE: c_int = 1;
pub const BPF_RB_CONS_POS: c_int = 2;
pub const BPF_RB_PROD_POS: c_int = 3;
const enum_unnamed_73 = c_uint;
pub const BPF_RINGBUF_BUSY_BIT: c_uint = 2147483648;
pub const BPF_RINGBUF_DISCARD_BIT: c_uint = 1073741824;
pub const BPF_RINGBUF_HDR_SZ: c_uint = 8;
const enum_unnamed_74 = c_uint;
pub const BPF_SK_LOOKUP_F_REPLACE: c_int = 1;
pub const BPF_SK_LOOKUP_F_NO_REUSEPORT: c_int = 2;
const enum_unnamed_75 = c_uint;
pub const BPF_ADJ_ROOM_NET: c_int = 0;
pub const BPF_ADJ_ROOM_MAC: c_int = 1;
pub const enum_bpf_adj_room_mode = c_uint;
pub const BPF_HDR_START_MAC: c_int = 0;
pub const BPF_HDR_START_NET: c_int = 1;
pub const enum_bpf_hdr_start_off = c_uint;
pub const BPF_LWT_ENCAP_SEG6: c_int = 0;
pub const BPF_LWT_ENCAP_SEG6_INLINE: c_int = 1;
pub const BPF_LWT_ENCAP_IP: c_int = 2;
pub const enum_bpf_lwt_encap_mode = c_uint;
pub const BPF_F_BPRM_SECUREEXEC: c_int = 1;
const enum_unnamed_76 = c_uint;
pub const BPF_F_INGRESS: c_int = 1;
pub const BPF_F_BROADCAST: c_int = 8;
pub const BPF_F_EXCLUDE_INGRESS: c_int = 16;
const enum_unnamed_77 = c_uint;
pub const BPF_SKB_TSTAMP_UNSPEC: c_int = 0;
pub const BPF_SKB_TSTAMP_DELIVERY_MONO: c_int = 1;
pub const BPF_SKB_CLOCK_REALTIME: c_int = 0;
pub const BPF_SKB_CLOCK_MONOTONIC: c_int = 1;
pub const BPF_SKB_CLOCK_TAI: c_int = 2;
const enum_unnamed_78 = c_uint;
const struct_unnamed_81 = extern struct {
    ipv4_src: __be32 = 0,
    ipv4_dst: __be32 = 0,
};
const struct_unnamed_82 = extern struct {
    ipv6_src: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    ipv6_dst: [4]__u32 = @import("std").mem.zeroes([4]__u32),
};
const union_unnamed_80 = extern union {
    unnamed_0: struct_unnamed_81,
    unnamed_1: struct_unnamed_82,
};
pub const struct_bpf_flow_keys = extern struct {
    nhoff: __u16 = 0,
    thoff: __u16 = 0,
    addr_proto: __u16 = 0,
    is_frag: __u8 = 0,
    is_first_frag: __u8 = 0,
    is_encap: __u8 = 0,
    ip_proto: __u8 = 0,
    n_proto: __be16 = 0,
    sport: __be16 = 0,
    dport: __be16 = 0,
    unnamed_0: union_unnamed_80 = @import("std").mem.zeroes(union_unnamed_80),
    flags: __u32 = 0,
    flow_label: __be32 = 0,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_79 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_sock = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_83 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct___sk_buff = opaque {};
const union_unnamed_84 = extern union {
    remote_ipv4: __u32,
    remote_ipv6: [4]__u32,
};
const union_unnamed_85 = extern union {
    tunnel_ext: __u16,
    tunnel_flags: __be16,
};
const union_unnamed_86 = extern union {
    local_ipv4: __u32,
    local_ipv6: [4]__u32,
};
pub const struct_bpf_tunnel_key = extern struct {
    tunnel_id: __u32 = 0,
    unnamed_0: union_unnamed_84 = @import("std").mem.zeroes(union_unnamed_84),
    tunnel_tos: __u8 = 0,
    tunnel_ttl: __u8 = 0,
    unnamed_1: union_unnamed_85 = @import("std").mem.zeroes(union_unnamed_85),
    tunnel_label: __u32 = 0,
    unnamed_2: union_unnamed_86 = @import("std").mem.zeroes(union_unnamed_86),
};
const union_unnamed_87 = extern union {
    remote_ipv4: __u32,
    remote_ipv6: [4]__u32,
};
pub const struct_bpf_xfrm_state = extern struct {
    reqid: __u32 = 0,
    spi: __u32 = 0,
    family: __u16 = 0,
    ext: __u16 = 0,
    unnamed_0: union_unnamed_87 = @import("std").mem.zeroes(union_unnamed_87),
};
pub const BPF_OK: c_int = 0;
pub const BPF_DROP: c_int = 2;
pub const BPF_REDIRECT: c_int = 7;
pub const BPF_LWT_REROUTE: c_int = 128;
pub const BPF_FLOW_DISSECTOR_CONTINUE: c_int = 129;
pub const enum_bpf_ret_code = c_uint;
pub const struct_bpf_tcp_sock = extern struct {
    snd_cwnd: __u32 = 0,
    srtt_us: __u32 = 0,
    rtt_min: __u32 = 0,
    snd_ssthresh: __u32 = 0,
    rcv_nxt: __u32 = 0,
    snd_nxt: __u32 = 0,
    snd_una: __u32 = 0,
    mss_cache: __u32 = 0,
    ecn_flags: __u32 = 0,
    rate_delivered: __u32 = 0,
    rate_interval_us: __u32 = 0,
    packets_out: __u32 = 0,
    retrans_out: __u32 = 0,
    total_retrans: __u32 = 0,
    segs_in: __u32 = 0,
    data_segs_in: __u32 = 0,
    segs_out: __u32 = 0,
    data_segs_out: __u32 = 0,
    lost_out: __u32 = 0,
    sacked_out: __u32 = 0,
    bytes_received: __u64 = 0,
    bytes_acked: __u64 = 0,
    dsack_dups: __u32 = 0,
    delivered: __u32 = 0,
    delivered_ce: __u32 = 0,
    icsk_retransmits: __u32 = 0,
};
const struct_unnamed_89 = extern struct {
    saddr: __be32 = 0,
    daddr: __be32 = 0,
    sport: __be16 = 0,
    dport: __be16 = 0,
};
const struct_unnamed_90 = extern struct {
    saddr: [4]__be32 = @import("std").mem.zeroes([4]__be32),
    daddr: [4]__be32 = @import("std").mem.zeroes([4]__be32),
    sport: __be16 = 0,
    dport: __be16 = 0,
};
const union_unnamed_88 = extern union {
    ipv4: struct_unnamed_89,
    ipv6: struct_unnamed_90,
};
pub const struct_bpf_sock_tuple = extern struct {
    unnamed_0: union_unnamed_88 = @import("std").mem.zeroes(union_unnamed_88),
};
pub const TCX_NEXT: c_int = -1;
pub const TCX_PASS: c_int = 0;
pub const TCX_DROP: c_int = 2;
pub const TCX_REDIRECT: c_int = 7;
pub const enum_tcx_action_base = c_int;
pub const struct_bpf_xdp_sock = extern struct {
    queue_id: __u32 = 0,
};
pub const XDP_ABORTED: c_int = 0;
pub const XDP_DROP: c_int = 1;
pub const XDP_PASS: c_int = 2;
pub const XDP_TX: c_int = 3;
pub const XDP_REDIRECT: c_int = 4;
pub const enum_xdp_action = c_uint;
pub const struct_xdp_md = extern struct {
    data: __u32 = 0,
    data_end: __u32 = 0,
    data_meta: __u32 = 0,
    ingress_ifindex: __u32 = 0,
    rx_queue_index: __u32 = 0,
    egress_ifindex: __u32 = 0,
};
const union_unnamed_91 = extern union {
    fd: c_int,
    id: __u32,
};
pub const struct_bpf_devmap_val = extern struct {
    ifindex: __u32 = 0,
    bpf_prog: union_unnamed_91 = @import("std").mem.zeroes(union_unnamed_91),
};
const union_unnamed_92 = extern union {
    fd: c_int,
    id: __u32,
};
pub const struct_bpf_cpumap_val = extern struct {
    qsize: __u32 = 0,
    bpf_prog: union_unnamed_92 = @import("std").mem.zeroes(union_unnamed_92),
};
pub const SK_DROP: c_int = 0;
pub const SK_PASS: c_int = 1;
pub const enum_sk_action = c_uint; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_93 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_94 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_95 = opaque {};
pub const struct_sk_msg_md = extern struct {
    unnamed_0: union_unnamed_93 = @import("std").mem.zeroes(union_unnamed_93),
    unnamed_1: union_unnamed_94 = @import("std").mem.zeroes(union_unnamed_94),
    family: __u32 = 0,
    remote_ip4: __u32 = 0,
    local_ip4: __u32 = 0,
    remote_ip6: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    local_ip6: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    remote_port: __u32 = 0,
    local_port: __u32 = 0,
    size: __u32 = 0,
    unnamed_2: union_unnamed_95 = @import("std").mem.zeroes(union_unnamed_95),
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_96 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_97 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_98 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_99 = opaque {};
pub const struct_sk_reuseport_md = extern struct {
    unnamed_0: union_unnamed_96 = @import("std").mem.zeroes(union_unnamed_96),
    unnamed_1: union_unnamed_97 = @import("std").mem.zeroes(union_unnamed_97),
    len: __u32 = 0,
    eth_protocol: __u32 = 0,
    ip_protocol: __u32 = 0,
    bind_inany: __u32 = 0,
    hash: __u32 = 0,
    unnamed_2: union_unnamed_98 = @import("std").mem.zeroes(union_unnamed_98),
    unnamed_3: union_unnamed_99 = @import("std").mem.zeroes(union_unnamed_99),
}; // /usr/include/linux/bpf.h:6624:8: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_prog_info = opaque {};
pub const struct_bpf_map_info = extern struct {
    type: __u32 = 0,
    id: __u32 = 0,
    key_size: __u32 = 0,
    value_size: __u32 = 0,
    max_entries: __u32 = 0,
    map_flags: __u32 = 0,
    name: [16]u8 = @import("std").mem.zeroes([16]u8),
    ifindex: __u32 = 0,
    btf_vmlinux_value_type_id: __u32 = 0,
    netns_dev: __u64 = 0,
    netns_ino: __u64 = 0,
    btf_id: __u32 = 0,
    btf_key_type_id: __u32 = 0,
    btf_value_type_id: __u32 = 0,
    btf_vmlinux_id: __u32 = 0,
    map_extra: __u64 = 0,
};
pub const struct_bpf_btf_info = extern struct {
    btf: __u64 = 0,
    btf_size: __u32 = 0,
    id: __u32 = 0,
    name: __u64 = 0,
    name_len: __u32 = 0,
    kernel_btf: __u32 = 0,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_101 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_102 = opaque {};
const struct_unnamed_103 = extern struct {
    cgroup_id: __u64 = 0,
    attach_type: __u32 = 0,
};
const struct_unnamed_106 = extern struct {
    map_id: __u32 = 0,
};
const union_unnamed_105 = extern union {
    map: struct_unnamed_106,
};
const struct_unnamed_108 = extern struct {
    cgroup_id: __u64 = 0,
    order: __u32 = 0,
};
const struct_unnamed_109 = extern struct {
    tid: __u32 = 0,
    pid: __u32 = 0,
};
const union_unnamed_107 = extern union {
    cgroup: struct_unnamed_108,
    task: struct_unnamed_109,
};
const struct_unnamed_104 = extern struct {
    target_name: __u64 = 0,
    target_name_len: __u32 = 0,
    unnamed_0: union_unnamed_105 = @import("std").mem.zeroes(union_unnamed_105),
    unnamed_1: union_unnamed_107 = @import("std").mem.zeroes(union_unnamed_107),
};
const struct_unnamed_110 = extern struct {
    netns_ino: __u32 = 0,
    attach_type: __u32 = 0,
};
const struct_unnamed_111 = extern struct {
    ifindex: __u32 = 0,
};
const struct_unnamed_112 = extern struct {
    map_id: __u32 = 0,
};
const struct_unnamed_113 = extern struct {
    pf: __u32 = 0,
    hooknum: __u32 = 0,
    priority: __s32 = 0,
    flags: __u32 = 0,
};
const struct_unnamed_114 = extern struct {
    addrs: __u64 = 0,
    count: __u32 = 0,
    flags: __u32 = 0,
    missed: __u64 = 0,
    cookies: __u64 = 0,
};
const struct_unnamed_115 = extern struct {
    path: __u64 = 0,
    offsets: __u64 = 0,
    ref_ctr_offsets: __u64 = 0,
    cookies: __u64 = 0,
    path_size: __u32 = 0,
    count: __u32 = 0,
    flags: __u32 = 0,
    pid: __u32 = 0,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_116 = opaque {};
const struct_unnamed_117 = extern struct {
    ifindex: __u32 = 0,
    attach_type: __u32 = 0,
};
const struct_unnamed_118 = extern struct {
    ifindex: __u32 = 0,
    attach_type: __u32 = 0,
};
const struct_unnamed_119 = extern struct {
    map_id: __u32 = 0,
    attach_type: __u32 = 0,
};
const union_unnamed_100 = extern union {
    raw_tracepoint: struct_unnamed_101,
    tracing: struct_unnamed_102,
    cgroup: struct_unnamed_103,
    iter: struct_unnamed_104,
    netns: struct_unnamed_110,
    xdp: struct_unnamed_111,
    struct_ops: struct_unnamed_112,
    netfilter: struct_unnamed_113,
    kprobe_multi: struct_unnamed_114,
    uprobe_multi: struct_unnamed_115,
    perf_event: struct_unnamed_116,
    tcx: struct_unnamed_117,
    netkit: struct_unnamed_118,
    sockmap: struct_unnamed_119,
};
pub const struct_bpf_link_info = extern struct {
    type: __u32 = 0,
    id: __u32 = 0,
    prog_id: __u32 = 0,
    unnamed_0: union_unnamed_100 = @import("std").mem.zeroes(union_unnamed_100),
};
pub const struct_bpf_token_info = extern struct {
    allowed_cmds: __u64 = 0,
    allowed_maps: __u64 = 0,
    allowed_progs: __u64 = 0,
    allowed_attachs: __u64 = 0,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_120 = opaque {};
pub const struct_bpf_sock_addr = extern struct {
    user_family: __u32 = 0,
    user_ip4: __u32 = 0,
    user_ip6: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    user_port: __u32 = 0,
    family: __u32 = 0,
    type: __u32 = 0,
    protocol: __u32 = 0,
    msg_src_ip4: __u32 = 0,
    msg_src_ip6: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    unnamed_0: union_unnamed_120 = @import("std").mem.zeroes(union_unnamed_120),
};
const union_unnamed_121 = extern union {
    args: [4]__u32,
    reply: __u32,
    replylong: [4]__u32,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_122 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_123 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_124 = opaque {};
pub const struct_bpf_sock_ops = extern struct {
    op: __u32 = 0,
    unnamed_0: union_unnamed_121 = @import("std").mem.zeroes(union_unnamed_121),
    family: __u32 = 0,
    remote_ip4: __u32 = 0,
    local_ip4: __u32 = 0,
    remote_ip6: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    local_ip6: [4]__u32 = @import("std").mem.zeroes([4]__u32),
    remote_port: __u32 = 0,
    local_port: __u32 = 0,
    is_fullsock: __u32 = 0,
    snd_cwnd: __u32 = 0,
    srtt_us: __u32 = 0,
    bpf_sock_ops_cb_flags: __u32 = 0,
    state: __u32 = 0,
    rtt_min: __u32 = 0,
    snd_ssthresh: __u32 = 0,
    rcv_nxt: __u32 = 0,
    snd_nxt: __u32 = 0,
    snd_una: __u32 = 0,
    mss_cache: __u32 = 0,
    ecn_flags: __u32 = 0,
    rate_delivered: __u32 = 0,
    rate_interval_us: __u32 = 0,
    packets_out: __u32 = 0,
    retrans_out: __u32 = 0,
    total_retrans: __u32 = 0,
    segs_in: __u32 = 0,
    data_segs_in: __u32 = 0,
    segs_out: __u32 = 0,
    data_segs_out: __u32 = 0,
    lost_out: __u32 = 0,
    sacked_out: __u32 = 0,
    sk_txhash: __u32 = 0,
    bytes_received: __u64 = 0,
    bytes_acked: __u64 = 0,
    unnamed_1: union_unnamed_122 = @import("std").mem.zeroes(union_unnamed_122),
    unnamed_2: union_unnamed_123 = @import("std").mem.zeroes(union_unnamed_123),
    unnamed_3: union_unnamed_124 = @import("std").mem.zeroes(union_unnamed_124),
    skb_len: __u32 = 0,
    skb_tcp_flags: __u32 = 0,
    skb_hwtstamp: __u64 = 0,
};
pub const BPF_SOCK_OPS_RTO_CB_FLAG: c_int = 1;
pub const BPF_SOCK_OPS_RETRANS_CB_FLAG: c_int = 2;
pub const BPF_SOCK_OPS_STATE_CB_FLAG: c_int = 4;
pub const BPF_SOCK_OPS_RTT_CB_FLAG: c_int = 8;
pub const BPF_SOCK_OPS_PARSE_ALL_HDR_OPT_CB_FLAG: c_int = 16;
pub const BPF_SOCK_OPS_PARSE_UNKNOWN_HDR_OPT_CB_FLAG: c_int = 32;
pub const BPF_SOCK_OPS_WRITE_HDR_OPT_CB_FLAG: c_int = 64;
pub const BPF_SOCK_OPS_ALL_CB_FLAGS: c_int = 127;
const enum_unnamed_125 = c_uint;
pub const SK_BPF_CB_TX_TIMESTAMPING: c_int = 1;
pub const SK_BPF_CB_MASK: c_int = 1;
const enum_unnamed_126 = c_uint;
pub const BPF_SOCK_OPS_VOID: c_int = 0;
pub const BPF_SOCK_OPS_TIMEOUT_INIT: c_int = 1;
pub const BPF_SOCK_OPS_RWND_INIT: c_int = 2;
pub const BPF_SOCK_OPS_TCP_CONNECT_CB: c_int = 3;
pub const BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB: c_int = 4;
pub const BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB: c_int = 5;
pub const BPF_SOCK_OPS_NEEDS_ECN: c_int = 6;
pub const BPF_SOCK_OPS_BASE_RTT: c_int = 7;
pub const BPF_SOCK_OPS_RTO_CB: c_int = 8;
pub const BPF_SOCK_OPS_RETRANS_CB: c_int = 9;
pub const BPF_SOCK_OPS_STATE_CB: c_int = 10;
pub const BPF_SOCK_OPS_TCP_LISTEN_CB: c_int = 11;
pub const BPF_SOCK_OPS_RTT_CB: c_int = 12;
pub const BPF_SOCK_OPS_PARSE_HDR_OPT_CB: c_int = 13;
pub const BPF_SOCK_OPS_HDR_OPT_LEN_CB: c_int = 14;
pub const BPF_SOCK_OPS_WRITE_HDR_OPT_CB: c_int = 15;
pub const BPF_SOCK_OPS_TSTAMP_SCHED_CB: c_int = 16;
pub const BPF_SOCK_OPS_TSTAMP_SND_SW_CB: c_int = 17;
pub const BPF_SOCK_OPS_TSTAMP_SND_HW_CB: c_int = 18;
pub const BPF_SOCK_OPS_TSTAMP_ACK_CB: c_int = 19;
pub const BPF_SOCK_OPS_TSTAMP_SENDMSG_CB: c_int = 20;
const enum_unnamed_127 = c_uint;
pub const BPF_TCP_ESTABLISHED: c_int = 1;
pub const BPF_TCP_SYN_SENT: c_int = 2;
pub const BPF_TCP_SYN_RECV: c_int = 3;
pub const BPF_TCP_FIN_WAIT1: c_int = 4;
pub const BPF_TCP_FIN_WAIT2: c_int = 5;
pub const BPF_TCP_TIME_WAIT: c_int = 6;
pub const BPF_TCP_CLOSE: c_int = 7;
pub const BPF_TCP_CLOSE_WAIT: c_int = 8;
pub const BPF_TCP_LAST_ACK: c_int = 9;
pub const BPF_TCP_LISTEN: c_int = 10;
pub const BPF_TCP_CLOSING: c_int = 11;
pub const BPF_TCP_NEW_SYN_RECV: c_int = 12;
pub const BPF_TCP_BOUND_INACTIVE: c_int = 13;
pub const BPF_TCP_MAX_STATES: c_int = 14;
const enum_unnamed_128 = c_uint;
pub const TCP_BPF_IW: c_int = 1001;
pub const TCP_BPF_SNDCWND_CLAMP: c_int = 1002;
pub const TCP_BPF_DELACK_MAX: c_int = 1003;
pub const TCP_BPF_RTO_MIN: c_int = 1004;
pub const TCP_BPF_SYN: c_int = 1005;
pub const TCP_BPF_SYN_IP: c_int = 1006;
pub const TCP_BPF_SYN_MAC: c_int = 1007;
pub const TCP_BPF_SOCK_OPS_CB_FLAGS: c_int = 1008;
pub const SK_BPF_CB_FLAGS: c_int = 1009;
const enum_unnamed_129 = c_uint;
pub const BPF_LOAD_HDR_OPT_TCP_SYN: c_int = 1;
const enum_unnamed_130 = c_uint;
pub const BPF_WRITE_HDR_TCP_CURRENT_MSS: c_int = 1;
pub const BPF_WRITE_HDR_TCP_SYNACK_COOKIE: c_int = 2;
const enum_unnamed_131 = c_uint;
pub const struct_bpf_perf_event_value = extern struct {
    counter: __u64 = 0,
    enabled: __u64 = 0,
    running: __u64 = 0,
};
pub const BPF_DEVCG_ACC_MKNOD: c_int = 1;
pub const BPF_DEVCG_ACC_READ: c_int = 2;
pub const BPF_DEVCG_ACC_WRITE: c_int = 4;
const enum_unnamed_132 = c_uint;
pub const BPF_DEVCG_DEV_BLOCK: c_int = 1;
pub const BPF_DEVCG_DEV_CHAR: c_int = 2;
const enum_unnamed_133 = c_uint;
pub const struct_bpf_cgroup_dev_ctx = extern struct {
    access_type: __u32 = 0,
    major: __u32 = 0,
    minor: __u32 = 0,
};
pub const struct_bpf_raw_tracepoint_args = extern struct {
    _args: [0]__u64 = @import("std").mem.zeroes([0]__u64),
    pub fn args(self: anytype) __helpers.FlexibleArrayType(@TypeOf(self), @typeInfo(@TypeOf(self.*._args)).array.child) {
        return @ptrCast(@alignCast(&self.*._args));
    }
};
pub const BPF_FIB_LOOKUP_DIRECT: c_int = 1;
pub const BPF_FIB_LOOKUP_OUTPUT: c_int = 2;
pub const BPF_FIB_LOOKUP_SKIP_NEIGH: c_int = 4;
pub const BPF_FIB_LOOKUP_TBID: c_int = 8;
pub const BPF_FIB_LOOKUP_SRC: c_int = 16;
pub const BPF_FIB_LOOKUP_MARK: c_int = 32;
const enum_unnamed_134 = c_uint;
pub const BPF_FIB_LKUP_RET_SUCCESS: c_int = 0;
pub const BPF_FIB_LKUP_RET_BLACKHOLE: c_int = 1;
pub const BPF_FIB_LKUP_RET_UNREACHABLE: c_int = 2;
pub const BPF_FIB_LKUP_RET_PROHIBIT: c_int = 3;
pub const BPF_FIB_LKUP_RET_NOT_FWDED: c_int = 4;
pub const BPF_FIB_LKUP_RET_FWD_DISABLED: c_int = 5;
pub const BPF_FIB_LKUP_RET_UNSUPP_LWT: c_int = 6;
pub const BPF_FIB_LKUP_RET_NO_NEIGH: c_int = 7;
pub const BPF_FIB_LKUP_RET_FRAG_NEEDED: c_int = 8;
pub const BPF_FIB_LKUP_RET_NO_SRC_ADDR: c_int = 9;
const enum_unnamed_135 = c_uint;
const union_unnamed_136 = extern union {
    tot_len: __u16,
    mtu_result: __u16,
};
const union_unnamed_137 = extern union {
    tos: __u8,
    flowinfo: __be32,
    rt_metric: __u32,
};
const union_unnamed_138 = extern union {
    ipv4_src: __be32,
    ipv6_src: [4]__u32,
};
const union_unnamed_139 = extern union {
    ipv4_dst: __be32,
    ipv6_dst: [4]__u32,
};
const struct_unnamed_141 = extern struct {
    h_vlan_proto: __be16 = 0,
    h_vlan_TCI: __be16 = 0,
};
const union_unnamed_140 = extern union {
    unnamed_0: struct_unnamed_141,
    tbid: __u32,
};
const struct_unnamed_143 = extern struct {
    mark: __u32 = 0,
};
const struct_unnamed_144 = extern struct {
    smac: [6]__u8 = @import("std").mem.zeroes([6]__u8),
    dmac: [6]__u8 = @import("std").mem.zeroes([6]__u8),
};
const union_unnamed_142 = extern union {
    unnamed_0: struct_unnamed_143,
    unnamed_1: struct_unnamed_144,
};
pub const struct_bpf_fib_lookup = extern struct {
    family: __u8 = 0,
    l4_protocol: __u8 = 0,
    sport: __be16 = 0,
    dport: __be16 = 0,
    unnamed_0: union_unnamed_136 = @import("std").mem.zeroes(union_unnamed_136),
    ifindex: __u32 = 0,
    unnamed_1: union_unnamed_137 = @import("std").mem.zeroes(union_unnamed_137),
    unnamed_2: union_unnamed_138 = @import("std").mem.zeroes(union_unnamed_138),
    unnamed_3: union_unnamed_139 = @import("std").mem.zeroes(union_unnamed_139),
    unnamed_4: union_unnamed_140 = @import("std").mem.zeroes(union_unnamed_140),
    unnamed_5: union_unnamed_142 = @import("std").mem.zeroes(union_unnamed_142),
};
const union_unnamed_145 = extern union {
    ipv4_nh: __be32,
    ipv6_nh: [4]__u32,
};
pub const struct_bpf_redir_neigh = extern struct {
    nh_family: __u32 = 0,
    unnamed_0: union_unnamed_145 = @import("std").mem.zeroes(union_unnamed_145),
};
pub const BPF_MTU_CHK_SEGS: c_int = 1;
pub const enum_bpf_check_mtu_flags = c_uint;
pub const BPF_MTU_CHK_RET_SUCCESS: c_int = 0;
pub const BPF_MTU_CHK_RET_FRAG_NEEDED: c_int = 1;
pub const BPF_MTU_CHK_RET_SEGS_TOOBIG: c_int = 2;
pub const enum_bpf_check_mtu_ret = c_uint;
pub const BPF_FD_TYPE_RAW_TRACEPOINT: c_int = 0;
pub const BPF_FD_TYPE_TRACEPOINT: c_int = 1;
pub const BPF_FD_TYPE_KPROBE: c_int = 2;
pub const BPF_FD_TYPE_KRETPROBE: c_int = 3;
pub const BPF_FD_TYPE_UPROBE: c_int = 4;
pub const BPF_FD_TYPE_URETPROBE: c_int = 5;
pub const enum_bpf_task_fd_type = c_uint;
pub const BPF_FLOW_DISSECTOR_F_PARSE_1ST_FRAG: c_int = 1;
pub const BPF_FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL: c_int = 2;
pub const BPF_FLOW_DISSECTOR_F_STOP_AT_ENCAP: c_int = 4;
const enum_unnamed_146 = c_uint;
pub const struct_bpf_func_info = extern struct {
    insn_off: __u32 = 0,
    type_id: __u32 = 0,
};
pub const struct_bpf_line_info = extern struct {
    insn_off: __u32 = 0,
    file_name_off: __u32 = 0,
    line_off: __u32 = 0,
    line_col: __u32 = 0,
};
pub const struct_bpf_spin_lock = extern struct {
    val: __u32 = 0,
};
pub const struct_bpf_timer = extern struct {
    __opaque: [2]__u64 = @import("std").mem.zeroes([2]__u64),
};
pub const struct_bpf_wq = extern struct {
    __opaque: [2]__u64 = @import("std").mem.zeroes([2]__u64),
};
pub const struct_bpf_dynptr = extern struct {
    __opaque: [2]__u64 = @import("std").mem.zeroes([2]__u64),
};
pub const struct_bpf_list_head = extern struct {
    __opaque: [2]__u64 = @import("std").mem.zeroes([2]__u64),
};
pub const struct_bpf_list_node = extern struct {
    __opaque: [3]__u64 = @import("std").mem.zeroes([3]__u64),
};
pub const struct_bpf_rb_root = extern struct {
    __opaque: [2]__u64 = @import("std").mem.zeroes([2]__u64),
};
pub const struct_bpf_rb_node = extern struct {
    __opaque: [4]__u64 = @import("std").mem.zeroes([4]__u64),
};
pub const struct_bpf_refcount = extern struct {
    __opaque: [1]__u32 = @import("std").mem.zeroes([1]__u32),
};
pub const struct_bpf_sysctl = extern struct {
    write: __u32 = 0,
    file_pos: __u32 = 0,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_147 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_148 = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_149 = opaque {};
pub const struct_bpf_sockopt = extern struct {
    unnamed_0: union_unnamed_147 = @import("std").mem.zeroes(union_unnamed_147),
    unnamed_1: union_unnamed_148 = @import("std").mem.zeroes(union_unnamed_148),
    unnamed_2: union_unnamed_149 = @import("std").mem.zeroes(union_unnamed_149),
    level: __s32 = 0,
    optname: __s32 = 0,
    optlen: __s32 = 0,
    retval: __s32 = 0,
};
pub const struct_bpf_pidns_info = extern struct {
    pid: __u32 = 0,
    tgid: __u32 = 0,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: union demoted to opaque type - has bitfield
const union_unnamed_151 = opaque {};
const union_unnamed_150 = extern union {
    unnamed_0: union_unnamed_151,
    cookie: __u64,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_sk_lookup = opaque {};
pub const struct_btf_ptr = extern struct {
    ptr: ?*anyopaque = null,
    type_id: __u32 = 0,
    flags: __u32 = 0,
};
pub const BTF_F_COMPACT: c_int = 1;
pub const BTF_F_NONAME: c_int = 2;
pub const BTF_F_PTR_RAW: c_int = 4;
pub const BTF_F_ZERO: c_int = 8;
const enum_unnamed_152 = c_uint;
pub const BPF_CORE_FIELD_BYTE_OFFSET: c_int = 0;
pub const BPF_CORE_FIELD_BYTE_SIZE: c_int = 1;
pub const BPF_CORE_FIELD_EXISTS: c_int = 2;
pub const BPF_CORE_FIELD_SIGNED: c_int = 3;
pub const BPF_CORE_FIELD_LSHIFT_U64: c_int = 4;
pub const BPF_CORE_FIELD_RSHIFT_U64: c_int = 5;
pub const BPF_CORE_TYPE_ID_LOCAL: c_int = 6;
pub const BPF_CORE_TYPE_ID_TARGET: c_int = 7;
pub const BPF_CORE_TYPE_EXISTS: c_int = 8;
pub const BPF_CORE_TYPE_SIZE: c_int = 9;
pub const BPF_CORE_ENUMVAL_EXISTS: c_int = 10;
pub const BPF_CORE_ENUMVAL_VALUE: c_int = 11;
pub const BPF_CORE_TYPE_MATCHES: c_int = 12;
pub const enum_bpf_core_relo_kind = c_uint;
pub const struct_bpf_core_relo = extern struct {
    insn_off: __u32 = 0,
    type_id: __u32 = 0,
    access_str_off: __u32 = 0,
    kind: enum_bpf_core_relo_kind = @import("std").mem.zeroes(enum_bpf_core_relo_kind),
};
pub const BPF_F_TIMER_ABS: c_int = 1;
pub const BPF_F_TIMER_CPU_PIN: c_int = 2;
const enum_unnamed_153 = c_uint;
pub const struct_bpf_iter_num = extern struct {
    __opaque: [1]__u64 = @import("std").mem.zeroes([1]__u64),
};
pub const BPF_F_PAD_ZEROS: c_int = 1;
pub const enum_bpf_kfunc_flags = c_uint;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __aro_max_align_ll: c_longlong = 0,
    __aro_max_align_ld: c_longdouble = 0,
};
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
pub extern fn memcpy(noalias __dest: ?*anyopaque, noalias __src: ?*const anyopaque, __n: usize) ?*anyopaque;
pub extern fn memmove(__dest: ?*anyopaque, __src: ?*const anyopaque, __n: usize) ?*anyopaque;
pub extern fn memccpy(noalias __dest: ?*anyopaque, noalias __src: ?*const anyopaque, __c: c_int, __n: usize) ?*anyopaque;
pub extern fn memset(__s: ?*anyopaque, __c: c_int, __n: usize) ?*anyopaque;
pub extern fn memcmp(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: usize) c_int;
pub extern fn __memcmpeq(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: usize) c_int;
pub extern fn memchr(__s: ?*const anyopaque, __c: c_int, __n: usize) ?*anyopaque;
pub extern fn strcpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8) [*c]u8;
pub extern fn strncpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) [*c]u8;
pub extern fn strcat(noalias __dest: [*c]u8, noalias __src: [*c]const u8) [*c]u8;
pub extern fn strncat(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) [*c]u8;
pub extern fn strcmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strncmp(__s1: [*c]const u8, __s2: [*c]const u8, __n: usize) c_int;
pub extern fn strcoll(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strxfrm(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) usize;
pub const struct___locale_data_154 = opaque {};
pub const struct___locale_struct = extern struct {
    __locales: [13]?*struct___locale_data_154 = @import("std").mem.zeroes([13]?*struct___locale_data_154),
    __ctype_b: [*c]const c_ushort = null,
    __ctype_tolower: [*c]const c_int = null,
    __ctype_toupper: [*c]const c_int = null,
    __names: [13][*c]const u8 = @import("std").mem.zeroes([13][*c]const u8),
};
pub const __locale_t = [*c]struct___locale_struct;
pub const locale_t = __locale_t;
pub extern fn strcoll_l(__s1: [*c]const u8, __s2: [*c]const u8, __l: locale_t) c_int;
pub extern fn strxfrm_l(__dest: [*c]u8, __src: [*c]const u8, __n: usize, __l: locale_t) usize;
pub extern fn strdup(__s: [*c]const u8) [*c]u8;
pub extern fn strndup(__string: [*c]const u8, __n: usize) [*c]u8;
pub extern fn strchr(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strrchr(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strchrnul(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strcspn(__s: [*c]const u8, __reject: [*c]const u8) usize;
pub extern fn strspn(__s: [*c]const u8, __accept: [*c]const u8) usize;
pub extern fn strpbrk(__s: [*c]const u8, __accept: [*c]const u8) [*c]u8;
pub extern fn strstr(__haystack: [*c]const u8, __needle: [*c]const u8) [*c]u8;
pub extern fn strtok(noalias __s: [*c]u8, noalias __delim: [*c]const u8) [*c]u8;
pub extern fn __strtok_r(noalias __s: [*c]u8, noalias __delim: [*c]const u8, noalias __save_ptr: [*c][*c]u8) [*c]u8;
pub extern fn strtok_r(noalias __s: [*c]u8, noalias __delim: [*c]const u8, noalias __save_ptr: [*c][*c]u8) [*c]u8;
pub extern fn strcasestr(__haystack: [*c]const u8, __needle: [*c]const u8) [*c]u8;
pub extern fn memmem(__haystack: ?*const anyopaque, __haystacklen: usize, __needle: ?*const anyopaque, __needlelen: usize) ?*anyopaque;
pub extern fn __mempcpy(noalias __dest: ?*anyopaque, noalias __src: ?*const anyopaque, __n: usize) ?*anyopaque;
pub extern fn mempcpy(noalias __dest: ?*anyopaque, noalias __src: ?*const anyopaque, __n: usize) ?*anyopaque;
pub extern fn strlen(__s: [*c]const u8) usize;
pub extern fn strnlen(__string: [*c]const u8, __maxlen: usize) usize;
pub extern fn strerror(__errnum: c_int) [*c]u8;
pub extern fn strerror_r(__errnum: c_int, __buf: [*c]u8, __buflen: usize) c_int;
pub extern fn strerror_l(__errnum: c_int, __l: locale_t) [*c]u8;
pub extern fn bcmp(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: usize) c_int;
pub extern fn bcopy(__src: ?*const anyopaque, __dest: ?*anyopaque, __n: usize) void;
pub extern fn bzero(__s: ?*anyopaque, __n: usize) void;
pub extern fn index(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn rindex(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn ffs(__i: c_int) c_int;
pub extern fn ffsl(__l: c_long) c_int;
pub extern fn ffsll(__ll: c_longlong) c_int;
pub extern fn strcasecmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strncasecmp(__s1: [*c]const u8, __s2: [*c]const u8, __n: usize) c_int;
pub extern fn strcasecmp_l(__s1: [*c]const u8, __s2: [*c]const u8, __loc: locale_t) c_int;
pub extern fn strncasecmp_l(__s1: [*c]const u8, __s2: [*c]const u8, __n: usize, __loc: locale_t) c_int;
pub extern fn explicit_bzero(__s: ?*anyopaque, __n: usize) void;
pub extern fn strsep(noalias __stringp: [*c][*c]u8, noalias __delim: [*c]const u8) [*c]u8;
pub extern fn strsignal(__sig: c_int) [*c]u8;
pub extern fn __stpcpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8) [*c]u8;
pub extern fn stpcpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8) [*c]u8;
pub extern fn __stpncpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) [*c]u8;
pub extern fn stpncpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) [*c]u8;
pub extern fn strlcpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) usize;
pub extern fn strlcat(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) usize;
pub const LIBBPF_STRICT_ALL: c_uint = 4294967295;
pub const LIBBPF_STRICT_NONE: c_uint = 0;
pub const LIBBPF_STRICT_CLEAN_PTRS: c_uint = 1;
pub const LIBBPF_STRICT_DIRECT_ERRS: c_uint = 2;
pub const LIBBPF_STRICT_SEC_NAME: c_uint = 4;
pub const LIBBPF_STRICT_NO_OBJECT_LIST: c_uint = 8;
pub const LIBBPF_STRICT_AUTO_RLIMIT_MEMLOCK: c_uint = 16;
pub const LIBBPF_STRICT_MAP_DEFINITIONS: c_uint = 32;
pub const __LIBBPF_STRICT_LAST: c_uint = 33;
pub const enum_libbpf_strict_mode = c_uint;
pub extern fn libbpf_set_strict_mode(mode: enum_libbpf_strict_mode) c_int;
pub extern fn libbpf_get_error(ptr: ?*const anyopaque) c_long;
pub const struct_btf = opaque {};
pub extern fn libbpf_find_kernel_btf() ?*struct_btf;
pub const struct_bpf_program = opaque {
    pub const bpf_program__get_type = __root.bpf_program__get_type;
    pub const bpf_program__get_expected_attach_type = __root.bpf_program__get_expected_attach_type;
    pub const bpf_program__name = __root.bpf_program__name;
    pub const bpf_program__section_name = __root.bpf_program__section_name;
    pub const bpf_program__autoload = __root.bpf_program__autoload;
    pub const bpf_program__autoattach = __root.bpf_program__autoattach;
    pub const bpf_program__insns = __root.bpf_program__insns;
    pub const bpf_program__insn_cnt = __root.bpf_program__insn_cnt;
    pub const bpf_program__fd = __root.bpf_program__fd;
    pub const bpf_program__attach = __root.bpf_program__attach;
    pub const bpf_program__attach_perf_event = __root.bpf_program__attach_perf_event;
    pub const bpf_program__attach_perf_event_opts = __root.bpf_program__attach_perf_event_opts;
    pub const bpf_program__attach_kprobe = __root.bpf_program__attach_kprobe;
    pub const bpf_program__attach_kprobe_opts = __root.bpf_program__attach_kprobe_opts;
    pub const bpf_program__attach_kprobe_multi_opts = __root.bpf_program__attach_kprobe_multi_opts;
    pub const bpf_program__attach_uprobe_multi = __root.bpf_program__attach_uprobe_multi;
    pub const bpf_program__attach_ksyscall = __root.bpf_program__attach_ksyscall;
    pub const bpf_program__attach_uprobe = __root.bpf_program__attach_uprobe;
    pub const bpf_program__attach_uprobe_opts = __root.bpf_program__attach_uprobe_opts;
    pub const bpf_program__attach_usdt = __root.bpf_program__attach_usdt;
    pub const bpf_program__attach_tracepoint = __root.bpf_program__attach_tracepoint;
    pub const bpf_program__attach_tracepoint_opts = __root.bpf_program__attach_tracepoint_opts;
    pub const bpf_program__attach_raw_tracepoint = __root.bpf_program__attach_raw_tracepoint;
    pub const bpf_program__attach_raw_tracepoint_opts = __root.bpf_program__attach_raw_tracepoint_opts;
    pub const bpf_program__attach_trace = __root.bpf_program__attach_trace;
    pub const bpf_program__attach_trace_opts = __root.bpf_program__attach_trace_opts;
    pub const bpf_program__attach_lsm = __root.bpf_program__attach_lsm;
    pub const bpf_program__attach_cgroup = __root.bpf_program__attach_cgroup;
    pub const bpf_program__attach_netns = __root.bpf_program__attach_netns;
    pub const bpf_program__attach_sockmap = __root.bpf_program__attach_sockmap;
    pub const bpf_program__attach_xdp = __root.bpf_program__attach_xdp;
    pub const bpf_program__attach_freplace = __root.bpf_program__attach_freplace;
    pub const bpf_program__attach_netfilter = __root.bpf_program__attach_netfilter;
    pub const bpf_program__attach_tcx = __root.bpf_program__attach_tcx;
    pub const bpf_program__attach_netkit = __root.bpf_program__attach_netkit;
    pub const bpf_program__attach_iter = __root.bpf_program__attach_iter;
    pub const bpf_program__type = __root.bpf_program__type;
    pub const bpf_program__expected_attach_type = __root.bpf_program__expected_attach_type;
    pub const bpf_program__flags = __root.bpf_program__flags;
    pub const bpf_program__log_level = __root.bpf_program__log_level;
    pub const bpf_program__log_buf = __root.bpf_program__log_buf;
    pub const @"type" = __root.bpf_program__get_type;
    pub const name = __root.bpf_program__name;
    pub const autoload = __root.bpf_program__autoload;
    pub const autoattach = __root.bpf_program__autoattach;
    pub const insns = __root.bpf_program__insns;
    pub const cnt = __root.bpf_program__insn_cnt;
    pub const fd = __root.bpf_program__fd;
    pub const attach = __root.bpf_program__attach;
    pub const event = __root.bpf_program__attach_perf_event;
    pub const opts = __root.bpf_program__attach_perf_event_opts;
    pub const kprobe = __root.bpf_program__attach_kprobe;
    pub const multi = __root.bpf_program__attach_uprobe_multi;
    pub const ksyscall = __root.bpf_program__attach_ksyscall;
    pub const uprobe = __root.bpf_program__attach_uprobe;
    pub const usdt = __root.bpf_program__attach_usdt;
    pub const tracepoint = __root.bpf_program__attach_tracepoint;
    pub const trace = __root.bpf_program__attach_trace;
    pub const lsm = __root.bpf_program__attach_lsm;
    pub const cgroup = __root.bpf_program__attach_cgroup;
    pub const netns = __root.bpf_program__attach_netns;
    pub const sockmap = __root.bpf_program__attach_sockmap;
    pub const xdp = __root.bpf_program__attach_xdp;
    pub const freplace = __root.bpf_program__attach_freplace;
    pub const netfilter = __root.bpf_program__attach_netfilter;
    pub const tcx = __root.bpf_program__attach_tcx;
    pub const netkit = __root.bpf_program__attach_netkit;
    pub const iter = __root.bpf_program__attach_iter;
    pub const flags = __root.bpf_program__flags;
    pub const level = __root.bpf_program__log_level;
    pub const buf = __root.bpf_program__log_buf;
};
pub extern fn bpf_program__get_type(prog: ?*const struct_bpf_program) enum_bpf_prog_type;
pub extern fn bpf_program__get_expected_attach_type(prog: ?*const struct_bpf_program) enum_bpf_attach_type;
pub const struct_bpf_map = opaque {
    pub const bpf_map__get_pin_path = __root.bpf_map__get_pin_path;
    pub const bpf_map__attach_struct_ops = __root.bpf_map__attach_struct_ops;
    pub const bpf_map__autocreate = __root.bpf_map__autocreate;
    pub const bpf_map__autoattach = __root.bpf_map__autoattach;
    pub const bpf_map__fd = __root.bpf_map__fd;
    pub const bpf_map__name = __root.bpf_map__name;
    pub const bpf_map__type = __root.bpf_map__type;
    pub const bpf_map__max_entries = __root.bpf_map__max_entries;
    pub const bpf_map__map_flags = __root.bpf_map__map_flags;
    pub const bpf_map__numa_node = __root.bpf_map__numa_node;
    pub const bpf_map__key_size = __root.bpf_map__key_size;
    pub const bpf_map__value_size = __root.bpf_map__value_size;
    pub const bpf_map__btf_key_type_id = __root.bpf_map__btf_key_type_id;
    pub const bpf_map__btf_value_type_id = __root.bpf_map__btf_value_type_id;
    pub const bpf_map__ifindex = __root.bpf_map__ifindex;
    pub const bpf_map__map_extra = __root.bpf_map__map_extra;
    pub const bpf_map__initial_value = __root.bpf_map__initial_value;
    pub const bpf_map__is_internal = __root.bpf_map__is_internal;
    pub const bpf_map__pin_path = __root.bpf_map__pin_path;
    pub const bpf_map__is_pinned = __root.bpf_map__is_pinned;
    pub const bpf_map__lookup_elem = __root.bpf_map__lookup_elem;
    pub const bpf_map__update_elem = __root.bpf_map__update_elem;
    pub const bpf_map__delete_elem = __root.bpf_map__delete_elem;
    pub const bpf_map__lookup_and_delete_elem = __root.bpf_map__lookup_and_delete_elem;
    pub const bpf_map__get_next_key = __root.bpf_map__get_next_key;
    pub const path = __root.bpf_map__get_pin_path;
    pub const ops = __root.bpf_map__attach_struct_ops;
    pub const autocreate = __root.bpf_map__autocreate;
    pub const autoattach = __root.bpf_map__autoattach;
    pub const fd = __root.bpf_map__fd;
    pub const name = __root.bpf_map__name;
    pub const @"type" = __root.bpf_map__type;
    pub const entries = __root.bpf_map__max_entries;
    pub const flags = __root.bpf_map__map_flags;
    pub const node = __root.bpf_map__numa_node;
    pub const size = __root.bpf_map__key_size;
    pub const id = __root.bpf_map__btf_key_type_id;
    pub const ifindex = __root.bpf_map__ifindex;
    pub const extra = __root.bpf_map__map_extra;
    pub const value = __root.bpf_map__initial_value;
    pub const internal = __root.bpf_map__is_internal;
    pub const pinned = __root.bpf_map__is_pinned;
    pub const elem = __root.bpf_map__lookup_elem;
    pub const key = __root.bpf_map__get_next_key;
};
pub extern fn bpf_map__get_pin_path(map: ?*const struct_bpf_map) [*c]const u8;
pub extern fn btf__get_raw_data(btf: ?*const struct_btf, size: [*c]__u32) ?*const anyopaque;
pub const struct_btf_ext = opaque {
    pub const btf_ext__get_raw_data = __root.btf_ext__get_raw_data;
    pub const data = __root.btf_ext__get_raw_data;
};
pub extern fn btf_ext__get_raw_data(btf_ext: ?*const struct_btf_ext, size: [*c]__u32) ?*const anyopaque;
pub extern fn libbpf_set_memlock_rlim(memlock_bytes: usize) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_map_create_opts = opaque {};
pub extern fn bpf_map_create(map_type: enum_bpf_map_type, map_name: [*c]const u8, key_size: __u32, value_size: __u32, max_entries: __u32, opts: ?*const struct_bpf_map_create_opts) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_prog_load_opts = opaque {};
pub extern fn bpf_prog_load(prog_type: enum_bpf_prog_type, prog_name: [*c]const u8, license: [*c]const u8, insns: ?*const struct_bpf_insn, insn_cnt: usize, opts: ?*struct_bpf_prog_load_opts) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_btf_load_opts = opaque {};
pub extern fn bpf_btf_load(btf_data: ?*const anyopaque, btf_size: usize, opts: ?*struct_bpf_btf_load_opts) c_int;
pub extern fn bpf_map_update_elem(fd: c_int, key: ?*const anyopaque, value: ?*const anyopaque, flags: __u64) c_int;
pub extern fn bpf_map_lookup_elem(fd: c_int, key: ?*const anyopaque, value: ?*anyopaque) c_int;
pub extern fn bpf_map_lookup_elem_flags(fd: c_int, key: ?*const anyopaque, value: ?*anyopaque, flags: __u64) c_int;
pub extern fn bpf_map_lookup_and_delete_elem(fd: c_int, key: ?*const anyopaque, value: ?*anyopaque) c_int;
pub extern fn bpf_map_lookup_and_delete_elem_flags(fd: c_int, key: ?*const anyopaque, value: ?*anyopaque, flags: __u64) c_int;
pub extern fn bpf_map_delete_elem(fd: c_int, key: ?*const anyopaque) c_int;
pub extern fn bpf_map_delete_elem_flags(fd: c_int, key: ?*const anyopaque, flags: __u64) c_int;
pub extern fn bpf_map_get_next_key(fd: c_int, key: ?*const anyopaque, next_key: ?*anyopaque) c_int;
pub extern fn bpf_map_freeze(fd: c_int) c_int;
pub const struct_bpf_map_batch_opts = extern struct {
    sz: usize = 0,
    elem_flags: __u64 = 0,
    flags: __u64 = 0,
};
pub extern fn bpf_map_delete_batch(fd: c_int, keys: ?*const anyopaque, count: [*c]__u32, opts: [*c]const struct_bpf_map_batch_opts) c_int;
pub extern fn bpf_map_lookup_batch(fd: c_int, in_batch: ?*anyopaque, out_batch: ?*anyopaque, keys: ?*anyopaque, values: ?*anyopaque, count: [*c]__u32, opts: [*c]const struct_bpf_map_batch_opts) c_int;
pub extern fn bpf_map_lookup_and_delete_batch(fd: c_int, in_batch: ?*anyopaque, out_batch: ?*anyopaque, keys: ?*anyopaque, values: ?*anyopaque, count: [*c]__u32, opts: [*c]const struct_bpf_map_batch_opts) c_int;
pub extern fn bpf_map_update_batch(fd: c_int, keys: ?*const anyopaque, values: ?*const anyopaque, count: [*c]__u32, opts: [*c]const struct_bpf_map_batch_opts) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_obj_pin_opts = opaque {};
pub extern fn bpf_obj_pin(fd: c_int, pathname: [*c]const u8) c_int;
pub extern fn bpf_obj_pin_opts(fd: c_int, pathname: [*c]const u8, opts: ?*const struct_bpf_obj_pin_opts) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_obj_get_opts = opaque {};
pub extern fn bpf_obj_get(pathname: [*c]const u8) c_int;
pub extern fn bpf_obj_get_opts(pathname: [*c]const u8, opts: ?*const struct_bpf_obj_get_opts) c_int;
pub extern fn bpf_prog_attach(prog_fd: c_int, attachable_fd: c_int, @"type": enum_bpf_attach_type, flags: c_uint) c_int;
pub extern fn bpf_prog_detach(attachable_fd: c_int, @"type": enum_bpf_attach_type) c_int;
pub extern fn bpf_prog_detach2(prog_fd: c_int, attachable_fd: c_int, @"type": enum_bpf_attach_type) c_int;
const union_unnamed_155 = extern union {
    replace_prog_fd: c_int,
    replace_fd: c_int,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_prog_attach_opts = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_prog_detach_opts = opaque {};
pub extern fn bpf_prog_attach_opts(prog_fd: c_int, target: c_int, @"type": enum_bpf_attach_type, opts: ?*const struct_bpf_prog_attach_opts) c_int;
pub extern fn bpf_prog_detach_opts(prog_fd: c_int, target: c_int, @"type": enum_bpf_attach_type, opts: ?*const struct_bpf_prog_detach_opts) c_int;
const struct_unnamed_157 = extern struct {
    bpf_cookie: __u64 = 0,
};
const struct_unnamed_158 = extern struct {
    flags: __u32 = 0,
    cnt: __u32 = 0,
    syms: [*c][*c]const u8 = null,
    addrs: [*c]const c_ulong = null,
    cookies: [*c]const __u64 = null,
};
const struct_unnamed_159 = extern struct {
    flags: __u32 = 0,
    cnt: __u32 = 0,
    path: [*c]const u8 = null,
    offsets: [*c]const c_ulong = null,
    ref_ctr_offsets: [*c]const c_ulong = null,
    cookies: [*c]const __u64 = null,
    pid: __u32 = 0,
};
const struct_unnamed_160 = extern struct {
    cookie: __u64 = 0,
};
const struct_unnamed_161 = extern struct {
    pf: __u32 = 0,
    hooknum: __u32 = 0,
    priority: __s32 = 0,
    flags: __u32 = 0,
};
const struct_unnamed_162 = extern struct {
    relative_fd: __u32 = 0,
    relative_id: __u32 = 0,
    expected_revision: __u64 = 0,
};
const struct_unnamed_163 = extern struct {
    relative_fd: __u32 = 0,
    relative_id: __u32 = 0,
    expected_revision: __u64 = 0,
};
const union_unnamed_156 = extern union {
    perf_event: struct_unnamed_157,
    kprobe_multi: struct_unnamed_158,
    uprobe_multi: struct_unnamed_159,
    tracing: struct_unnamed_160,
    netfilter: struct_unnamed_161,
    tcx: struct_unnamed_162,
    netkit: struct_unnamed_163,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_link_create_opts = opaque {};
pub extern fn bpf_link_create(prog_fd: c_int, target_fd: c_int, attach_type: enum_bpf_attach_type, opts: ?*const struct_bpf_link_create_opts) c_int;
pub extern fn bpf_link_detach(link_fd: c_int) c_int;
pub const struct_bpf_link_update_opts = extern struct {
    sz: usize = 0,
    flags: __u32 = 0,
    old_prog_fd: __u32 = 0,
    old_map_fd: __u32 = 0,
};
pub extern fn bpf_link_update(link_fd: c_int, new_prog_fd: c_int, opts: [*c]const struct_bpf_link_update_opts) c_int;
pub extern fn bpf_iter_create(link_fd: c_int) c_int;
pub const struct_bpf_prog_test_run_attr = extern struct {
    prog_fd: c_int = 0,
    repeat: c_int = 0,
    data_in: ?*const anyopaque = null,
    data_size_in: __u32 = 0,
    data_out: ?*anyopaque = null,
    data_size_out: __u32 = 0,
    retval: __u32 = 0,
    duration: __u32 = 0,
    ctx_in: ?*const anyopaque = null,
    ctx_size_in: __u32 = 0,
    ctx_out: ?*anyopaque = null,
    ctx_size_out: __u32 = 0,
};
pub extern fn bpf_prog_get_next_id(start_id: __u32, next_id: [*c]__u32) c_int;
pub extern fn bpf_map_get_next_id(start_id: __u32, next_id: [*c]__u32) c_int;
pub extern fn bpf_btf_get_next_id(start_id: __u32, next_id: [*c]__u32) c_int;
pub extern fn bpf_link_get_next_id(start_id: __u32, next_id: [*c]__u32) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_get_fd_by_id_opts = opaque {};
pub extern fn bpf_prog_get_fd_by_id(id: __u32) c_int;
pub extern fn bpf_prog_get_fd_by_id_opts(id: __u32, opts: ?*const struct_bpf_get_fd_by_id_opts) c_int;
pub extern fn bpf_map_get_fd_by_id(id: __u32) c_int;
pub extern fn bpf_map_get_fd_by_id_opts(id: __u32, opts: ?*const struct_bpf_get_fd_by_id_opts) c_int;
pub extern fn bpf_btf_get_fd_by_id(id: __u32) c_int;
pub extern fn bpf_btf_get_fd_by_id_opts(id: __u32, opts: ?*const struct_bpf_get_fd_by_id_opts) c_int;
pub extern fn bpf_link_get_fd_by_id(id: __u32) c_int;
pub extern fn bpf_link_get_fd_by_id_opts(id: __u32, opts: ?*const struct_bpf_get_fd_by_id_opts) c_int;
pub extern fn bpf_obj_get_info_by_fd(bpf_fd: c_int, info: ?*anyopaque, info_len: [*c]__u32) c_int;
pub extern fn bpf_prog_get_info_by_fd(prog_fd: c_int, info: ?*struct_bpf_prog_info, info_len: [*c]__u32) c_int;
pub extern fn bpf_map_get_info_by_fd(map_fd: c_int, info: [*c]struct_bpf_map_info, info_len: [*c]__u32) c_int;
pub extern fn bpf_btf_get_info_by_fd(btf_fd: c_int, info: [*c]struct_bpf_btf_info, info_len: [*c]__u32) c_int;
pub extern fn bpf_link_get_info_by_fd(link_fd: c_int, info: [*c]struct_bpf_link_info, info_len: [*c]__u32) c_int;
const union_unnamed_164 = extern union {
    prog_cnt: __u32,
    count: __u32,
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_prog_query_opts = opaque {};
pub extern fn bpf_prog_query_opts(target: c_int, @"type": enum_bpf_attach_type, opts: ?*struct_bpf_prog_query_opts) c_int;
pub extern fn bpf_prog_query(target_fd: c_int, @"type": enum_bpf_attach_type, query_flags: __u32, attach_flags: [*c]__u32, prog_ids: [*c]__u32, prog_cnt: [*c]__u32) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_raw_tp_opts = opaque {};
pub extern fn bpf_raw_tracepoint_open_opts(prog_fd: c_int, opts: ?*struct_bpf_raw_tp_opts) c_int;
pub extern fn bpf_raw_tracepoint_open(name: [*c]const u8, prog_fd: c_int) c_int;
pub extern fn bpf_task_fd_query(pid: c_int, fd: c_int, flags: __u32, buf: [*c]u8, buf_len: [*c]__u32, prog_id: [*c]__u32, fd_type: [*c]__u32, probe_offset: [*c]__u64, probe_addr: [*c]__u64) c_int;
pub extern fn bpf_enable_stats(@"type": enum_bpf_stats_type) c_int;
pub const struct_bpf_prog_bind_opts = extern struct {
    sz: usize = 0,
    flags: __u32 = 0,
};
pub extern fn bpf_prog_bind_map(prog_fd: c_int, map_fd: c_int, opts: [*c]const struct_bpf_prog_bind_opts) c_int;
pub const struct_bpf_test_run_opts = extern struct {
    sz: usize = 0,
    data_in: ?*const anyopaque = null,
    data_out: ?*anyopaque = null,
    data_size_in: __u32 = 0,
    data_size_out: __u32 = 0,
    ctx_in: ?*const anyopaque = null,
    ctx_out: ?*anyopaque = null,
    ctx_size_in: __u32 = 0,
    ctx_size_out: __u32 = 0,
    retval: __u32 = 0,
    repeat: c_int = 0,
    duration: __u32 = 0,
    flags: __u32 = 0,
    cpu: __u32 = 0,
    batch_size: __u32 = 0,
};
pub extern fn bpf_prog_test_run_opts(prog_fd: c_int, opts: [*c]struct_bpf_test_run_opts) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_token_create_opts = opaque {};
pub extern fn bpf_token_create(bpffs_fd: c_int, opts: ?*struct_bpf_token_create_opts) c_int;
pub const struct___va_list_tag_165 = extern struct {
    unnamed_0: c_uint = 0,
    unnamed_1: c_uint = 0,
    unnamed_2: ?*anyopaque = null,
    unnamed_3: ?*anyopaque = null,
};
pub const __builtin_va_list = [1]struct___va_list_tag_165;
pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
const union_unnamed_166 = extern union {
    __wch: c_uint,
    __wchb: [4]u8,
};
pub const __mbstate_t = extern struct {
    __count: c_int = 0,
    __value: union_unnamed_166 = @import("std").mem.zeroes(union_unnamed_166),
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
pub extern fn vfprintf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn vprintf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn vsprintf(noalias __s: [*c]u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn snprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vsnprintf(noalias __s: [*c]u8, __maxlen: usize, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn vasprintf(noalias __ptr: [*c][*c]u8, noalias __f: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn __asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn asprintf(noalias __ptr: [*c][*c]u8, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn vdprintf(__fd: c_int, noalias __fmt: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn dprintf(__fd: c_int, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn fscanf(noalias __stream: ?*FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn scanf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfscanf(noalias __s: ?*FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn vscanf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
pub extern fn vsscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag_165) c_int;
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
pub const pid_t = __pid_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const clock_t = __clock_t;
pub const clockid_t = __clockid_t;
pub const time_t = __time_t;
pub const timer_t = __timer_t;
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
pub const struct_timespec = extern struct {
    tv_sec: __time_t = 0,
    tv_nsec: __syscall_slong_t = 0,
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
const struct_unnamed_167 = extern struct {
    __low: c_uint = 0,
    __high: c_uint = 0,
};
pub const __atomic_wide_counter = extern union {
    __value64: c_ulonglong,
    __value32: struct_unnamed_167,
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
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
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
pub extern fn libbpf_major_version() __u32;
pub extern fn libbpf_minor_version() __u32;
pub extern fn libbpf_version_string() [*c]const u8;
pub const __LIBBPF_ERRNO__START: c_int = 4000;
pub const LIBBPF_ERRNO__LIBELF: c_int = 4000;
pub const LIBBPF_ERRNO__FORMAT: c_int = 4001;
pub const LIBBPF_ERRNO__KVERSION: c_int = 4002;
pub const LIBBPF_ERRNO__ENDIAN: c_int = 4003;
pub const LIBBPF_ERRNO__INTERNAL: c_int = 4004;
pub const LIBBPF_ERRNO__RELOC: c_int = 4005;
pub const LIBBPF_ERRNO__LOAD: c_int = 4006;
pub const LIBBPF_ERRNO__VERIFY: c_int = 4007;
pub const LIBBPF_ERRNO__PROG2BIG: c_int = 4008;
pub const LIBBPF_ERRNO__KVER: c_int = 4009;
pub const LIBBPF_ERRNO__PROGTYPE: c_int = 4010;
pub const LIBBPF_ERRNO__WRNGPID: c_int = 4011;
pub const LIBBPF_ERRNO__INVSEQ: c_int = 4012;
pub const LIBBPF_ERRNO__NLPARSE: c_int = 4013;
pub const __LIBBPF_ERRNO__END: c_int = 4014;
pub const enum_libbpf_errno = c_uint;
pub extern fn libbpf_strerror(err: c_int, buf: [*c]u8, size: usize) c_int;
pub extern fn libbpf_bpf_attach_type_str(t: enum_bpf_attach_type) [*c]const u8;
pub extern fn libbpf_bpf_link_type_str(t: enum_bpf_link_type) [*c]const u8;
pub extern fn libbpf_bpf_map_type_str(t: enum_bpf_map_type) [*c]const u8;
pub extern fn libbpf_bpf_prog_type_str(t: enum_bpf_prog_type) [*c]const u8;
pub const LIBBPF_WARN: c_int = 0;
pub const LIBBPF_INFO: c_int = 1;
pub const LIBBPF_DEBUG: c_int = 2;
pub const enum_libbpf_print_level = c_uint;
pub const libbpf_print_fn_t = ?*const fn (level: enum_libbpf_print_level, [*c]const u8, ap: [*c]struct___va_list_tag_165) callconv(.c) c_int;
pub extern fn libbpf_set_print(@"fn": libbpf_print_fn_t) libbpf_print_fn_t; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_object_open_opts = opaque {};
pub const struct_bpf_object = opaque {
    pub const bpf_object__load = __root.bpf_object__load;
    pub const bpf_object__close = __root.bpf_object__close;
    pub const bpf_object__pin_maps = __root.bpf_object__pin_maps;
    pub const bpf_object__unpin_maps = __root.bpf_object__unpin_maps;
    pub const bpf_object__pin_programs = __root.bpf_object__pin_programs;
    pub const bpf_object__unpin_programs = __root.bpf_object__unpin_programs;
    pub const bpf_object__pin = __root.bpf_object__pin;
    pub const bpf_object__unpin = __root.bpf_object__unpin;
    pub const bpf_object__set_kversion = __root.bpf_object__set_kversion;
    pub const bpf_object__gen_loader = __root.bpf_object__gen_loader;
    pub const load = __root.bpf_object__load;
    pub const close = __root.bpf_object__close;
    pub const maps = __root.bpf_object__pin_maps;
    pub const programs = __root.bpf_object__pin_programs;
    pub const pin = __root.bpf_object__pin;
    pub const unpin = __root.bpf_object__unpin;
    pub const kversion = __root.bpf_object__set_kversion;
    pub const loader = __root.bpf_object__gen_loader;
};
pub extern fn bpf_object__open(path: [*c]const u8) ?*struct_bpf_object;
pub extern fn bpf_object__open_file(path: [*c]const u8, opts: ?*const struct_bpf_object_open_opts) ?*struct_bpf_object;
pub extern fn bpf_object__open_mem(obj_buf: ?*const anyopaque, obj_buf_sz: usize, opts: ?*const struct_bpf_object_open_opts) ?*struct_bpf_object;
pub extern fn bpf_object__load(obj: ?*struct_bpf_object) c_int;
pub extern fn bpf_object__close(obj: ?*struct_bpf_object) void;
pub extern fn bpf_object__pin_maps(obj: ?*struct_bpf_object, path: [*c]const u8) c_int;
pub extern fn bpf_object__unpin_maps(obj: ?*struct_bpf_object, path: [*c]const u8) c_int;
pub extern fn bpf_object__pin_programs(obj: ?*struct_bpf_object, path: [*c]const u8) c_int;
pub extern fn bpf_object__unpin_programs(obj: ?*struct_bpf_object, path: [*c]const u8) c_int;
pub extern fn bpf_object__pin(object: ?*struct_bpf_object, path: [*c]const u8) c_int;
pub extern fn bpf_object__unpin(object: ?*struct_bpf_object, path: [*c]const u8) c_int;
pub extern fn bpf_object__name(obj: ?*const struct_bpf_object) [*c]const u8;
pub extern fn bpf_object__kversion(obj: ?*const struct_bpf_object) c_uint;
pub extern fn bpf_object__set_kversion(obj: ?*struct_bpf_object, kern_version: __u32) c_int;
pub extern fn bpf_object__token_fd(obj: ?*const struct_bpf_object) c_int;
pub extern fn bpf_object__btf(obj: ?*const struct_bpf_object) ?*struct_btf;
pub extern fn bpf_object__btf_fd(obj: ?*const struct_bpf_object) c_int;
pub extern fn bpf_object__find_program_by_name(obj: ?*const struct_bpf_object, name: [*c]const u8) ?*struct_bpf_program;
pub extern fn libbpf_prog_type_by_name(name: [*c]const u8, prog_type: [*c]enum_bpf_prog_type, expected_attach_type: [*c]enum_bpf_attach_type) c_int;
pub extern fn libbpf_attach_type_by_name(name: [*c]const u8, attach_type: [*c]enum_bpf_attach_type) c_int;
pub extern fn libbpf_find_vmlinux_btf_id(name: [*c]const u8, attach_type: enum_bpf_attach_type) c_int;
pub extern fn bpf_object__next_program(obj: ?*const struct_bpf_object, prog: ?*struct_bpf_program) ?*struct_bpf_program;
pub extern fn bpf_object__prev_program(obj: ?*const struct_bpf_object, prog: ?*struct_bpf_program) ?*struct_bpf_program;
pub extern fn bpf_program__set_ifindex(prog: ?*struct_bpf_program, ifindex: __u32) void;
pub extern fn bpf_program__name(prog: ?*const struct_bpf_program) [*c]const u8;
pub extern fn bpf_program__section_name(prog: ?*const struct_bpf_program) [*c]const u8;
pub extern fn bpf_program__autoload(prog: ?*const struct_bpf_program) bool;
pub extern fn bpf_program__set_autoload(prog: ?*struct_bpf_program, autoload: bool) c_int;
pub extern fn bpf_program__autoattach(prog: ?*const struct_bpf_program) bool;
pub extern fn bpf_program__set_autoattach(prog: ?*struct_bpf_program, autoattach: bool) void;
pub extern fn bpf_program__insns(prog: ?*const struct_bpf_program) ?*const struct_bpf_insn;
pub extern fn bpf_program__set_insns(prog: ?*struct_bpf_program, new_insns: ?*struct_bpf_insn, new_insn_cnt: usize) c_int;
pub extern fn bpf_program__insn_cnt(prog: ?*const struct_bpf_program) usize;
pub extern fn bpf_program__fd(prog: ?*const struct_bpf_program) c_int;
pub extern fn bpf_program__pin(prog: ?*struct_bpf_program, path: [*c]const u8) c_int;
pub extern fn bpf_program__unpin(prog: ?*struct_bpf_program, path: [*c]const u8) c_int;
pub extern fn bpf_program__unload(prog: ?*struct_bpf_program) void;
pub const struct_bpf_link = opaque {
    pub const bpf_link__pin = __root.bpf_link__pin;
    pub const bpf_link__unpin = __root.bpf_link__unpin;
    pub const bpf_link__update_program = __root.bpf_link__update_program;
    pub const bpf_link__disconnect = __root.bpf_link__disconnect;
    pub const bpf_link__detach = __root.bpf_link__detach;
    pub const bpf_link__destroy = __root.bpf_link__destroy;
    pub const bpf_link__update_map = __root.bpf_link__update_map;
    pub const pin = __root.bpf_link__pin;
    pub const unpin = __root.bpf_link__unpin;
    pub const program = __root.bpf_link__update_program;
    pub const disconnect = __root.bpf_link__disconnect;
    pub const detach = __root.bpf_link__detach;
    pub const destroy = __root.bpf_link__destroy;
    pub const map = __root.bpf_link__update_map;
};
pub extern fn bpf_link__open(path: [*c]const u8) ?*struct_bpf_link;
pub extern fn bpf_link__fd(link: ?*const struct_bpf_link) c_int;
pub extern fn bpf_link__pin_path(link: ?*const struct_bpf_link) [*c]const u8;
pub extern fn bpf_link__pin(link: ?*struct_bpf_link, path: [*c]const u8) c_int;
pub extern fn bpf_link__unpin(link: ?*struct_bpf_link) c_int;
pub extern fn bpf_link__update_program(link: ?*struct_bpf_link, prog: ?*struct_bpf_program) c_int;
pub extern fn bpf_link__disconnect(link: ?*struct_bpf_link) void;
pub extern fn bpf_link__detach(link: ?*struct_bpf_link) c_int;
pub extern fn bpf_link__destroy(link: ?*struct_bpf_link) c_int;
pub extern fn bpf_program__attach(prog: ?*const struct_bpf_program) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_perf_event_opts = opaque {};
pub extern fn bpf_program__attach_perf_event(prog: ?*const struct_bpf_program, pfd: c_int) ?*struct_bpf_link;
pub extern fn bpf_program__attach_perf_event_opts(prog: ?*const struct_bpf_program, pfd: c_int, opts: ?*const struct_bpf_perf_event_opts) ?*struct_bpf_link;
pub const PROBE_ATTACH_MODE_DEFAULT: c_int = 0;
pub const PROBE_ATTACH_MODE_LEGACY: c_int = 1;
pub const PROBE_ATTACH_MODE_PERF: c_int = 2;
pub const PROBE_ATTACH_MODE_LINK: c_int = 3;
pub const enum_probe_attach_mode = c_uint; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_kprobe_opts = opaque {};
pub extern fn bpf_program__attach_kprobe(prog: ?*const struct_bpf_program, retprobe: bool, func_name: [*c]const u8) ?*struct_bpf_link;
pub extern fn bpf_program__attach_kprobe_opts(prog: ?*const struct_bpf_program, func_name: [*c]const u8, opts: ?*const struct_bpf_kprobe_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_kprobe_multi_opts = opaque {};
pub extern fn bpf_program__attach_kprobe_multi_opts(prog: ?*const struct_bpf_program, pattern: [*c]const u8, opts: ?*const struct_bpf_kprobe_multi_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_uprobe_multi_opts = opaque {};
pub extern fn bpf_program__attach_uprobe_multi(prog: ?*const struct_bpf_program, pid: pid_t, binary_path: [*c]const u8, func_pattern: [*c]const u8, opts: ?*const struct_bpf_uprobe_multi_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_ksyscall_opts = opaque {};
pub extern fn bpf_program__attach_ksyscall(prog: ?*const struct_bpf_program, syscall_name: [*c]const u8, opts: ?*const struct_bpf_ksyscall_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_uprobe_opts = opaque {};
pub extern fn bpf_program__attach_uprobe(prog: ?*const struct_bpf_program, retprobe: bool, pid: pid_t, binary_path: [*c]const u8, func_offset: usize) ?*struct_bpf_link;
pub extern fn bpf_program__attach_uprobe_opts(prog: ?*const struct_bpf_program, pid: pid_t, binary_path: [*c]const u8, func_offset: usize, opts: ?*const struct_bpf_uprobe_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_usdt_opts = opaque {};
pub extern fn bpf_program__attach_usdt(prog: ?*const struct_bpf_program, pid: pid_t, binary_path: [*c]const u8, usdt_provider: [*c]const u8, usdt_name: [*c]const u8, opts: ?*const struct_bpf_usdt_opts) ?*struct_bpf_link;
pub const struct_bpf_tracepoint_opts = extern struct {
    sz: usize = 0,
    bpf_cookie: __u64 = 0,
};
pub extern fn bpf_program__attach_tracepoint(prog: ?*const struct_bpf_program, tp_category: [*c]const u8, tp_name: [*c]const u8) ?*struct_bpf_link;
pub extern fn bpf_program__attach_tracepoint_opts(prog: ?*const struct_bpf_program, tp_category: [*c]const u8, tp_name: [*c]const u8, opts: [*c]const struct_bpf_tracepoint_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_raw_tracepoint_opts = opaque {};
pub extern fn bpf_program__attach_raw_tracepoint(prog: ?*const struct_bpf_program, tp_name: [*c]const u8) ?*struct_bpf_link;
pub extern fn bpf_program__attach_raw_tracepoint_opts(prog: ?*const struct_bpf_program, tp_name: [*c]const u8, opts: ?*struct_bpf_raw_tracepoint_opts) ?*struct_bpf_link;
pub const struct_bpf_trace_opts = extern struct {
    sz: usize = 0,
    cookie: __u64 = 0,
};
pub extern fn bpf_program__attach_trace(prog: ?*const struct_bpf_program) ?*struct_bpf_link;
pub extern fn bpf_program__attach_trace_opts(prog: ?*const struct_bpf_program, opts: [*c]const struct_bpf_trace_opts) ?*struct_bpf_link;
pub extern fn bpf_program__attach_lsm(prog: ?*const struct_bpf_program) ?*struct_bpf_link;
pub extern fn bpf_program__attach_cgroup(prog: ?*const struct_bpf_program, cgroup_fd: c_int) ?*struct_bpf_link;
pub extern fn bpf_program__attach_netns(prog: ?*const struct_bpf_program, netns_fd: c_int) ?*struct_bpf_link;
pub extern fn bpf_program__attach_sockmap(prog: ?*const struct_bpf_program, map_fd: c_int) ?*struct_bpf_link;
pub extern fn bpf_program__attach_xdp(prog: ?*const struct_bpf_program, ifindex: c_int) ?*struct_bpf_link;
pub extern fn bpf_program__attach_freplace(prog: ?*const struct_bpf_program, target_fd: c_int, attach_func_name: [*c]const u8) ?*struct_bpf_link;
pub const struct_bpf_netfilter_opts = extern struct {
    sz: usize = 0,
    pf: __u32 = 0,
    hooknum: __u32 = 0,
    priority: __s32 = 0,
    flags: __u32 = 0,
};
pub extern fn bpf_program__attach_netfilter(prog: ?*const struct_bpf_program, opts: [*c]const struct_bpf_netfilter_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_tcx_opts = opaque {};
pub extern fn bpf_program__attach_tcx(prog: ?*const struct_bpf_program, ifindex: c_int, opts: ?*const struct_bpf_tcx_opts) ?*struct_bpf_link; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_netkit_opts = opaque {};
pub extern fn bpf_program__attach_netkit(prog: ?*const struct_bpf_program, ifindex: c_int, opts: ?*const struct_bpf_netkit_opts) ?*struct_bpf_link;
pub extern fn bpf_map__attach_struct_ops(map: ?*const struct_bpf_map) ?*struct_bpf_link;
pub extern fn bpf_link__update_map(link: ?*struct_bpf_link, map: ?*const struct_bpf_map) c_int;
pub const struct_bpf_iter_attach_opts = extern struct {
    sz: usize = 0,
    link_info: [*c]union_bpf_iter_link_info = null,
    link_info_len: __u32 = 0,
};
pub extern fn bpf_program__attach_iter(prog: ?*const struct_bpf_program, opts: [*c]const struct_bpf_iter_attach_opts) ?*struct_bpf_link;
pub extern fn bpf_program__type(prog: ?*const struct_bpf_program) enum_bpf_prog_type;
pub extern fn bpf_program__set_type(prog: ?*struct_bpf_program, @"type": enum_bpf_prog_type) c_int;
pub extern fn bpf_program__expected_attach_type(prog: ?*const struct_bpf_program) enum_bpf_attach_type;
pub extern fn bpf_program__set_expected_attach_type(prog: ?*struct_bpf_program, @"type": enum_bpf_attach_type) c_int;
pub extern fn bpf_program__flags(prog: ?*const struct_bpf_program) __u32;
pub extern fn bpf_program__set_flags(prog: ?*struct_bpf_program, flags: __u32) c_int;
pub extern fn bpf_program__log_level(prog: ?*const struct_bpf_program) __u32;
pub extern fn bpf_program__set_log_level(prog: ?*struct_bpf_program, log_level: __u32) c_int;
pub extern fn bpf_program__log_buf(prog: ?*const struct_bpf_program, log_size: [*c]usize) [*c]const u8;
pub extern fn bpf_program__set_log_buf(prog: ?*struct_bpf_program, log_buf: [*c]u8, log_size: usize) c_int;
pub extern fn bpf_program__set_attach_target(prog: ?*struct_bpf_program, attach_prog_fd: c_int, attach_func_name: [*c]const u8) c_int;
pub extern fn bpf_object__find_map_by_name(obj: ?*const struct_bpf_object, name: [*c]const u8) ?*struct_bpf_map;
pub extern fn bpf_object__find_map_fd_by_name(obj: ?*const struct_bpf_object, name: [*c]const u8) c_int;
pub extern fn bpf_object__next_map(obj: ?*const struct_bpf_object, map: ?*const struct_bpf_map) ?*struct_bpf_map;
pub extern fn bpf_object__prev_map(obj: ?*const struct_bpf_object, map: ?*const struct_bpf_map) ?*struct_bpf_map;
pub extern fn bpf_map__set_autocreate(map: ?*struct_bpf_map, autocreate: bool) c_int;
pub extern fn bpf_map__autocreate(map: ?*const struct_bpf_map) bool;
pub extern fn bpf_map__set_autoattach(map: ?*struct_bpf_map, autoattach: bool) c_int;
pub extern fn bpf_map__autoattach(map: ?*const struct_bpf_map) bool;
pub extern fn bpf_map__fd(map: ?*const struct_bpf_map) c_int;
pub extern fn bpf_map__reuse_fd(map: ?*struct_bpf_map, fd: c_int) c_int;
pub extern fn bpf_map__name(map: ?*const struct_bpf_map) [*c]const u8;
pub extern fn bpf_map__type(map: ?*const struct_bpf_map) enum_bpf_map_type;
pub extern fn bpf_map__set_type(map: ?*struct_bpf_map, @"type": enum_bpf_map_type) c_int;
pub extern fn bpf_map__max_entries(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__set_max_entries(map: ?*struct_bpf_map, max_entries: __u32) c_int;
pub extern fn bpf_map__map_flags(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__set_map_flags(map: ?*struct_bpf_map, flags: __u32) c_int;
pub extern fn bpf_map__numa_node(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__set_numa_node(map: ?*struct_bpf_map, numa_node: __u32) c_int;
pub extern fn bpf_map__key_size(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__set_key_size(map: ?*struct_bpf_map, size: __u32) c_int;
pub extern fn bpf_map__value_size(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__set_value_size(map: ?*struct_bpf_map, size: __u32) c_int;
pub extern fn bpf_map__btf_key_type_id(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__btf_value_type_id(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__ifindex(map: ?*const struct_bpf_map) __u32;
pub extern fn bpf_map__set_ifindex(map: ?*struct_bpf_map, ifindex: __u32) c_int;
pub extern fn bpf_map__map_extra(map: ?*const struct_bpf_map) __u64;
pub extern fn bpf_map__set_map_extra(map: ?*struct_bpf_map, map_extra: __u64) c_int;
pub extern fn bpf_map__set_initial_value(map: ?*struct_bpf_map, data: ?*const anyopaque, size: usize) c_int;
pub extern fn bpf_map__initial_value(map: ?*const struct_bpf_map, psize: [*c]usize) ?*anyopaque;
pub extern fn bpf_map__is_internal(map: ?*const struct_bpf_map) bool;
pub extern fn bpf_map__set_pin_path(map: ?*struct_bpf_map, path: [*c]const u8) c_int;
pub extern fn bpf_map__pin_path(map: ?*const struct_bpf_map) [*c]const u8;
pub extern fn bpf_map__is_pinned(map: ?*const struct_bpf_map) bool;
pub extern fn bpf_map__pin(map: ?*struct_bpf_map, path: [*c]const u8) c_int;
pub extern fn bpf_map__unpin(map: ?*struct_bpf_map, path: [*c]const u8) c_int;
pub extern fn bpf_map__set_inner_map_fd(map: ?*struct_bpf_map, fd: c_int) c_int;
pub extern fn bpf_map__inner_map(map: ?*struct_bpf_map) ?*struct_bpf_map;
pub extern fn bpf_map__lookup_elem(map: ?*const struct_bpf_map, key: ?*const anyopaque, key_sz: usize, value: ?*anyopaque, value_sz: usize, flags: __u64) c_int;
pub extern fn bpf_map__update_elem(map: ?*const struct_bpf_map, key: ?*const anyopaque, key_sz: usize, value: ?*const anyopaque, value_sz: usize, flags: __u64) c_int;
pub extern fn bpf_map__delete_elem(map: ?*const struct_bpf_map, key: ?*const anyopaque, key_sz: usize, flags: __u64) c_int;
pub extern fn bpf_map__lookup_and_delete_elem(map: ?*const struct_bpf_map, key: ?*const anyopaque, key_sz: usize, value: ?*anyopaque, value_sz: usize, flags: __u64) c_int;
pub extern fn bpf_map__get_next_key(map: ?*const struct_bpf_map, cur_key: ?*const anyopaque, next_key: ?*anyopaque, key_sz: usize) c_int; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_xdp_set_link_opts = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_xdp_attach_opts = opaque {}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_xdp_query_opts = opaque {};
pub extern fn bpf_xdp_attach(ifindex: c_int, prog_fd: c_int, flags: __u32, opts: ?*const struct_bpf_xdp_attach_opts) c_int;
pub extern fn bpf_xdp_detach(ifindex: c_int, flags: __u32, opts: ?*const struct_bpf_xdp_attach_opts) c_int;
pub extern fn bpf_xdp_query(ifindex: c_int, flags: c_int, opts: ?*struct_bpf_xdp_query_opts) c_int;
pub extern fn bpf_xdp_query_id(ifindex: c_int, flags: c_int, prog_id: [*c]__u32) c_int;
pub const BPF_TC_INGRESS: c_int = 1;
pub const BPF_TC_EGRESS: c_int = 2;
pub const BPF_TC_CUSTOM: c_int = 4;
pub const enum_bpf_tc_attach_point = c_uint;
pub const BPF_TC_F_REPLACE: c_int = 1;
pub const enum_bpf_tc_flags = c_uint; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_tc_hook = opaque {
    pub const bpf_tc_hook_create = __root.bpf_tc_hook_create;
    pub const bpf_tc_hook_destroy = __root.bpf_tc_hook_destroy;
    pub const create = __root.bpf_tc_hook_create;
    pub const destroy = __root.bpf_tc_hook_destroy;
}; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_bpf_tc_opts = opaque {};
pub extern fn bpf_tc_hook_create(hook: ?*struct_bpf_tc_hook) c_int;
pub extern fn bpf_tc_hook_destroy(hook: ?*struct_bpf_tc_hook) c_int;
pub extern fn bpf_tc_attach(hook: ?*const struct_bpf_tc_hook, opts: ?*struct_bpf_tc_opts) c_int;
pub extern fn bpf_tc_detach(hook: ?*const struct_bpf_tc_hook, opts: ?*const struct_bpf_tc_opts) c_int;
pub extern fn bpf_tc_query(hook: ?*const struct_bpf_tc_hook, opts: ?*struct_bpf_tc_opts) c_int;
pub const ring_buffer_sample_fn = ?*const fn (ctx: ?*anyopaque, data: ?*anyopaque, size: usize) callconv(.c) c_int;
pub const struct_ring_buffer_opts = extern struct {
    sz: usize = 0,
};
pub const struct_ring_buffer = opaque {
    pub const ring_buffer__free = __root.ring_buffer__free;
    pub const ring_buffer__add = __root.ring_buffer__add;
    pub const ring_buffer__poll = __root.ring_buffer__poll;
    pub const ring_buffer__consume = __root.ring_buffer__consume;
    pub const ring_buffer__consume_n = __root.ring_buffer__consume_n;
    pub const ring_buffer__ring = __root.ring_buffer__ring;
    pub const free = __root.ring_buffer__free;
    pub const add = __root.ring_buffer__add;
    pub const poll = __root.ring_buffer__poll;
    pub const consume = __root.ring_buffer__consume;
    pub const n = __root.ring_buffer__consume_n;
    pub const ring = __root.ring_buffer__ring;
};
pub extern fn ring_buffer__new(map_fd: c_int, sample_cb: ring_buffer_sample_fn, ctx: ?*anyopaque, opts: [*c]const struct_ring_buffer_opts) ?*struct_ring_buffer;
pub extern fn ring_buffer__free(rb: ?*struct_ring_buffer) void;
pub extern fn ring_buffer__add(rb: ?*struct_ring_buffer, map_fd: c_int, sample_cb: ring_buffer_sample_fn, ctx: ?*anyopaque) c_int;
pub extern fn ring_buffer__poll(rb: ?*struct_ring_buffer, timeout_ms: c_int) c_int;
pub extern fn ring_buffer__consume(rb: ?*struct_ring_buffer) c_int;
pub extern fn ring_buffer__consume_n(rb: ?*struct_ring_buffer, n: usize) c_int;
pub extern fn ring_buffer__epoll_fd(rb: ?*const struct_ring_buffer) c_int;
pub const struct_ring = opaque {
    pub const ring__consume = __root.ring__consume;
    pub const ring__consume_n = __root.ring__consume_n;
    pub const consume = __root.ring__consume;
    pub const n = __root.ring__consume_n;
};
pub extern fn ring_buffer__ring(rb: ?*struct_ring_buffer, idx: c_uint) ?*struct_ring;
pub extern fn ring__consumer_pos(r: ?*const struct_ring) c_ulong;
pub extern fn ring__producer_pos(r: ?*const struct_ring) c_ulong;
pub extern fn ring__avail_data_size(r: ?*const struct_ring) usize;
pub extern fn ring__size(r: ?*const struct_ring) usize;
pub extern fn ring__map_fd(r: ?*const struct_ring) c_int;
pub extern fn ring__consume(r: ?*struct_ring) c_int;
pub extern fn ring__consume_n(r: ?*struct_ring, n: usize) c_int;
pub const struct_user_ring_buffer_opts = extern struct {
    sz: usize = 0,
};
pub const struct_user_ring_buffer = opaque {
    pub const user_ring_buffer__reserve = __root.user_ring_buffer__reserve;
    pub const user_ring_buffer__reserve_blocking = __root.user_ring_buffer__reserve_blocking;
    pub const user_ring_buffer__submit = __root.user_ring_buffer__submit;
    pub const user_ring_buffer__discard = __root.user_ring_buffer__discard;
    pub const user_ring_buffer__free = __root.user_ring_buffer__free;
    pub const reserve = __root.user_ring_buffer__reserve;
    pub const blocking = __root.user_ring_buffer__reserve_blocking;
    pub const submit = __root.user_ring_buffer__submit;
    pub const discard = __root.user_ring_buffer__discard;
    pub const free = __root.user_ring_buffer__free;
};
pub extern fn user_ring_buffer__new(map_fd: c_int, opts: [*c]const struct_user_ring_buffer_opts) ?*struct_user_ring_buffer;
pub extern fn user_ring_buffer__reserve(rb: ?*struct_user_ring_buffer, size: __u32) ?*anyopaque;
pub extern fn user_ring_buffer__reserve_blocking(rb: ?*struct_user_ring_buffer, size: __u32, timeout_ms: c_int) ?*anyopaque;
pub extern fn user_ring_buffer__submit(rb: ?*struct_user_ring_buffer, sample: ?*anyopaque) void;
pub extern fn user_ring_buffer__discard(rb: ?*struct_user_ring_buffer, sample: ?*anyopaque) void;
pub extern fn user_ring_buffer__free(rb: ?*struct_user_ring_buffer) void;
pub const perf_buffer_sample_fn = ?*const fn (ctx: ?*anyopaque, cpu: c_int, data: ?*anyopaque, size: __u32) callconv(.c) void;
pub const perf_buffer_lost_fn = ?*const fn (ctx: ?*anyopaque, cpu: c_int, cnt: __u64) callconv(.c) void; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_perf_buffer_opts = opaque {};
pub const struct_perf_buffer = opaque {
    pub const perf_buffer__free = __root.perf_buffer__free;
    pub const perf_buffer__poll = __root.perf_buffer__poll;
    pub const perf_buffer__consume = __root.perf_buffer__consume;
    pub const perf_buffer__consume_buffer = __root.perf_buffer__consume_buffer;
    pub const perf_buffer__buffer = __root.perf_buffer__buffer;
    pub const free = __root.perf_buffer__free;
    pub const poll = __root.perf_buffer__poll;
    pub const consume = __root.perf_buffer__consume;
    pub const buffer = __root.perf_buffer__consume_buffer;
};
pub extern fn perf_buffer__new(map_fd: c_int, page_cnt: usize, sample_cb: perf_buffer_sample_fn, lost_cb: perf_buffer_lost_fn, ctx: ?*anyopaque, opts: ?*const struct_perf_buffer_opts) ?*struct_perf_buffer;
pub const LIBBPF_PERF_EVENT_DONE: c_int = 0;
pub const LIBBPF_PERF_EVENT_ERROR: c_int = -1;
pub const LIBBPF_PERF_EVENT_CONT: c_int = -2;
pub const enum_bpf_perf_event_ret = c_int;
pub const struct_perf_event_header = opaque {};
pub const perf_buffer_event_fn = ?*const fn (ctx: ?*anyopaque, cpu: c_int, event: ?*struct_perf_event_header) callconv(.c) enum_bpf_perf_event_ret; // /usr/include/asm-generic/int-ll64.h:20:1: warning: struct demoted to opaque type - has bitfield
pub const struct_perf_buffer_raw_opts = opaque {};
pub const struct_perf_event_attr = opaque {};
pub extern fn perf_buffer__new_raw(map_fd: c_int, page_cnt: usize, attr: ?*struct_perf_event_attr, event_cb: perf_buffer_event_fn, ctx: ?*anyopaque, opts: ?*const struct_perf_buffer_raw_opts) ?*struct_perf_buffer;
pub extern fn perf_buffer__free(pb: ?*struct_perf_buffer) void;
pub extern fn perf_buffer__epoll_fd(pb: ?*const struct_perf_buffer) c_int;
pub extern fn perf_buffer__poll(pb: ?*struct_perf_buffer, timeout_ms: c_int) c_int;
pub extern fn perf_buffer__consume(pb: ?*struct_perf_buffer) c_int;
pub extern fn perf_buffer__consume_buffer(pb: ?*struct_perf_buffer, buf_idx: usize) c_int;
pub extern fn perf_buffer__buffer_cnt(pb: ?*const struct_perf_buffer) usize;
pub extern fn perf_buffer__buffer_fd(pb: ?*const struct_perf_buffer, buf_idx: usize) c_int;
pub extern fn perf_buffer__buffer(pb: ?*struct_perf_buffer, buf_idx: c_int, buf: [*c]?*anyopaque, buf_size: [*c]usize) c_int;
pub const struct_bpf_prog_linfo = opaque {
    pub const bpf_prog_linfo__free = __root.bpf_prog_linfo__free;
    pub const free = __root.bpf_prog_linfo__free;
};
pub extern fn bpf_prog_linfo__free(prog_linfo: ?*struct_bpf_prog_linfo) void;
pub extern fn bpf_prog_linfo__new(info: ?*const struct_bpf_prog_info) ?*struct_bpf_prog_linfo;
pub extern fn bpf_prog_linfo__lfind_addr_func(prog_linfo: ?*const struct_bpf_prog_linfo, addr: __u64, func_idx: __u32, nr_skip: __u32) [*c]const struct_bpf_line_info;
pub extern fn bpf_prog_linfo__lfind(prog_linfo: ?*const struct_bpf_prog_linfo, insn_off: __u32, nr_skip: __u32) [*c]const struct_bpf_line_info;
pub extern fn libbpf_probe_bpf_prog_type(prog_type: enum_bpf_prog_type, opts: ?*const anyopaque) c_int;
pub extern fn libbpf_probe_bpf_map_type(map_type: enum_bpf_map_type, opts: ?*const anyopaque) c_int;
pub extern fn libbpf_probe_bpf_helper(prog_type: enum_bpf_prog_type, helper_id: enum_bpf_func_id, opts: ?*const anyopaque) c_int;
pub extern fn libbpf_num_possible_cpus() c_int;
pub const struct_bpf_map_skeleton = extern struct {
    name: [*c]const u8 = null,
    map: [*c]?*struct_bpf_map = null,
    mmaped: [*c]?*anyopaque = null,
    link: [*c]?*struct_bpf_link = null,
};
pub const struct_bpf_prog_skeleton = extern struct {
    name: [*c]const u8 = null,
    prog: [*c]?*struct_bpf_program = null,
    link: [*c]?*struct_bpf_link = null,
};
pub const struct_bpf_object_skeleton = extern struct {
    sz: usize = 0,
    name: [*c]const u8 = null,
    data: ?*const anyopaque = null,
    data_sz: usize = 0,
    obj: [*c]?*struct_bpf_object = null,
    map_cnt: c_int = 0,
    map_skel_sz: c_int = 0,
    maps: [*c]struct_bpf_map_skeleton = null,
    prog_cnt: c_int = 0,
    prog_skel_sz: c_int = 0,
    progs: [*c]struct_bpf_prog_skeleton = null,
    pub const bpf_object__open_skeleton = __root.bpf_object__open_skeleton;
    pub const bpf_object__load_skeleton = __root.bpf_object__load_skeleton;
    pub const bpf_object__attach_skeleton = __root.bpf_object__attach_skeleton;
    pub const bpf_object__detach_skeleton = __root.bpf_object__detach_skeleton;
    pub const bpf_object__destroy_skeleton = __root.bpf_object__destroy_skeleton;
    pub const skeleton = __root.bpf_object__open_skeleton;
};
pub extern fn bpf_object__open_skeleton(s: [*c]struct_bpf_object_skeleton, opts: ?*const struct_bpf_object_open_opts) c_int;
pub extern fn bpf_object__load_skeleton(s: [*c]struct_bpf_object_skeleton) c_int;
pub extern fn bpf_object__attach_skeleton(s: [*c]struct_bpf_object_skeleton) c_int;
pub extern fn bpf_object__detach_skeleton(s: [*c]struct_bpf_object_skeleton) void;
pub extern fn bpf_object__destroy_skeleton(s: [*c]struct_bpf_object_skeleton) void;
pub const struct_bpf_var_skeleton = extern struct {
    name: [*c]const u8 = null,
    map: [*c]?*struct_bpf_map = null,
    addr: [*c]?*anyopaque = null,
};
pub const struct_bpf_object_subskeleton = extern struct {
    sz: usize = 0,
    obj: ?*const struct_bpf_object = null,
    map_cnt: c_int = 0,
    map_skel_sz: c_int = 0,
    maps: [*c]struct_bpf_map_skeleton = null,
    prog_cnt: c_int = 0,
    prog_skel_sz: c_int = 0,
    progs: [*c]struct_bpf_prog_skeleton = null,
    var_cnt: c_int = 0,
    var_skel_sz: c_int = 0,
    vars: [*c]struct_bpf_var_skeleton = null,
    pub const bpf_object__open_subskeleton = __root.bpf_object__open_subskeleton;
    pub const bpf_object__destroy_subskeleton = __root.bpf_object__destroy_subskeleton;
    pub const subskeleton = __root.bpf_object__open_subskeleton;
};
pub extern fn bpf_object__open_subskeleton(s: [*c]struct_bpf_object_subskeleton) c_int;
pub extern fn bpf_object__destroy_subskeleton(s: [*c]struct_bpf_object_subskeleton) void;
pub const struct_gen_loader_opts = extern struct {
    sz: usize = 0,
    data: [*c]const u8 = null,
    insns: [*c]const u8 = null,
    data_sz: __u32 = 0,
    insns_sz: __u32 = 0,
};
pub extern fn bpf_object__gen_loader(obj: ?*struct_bpf_object, opts: [*c]struct_gen_loader_opts) c_int;
pub const TRI_NO: c_int = 0;
pub const TRI_YES: c_int = 1;
pub const TRI_MODULE: c_int = 2;
pub const enum_libbpf_tristate = c_uint;
pub const struct_bpf_linker_opts = extern struct {
    sz: usize = 0,
};
pub const struct_bpf_linker_file_opts = extern struct {
    sz: usize = 0,
};
pub const struct_bpf_linker = opaque {
    pub const bpf_linker__add_file = __root.bpf_linker__add_file;
    pub const bpf_linker__finalize = __root.bpf_linker__finalize;
    pub const bpf_linker__free = __root.bpf_linker__free;
    pub const file = __root.bpf_linker__add_file;
    pub const finalize = __root.bpf_linker__finalize;
    pub const free = __root.bpf_linker__free;
};
pub extern fn bpf_linker__new(filename: [*c]const u8, opts: [*c]struct_bpf_linker_opts) ?*struct_bpf_linker;
pub extern fn bpf_linker__add_file(linker: ?*struct_bpf_linker, filename: [*c]const u8, opts: [*c]const struct_bpf_linker_file_opts) c_int;
pub extern fn bpf_linker__finalize(linker: ?*struct_bpf_linker) c_int;
pub extern fn bpf_linker__free(linker: ?*struct_bpf_linker) void;
pub const libbpf_prog_setup_fn_t = ?*const fn (prog: ?*struct_bpf_program, cookie: c_long) callconv(.c) c_int;
pub const libbpf_prog_prepare_load_fn_t = ?*const fn (prog: ?*struct_bpf_program, opts: ?*struct_bpf_prog_load_opts, cookie: c_long) callconv(.c) c_int;
pub const libbpf_prog_attach_fn_t = ?*const fn (prog: ?*const struct_bpf_program, cookie: c_long, link: [*c]?*struct_bpf_link) callconv(.c) c_int;
pub const struct_libbpf_prog_handler_opts = extern struct {
    sz: usize = 0,
    cookie: c_long = 0,
    prog_setup_fn: libbpf_prog_setup_fn_t = null,
    prog_prepare_load_fn: libbpf_prog_prepare_load_fn_t = null,
    prog_attach_fn: libbpf_prog_attach_fn_t = null,
};
pub extern fn libbpf_register_prog_handler(sec: [*c]const u8, prog_type: enum_bpf_prog_type, exp_attach_type: enum_bpf_attach_type, opts: [*c]const struct_libbpf_prog_handler_opts) c_int;
pub extern fn libbpf_unregister_prog_handler(handler_id: c_int) c_int;

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
pub const __LIBBPF_BPF_H = "";
pub const __LINUX_BPF_H__ = "";
pub const _LINUX_TYPES_H = "";
pub const _ASM_GENERIC_TYPES_H = "";
pub const _ASM_GENERIC_INT_LL64_H = "";
pub const __ASM_X86_BITSPERLONG_H = "";
pub const __BITS_PER_LONG = @as(c_int, 64);
pub const __ASM_GENERIC_BITS_PER_LONG = "";
pub const __BITS_PER_LONG_LONG = @as(c_int, 64);
pub const _LINUX_POSIX_TYPES_H = "";
pub const _LINUX_STDDEF_H = "";
pub inline fn __struct_group_tag(TAG: anytype) @TypeOf(TAG) {
    _ = &TAG;
    return TAG;
}
pub const __struct_group = @compileError("unable to translate C expr: unexpected token 'union'"); // /usr/include/linux/stddef.h:33:9
pub const __DECLARE_FLEX_ARRAY = @compileError("unable to translate macro: undefined identifier `__empty_`"); // /usr/include/linux/stddef.h:54:9
pub inline fn __counted_by(m: anytype) void {
    _ = &m;
    return;
}
pub inline fn __counted_by_le(m: anytype) void {
    _ = &m;
    return;
}
pub inline fn __counted_by_be(m: anytype) void {
    _ = &m;
    return;
}
pub const __kernel_nonstring = "";
pub const __FD_SETSIZE = @as(c_int, 1024);
pub const _ASM_X86_POSIX_TYPES_64_H = "";
pub const __ASM_GENERIC_POSIX_TYPES_H = "";
pub const __bitwise = "";
pub const __bitwise__ = "";
pub const __aligned_u64 = @compileError("unable to translate macro: undefined identifier `aligned`"); // /usr/include/linux/types.h:50:9
pub const __aligned_s64 = @compileError("unable to translate macro: undefined identifier `aligned`"); // /usr/include/linux/types.h:51:9
pub const __aligned_be64 = @compileError("unable to translate macro: undefined identifier `aligned`"); // /usr/include/linux/types.h:52:9
pub const __aligned_le64 = @compileError("unable to translate macro: undefined identifier `aligned`"); // /usr/include/linux/types.h:53:9
pub const __LINUX_BPF_COMMON_H__ = "";
pub inline fn BPF_CLASS(code: anytype) @TypeOf(code & @as(c_int, 0x07)) {
    _ = &code;
    return code & @as(c_int, 0x07);
}
pub const BPF_LD = @as(c_int, 0x00);
pub const BPF_LDX = @as(c_int, 0x01);
pub const BPF_ST = @as(c_int, 0x02);
pub const BPF_STX = @as(c_int, 0x03);
pub const BPF_ALU = @as(c_int, 0x04);
pub const BPF_JMP = @as(c_int, 0x05);
pub const BPF_RET = @as(c_int, 0x06);
pub const BPF_MISC = @as(c_int, 0x07);
pub inline fn BPF_SIZE(code: anytype) @TypeOf(code & @as(c_int, 0x18)) {
    _ = &code;
    return code & @as(c_int, 0x18);
}
pub const BPF_W = @as(c_int, 0x00);
pub const BPF_H = @as(c_int, 0x08);
pub const BPF_B = @as(c_int, 0x10);
pub inline fn BPF_MODE(code: anytype) @TypeOf(code & @as(c_int, 0xe0)) {
    _ = &code;
    return code & @as(c_int, 0xe0);
}
pub const BPF_IMM = @as(c_int, 0x00);
pub const BPF_ABS = @as(c_int, 0x20);
pub const BPF_IND = @as(c_int, 0x40);
pub const BPF_MEM = @as(c_int, 0x60);
pub const BPF_LEN = @as(c_int, 0x80);
pub const BPF_MSH = @as(c_int, 0xa0);
pub inline fn BPF_OP(code: anytype) @TypeOf(code & @as(c_int, 0xf0)) {
    _ = &code;
    return code & @as(c_int, 0xf0);
}
pub const BPF_ADD = @as(c_int, 0x00);
pub const BPF_SUB = @as(c_int, 0x10);
pub const BPF_MUL = @as(c_int, 0x20);
pub const BPF_DIV = @as(c_int, 0x30);
pub const BPF_OR = @as(c_int, 0x40);
pub const BPF_AND = @as(c_int, 0x50);
pub const BPF_LSH = @as(c_int, 0x60);
pub const BPF_RSH = @as(c_int, 0x70);
pub const BPF_NEG = @as(c_int, 0x80);
pub const BPF_MOD = @as(c_int, 0x90);
pub const BPF_XOR = @as(c_int, 0xa0);
pub const BPF_JA = @as(c_int, 0x00);
pub const BPF_JEQ = @as(c_int, 0x10);
pub const BPF_JGT = @as(c_int, 0x20);
pub const BPF_JGE = @as(c_int, 0x30);
pub const BPF_JSET = @as(c_int, 0x40);
pub inline fn BPF_SRC(code: anytype) @TypeOf(code & @as(c_int, 0x08)) {
    _ = &code;
    return code & @as(c_int, 0x08);
}
pub const BPF_K = @as(c_int, 0x00);
pub const BPF_X = @as(c_int, 0x08);
pub const BPF_MAXINSNS = @as(c_int, 4096);
pub const BPF_JMP32 = @as(c_int, 0x06);
pub const BPF_ALU64 = @as(c_int, 0x07);
pub const BPF_DW = @as(c_int, 0x18);
pub const BPF_MEMSX = @as(c_int, 0x80);
pub const BPF_ATOMIC = @as(c_int, 0xc0);
pub const BPF_XADD = @as(c_int, 0xc0);
pub const BPF_MOV = @as(c_int, 0xb0);
pub const BPF_ARSH = @as(c_int, 0xc0);
pub const BPF_END = @as(c_int, 0xd0);
pub const BPF_TO_LE = @as(c_int, 0x00);
pub const BPF_TO_BE = @as(c_int, 0x08);
pub const BPF_FROM_LE = BPF_TO_LE;
pub const BPF_FROM_BE = BPF_TO_BE;
pub const BPF_JNE = @as(c_int, 0x50);
pub const BPF_JLT = @as(c_int, 0xa0);
pub const BPF_JLE = @as(c_int, 0xb0);
pub const BPF_JSGT = @as(c_int, 0x60);
pub const BPF_JSGE = @as(c_int, 0x70);
pub const BPF_JSLT = @as(c_int, 0xc0);
pub const BPF_JSLE = @as(c_int, 0xd0);
pub const BPF_JCOND = @as(c_int, 0xe0);
pub const BPF_CALL = @as(c_int, 0x80);
pub const BPF_EXIT = @as(c_int, 0x90);
pub const BPF_FETCH = @as(c_int, 0x01);
pub const BPF_XCHG = @as(c_int, 0xe0) | BPF_FETCH;
pub const BPF_CMPXCHG = @as(c_int, 0xf0) | BPF_FETCH;
pub const BPF_LOAD_ACQ = @as(c_int, 0x100);
pub const BPF_STORE_REL = @as(c_int, 0x110);
pub const MAX_BPF_REG = __MAX_BPF_REG;
pub const MAX_BPF_ATTACH_TYPE = __MAX_BPF_ATTACH_TYPE;
pub const MAX_BPF_LINK_TYPE = __MAX_BPF_LINK_TYPE;
pub const BPF_F_ALLOW_OVERRIDE = @as(c_uint, 1) << @as(c_int, 0);
pub const BPF_F_ALLOW_MULTI = @as(c_uint, 1) << @as(c_int, 1);
pub const BPF_F_REPLACE = @as(c_uint, 1) << @as(c_int, 2);
pub const BPF_F_BEFORE = @as(c_uint, 1) << @as(c_int, 3);
pub const BPF_F_AFTER = @as(c_uint, 1) << @as(c_int, 4);
pub const BPF_F_ID = @as(c_uint, 1) << @as(c_int, 5);
pub const BPF_F_PREORDER = @as(c_uint, 1) << @as(c_int, 6);
pub const BPF_F_STRICT_ALIGNMENT = @as(c_uint, 1) << @as(c_int, 0);
pub const BPF_F_ANY_ALIGNMENT = @as(c_uint, 1) << @as(c_int, 1);
pub const BPF_F_TEST_RND_HI32 = @as(c_uint, 1) << @as(c_int, 2);
pub const BPF_F_TEST_STATE_FREQ = @as(c_uint, 1) << @as(c_int, 3);
pub const BPF_F_SLEEPABLE = @as(c_uint, 1) << @as(c_int, 4);
pub const BPF_F_XDP_HAS_FRAGS = @as(c_uint, 1) << @as(c_int, 5);
pub const BPF_F_XDP_DEV_BOUND_ONLY = @as(c_uint, 1) << @as(c_int, 6);
pub const BPF_F_TEST_REG_INVARIANTS = @as(c_uint, 1) << @as(c_int, 7);
pub const BPF_F_NETFILTER_IP_DEFRAG = @as(c_uint, 1) << @as(c_int, 0);
pub const BPF_PSEUDO_MAP_FD = @as(c_int, 1);
pub const BPF_PSEUDO_MAP_IDX = @as(c_int, 5);
pub const BPF_PSEUDO_MAP_VALUE = @as(c_int, 2);
pub const BPF_PSEUDO_MAP_IDX_VALUE = @as(c_int, 6);
pub const BPF_PSEUDO_BTF_ID = @as(c_int, 3);
pub const BPF_PSEUDO_FUNC = @as(c_int, 4);
pub const BPF_PSEUDO_CALL = @as(c_int, 1);
pub const BPF_PSEUDO_KFUNC_CALL = @as(c_int, 2);
pub const BPF_F_QUERY_EFFECTIVE = @as(c_uint, 1) << @as(c_int, 0);
pub const BPF_F_TEST_RUN_ON_CPU = @as(c_uint, 1) << @as(c_int, 0);
pub const BPF_F_TEST_XDP_LIVE_FRAMES = @as(c_uint, 1) << @as(c_int, 1);
pub const BPF_F_TEST_SKB_CHECKSUM_COMPLETE = @as(c_uint, 1) << @as(c_int, 2);
pub const BPF_BUILD_ID_SIZE = @as(c_int, 20);
pub const BPF_OBJ_NAME_LEN = @as(c_uint, 16);
pub const ___BPF_FUNC_MAPPER = @compileError("unable to translate macro: undefined identifier `unspec`"); // /usr/include/linux/bpf.h:5854:9
pub const __BPF_FUNC_MAPPER_APPLY = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/linux/bpf.h:6075:9
pub inline fn __BPF_FUNC_MAPPER(FN: anytype) @TypeOf(___BPF_FUNC_MAPPER(__BPF_FUNC_MAPPER_APPLY, FN)) {
    _ = &FN;
    return ___BPF_FUNC_MAPPER(__BPF_FUNC_MAPPER_APPLY, FN);
}
pub inline fn BPF_F_ADJ_ROOM_ENCAP_L2(len: anytype) @TypeOf((__helpers.cast(__u64, len) & BPF_ADJ_ROOM_ENCAP_L2_MASK) << BPF_ADJ_ROOM_ENCAP_L2_SHIFT) {
    _ = &len;
    return (__helpers.cast(__u64, len) & BPF_ADJ_ROOM_ENCAP_L2_MASK) << BPF_ADJ_ROOM_ENCAP_L2_SHIFT;
}
pub const BPF_F_REDIRECT_FLAGS = (BPF_F_INGRESS | BPF_F_BROADCAST) | BPF_F_EXCLUDE_INGRESS;
pub const __bpf_md_ptr = @compileError("unable to translate macro: undefined identifier `aligned`"); // /usr/include/linux/bpf.h:6265:9
pub const XDP_PACKET_HEADROOM = @as(c_int, 256);
pub const BPF_TAG_SIZE = @as(c_int, 8);
pub inline fn BPF_LINE_INFO_LINE_NUM(line_col: anytype) @TypeOf(line_col >> @as(c_int, 10)) {
    _ = &line_col;
    return line_col >> @as(c_int, 10);
}
pub inline fn BPF_LINE_INFO_LINE_COL(line_col: anytype) @TypeOf(line_col & @as(c_int, 0x3ff)) {
    _ = &line_col;
    return line_col & @as(c_int, 0x3ff);
}
pub const @"bool" = bool;
pub const @"true" = @as(c_int, 1);
pub const @"false" = @as(c_int, 0);
pub const __bool_true_false_are_defined = @as(c_int, 1);
pub const __STDC_VERSION_STDDEF_H__ = @as(c_long, 202311);
pub const NULL = __helpers.cast(?*anyopaque, @as(c_int, 0));
pub const offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // /usr/local/zig/lib/compiler/aro/include/stddef.h:18:9
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H = @as(c_int, 1);
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
pub const __LIBBPF_LIBBPF_COMMON_H = "";
pub const _STRING_H = @as(c_int, 1);
pub const __need_size_t = "";
pub const __need_NULL = "";
pub const _BITS_TYPES_LOCALE_T_H = @as(c_int, 1);
pub const _BITS_TYPES___LOCALE_T_H = @as(c_int, 1);
pub const _STRINGS_H = @as(c_int, 1);
pub const __LIBBPF_VERSION_H = "";
pub const LIBBPF_MAJOR_VERSION = @as(c_int, 1);
pub const LIBBPF_MINOR_VERSION = @as(c_int, 5);
pub const LIBBPF_API = @compileError("unable to translate macro: undefined identifier `visibility`"); // /usr/include/bpf/libbpf_common.h:16:9
pub const LIBBPF_DEPRECATED = @compileError("unable to translate macro: undefined identifier `deprecated`"); // /usr/include/bpf/libbpf_common.h:19:9
pub const LIBBPF_DEPRECATED_SINCE = @compileError("unable to translate macro: undefined identifier `__LIBBPF_MARK_DEPRECATED_`"); // /usr/include/bpf/libbpf_common.h:22:9
pub inline fn __LIBBPF_CURRENT_VERSION_GEQ(major: anytype, minor: anytype) @TypeOf((LIBBPF_MAJOR_VERSION > major) or ((LIBBPF_MAJOR_VERSION == major) and (LIBBPF_MINOR_VERSION >= minor))) {
    _ = &major;
    _ = &minor;
    return (LIBBPF_MAJOR_VERSION > major) or ((LIBBPF_MAJOR_VERSION == major) and (LIBBPF_MINOR_VERSION >= minor));
}
pub inline fn __LIBBPF_MARK_DEPRECATED_1_0(X: anytype) @TypeOf(X) {
    _ = &X;
    return X;
}
pub const ___libbpf_cat = @compileError("unable to translate C expr: unexpected token '##'"); // /usr/include/bpf/libbpf_common.h:45:9
pub inline fn ___libbpf_select(NAME: anytype, NUM: anytype) @TypeOf(___libbpf_cat(NAME, NUM)) {
    _ = &NAME;
    _ = &NUM;
    return ___libbpf_cat(NAME, NUM);
}
pub inline fn ___libbpf_nth(_1: anytype, _2: anytype, _3: anytype, _4: anytype, _5: anytype, _6: anytype, N: anytype) @TypeOf(N) {
    _ = &_1;
    _ = &_2;
    _ = &_3;
    _ = &_4;
    _ = &_5;
    _ = &_6;
    _ = &N;
    return N;
}
pub const ___libbpf_cnt = @compileError("unable to translate C expr: unexpected token '__VA_ARGS__'"); // /usr/include/bpf/libbpf_common.h:48:9
pub const ___libbpf_overload = @compileError("unable to translate C expr: unexpected token '__VA_ARGS__'"); // /usr/include/bpf/libbpf_common.h:49:9
pub const LIBBPF_OPTS = @compileError("unable to translate macro: untranslatable usage of arg `TYPE`"); // /usr/include/bpf/libbpf_common.h:64:9
pub const LIBBPF_OPTS_RESET = @compileError("unable to translate macro: undefined identifier `___`"); // /usr/include/bpf/libbpf_common.h:80:9
pub const __LIBBPF_LEGACY_BPF_H = "";
pub const DECLARE_LIBBPF_OPTS = LIBBPF_OPTS;
pub const bpf_map_create_opts__last_field = @compileError("unable to translate macro: undefined identifier `token_fd`"); // /usr/include/bpf/bpf.h:59:9
pub const bpf_prog_load_opts__last_field = @compileError("unable to translate macro: undefined identifier `token_fd`"); // /usr/include/bpf/bpf.h:112:9
pub const MAPS_RELAX_COMPAT = @as(c_int, 0x01);
pub const BPF_LOG_BUF_SIZE = UINT32_MAX >> @as(c_int, 8);
pub const bpf_btf_load_opts__last_field = @compileError("unable to translate macro: undefined identifier `token_fd`"); // /usr/include/bpf/bpf.h:143:9
pub const bpf_map_batch_opts__last_field = @compileError("unable to translate macro: undefined identifier `flags`"); // /usr/include/bpf/bpf.h:168:9
pub const bpf_obj_pin_opts__last_field = @compileError("unable to translate macro: undefined identifier `path_fd`"); // /usr/include/bpf/bpf.h:310:9
pub const bpf_obj_get_opts__last_field = @compileError("unable to translate macro: undefined identifier `path_fd`"); // /usr/include/bpf/bpf.h:324:9
pub const bpf_prog_attach_opts__last_field = @compileError("unable to translate macro: undefined identifier `expected_revision`"); // /usr/include/bpf/bpf.h:348:9
pub const bpf_prog_detach_opts__last_field = @compileError("unable to translate macro: undefined identifier `expected_revision`"); // /usr/include/bpf/bpf.h:358:9
pub const bpf_link_create_opts__last_field = @compileError("unable to translate macro: undefined identifier `uprobe_multi`"); // /usr/include/bpf/bpf.h:441:9
pub const bpf_link_update_opts__last_field = @compileError("unable to translate macro: undefined identifier `old_map_fd`"); // /usr/include/bpf/bpf.h:455:9
pub const bpf_get_fd_by_id_opts__last_field = @compileError("unable to translate macro: undefined identifier `open_flags`"); // /usr/include/bpf/bpf.h:489:9
pub const bpf_prog_query_opts__last_field = @compileError("unable to translate macro: undefined identifier `revision`"); // /usr/include/bpf/bpf.h:601:9
pub const bpf_raw_tp_opts__last_field = @compileError("unable to translate macro: undefined identifier `cookie`"); // /usr/include/bpf/bpf.h:626:9
pub const bpf_prog_bind_opts__last_field = @compileError("unable to translate macro: undefined identifier `flags`"); // /usr/include/bpf/bpf.h:648:9
pub const bpf_test_run_opts__last_field = @compileError("unable to translate macro: undefined identifier `batch_size`"); // /usr/include/bpf/bpf.h:674:9
pub const bpf_token_create_opts__last_field = @compileError("unable to translate macro: undefined identifier `flags`"); // /usr/include/bpf/bpf.h:684:9
pub const __LIBBPF_LIBBPF_H = "";
pub const __STDC_VERSION_STDARG_H__ = @as(c_int, 0);
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:12:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:14:9
pub const va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:15:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:18:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // /usr/local/zig/lib/compiler/aro/include/stdarg.h:22:9
pub const __GNUC_VA_LIST = @as(c_int, 1);
pub const _STDIO_H = @as(c_int, 1);
pub const __GLIBC_USE_LIB_EXT2 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = @as(c_int, 0);
pub const __need___va_list = "";
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
pub const _SYS_TYPES_H = @as(c_int, 1);
pub const __u_char_defined = "";
pub const __ino_t_defined = "";
pub const __dev_t_defined = "";
pub const __gid_t_defined = "";
pub const __mode_t_defined = "";
pub const __nlink_t_defined = "";
pub const __uid_t_defined = "";
pub const __pid_t_defined = "";
pub const __id_t_defined = "";
pub const __daddr_t_defined = "";
pub const __key_t_defined = "";
pub const __clock_t_defined = @as(c_int, 1);
pub const __clockid_t_defined = @as(c_int, 1);
pub const __time_t_defined = @as(c_int, 1);
pub const __timer_t_defined = @as(c_int, 1);
pub const __BIT_TYPES_DEFINED__ = @as(c_int, 1);
pub const _ENDIAN_H = @as(c_int, 1);
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
pub const _STRUCT_TIMESPEC = @as(c_int, 1);
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
pub const bpf_object_open_opts__last_field = @compileError("unable to translate macro: undefined identifier `bpf_token_path`"); // /usr/include/bpf/libbpf.h:205:9
pub const bpf_object__for_each_program = @compileError("unable to translate C expr: unexpected token 'for'"); // /usr/include/bpf/libbpf.h:327:9
pub const bpf_perf_event_opts__last_field = @compileError("unable to translate macro: undefined identifier `force_ioctl_attach`"); // /usr/include/bpf/libbpf.h:491:9
pub const bpf_kprobe_opts__last_field = @compileError("unable to translate macro: undefined identifier `attach_mode`"); // /usr/include/bpf/libbpf.h:530:9
pub const bpf_kprobe_multi_opts__last_field = @compileError("unable to translate macro: undefined identifier `session`"); // /usr/include/bpf/libbpf.h:558:9
pub const bpf_uprobe_multi_opts__last_field = @compileError("unable to translate macro: undefined identifier `retprobe`"); // /usr/include/bpf/libbpf.h:583:9
pub const bpf_ksyscall_opts__last_field = @compileError("unable to translate macro: undefined identifier `retprobe`"); // /usr/include/bpf/libbpf.h:625:9
pub const bpf_uprobe_opts__last_field = @compileError("unable to translate macro: undefined identifier `attach_mode`"); // /usr/include/bpf/libbpf.h:685:9
pub const bpf_usdt_opts__last_field = @compileError("unable to translate macro: undefined identifier `usdt_cookie`"); // /usr/include/bpf/libbpf.h:734:9
pub const bpf_tracepoint_opts__last_field = @compileError("unable to translate macro: undefined identifier `bpf_cookie`"); // /usr/include/bpf/libbpf.h:764:9
pub const bpf_raw_tracepoint_opts__last_field = @compileError("unable to translate macro: undefined identifier `cookie`"); // /usr/include/bpf/libbpf.h:781:9
pub const bpf_trace_opts__last_field = @compileError("unable to translate macro: undefined identifier `cookie`"); // /usr/include/bpf/libbpf.h:797:9
pub const bpf_netfilter_opts__last_field = @compileError("unable to translate macro: undefined identifier `flags`"); // /usr/include/bpf/libbpf.h:827:9
pub const bpf_tcx_opts__last_field = @compileError("unable to translate macro: undefined identifier `expected_revision`"); // /usr/include/bpf/libbpf.h:842:9
pub const bpf_netkit_opts__last_field = @compileError("unable to translate macro: undefined identifier `expected_revision`"); // /usr/include/bpf/libbpf.h:857:9
pub const bpf_iter_attach_opts__last_field = @compileError("unable to translate macro: undefined identifier `link_info_len`"); // /usr/include/bpf/libbpf.h:873:9
pub const bpf_object__for_each_map = @compileError("unable to translate C expr: unexpected token 'for'"); // /usr/include/bpf/libbpf.h:958:9
pub const bpf_map__for_each = bpf_object__for_each_map;
pub const bpf_xdp_set_link_opts__last_field = @compileError("unable to translate macro: undefined identifier `old_fd`"); // /usr/include/bpf/libbpf.h:1235:9
pub const bpf_xdp_attach_opts__last_field = @compileError("unable to translate macro: undefined identifier `old_prog_fd`"); // /usr/include/bpf/libbpf.h:1242:9
pub const bpf_xdp_query_opts__last_field = @compileError("unable to translate macro: undefined identifier `xdp_zc_max_segs`"); // /usr/include/bpf/libbpf.h:1255:9
pub inline fn BPF_TC_PARENT(a: anytype, b: anytype) @TypeOf(((a << @as(c_int, 16)) & __helpers.promoteIntLiteral(c_uint, 0xFFFF0000, .hex)) | (b & @as(c_uint, 0x0000FFFF))) {
    _ = &a;
    _ = &b;
    return ((a << @as(c_int, 16)) & __helpers.promoteIntLiteral(c_uint, 0xFFFF0000, .hex)) | (b & @as(c_uint, 0x0000FFFF));
}
pub const bpf_tc_hook__last_field = @compileError("unable to translate macro: undefined identifier `parent`"); // /usr/include/bpf/libbpf.h:1285:9
pub const bpf_tc_opts__last_field = @compileError("unable to translate macro: undefined identifier `priority`"); // /usr/include/bpf/libbpf.h:1296:9
pub const ring_buffer_opts__last_field = @compileError("unable to translate macro: undefined identifier `sz`"); // /usr/include/bpf/libbpf.h:1318:9
pub const user_ring_buffer_opts__last_field = @compileError("unable to translate macro: undefined identifier `sz`"); // /usr/include/bpf/libbpf.h:1418:9
pub const perf_buffer_opts__last_field = @compileError("unable to translate macro: undefined identifier `sample_period`"); // /usr/include/bpf/libbpf.h:1539:9
pub const perf_buffer_raw_opts__last_field = @compileError("unable to translate macro: undefined identifier `map_keys`"); // /usr/include/bpf/libbpf.h:1583:9
pub const gen_loader_opts__last_field = @compileError("unable to translate macro: undefined identifier `insns_sz`"); // /usr/include/bpf/libbpf.h:1772:9
pub const bpf_linker_opts__last_field = @compileError("unable to translate macro: undefined identifier `sz`"); // /usr/include/bpf/libbpf.h:1786:9
pub const bpf_linker_file_opts__last_field = @compileError("unable to translate macro: undefined identifier `sz`"); // /usr/include/bpf/libbpf.h:1792:9
pub const libbpf_prog_handler_opts__last_field = @compileError("unable to translate macro: undefined identifier `prog_attach_fn`"); // /usr/include/bpf/libbpf.h:1855:9
pub const bpf_cond_pseudo_jmp = enum_bpf_cond_pseudo_jmp;
pub const bpf_insn = struct_bpf_insn;
pub const bpf_lpm_trie_key = struct_bpf_lpm_trie_key;
pub const bpf_lpm_trie_key_hdr = struct_bpf_lpm_trie_key_hdr;
pub const bpf_lpm_trie_key_u8 = struct_bpf_lpm_trie_key_u8;
pub const bpf_cgroup_storage_key = struct_bpf_cgroup_storage_key;
pub const bpf_cgroup_iter_order = enum_bpf_cgroup_iter_order;
pub const bpf_iter_link_info = union_bpf_iter_link_info;
pub const bpf_cmd = enum_bpf_cmd;
pub const bpf_map_type = enum_bpf_map_type;
pub const bpf_prog_type = enum_bpf_prog_type;
pub const bpf_attach_type = enum_bpf_attach_type;
pub const bpf_link_type = enum_bpf_link_type;
pub const bpf_perf_event_type = enum_bpf_perf_event_type;
pub const bpf_addr_space_cast = enum_bpf_addr_space_cast;
pub const bpf_stats_type = enum_bpf_stats_type;
pub const bpf_stack_build_id_status = enum_bpf_stack_build_id_status;
pub const bpf_stack_build_id = struct_bpf_stack_build_id;
pub const bpf_attr = union_bpf_attr;
pub const bpf_func_id = enum_bpf_func_id;
pub const bpf_adj_room_mode = enum_bpf_adj_room_mode;
pub const bpf_hdr_start_off = enum_bpf_hdr_start_off;
pub const bpf_lwt_encap_mode = enum_bpf_lwt_encap_mode;
pub const bpf_flow_keys = struct_bpf_flow_keys;
pub const bpf_sock = struct_bpf_sock;
pub const __sk_buff = struct___sk_buff;
pub const bpf_tunnel_key = struct_bpf_tunnel_key;
pub const bpf_xfrm_state = struct_bpf_xfrm_state;
pub const bpf_ret_code = enum_bpf_ret_code;
pub const bpf_tcp_sock = struct_bpf_tcp_sock;
pub const bpf_sock_tuple = struct_bpf_sock_tuple;
pub const tcx_action_base = enum_tcx_action_base;
pub const bpf_xdp_sock = struct_bpf_xdp_sock;
pub const xdp_action = enum_xdp_action;
pub const xdp_md = struct_xdp_md;
pub const bpf_devmap_val = struct_bpf_devmap_val;
pub const bpf_cpumap_val = struct_bpf_cpumap_val;
pub const sk_action = enum_sk_action;
pub const sk_msg_md = struct_sk_msg_md;
pub const sk_reuseport_md = struct_sk_reuseport_md;
pub const bpf_prog_info = struct_bpf_prog_info;
pub const bpf_map_info = struct_bpf_map_info;
pub const bpf_btf_info = struct_bpf_btf_info;
pub const bpf_link_info = struct_bpf_link_info;
pub const bpf_token_info = struct_bpf_token_info;
pub const bpf_sock_addr = struct_bpf_sock_addr;
pub const bpf_sock_ops = struct_bpf_sock_ops;
pub const bpf_perf_event_value = struct_bpf_perf_event_value;
pub const bpf_cgroup_dev_ctx = struct_bpf_cgroup_dev_ctx;
pub const bpf_raw_tracepoint_args = struct_bpf_raw_tracepoint_args;
pub const bpf_fib_lookup = struct_bpf_fib_lookup;
pub const bpf_redir_neigh = struct_bpf_redir_neigh;
pub const bpf_check_mtu_flags = enum_bpf_check_mtu_flags;
pub const bpf_check_mtu_ret = enum_bpf_check_mtu_ret;
pub const bpf_task_fd_type = enum_bpf_task_fd_type;
pub const bpf_func_info = struct_bpf_func_info;
pub const bpf_line_info = struct_bpf_line_info;
pub const bpf_spin_lock = struct_bpf_spin_lock;
pub const bpf_timer = struct_bpf_timer;
pub const bpf_wq = struct_bpf_wq;
pub const bpf_dynptr = struct_bpf_dynptr;
pub const bpf_list_head = struct_bpf_list_head;
pub const bpf_list_node = struct_bpf_list_node;
pub const bpf_rb_root = struct_bpf_rb_root;
pub const bpf_rb_node = struct_bpf_rb_node;
pub const bpf_refcount = struct_bpf_refcount;
pub const bpf_sysctl = struct_bpf_sysctl;
pub const bpf_sockopt = struct_bpf_sockopt;
pub const bpf_pidns_info = struct_bpf_pidns_info;
pub const bpf_sk_lookup = struct_bpf_sk_lookup;
pub const btf_ptr = struct_btf_ptr;
pub const bpf_core_relo_kind = enum_bpf_core_relo_kind;
pub const bpf_core_relo = struct_bpf_core_relo;
pub const bpf_iter_num = struct_bpf_iter_num;
pub const bpf_kfunc_flags = enum_bpf_kfunc_flags;
pub const __locale_struct = struct___locale_struct;
pub const libbpf_strict_mode = enum_libbpf_strict_mode;
pub const btf = struct_btf;
pub const bpf_program = struct_bpf_program;
pub const bpf_map = struct_bpf_map;
pub const btf_ext = struct_btf_ext;
pub const bpf_map_create_opts = struct_bpf_map_create_opts;
pub const bpf_prog_load_opts = struct_bpf_prog_load_opts;
pub const bpf_btf_load_opts = struct_bpf_btf_load_opts;
pub const bpf_map_batch_opts = struct_bpf_map_batch_opts;
pub const bpf_link_create_opts = struct_bpf_link_create_opts;
pub const bpf_link_update_opts = struct_bpf_link_update_opts;
pub const bpf_prog_test_run_attr = struct_bpf_prog_test_run_attr;
pub const bpf_get_fd_by_id_opts = struct_bpf_get_fd_by_id_opts;
pub const bpf_raw_tp_opts = struct_bpf_raw_tp_opts;
pub const bpf_prog_bind_opts = struct_bpf_prog_bind_opts;
pub const bpf_test_run_opts = struct_bpf_test_run_opts;
pub const bpf_token_create_opts = struct_bpf_token_create_opts;
pub const _G_fpos_t = struct__G_fpos_t;
pub const _G_fpos64_t = struct__G_fpos64_t;
pub const _IO_marker = struct__IO_marker;
pub const _IO_FILE = struct__IO_FILE;
pub const _IO_cookie_io_functions_t = struct__IO_cookie_io_functions_t;
pub const timeval = struct_timeval;
pub const timespec = struct_timespec;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const libbpf_errno = enum_libbpf_errno;
pub const libbpf_print_level = enum_libbpf_print_level;
pub const bpf_object_open_opts = struct_bpf_object_open_opts;
pub const bpf_object = struct_bpf_object;
pub const bpf_link = struct_bpf_link;
pub const bpf_perf_event_opts = struct_bpf_perf_event_opts;
pub const probe_attach_mode = enum_probe_attach_mode;
pub const bpf_kprobe_opts = struct_bpf_kprobe_opts;
pub const bpf_kprobe_multi_opts = struct_bpf_kprobe_multi_opts;
pub const bpf_uprobe_multi_opts = struct_bpf_uprobe_multi_opts;
pub const bpf_ksyscall_opts = struct_bpf_ksyscall_opts;
pub const bpf_uprobe_opts = struct_bpf_uprobe_opts;
pub const bpf_usdt_opts = struct_bpf_usdt_opts;
pub const bpf_tracepoint_opts = struct_bpf_tracepoint_opts;
pub const bpf_raw_tracepoint_opts = struct_bpf_raw_tracepoint_opts;
pub const bpf_trace_opts = struct_bpf_trace_opts;
pub const bpf_netfilter_opts = struct_bpf_netfilter_opts;
pub const bpf_tcx_opts = struct_bpf_tcx_opts;
pub const bpf_netkit_opts = struct_bpf_netkit_opts;
pub const bpf_iter_attach_opts = struct_bpf_iter_attach_opts;
pub const bpf_xdp_set_link_opts = struct_bpf_xdp_set_link_opts;
pub const bpf_xdp_attach_opts = struct_bpf_xdp_attach_opts;
pub const bpf_xdp_query_opts = struct_bpf_xdp_query_opts;
pub const bpf_tc_attach_point = enum_bpf_tc_attach_point;
pub const bpf_tc_flags = enum_bpf_tc_flags;
pub const bpf_tc_hook = struct_bpf_tc_hook;
pub const bpf_tc_opts = struct_bpf_tc_opts;
pub const ring_buffer_opts = struct_ring_buffer_opts;
pub const ring_buffer = struct_ring_buffer;
pub const ring = struct_ring;
pub const user_ring_buffer_opts = struct_user_ring_buffer_opts;
pub const user_ring_buffer = struct_user_ring_buffer;
pub const perf_buffer_opts = struct_perf_buffer_opts;
pub const perf_buffer = struct_perf_buffer;
pub const bpf_perf_event_ret = enum_bpf_perf_event_ret;
pub const perf_event_header = struct_perf_event_header;
pub const perf_buffer_raw_opts = struct_perf_buffer_raw_opts;
pub const perf_event_attr = struct_perf_event_attr;
pub const bpf_prog_linfo = struct_bpf_prog_linfo;
pub const bpf_map_skeleton = struct_bpf_map_skeleton;
pub const bpf_prog_skeleton = struct_bpf_prog_skeleton;
pub const bpf_object_skeleton = struct_bpf_object_skeleton;
pub const bpf_var_skeleton = struct_bpf_var_skeleton;
pub const bpf_object_subskeleton = struct_bpf_object_subskeleton;
pub const gen_loader_opts = struct_gen_loader_opts;
pub const libbpf_tristate = enum_libbpf_tristate;
pub const bpf_linker_opts = struct_bpf_linker_opts;
pub const bpf_linker_file_opts = struct_bpf_linker_file_opts;
pub const bpf_linker = struct_bpf_linker;
pub const libbpf_prog_handler_opts = struct_libbpf_prog_handler_opts;
