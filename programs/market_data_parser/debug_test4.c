#include <stdio.h>
#include <string.h>
#include <market_data_core.h>

int main() {
    const char* binance_json =
        "{\"e\":\"depthUpdate\",\"E\":1699999999,\"s\":\"BTCUSDT\","
        "\"U\":123456,\"u\":123457,"
        "\"b\":[[\"50000.00\",\"1.5\"],[\"49999.00\",\"2.0\"]],"
        "\"a\":[[\"50001.00\",\"1.0\"],[\"50002.00\",\"0.5\"]]}";
    
    MDC_Parser* parser = mdc_parser_create((const uint8_t*)binance_json, strlen(binance_json));
    
    char value_buf[64];
    size_t value_size;
    
    // Find "e"
    MDC_Error err = mdc_parser_find_field(parser, (const uint8_t*)"e", 1, (uint8_t*)value_buf, sizeof(value_buf), &value_size);
    printf("Find 'e': err=%d\n", err);
    
    // Find "s"
    err = mdc_parser_find_field(parser, (const uint8_t*)"s", 1, (uint8_t*)value_buf, sizeof(value_buf), &value_size);
    printf("Find 's': err=%d\n", err);
    
    // Reset and find "E"
    mdc_parser_reset(parser);
    err = mdc_parser_find_field(parser, (const uint8_t*)"E", 1, (uint8_t*)value_buf, sizeof(value_buf), &value_size);
    printf("Find 'E' (after reset): err=%d\n", err);
    if (err == 0) {
        value_buf[value_size] = '\0';
        printf("   Value: '%s'\n", value_buf);
    }
    
    mdc_parser_destroy(parser);
    return 0;
}
