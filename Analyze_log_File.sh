#!/bin/bash
LOGFILE="$1"

if [ ! -f "$LOGFILE" ]; then
  echo "File not found!"
  exit 1
fi

echo "Analyzing $LOGFILE..."

TOTAL_LINES=$(wc -l < "$LOGFILE")
ERROR_LINES=$(grep -c "ERROR" "$LOGFILE")
WARNING_LINES=$(grep -c "WARNING" "$LOGFILE")
Total_Lines_with_Ips=$(grep -Ec "([0-9]{1,3}\.){3}[0-9]{1,3}" "$LOGFILE" )
echo " Total lines:   $TOTAL_LINES"
echo " ERROR lines:   $ERROR_LINES"
echo " WARNING lines: $WARNING_LINES"
echo "Total Lines With Ip Addresses : $Total_Lines_with_Ips"

# Find top 5 IP addresses
echo " Top 5 IP addresses:"
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOGFILE" \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -5 \
  | awk '{print NR". "$2" - "$1" times"}'

# Extract ERROR lines into a new timestamped file
TIMESTAMP=$(date +%Y-%m-%d)
ERROR_FILE="Error_summary_${TIMESTAMP}.txt"
WARNING_FILE="Warning_summary_${TIMESTAMP}.txt"
INFO_FILE="Info_summary_${TIMESTAMP}.txt"
grep "ERROR" "$LOGFILE" > "$ERROR_FILE"
grep "WARNING" "$LOGFILE" > "$ERROR_FILE"
grep "INFO" "$LOGFILE" > "$ERROR_FILE"

echo " ERROR lines written to: $ERROR_FILE"
echo " WARNING lines written to: $WARNING_FILE"
echo " INFO lines written to: $INFO_FILE"
