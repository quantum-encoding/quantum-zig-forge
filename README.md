# Quantum Zig Forge

A monorepo of production-grade Zig programs and libraries developed by QUANTUM ENCODING LTD.

## Structure

```
quantum-zig-forge/
├── programs/             # Standalone programs
│   ├── zig_ai/           # Universal AI CLI (Claude, DeepSeek, Gemini, Grok, Vertex)
│   ├── http_sentinel/    # Production HTTP client library with AI providers
│   │   └── programs/quantum_curl/  # High-velocity HTTP router [PREMIER]
│   ├── guardian_shield/  # Multi-layered Linux security framework
│   ├── chronos_engine/   # Sovereign Clock temporal tracking system
│   ├── zig_jail/         # Kernel-enforced syscall sandbox
│   ├── zig_port_scanner/ # High-performance TCP port scanner
│   ├── duck_agent_scribe/ # Eternal accountability logging for AI agents
│   ├── duck_cache_scribe/ # Automated git commit/push daemon
│   ├── cognitive_telemetry_kit/ # AI cognitive state monitoring toolkit
│   ├── stratum_engine_claude/ # High-frequency Stratum mining engine (Claude)
│   ├── stratum_engine_grok/ # io_uring Stratum mining engine (Grok)
│   ├── timeseries_db/       # High-performance columnar time series database
│   ├── market_data_parser/  # Zero-copy exchange market data parser
│   ├── financial_engine/    # HFT trading system with Alpaca integration
│   ├── async_scheduler/     # Work-stealing async task scheduler
│   ├── zero_copy_net/       # io_uring zero-copy network stack
│   ├── simd_crypto/         # SIMD-accelerated cryptographic primitives [STUBBED]
│   ├── memory_pool/         # Fixed-size memory pool allocator [WIP]
│   └── lockfree_queue/      # Lock-free SPSC/MPMC queues [WIP]
├── libs/                 # Shared libraries
├── docs/                 # Monorepo-wide documentation
├── tests/                # Integration tests
├── scripts/              # Build and utility scripts
├── zig-out/              # Centralized build output
│   ├── bin/              # All program binaries
│   └── lib/              # Shared libraries
└── build.zig             # Root build orchestrator
```

## Building

### Build Everything

```bash
zig build
```

All binaries will be placed in `zig-out/bin/` at the repository root.

### Build Specific Programs

```bash
zig build quantum_curl
zig build http_sentinel
zig build guardian_shield
zig build chronos_engine
zig build zig_jail
zig build zig_port_scanner
zig build duck_agent_scribe
zig build duck_cache_scribe
zig build cognitive_telemetry_kit
zig build stratum_engine_claude
zig build stratum_engine_grok
zig build timeseries_db
zig build market_data_parser
zig build financial_engine
zig build async_scheduler
zig build zero_copy_net
zig build simd_crypto
zig build memory_pool
zig build lockfree_queue
```

### Build All Programs

```bash
zig build all
```

## Testing

Run all tests across the monorepo:

```bash
zig build test
```

## Cleaning

Remove all build artifacts:

```bash
zig build clean
```

## Programs

### quantum_curl (Premier Strategic Asset)

**High-Velocity Command-Driven Router for Microservice Orchestration**

Quantum Curl is not a curl clone. It is a strategic weapon designed for the orchestration and stress-testing of complex microservice architectures. The core innovation: decoupling the **Battle Plan** (JSONL manifest) from the **Execution Engine** (high-concurrency Zig runtime).

**Performance:**
| Metric | Value | Comparison |
|--------|-------|------------|
| Routing Latency | ~2ms p99 | 5-7x lower than nginx |
| Concurrency | Thread-per-request | Zero contention |
| Memory | Client-per-worker | No shared state |

**Strategic Applications:**
- **Service Mesh Router**: Decentralized, high-velocity inter-service communication
- **Resilience Testing**: Native retry/backoff imposes discipline on flaky services
- **Stress Testing**: Find breaking points under realistic concurrent load
- **API Test Suites**: Batch execution with full telemetry

