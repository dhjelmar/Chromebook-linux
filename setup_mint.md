# Description
- Linux Mint LMDE 6 faye (based on Debian 12 bookworm)
- see that with: cat /etc/os-release
- terminal shortcuts
  - C-S-c = copy to clipboard
  - C-S-v = C-S-insert = paste from clipboard
  - S-v =   S-insert = paste what is highlighted

# install operating system
- Useful videos
  - https://www.youtube.com/watch?v=J2sRqICVi7Y
  - https://www.youtube.com/watch?v=QKT-hXLfN2c

- rough steps
  - Create bootable USB with operating system
   - Download iso
   - Install on USB using Etcher (https://www.balena.io/etcher/)
   - Flash ios to USB
 - In Windows
   - Install MiniTool Disk Partition Manager
   - Create unallocated free space on disk for LMDE
     (if needed, delete partition in either MiniTool on Windows or Gparted on install disk will unallocate the space)
 - Boot from USB
   - Enter BIOS with, e.g., F2 or Del during boot
     - Go to exit
     - Select usb entry for debian UEFI
     - Start LMDE 6 64-bit
   - Install LMDE
     - Select installation icon on desktop
     - When asked about partitions, select "other" rather than "automatic"

        TOWER
        - Manual setup of 3 partitions on new SSD
           - EFI Boot loader: 100 MB fat32 primary partition; mount point /boot/EFI
           - Root (system files): 100 GB ext4 primary partition, mount point /
              - swap: using swap file under root rather than 16 GB ext4 logical partition
           - Home (personal files): 400 GB ext4 primary partition, mount point /home/<user>
        - Manual setup of 1 partition on a separate drive
           - Timeshift: 300 GB (3x the root partition size) primary partition on some other drive
              - Search / Timeshift (or can find as "System Snapshots" in the welcome window
              - rsync is the only option for Debian
              - Select the ext4 partition that I created on a separate drive
              - Snapshot leves
                 - weekly: keep 2
                 - boot  : keep 3
              - Description: Snapshots are not scheduled at fixed times.
                             A maintenance task runs once overy hour and creates snapshots as needed.
                             Boot snapshots are created with a delay of 10 minutes after system startup.
              - User home directories (options: exclude all files; include only hidden files; include all files)
                 - /home/username: exclude all files (default)
                 - /root         : exclude all files (default)

         TOWER2
         - Manual setup of 4 partitions on single SSD
	    - Use GParted to setup to create following partitions; used same thing for name and label of each partition
                                            size       format     partition typ      mount point    label and name
                                            ------     ------     --------------     -----------    --------------
              - EFI Boot loader:     	     100 MB     fat32	   primary	      /boot/EFI	     boot
              - Root (system files): 	     100 GB 	ext4 	   primary            /              root
                 - swap: using swap file under root rather than 16 GB ext4 logical partition
              - Timeshift: 		     300 GB     ext4	   primary			     timeshift
                                            (3x the root partition size)
              - Home (personal files):      balance	ext4 	   primary	      /home/<user>   home
              - no 16GB swap partion made; later will use a swap file under root instead
              
          - still in GParted, edit flags for EFI boot loader partition
	     - check the "boot" and "esp" fl
          - exit GParted
          - Refresh partitioning window in installer
          - Right click each created device and assign mount points
             - 100 MB fat32 to /boot/efi
             - 100 GB ext4  to /
             - 300 GB ext4  can leave blank for now
             - 594 GB ext4  to /home

     - Grub menu needs to be the same partition as the boot partition

     - finish installation of LMDE letting it reboot when done
     - turn on firewall in "First Steps"
     - setup TimeShift in "First Steps" / TimeShift / Settings and create 1 snapshot
       - Type: rsync
       - Location: Select location that was created for timeshift on same or different drive


# determine which linux version is installed
`
lsb_release -a
`


# DUAL BOOT MESSED UP WINDOWS / LINUX TIME (may have been messing up Brave and causing "Aw, Snap!)
- https://itsfoss.com/wrong-time-dual-boot/
- At bootup, the computer uses the hardware clock to set the system clock.
- After that, the system clock is used to track time.
- By default, Windows assumes the time stored on the hardware clock is the local time.
- By default, Linux assumes the time stored on the hardware clock is UTC, not local time.
- Any change in Windows or Linux to the system clock is used to set the hardware clock.

- The following should make Linux use local time for the hardware clock.
  (Could have done something different, but this is recommended as easiest.)
  '
  timedatectl set-local-rtc 1
  '


# Grub setup using `grub-customizer`
- Install `grub-customizer`
  `sudo apt install grub-customizer`
- Run `grub-customizer`
  - In List Configuration, define order for which option to boot
  - In General Settings, uncheck `look for other operating systems` to protect VM from os-prober
- Reboot to check that it is working
  - Enters grub when boots
  - Waits 10 sec
  - Boots 1st listed OS if not changed
  - Down arrow and enter to boot into a different OS


# Software Installation in order of preference:
1. Flatpack (Flathub)
2. System package
3. deb file

 My understanding on Flatpack (Flathub) vs. system versions of packages:
 - Flatpack is bigger because it is more sandboxed by including all system dependencies
   regardless of whether they already exist.
 - Flatpack is generally a more recent version.
 - Flatpack and System packages are both better than deb file installations because
   they are automatically included in system software updates. Not sure if this
   is true of deb files based on instructions I've worked through.


# update apt-get
```
sudo apt-get update && sudo apt-get upgrade -y
# if need root access at some point, enter in shell: sudo -i
```


# firewall (UFW = Uncomplicated FireWall)
```
help.ubuntu.com/community/Gufw
- Search / firewall
  - profile: Home
  - Status: Slide to on
  - Incoming: Deny (default)
  - Outgoing: Allow (default) <-- needed to, for example, send a request to the internet
  - Press Rule / + to open "Add a Firewall Rule" popup
```

# install chrome
- could not find in software manager
  ```
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install ./google-chrome-stable_current_amd64.deb
  ```

- if slow, try suggestions here

  - https://forums.linuxmint.com/viewtopic.php?t=302023

  - First try the last post. If that doesn't work, could try purging and reinstall Timeshift which helped someone else.


# GitHub
## install
```
# https://www.techrepublic.com/article/how-to-use-github-in-chrome-os/
sudo apt-get install git
git config --global user.name dlhjel
git config --global user.email dlhjel@gmail.com
git config --global color.ui true
git config --global core.editor emacs
cd ~/
```

## create SSH keys
```
ssh-keygen -t ed25519 -C dlhjel@gmail.com
## hit enter twice after above command (provide a name when prompted like id_ed25519_github)
## copy the contents of the ~/.ssh/*pub key and add it to GitHub

## start ssh agent if not already running (it is probably already running so command is commented out)
##    eval "$(ssh-agent -s)"
## add the key with
ssh-add ~/.ssh/id_ed25519_github
```

## create folders
```
mkdir ~/Documents/GitHub
cd ~/Documents/GitHub
git clone git@github.com:dhjelmar/Chromebook-linux.git
git clone git@github.com:dhjelmar/R-setup.git
# Other commands
#    ! git pull              # update repos from inside repos folder
#    ! git add file1 file2   # stage files for commit (may not need with -a option on commit)
#    ! git commit -am "commit message"   # commit all changes with a message
#    ! git push              # upload committed changes to GitHub
```

# .bash_aliases
add following to bottom of ~/.bash_aliases
```
source ~/Documents/GitHub/Chromebook-linux/_bash_aliases
```

# EMACS

- search / software manager / emacs

- added statistical mode
  - search / software manager / elpa-ess

- .emacs file
  ```
  ln -s ~/Documents/GitHub/Chromebook-linux/_emacs_mint ~/.emacs.d/init.el
  ```

- run with: `e .`


# Nemo file manager (already installed as default file manager)

# secure delete
- Standard file shredders that overwrite files with zeros (like `/usr/bin/shred -f -u -v -z -n 3 filename`) are good for an HHD but useless on and bad for an SSD. An SSD uses wear leveling so wehn shred tries to overwrite a block of memory, the SSD controller just writes the zeros to a new physical block to save wear on the old one.
- For most modern SSDs and operating systems (Windows 10/11, macOS, modern Linux), simply deleting a file and emptying the Trash is actually quite secure.
- By default, Linux usually runs TRIM on a weekly schedule via a systemd timer. To ensure the data is cleared right now, manually trigger the fstrim command on the partition where the file lived (usually /).
  ```
  # to run on current drive
  sudo fstrim -v /

  # to run on a different drive (e.g., Windows_SSD_ntfs)
  sudo fstrim -v /mnt/Windows_SSD_ntfs
  ```

- added smart secure delete option to nemo file manager based on whether on SSD or HDD
  ```
  cd /home/david/Documents/GitHub/Chromebook-linux/setup_mint_files
  cp smart_secure_delete.sh          /home/david/.local/share/nemo/actions
  cp smart_secure_delete.nemo_action /home/david/.local/share/nemo/actions
  ```

# Thunderbird
- using system version
- following may be from when tested flatpak version; some of this may be good to recreate in system version
  ```
  # uninstalled system version that came with LMDE to use flatpck instead
  
  # needed to change so unread email would be magenta
  # in "advanced preferences, search for userprof and toggle:
  #     toolkit.legacyUserProfileCustomizations.stylesheets to true
  # 
  # if using system version of thunderbird (lsz* folder might have a different name):
  #    cd ~/.thunderbird/lszg1so8.default-default
  #    mkdir chrome
  #    cd chrome
  #    ln -s ~/Documents/GitHub/Chromebook-linux/setup_mint_files/userChrome.css userChrome.css
  #
  # if using flatpack version of thunderbird (lsz* folder might have a different name):
  #    cd ~/.var/app/org.mozilla.Thunderbird/.thunderbird/mfxq8yi7.default-esr
  #    mkdir chrome
  #    cd chrome
  #    ln -s ~/Documents/GitHub/Chromebook-linux/setup_mint_files/userChrome.css userChrome.css
  
  # https://superuser.com/questions/13518/change-the-default-sorting-order-in-thunderbird
  # go into settings / config editor (advanced preferences) / mailnews.default
  # see above to change default: sort order (2  = decending)
  #                              sort type  (21 = based on order received)
  #                              sort flag  (0  = unthreaded)
  ```

# exiftool
```
sudo apt install exiftool
```

# VLC
```
# installed with software manager

# alternately could use
# sudo apt-get install vlc
```

# YouTube-DL (requires Python to run)
```
#sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
#sudo chmod a+rx /usr/local/bin/youtube-dl
```

# Anaconda
```
# installation instructions: https://docs.anaconda.com/anaconda/install/linux/
sudo apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
cd ~/Downloads
curl -O https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
# compared following to expected shasum here: https://repo.anaconda.com/archive/
shasum -a 256 Anaconda3-2024.06-1-Linux-x86_64.sh
bash Anaconda3-2024.06-1-Linux-x86_64.sh
# install to /home/<USER>/anaconda3
# choose yes to automatically activate conda
# should not need the following
#    source ~/anaconda3/bin/activate 
#    conda init
```

# Brave (use this instead of flatpak)
```
# https://brave.com/linux/
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

## to remove
#sudo apt purge brave-browser
#sudo rm /etc/apt/sources.list.d/brave-browser-release.list
#sudo apt-key del A8580BDC82D3DC6C
#rm -rf ~/.config/BraveSoftware
#rm -rf ~/.cache/BraveSoftware
```

# auto-mount ntfs drives
```
# https://www.cyberciti.biz/faq/debian-ubuntu-linux-auto-mounting-windows-ntfs-file-system/
sudo apt-get install ntfs-3g
# find UUIDs of drives
lsblk
sudo blkid /dev/sda2
sudo blkid /dev/sdb1
# modify /etc/fstab; see copy at $github_path/setup_mint_files/fstab
# test mount
sudo /usr/bin/mount -a   # this failed with insufficient permission

# hard to see NTFS files because of green background when use ls command
# fixed creating and evaluating .dircolors file
# first found current settings with: dircolors -p > ~/.dircolors
# modified .dircolors file and executed by adding following to _bash_aliases
eval "$(dircolors $git_path/Chromebook-linux/setup_mint_files/.dircolors)"
```

# VS Code (Microsoft Visual Studio Code) (31 GB = 62% full before install; xxxx after install)
```
# https://www.linuxcapable.com/how-to-install-microsoft-visual-studio-code-on-debian-11/
# update system to avoid conflicts
sudo apt update && sudo apt upgrade -y
# install package to assist in installing software
sudo apt install software-properties-common apt-transport-https wget -y
# import Microsoft GPG key
wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg
# import Michrosoft Visual Source Repository
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
# update system again
sudo apt update
# install VS Code
sudo apt install code -y

# launch
# code

# to remove
# sudo apt remove code --purge
# sudo rm /etc/apt/sources.list.d/vscode.list
# sudo rm /usr/share/keyrings/vscode.gpg
```


# yq - YAML processor needed for uv-setup function in _bash_aliases
sudo apt install yq


# OnlyOffice
- sofware manager / onlyoffice <-- flatpak available
- or do it the old fashioned way
  ```
  ## Add GPG key:
  #mkdir -p -m 700 ~/.gnupg
  #gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
  #chmod 644 /tmp/onlyoffice.gpg
  #sudo chown root:root /tmp/onlyoffice.gpg
  #sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
  ### Add desktop editors repository:
  #echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list
  ### Update the package manager cache:
  #sudo apt-get update
  ### Now the editors can be easily installed using the following command:
  #sudo apt-get install onlyoffice-desktopeditors
  ```

# digikam
- installed with search / software manager (not synaptic package manager)
- installed the system version rather than Flathub


# Gimp
- installed with search / software manager (not synaptic package manager)
- installed Flatpack rather than system version


# SIGNAL FOR POTENTIAL USE AS GROUP VIDEO CONFERENCE
-  https://signal.org/download/linux/
-  NOTE: These instructions only work for 64-bit Debian-based
         Linux distributions such as Ubuntu, Mint etc.

1. Install our official public software signing key:
  ```
  cd ~/Downloads
  wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
  cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
  ```

2. Add our repository to your list of repositories:
  ```
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list
  ```

3. Update your package database and install Signal:
  ```
  sudo apt update && sudo apt install signal-desktop
  ```

# Zoom
  ```
  cd ~/Downloads
  wget https://zoom.us/client/latest/zoom_amd64.deb
  sudo apt install ./zoom_amd64.deb
  # zoom   # to launch
  # sudo apt remove zoom
  ```

# OpenSCAD
- used "Software Manager" to install system package instead of the commands below
  (https://openscad.org/downloads.html)
  ```
  sudo apt-get install openscad
  ```


# RSTUDIO (R was preinstalled with LMDE)

- I installed LMDE 7 which is based on Debian 13 Trixie. Need compatable version.
  ```
  sudo apt update
  sudo apt install r-base r-base-dev

  # download deb file from: https://posit.co/download/rstudio-desktop/
  # double click deb file in file manager to install
  ```

- OLD INSTRUCTIONS BELOW THAT MAY BE USEFUL IN THE FUTURE
  ```
  # https://linuxcapable.com/how-to-install-r-programming-language-on-debian-linux/
  # update system
  sudo apt update
  sudo apt upgrade
  
  # update version of R
  apt remove r-base-core
  apt install -t bookworm-cran40 r-base
  
  # https://cran.r-project.org/bin/linux/debian/
  # https://rpubs.com/hrpunio/1153216
  # install required packages
  sudo apt install dirmngr apt-transport-https ca-certificates software-properties-common -y
  # import CRAN respository
  R=https://cloud.r-project.org/bin/linux/debian bookworm-cran40/
  echo "deb [signed-by=/usr/share/keyrings/cran.gpg] ${R}" | sudo tee /etc/apt/sources.list.d/cran.list
  # update R packages
  apt install libv8-dev
  apt install lib-sodium.h
  apt install libopenblas-dev
  update.packages(ask = FALSE)
  sudo apt install r-base-core r-base-dev
  
  # deb http://cloud.r-project.org/bin/linux/debian bookworm-cran40/
  # sudo apt install r-base
  # R --version
  
  # https://computingforgeeks.com/how-to-install-r-and-rstudio-on-debian/
  # https://ahmorris.org/post/2023-09-16-install-rstudio-on-debian-12-bookworm/
  # https://cloud.r-project.org/bin/linux/debian/
  
  # install RStudio
  cd ~/Downloads
  sudo apt -y install wget
  # downloaded deb file from https://posit.co/download/rstudio-desktop/
  wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.12.1-563-amd64.deb
  
  # obtain public key
  gpg --keyserver keys.openpgp.org --search-keys 51C0B5BB19F92D60
  # asked to "Enger number(s), N)ext, or Q)uit". I entered 1.
  
  # validate signture
  gpg --verify rstudio-2024.12.1-563-amd64.deb
  
  # install
  sudo apt install -f ./rstudio-2024.12.1-563-amd64.deb
  
  # launch RStudio
  rstudio
  
  # install a couple things needed to support various packages (RTools not needed on Linux, only Windows)
  sudo apt install libcurl4-openssl-dev
  sudo apt install cmake
  ```

- to remove R
  ```
  remove_r() {
     sudo apt-get remove rstudio      # rstudio
     rm -r ~/.local/share/rstudio     # rstudio settings
     sudo apt-get remove r-base       # R packages
     sudo apt-get remove r-base-core  # R and possibly some packages
  }
  # remove_r
  ```

# Nomacs picture viewer
```
flatpak install flathub org.nomacs.ImageLounge
```

# MEGA cloud storage
```
cd ~/Downloads
wget https://mega.nz/linux/repo/Debian_12/amd64/megasync-Debian_12_amd64.deb
sudo apt install "$PWD/megasync-Debian_12_amd64.deb"
```

# rsnapshot (timeshift)
```
# https://rsnapshot.org/faq.html
# https://www.tecmint.com/rsnapshot-a-file-system-backup-utility-for-linux/
sudo apt-get install rsnapshot

# modify /etc/rsnapshot.conf file
# (1) changed location of snapshot_root as follows where replace USER with value of $USER
#   snapshot_root   /home/USER/.rsnapshot
#
# (2) added the following
#   #########################################
#   #           BACKUP INTERVALS            #
#   # Must be unique and in ascending order #
#   # i.e. hourly, daily, weekly, etc.      #
#   #########################################
#   
#   interval        hourly  6
#   interval        daily   7
#   interval        weekly  4
#   interval        monthly 3

# test configuration file with following
rsnapshot configtest

mkdir $HOME/.rsnapshot
```


# DROPBOX
installed system package with Software Manager


# CHEESE
- program needed for endoscope to work on Chromebook
- launch with "cheese"


# KeePassXC
- install
  ```
  sudo apt-get install keepassxc
  ```
- launch with "keepassxc" or "kpx" alias


# QUARTO
installed as extension within vscode so do not think I need the following
```
## download deb file from web
## sudo dpkg -i ~/Downloads/quarto-1.3.290-linux-amd64.deb
## to remove quarto
## sudo apt-get remove quarto
```

# Foxit PDF reader
download tar file from https://www.foxit.com/downloads/pdf-reader-thanks.html?product=Foxit-Reader&platform=Linux-64-bit&version=&package_type=&language=English&formId=download-reader
```
pd ~/Downloads
tar xzvf FoxitReader*.tar.gz
sudo chmod a+x FoxitReader*.run
sudo ./FoxitReader*.run
## usage: FoxitReader &
## to uninstall:
##    sudo /opt/foxitsoftware/foxitreader/maintenancetool
```

## OCRmyPDF
- install ghostscript (required)
????????????
- install tesseract (required)
???????????
- install ocrmypdf
  ```
  sudo apt install ocrmypdf
  ```


## auto-mount usb drives
```
# https://github.com/Ferk/udev-media-automount
# download: https://github.com/Ferk/udev-media-automount/archive/refs/heads/master.zip
unzip master.zip
cd udev-media-automount-master
sudo make install
sudo udevadm control --reload-rules
sudo udevadm trigger
```

# SSH - install as client (i.e., not the server)
- Linux
```
sudo apt install openssh-client
```

- On Windows, follow instructions here:
  ```
  # https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui
  # Username can be found by entering following in Windows PowerShell
  #      $env:USERNAME
  # and servername can be found by entering following in Windows PowerShell
  #      ipconfig | select-string  ('(\s)+IPv4.+\s(?<IP>(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))(\s)*') -AllMatches | %{ $_.Matches } | % { $_.Groups["IP"]} | %{ $_.Value }
  # Log into remote PC from linux using password at the prompt (e.g., ssh jack@192.168.1.101):
  #      ssh username@servername
  # The above does not work with MS Account. Need stand alone account. Grrr#!!**!
  # https://answers.microsoft.com/en-us/windows/forum/all/ssh-login-to-microsoft-account-linked-windows/69ea0428-5b06-401c-bb86-e45228709e0b
  ```

- IDEA (not sure how much of this I've used if any)
  ```
  ##    - Create local admin account
  ##    - Change MS linked account to "standard user"
  ##    - ssh into local admin account (or would it be better to ssh into local standard user account?)

  ## If can log in using the above, can replace password to ssh with a keypair. 
  ## On Linux, generate new ssh keypair
  ## (https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux)
  ## From terminal where found username@servername on Windows from above: 
  ##      cd ~/.ssh
  ##      ssh-keygen -t ed25519 -C "username@servername"
  ## Name the key, e.g., id_ed25519_keyname (creates id_ed25519_keyname and id_ed25519_keyname.pub).
  ## Recommended to add a pin for the key.
  ## Start ssh agent
  ##      eval "$(ssh-agent -s)"
  ## Add private key to agent
  ##      ssh-add ~/.ssh/id_ed25519_keyname
  ## To remove private key from agent
  ##      ssh-add -d ~/.ssh/id_ed25519_keyname
  ## From Linux while logged into Windows PC through ssh, enter the following in terminal
  ## to add the public key to Windows in ~/.ssh/authorized_keys file.
  ##      ssh-copy-id -i ~/.ssh/id_ed25519_keyname.pub username@servername
  ## above step failed so tried looking here:
  ## https://superuser.com/questions/1451241/command-to-copy-client-public-key-to-windows-openssh-sftp-ssh-server-authorized
  ## and used manual process:
  ##     - Copy xxxxxx.pub file to windows server at location C:\Users\username\.ssh\authorized_keys
  ##     - Update ACL on windows server using command
  ##             icacls.exe "C:\Users\username\.ssh" /inheritance:r /gr
  ## Still not able to log in with keypair.
  ## Again tried following which automatically created authorized_keys file
  ##     - In Windows C:/Users/username, moved manually created authorized_keys file to authorized_keys_junk
  ##     - In Linux ssh session, entered: ssh-copy-id username@servername
  ## Next ssh should only require pin and not password, but it still is asking for a password.
  ```

# Gramps

- First tried system package but it did not seem to include `edit/addon manager`.
  Did find addon manager in menu but nothing populated.

- Installed flatpak
  ```
  # https://gramps-project.org/wiki/index.php/Installing_Gramps_for_Linux_computers#Debian_package
  sudo flatpak install flathub org.gramps_project.Gramps
  ```

- Following may work to build from source but not tried
  ```
  Building from Source (Advanced Users):
  Install necessary dependencies:
  sudo apt install git
  sudo apt install python3-dev
  sudo apt install python3-pip
  sudo apt install build-essential
  sudo apt install libgspell-1-dev
  sudo apt install libxml2-dev
  sudo apt install libxslt-dev
  sudo apt install libglib2.0-dev
  sudo apt install libgdk-pixbuf2.0-dev
  sudo apt install libgtk2.0-dev
  sudo apt install libpango-dev
  sudo apt install libwebkitgtk-1.0-dev
  sudo apt install libsqlite3-dev
  sudo apt install libldap2-dev
  sudo apt install libpcre3-dev
  sudo apt install libffi-dev
  sudo apt install libpython3-dev
  sudo apt install python3-setuptools
  Clone the Gramps repository: git clone https://github.com/gramps-project/gramps.git Gramps
  Navigate to the Gramps directory: cd Gramps
  Create a build directory: mkdir build
  Navigate to the build directory: cd build
  Configure the build: cmake ..
  Build Gramps: make
  Install Gramps: sudo make install 
  ```

# brightness and gamma applet
- if out of date, then may need to upgrade linux to newer version
- manual option
  - first check that DDC/CI is enabled in monitor setup (find using menu button)
  - install ddcutil
    ```
    sudo apt install ddcutil
    ```

   - to increase brightness: `sudo ddcutil setvcp 10 + 10`
   - to decrease brightness: `sudo ddcutil setvcp 10 - 10`

# Create VM on Windows SSD using Gnome Boxes

1. Use symbolic link to change location for VM from ~/.local/share
        ```
        cd /home/david/Windows_SSD_ntfs/Documents/01_Dave  
        mkdir gnome-boxes  
        cd /home/david/.local/share  
        ln -s ~/Windows_SSD_ntfs/Documents/01_Dave/gnome-boxes gnome-boxes
        ```
2. Download Windows 11 ISO from Microsoft

3. In boxes, create VM
   - Click on + then did the following:  
      - On host, confirmed UEFI rather than BIOS firmware with:  
        ```
        test -d /sys/firmware/efi && echo UEFI || echo BIOS
        ```  
      - In Boxes, installed for UEFI firmware with 4 GB memory and 80 GB storage

4. fix copy/paste from linux to VM
    - Different sources conflict in whether spice-vdagent needs to be running on just the guest or also the host.
    I installed it on both.

      - Linux host
        - Download and install
        - check that it is running: `ps aux | grep vdagent`
        
      - Windows Guest VM
        https://itsfoss.com/share-files-gnome-boxes/
        - Download and install **Windows SPICE Guest Tools** (`spice-guest-tools-latest.exe`) from
	  https://www.spice-space.org/download.html.
        - Download and install `virtio-win-guest-tools` needed to complete clipboard sharing and
	  to enable full window VM. Found here:
          ```
          https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.285-1/
          ```
           
        - Linux guest OS (not tested)
          ```
          sudo apt install spice-webdavd spice-client-gtk spice-vdagent
          ```
        
5. Fix Yubikey (not working yet; not really needed since I got copy/paste working between host and guest)
   ```
        sudo apt install pcscd && sudo systemctl enable --now pcscd
   ```     
   Possibly try  
   ```
   sudo usermod -aG plugdev \$USER
   ```
   Log out and back in for changes to take effect.


6. Install MS Offce in VM and activate
   https://www.reddit.com/r/microsoftoffice/comments/17r7jls/how_to_download_microsoft_office_2019_or_2021/
   - Download the 2021 Office Professional Plus from here.
     https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/en-US/ProPlus2021Retail.img
   - Install MS Office
   - Open PowerShell as an administrator:
     - Run:
       ```
       irm https://get.activated.win/ | iex
       ```
     - Press activation method   : [2] hook - Office
     - Choose installation option: [1] Install Ohook Office Activation

7. File sharing
   - In Windows VM (guest OS), install spice-webdavd
     - Download & Install Get the installer from spice-space.org or via Winget:
       ```
       # in powershell
       winget install --id=Spice.SpiceWebDAVd -e
       ```
     - Enable the Service: Open Task Manager → Services → Enable spice-webdavd.
       - Found instructions to alternatively run map-drive.bat from
         C:\Program Files\Spice webdav\ if not running as a service.
       - It was already running so above action needed for now
       - Firewall Settings
         - Instructions also said to disable or configure Windows Firewall to allow the service
	 - I did not need to do this either. Windows Defender was fine with no changes.


# Disk Usage
Useful and quick tool to identify largest folders and files
`sudo apt install ncdu`
Graphical tool like WinDirStat that comes with Linux Mint
`baobab`


# To update system
- run the system update manager when there is a notification in lower right of window
- automatic method to update `apt` and `flatpak` aps in _bash_aliases
  ```
  update
  ```

- The above automatic update does all of the following
  - updates apps installed using `apt` (including `apt-get`) 
  
    https://www.fosslinux.com/49955/keep-your-debian-updated.htm

    ```
    sudo apt update
    apt list --upgradable
    # if above only returns "Listing... Done" then there is nothing to update
    # to upgrade everything
    sudo apt upgrade -y
    # clean up when done
    sudo apt-get clean
    # also run the following
    sudo apt-get autoclean
    sudo apt autoremove;
    ```

  - updates flatpaks
    ```
    sudo flatpak update
    ```

 - If only need to update a specific package (in the following, replace <package_name> with actual name of the package).
   ```
    sudo apt update
    sudo apt --only-upgrade install <package_name>
   ```
