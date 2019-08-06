project_dir=/data/deploy/scripts
date_subfix=$(date "+%Y-%m-%d_%H:%M:%S")
error_msg=${1:-"[告警通知]数据库异常，请及时处理！"}
ok_msg=${2:-"[恢复通知]数据库恢复正常！"}
error_time_file=${3:-"$project_dir/db_error_time.txt"}
ret_code=$( /opt/mysql/bin/mysql -P3306 -h127.0.0.1 -umonitor -pxxxxx -e "select 200"|tail -1)
[ ! -e $error_time_file ]&&echo -n 0 >$error_time_file
error_time=$(cat $error_time_file)
dingding_token="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
function dingding(){
    token=$1
    msg=$2
    curl https://oapi.dingtalk.com/robot/send?access_token=$token \
       -H 'Content-Type: application/json' \
       -d '{"msgtype": "text", 
        "text": {
             "content": "'$msg'"
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
	dingding $dingding_token ${date_subfix}-$error_msg
    fi
    echo -n $(expr $error_time + 1) >$error_time_file
fi
