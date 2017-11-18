#!/usr/bin/env bash

# DevToolit is a small script to get you started with prototyping front-end designs using scss

# colours

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
DEFAULT='\033[0m'
WARNING='\033[1;31m'

# commands


# core functions ------
project_location() {
  read -p "Enter application name: " appname
  echo "Where would you like to save this project?"
  echo ${GREEN}"Default app location is: $PWD/$appname" ${DEFAULT}
  read -p "Enter app root location: " location
  if [ "$location" = "" ]; then
    app_path=$PWD/$appname
  else
    app_path="$location/$appname"
  fi
}

create_dir() {
  mkdir -p $app_path
  notify-send -i /usr/share/icons/suru/actions/scalable/clock.svg "Starting project: $appname..." "`date`"
  notify-send -i /usr/share/icons/suru/actions/scalable/tick.svg "Success!" "Project started at: $app_path"
  echo ${GREEN}"Project started at: $app_path" ${DEFAULT}
  enter_dir() {
    cd $app_path
  }

  enter_dir
}

enter_dir() {
  cd $app_path
}

file_check() {
  if [ -f $app_path/gulpfile.js ] && [ -s $app_path/gulpfile.js ] && [ -s $app_path/app/index.html ]; then
    echo ${RED}"ERROR: Directory already contains a project! "${DEFAULT}
    echo "$app_path"
    echo ${RED}"Please specify another directory."${DEFAULT}
    echo ${RED}"-----------------------------ERROR----------------------------"${DEFAULT}
    read ERROR
    project_location
  fi
}

# installing nodejs the right way using nvm
node_install() {
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
    source ~/.bashrc
    export NVM_DIR="/home/$USER/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 
    nvm install stable
}

node_install_message() {
  echo "NodeJS installation complete. Please restart this script to bootstrap your application. Press Enter to continue."
  read restart
  . ~/.bashrc
  exit
}

node_check() {
  echo ${GREEN}DEPENDENCY VERIFICATION${DEFAULT}
  [ "nvm --version" > /dev/null ]
  if [ "$?" = "0" ]; then
    local npm_version=$(node -v)
    local node_version=$(npm -v)
    echo ${GREEN}NodeJS $node_version "is present, executing next instruction..."${DEFAULT}
    echo ${GREEN}npm $npm_version "is present, executing next instruction..."${DEFAULT}
    echo ${GREEN}"-----------------------------READY----------------------------"${DEFAULT}
  else
    echo ${RED}"NodeJS not present, not executing."${DEFAULT}
    echo ${YELLOW}"Would you like to install node automatically? [Yes/No]"${DEFAULT}
    read response

    case $response in
      [Yy]* ) node_install; node_install_message; break;;
      [Nn]* ) echo ${RED}NodeJS not present, please head over to https://nodejs.org/en to download the latest version of nodejs before proceeding.${DEFAULT} exit;;
      * ) echo ${RED}"Invalid option: Please type Yes or No"${DEFAULT}
    esac
    echo ${RED}-----------------------------ERROR----------------------------${DEFAULT}
    read ERROR
    exit
  fi
}

create_structure() {
  echo ${YELLOW}Step 1: Creating structure...${DEFAULT}
  echo $app_path
  mkdir -p $app_path/app/assets/css && mkdir -p $app_path/app/assets/scss && touch $app_path/app/assets/scss/styles.scss && mkdir -p $app_path/app/assets/js && touch $app_path/app/assets/js/app.js && mkdir -p $app_path/app/assets/fonts
  mkdir -p $app_path/app/public/images && touch $app_path/app/index.html && touch $app_path/gulpfile.js
  echo ${GREEN}Structure successfully created.${DEFAULT}
  echo ${GREEN}-------------------------------${DEFAULT}
}

npm_init() {
  echo ${YELLOW}"Step 2: Initialising npm..."${DEFAULT}
  npm init
  if [ $? != 0 ]; then
    ${RED}echo "You can also check this guide on how to fix npm permission issues:"
    echo "https://docs.npmjs.com/getting-started/fixing-npm-permissions"${DEFAULT}
  fi
}

