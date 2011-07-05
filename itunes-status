state=`osascript -e 'tell application "iTunes" to player state as string'`;
#echo "iTunes is currently $state.";
if [ $state = "playing" ]; then
	artist=`osascript -e 'tell application "iTunes" to artist of current track as string'`;
	track=`osascript -e 'tell application "iTunes" to name of current track as string'`;
	#echo "Current track $artist:  $track";
	echo "$artist:  $track";
fi