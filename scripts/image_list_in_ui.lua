--[[
  This file is part of darktable,
  copyright (c) 2018 Bernard REMOND

  darktable is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  darktable is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with darktable.  If not, see <http://www.gnu.org/licenses/>.
]]
--[[
IMAGE_LIST_IN_UI
Add a widget with the list of the selected images for easy copy/paste


USAGE
* require this file from your main lua config file:

This plugin will add a widget at the bottom of the left column in lighttable mode
]]

local dt = require "darktable"

dt.configuration.check_version(...,{3,0,0},{4,0,0},{5,0,0})


local gettext = dt.gettext


-- Tell gettext where to find the .mo file translating messages for a particular domain
gettext.bindtextdomain("image_list_in_ui",dt.configuration.config_dir.."/lua/locale/")


local function _(msgid)
    return gettext.dgettext("image_list_in_ui", msgid)
end









-- <GUI>
local get_filename = dt.new_widget("entry") {
    text = "Selected_images.csv", 
    placeholder=_("CSV filename"),
    is_password = true,
    editable = true,
    tooltip = _("Filename of the exported CSV file")
}

local get_sep = dt.new_widget("entry") {
    text = ";", 
    placeholder=_("CSV separator"),
    is_password = true,
    editable = true,
    tooltip = _("Separator used in the exported CSV file")
}


local export_button = dt.new_widget("button") {
  label = _("export"),
  --clicked_callback = function()
  --  write_image_list_to_csv()
  --  print("Done.")
  --end,
}

local show_selected_images = dt.new_widget("check_button")
{
  label = _("show list of selected images"),
  value = false
}


local main_label = dt.new_widget("label"){selectable = true, ellipsize = "middle", halign = "start"}


local function refresh_widget()
  local selection = dt.gui.selection()
  local result = ""

  local array = {}
  if (show_selected_images.value) then
    for _,img in pairs(selection) do
      img_name = img.filename
      if result == "" then
        result = img_name
      else
        result = result.."\n"..img_name
      end
    end
    main_label.label = result
  else
    main_label.label = ""
  end
end





local function write_csv(path, data, sep)
    sep = sep or ';'
    local file,errmsg = assert(io.open(path, "w"))
	if not file then
		error(errmsg)
	else	
		for i=1,#data do
			for j=1,#data[i] do
				if j>1 then file:write(sep) end
				file:write('"'..tostring(data[i][j])..'"')
			end
			file:write('\n')
		end
	end
  file:close()
end


local function write_image_list_to_csv()
		local errmsg
		local filename
		local sep
		
		if get_filename.text ~= "" then
			filename = get_filename.text
			--  make sure there is no non-printable characters in the filename
			filename = string.gsub(filename, "\n", "")
			filename = string.gsub(filename, "\r", "")
			filename = string.gsub(filename, "\t", "")		
		else
			filename = "list_of_selected_images.csv"
		end
		
		if get_sep.text ~= "" then
			sep = get_sep.text
		else
			sep = ";"
		end	

		-- Prepare header
    local data = {}
    data[1] = {}
		data[1][1] = "img.filename" -- image_filename
		data[1][2] = "img.path" -- path
		data[1][3] = "img.creator" -- author
		data[1][4] = "img.publisher" -- publisher
		data[1][5] = "img.description"  -- description
		data[1][6] = "img.title" -- title
		data[1][7] = "img.rating" -- rating
		data[1][8] = "img.rights" -- rights
		data[1][9] = "img.exif_focal_length" -- exif_focal_length
		data[1][10] = "img.exif_aperture" -- exif_aperture
		data[1][11] = "img.exif_iso" -- exif_iso
		data[1][12] = "img.is_hdr" -- is_hdr
		data[1][13] = "img.red" -- red
		data[1][14] = "img.blue" 
		data[1][15] = "img.purple" 
		data[1][16] = "img.green"
		data[1][17] = "img.yellow" 
		data[1][18] = "img.width" 
		data[1][19] = "img.height" 
		data[1][20] = "img.exif_focus_distance"
		data[1][21] = "img.latitude" 
		data[1][22] = "img.longitude" 
		data[1][23] = "directory" -- string.gsub(file, "(.*)(%/.*%..*)", "%1") -- dir
		data[1][24] = "extension" -- string.gsub(file, "(.*)(%..*)", "%2")	-- ext
		data[1][25] = "filename"

		  
		local i = 1
    local selection = dt.gui.selection()
  	for _,img in pairs(selection) do
			-- prepare the data, one line per image
      file = tostring(img)
      data[i+1] = {}
			data[i+1][1] = img.filename -- image_filename
			data[i+1][2] = img.path -- path
			data[i+1][3] = img.creator -- author
			data[i+1][4] = img.publisher -- publisher
			data[i+1][5] = img.description  -- description
			data[i+1][6] = img.title -- title
			data[i+1][7] = img.rating -- rating
			data[i+1][8] = img.rights -- rights
			data[i+1][9] = img.exif_focal_length -- exif_focal_length
			data[i+1][10] = img.exif_aperture -- exif_aperture
			data[i+1][11] = img.exif_iso -- exif_iso
			data[i+1][12] = img.is_hdr -- is_hdr
			data[i+1][13] = img.red -- red
			data[i+1][14] = img.blue 
			data[i+1][15] = img.purple 
			data[i+1][16] = img.green
			data[i+1][17] = img.yellow 
			data[i+1][18] = img.width 
			data[i+1][19] = img.height 
			data[i+1][20] = img.exif_focus_distance
			data[i+1][21] = img.latitude 
			data[i+1][22] = img.longitude 
			data[i+1][23] = string.gsub(file, "(.*)(%/.*%..*)", "%1") -- dir
			data[i+1][24] = string.gsub(file, "(.*)(%..*)", "%2")	-- ext
			data[i+1][25] = file	-- ext
			i = i+1
		end
		-- Write to the CSV file
		write_csv(filename, data, sep)
    print("Image list written to "..filename)
    dt.print(_("Image list written to "..filename))
end




-- back UI elements in a table
-- thanks to wpferguson for the hint
local widget_table = {}
widget_table[#widget_table  + 1] = show_selected_images
widget_table[#widget_table  + 1] = get_filename
widget_table[#widget_table  + 1] = get_sep
widget_table[#widget_table  + 1] = export_button
widget_table[#widget_table  + 1] = dt.new_widget("separator"){}
widget_table[#widget_table  + 1] = main_label


--create module
dt.register_lib(
  "image_list_in_ui",     -- Module name
  "Selected image names",     -- name
  true,                -- expandable
  false,               -- resetable
  {[dt.gui.views.lighttable] = {"DT_UI_CONTAINER_PANEL_LEFT_CENTER", 300}},

  dt.new_widget("box"){
    orientation = "vertical",
    table.unpack(widget_table),
  },
  nil,-- view_enter
  nil -- view_leave
)


main_label.reset_callback = refresh_widget
export_button.clicked_callback = write_image_list_to_csv

dt.register_event("mouse-over-image-changed",refresh_widget);

  --
-- vim: shiftwidth=2 expandtab tabstop=2 cindent syntax=lua
