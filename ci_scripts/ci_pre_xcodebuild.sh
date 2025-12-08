#!/bin/sh

# Fail fast on errors, unset variables, and pipeline failures
set -euo pipefail

# -----------------------------------------------------------------------------
#  ci_pre_xcodebuild.sh
#  Purpose: Prepare environment before Xcode build in Xcode Cloud.
#  - Validates required environment variables
#  - Ensures destination directory exists
#  - Writes a Secrets.json file with properly escaped JSON
#  - Uses absolute paths based on CI_PRIMARY_REPOSITORY_PATH
# -----------------------------------------------------------------------------

echo "Stage: PRE-Xcode Build is activated .... "

# Resolve repository root (Xcode Cloud sets CI_PRIMARY_REPOSITORY_PATH)
REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(pwd)}"
cd "$REPO_ROOT"

# Validate required environment variables (fail with a clear message if missing)
: "${GOOGLE_CLIENT_ID:?Environment variable GOOGLE_CLIENT_ID is not set}"
: "${GOOGLE_URL_SCHEME:?Environment variable GOOGLE_URL_SCHEME is not set}"

# Define destination paths
TARGET_DIR="ToDoNotes/SupportingFiles"
TARGET_FILE="$TARGET_DIR/Secrets.json"

# Ensure destination directory exists
mkdir -p "$TARGET_DIR"

# Prefer python3 for safe JSON serialization; fallback to jq if available
if command -v /usr/bin/python3 >/dev/null 2>&1; then
  echo "Writing Secrets.json via python3 ..."
  /usr/bin/python3 - <<'PY' > "$TARGET_FILE"
import json, os, sys

data = {
    "GOOGLE_CLIENT_ID": os.environ.get("GOOGLE_CLIENT_ID", ""),
    "GOOGLE_URL_SCHEME": os.environ.get("GOOGLE_URL_SCHEME", "")
}
json.dump(data, sys.stdout, ensure_ascii=False)
sys.stdout.write("\n")
PY
elif command -v jq >/dev/null 2>&1; then
  echo "Writing Secrets.json via jq ..."
  jq -n \
    --arg GOOGLE_CLIENT_ID "$GOOGLE_CLIENT_ID" \
    --arg GOOGLE_URL_SCHEME "$GOOGLE_URL_SCHEME" \
    '{GOOGLE_CLIENT_ID:$GOOGLE_CLIENT_ID, GOOGLE_URL_SCHEME:$GOOGLE_URL_SCHEME}' > "$TARGET_FILE"
else
  echo "ERROR: Neither python3 nor jq is available to safely generate JSON." >&2
  echo "Please ensure /usr/bin/python3 or jq is installed in the CI environment." >&2
  exit 1
fi

# Confirm result
if [ -s "$TARGET_FILE" ]; then
  echo "Wrote Secrets.json file at $TARGET_FILE"
else
  echo "ERROR: Secrets.json was not created or is empty." >&2
  exit 1
fi

echo "Stage: PRE-Xcode Build is DONE .... "

exit 0
