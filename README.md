# elm-scrapbook

## Installation

    elm package install

To generate the html files to be served:

    ls *.elm | while read filename; do elm make $filename --output site/`basename $filename .elm`.html; done


