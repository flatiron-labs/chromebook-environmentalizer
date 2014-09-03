#!/bin/bash

trap restoreSudoers INT

echo_yellow()
{
  YELLOW=$(tput setaf 3)
  NORMAL=$(tput sgr0)
  echo "${YELLOW}$1${NORMAL}"
}

function editSudoers {
  echo_yellow "\n"
  echo_yellow "Setting up..."
  cd ~
  
  curl "https://raw.githubusercontent.com/flatiron-labs/chromebook-environmentalizer/master/edit_sudoers.sh" -o "edit_sudoers.sh"
  chmod a+rx edit_sudoers.sh && sudo ./edit_sudoers.sh $USER && rm edit_sudoers.sh
}

function restoreSudoers {
  echo_yellow "\n"
  echo_yellow "Cleaning up..."
  cd ~

  curl "https://raw.githubusercontent.com/flatiron-labs/chromebook-environmentalizer/master/restore_sudoers.sh" -o "restore_sudoers.sh"
  chmod a+rx restore_sudoers.sh && sudo ./restore_sudoers.sh && rm restore_sudoers.sh
}

function copyBashProfile {
  echo_yellow "\n"
  echo_yellow 'Getting Flatiron School .bashrc...'
  cd ~
  
  if [ -f .bashrc ]; then
    mv .bashrc .bashrc.old
  fi

  curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/bashrc" -o ".bashrc"
}

function installRVM {
  echo_yellow "\n"
  echo_yellow 'Installing RVM and Ruby 2.1.2...'
  cd ~

  \curl -L https://get.rvm.io | bash -s stable --ruby=2.1.2
  source $HOME/.bashrc
  source $HOME/.rvm/scripts/rvm

  rvm use 2.1.2 --default
}

function installNokogiri {
  echo_yellow "\n"
  echo_yellow 'Installing Nokogiri... This could be a while...'
  cd ~
  gem install nokogiri
}

function getGitconfig {
  echo_yellow "\n"
  echo_yellow "Setting up .gitconfig and GitHub SSH Key..."
  cd ~
  
  if [ -f .gitconfig ]; then
    mv .gitconfig .gitconfig.old
  fi

  curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/gitconfig" -o ".gitconfig"
  sed -i "s/<YOUR HOME DIRECTORY>/$USER/g" .gitconfig

  YELLOW=$(tput setaf 3)
  NORMAL=$(tput sgr0)

  echo_yellow "\n"
  echo_yellow 'You will now be prompted to for your github information.'
  echo_yellow 'If you do not have an account create one at github.com'
  echo_yellow 'Right click on the link above and select "Open Link"'
  printf "Enter your GitHub username: "
  read username < /dev/tty

  printf "Enter your GitHub email address: "
  read email < /dev/tty

  echo_yellow 'You will need to set up an apikey with Github.'
  echo_yellow 'Follow these steps to create one'
  echo_yellow 'Visit https://github.com/settings/tokens/new to set one up.'
  echo_yellow 'You MUST select at least, repo, public_repo, write:public_key, user, admin:public_key, and gist.'
  echo_yellow 'Call this token chromebook-environmentalizer and click Generate Token'
  echo_yellow 'Copy the token on the next page'
  echo_yellow 'paste into the command line with [CTRL + SHIFT + v] then press [ENTER]'
  printf "Enter your GitHub API key: "
  read apikey < /dev/tty

  sed -i "s/<github username>/$username/g" .gitconfig
  sed -i "s/<API token>/$apikey/g" .gitconfig
  sed -i "s/<github email address>/$email/g" .gitconfig

  if [ ! -f .ssh/id_rsa.pub ]; then
    ssh-keygen -t rsa -N '' -C "$username@github" -f "$HOME/.ssh/id_rsa"
  fi
  
  sshkey=$(cat $HOME/.ssh/id_rsa.pub)

  curl -s -u "$username:$apikey" https://api.github.com/user/keys -d "{\"title\":\"$username@github\",\"key\":\"$sshkey\"}"

  echo_yellow 'Connecting to Github. Please enter "yes" to continue.'
  ssh -T git@github.com

  exit 0

}

