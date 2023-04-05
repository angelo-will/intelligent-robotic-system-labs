while true
do
	watch -d -t -g ls -lR > /dev/null
	pkill -9 argos3
	argos3 -c composite-behavior.argos &
done