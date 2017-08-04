FROM centos:centos7

MAINTAINER jonesc47@gene.com

LABEL "project"="gRED HPC"

ENV LUAROCKS_VER 2.4.2
ENV LUA_VER 5.1.4
ENV EB_VER 3.3.0
ENV LMOD_VER 7.6
ENV APPS_PREFIX /gstore/apps

#add user
RUN groupadd gredsys_pg -g 2376
RUN useradd gredsys -u 739146 -g gredsys_pg

#set the timezone
RUN /bin/rm /etc/localtime ; ln -sv /usr/share/zoneinfo/US/Pacific /etc/localtime

#setup the system
RUN yum makecache fast
RUN yum groupinstall "Development Tools" -y
RUN yum install -y build-essential libtool autotools-dev automake autoconf git screen vim wget python3

#add create repo to make sure we can deploy the repos
RUN yum install -y epel-release
RUN yum install -y createrepo

#packages to mimic LSOE builds, per pRED TOP
RUN yum install -y emacs emacs-common \
                   libotf netpbm netpbm-progs \
                   readline readline-devel \
                   xterm xorg-x11-xauth xorg-x11-server-utils \
                   xorg-x11-server-common \
                   xorg-x11-server-Xorg xorg-x11-proto-devel \
                   libXt-devel libX11-devel gcc-plugin-devel \
                   ruby-devel gcc make rpm-build rubygems \
                   openssl-devel libssl-dev libopenssl-devel

# install lua
RUN yum install lua-devel lua tcl-devel tcl -y
RUN yum clean all

##install luarocks
RUN mkdir -vp --mode 2775 ${APPS_PREFIX}
WORKDIR /tmp/
RUN wget http://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VER}.tar.gz
RUN tar -xzvf luarocks-${LUAROCKS_VER}.tar.gz

WORKDIR /tmp/luarocks-${LUAROCKS_VER}
RUN ./configure --prefix=${APPS_PREFIX}/luarocks/${LUAROCKS_VER} ; \
    make clean ; \
    make build ; \
    make install

WORKDIR ${APPS_PREFIX}
COPY luarocks.sh /etc/profile.d/luarocks.sh
COPY luarocks.csh /etc/profile.d/luarocks.csh

ENV LUAROCKS_PREFIX "${APPS_PREFIX}/luarocks/${LUAROCKS_VER}"
ENV PATH "$PATH:${LUAROCKS_PREFIX}/bin/:${LUAROCKS_PREFIX}/lib/"
ENV LUA_PATH "${LUAROCKS_PREFIX}/share/lua/5.1/?.lua;${LUAROCKS_PREFIX}/share/lua/5.1/?/init.lua;;"
ENV LUA_CPATH "${LUAROCKS_PREFIX}/lib/lua/5.1/?.so;;"

RUN luarocks install luaposix
RUN luarocks install luafilesystem

#install Lmod
WORKDIR /tmp/
RUN git clone https://github.com/TACC/Lmod.git
WORKDIR /tmp/Lmod
RUN git checkout tags/${LMOD_VER} -b ${LMOD_VER}
RUN ./configure --prefix=${APPS_PREFIX} --with-siteName=gRED
RUN make install

COPY z00_lmod.sh ${APPS_PREFIX}/lmod/lmod/init/profile
RUN ln -s ${APPS_PREFIX}/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
RUN ln -s ${APPS_PREFIX}/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh

COPY lmod/libexec/SitePackage.lua ${APPS_PREFIX}/lmod/lmod/libexec/
RUN mkdir -vp ${APPS_PREFIX}/lmod/etc/

#Install EasyBuild requirements
###### ###### ###### ###### ###### ######
RUN gem install --no-ri --no-rdoc fpm

ENV PATH "$PATH:${LUAROCKS_PREFIX}/bin/:${LUAROCKS_PREFIX}/lib/"

#setup easy build, chown the whole path to the user
RUN chown -cR gredsys.gredsys_pg ${APPS_PREFIX}/.. /tmp/Lmod

# Run as gredsys
USER gredsys

WORKDIR /tmp/
ENV MODULEPATH=${APPS_PREFIX}/modules:$MODULEPATH

#parameter for using fpm
ENV EASYBUILD_PREFIX=${APPS_PREFIX}

#install source directories
ENV EB_BOOTSTRAP_SOURCEPATH=/tmp/eb_source
RUN mkdir -vp ${EB_BOOTSTRAP_SOURCEPATH}
COPY source/easybuild-easyconfigs-${EB_VER}.tar.gz ${EB_BOOTSTRAP_SOURCEPATH}
COPY source/easybuild-framework-${EB_VER}.tar.gz ${EB_BOOTSTRAP_SOURCEPATH}
COPY source/easybuild-easyblocks-${EB_VER}.tar.gz ${EB_BOOTSTRAP_SOURCEPATH}
COPY source/bootstrap_eb.py ${EB_BOOTSTRAP_SOURCEPATH}

COPY eb_setup.sh /tmp
RUN bash /tmp/eb_setup.sh

#setup final workdir
RUN mkdir -vp /home/gredsys
RUN chown -cR gredsys.gredsys_pg /home/gredsys

WORKDIR /home/gredsys

#### End of File, if this is missing the file has been truncated
