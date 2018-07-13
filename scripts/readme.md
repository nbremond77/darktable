# Darktable Lua scripts
Here is a collection of usefull Darktable scripts made or customized by me.
Please send me comments or patch if you like.

- **image_list_in_ui.lua** : Display and allow to export the list of all the selected images
This script add a new tool on the left of the user interface, that display and allow to export the list of all the selected images. The list of selected images is exported as a CSV file (the ";" defaut separator cna be changed), along with the main attributes of the image.
- **select_list_of_images.lua** : Select a list of images 
This script add a new tool on the right of the user interface, that allow to select a list of images for processing. Copy and paste the list of images and click the "Select" button. All the listed images are now selected, and you can apply color dots, tags, etc... I use this tool when I get a list of images a customer has selected for pos-processing
- **control_exiftool_export.lua** : Remove meta-data from the exported image using exiftool
This script add a new tool on the right of the user interface, below the export tool, that allow to select the meta-data to be removed from the exported images. This script allows to remove all meta-data, to remove all meta-data from a certain group, to remove only few tags, or to remove all meta-data of a certain group except some meta-data


