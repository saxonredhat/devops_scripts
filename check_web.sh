project_dir=/data/deploy/scripts
date_subfix=$(date "+%Y-%m-%d_%H:%M:%S")
#check_url=${1:-"https://pan.codemax.org.cn:6443/login"}
check_url=${1:-"https://xxxxx.com/login"}
error_msg=${2:-"[告警通知]网盘异常，请及时处理！"}
ok_msg=${3:-"[恢复通知]网盘恢复正常！"}
error_time_file=${4:-"$project_dir/netdisk_error_time.txt"}
retries=10
intervals=3
dingding_token="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
[ ! -e $error_time_file ]&&echo -n 0 >$error_time_file
error_time=$(cat $error_time_file)
#ret_code=$(curl -I -m 4 -o /dev/null -s -w %{http_code} $check_url)
#对监控API多次尝试
retry_counts=0
while [ $retry_counts -lt $retries ];do
    ret_code=$(curl -I -m 4 -o /dev/null -s -w %{http_code} $check_url)
    if [ x"$ret_code" == x"200" ];then
        break
    fi
    sleep $intervals
    retry_counts=$(expr $retry_counts + 1)
    echo "共${retries}次，重试第${retry_counts}次..."
done

function dingding(){
    token=$1
    msg=$2
    curl https://oapi.dingtalk.com/robot/send?access_token=$token \
       -H 'Content-Type: application/json' \
       -d '{"msgtype": "markdown", 
        "markdown": {
	     "title": "消息",
             "text": "'$msg'"
        }
    }'

}
if [ x"$ret_code" == x"200" ];then
    echo "ok"
    #判断里面的值为非0，则发送钉钉网盘恢复
    #设置error_time=0
    if [ $error_time -ne 0 ];then
	dingding $dingding_token $date_subfix-$ok_msg
        echo -n 0 >$error_time_file
    fi
else
    echo "error"
    #判断里面的值为0，发送钉钉
    #把error_time+1
    if [ $error_time -eq 0 ];then
	dingding $dingding_token $date_subfix-$error_msg
    fi
    echo -n $(expr $error_time + 1) >$error_time_file
fi
