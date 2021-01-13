#! /usr/bin/env bash
PREFLOG="[LOG:$BASHPID]"
PREFWRN="[WRN:$BASHPID]"
PREFERR="[ERR:$BASHPID]"
[[ ! -z "$DEBUG" ]] && echo "$PREFLOG run $0" 
if [ $# -eq 0 ]; then
  echo "$PREFERR command line contains no arguments"
  exit 1
fi
WCM_STORER=${RCLONE_REMOTE_NAME:-"wcm-storer"}
CAM_NAME=${WCM_CAM_NAME:-$(hostname)}

year=$1; month=$2; day=$3
hour=$4; minutes=$5; seconds=$6
event=$7; frame_n=$8; cam_id=$9
change_pxl=${10}
noise=${11}
marea_w=${12}; marea_h=${13}
marea_x=${14}; marea_y=${15}
event_text=${16}
filepath=${17}
movie_type_n=${18}
target_dir=${19}

dirpath=$(dirname $filepath)
subdir=${dirpath/$target_dir/}
remotedir=$CAM_NAME$subdir

[[ ! -z "$DEBUG" ]] && echo "$PREFLOG rclone copy $filepath $WCM_STORER:$remotedir" 
[[ ! -z "$filepath" ]] && [[ ! -z "$remotedir" ]] && (rclone copy $filepath $WCM_STORER:/$remotedir &) || \
  echo "$PREFERR rclone copy wrong filepath($filepath) or remotedir($remotedir)"

if [[ ! -z "$WCM_API_URI" ]]; then
  [[ ! -z "$DEBUG" ]] && echo "$PREFLOG http --ignore-stdin -f POST $WCM_API_URI/cb/motion/picture/upload/$CAM_NAME/$cam_id image@$filepath"
  http --ignore-stdin -f POST $WCM_API_URI/cb/motion/picture/upload/$CAM_NAME/$cam_id image@$filepath 2>/dev/null | jq '.object==true' | grep -q true
fi
