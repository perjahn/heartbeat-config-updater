ls -la
if [ -f h.tar.gz ]; then
  mv h.tar.gz hold.tar.gz
fi

tar --sort=name --owner=root:0 --group=root:0 --mtime='UTC 2020-01-01' -c *.yml | gzip -n >h.tar.gz

ls -la
if [ -f hold.tar.gz ]; then
  if cmp -s h.tar.gz hold.tar.gz; then
    printf "No changes."
  else
    printf "Pushing changed file."
    git config user.email "noreply@example.com"
    git config user.name "Pack user"
    git commit h.tar.gz -m "Added new files `date`"
    git push
  fi
else
  printf "Pushing new file."
  git config user.email "noreply@example.com"
  git config user.name "Pack user"
  git add h.tar.gz
  git commit h.tar.gz -m "Added new files `date`"
  git push
fi
