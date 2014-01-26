#!/usr/bin/python

import sys
import re

PATTERN = re.compile(r"\$GLOBALS\['FW_URL_OLD'\] = '([^']+)';")

for line in sys.stdin:
  m = PATTERN.match(line)
  if m:
    print m.group(1)
    break
