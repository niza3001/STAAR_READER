for f in *.aiff
do
afinfo -x $f | grep '<duration' | cut -f2 -d">"|cut -f1 -d"<" >> normalDurations.txt
done