npm_gulp() {
  echo ${YELLOW}"Step 3: Installing gulp globally..."${DEFAULT}
  gulp -v > /dev/null
  if [ "$?" = "0" ]; then
    echo ${GREEN}"Gulp already installed, proceeding to next instruction..."${DEFAULT}
  else
    npm install gulp -g
  fi
}

npm_dependencies() {
  echo ${YELLOW}"------------------------------------"${DEFAULT}
  echo ${YELLOW}"Step 4: INSTALLING DEPENDENCIES"${DEFAULT}
  echo ${YELLOW}"------------------------------------"${DEFAULT}
}

npm_gulp_local() {
  echo ${GREEN}"DEPENDENCY: gulp-dev..."${DEFAULT}
  npm install gulp --save-dev
}

npm_gulp_sass() {
  echo ${GREEN}"DEPENDENCY: gulp-sass..."${DEFAULT}
  npm install gulp-sass --save-dev
}

npm_browser_sync() {
  echo ${GREEN}"DEPENDENCY: browser-sync..."${DEFAULT}
  npm install browser-sync --save-dev
}

gulp_setup() {
  echo ${YELLOW}"Step 5: Setting up your gulp file - writing tasks..."${DEFAULT}
    # writing the gulp tasks...
    cat <<EOT >> $app_path/gulpfile.js
  var gulp = require('gulp');
  var sass = require('gulp-sass');
  var browserSync = require('browser-sync').create();

  gulp.task('sass', function(){
    return gulp.src('app/assets/scss/**/*.scss')
      .pipe(sass())
      .pipe(gulp.dest('app/assets/css'))
      .pipe(browserSync.reload({
        stream: true
      }))
  });

  gulp.task('watch', function(){
    gulp.watch('app/assets/scss/**/*.scss', ['sass']);
  })

  gulp.task('browserSync', function() {
    browserSync.init({
      server: {
        baseDir: 'app'
      },
    })
  })

  gulp.task('watch', ['browserSync', 'sass'], function (){
    gulp.watch('app/assets/scss/**/*.scss', ['sass']);
  });
EOT

#Clean terminal display
clear
}

last_stage() {
  curl -sSL https://gist.githubusercontent.com/VEEGISHx/35a5829fb45761e9f5c982b642b0c01b/raw/c91d3cd7eb4af6ba3921f03870c517d57f2f5f4b/index.html > $app_path/app/index.html
  curl -sSL https://gist.githubusercontent.com/VEEGISHx/0cffb649e44814739c8f4038a4c2f814/raw/e8051d5b8eb6c8c09fb2c705699e1bbc27f199e4/style.css > $app_path/app/assets/scss/styles.scss
}

success_message() {
  notify-send -i /usr/share/icons/suru/actions/scalable/tick.svg "Setup complete!" "Start your server by running the command 'gulp watch' inside $app_path"
  echo ${GREEN}"------------------------------------"${DEFAULT}
  echo ${GREEN}"SETUP COMPLETE"${DEFAULT}
  echo ${GREEN}"------------------------------------"${DEFAULT}
  if [ $(id -u) = 0 ]; then
    echo ${RED}"IMPORTANT: Looks like you used sudo to run this script, you need to change the ownership of the app folder in order to allow modifications as a non-root user by running the following command:"${DEFAULT}
    echo ${YELLOW}"sudo chown -R $""USER app"${DEFAULT}
  fi
  echo "Run the command ${YELLOW}gulp watch${DEFAULT} and start prototyping!"
  echo ${GREEN}"Have fun building stuff!"${DEFAULT}
}

# Initial stage

# Permission check
if [ $(id -u) = 0 ]; then
  echo ${WARNING}"Warning: It is highly recommended not to run this script as root since there is no need to. If somehow you are facing permission issues, please reinstall node without using sudo."${DEFAULT}
  read Error
fi


# Getting started
echo "Hello $USER, ready to get started? [Yes/No]"

read answer

case $answer in
    [Yy]* ) node_check; project_location; file_check; create_dir; create_structure; npm_init; npm_gulp; npm_dependencies; npm_gulp_local; npm_gulp_sass; npm_browser_sync; gulp_setup; last_stage;enter_dir; success_message break;;
    [Nn]* ) exit;;
    * ) echo "Error: Please answer yes or no.";;
esac
