#!/usr/bin/env bash

checks() {
    if ! [ $(id -u) = 0 ]; then
        echo -e "\033[1;34mRun me as a root.\033[0;37m"
        exit 1
    fi
}

dirmake() {
    mkdir -p /mnt/hbs
    cd /mnt/hbs
}

dist_type() {
    read -p "Family (arch/debian/gentoo/slackware/void):" DIST
}

dist_family() {
    if [[ "$DIST" = arch ]]; then
        echo -e "\033[1;Choosen Arch.\033[0;37m"
    elif [[ "$DIST" = debian ]]; then
        read -p "Which type? (debian/ubuntu):" DEB
        echo -e "\033[1;34mChoosen $DEB.\033[0;37m"
    elif [[ "$DIST" = gentoo ]]; then
        echo -e "\033[1;34mChoosen gentoo.\033[0;37m"
    elif [[ "$DIST" = slackware ]]; then
        echo -e "\033[1;34mChoosen slackware.\033[0;37m"
    elif [[ "$DIST" = void ]]; then
        echo -e "\033[1;34mChoosen Void.\033[0;37m"
    else 
        input_error
    fi
}

hbs_pacman() {
    echo -e "\033[1;34mNow acquire arch tarball.\033[0;37m"  
    wget https://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst
    untar
}

hbs_deb() {
    if [[ "$DEB" == ubuntu ]]; then
        echo -e "\033[1;34mNow acquire ubuntu minimal tarball.\033[0;37m" 
        wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64-root.tar.xz
        untar
    elif [[ "$DEB" == debian ]]; then
        echo -e "\033[1;34mGood luck. Now you on your own. =)\033[0;37m" 
        hbs_deb_str
    else
        input_error
    fi
}

hbs_gentoo() {
    read -p "Which gentoo stage3 we will use? (openrc/systemd):" GEN_INIT
    if [[ "$GEN_INIT" == openrc ]]; then
        echo -e "\033[1;34mNow acquire gentoo openrc stage3 tarball.\033[0;37m"  
        wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20240428T163427Z/stage3-amd64-openrc-20240428T163427Z.tar.xz
    elif [[ "$GEN_INIT" == systemd ]]; then
        echo -e "\033[1;34mNow acquire gentoo openrc stage3 tarball.\033[0;37m"  
        wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20240428T163427Z/stage3-amd64-systemd-20240428T163427Z.tar.xz
    else
        input_error
    fi
    untar
}

hbs_slackware() {
    echo -e "\033[1;34mNow acquire slack tarball.\033[0;37m" 
    wget https://ponce.cc/slackware/lxc/slackware64-current-mini-20160515.tar.xz
    untar
}

hbs_void() {
    read -p "Wich type of void we will use? (base/musl):" VOID_TYPE
    if [[ "$VOID_TYPE" == base ]]; then
        echo -e "\033[1;34mNow acquire void base tarball.\033[0;37m"  
        wget https://repo-default.voidlinux.org/live/20240314/void-x86_64-ROOTFS-20240314.tar.xz
    elif [[ "$VOID_TYPE" == musl ]]; then
        echo -e "\033[1;34mNow acquire void base tarball.\033[0;37m" 
        wget https://repo-default.voidlinux.org/live/20240314/void-x86_64-musl-ROOTFS-20240314.tar.xz
    else
        input_error
    fi
    untar
}

hbs_deb_str() {
    if [ -d /usr/share ]; then
        mkdir /usr/share/debootstrap/
        mkdir /usr/share/debootstrap/scripts/
    else
        mkdir /usr/share/
        mkdir /usr/share/debootstrap/
        mkdir /usr/share/debootstrap/scripts/
    fi
    curl https://raw.githubusercontent.com/aburch/debootstrap/master/scripts/sid > /usr/share/debootstrap/scripts/sid
    curl https://raw.githubusercontent.com/aburch/debootstrap/master/functions > /usr/share/debootstrap/functions
    bash <(curl -fsLS https://raw.githubusercontent.com/aburch/debootstrap/master/debootstrap) --arch=amd64 --make-tarball=debian.tar.gz --no-check-certificate --no-check-gpg sid /mnt/hsb http://deb.debian.org/debian/
    rm -rf /usr/share/debootstrap
    untar
}

hbs_type() {
    if [[ "$DIST" = arch ]]; then
        hbs_pacman
    elif [[ "$DIST" = debian ]]; then
        hbs_deb
    elif [[ "$DIST" = gentoo ]]; then
        hbs_gentoo
    elif [[ "$DIST" = slackware ]]; then
        hbs_slackware
    elif [[ "$DIST" = void ]]; then
        hbs_void
    fi
}

input_error() {
    echo -e "\033[1;34mProvide a valid option!\033[0;37m"
    exit 1
}

untar() {
    echo -e "\033[1;34mDe-archiving tarball.\033[0;37m"
    tar xpf *tar* --numeric-owner
    rm *tar* 
}

checks
dirmake
dist_type
dist_family
hbs_type