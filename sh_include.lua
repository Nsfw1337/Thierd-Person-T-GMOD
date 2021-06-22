
-----------------------------------------------------

dThirdPerson = {}
dThirdPerson.config = dThirdPerson.config or {}

local function findInFolder( currentFolder, ignoreRootFolder )
	local files, folders = file.Find( currentFolder .. "*", "LUA" )

	if not ignoreRootFolder then
		for _, File in ipairs( files ) do
			if SERVER and File:find( "sv_" ) then
				include( currentFolder .. File )
			elseif File:find( "cl_" ) then
				if SERVER then AddCSLuaFile( currentFolder .. File )
				else include( currentFolder .. File ) end
			elseif File:find( "sh_" ) then
				if SERVER then AddCSLuaFile( currentFolder .. File ) end
				include( currentFolder .. File )
			end
		end
	end

	for _, folder in ipairs( folders ) do
		findInFolder( currentFolder .. folder .. "/" )
	end
end

findInFolder( "darkrp_modules/the_division_thirdperson/", true )
