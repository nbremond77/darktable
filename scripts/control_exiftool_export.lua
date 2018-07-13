--[[
    This file is part of darktable,
    copyright 2016 by Christian Kanzian.
    copyright 2018 by Bernard Rémond.

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
EXIFTOOL ACTIONS ON EXPORT 
  This script adds a new UI element in the lighttable mode beyond the export modul. 
  If the tickbox is checked the script calls the 'exiftool' with the selected command line options on currently exported images.
  The original exported image will be overwritten. Following options are selectable:
  
  * -XMP-dc:Subject > IPTC:Keywords -> will copy tags from xmp to IPTC

  * -all= -> remove all metadata
  * -XMP:all= -> remove darktable history
  * -IPTC:all= -> remove IPTC data
  * -EXIF:all= -> remove EXIF data
  * -MakerNotes:all= -> remove MakerNotes data
  * -Photoshop:all= -> remove Photoshop data
  * -gps:all=  -> remove all geotags

  * -artist= -> remove author
  * -owner= -> remove owner
  * -copyright= -> remove copyright

  * -Title= -ObjectName= -> remove title
  * -comment= -Description= -Caption-Abstract= -ImageDescription= -> remove description
  * -keywords= -Subject= -> remove keywords
  * -time:all -> remove time information
  
  
  Remove all tags except a few:
  exiftool -all= -tagsFromFile @ -Title -ObjectName -Description -Caption-Abstract -Subject -Keywords
  
  See the tags in a file:
  exiftool -s -G 
  
ADDITIONAL SOFTWARE NEEDED FOR THIS SCRIPT
* exiftool - from Phil Harvey http://www.sno.phy.queensu.ca/~phil/exiftool/. 
             Linux distribtions typically ship this as a package. 
             Please check if it is installed.


LIMITATIONS
  You can not save any presets.


INSTALATION
 * copy this file in $CONFIGDIR/lua/ where CONFIGDIR is your darktable configuration directory
 * add the following line in the file $CONFIGDIR/luarc require "exiftool_export"

USAGE

]]

local dt = require "darktable"
dt.configuration.check_version(...,{3,0,0},{4,0,0},{5,0,0})


-- function copied from hugin.lua
local function checkIfBinExists(bin)
  local handle = io.popen("which "..bin)
  local result = handle:read()
  local ret
  handle:close()
  if (result) then
    dt.print_error("true checkIfBinExists: "..bin)
    ret = true
  else
    dt.print_error(bin.." not found")
    ret = false
  end


  return ret
end


if not checkIfBinExists("exiftool") then
    dt.print_error("exiftool not found")
    return
end



  local exiftool_enable = dt.new_widget("check_button") { label = "enable exiftool" }

  -- TODO: add another checkbox to switch the overwrite option on/off
  --local exif_overwrite_img =  dt.new_widget("check_button") { label = "overwrite original"}

  local tag_copytags  = dt.new_widget("check_button") { label = "copy tags from xmp to IPTC" }

	
  local label_remove = dt.new_widget("label"){
   label = "remove:",
   halign = "start"
   }

  local tag_remove_all  = dt.new_widget("check_button") { label = "'-all='  remove all metadata" }
  local tag_remove_xmp  = dt.new_widget("check_button") { label = "'-XMP:all='  remove darktable history" }
  local tag_remove_iptc = dt.new_widget("check_button") { label = "'-IPTC:all='  remove IPTC data" }
  local tag_remove_exif = dt.new_widget("check_button") { label = "'-EXIF:all='  remove EXIF data" }
  local tag_remove_MakerNotes = dt.new_widget("check_button") { label = "'-MakerNotes:all='  remove MakerNotes data" }
  local tag_remove_Photoshop = dt.new_widget("check_button") { label = "'-Photoshop:all='  remove Photoshop data" }
  local tag_remove_geotags = dt.new_widget("check_button") { label = "'-gps:all='  remove all geotags" }
  local tag_remove_artist = dt.new_widget("check_button") { label = "'-artist='  remove author" }
  local tag_remove_owner = dt.new_widget("check_button") { label = "'-owner='  remove owner" }
  local tag_remove_copyright = dt.new_widget("check_button") { label = "'-copyright='  remove copyright" }
  local tag_remove_title = dt.new_widget("check_button") { label = "'-Title= -ObjectName='  remove title" }
  local tag_remove_description = dt.new_widget("check_button") { label = "'-comment='  remove description" }
  local tag_remove_keywords = dt.new_widget("check_button") { label = "'-keywords='  remove keywords" }
  local tag_remove_time = dt.new_widget("check_button") { label = "'-time:all' -> remove time information" }


  local label_keep = dt.new_widget("label"){
   label = "but keep:",
   halign = "start"
   }

  local tag_keep_artist = dt.new_widget("check_button") { label = "'-artist='  keep author" }
  local tag_keep_owner = dt.new_widget("check_button") { label = "'-owner='  keep owner" }
  local tag_keep_copyright = dt.new_widget("check_button") { label = "'-copyright='  keep copyright" }
  local tag_keep_title = dt.new_widget("check_button") { label = "'-Title='  keep title" }
  local tag_keep_description = dt.new_widget("check_button") { label = "'-comment='  keep description" }
  local tag_keep_keywords = dt.new_widget("check_button") { label = "'-keywords='  keep keywords" }
  local tag_keep_time = dt.new_widget("check_button") { label = "'-time:all'  keep time information" }
   

  local exif_widget = dt.new_widget("box"){
	orientation = horizontal,
	exiftool_enable,
	tag_copytags,
	label_remove,
	tag_remove_all,
	tag_remove_xmp,
	tag_remove_iptc,
	tag_remove_exif,
	tag_remove_MakerNotes,
	tag_remove_Photoshop,
	tag_remove_geotags,
	tag_remove_artist,
	tag_remove_owner,
	tag_remove_copyright,
	tag_remove_title,
	tag_remove_description,
	tag_remove_keywords,
	tag_remove_time,
	label_keep,
	tag_keep_artist,
	tag_keep_owner,
	tag_keep_copyright,
	tag_keep_title,
	tag_keep_description,
	tag_keep_keywords,
	tag_keep_time
    }


