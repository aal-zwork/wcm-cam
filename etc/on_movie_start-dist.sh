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

subdir=/$cam_id/$year/$month/$day/$hour
remotedir=$CAM_NAME$subdir

if [[ -z "$remotedir" ]]; then echo "$PREFERR mkdir remotedir is ''"; else
  [[ ! -z "$DEBUG" ]] && echo "$PREFLOG rclone mkdir $WCM_STORER:/$remotedir" 
  rclone mkdir $WCM_STORER:/$remotedir &
fi

# AUDIO REСORD
[[ -z "$WCM_AUDIO" ]] && exit 0
audio_hw_name_var="WCM_AUDIO_$cam_id"
audio_hw=${!audio_hw_name_var:-"plughw:0"}
ps_line=$(ps aux | grep -e [a]record.-D.$audio_hw.*.wav)
arecord_pid=$(echo $ps_line | awk '{print $1}')
if [[ ! -z "$arecord_pid" ]]; then 
  echo "$PREFWRN kill -9 $arecord_pid &> /dev/null" 
  kill -9 $arecord_pid &> /dev/null 
fi
if [[ -z "$audio_hw" ]]; then echo "$PREFWRN arecord audio_hw for cam($cam_id) is ''"; else
  #audiofilepath=$target_dir$subdir/$hour$minutes$seconds-$event.wav
  audiofilepath=$filepath.wav
  if [[ -z "$audiofilepath" ]]; then echo "$PREFERR arecord audiofilepath is ''"; else
    [[ ! -z "$DEBUG" ]] && echo "$PREFLOG mkdir -p $target_dir$subdir; (arecord -D $audio_hw -r 16000 -f S16_LE $audiofilepath &)" 
    mkdir -p $target_dir$subdir;
    arecord -D $audio_hw -r 16000 -f S16_LE $audiofilepath &
  fi
fi
