#! /usr/bin/env bash
ls *.elm | while read filename; do elm make $filename --output site/`basename $filename .elm`.html; done
