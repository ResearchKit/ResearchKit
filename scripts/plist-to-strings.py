#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2015, Ricardo Sánchez-Sáez. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1.  Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 
# 2.  Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
# 
# 3.  Neither the name of the copyright holder(s) nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission. No license is granted to the trademarks of
# the copyright holders even if such marks are included in this software.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This script reads and converts a binary .strings file (binary .plist) into a plaintext .string file.
#
# Since binary .strings files are generally unsorted, it takes a master plaintext .strings file
# (typically en.lproj/Localizable.strings) and uses it for sorting they keys in the target converted file.
#
# The target file can have all or some of the string keys in the master file. If the master file has
# additional string keys not found in the target file, they are ignored.
# String keys present in the target file but not present in the master file are added at the end of the
# converted file in an undefined order.
#
# This script has been tested with Python 2.7.6. You need to have Xcode Command Line Tools installed (it uses plutil).
#
# Single file usage example:
#   ./plist-to-strings.py -m en.lproj/ResearchKit.strings -t es.lproj/ResearchKit.strings
#
# Whole project usage example (using 'en.lproj' as the master plaintext localization):
#   localizedFolder="../ProjectPath/Localized"; for languageFolder in $(ls $localizedFolder); do if [[ "$languageFolder" != "en.lproj" ]]; then ./plist-to-strings.py -m ${localizedFolder}/en.lproj/Localizable.strings -t ${localizedFolder}/${languageFolder}/Localizable.strings; fi; done

import argparse
import os
import plistlib
import shutil
import subprocess
import sys
import uuid

def warning(string):
    sys.stdout.write("WARNING: " + string + '\n\n')

def error(string):
    sys.stderr.write("ERROR: " + string + '\n\n')

parser = argparse.ArgumentParser()
parser.add_argument('-m', '--master', help='Master plain text .strings file', required=True)
parser.add_argument('-t', '--target', help='Target binary plist .strings file to convert to plain text', required=True)
args = parser.parse_args()
masterFileName = args.master
targetFileName = args.target

def checkIfEssentialFileExists(fileName, fileTag):
    if not os.path.isfile(fileName):
        print(fileTag + ' .strings file not found: ' + fileName + '\n')
        parser.print_usage()
        sys.exit(1)

checkIfEssentialFileExists(masterFileName, "Master")
checkIfEssentialFileExists(targetFileName, "Target")

def convertBinaryPlistToStrings(masterFileName, targetFileName):
    def buildStringsLine(stringKey, localizedString):
        # escape '\', '"', '\n' and '\r' characters on the target plain text string
        escapedString = localizedString.replace('\\', '\\\\').replace('"','\\"').replace('\n','\\n').replace('\r','\\r')
        return '"' + stringKey + '" = "' + escapedString + '";\n'

    outputEncoding = 'UTF-8'

    targetFileNameWithoutExtension = os.path.splitext(targetFileName)[0]
    UUID = uuid.uuid1() 
    temporaryTargetFileName = targetFileNameWithoutExtension + '.' + UUID.hex + '.strings.plist'
    shutil.copyfile(targetFileName, temporaryTargetFileName)

    # convert binary .strings.plist to hex .strings.plist 
    subprocess.call(['plutil', '-convert', 'xml1', temporaryTargetFileName])
    targetPlist = plistlib.readPlist(temporaryTargetFileName)

    masterFile = open(masterFileName)

    temporaryOutputFileName = targetFileNameWithoutExtension + '.' + UUID.hex + '.strings'
    temporaryOutputFile = open(temporaryOutputFileName, 'w')

    for line in masterFile:
        # preserve comments and blank lines
        # warning: multiline comments cannot have a line starting with the double quote character " 
        if len(line.strip())==0 or line.strip()[0] != '"':
            temporaryOutputFile.write(line.encode(outputEncoding))
        
        else:
            # get appropriate string from target plist, convert it, and write to output
            
            # master line example:             "CONSENT_NAME_TITLE" = "Consent";
            # master tokenizedLine example:    ['', 'CONSENT_NAME_TITLE', ' = ', 'Consent', ';']
        
            # remove escaped \\ and \" so they don't interfere with the tokenizer (we don't need the correct master string)
            intermediateLine = line.strip().replace('\\\\', '').replace('\\"','')
            tokenizedLine = intermediateLine.split('"')
        
            # ignore abnormal lines (these should not appear)
            if len(tokenizedLine) != 5:
                error("Ignoring malformed line:" + line.strip())
                continue
            
            stringKey = tokenizedLine[1]
            if stringKey not in targetPlist:
                warning("String key not found in target file: " + stringKey)
                continue
            
            targetLine = buildStringsLine(stringKey, targetPlist[stringKey])
            temporaryOutputFile.write(targetLine.encode(outputEncoding))
            
            del targetPlist[stringKey]

    # Add remaining target string keys
    if len(targetPlist) > 0:        
        temporaryOutputFile.write("\n\n/* Unsorted */\n")
        for stringKey in targetPlist:
            targetLine = buildStringsLine(stringKey, targetPlist[stringKey]).encode(outputEncoding)
            temporaryOutputFile.write(targetLine)

    temporaryOutputFile.close()
    masterFile.close()
    
    os.remove(temporaryTargetFileName)
    os.rename(temporaryOutputFileName, targetFileName)


print('Converting: ' + targetFileName)
convertBinaryPlistToStrings(masterFileName, targetFileName)
print('...done')
