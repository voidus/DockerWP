#!/bin/bash
perl -ne "print if s/\\\$GLOBALS\\['FW_URL_OLD'\\] = '([^']+)';/\$1/" $1
