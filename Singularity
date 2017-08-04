bootstrap:docker
From:centos:centos7

%post
# jonesc47@gene.com
# "project"="gRED HPC"

export LUAROCKS_VER=2.4.2
echo "export LUAROCKS_VER=2.4.2" >> /environment
export LUA_VER=5.1.4
echo "export LUA_VER=5.1.4" >> /environment
export EB_VER=3.3.0
echo "export EB_VER=3.3.0" >> /environment
export LMOD_VER=7.6
echo "export LMOD_VER=7.6" >> /environment
export APPS_PREFIX=/gstore/apps
echo "export APPS_PREFIX=/gstore/apps" >> /environment

groupadd gredsys_pg -g 2376
useradd gredsys -u 739146 -g gredsys_pg

/bin/rm /etc/localtime ; ln -sv /usr/share/zoneinfo/US/Pacific /etc/localtime
yum makecache fast
yum groupinstall "Development Tools" -y
yum install -y build-essential libtool autotools-dev automake autoconf git screen vim wget python3
yum install -y epel-release
yum install -y createrepo
yum install -y emacs emacs-common \
                   libotf netpbm netpbm-progs \
                   readline readline-devel \
                   xterm xorg-x11-xauth xorg-x11-server-utils \
                   xorg-x11-server-common \
                   xorg-x11-server-Xorg xorg-x11-proto-devel \
                   libXt-devel libX11-devel gcc-plugin-devel \
                   ruby-devel gcc make rpm-build rubygems \
                   openssl-devel libssl-dev libopenssl-devel

yum install lua-devel lua tcl-devel tcl -y
yum clean all

mkdir -vp --mode 2775 ${APPS_PREFIX}

cd /tmp/
wget http://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VER}.tar.gz
tar -xzvf luarocks-${LUAROCKS_VER}.tar.gz
cd /tmp/luarocks-${LUAROCKS_VER}
./configure --prefix=${APPS_PREFIX}/luarocks/${LUAROCKS_VER} ; \
    make clean ; \
    make build ; \
    make install

cd ${APPS_PREFIX}
cp luarocks.sh /etc/profile.d/luarocks.sh
cp luarocks.csh /etc/profile.d/luarocks.csh

export LUAROCKS_PREFIX=${APPS_PREFIX}/luarocks/${LUAROCKS_VER}
echo "export LUAROCKS_PREFIX=${APPS_PREFIX}/luarocks/${LUAROCKS_VER}" >> /environment
export PATH=$PATH:${LUAROCKS_PREFIX}/bin/:${LUAROCKS_PREFIX}/lib/
echo "export PATH=$PATH:${LUAROCKS_PREFIX}/bin/:${LUAROCKS_PREFIX}/lib/" >> /environment
export LUA_PATH=${LUAROCKS_PREFIX}/share/lua/5.1/?.lua;${LUAROCKS_PREFIX}/share/lua/5.1/?/init.lua;;
echo "export LUA_PATH=${LUAROCKS_PREFIX}/share/lua/5.1/?.lua;${LUAROCKS_PREFIX}/share/lua/5.1/?/init.lua;;" >> /environment
export LUA_CPATH=${LUAROCKS_PREFIX}/lib/lua/5.1/?.so;;
echo "export LUA_CPATH=${LUAROCKS_PREFIX}/lib/lua/5.1/?.so;;" >> /environment

luarocks install luaposix
luarocks install luafilesystem

cd /tmp/
git clone https://github.com/TACC/Lmod.git
cd /tmp/Lmod
git checkout tags/${LMOD_VER} -b ${LMOD_VER}
./configure --prefix=${APPS_PREFIX} --with-siteName=gRED
make install
cp z00_lmod.sh ${APPS_PREFIX}/lmod/lmod/init/profile
ln -s ${APPS_PREFIX}/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
ln -s ${APPS_PREFIX}/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh
cp lmod/libexec/SitePackage.lua ${APPS_PREFIX}/lmod/lmod/libexec/
mkdir -vp ${APPS_PREFIX}/lmod/etc/

gem install --no-ri --no-rdoc fpm

export PATH=$PATH:${LUAROCKS_PREFIX}/bin/:${LUAROCKS_PREFIX}/lib/
echo "export PATH=$PATH:${LUAROCKS_PREFIX}/bin/:${LUAROCKS_PREFIX}/lib/" >> /environment
chown -cR gredsys.gredsys_pg ${APPS_PREFIX}/.. /tmp/Lmod

USER gredsys
cd /tmp/
export MODULEPATH=${APPS_PREFIX}/modules:$MODULEPATH
echo "export MODULEPATH=${APPS_PREFIX}/modules:$MODULEPATH" >> /environment
export EASYBUILD_PREFIX=${APPS_PREFIX}
echo "export EASYBUILD_PREFIX=${APPS_PREFIX}" >> /environment
export EB_BOOTSTRAP_SOURCEPATH=/tmp/eb_source
echo "export EB_BOOTSTRAP_SOURCEPATH=/tmp/eb_source" >> /environment

mkdir -vp ${EB_BOOTSTRAP_SOURCEPATH}

cp source/easybuild-easyconfigs-${EB_VER}.tar.gz ${EB_BOOTSTRAP_SOURCEPATH}
cp source/easybuild-framework-${EB_VER}.tar.gz ${EB_BOOTSTRAP_SOURCEPATH}
cp source/easybuild-easyblocks-${EB_VER}.tar.gz ${EB_BOOTSTRAP_SOURCEPATH}
cp source/bootstrap_eb.py ${EB_BOOTSTRAP_SOURCEPATH}

cp eb_setup.sh /tmp

bash /tmp/eb_setup.sh

mkdir -vp /home/gredsys
chown -cR gredsys.gredsys_pg /home/gredsys

#### End of File, if this is missing the file has been truncated
