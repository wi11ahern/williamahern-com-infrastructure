#!/bin/bash
find . -type f -name "provider.tf" -prune -exec rm -rf {} \;
find . -type f -name "backend.tf" -prune -exec rm -rf {} \;
find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;