**Quick Start:**
```bash
# Process from stdin
echo '{"id":"1","method":"GET","url":"https://httpbin.org/get"}' | quantum-curl

# Process from file with high concurrency
quantum-curl --file battle-plan.jsonl --concurrency 100
```

**Documentation:** [programs/quantum_curl/README.md](programs/quantum_curl/README.md)

**Binary:** `quantum-curl`

---

### http_sentinel

A production-grade HTTP client library for Zig 0.16.0+, built on `std.Io.Threaded` architecture. This is the core dependency for quantum_curl.

**Features:**
- Thread-safe concurrent HTTP operations
- Client-per-worker pattern for zero contention
- Automatic GZIP decompression
- Full HTTP method support (GET, POST, PUT, PATCH, DELETE, HEAD)
- Production-tested in high-frequency trading systems

**Documentation:** [programs/http_sentinel/README.md](programs/http_sentinel/README.md)

**Binaries:**
- `zig-ai` - AI providers CLI tool
- Multiple examples and demos

### guardian_shield

Multi-layered Linux security framework implementing the "Chimera Protocol" with defense-in-depth strategy.

**Features:**
- User-space protection via LD_PRELOAD syscall interception (`libwarden.so`)
- Kernel-space execution control via LSM BPF (`zig-sentinel`)
- Fork bomb prevention (`libwarden-fork.so`)
- eBPF-based system monitoring and anomaly detection
- Multi-dimensional threat detection (crypto mining, gaming cheats, etc.)
- Cognitive state tracking via Chronos Engine
- Production-tested Linux security

**Documentation:** [programs/guardian_shield/README.md](programs/guardian_shield/README.md)

**Binaries:**
- `zig-sentinel` - eBPF system monitor
- `conductor-daemon` - Strategic command daemon
- `chronos-stamp-cognitive-direct` - Cognitive state tracker
- `hardware-detector` - System capability detection
- `adaptive-pattern-loader` - Adaptive threat pattern loading
- Test harnesses: `test-inquisitor`, `test-oracle-advanced`, `test-conductor-daemon`

**Libraries:**
- `libwarden.so` - Filesystem protection library
- `libwarden-fork.so` - Fork bomb protection library

### chronos_engine

Sovereign Clock temporal tracking system with Phi-synchronized timestamps and cognitive state monitoring.

**Features:**
- Monotonic tick counter independent of wall clock
- PHI-synchronized timestamp generation for distributed systems
- D-Bus interface for system-wide time coordination
- Cognitive state tracking for AI agent monitoring
- Real-time metrics aggregation with rolling time windows
- SVG visualization of cognitive state timelines
- Integration with Claude Code for development workflow tracking

**Documentation:** [programs/chronos_engine/README.md](programs/chronos_engine/README.md)

**Binaries:**
- `chronosd` - Chronos daemon with D-Bus service
- `chronos-stamp` - CLI timestamp generation tool
- `chronos-stamp-cognitive` - Cognitive-aware timestamp tool
- `chronos-stamp-cognitive-direct` - Direct cognitive state integration
- `cognitive-watcher` - Real-time AI process monitoring
- `chronos-logger-simple` - Simplified logging interface
- `test-phi-timestamp` - PHI timestamp validation
- `test-cognitive-states` - Cognitive state machine tests
- `test-cognitive-metrics` - Metrics system validation
- Multiple example tools and visualizers

### zig_jail

Kernel-enforced syscall sandbox using seccomp-BPF, Linux namespaces, and capabilities for secure process isolation.

**Features:**
- Seccomp-BPF filtering with kernel-enforced syscall whitelist/blacklist
- Linux namespace isolation (PID, mount, network, IPC)
- Capability dropping for privilege restriction
- Profile-based security configurations (minimal, python-safe, node-safe, shell-readonly)
- Bind mount support with read-only options
- Defense-in-depth security architecture

