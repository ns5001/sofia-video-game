import os
import sys
import platform;

splitchar = "/"

if platform.system() == 'Windows':
	print( "\nWindows system" )
	splitchar = "\\"

rootdir = './assets'

allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'

def cleanString( string ):
	filen = os.path.splitext(string)
	s = list(filen[0])
	for i,c in enumerate(s):
		if s[i] not in allowedChars:
			s[i] = '_'
	return "".join(s) + "".join(list(filen[1]))

print "\nScrubbing Asset Folder Names:\n"

for subdir, dirs, files in os.walk(rootdir):
    for file in files:
    	os.rename( subdir + splitchar + file, subdir + splitchar + cleanString( file ) )
    	