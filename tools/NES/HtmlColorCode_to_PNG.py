#!/usr/bin/python
'''
Script: HtmlColorCode_to_PNG.py
(The script file name can be changed.)
Author: Loic GUYADER (froggy77)
Copyright: 2021
License: GPL
Version: 1.0.0
Date: 2021/01/03
Python version: 3.9.0

Description:
Draw an image (.png) from a list of HTML color code.
A square of 16 pixels * 16 pixels for each color.

HtmlColorCode_to_PNG.py -i <inputfile> -o <outputfile>
e.g.: HtmlColorCode_to_PNG.py -i myFile.dat -o NewImage.png

If <outputfile> already exists, add '-f' to force the command. 
e.g.: HtmlColorCode_to_PNG.py -i myFile.dat -o NewImage.png -f

- <inputfile> is a text file (.dat, .txt ...) containing the colors.
Example of a list of HTML color code:
#646464
#aeaeae
#ffffff
#002d69
#0f63b3
#bcdfff

- <outputfile> is the image (.png)

- The input file and output file do not allow spaces in the name.

- Help:
HtmlColorCode_to_PNG.py -h

'''

# Library
import sys, getopt, os, re
from PIL import Image, ImageColor, ImageDraw

# Main function
def main(argv):

    # Tile size
    tileSize = 16
    # Files
    inputfile = ''
    outputfile = ''
    # Messages
    titleError = '---------\n  ERROR\n---------'
    msgCommand = str(sys.argv[0]) + ' -i <inputfile> -o <outputfile>'
    msgHelp = 'Type "' + str(sys.argv[0]) + ' -h" for help.'
    msgForce = 'Add "-f" to force the command if the output file already exists.\nIMPORTANT: The file wil be replaced.'
    msgExample = 'e.g.: ' + str(sys.argv[0]) + ' -i myFile.dat -o NewImage.png'
    # Test the options and the arguments of the command.
    try:
        opts, args = getopt.getopt(argv,'hi:o:f',['ifile=','ofile='])
    except getopt.GetoptError:
        print (titleError)
        print (msgCommand)
        print(msgHelp)
        sys.exit(2)
    force = False
    for opt, arg in opts:
        if opt == '-h':
            print ('--------\n  HELP\n--------')
            print (msgCommand + '\n')
            print(msgExample)
            print('(myFile.dat containing the list of html color codes.)\n')
            print (msgForce + '\n')
            print(msgExample, '-f')
            sys.exit()
        elif opt == '-f':
            force = True
        elif opt in ('-i', '--ifile'):
            inputfile = arg
        elif opt in ('-o', '--ofile'):
            outputfile = arg

    if (len(sys.argv) < 5):
        print (titleError)
        print ("- Warning: Missing argument.")
        print (msgCommand)
        print(msgHelp)
        sys.exit()
    elif (inputfile != '') or (outputfile != ''):
        if (len(sys.argv) >= 5):
            currentPath = os.getcwd()
            pList = currentPath + "\\" + inputfile
            pImg = currentPath + "\\" + outputfile
            # NO GO; need to force because the output file already exists.
            if (not os.path.isfile(pList)) or (os.path.isfile(pImg) and not force):
                print (titleError)
                if not(os.path.isfile(pList)):
                    print ('- Warning: The file "' + inputfile + '" does not exist.')
                if (os.path.isfile(pImg) and not force):
                    print ('- Warning: The image "' + outputfile + '" already exists.')
                    print (msgForce)
                sys.exit()
            # GO
            else:
                # Read the input file for the list of html color codes.
                fList = open(pList, "r")
                Lines = fList.readlines()
                regexHtml = r"^#[0-9a-fA-F]{6}"
                count = 0
                colors = []
                for line in Lines:
                    if re.match(regexHtml, line):
                        color = ImageColor.getcolor(line, "RGB")
                        colors.append(color)
                        count += 1
                fList.close()

                # Draw the palette of colors from input file into output file.
                img = Image.new('RGB', (tileSize, count * tileSize), (255, 255, 255))
                draw = ImageDraw.Draw(img)
                length = len(colors)
                count = 0
                for i in range(length):
                    draw.rectangle((0, (count * tileSize), ((count + 1) * tileSize), ((count + 1) * tileSize)), fill = colors[i])
                    count += 1

                # Save the output file (.png)
                img.save(pImg, "PNG")
                print('The file "' + pImg + '" has been created successfully.')


if __name__ == "__main__":
    main(sys.argv[1:])