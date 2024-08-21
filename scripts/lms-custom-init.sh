#!/bin/sh
#
# Custom initialization script for the Lyrion Media Server docker container. This script will
# ensure that ffmpeg is installed. This is required to play HLS streams (i.e. SiriusXM)
# 
# Usage: drop this into the LMS config directory as 'custom-init.sh'. Ensure the 
# executable bit is set
#

apt-get update -qq
apt-get install --no-install-recommends -qy ffmpeg
