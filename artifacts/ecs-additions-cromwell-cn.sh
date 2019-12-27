#!/bin/bash

# Copyright 2019 Amazon.com, Inc. or its affiliates.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#
#  3. Neither the name of the copyright holder nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
#  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
#  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
#  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
#  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
#  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
#  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.

# Modified by Xianghui Cui @Dec25,2019 to adapative to AWS China Region
# Get more info by: https://github.com/Iwillsky/cromwellcn

function error() {
    # exit with an error message
    echo "[ERROR] ($2) $1" >&2
    exit "${2:-1}"
}

function missing_image_error() {
    error "Required container image is missing: $1" 301
}

function incorrect_image_error() {
    error "Incorrect container image: $1 vs $2" 302
}

function missing_container_error() {
    error "Container is missing or could not start: $1" 303
}

function get_image_id() {
    # get the image id for a [repository[:tag]] spec
    docker images --quiet "$1"
}

function get_container_id() {
    # retrieve a container id that is based on the specified image
    local -i max_attempts=${2:-10}
    local -i attempts=0
    local id=""
    while true; do
        local id=$(docker ps --quiet --filter "ancestor=$1")
        if [[ ! -z "$id" ]]; then
            break
        fi

        sleep 1
        (( attempts++ ))

        if [[ $attempts -gt $max_attempts ]]; then
            break
        fi
    done

    echo $id
}

function is_missing_image() {
    local image=$(get_image_id "$1")
    if [[ -z "$image" ]]; then
        missing_image_error $1
    fi
    
    echo "Image found: $1"
}

function is_same_image() {
    local left=$(get_image_id "$1")
    local right=$(get_image_id "$2")

    if [ ! "$left" == "$right" ]; then
        incorrect_image_error $left $right
    fi

    echo "Images match: $1 ($left) vs $2 ($right)"
}

# install ecs-proxy
#PROXY_IMAGE="quay.io/broadinstitute/cromwell-aws-proxy:latest"
#docker pull $PROXY_IMAGE
#is_missing_image "$PROXY_IMAGE"
#docker image tag "$PROXY_IMAGE" "ecs-agent-proxy:latest"
#is_same_image "$PROXY_IMAGE" "ecs-agent-proxy:latest"

# configure to use patched ecs-agent
#PATCHED_AGENT_IMAGE="elerch/amazon-ecs-agent:latest"
#docker pull $PATCHED_AGENT_IMAGE
#is_missing_image "$PATCHED_AGENT_IMAGE"
#docker image tag "$PATCHED_AGENT_IMAGE" "amazon/amazon-ecs-agent:latest"
#is_same_image "$PATCHED_AGENT_IMAGE" "amazon/amazon-ecs-agent:latest"

# get cromwellcn assets
wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/images/proxycn.tar
docker load -i proxycn.tar
docker image tag "overlapproxycn:latest" "ecs-agent-proxy:latest"

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/images/agent.tar
docker load -i agent.tar
docker image tag "elerch/amazon-ecs-agent:latest" "amazon/amazon-ecs-agent:latest"

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/images/alinux.tar
docker load -i alinux.tar

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/images/ubuntu.tar
docker load -i ubuntu.tar

wget https://awshcls.s3.cn-northwest-1.amazonaws.com.cn/cromwellcn/images/broadgatk4.tar
docker load -i broadgatk4.tar

# you can also expand to load more *.tar resources to cut down the ready time in China Region
# ...

cd /var/cache/ecs
docker save -o ecs-agent-cromwell.tar elerch/amazon-ecs-agent
ln -fs ecs-agent-cromwell.tar ecs-agent.tar