I got this working, but I am not sure if these instructions are up to date.


# SSH Server
- https://www.socketxp.com/iot/install-setup-ssh-server-client-iot-device/
- on server
  ```
  # install, enable, and run ssh server as a daemon in background
  sudo apt-get update
  sudo apt-get install openssh-server
  # to start on boot
  sudo systemctl enable ssh
  # to start service if needed
  sudo systemctl start ssh
  
  # to see status
  sudo systemctl status ssh

  #  on client
  # get ip address
  ip a
  # under <BROADCAST,MULTICAST,UP,LOWER_UP>, look for inet line:
  #       inet 192.168.0.31/16 brd 192.168.0.255 scope global dynamic noprefixroute enp0s3
  #            ------------                                                         ------
  # then short ip address would be:
  #       192.168.0.31
  # the long ip address would be:
  #       192.168.0.31/16
  # with network interface
  #       enp0s3

  #----------------------
  # on server
  # configure firewall to allow incoming connections on port 22 (default ssh port)
  # entered following but replaced the `192.168.0.31/16` with the long client ip address
  sudo ufw allow from 192.168.0.31/16 to any port 22
  
  #----------------------
  # on client
  
  # install ssh client
  sudo apt-get update
  sudo apt-get install openssh-client
  
  #----------------------
  # on client, log into server with:
  ssh username_on_server@server_ip_address
  # Got a message that "The authenticity of host `server ip address` could not be established.
  # Asked if I wanted to continue connecting. Answer `yes`
  # Warning that the server ip was permanently added to list of known hosts [on client]
  # Enter server password.
  
  #----------------------
  # on client, log out of server
  exit
  
  # setup ssh keys
  ssh-keygen -t rsa -C 'user_name_on_client@client_pc_name'
  # where user_name_on_client@client_pc_name from client terminal prompt
  # the -C comment may be unnecessary
  
  # copy the contents of the pub key to the ~/.ssh/authorized_keys file on the server
  # by entering the following on the client while still logged out of server
  ssh-copy-id -i mykey.pub username_on_server@server_ip_address
  # where user_name_on_server is from user_name_on_server@server_pc_name on server terminal prompt
  #       servier_ip_address is the short version of the ip (e.g., 192.168.0.31)
  
  
  #----------------------
  # on server
  # disable password authentication
  # open ssh server config file
  sudo emacs /etc/ssh/sshd_config
  # search for following keywords and set as follows
  #    PasswordAuthentication no
  #    PubkeyAuthentication yes
  #    MaxAuthTries 3
  
  # giving up on the following for now
  # https://goteleport.com/blog/ssh-hardening-to-prevent-brute-force-attacks/
  # the following provides backup protection to the same thing what was done in the firewall
  # in /etc/hosts.deny, set the following (everything was originally commented out)
  #    ALL: ALL
  # in /etc/hosts.allow, set the following were my_client_IP is replaced with the allowed client IP
  #    ALL: my_clisudent_IP
  
  # restart service
  sudo service ssh restart
  
  # reboot server
  
  # if mess up sshd_config file, will get a "start request repeated too quickly" error as the system
  # attempts and reattempts to restart. Find details of the error by inspecting output from:
  #      journalctl -e
  # then manually start service again and check status
  #      sudo systemctl start ssh
  #      sudo systemctl status ssh

  # on client
  
  # attempt to log into server with ssh key
  ssh -i ~/.ssh/mykey.pub username_on_server@server_ip_address
  # where mykey is the name of the key that was created earlier
  
  # simplify login by creating config file
  # create ~/.ssh/config file containing the following
  Host host_name
       HostName server_ip_address
            User username_on_server
                 IdentityFile ~/.ssh/mykey
                 # where host_name can probably be anything (e.g., tower) or possibly needs to be
                 # server_pc_name which was found above
                 
                 # attempt to log into server with simpler ssh command
                 ssh host_name
                 
                 
                 #----------------------
                 # to enable running GUI on server with X11 forwarding
                 
                 #-----
                 # on server
                 # in /etc/ssh/sshd_config, set
                 #     X11Forwarding yes                  <-- this was already set
                 # restart the sshd daemon (only if it was not already set)
                 sudo systemctl restart ssh
                 
                 #-----
                 # on client to start ssh with X11 forwarding for displaying GUI from mint on remote
                 # run ssh using -X
                 ssh -X tower
                 
                 # X11 works but is very slow
  ```		 		 	  

#-----------------------------------------------------------------------------
# ThinLinc (an attempt to speed up ssh with GUI)
# https://www.learnlinux.tv/thinlinc-overview-and-tutorial-how-to-install-and-utilize-this-linux-remote-desktop-solution/

#------------------
# SERVER

# download thinlinc server software for administrators
# https://www.cendio.com/thinlinc/download/

# extract from zip folder by selecting in file manager
# double click on "Click to install" and follow prompts
# options:
#    - chose "Master" server rather than "Agent" server
#    - Message that "ThinLinc Commands not in Sudo PATH" so need to specify complete path when running
#      ThinLinc admin commands. Instructions to fix this in ThinLinc Administrator's Guide under
#      Installation chapter, "Run ThinLinc administration commands using sudo"

#------------------
# CLIENT

# install
# on client, download thinlinc server software for users
# https://www.cendio.com/thinlinc/download/
# downloaded DEB version
# open in file manager and double click to install

# configure and connect
# open "ThinLinc client" from start
# Options / Security / Public key (since I already set up ssh)
# entries:
#    - server  : ip address
#    - username: username on server
#    - key     : full path to ssh key (do not add the .pub extension)

# additional configuration
# potential settings: https://www.cendio.com/resources/docs/tag/client_config_params.html
# edit /opt/thinlinc/etc/tlclient.conf
# set:
#   ALLOW_HOSTKEY_UPDATE=publickey    # it was password
#   AUTOLOGIN=0                       # was 0 but can set to 1 for autologin when open ThinLinc app

# need to be logged out of server to connect with it using ThinLinc

#------------------
# CLIENT
# If getting frequent requests on serer for password associated with issue with keyring login,
# open 'start / passwords & keys when logged' into server. Right click 'Login' and change password
# to be blank. The existing password should be the same as the login password. The issue seems to
# be that the login keyring gets unlocked when manually logging into the server, but not
# when automatially logging into the server.

# Getting rid of the "Authentication is required to modify a system repository" dialogue.     # dlh error
# suggestion not tried yet
# https://www.reddit.com/r/debian/comments/mcxzp8/getting_rid_of_the_authentication_is_required/?rdt=42244
# gsettings set org.gnome.software download-updates false

# another suggestino
# gsettings set org.gnome.software download-updates-notify false

#------------------
# getting Yubikey to work with ThinLinc

https://bugzilla.cendio.com/show_bug.cgi?id=8251
https://community.thinlinc.com/t/anyone-working-fido2-token-forwarding-support/904
https://community.thinlinc.com/t/linux-remote-desktop-authentication-is-thinlinc-compatible-with-yubikey/280/2

https://community.thinlinc.com/t/smartcard-export-no-longer-working/843/17
# add following to bashrc
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/thinlinc/lib64:/opt/thinlinc/lib"

