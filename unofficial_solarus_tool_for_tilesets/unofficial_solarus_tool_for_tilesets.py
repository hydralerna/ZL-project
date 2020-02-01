#!/usr/bin/env python2
# --------------------------------------
#         (UNOFFICIAL SOLARUS TOOL)
# --------------------------------------
# GIMP Python plug-in Wizard for Solarus tilesets
# D A T  F I L E  C R E A T I O N  W I Z A R D
# F O R  S O L A R U S  T I L E S E T S
# --------------------------------------
# Version: 0.1.-alpha 2019.12.28
# This script was tested with GIMP v2.10.10 on Windows
# Author: Loic Guyader
# loic.guyader.froggy@gmail.com
# License: CC BY-NC-SA
#
# --------------------------------------
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses>.
# --------------------------------------

from gimpfu import *

gettext.install("gimp20-python", gimp.locale_directory, unicode=True)

import sys
import math
# import datetime
import os.path
from os import path
from collections import OrderedDict

# -----------------
# F U N C T I O N S
# -----------------

# Function to get pixel region
def get_tile(layer, x, y, w, h):
    pr = layer.get_pixel_rgn(x, y, w, h)
    return pr[x : x + w, y : y + h]

# Main function
def do_create_dat_file(img, drw, ground, width, height, color_to_exclude, background_color, dat_dirname, dat_filename):

	# Not used
	# od_dict = OrderedDict([('id', 'str'), ('ground', 'str'), ('default_layer', 'int'), ('x', 'int'), ('y', 'int'), ('width', 'int'), ('height', 'int'), ('repeat_mode', 'str')])
	
	# Name the dat file
	filename = img.filename
	if filename is not None:
		if path.exists(filename):
			if dat_dirname is None and dat_filename == "None":
				name = os.path.basename(filename)
				if ".tile" in name and len(name) > 5:
					dat_filename = filename[:-len(name)] + name.split(".tiles")[0] + ".dat"
				else:
					dat_filename = os.path.splitext(img.filename)[0] + ".dat"
			else:
				if ".dat" in name and len(name) > 4:
					dat_filename = os.path.join(dat_dirname, '') + dat_filename
				else:
					dat_filename = os.path.join(dat_dirname, '') + dat_filename + ".dat"

	# Count the number of array
	if path.exists(dat_filename):
		with open(dat_filename) as dat:
			line = dat.readline()
			count = 0
			while line:
				l = "{}".format(line.strip())
				if '}' in l:
					count += 1
				line = dat.readline()
	## ---------
	## Not used - Creation of a dictionary from the dat file
	# if path.exists(dat_filename):
		## dat_filename = os.path.splitext(dat_filename)[0] + datetime.datetime.now().strftime('_%Y%m%d_%H%M%S.dat')
		# with open(dat_filename) as dat:
			# line = dat.readline()
			# dict_dat = OrderedDict()
			# count = 0
			# while line:
				# l = "{}".format(line.strip())
				# if '=' in l:
					# if '"' in l:
						# integer = False
					# else:
						# integer = True
					# l = l.replace(',', '').replace('\"', '').replace(' ','')
					# if integer:
						# dict_dat["d{0}".format(count)][l.split('=')[0]] = int(l.split('=')[1])
					# else:
						# dict_dat["d{0}".format(count)][l.split('=')[0]] = l.split('=')[1]
				# elif 'tile_pattern{' in l:
					# dict_dat["d{0}".format(count)] = OrderedDict()
				# elif '}' in l and len(l) == 1:
					# count += 1
				# elif 'background_color{' in l:
					# dict_dat["d{0}".format(count)] = {"background_color" : eval(l.split('{')[1].replace('}', '').strip())}
					# count += 1
				# else:
					# pass
				# line = dat.readline()
	## Not used - Creation of dat file from a dictionary
	# tmp_filename = os.path.splitext(dat_filename)[0] + '_tmp.dat'
	# f = open(tmp_filename, "w")
	# for _, d in dict_dat.items():
		# if d.keys()[0] == 'background_color':
			# print >>f, str(d['background_color']).replace('(', 'background_color{ ').replace(')', ' }')
		# else:
			# print >>f, "tile_pattern{"
			# for i in d:
				# if od_dict[i] == 'int':
					# print >>f, "  " + i + " = " + str(d[i]) + ","
				# else:
					# print >>f, "  " + i + " = " + '\"' + str(d[i]) + '\",'
			# print >>f, "}\n"
	# f.close()
	## ---------
	
	# Create a temporary image from the source image
	tmp_img = gimp.Image.duplicate(img)
	new_drw = tmp_img.active_drawable

	# Variables 
	ground = ["traversable", "wall"][ground]
	width = int(width)
	height = int(height)
	non_empty, x1, y1, x2, y2 = pdb.gimp_selection_bounds(tmp_img)
	sel_width = x2 - x1
	sel_height = y2 - y1
	nx = sel_width / width
	ny = sel_height / height

	# No selection, convert to RGB, add alpha and clear the color to exclude if necessary
	pdb.gimp_selection_none(tmp_img)
	if not(new_drw.is_rgb):
		pdb.gimp_image_convert_rgb(tmp_img)
	new_drw = tmp_img.active_drawable
	if not new_drw.has_alpha:
		pdb.gimp_layer_add_alpha(new_drw)
	pdb.gimp_image_select_color(tmp_img, 2, new_drw, color_to_exclude)
	if not pdb.gimp_selection_is_empty(tmp_img):
		pdb.gimp_edit_clear(new_drw)

	# Write to dat file the line for background_color. Get the first identification number to write
	if path.exists(dat_filename):
		id = count
		# id = len(dict_dat.keys())
	else:
		f = open(dat_filename, "w")
		first_line = "background_color{ " + str(int(background_color.red * 255)) + ", " + str(int(background_color.green * 255)) + ", " + str(int(background_color.blue * 255)) + " }"
		print >>f, first_line
		f.close()
		id = 1
	# Write to dat file the arrays for tile_pattern
	for i in range(0, ny):
		y = y1 + (i * height)
		for j in range(0, nx):
			x = x1 + (j * width)
			# Analyze the tiles to see if some are transparent
			tile = get_tile(new_drw, x, y, width, height)
			count = 0
			tile_is_alpha = True
			for k in tile: 
				if count % 4 == 3:
					alpha = ord(tile[count])
					if alpha != 0:
						tile_is_alpha = False
						break
				count += 1
			if not tile_is_alpha:
				f = open(dat_filename, "a")
				print >>f, "tile_pattern{\n  id = \"" + str(id) + "\",\n  ground = \"" + ground + "\",\n  default_layer = 0,\n  x = " + str(x) + ",\n  y = " + str(y) + ",\n  width = " + str(width) + ",\n  height = " + str(height) + ",\n}\n"
				id += 1
				f.close()

	# Delete the temporary image		
	pdb.gimp_image_delete(tmp_img)

	# ---------------
	# R E G I S T E R
	# ---------------

