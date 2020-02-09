#*******************************************************************************
#    (c) 2020 ZondaX GmbH
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#*******************************************************************************
FROM ubuntu:18.04

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y bison flex sed wget curl cvs subversion git-core coreutils unzip texi2html texinfo docbook-utils gawk python-pysqlite2 diffstat help2man make gcc build-essential g++ desktop-file-utils chrpath libxml2-utils xmlto docbook bsdmainutils iputils-ping cpio python-wand python-pycryptopp python-crypto \
    libsdl1.2-dev xterm corkscrew device-tree-compiler mercurial u-boot-tools libarchive-zip-perl \
    ncurses-dev bc linux-headers-generic gcc-multilib libncurses5-dev libncursesw5-dev lrzsz dos2unix lib32ncurses5 repo libssl-dev

# Other useful packages
RUN apt-get update && \
    apt-get -y install repo ccache sudo wget cpio locales gdisk tmux zsh

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8 
RUN chsh -s $(which zsh)

####################################
####################################
# Create zondax user
RUN adduser --disabled-password --gecos "" -u 1000 --shell /usr/bin/zsh zondax
RUN echo "zondax ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/zondax
USER zondax

ADD entrypoint.sh /home/zondax/entrypoint.sh
RUN mkdir -p /home/zondax/shared

RUN git config --global user.email "info@zondax.ch"
RUN git config --global user.name "zondax"
RUN git config --global color.ui true

ENV ZSH_THEME agnoster
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ""  --unattended
RUN cd $HOME; \
    git clone https://github.com/gpakosz/.tmux.git; \
    ln -s -f .tmux/.tmux.conf ; \
    cp .tmux/.tmux.conf.local .

RUN echo "alias stm='$HOME/shared/setup_stm.sh'" >> $HOME/.zshrc

####################################
####################################

# START SCRIPT
ENTRYPOINT ["/home/zondax/entrypoint.sh"]
