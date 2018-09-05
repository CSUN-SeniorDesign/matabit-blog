#!/bin/bash 
printf "============================\n"
printf "Running hugo to build blog pages \n"
printf "============================\n"
hugo 
echo
printf "============================\n"
printf "Blog built \n"
printf "============================\n"
echo
printf "============================\n"
printf "Deploying to EC2 instance\n"
printf "============================\n"
echo
zip -r public.zip public/ 
rsync -azP public.zip ubuntu@matabit.org:/home/ubuntu/hugo/
echo
ssh ubuntu@matabit.org << EOF
  sudo unzip -o hugo/public.zip -d /var/www/matabit-blog
  sudo chown -hR www-data:www-data /var/www/matabit-blog
EOF
echo
printf "============================\n"
printf "Blog has been deployed\n" 
printf "============================\n"
echo