#!/usr/bin/env python2

from gimpfu import *
import sys
import math


def do_animated_circles(image, drawable, color, animations_nb, animations_nb_by_row, diameter_1, diameter_2, diameter_3, diameter_4):
    list = [int(diameter_1), int(diameter_2), int(diameter_3), int(diameter_4)]
    size = list[0]
    opacities = [46.3, 74.5, 90.6, 100.0]
    pixels = [2, 0, 2, 4]
    frames_nb = len(pixels)
    animations_nb = int(animations_nb)
    animations_nb_by_row = int(animations_nb_by_row)
    if animations_nb <= animations_nb_by_row:
        value_by_row = animations_nb
    else:
        value_by_row = animations_nb_by_row
    width = size * frames_nb * value_by_row
    row_nb = int(math.ceil(float(animations_nb) / animations_nb_by_row))
    height = size * row_nb
    type = RGB
    image = pdb.gimp_image_new(width, height, type)
    type = RGBA_IMAGE
    name = "animated circles"
    opacity = 100
    mode = LAYER_MODE_NORMAL_LEGACY
    layer = pdb.gimp_layer_new(image, width, height, type, name, opacity, mode)
    layer.add_alpha()
    layer.fill(TRANSPARENT_FILL)
    image.add_layer(layer, 0)
    display = pdb.gimp_display_new(image)
    pdb.gimp_progress_init("Processing", display)
    drawable = pdb.gimp_image_get_active_drawable(image)
    pdb.gimp_undo_push_group_start(image)
    pdb.gimp_context_set_antialias(False)
    pdb.gimp_context_set_feather(False)
    pdb.gimp_context_set_feather_radius(0, 0)
    operation = CHANNEL_OP_REPLACE
    fill_mode = BUCKET_FILL_FG
    pdb.gimp_context_set_foreground(color)
    paint_mode = LAYER_MODE_NORMAL_LEGACY
    threshold = 0
    sample_merged = True
    pdb.gimp_selection_none(image)
    offset_y = 0
    for i in range(0, animations_nb):
        offset_y = math.floor(i / animations_nb_by_row) * size
        for j in range(0, frames_nb):
            offset_x = j * size + ((frames_nb * size) * (i % animations_nb_by_row))
            count = 0
            for k in list:
                diameter = (k - (i * 2)) - pixels[j]
                if diameter < 8:
                    break
                else:
                    x = (size - diameter) / 2 + offset_x
                    y = (size - diameter) / 2 + offset_y
                opacity = opacities[count]
                pdb.gimp_image_select_ellipse(image, operation, x, y, diameter, diameter)
                if count != 0:
                    pdb.gimp_drawable_edit_clear(drawable)
                pdb.gimp_edit_bucket_fill(drawable, fill_mode, paint_mode, opacity, threshold, sample_merged, x, y)
                # pdb.gimp_displays_flush()
                count += 1
                pdb.gimp_progress_update(float(i)/animations_nb)
                percent = int((float(i) / animations_nb) * 100)
                pdb.gimp_progress_set_text("Processing: " + str(percent) + " %")
    pdb.gimp_selection_none(image)
    pdb.gimp_image_grid_set_spacing(image, size, size)
    pdb.gimp_image_grid_set_offset(image, 0, 0)
    pdb.gimp_displays_flush()
    pdb.gimp_undo_push_group_end(image)

register(
    "pixelart_animated_circles",
    "(PIXEL ART COLLECTION - GIMP Python plug-in)\n\n\t-*-  A N I M A T E D  C I R C L E S  -*-\n\nIt creates animated circles for a spritesheet.",
    "It creates animated circles for a spritesheet.",
	"Loic Guyader, froggy77",
	"Loic Guyader, froggy77. License: CC BY-NC-SA",
    "2023",
    "pixel-art-animated-circles", # Name of the menu
    "*",      # Alternately use RGB, RGB*, GRAY*, INDEXED etc.
    [
    (PF_IMAGE, "image",    "Image", None),
	(PF_DRAWABLE, "drawable", "Drawable", None),
    (PF_COLOR, "color", "Color", (1.0, 1.0, 1.0)),
    (PF_SPINNER, "animations_nb", "Number of animations", 16, [1, 100, 1]),
    (PF_SPINNER, "animations_nb_by_row", "Number of animations by row", 2, [1, 20, 1]),
    (PF_SPINNER, "diameter_1", "Diameter 1", 192, [1, 256, 8]),
    (PF_SPINNER, "diameter_2", "Diameter 2", 160, [1, 256, 8]),
    (PF_SPINNER, "diameter_3", "Diameter 3", 152, [1, 256, 8]),
    (PF_SPINNER, "diameter_4", "Diameter 4", 128, [1, 256, 8]),
    ],
    [],
    do_animated_circles, 
    menu="<Image>/Filters"  # Path of the menu
)

main()