**Documentation:** [programs/zig_jail/README.md](programs/zig_jail/README.md)

**Binaries:**
- `zig-jail` - Syscall sandbox CLI

### zig_port_scanner

High-performance, multi-threaded TCP port scanner for network security monitoring and AI agent activity detection.

**Features:**
- Multi-threaded concurrent scanning (up to 100 threads)
- Order-independent argument parsing
- Non-blocking I/O with poll() for efficient connection testing
- Service detection for common protocols
- Flexible port ranges (single, ranges, comma-separated lists)
- Configurable connection timeout
- Real-time verbose mode and closed port reporting
- Comprehensive error handling and input validation

**Documentation:** [programs/zig_port_scanner/README.md](programs/zig_port_scanner/README.md)

**Binaries:**
- `zig-port-scanner` - TCP port scanner CLI

**Use Cases:**
- Baseline network activity monitoring
- Detection of unauthorized network connections from AI agents
- Identification of reverse shells and data exfiltration attempts
- Security auditing and vulnerability assessment

### duck_agent_scribe

Eternal accountability logging system for spawned AI agents with full lifecycle tracking.

**Features:**
- Agent initialization with chronos tick timestamps
- Turn-by-turn logging with 4th-dimensional timestamps
- Completion tracking with status, turns taken, and tokens used
- Batch manifest management for multi-agent orchestration
- Retry lineage tracking for failed agent attempts
- JSON-based manifest storage for each agent run

**Documentation:** [programs/duck_agent_scribe/README.md](programs/duck_agent_scribe/README.md)

**Binaries:**
- `duckagent-scribe` - Agent accountability CLI

**Commands:**
- `init` - Initialize eternal log for new agent
- `log` - Log agent turn/action
- `complete` - Mark agent completion
- `batch-complete` - Finalize batch manifest
- `query` - Query agent logs
- `lineage` - Show retry lineage

### duck_cache_scribe

Automated git commit/push daemon for continuous repository synchronization with chronos timestamps.

**Features:**
- inotify-based file change detection
- Debounced commits to prevent commit storms
- Chronos-stamp integration for 4th-dimensional commit messages
- Automatic push after configurable commit threshold
- Exponential backoff retry for network failures
- JSON configuration for repository settings
- Systemd service integration

**Documentation:** [programs/duck_cache_scribe/README.md](programs/duck_cache_scribe/README.md)

**Binaries:**
- `duckcache-scribe` - Git sync daemon

**Configuration:**
- `repo_path` - Target repository path
- `remote_name` - Git remote name
- `branch_name` - Branch to push
- `chronos_stamp_path` - Path to chronos-stamp binary
- `agent_id` - Agent identifier for commits
- `debounce_ms` - Debounce interval in milliseconds

### cognitive_telemetry_kit

Comprehensive toolkit for monitoring AI agent cognitive states with real-time telemetry and analytics.

**Components:**
- `chronos-hook` - Claude Code hook for automatic chronos timestamps on tool completions
- `cognitive-state-server` - D-Bus server with SQLite-backed cognitive state cache
- `cognitive-tools` - Analytics and export utilities for cognitive telemetry data

**Features:**
- Real-time cognitive state tracking via inotify file watching
- D-Bus interface for system-wide state queries
- SQLite persistence with in-memory caching
- CSV export for external analysis
- Confidence scoring and pattern detection
- Claude Code integration via hooks

**Documentation:** [programs/cognitive_telemetry_kit/README.md](programs/cognitive_telemetry_kit/README.md)

**Binaries:**
- `chronos-hook` - Git commit hook with cognitive state injection
- `cognitive-state-server` - In-memory state oracle daemon
- `cognitive-export` - CSV export tool
- `cognitive-stats` - Analytics and statistics
- `cognitive-query` - Advanced state search
- `cognitive-confidence` - Code quality confidence analyzer

**Dependencies:**
- SQLite3
- D-Bus
- libbpf (for eBPF components)

### stratum_engine_claude

