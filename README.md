# Syncpod

A script to synchronize podcast episodes on a [RockBox][1] or similar mass storage device portable player.

The directory hierarchy is expected to be maintained in `$DOWNLOAD_PATH` by something more clever than this
script. The script updates a podcasts playlist ordered by file modification time. This playlist is also used
to detect episodes that were deleted on the player when synchronizing, they are deleted from `$DOWNLOAD_PATH`.

  [1]: http://www.rockbox.org/
