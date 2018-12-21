
if [ "$1" != "" ]; then
	echo "*** Commit Message: $1 ***"
	message=" - $1"
else
	message=""
fi

echo "*** Make Polymer 3 branch ***"
git checkout -b polymer-3-`date +%Y-%m-%d-%H%M%S`

echo "*** Remove index.html and all-imports.html ***"
rm -f index.html
rm -f all-imports.html

echo "*** Temporarily changing tabs to spaces for all js and html files ***"
array=(`find . \( -name "*.html" -o -name "*.js" \) -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -i.original 's/	/    /g' $line
	rm -f $line.original
done

echo "*** Temporarily add this script and dependency map to the .gitignore file ***"
echo "toPolymer3.sh" >> ./.gitignore
echo "dependency-map.txt" >> ./.gitignore

echo "*** Committing this change as the modulizer needs a clean repo ***"
git add -u
git commit -m "Cleanup files and temporarily change tabs to spaces for modulizer"

echo "*** Run bower install ***"
rm -rf bower_components
rm -rf bower_components-1.x
rm -f bower-1.x.json
npm install -g bower
bower install

echo "*** Remove node_modules folder (Windows issue, otherwise you get a heap stack error) ***"
rm -rf node_modules

echo "*** Run the modulizer ***"
npm install -g polymer-modulizer
curl https://raw.githubusercontent.com/Brightspace/polymer-3-converter/master/dependency-map.txt -o dependency-map.txt
echo | modulizer --import-style name --out . --dependency-mapping $(cat dependency-map.txt | tr '\
' ' ' | tr -d '\r')

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
	sed -i.original '2i\
\  \"npm\": true,
' $line
	sed -i.original "s/2-hybrid/3/" $line
	sed -i.original "s/polymer-2/polymer-3/" $line
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

echo "*** Fix import { Element } in .js files ***"
array=(`find . -name "*.js" -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -E -i.original "s,import \{ Element \} from '(..\/)?@polymer\/polymer\/polymer-element.js';,// WORKAROUND: polymer-modulizer grabs non-existing Element export from polymer-element\\
// TODO: Remove Element reference\\
import { PolymerElement as Element } from '@polymer/polymer/polymer-element.js';,g" $line
	rm -f $line.original
done

echo "*** Fix ResizeObserver path ***"
array=(`find . -name "*.js" -not \( -path "./node_modules*" -o -path "./bower_components*" -o -path "./.git*" \)`)
for line in "${array[@]}"
do
	sed -E -i.original "s,import '(..\/)?resize-observer-polyfill\/resize-observer.js';,import ResizeObserver from 'resize-observer-polyfill/dist/ResizeObserver.es.js';,g" $line
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

echo "*** Remove postinstall from package.json ***"
sed -i.original "/\"postinstall\":/d" package.json

echo "*** Update linting in package.json ***"
sed -i.original '/\"lint\":/c\
\    \"lint\": \"npm run lint:wc && npm run lint:js\",
' package.json
sed -i.original '/\"lint:js\":/c\
\    \"lint:js\": \"eslint . --ext .js,.html test/**/*.js test/**/*.html demo/**/*.js demo/**/*.html\",
' package.json
sed -i.original '/\"lint:html\":/c\
\    \"lint:js\": \"eslint . --ext .js,.html test/**/*.js test/**/*.html demo/**/*.js demo/**/*.html\",
' package.json
sed -i.original '/\"lint:wc\":/c\
\    \"lint:wc\": \"polymer lint\",
' package.json
sed -i.original '/\"test:lint\":/c\
\    \"test:lint\": \"npm run test:lint:wc && npm run test:lint:js\",
' package.json
sed -i.original '/\"test:lint:js\":/c\
\    \"test:lint:js\": \"eslint . --ext .js,.html test/**/*.js test/**/*.html demo/**/*.js demo/**/*.html\",
' package.json
sed -i.original '/\"test:lint:html\":/c\
\    \"test:lint:js\": \"eslint . --ext .js,.html test/**/*.js test/**/*.html demo/**/*.js demo/**/*.html\",
' package.json
sed -i.original '/\"test:lint:wc\":/c\
\    \"test:lint:wc\": \"polymer lint\",
' package.json
rm -f package.json.original

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
sed -i.original "/bower*/d" .gitignore
sed -i.original "/toPolymer3.sh/d" .gitignore
sed -i.original "/dependency-map.txt/d" .gitignore
rm -f .gitignore.original

echo "*** Commit .gitignore file ***"
git add .gitignore
git commit -m "Cleanup .gitignore file"

echo "*** Squash commits for better review experience (no merge conflicts) ***"
git reset --soft master
git add -A
git reset -- toPolymer3.sh
git reset -- dependency-map.txt
git reset -- README.md
git checkout README.md
git commit -m "Polymer 3 Conversion $message"

echo "*** Remove package-lock.json file ***"
rm -f package-lock.json

echo "*** Re-install npm dependencies ***"
npm i
