#!/usr/bin/env python3
"""
Comprehensive API compatibility fixer for Alpaca v3 Go SDK.
Fixes common API compatibility issues systematically.
"""
import os
import re
import glob

def fix_file(file_path):
    """Fix API compatibility issues in a single Go file."""
    print(f"Fixing {file_path}")
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Fix 1: uint32 to int for PageLimit
    content = re.sub(r'PageLimit:\s*uint32\(([^)]+)\)', r'PageLimit: int(\1)', content)
    
    # Fix 2: pos.Qty.Int64() to pos.Qty.BigInt().Int64()
    content = re.sub(r'pos\.Qty\.Int64\(\)', r'pos.Qty.BigInt().Int64()', content)
    
    # Fix 3: decimal.NewFromXXX to pointer for struct literals
    # This is more complex and needs careful handling
    
    # Fix 4: GetLatestQuote API changes
    content = re.sub(
        r's\.dataClient\.GetLatestQuote\(([^)]+)\)',
        r's.dataClient.GetLatestQuote(\1, marketdata.GetLatestQuoteRequest{})',
        content
    )
    
    # Fix 5: Remove undefined streamClient references
    content = re.sub(r'return streamClient\.Disconnect\(\)', 'return nil', content)
    
    if content != original_content:
        with open(file_path, 'w') as f:
            f.write(content)
        print(f"  ✓ Fixed {file_path}")
        return True
    else:
        print(f"  - No changes needed for {file_path}")
        return False

def main():
    """Fix all Go strategy files."""
    strategy_files = glob.glob("strategies/*.go")
    
    fixed_count = 0
    for file_path in strategy_files:
        if fix_file(file_path):
            fixed_count += 1
    
    print(f"\nFixed {fixed_count} out of {len(strategy_files)} files")

if __name__ == "__main__":
    main()