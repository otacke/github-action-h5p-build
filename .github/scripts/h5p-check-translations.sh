#!/bin/bash

# Check for missing translation directory
if [ ! -d "./language" ]; then
  echo "No language directory found"
  exit 0
fi

# Install H5P CLI tool
npm i -g h5p

# Color palette
COLOR_OFF='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'

# Keep track of errors
ERROR_COUNT=0

# Remember current library name
LIBRARY_DIR=$(pwd | rev | cut -d "/" -f1 | rev)

# Check JSON validity.
check_json_validity() {
  if ! json_pp < "$entry" &> /dev/null; then
    echo "Translation file does not seem to be valid JSON"
    json_pp < "$entry" || true
    (( ERROR_COUNT=ERROR_COUNT + 1 ))
  fi
}

# Check unsafe translations
check_unsafe_translations() {
  UNSAFE_TRANSLATIONS_COUNT=$(echo "$RESULT" | grep -c "^Unsafe translation$")

  if (( UNSAFE_TRANSLATIONS_COUNT == 0 )); then
    (( ERROR_COUNT=ERROR_COUNT + 1 ))
  else
    ISSUE_COUNT=$(echo "$RESULT" | wc -l)
    (( ISSUE_COUNT=(ISSUE_COUNT - 1) / 2 ))

    if (( ISSUE_COUNT - EXPECTED_UNSAFE_TRANSLATIONS >= UNSAFE_TRANSLATIONS_COUNT )); then
      (( ERROR_COUNT=ERROR_COUNT + 1 ))
    fi
  fi
}

for entry in "./language"/*; do
  BASENAME=$(basename "$entry")
  if [[ $BASENAME == "*" ]]; then
    continue
  fi

  echo -e "${COLOR_BLUE}Checking $BASENAME${COLOR_OFF}"

  check_json_validity

  cd ..

  # Check translation validity
  LANGUAGE_CODE=$(basename "$entry" .json)

  RESULT=$(npx h5p check-translations -diff "$LANGUAGE_CODE" "$LIBRARY_DIR")
  echo "$RESULT"

  if (( $(echo "$RESULT" | grep -c "FAILED") != 0 )); then
    # ${{ inputs.expected-unsafe-translations }} will be replaced by github action
    EXPECTED_UNSAFE_TRANSLATIONS=${{ inputs.expected-unsafe-translations }}

    if [[ $EXPECTED_UNSAFE_TRANSLATIONS ]]; then
      check_unsafe_translations
    else
      (( ERROR_COUNT=ERROR_COUNT + 1 ))
    fi
  fi

  cd - > /dev/null || continue
done

if (( ERROR_COUNT != 0 )); then
  echo -e "${COLOR_RED}Some translations seem to contain errors${COLOR_OFF}"
  exit 1
else
  exit 0
fi
