###############################################################################
#  Copyright 2013 - 2018 Software AG, Darmstadt, Germany and/or its licensors
#
#   SPDX-License-Identifier: Apache-2.0
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.                                                            
#
###############################################################################

ARG BUILDER_IMAGE=store/softwareag/commandcentral-builder:10.3
ARG NODE_IMAGE=store/softwareag/commandcentral-node:10.3
ARG BASE_IMAGE=centos:7

FROM $NODE_IMAGE as node
FROM $BUILDER_IMAGE as builder

ENV SAG_HOME=/opt/softwareag

# get the managed node
COPY --from=node --chown=1724:1724 $SAG_HOME/ $SAG_HOME/

ARG REPO_PRODUCT_URL=https://sdc.softwareag.com/dataservewebM103/repository # product repository must match target release
ARG REPO_FIX_URL=https://sdc.softwareag.com/updates/prodRepo # fix repository must have fixes for the target release
ARG REPO_USERNAME=sergei.pogrebnyak@softwareag.com
ARG REPO_PASSWORD

# build-time template parameter: hello.name
ARG __hello_name=DockerHub

# Apply template.yaml, run smoke tests, cleanup
RUN $CC_HOME/provision.sh 
# && $CC_HOME/cleanup.sh

# target image
FROM $BASE_IMAGE

ENV SAG_HOME=/opt/softwareag

# expose any ports from runtimes defined in the template.yaml
EXPOSE 8092 8093

COPY --from=builder --chown=1724:1724 $SAG_HOME $SAG_HOME

# entrypoint scripts
# ADD entrypoint.sh $SAG_HOME

ENTRYPOINT $SAG_HOME/profiles/SPM/bin/console.sh
