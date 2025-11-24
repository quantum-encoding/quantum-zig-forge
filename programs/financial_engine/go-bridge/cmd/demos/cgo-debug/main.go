package main

/*
#include "synapse_bridge.h"
*/
import "C"
import "fmt"
import "unsafe"

func main() {
	var packet C.MarketPacket
	fmt.Printf("MarketPacket size: %d bytes\n", C.sizeof_MarketPacket)
	fmt.Printf("Packet fields:\n")
	fmt.Printf("  timestamp_ns: offset %d\n", unsafe.Offsetof(packet.timestamp_ns))
	
	// This will show us what CGO actually generates
}