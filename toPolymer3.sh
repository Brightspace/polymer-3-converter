#!/bin/bash

if [ "$1" != "" ]; then
	echo "*** Commit Message: $1 ***"
	message=" - $1"
else
	message=""
fi

echo "*** Make Polymer 3 branch ***"
git checkout -b polymer-3-`date +%Y-%m-%d-%H%M%S` master

echo "*** Temporarily changing tabs to spaces for all js and html files ***"
array=(`find . \( -name "*.html" -o -name "*.js" \) -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original 's/	/    /g' $line
	rm -f $line.original
done

echo "*** Temporarily add this script to the .gitignore file ***"
echo "toPolymer3.sh" >> ./.gitignore

echo "*** Committing this change as the modulizer needs a clean repo ***"
git add -u
git commit -m "Temporarily change tabs to spaces for modulizer"

echo "*** Run bower install ***"
rm -rf bower_components
rm -rf bower_components-1.x
rm -f bower-1.x.json
npm install -g bower
bower install

echo "*** Remove node_modules folder (Windows issue, otherwise you get a heap stack error) ***"
rm -r node_modules

echo "*** Run the modulizer ***"
npm install -g polymer-modulizer
modulizer --out .

echo "*** Discard the travis file changes (they are not needed) ***"
git checkout .travis.yml

echo "*** Update .eslintrc.json files ***"
array=(`find . -name "*.eslintrc.json" -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original "s/polymer-config/polymer-3-config/" $line
	sed -i.original "s/wct-config/wct-polymer-3-config/" $line
	rm -f $line.original
done

echo "*** Update polymer.json files ***"
array=(`find . -name "polymer.json" -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original "2i\  \"npm\": true," $line
	sed -i.original "s/2-hybrid/3/" $line
	rm -f $line.original
done

echo "*** Replace uses of bower_components with node_modules in .scss files ***"
array=(`find . -name "*.scss" -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original "s/bower_components/node_modules/g" $line
	rm -f $line.original
done

echo "*** Replace \\$ with just $ in .js files ***"
array=(`find . -name "*.js" -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original "s/[\]\\$=/\$=/g" $line
	rm -f $line.original
done

echo "*** Fix test html files (remove extra <script> tag) ***"
array=(`find . -path "./test/*.html" -not \( -path "./test/acceptance/*" \)`)
for line in "${array[@]}"
do
	sed -i.original -z "s/<script>\n *<script type=\"module\">/<script type=\"module\">/" $line
	rm -f $line.original
done

echo "*** Update .eslintignore file ***"
if !(grep -q "test/acceptance/*" .eslintignore); then
	echo "test/acceptance/*" >> .eslintignore
fi
if !(grep -q "reports" .eslintignore); then
	echo "reports" >> .eslintignore
fi

echo "*** Add webcomponentsjs to package.json ***"
npm i --save-dev --package-lock-only --no-package-lock @webcomponents/webcomponentsjs

echo "*** Add polymer-cli to package.json ***"
npm i --save-dev --package-lock-only --no-package-lock polymer-cli@latest

echo "*** Add babel-eslint to package.json ***"
npm i --save-dev --package-lock-only --no-package-lock babel-eslint

echo "*** Add @babel/polyfill to package.json (for IE11 test fix) ***"
npm i --save-dev --package-lock-only --no-package-lock @babel/polyfill

echo "*** Add babel polyfill to test files (for IE11 test fix) ***"
array=(`find . -path "./test/*.html" -not \( -path "./test/acceptance/*" -o -path "./test/index.html" \)`)
for line in "${array[@]}"
do
	sed -i.original '/webcomponents-bundle.js/i\        <script src=\"..\/..\/@babel\/polyfill\/browser.js\"><\/script>' $line
	rm -f $line.original
done

echo "*** Remove postinstall from package.json ***"
sed -i.original "/\"postinstall\":/d" package.json

echo "*** Update linting in package.json ***"
sed -i.original "/\"lint\":/c\    \"lint\": \"npm run lint:wc && npm run lint:js\"," package.json
sed -i.original "/\"lint:html\":/c\    \"lint:js\": \"eslint . test/** demo/** --ext .js,.html\"," package.json
rm -f package.json.original

echo "*** Convert d2l bower components to polymer-3 npm versions ***"
declare -A dependencies
dependencies["d2l-colors"]="git+https://github.com/BrightspaceUI/colors.git#polymer-3"
dependencies["d2l-typography"]="git+https://github.com/BrightspaceUI/typography.git#polymer-3"
dependencies["d2l-offscreen"]="git+https://github.com/BrightspaceUI/offscreen.git#polymer-3"
dependencies["d2l-polymer-behaviors"]="git+https://github.com/Brightspace/d2l-polymer-behaviors-ui.git#polymer-3.x"
dependencies["d2l-icons"]="git+https://github.com/BrightspaceUI/icons.git#polymer-3"
dependencies["d2l-button"]="git+https://github.com/BrightspaceUI/button.git#polymer-3"
dependencies["d2l-link"]="git+https://github.com/BrightspaceUI/link.git#polymer-3"

array=(`grep -i "^    \"d2l-.*\":" bower.json | cut -d"\"" -f2`)
for line in "${array[@]}"
do
	echo $line
	if [ ${dependencies[$line]} ]
	then
		echo ${dependencies[$line]}
		npm i --save --package-lock-only --no-package-lock ${dependencies[$line]}
	fi
done

echo "*** Remove bower_components directory and bower.json ***"
rm -rf bower_components
rm -f bower.json

echo "*** Convert spaces back to tabs for the html and js files ***"
array=(`find . \( -name "*.html" -o -name "*.js" \) -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original 's/    /	/g' $line
	rm -f $line.original
done

echo "*** Commit Polymer 3 conversion changes ***"
git add -A
git commit -m "Polymer 3 Conversion $message"

echo "*** Cleanup .gitignore file ***"
sed -i.original "/\(bower*\|toPolymer3.sh\)/d" .gitignore
rm -f .gitignore.original

echo "*** Commit .gitignore file ***"
git add .gitignore
git commit -m "Cleanup .gitignore file"

echo "*** Squash commits for better review experience (no merge conflicts) ***"
git reset --soft master
git add -A
git reset -- toPolymer3.sh
git commit -m "Polymer 3 Conversion $message"
