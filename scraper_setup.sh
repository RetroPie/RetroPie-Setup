#!/bin/bash
#RetroPie gamelist.xml setup
#by Nathaniel Dragon on 2017-02-04
for d in ~/RetroPie/roms/*; do
  if [ ! -f $d/gamelist.xml ]; then
    echo "Make gamelist.xml in $d"
    echo '<?xml version="1.0"?><gameList />' > $d/gamelist.xml
  else
    echo "$d already has a file."
  fi
done
