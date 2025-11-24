package main

/*
#include "synapse_bridge.h"
*/
import "C"
import "fmt"
import "reflect"

func main() {
	var packet C.MarketPacket
	
	// Use reflection to see actual field names
	t := reflect.TypeOf(packet)
	fmt.Printf("MarketPacket has %d fields:\n", t.NumField())
	
	for i := 0; i < t.NumField(); i++ {
		field := t.Field(i)
		fmt.Printf("  [%d] %s (type: %v)\n", i, field.Name, field.Type)
	}
}