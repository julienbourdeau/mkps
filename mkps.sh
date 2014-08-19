#!/bin/bash

red='\e[0;31m'
green='\e[0;32m'
orange='\e[0;33m'
NC='\e[0m' # No Color

remoteGitRepo="git@github.com:PrestaShop/PrestaShop.git"
defaultRootDir="/var/www/"
defaultDir="PrestaShop"

db_pass="_root_"

cd $defaultRootDir

if [ -d $defaultRootDir$defaultDir ]; then 	
	echo -e "${orange}Deleting existing $defaultRootDir$defaultDir ${NC}"
	sudo rm -rf $defaultRootDir$defaultDir
fi

echo -e "${green}Cloning remote git repository ${NC}"
git clone $remoteGitRepo

cd $defaultDir

echo -e "${green}Initializing repository submodules ${NC}"
git submodule init 2>/dev/null
echo -e "${green}Updating repository submodules ${NC}"
git submodule update 2>/dev/null

echo -e "${green}Installing PrestaShop ${NC}"
php ./install-dev/index_cli.php --domain=prestashop.ps --db_server=localhost --db_name=prestashop --db_user=root --db_password=$db_pass

echo -e "${green}Moving each module to 'dev' branch ${NC}"
git submodule foreach git checkout dev 2>/dev/null
git submodule foreach git pull --no-rebase 2>/dev/null

echo -e "${green}Tweaking git repository ${NC}"
git config core.fileMode false 2>/dev/null
git foreach git config core.fileMode false 2>/dev/null
git submodule foreach git config --global url.ssh://git@github.com/.insteadOf https://github.com/

echo -e "${green}Installing git hooks ${NC}"
cd .git/hooks
wget https://raw.githubusercontent.com/PrestaShop/standard_coding_hook/master/commit-msg 2>/dev/null
wget https://raw.githubusercontent.com/PrestaShop/standard_coding_hook/master/pre-commit 2>/dev/null

