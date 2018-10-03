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
cp -R public.zip ~/CIT480/matabit-infrastructure/Ansible/roles/hugo/templates
echo

echo
printf "============================\n"
printf "Blog has been built and zipped\n" 
printf "============================\n"
echo
