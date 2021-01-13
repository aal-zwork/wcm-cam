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

[[ -z "$filepath" ]] && (echo "$PREFERR video rclone copy wrong filepath is ''"; exit)

dirpath=$(dirname $filepath)
subdir=${dirpath/$target_dir/}
[[ -z "$subdir" ]] && (echo "$PREFERR video rclone copy wrong subdir is ''"; exit)

remotedir=$CAM_NAME$subdir
[[ -z "$remotedir" ]] && (echo "$PREFERR video rclone copy wrong remotedir is ''"; exit)

# VIDEO COPY
[[ ! -z "$DEBUG" ]] && echo "$PREFLOG video rclone copy $filepath $WCM_STORER:/$remotedir" 
rclone copy $filepath $WCM_STORER:/$remotedir &


# AUDIO COPY
[[ -z "$WCM_AUDIO" ]] && exit 0
audio_hw_name_var="WCM_AUDIO_$cam_id"
audio_hw=${!audio_hw_name_var:-"plughw:0"}
ps_line=$(ps aux | grep -e [a]record.-D.$audio_hw.*.wav)
arecord_pid=$(echo $ps_line | awk '{print $1}')
if [[ -z "$arecord_pid" ]]; then echo "$PREFERR kill arecord_pid is ''"; else
  [[ ! -z "$DEBUG" ]] && echo "$PREFLOG kill $arecord_pid &> /dev/null"
  kill $arecord_pid &> /dev/null

  #audiofilepath=$(echo $ps_line | awk '{print $11}')
  audiofilepath=$filepath.wav
  if [[ -z "$audiofilepath" ]]; then echo "$PREFERR audio rclone copy  wrong audiofilepath is ''"; else
    [[ ! -z "$DEBUG" ]] && echo "$PREFLOG (sleep 5; kill -9 $arecord_pid > /dev/null; rclone copy $audiofilepath $WCM_STORER:/$remotedir) &"
    (sleep 5; kill -9 $arecord_pid &> /dev/null; rclone copy $audiofilepath $WCM_STORER:/$remotedir) &
  fi
fi
