#!/bin/bash
perl -ne "print if s/\\\$GLOBALS\\['FW_URL_OLD'\\] = 'http:\/\/([^']+)';/\$1/" $1
