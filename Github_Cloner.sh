#!/usr/bin/env bash
INPUT_FILE="$1"
LOG_FILE="github_sync.log"

touch "$LOG_FILE"
echo "Checking repositories from $INPUT_FILE..."

while IFS= read -r repo || [ -n "$repo" ]; do
  # Skip empty lines or lines that start with a '#' character (comments)
  if [[ -z "$repo" || "$repo" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  repo_name="$(basename "$repo" .git)"
  timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
  }
  echo "Processing: $repo"

  if [ -d "$repo_name" ]; then
    echo "Repository already exists: $repo_name — pulling latest changes..."
    (
      cd "$repo_name" || exit 0
      # Try pulling from main, if that fails try master
      if git pull origin main >> "../$LOG_FILE" 2>&1; then
        echo "[$(timestamp)] Pulled latest changes for $repo_name" >> "../$LOG_FILE"
      elif git pull origin master >> "../$LOG_FILE" 2>&1; then
        echo "[$(timestamp)] Pulled latest changes for $repo_name (master branch)" >> "../$LOG_FILE"
      else
        echo "[$(timestamp)] Error: failed to pull latest changes for $repo_name" >> "../$LOG_FILE"
      fi
    )
  else
    echo "Cloning $repo..."
    if git clone "$repo" >> "$LOG_FILE" 2>&1; then
      echo "[$(timestamp)] Cloned $repo" >> "$LOG_FILE"
    else
      echo "[$(timestamp)] Error: failed to clone $repo" >> "$LOG_FILE"
    fi
  fi
done < "$INPUT_FILE"
echo "Done. See $LOG_FILE for details."
