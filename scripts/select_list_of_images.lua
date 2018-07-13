--[[
    This file is part of darktable,
    Copyright (C) 2018 by Bernard REMOND

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--[[
SELECT_LIST
   Select the images list specified in the widget
   This function is intended to quickly select a bunch of images from an image list provided as a text.
   For example when a customer give you a list of image (filenames) to be post-processed, this 
   widget allows you to quickly select these images.

INSTALATION
   * copy this file in $CONFIGDIR/lua/ where CONFIGDIR is your darktable configuration directory
   * add the following line in the file $CONFIGDIR/luarc require "select_list_of_images"
]]


local dt = require "darktable"
local debug = require "darktable.debug"


local gettext = dt.gettext

dt.configuration.check_version(...,{3,0,0},{4,0,0},{5,0,0})

-- Tell gettext where to find the .mo file translating messages for a particular domain
gettext.bindtextdomain("select_list_of_images",dt.configuration.config_dir.."/lua/locale/")

local function _(msgid)
    return gettext.dgettext("select_list_of_images", msgid)
end




-- Split a string into lines separated by either DOS or Unix line endings, creating a table out of the results.
local function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

--function SplitFilename(strFilename)
	-- Returns the Path, Filename, and Extension as 3 values
	--if lfs.attributes(strFilename,"mode") == "directory" then
	--	local strPath = strFilename:gsub("[\\/]$","")
	--	return strPath.."\\","",""
	--end
--	return strFilename:match("(.-)([^\\/]-([^\\/%.]+))$")
--end




local function select_images(imagelist)
  local selection = {}
  job = dt.gui.create_job(_("select image "), true, stop_selection)

 
  for key,image in ipairs(dt.collection) do
    if(job.valid) then
      job.percent = (key-1)/#dt.collection
      --print("Analysis : "..image.filename)

      -- Look if the following image is in the list of images to find
      local tmp = string.lower(image.filename)
      local nameWithouExtension = string.match(tmp, "(.+)%..+")

      for _,imagename in ipairs(imagelist) do
        local imagenameWithouExtension = string.lower(imagename)
        if string.find(imagenameWithouExtension,"%.") then
          imagenameWithouExtension = string.match(imagenameWithouExtension, "(.+)%..+")
        end 
        --print("Check: "..imagenameWithouExtension.." / "..nameWithouExtension)
        if nameWithouExtension == imagenameWithouExtension then
          table.insert(selection,image)
          dt.print("Select: "..imagename)
          --print("Select: "..imagename)
          break
        end
      end
    else
      break
    end
  end

  dt.gui.selection(selection)

  job.valid = false
  -- return selection
end


local function stop_selection(job)
    job.valid = false
end


-- <GUI>
local new_selectList = dt.new_widget("text_view"){
    text = "image_list",
    --placeholder = _("list of images"),
    --is_password = false,
    editable = true,
    tooltip = _("enter the list of images to select\none image per line\nnot case sensitive\nextension is ignored")
}


local set_selectList_button = dt.new_widget("button") {
  label = _("select"),
  clicked_callback = function()
    if new_selectList.text == "" then
      dt.print(_("list of images to select is empty!"))
      --print("list of images to select is empty!")
    else
      local list = split(new_selectList.text,"\n")
      selection = select_images(list)
      --print("Done.")
    end
  end,
}

local image_list_widget = dt.new_widget ("box") {
    orientation = "horizontal",
    dt.new_widget("label") { label = _("list of images:") },
    new_selectList
}


-- back UI elements in a table
-- thanks to wpferguson for the hint
local widget_table = {}
widget_table[#widget_table  + 1] = set_selectList_button
widget_table[#widget_table  + 1] = dt.new_widget("separator"){}
widget_table[#widget_table  + 1] = image_list_widget


--create module
dt.register_lib(
  "Selectlist",     -- Module name
  "Select list of images",     -- name
  true,                -- expandable
  false,               -- resetable
  {[dt.gui.views.lighttable] = {"DT_UI_CONTAINER_PANEL_RIGHT_CENTER", 490}},

  dt.new_widget("box"){
    orientation = "vertical",
    table.unpack(widget_table),

  },
  nil,-- view_enter
  nil -- view_leave
)



-- vim: shiftwidth=2 expandtab tabstop=2 cindent syntax=lua
-- kate: tab-indents: off; indent-width 2; replace-tabs on; remove-trailing-space on;
