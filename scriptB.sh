echo '1. From which ip were the most requests? '
sort apache.log | awk '{print $1}' |uniq -c | sort -bgr | head -n 1
echo '2. What is the most requested page? '
sort apache.log | awk '{print $7}' |uniq -c | sort -bgr | head -n 1
echo '3. How many requests were there from each ip? '
sort apache.log | awk '{print $1}' |uniq -c | sort -bgr
echo '4. What non-existent pages were clients referred to? '
sort apache.log | awk '{print $7 " " $9}'| grep 404 |uniq  | sort -bgr |awk '{print $1}'
echo '5. What time did site get the most requests?' 
sort apache.log  | awk '{split($4,a,":");print a[2]":"a[3]":"a[4]}' | uniq -c |sort -bgr|head -n 1
echo '6. What search bots have accessed the site? (UA + IP)'
sort apache.log  | grep -e "Googlebot" -e "Mail.RU_Bot" -e "bingbot" -e "Applebot" | awk '{print $1, $7, $12, $13,$14,$15,$16}'|uniq -c| sort -bg
