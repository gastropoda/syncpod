# "private" variables
# ===================
TARGET_PATH="$MOUNT_POINT/$PODCASTS_ROOT"
# Field separator for `list_tracks()`
IFS=$'\t'

check_if_mounted() {
  if [ ! -d "$TARGET_PATH" ] ; then
    echo "'$TARGET_PATH' missing, player not mounted?"
    exit 1
  fi
}

delete_deleted() {
  echo "Searching and destroying the episodes deleted on the player"
  cat "$PLAYLIST" | while read relative ; do
    relative=${relative#/$PODCASTS_ROOT/}
    if [ ! -f "$TARGET_PATH/$relative" -a -f "$DOWNLOAD_PATH/$relative" ] ; then
      echo " [-] $relative"
      rm "$DOWNLOAD_PATH/$relative"
    fi
  done
}

list_tracks() {
  find "$1" \( -name "*.mp3" -or -name "*.ogg" \) -printf "%TY-%Tm-%Td %TH:%TM${IFS}%k${IFS}%P\n" | sort
}

copy_downloaded() {
  avail=$(df "$MOUNT_POINT" -k --output=avail | tail -1) # in 1k blocks
  avail=$((avail - ELBOW_ROOM))
  echo "Copying new podcast episodes to the player"
  list_tracks "$DOWNLOAD_PATH" | while read timestamp size path ; do
    to="$TARGET_PATH/$path"
    if [[ ! -f "$to" ]] ; then
      if [[ $avail -gt $size ]] ; then
        from="$DOWNLOAD_PATH/$path"
        echo " [+] $path"
        mkdir -p $(dirname $to)
        cp "$from" "$to"
        avail=$((avail - size))
      else
        echo " [ ] $path won't fit, skipping"
      fi
    fi
  done
}

update_playlist() {
  echo "Updating the playlist"
  list_tracks "$TARGET_PATH" | while read timestamp size path ; do
    echo "/$PODCASTS_ROOT/$path"
  done | tee "$PLAYLIST"
}


