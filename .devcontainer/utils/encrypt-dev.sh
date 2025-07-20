#!/bin/bash

#enc
openssl enc -aes-256-cbc -salt -pbkdf2 -in file.txt -out file.enc -pass pass:laTuaPassword
#dec
openssl enc -d -aes-256-cbc -pbkdf2 -in file.enc -out file.txt -pass pass:laTuaPassword