register(
	"unofficial_solarus_tool_for_tilesets",
	"(UNOFFICIAL SOLARUS TOOL - GIMP Python plug-in)\n\n\t-*-  D A T  F I L E  C R E A T I O N  W I Z A R D  -*-\n-*-  F O R  S O L A R U S  T I L E S E T S  -*-\n\nIMPORTANT: Only for NEW tileset!!!\nThis should help create Solarus dat files for NEW tilesets.\nDo not use this script if you have already edited the dat files with the Solarus editor, since all the options are not taken into account and will be deleted.",
	"IMPORTANT: Only for NEW tileset!!! This should help create Solarus dat files for NEW tilesets. Do not use this script if you have already edited the dat files with the Solarus editor, since all the options are not taken into account and will be deleted.",
	"Loic Guyader, froggy77",
	"Loic Guyader, froggy77. License: CC BY-NC-SA",
	"2019",
	"unofficial-Solarus-tool-for-tilesets", # Menu item Name
	"*",      # Alternately use RGB, RGB*, GRAY*, INDEXED etc.
	[
	(PF_IMAGE, "image",	"Input image:", None),
	(PF_DRAWABLE, "drawable", "Input drawable:", None),
	(PF_OPTION, "ground", "Ground:", 0, ("traversable", "wall")),
	(PF_SPINNER, "width", "Tile width:", 16, [8, 64, 8]),
	(PF_SPINNER, "height", "Tile height:", 16, [8, 64, 8]),
	(PF_COLOR, "color_to_exclude", "Color to exclude", (1.0, 0.0, 1.0)),
	(PF_COLOR, "background_color", "Background color", (1.0, 1.0, 1.0)),
	(PF_DIRNAME, "dat_dirname", "Output directory (for the .dat file)", ""),
	(PF_STRING, "dat_filename", ".dat filename", None),
	],
	[],
	do_create_dat_file,
	menu="<Image>/Filters",  # Host menu for the MenuItem
	domain=("gimp20-python", gimp.locale_directory)
)

main()