dt.register_lib("controlexiftool_ui","control exiftool on export",true,false,{
    [dt.gui.views.lighttable] = {"DT_UI_CONTAINER_PANEL_RIGHT_CENTER", 0}
    }, exif_widget
    );
 

-- function to build command
local function exiftool_call(img)
   local exif_cmd
   local options   = ""
   local options2  = " -tagsFromFile @"


   local imgexp = tostring(img)
   print(imgexp)

   if tag_copytags.value == true then options = options.." -XMP-dc:Subject > IPTC:Keywords" end
   if tag_remove_all.value == true then options = options.." -all=" end
   if tag_remove_xmp.value == true then options = options.." -XMP:all=" end
   if tag_remove_iptc.value == true then options = options.." -IPTC:all=" end
   if tag_remove_exif.value == true then options = options.." -EXIF:all=" end
   if tag_remove_MakerNotes.value == true then options = options.." -MakerNotes:all=" end
   if tag_remove_Photoshop.value == true then options = options.." -Photoshop:all=" end
   if tag_remove_geotags.value == true then options = options.." -gps:all=" end
   if tag_remove_artist.value == true then options = options.." -artist=" end
   if tag_remove_owner.value == true then options = options.." -owner=" end
   if tag_remove_copyright.value == true then options = options.." -copyright=" end
   if tag_remove_title.value == true then options = options.." -Title= -ObjectName=" end
   if tag_remove_description.value == true then options = options.." -comment= -Description= -Caption-Abstract= -ImageDescription=" end
   if tag_remove_keywords.value == true then options = options.." -keywords= -Subject=" end
   if tag_remove_time.value == true then options = options.." -time:all=" end

   if tag_keep_artist.value == true then options2 = options2.." -artist" end
   if tag_keep_owner.value == true then options2 = options2.." -owner" end
   if tag_keep_copyright.value == true then options2 = options2.." -copyright" end
   if tag_keep_title.value == true then options2 = options2.." -Title -ObjectName" end
   if tag_keep_description.value == true then options2 = options2.." -comment -Description -Caption-Abstract -ImageDescription" end
   if tag_keep_keywords.value == true then options2 = options2.." -keywords -Subject" end
   if tag_keep_time.value == true then options2 = options2.." -time:all" end

   if options2 == " -tagsFromFile @" then options2 = "" end

   exif_cmd = "exiftool "..options..options2.." -overwrite_original ".."'" .. imgexp .. "'"

   return exif_cmd
end   


-- final call exiftool if enabled on export events 
dt.register_event("intermediate-export-image", function(event,img,filename)
    
    if not exiftool_enable.value == true then
       return
    end
   
    local cmd = exiftool_call(filename)  
    dt.print("Call "..cmd) 
    print("Call "..cmd)

    dt.control.execute(cmd)
      
end
)