High-frequency Stratum mining engine with SIMD-optimized SHA256, mempool monitoring, and exchange execution.

**Features:**
- SIMD-optimized SHA256d hashing (AVX2/AVX-512 support)
- Stratum V1 protocol implementation for mining pools
- Real-time Bitcoin P2P mempool monitoring
- mbedTLS-based secure exchange connections
- WebSocket-over-TLS for live market data
- High-frequency execution engine for trading
- Real-time mining and mempool dashboard

**Documentation:** [programs/stratum_engine_claude/README.md](programs/stratum_engine_claude/README.md)

**Binaries:**
- `stratum-engine` - Main mining engine
- `stratum-engine-dashboard` - Real-time mining + mempool dashboard
- `bench-sha256` - SHA256 performance benchmarks
- `test-mempool` - Bitcoin P2P mempool connection test
- `test-execution-engine` - High-frequency execution test
- `test-tls` - TLS/exchange connection test
- `test-exchange-client` - WebSocket exchange client test

**Dependencies:**
- mbedTLS (TLS support for exchange connections)

### stratum_engine_grok

Alternative Stratum mining engine using Linux io_uring for high-performance async I/O.

**Features:**
- Linux io_uring for zero-copy async networking
- Native SHA256d hashing implementation
- Stratum V1 protocol client
- JSON-RPC message parsing
- Efficient buffer management with ring buffers

**Documentation:** [programs/stratum_engine_grok/README.md](programs/stratum_engine_grok/README.md)

**Binaries:**
- `stratum-engine-grok` - io_uring-based Stratum mining client

**Requirements:**
- Linux kernel 5.1+ (io_uring support)

### timeseries_db

High-performance columnar time series database optimized for OHLCV (candlestick) market data.

**Features:**
- mmap-based zero-copy reads for 10M+ reads/second
- Columnar storage format for efficient compression
- SIMD-accelerated delta encoding (AVX2/AVX-512)
- B-tree indexing for O(log N) time-range queries
- Delta + bit-packing compression (87.5%+ reduction)
- Lock-free concurrent reads

**Documentation:** [programs/timeseries_db/README.md](programs/timeseries_db/README.md)

**Binaries:**
- `tsdb` - Time series database CLI

**Commands:**
- `write <symbol> <csv_file>` - Import candles from CSV
- `query <symbol> <start> <end>` - Query time range
- `info <symbol>` - Show database info
- `benchmark` - Run performance benchmarks

### market_data_parser

Zero-copy parsing of exchange market data feeds at wire speed.

**Features:**
- SIMD-accelerated JSON parsing (AVX2/AVX-512)
- Zero-copy field extraction for sub-microsecond latency
- Cache-line aligned lock-free order book
- 2M+ messages/second throughput
- Support for Binance, Coinbase WebSocket protocols

**Documentation:** [programs/market_data_parser/README.md](programs/market_data_parser/README.md)

**Binaries:**
- `bench-parser` - Parser performance benchmarks
- `example-binance` - Binance protocol example

**Performance:**
- Simple message: ~96ns/msg (10.4M msg/sec)
- Binance depth: ~189ns/msg (5.3M msg/sec)
- ~50x faster than Python (ujson)
- ~3x faster than C++ (RapidJSON)

### financial_engine

High-frequency trading system ("The Great Synapse") combining Zig's ultra-low latency processing with Go's networking capabilities for Alpaca API integration.

**Features:**
- Sub-microsecond latency HFT engine
- Lock-free order book implementation
- Custom zero-GC memory pools
- Fixed-point decimal arithmetic
- Alpaca paper/live trading integration
- Go bridge for network layer (CGO)
- Real-time market data processing

**Documentation:** [programs/financial_engine/README.md](programs/financial_engine/README.md)

**Zig Binaries:**
- `zig-financial-engine` - Main trading engine
- `hft-system` - HFT system with strategy engine
- `live-trading` - Live trading system
- `real-hft-system` - Real HFT with Alpaca WebSocket
- `trading-api-test` - Alpaca trading API test

