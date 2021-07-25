set -e
date --rfc-3339 seconds

if [ -d heartbeat-config ]; then
  rm -rf heartbeat-config
fi
giturl=git@github.com:perjahn/heartbeat-config-updater
#echo "Cloning repo $giturl"
git clone "$giturl" --depth 1 --single-branch --no-tags
cd heartbeat-config

if [ "$#" -eq 1 ]; then
  slackurl=https://hooks.slack.com/services/$1
fi

# todo: remove missing files

for filename in *.yml
do
  targetfile="/etc/heartbeat/monitors.d/$filename"
  if [ -f $targetfile ]; then
    if cmp -s $filename $targetfile; then
      echo "Identical file: '$filename'"
      rm $filename
    else
      echo "Replacing: '$filename' -> '$targetfile'"
      if [ $slackurl ]; then
        msg='{"text": "'`hostname`' <!date^'`date +%s`'^{date_num} {time_secs}| >. Replacing: '$filename'\n```'`diff $targetfile $filename | sed ':a;N;$!ba;s/\n/\\n/g'`'```"}'
        curl -X POST -H "Content-Type: application/json" -d "$msg" $slackurl
      fi
      mv $filename $targetfile
    fi
  else
    echo "New file: '$filename' -> '$targetfile'"
    if [ $slackurl ]; then
      msg='{"text": "'`hostname`' <!date^'`date +%s`'^{date_num} {time_secs}| >. New file: '$filename'"}'
      curl -X POST -H "Content-Type: application/json" -d "$msg" $slackurl
    fi
    mv $filename $targetfile
  fi
done

cd ..
rm -rf heartbeat-config
