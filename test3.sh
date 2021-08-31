
# echo please enter your name:
# read name
name=$1
echo hi ${name}! >> test.txt
echo 
echo the time is $(date +"%T") >> test.txt
echo 
echo today is $(date +"%A %B %d" ) >> test.txt