function getGitignore {
  echo_yellow "\n"
  echo_yellow 'Setting up .gitignore...'
  cd ~

  if [ -f .gitignore ]; then
    mv .gitignore .gitignore.old
  fi

  curl "http://bit.ly/flatiron-gitignore" -o ".gitignore"
}

function setupGemrc {
  echo_yellow "\n"
  echo_yellow 'Setting up .gemrc...'
  cd ~

  if [ -f .gemrc ]; then
    mv .gemrc .gemrc.old
  fi

  touch .gemrc
  echo_yellow "gem: --no-ri --no-rdoc" > .gemrc
}

function getIrbrc {
  echo_yellow "\n"
  echo_yellow 'Setting up .irbrc...'
  cd ~

  if [ -f .irbrc ]; then
    mv .irbrc .irbrc.old
  fi

  curl "https://gist.githubusercontent.com/loganhasson/f9fe9a73a1839ba1ef4a/raw/f65cef4fd4ac12d832e109eaca477c5b2dc686b0/.irbrc" -o ".irbrc"
}

function setupSublimePreferences {
  echo_yellow "\n"
  echo_yellow 'Setting Up SublimeText 3.0...'
  cd ~
  subl && sleep 3
  kill -15 $(ps aux | grep subl | grep -v grep | awk '{ print $2 }')
  
  cd "$HOME/.config/sublime-text-3/Installed Packages"
  curl "https://sublime.wbond.net/Package%20Control.sublime-package" -o "Package Control.sublime-package"

  cd "$HOME/.config/sublime-text-3/Packages"
  mkdir Color\ Scheme\ -\ Default
  cd Color\ Scheme\ -\ Default
  curl "http://flatironschool.s3.amazonaws.com/curriculum/resources/environment/themes/Solarized%20Flatiron.zip" -o "Solarized Flatiron.zip"
  unzip "Solarized Flatiron.zip"
  rm "Solarized Flatiron.zip" "Solarized Dark (Flatiron).terminal" "Solarized Light (Flatiron).terminal"
  
  cd "$HOME/.config/sublime-text-3/Packages/User"
  curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/Preferences.sublime-settings" -o "Preferences.sublime-settings"
}

function setupDirStructure {
  echo_yellow "\n"
  echo_yellow 'Setting up basic development directory structure...'
  cd ~

  mkdir -p Development/code
}

function setupPostgresUser {
  if [ -d /usr/bin/psql ]; then
    echo_yellow "\n"
    echo_yellow 'Setting up postgres user...'
    echo_yellow 'You will be required to enter your password again...'
    cd ~

    postgresExitCode=1
    while [[ $postgresExitCode -ne 0 ]]; do
      sudo -u postgres createuser -P $USER
      postgresExitCode=$?
      if [[ $postgresExitCode -ne 0 ]]; then
        echo_yellow "Sorry something went wrong. Try again."
      fi
    done

    sudo -u postgres createdb $USER
  fi
  # sudo touch /var/lib/postgresql/.psql_history
}

function deactivateChromebookEnvironmentalizer {
  if [ -f /usr/share/upstart/xdg/autostart/chromebook-environmentalizer.desktop ]; then
    sudo echo -e 'Hidden=true' >> /usr/share/upstart/xdg/autostart/chromebook-environmentalizer.desktop
  fi
}

function completeSetup {
  echo_yellow "\n"
  echo_yellow "Done!"
}

editSudoers
getGitconfig
setupPostgresUser
copyBashProfile
installRVM
installNokogiri
setupGemrc
getIrbrc
setupSublimePreferences
setupDirStructure
restoreSudoers
deactivateChromebookEnvironmentalizer
completeSetup
