#!/bin/bash

red='\e[91m'
green='\e[92m'
none='\e[0m'
_red() { echo -e  -e ${red}$*${none}; }
_green() { echo -e  -e ${green}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e  -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

while true
do

# Logo
curl -s https://raw.githubusercontent.com/skyMetaverse/logo/main/logo.sh | bash

source ~/.profile

PS3='选择一个操作 '
options=(
"安装环境" 
"安装节点" 
"重装节点"
"查看节点同步状态" 
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
                   
"安装环境")
echo -e  "================================================================================================================="
echo -e  "                                       ${green}准备开始${none}"
echo -e  "================================================================================================================="

sudo apt update && sudo apt upgrade -y && \
sudo apt install curl jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
sleep 3
# Check Docker installed
docker -v
if [ $? -eq  0 ]; then
    echo -e  "================================================================================================================="
    echo -e  "                                       ${green}Docker已安装-版本：`docker -v`${none}"
    echo -e  "================================================================================================================="
else
    echo -e  "================================================================================================================="
    echo -e  "                                       ${green}安装Docker${none}"
    echo -e  "================================================================================================================="
    curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh && systemctl enable docker && systemctl start docker 
    sleep 2
    echo -e  "                                       ${green}Docker安装成功-版本：`docker -v`{none}"
fi
# Check docker-compose installed
docker-compose -v
if [ $? -eq  0 ]; then
    echo -e  "================================================================================================================="
    echo -e  "                                       ${green}docker-compose已安装-版本：`docker-compose -v`${none}"
    echo -e  "================================================================================================================="
else
    echo -e  "================================================================================================================="
    echo -e  "                                       ${green}安装Ddocker-compose${none}"
    echo -e  "================================================================================================================="
    curl -L https://github.com/docker/compose/releases/download/v2.10.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    sleep 2
    echo -e  "                                       ${green}docker-compose安装成功-版本：`docker-compose -v`${none}"
fi

echo -e  "================================================================================================================="
echo -e  "                                       ${green}服务器环境已安装完成!${none}"
echo -e  "================================================================================================================="
break
;;
            
"安装节点")
echo -e  "================================================================================================================="
echo -e  "                                       ${green}输入节点的名称:${none}"
echo -e  "================================================================================================================="
                
read nodeName

echo -e  "================================================================================================================="
echo -e  "                                       ${green}输入钱包地址:${none}"
echo -e  "================================================================================================================="
               
read walletAddress

echo -e  "================================================================================================================="
echo -e  "                                       ${green}输入绘图大小(最大100G,必须加上单位):${none}"
echo -e  "================================================================================================================="

read plotSize

echo -e  "================================================================================================================="
echo -e  "                                       ${green}节点安装开始${none}"
echo -e  "================================================================================================================="

sudo mkdir ~/subspace-docker
pushd ~/subspace-docker
sudo wget -O docker-compose.yml https://raw.githubusercontent.com/skyMetaverse/subspace-docker/main/dokcer-compose.yml.bak
sed -i "s/INSERT_YOUR_ID/$nodeName/g" docker-compose.yml
sed -i "s/WALLET_ADDRESS/$walletAddress/g" docker-compose.yml
sed -i "s/PLOT_SIZE/$plotSize/g" docker-compose.yml
sudo docker-compose pull
sudo docker-compose up -d
sleep 3

echo -e  "================================================================================================================="
echo -e  "                                       ${green}节点安装成功!${none}"
echo -e  "================================================================================================================="
break
;;

"重装节点")
echo -e  "================================================================================================================="
echo -e  "                                       ${green}输入新节点的名称:${none}"
echo -e  "================================================================================================================="
                
read nodeName

echo -e  "================================================================================================================="
echo -e  "                                       ${green}输入新钱包地址:${none}"
echo -e  "================================================================================================================="
               
read walletAddress

echo -e  "================================================================================================================="
echo -e  "                                       ${green}输入新绘图大小((最大100G,必须加上单位)):${none}"
echo -e  "================================================================================================================="

read plotSize

echo -e  "================================================================================================================="
echo -e  "                                       ${green}节点重装开始${none}"
echo -e  "================================================================================================================="

pushd ~/subspace-docker
docker-compose ps
if [ $? -eq  2 ]; then
    docker-compose down -v
    rm -rf docker-compose.yml
    sudo wget -O docker-compose.yml https://raw.githubusercontent.com/skyMetaverse/subspace-docker/main/dokcer-compose.yml.bak
    sed -i "s/INSERT_YOUR_ID/$nodeName/g" docker-compose.yml
    sed -i "s/WALLET_ADDRESS/$walletAddress/g" docker-compose.yml
    sed -i "s/PLOT_SIZE/$plotSize/g" docker-compose.yml
    sudo docker-compose up -d
    sleep 3
else
    docker-compose down -v
    rm -rf docker-compose.yml
    sudo wget -O docker-compose.yml https://raw.githubusercontent.com/skyMetaverse/subspace-docker/main/dokcer-compose.yml.bak
    sed -i "s/INSERT_YOUR_ID/$nodeName/g" docker-compose.yml
    sed -i "s/WALLET_ADDRESS/$walletAddress/g" docker-compose.yml
    sed -i "s/PLOT_SIZE/$plotSize/g" docker-compose.yml
    sudo docker-compose up -d
    sleep 3
fi

echo -e  "================================================================================================================="
echo -e  "                                       ${green}节点重装成功!${none}"
echo -e  "================================================================================================================="
break
;;

"查看节点同步状态")
echo -e  "==============================================================================================================================================================================="
echo -e  "                                       ${green}节点状态为false时，代表同步成功${none}"
echo -e  "${green}也可以通过https://telemetry.subspace.network/#list/0x43d10ffd50990380ffe6c9392145431d630ae67e89dbc9c014cac2a417759101 查看同步状态"
echo -e  "==============================================================================================================================================================================="
echo -e  "                                       ${red}节点状态 = ${none}$(docker exec -it subspace-docker-node-1 curl -s -X POST http://localhost:9933 -H "Content-Type: application/json" --data '{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}' | jq .result.isSyncing)"
break
;;

"退出")
exit
;;

*) echo "invalid option $REPLY";;
esac
done
done
