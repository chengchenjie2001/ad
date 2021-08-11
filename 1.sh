#!/bin/sh
# 下载三方规则
#综合pc
wget -O ad1.txt https://cdn.jsdelivr.net/gh/o0HalfLife0o/list@master/ad-pc.txt
#手机
wget -O ad2.txt https://cdn.jsdelivr.net/gh/banbendalao/ADgk@latest/ADgk.txt
#anti-ad
wget -O ad3.txt https://anti-ad.net/easylist.txt
#youtube
wget -O youtube https://cdn.jsdelivr.net/gh/Ewpratten/youtube_ad_blocklist@master/blocklist.txt
#综合host
wget -O host https://cdn.jsdelivr.net/gh/StevenBlack/hosts@master/alternates/fakenews-gambling/hosts
#adaway
wget -O host1 https://cdn.jsdelivr.net/gh/AdAway/adaway.github.io@master/hosts.txt
#yhost
wget -O host2 https://cdn.jsdelivr.net/gh/VeleSila/yhosts@master/hosts
#自定义规则
wget -O ad_out.txt https://cdn.jsdelivr.net/gh/chengchenjie2001/ad_out@master/ad_out.txt

## ---------------------------------------------------处理开始------------------------------------------------------
#删除各文件无用部分
sed -i '/^!/d;1d' ad1.txt
sed -i '/^!/d' ad2.txt
sed -i '/^!/d' ad3.txt
sed -i '1,40d;s/#.*//;/^$/d' host
sed -i '/^#/d;/^$/d' host1
sed -i '/^#/d;/^$/d' host2
#合并下载文件删除不需要文件
cat ad2.txt ad3.txt |awk '!x[$0]++' > ad4.txt
rm -rf ad2.txt ad3.txt
cat host1 host2  > host3
rm -rf host1 host2
#处理host与host3
cat host > host.txt
sed -i 's/^0.0.0.0\ /||https:\/\//g' host.txt
cat host >> host.txt 
sed -i 's/^0.0.0.0\ /||http:\/\//g' host.txt
cat host3 > host1.txt
sed -i 's/^127.0.0.1\ /||https:\/\//g' host1.txt
cat host3 >> host1.txt
sed -i 's/^127.0.0.1\ /||http:\/\//g' host1.txt
cat host.txt host1.txt |awk '!x[$0]++' > hosts.txt 
rm -rf host host3 host.txt host1.txt
# 此处对hosts进行单独处理
sed -i '/localhost/d' hosts.txt
# 删除可能导致卡死的神奇规则
sed -i '/https:\/\/\*/d' hosts.txt
# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
koolproxyR_del_rule=1
while [ $koolproxyR_del_rule = 1 ];do
    del_rule=`cat hosts.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
    if [[ "$del_rule" != "" ]]; then
        sed -i "${del_rule}d" hosts.txt
    else
        koolproxyR_del_rule=0
    fi
done	
# 处理ad.txt与ad1.txt
## 删除导致崩溃的规则
sed -i '/^\$/d' ad4.txt
sed -i '/\*\$/d' ad1.txt
sed -i '/^\$/d' ad4.txt
sed -i '/\*\$/d' ad1.txt
# 将规则转化成kp能识别的https
cat ad4.txt | grep "^||" | sed 's#^||#||https://#g' >> ad4_https.txt
cat ad1.txt | grep "^||" | sed 's#^||#||https://#g' >> ad1_https.txt
# 移出https不支持规则domain=
sed -i 's/\(,domain=\).*//g' ad4_https.txt
sed -i 's/\(\$domain=\).*//g' ad4_https.txt
sed -i 's/\(domain=\).*//g' ad4_https.txt
sed -i '/\^$/d' ad4_https.txt
sed -i '/\^\*\.gif/d' ad4_https.txt
sed -i '/\^\*\.jpg/d' ad4_https.txt
sed -i 's/\(,domain=\).*//g' ad1_https.txt
sed -i 's/\(\$domain=\).*//g' ad1_https.txt
sed -i 's/\(domain=\).*//g' ad1_https.txt
sed -i '/\^$/d' ad1_https.txt
sed -i '/\^\*\.gif/d' ad1_https.txt
sed -i '/\^\*\.jpg/d' ad1_https.txt
cat ad4.txt | grep "^||" | sed 's#^||#||http://#g' >> ad4_https.txt
cat ad1.txt | grep "^||" | sed 's#^||#||http://#g' >> ad1_https.txt
cat ad4.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> ad4_https.txt
cat ad1.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> ad1_https.txt
# 源文件替换成http
cat ad4.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> ad4_https.txt
cat ad1.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> ad1_https.txt
cat ad4.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> ad4_https.txt
cat ad1.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> ad1_https.txt
cat ad4.txt | grep -i '^[0-9a-z]'| grep -i '^|http' >> ad4_https.txt
cat ad1.txt | grep -i '^[0-9a-z]'| grep -i '^|http' >> ad1_https.txt
# 删除可能导致变慢的Https规则
sed -i '/\.\*\//d' ad4_https.txt
sed -i '/\.\*\//d' ad1_https.txt
#处理YouTube广告域名
cat youtube | grep -i '^[0-9a-z]' | sed 's#^#||https://#g' >> youtube.txt
cat youtube | grep -i '^[0-9a-z]'| sed 's#^#||http://#g' >> youtube.txt
# 合多归一
cat ad4_https.txt >> ad4.txt
cat ad1_https.txt >> ad1.txt
cat ad4.txt ad1.txt youtube.txt ad_out.txt |awk '!x[$0]++' > ad.txt 
rm -rf *_https.txt ad1.txt ad4.txt youtube youtube.txt ad_out.txt
# 删除可能导致卡死的神奇规则
sed -i '/https:\/\/\*/d' ad.txt
# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
koolproxyR_del_rule=1
while [ $koolproxyR_del_rule = 1 ];do
    del_rule=`cat ad.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
    if [[ "$del_rule" != "" ]]; then
        sed -i "${del_rule}d" ad.txt
    else
        koolproxyR_del_rule=0
    fi
done	
