#!/bin/bash

# install vsftp
yum install vsftpd db4-utils

# edit pam file
sed -i 's/^[^#]/#&/g' /etc/pam.d/vsftpd
echo "auth    required        /lib64/security/pam_userdb.so   db=/etc/vsftpd/vir_user" >> /etc/pam.d/vsftpd
echo "account required        /lib64/security/pam_userdb.so   db=/etc/vsftpd/vir_user" >> /etc/pam.d/vsftpd

# create user and password
read -p "user and password, Examples: (user password) : " user password
echo -e "$user\n$password" >> /etc/vsftpd/vir_user
db_load -T -t hash -f /etc/vsftpd/vir_user /etc/vsftpd/vir_user.db
chmod 600 /etc/vsftpd/vir_user*

# create vsftp virtual user config dir
if [ ! -d /etc/vsftpd/vconf ] ; then
  mkdir /etc/vsftpd/vconf
fi

# create vsftpd virtual user config file
echo -e "local_root=/ftp_data\nguest_username=ftp\nwrite_enable=YES\ndownload_enable=YES\nfile_open_mode=0622\nanon_world_readable_only=NO\nanon_upload_enable=NO\nanon_mkdir_write_enable=NO\nanon_other_write_enable=NO" >> /etc/vsftpd/vconf/$user

# create ftp data dir
if [ ! -d /ftp_data ] ; then
  mkdir /ftp_data
  chown ftp.ftp /ftp_data
fi

# create vsftp config file
mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
echo -e "anonymous_enable=NO\nlocal_enable=YES\nwrite_enable=YES\nlocal_umask=022\nvirtual_use_local_privs=YES\nguest_enable=yes\nchroot_local_user=YES\nhide_ids=YES\nuse_localtime=YES\ntcp_wrappers=YES\nuserlist_enable=YES\nlisten=YES\npam_service_name=vsftpd\nuserlist_enable=YES\nuse_sendfile=NO\npasv_enable=YES\npasv_min_port=30000\npasv_max_port=30010\nuser_config_dir=/etc/vsftpd/vconf" >> /etc/vsftpd/vsftpd.conf

# start vsftp 
chkconfig vsftpd on
service vsftpd start
