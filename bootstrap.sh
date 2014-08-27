#!/bin/bash

trap restoreSudoers INT

function editSudoers {
  echo "Setting up..."
  cd ~
  
  curl "https://raw.githubusercontent.com/flatiron-labs/chromebook-environmentalizer/master/edit_sudoers.sh" -o "edit_sudoers.sh"
  chmod a+rx edit_sudoers.sh && sudo ./edit_sudoers.sh $USER && rm edit_sudoers.sh
}

function restoreSudoers {
  echo "Cleaning up..."
  cd ~

  curl "https://raw.githubusercontent.com/flatiron-labs/chromebook-environmentalizer/master/restore_sudoers.sh" -o "restore_sudoers.sh"
  chmod a+rx restore_sudoers.sh && sudo ./restore_sudoers.sh && rm restore_sudoers.sh
}

function copyBashProfile {
  echo 'Getting Flatiron School .bashrc...'
  cd ~
  
  if [ -f .bashrc ]; then
    mv .bashrc .bashrc.old
  fi

  curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/bashrc" -o ".bashrc"
}

function installRVM {
  echo 'Installing RVM and Ruby 2.1.2...'
  cd ~

  \curl -L https://get.rvm.io | bash -s stable --ruby=2.1.2
  source $HOME/.bashrc
  source $HOME/.rvm/scripts/rvm

  rvm use 2.1.2 --default
}

function installNokogiri {
  echo 'Installing Nokogiri... This could be a while...'
  cd ~
  gem install nokogiri
}

function getGitconfig {
  echo "Setting up .gitconfig and GitHub SSH Key..."
  cd ~
  
  if [ -f .gitconfig ]; then
    mv .gitconfig .gitconfig.old
  fi

  curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/gitconfig" -o ".gitconfig"
  sed -i "s/<YOUR HOME DIRECTORY>/$USER/g" .gitconfig

  printf 'Enter your GitHub username: '
  read username < /dev/tty

  printf 'Enter your GitHub email address: '
  read email < /dev/tty

  printf 'Enter your GitHub API key (set one up at https://github.com/settings/applications): '
  read apikey < /dev/tty

  sed -i "s/<github username>/$username/g" .gitconfig
  sed -i "s/<API token>/$apikey/g" .gitconfig
  sed -i "s/<github email address>/$email/g" .gitconfig

  if [ ! -f .ssh/id_rsa.pub ]; then
    ssh-keygen -t rsa -N '' -C "$username@github" -f "$HOME/.ssh/id_rsa"
  fi
  
  sshkey=$(cat $HOME/.ssh/id_rsa.pub)

  curl -s -u "$username:$apikey" https://api.github.com/user/keys -d "{\"title\":\"$username@github\",\"key\":\"$sshkey\"}"
}

function getGitignore {
  echo 'Setting up .gitignore...'
  cd ~

  if [ -f .gitignore ]; then
    mv .gitignore .gitignore.old
  fi

  curl "http://bit.ly/flatiron-gitignore" -o ".gitignore"
}

function setupGemrc {
  echo 'Setting up .gemrc...'
  cd ~

  if [ -f .gemrc ]; then
    mv .gemrc .gemrc.old
  fi

  touch .gemrc
  echo "gem: --no-ri --no-rdoc" > .gemrc
}

function getIrbrc {
  echo 'Setting up .irbrc...'
  cd ~

  if [ -f .irbrc ]; then
    mv .irbrc .irbrc.old
  fi

  curl "https://gist.githubusercontent.com/loganhasson/f9fe9a73a1839ba1ef4a/raw/f65cef4fd4ac12d832e109eaca477c5b2dc686b0/.irbrc" -o ".irbrc"
}

function setupDirStructure {
  echo 'Setting up basic development directory structure...'
  cd ~

  mkdir -p Development/code
}

# This should be put in the ubuntu installer when it adds sublime
# function setsUpSublimePreferences {
#   echo 'Setting Up SublimeText 3.0...'
#   cd ~


#   # cp -r "/Volumes/Sublime Text 2/Sublime Text 2.app" "/Applications/Sublime Text 2.app"
#   sudo ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/local/bin
#   open "/Applications/Sublime Text 2.app" && sleep 3 && killall "Sublime Text 2"
  
#   cd "$HOME/Library/Application Support/Sublime Text 2/Installed Packages"
#   curl "https://sublime.wbond.net/Package%20Control.sublime-package" -o "Package Control.sublime-package"

#   cd "$HOME/Library/Application Support/Sublime Text 2/Packages/Color Scheme - Default"
#   curl "http://flatironschool.s3.amazonaws.com/curriculum/resources/environment/themes/Solarized%20Flatiron.zip" -o "Solarized Flatiron.zip"
#   tar -zxvf "Solarized Flatiron.zip"
#   rm "Solarized Flatiron.zip"
  
#   cd "$HOME/Library/Application Support/Sublime Text 2/Packages/Default"
#   sed -i "s/\"color_scheme\": \"Packages\/Color Scheme - Default\/Monokai.tmTheme\",/\"color_scheme\": \"Packages\/Color Scheme - Default\/Solarized Light (Flatiron).tmTheme\",/g" Preferences.sublime-settings
#   sed -i "s/\"tab_size\": 4,/\"tab_size\": 2,/g" Preferences.sublime-settings
#   sed -i "s/\"translate_tabs_to_spaces\": false,/\"translate_tabs_to_spaces\": true,/g" Preferences.sublime-settings
# }

function completeSetup {
  echo "Done!"
}

editSudoers
copyBashProfile
installRVM
installNokogiri
getGitconfig
setupGemrc
getIrbrc
setupDirStructure
# setsUpSublimePreferences
restoreSudoers
completeSetup
