# polymer-3-converter

**Tested on:**
- Windows 10 - Git Bash
- MacOS Sierra (10.12.6) - Bash

The purpose of this script is to help convert a hybrid Polymer 1 web component to Polymer 3, using `polymer-modulizer`.

## Before Converting

In order to keep the script simple, it assumes some things about how the repo is setup.  It's easiest to make these changes in master first, before making the `hybrid` branch and running the converter.  Some things to look for:
- It looks for the following set of linting commands to update, and you should use one of these naming conventions:
  - `lint`, `lint:html` and `lint:wc`
  - `test:lint`, `test:lint:html` and `test:lint:wc`
- You'll want to have `strip-whitespace` in the `template` to get a consistent output style from the modulizer

You should also make sure the components work in Shadow DOM _before_ converting. See: [Polymer 3 Test Plan](polymer-3-testplan.md).

## How to convert a Hybrid web component to a Polymer 3 web component

1. Make sure you are on the master branch and have pulled the latest changes
2. Branch off master and create a `hybrid` branch
3. Switch back to the master branch
4. Make sure you have no uncommitted changes
5. Add the `toPolymer3.sh` file to the root of the component repo you are converting
6. Run `./toPolymer3.sh "<optional_commit_message>"`
7. Apply any special repo patches (found in the `/patches` folder of this repo) with `git apply <patch_name>`
8. Put up the PR against master
9. If there are specific repo issues you need to make after running the script (for example, special galen changes), you can save those as a patch and add it to the `/patches` folder here.
10. Once all is good, merge!
11. Make a major release against master
12. Make sure to check the `dependency-map.txt` file in the repo has the correct major version, so all further conversions can use the polymer 3 version of this component.

## If changes have occurred on the hybrid branch, and you need to update master/polymer 3

1. Go to the hybrid branch and pull the latest changes
2. Make sure you have no uncommitted changes
3. Add the `toPolymer3.sh` file to the root of the repo
4. Run `./toPolymer3.sh "<optional_commit_message>"`
5. Apply any special repo patches (found in the `/patches` folder of this repo) with `git apply <patch_name>`
6. Put up the PR against master
7. If all is good (you see the same changes as made to the hybrid branch), merge and make a release!

## Testing

See: [Polymer 3 Test Plan](polymer-3-testplan.md).
