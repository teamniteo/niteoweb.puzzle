#!/bin/bash
# to install: $ ln -s ../../pre-commit-check.sh .git/hooks/pre-commit
# TODO: check for exit code of each command
# TODO: stash changes before doing tests: http://codeinthehole.com/writing/tips-for-using-a-git-pre-commit-hook/

function handle_exit {
    if [ $? -ne 0 ]; then
        EXITCODE=1
    fi
}

EXITCODE=0

echo 'Running tests'
bin/test; handle_exit

echo '====== Running ZPTLint ======'
for pt in `find src/niteoweb/puzzle/ -name "*.pt"` ; do bin/zptlint $pt; done
for xml in `find src/niteoweb/puzzle/ -name "*.xml"` ; do bin/zptlint $xml; done
for zcml in `find src/niteoweb/puzzle/ -name "*.zcml"` ; do bin/zptlint $zcml; done

echo '====== Running PyFlakes ======'
bin/zopepy setup.py flakes; handle_exit

echo '====== Running pep8 =========='
bin/pep8 --ignore=E501 --count src/niteoweb/puzzle; handle_exit
bin/pep8 --ignore=E501 --count setup.py; handle_exit

if [ $EXITCODE -ne 0 ]; then
    exit 1
fi
