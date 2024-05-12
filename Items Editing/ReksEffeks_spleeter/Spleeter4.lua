-- @noindex

reaper.Undo_BeginBlock()

function getPath(str)
	if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
		return str:match("(.*[\\])")
	else
		return str:match("(.*[/])")
	end
end

if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
	pt = "python -m "
	else
	pt = ""
end

sel_item = reaper.GetSelectedMediaItem( 0, 0 )

if not sel_item then 
	reaper.MB( "Select one audio item.", "Select Audio Item", 0 ) 
	end_script = 1 
end

if sel_item then
	reaper.Main_OnCommand( 41173, 0 )
	item_pos =  reaper.GetMediaItemInfo_Value( sel_item, "D_POSITION" )     
	item_take = reaper.GetMediaItemTake( sel_item, 0 )
	source = reaper.GetMediaItemTake_Source( item_take )
	filename = reaper.GetMediaSourceFileName(source, "")
	filepath = filename
	filename_no_ext = string.gsub(filename, '[.]%w%w%w$','')
	take_type = reaper.TakeIsMIDI( item_take )
	if take_type then
		reaper.MB( "Item is MIDI", "Select Audio Item", 0 )
		end_script = 1
	end 
end

if not end_script then

	local cmd = (pt .. 'spleeter separate -p spleeter:4stems-16kHz -o \"' .. getPath(filepath) .. '\" \"' .. filename .. '\"')

	if reaper.MB( "       Splitting selected audio into 4 stems.\n\n             Vocals / Drums / Bass / Other\n\nProgram will hang until task is done. Continue?", "Spleeter confirmation", 1 ) == 1 then
		os.execute(cmd)
		reaper.InsertMedia(filename_no_ext .. "/vocals.wav", 1)
		reaper.InsertMedia(filename_no_ext .. "/drums.wav", 1)
		reaper.InsertMedia(filename_no_ext .. "/bass.wav", 1)
		reaper.InsertMedia(filename_no_ext .. "/other.wav", 1)
		reaper.MB( "Done.", "Spleeter", 0 )
	end
end

reaper.Undo_EndBlock("Spleeter (4 stems)",0)