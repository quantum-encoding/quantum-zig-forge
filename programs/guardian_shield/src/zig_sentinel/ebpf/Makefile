# Makefile for Guardian Shield eBPF programs
# Compiles both syscall_counter and inquisitor

CLANG := clang
BPFTOOL := bpftool
ARCH := $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')

BPF_CFLAGS := -target bpf -D__TARGET_ARCH_$(ARCH) -O2 -g -Wall
BPF_INCLUDES := -I. -I/usr/include -I/usr/include/$(shell uname -m)-linux-gnu

PROGS := syscall_counter.bpf.o grimoire-oracle.bpf.o

.PHONY: all clean

all: $(PROGS)

%.bpf.o: %.bpf.c
	$(CLANG) $(BPF_CFLAGS) $(BPF_INCLUDES) -c $< -o $@
	@echo "✓ Compiled: $@"

clean:
	rm -f *.bpf.o
	@echo "✓ Cleaned BPF objects"

install: all
	@echo "✓ BPF programs compiled and ready"
