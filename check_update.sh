#!/bin/bash
dir1=$(echo $1|sed 's#/$##g')
dir2=$(echo $2|sed 's#/$##g')
exclude_dir=${3:-"IsExistString"}
exclude_name="\.svn"
add_message="增加"
del_message="删除"
mfy_message="更新"
#比较dir1和dir2目录的文件不同
find $dir1 -type f|grep -Ev "$exclude_name"|grep -Ev "$exclude_dir"|while read line;do
        #判断dir2文件是否存在，如果存在，则比较文件是否一致,如果不存在，则打印不存在
        #提取不含目录的文件路径
        r_file=$(echo $line|sed "s#^$dir1##g")
        #拼接dir2所在的文件路径
        dir2_file=$(echo $dir2/$r_file)
        #判断dir2文件是否存在
        if [ -e "$dir2_file" ];then
                diff $line $dir2_file >/dev/null 2>&1
                if [ $? -ne 0 ];then
                        echo -e "\033[32m\t$mfy_message\t$r_file\033[0m"
                fi
        else
                echo -e "\033[31m\t$del_message\t$r_file\033[0m"
        fi
done|sort -r

find $dir2 -type f|grep -Ev "$exclude_name"|grep -Ev "$exclude_dir"|while read line;do
        r_file=$(echo $line|sed "s#^$dir2##g")
        dir1_file=$(echo $dir1/$r_file)
        if [ ! -e "$dir1_file" ];then
                echo -e "\033[33m\t$add_message\t$r_file\033[0m"
        fi
done
#获取dir2存在且dir1不存在的文件
