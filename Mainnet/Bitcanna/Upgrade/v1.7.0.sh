#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=8771420
VERSION=v1.7.0
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
        height=$(bcnad status |& jq -r ."SyncInfo"."latest_block_height")
        if ((height>=$BLOCK)); then

                cd $HOME
                wget https://github.com/BitCannaGlobal/bcna/releases/download/$VERSION/bcna_linux_amd64.tar.gz
                tar -xvzf bcna_linux_amd64.tar.gz
                rm -rf bcna_linux_amd64.tar.gz
                chmod +x bcnad
                sudo mv bcnad $(which bcnad)
                sudo systemctl restart bcnad && journalctl -fu bcnad -o cat

                for (( timer=60; timer>0; timer-- )); do
                        printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
                        sleep 1
                done
                height=$(bcnad status |& jq -r ."SyncInfo"."latest_block_height")
                if ((height>$BLOCK)); then
                        echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
                fi
                bcnad version --long | head
                break
        else
                echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) blocks left)"
        fi
        sleep 5
done