**Note:** Go components require separate build with `CGO_ENABLED=1 go build` in the `go-bridge/` directory.

**Dependencies:**
- libzmq (ZeroMQ for IPC)
- libwebsockets (for real-hft-system)

### async_scheduler

Work-stealing async task scheduler for concurrent Zig applications.

**Features:**
- Chase-Lev work-stealing deque (lock-free)
- Thread pool management
- Task priorities and handles
- Async/await-style task completion
- Zero-allocation fast path (target)

**Documentation:** [programs/async_scheduler/README.md](programs/async_scheduler/README.md)

**Binaries:**
- `bench-scheduler` - Scheduler performance benchmarks

**Status:** Work in progress - core components implemented, performance optimization needed.

### zero_copy_net

io_uring-based zero-copy network stack for ultra-low latency networking.

**Features:**
- io_uring integration via `std.os.linux.IoUring`
- Lock-free buffer pool with page-aligned buffers
- TCP server with callback-based API
- Connection tracking with HashMap
- Zero-copy data path design

**Documentation:** [programs/zero_copy_net/README.md](programs/zero_copy_net/README.md)

**Binaries:**
- `tcp-echo` - TCP echo server example

**Status:** TCP server compiles and ready for testing. UDP socket needs rewrite.

**Requirements:**
- Linux kernel 5.1+ (io_uring support)

### simd_crypto

SIMD-accelerated cryptographic primitives for high-performance applications.

**Features:**
- SHA256 with AVX2/AVX-512 acceleration (planned)
- AES-NI support (planned)
- ChaCha20 SIMD implementation (planned)

**Documentation:** [programs/simd_crypto/README.md](programs/simd_crypto/README.md)

**Status:** STUBBED - Function signatures defined, implementations return placeholder values. Ready for implementation.

### memory_pool

Fixed-size memory pool allocator for predictable, ultra-low latency allocations.

**Features:**
- O(1) allocation/deallocation via free-list
- <10ns allocation, <5ns deallocation (target)
- Fixed object sizes for cache-friendly access
- Zero fragmentation

**Documentation:** [programs/memory_pool/README.md](programs/memory_pool/README.md)

**Status:** Work in progress - Core pool implementation complete, needs benchmarks and additional pool types.

### lockfree_queue

Lock-free SPSC (Single Producer Single Consumer) and MPMC (Multi Producer Multi Consumer) queues.

**Features:**
- SPSC queue with cache-line padding
- MPMC queue with atomic operations
- Wait-free fast path for producers
- Bounded capacity for predictable memory usage

**Documentation:** [programs/lockfree_queue/README.md](programs/lockfree_queue/README.md)

**Status:** Work in progress - SPSC queue complete, MPMC queue implemented.

## Requirements

- **Zig Version:** 0.16.0-dev.1303+ (minimum)
- **OS:** Linux (required for guardian_shield, chronos_engine, zig_jail), macOS/Windows (http_sentinel)
- **Dependencies:**
  - `libbpf` (for guardian_shield eBPF components)
  - `libdbus-1` (for guardian_shield and chronos_engine D-Bus integration)
  - TLS support (for http_sentinel HTTPS)
  - Linux kernel 3.17+ with seccomp support (for zig_jail)

## License

MIT License - See individual program LICENSE files for details.

```
Copyright 2025 QUANTUM ENCODING LTD
Website: https://quantumencoding.io
Contact: rich@quantumencoding.io
```

## Adding New Programs

1. Create program directory: `programs/your-program/`
2. Add `build.zig` and source code
3. Update root `build.zig` to include your program
4. Update this README

## Development

Each program maintains its own:
- Source code (`src/`)
- Build configuration (`build.zig`)
- Documentation (`README.md`)
- Examples (`examples/`)
- Tests (`tests/`)

The root build system orchestrates building all programs and collects binaries into a single `zig-out/` directory for convenience.
