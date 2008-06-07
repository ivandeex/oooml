#!/bin/bash
WS_DIR=/home/vit/workspace
SAXON_DIR=/home/vit/bin/docbook/saxon8
SAXON_JARS=$SAXON_DIR/saxon8.jar:$SAXON_DIR/saxon8-dom.jar
CP=$WS_DIR/word2ooo/bin/word2ooo.jar:$WS_DIR/rtf7/bin/v7rtf.jar:$SAXON_JARS
java -Xmx256m -cp $CP net.vitki.ooo7.ConvertToDocBook "$@"
