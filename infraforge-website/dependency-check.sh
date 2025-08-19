#!/bin/bash
# dependency-check.sh
# Fails if any required dependency is missing from node_modules
set -e
REQUIRED=(web-vitals)
for dep in "${REQUIRED[@]}"; do
  if ! [ -d "node_modules/$dep" ]; then
    echo "\033[0;31mERROR: Dependency '$dep' is missing. Run 'npm ci' or 'npm install'.\033[0m"
    exit 1
  fi
done

echo "\033[0;32mAll required dependencies are present.\033[0m"
