# request directory containing photos to compress
dir=$(zenity --file-selection --directory --title="Choissisez le dossier contenant les photos à compresser");
[ -z "$dir" ] && exit 0;
# create destinqtion directory, if needed
newDir="${dir}_1280"
mkdir -p "$newDir";
# determine number of files
cd "$dir";
nbFiles=0
for fil in * **/*; do
  if [ -f "$fil" ]; then
    nbFiles=$(($nbFiles+1))
  fi
 done
nbFilesCompressed=0;
# loop through photos
for fil in * **/*; do
  if [ -f "$fil" ]; then
    # update progress bar
    echo $(($nbFilesCompressed*100/$nbFiles));
    nbFilesCompressed=$(($nbFilesCompressed+1));
    # create subdirectory (if necessary)
    subDir="$(dirname "$fil")"
    mkdir -p "$newDir/$subDir"
    # check extension
    ext=$(echo ${fil##*.} | tr '[:upper:]' '[:lower:]')
    if [ "$ext" = "jpg" ] || [ "$ext" = "jpeg" ] || [ "$ext" = "png" ]; then
      # convert image
      echo "# Compression de $fil"
      CMD="convert '$fil' -resize 1280x1280\> '$newDir/$fil'";
      eval "$CMD"
    elif [ "$ext" = "mov" ] || [ "$ext" = "mp4" ] || [ "$ext" = "avi" ]; then
      # convert video
      RES=$(avconv -i "$fil" 2>&1 | egrep ' [0-9]*x[0-9]* ' | sed 's/.* \([0-9]*x[0-9]*\) .*/\1/')
      RESW=$(echo "$RES" | awk -F 'x' '{print $1}')
      RESH=$(echo "$RES" | awk -F 'x' '{print $2}')
      NRESH=450
      echo "# Compression de $fil: ${NRESW}x${NRESH}"
      NRESW=$(echo "" | awk '{printf("%d\n", '"$NRESH"'/'"$RESH"'*'"$RESW"')}')
      CMD="avconv -i '$fil' -threads auto -s ${NRESW}x${NRESH} -vcodec mpeg4 -acodec mp3 -b 3000k -r 30 -y '$newDir/$fil'"
      eval "$CMD"
    else
      # copy file
      echo "# Copie de $fil"
      CMD="cp '$fil' '$newDir/$fil'";
      eval "$CMD"
    fi
    # keep date
    # touch -d "$(date +"%Y-%m-%d %H:%M:%S" -r "$fil")" "$newDir/$fil"
  fi
done |
zenity --progress --title="Progression" --percentage=0 --auto-close 
