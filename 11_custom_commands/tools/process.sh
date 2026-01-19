#!/bin/bash
# Example processing script (like GAMESS's addomp.sh)
# This could add OpenMP directives, fix formatting, etc.

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Example: Add a comment header to the file
# In real use, this might add OpenMP directives, fix line lengths, etc.

TEMP_FILE="${FILE}.tmp"

echo "! This file was processed by process.sh" > "$TEMP_FILE"
echo "! Original source: $(basename "$FILE" .f90).src" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
cat "$FILE" >> "$TEMP_FILE"

mv "$TEMP_FILE" "$FILE"

echo "Processed: $FILE"
