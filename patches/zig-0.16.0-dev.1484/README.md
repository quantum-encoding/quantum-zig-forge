# Zig 0.16.0-dev.1484 Standard Library Patches

These patches fix issues discovered when building quantum-zig-forge against Zig 0.16.0-dev.1484.

## Patches

### 0001-add-SocketNotListening-to-AcceptError.patch

**File:** `lib/std/Io/net.zig`

Adds `SocketNotListening` to the `AcceptError` error set. This error is returned when `accept()` is called on a socket that isn't listening (EINVAL). Without this patch, user code that attempts to return `SocketNotListening` from functions using `AcceptError` fails to compile.

### 0002-add-posixConnectWithTimeout.patch

**File:** `lib/std/Io/Threaded.zig`

Implements the `TODO implement netConnectIpPosix with timeout` that currently panics. This patch:

1. Adds `posixConnectWithTimeout()` helper function using non-blocking sockets + poll()
2. Modifies `netConnectIpPosix()` to use the timeout when requested
3. Properly handles EINPROGRESS and checks SO_ERROR after poll() completion

This enables HTTP clients and other network code to use connection timeouts.

## Applying Patches

```bash
# From the Zig installation directory
cd /path/to/zig

# Apply patches
patch -p1 < /path/to/0001-add-SocketNotListening-to-AcceptError.patch
patch -p1 < /path/to/0002-add-posixConnectWithTimeout.patch
```

## Testing

After applying patches, build the quantum-zig-forge projects:

```bash
cd programs/chronos_engine && zig build
cd programs/quantum_curl && zig build
cd programs/financial_engine && zig build
cd programs/http_sentinel && zig build
cd programs/stratum_engine_claude && zig build
```

## Zig Version

These patches are specifically for:
- **Version:** 0.16.0-dev.1484+d0ba6642b
- **Download:** https://ziglang.org/builds/zig-linux-x86_64-0.16.0-dev.1484+d0ba6642b.tar.xz
