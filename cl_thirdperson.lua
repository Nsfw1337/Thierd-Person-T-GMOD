local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudCrosshair = true,
	CHudAmmo = true,
}

local config = dThirdPerson.config

local function toggleThirdPerson()
	CAMI.PlayerHasAccess( LocalPlayer(), "dThirdPerson_access", function()
		DarkRP.thirdPersonEnabled = not DarkRP.thirdPersonEnabled
	end )
end

net.Receive( "dThirdPerson_toggle", toggleThirdPerson )

hook.Add( "PlayerButtonUp", "dThirdPerson_keyBind", function( player, buttonId )
	if not IsFirstTimePredicted() then return end
	if player ~= LocalPlayer() then return end
	if buttonId ~= config.keyBind then return end
	if gui.IsGameUIVisible() then return end
	if player:IsTyping() then return end

	toggleThirdPerson()
end )

if config.enableThirdPersonOnConnect then
	hook.Add( "InitPostEntity", "dThirdPerson_toggleOnJoin", function()
		toggleThirdPerson()

		hook.Remove( "InitPostEntity", "dThirdPerson_toggleOnJoin" )
	end )
end

hook.Add( "CalcView", "thirdPersonView", function( client, position, angles, fov, znear, zfar )
	if not DarkRP.thirdPersonEnabled then return end

	local distance = 65
	local traceData = {
		start = position,
		endpos = position - angles:Forward() * distance + ( ( angles:Right() * distance ) / 3 ),
		filter = LocalPlayer()
	}

	local trace = util.TraceLine( traceData )
	local newDistance = trace.HitPos:Distance( position )

	if newDistance < distance - 10 then
		distance = newDistance - 10
	end

	return {
		origin = position - angles:Forward() * distance + ( ( angles:Right() * distance ) / 5 ),
		angles = angles,
		fov = fov,
		filter = LocalPlayer(),
		drawviewer = true,
		znear = nearZ,
		zfar = farZ
	}
end )

hook.Add( "HUDPaint", "thirdperson", function()
	if not DarkRP.thirdPersonEnabled then return end
	if config.hideCrosshair then return end

	local trace = {}
	trace.start = LocalPlayer():GetShootPos()
	trace.endpos = trace.start + LocalPlayer():GetAimVector() * 9000
	trace.filter = LocalPlayer()
	local tr = util.TraceLine( trace )

	local pos = tr.HitPos:ToScreen()
	local fraction = math.min( ( tr.HitPos - trace.start ):Length(), 1024 ) / 1024
	local size = 10 + 20 * ( 1 - fraction )
	local offset = size * 0.5
	local offset2 = offset - size * 0.1

	trace = {}
	trace.start = LocalPlayer():GetPos()
	trace.endpos = tr.HitPos + tr.HitNormal * 5
	trace.filter = LocalPlayer()
	tr = util.TraceLine( trace )

	surface.SetDrawColor( color_white )
	surface.DrawLine( pos.x - offset, pos.y, pos.x - offset2, pos.y )
	surface.DrawLine( pos.x + offset, pos.y, pos.x + offset2, pos.y )
	surface.DrawLine( pos.x, pos.y - offset, pos.x, pos.y - offset2 )
	surface.DrawLine( pos.x, pos.y + offset, pos.x, pos.y + offset2 )
	surface.DrawLine( pos.x - 1, pos.y, pos.x + 1, pos.y )
end )

hook.Add( "HUDShouldDraw", "thirdperson", function( name )
	if name == "CHudCrosshair" and DarkRP.thirdPersonEnabled then
		return false
	end
end )

local drawDivisionHUDVar = CreateClientConVar( "fruit_hud_drawTheDivision", "1", true )

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
 	if not DarkRP.thirdPersonEnabled or not drawDivisionHUDVar:GetBool() then return end
	if hide[ name ] then return false end
end )

local weaponBlacklist = config.weaponBlacklist

local health, armor = 0, 0
local xPos, yPos = 90, 0
local healthBarWidth, healthBarHeight = 200, 28
local healthDividerAmount = 2

local primaryAmmoContainerWidth, primaryAmmoContainerHeight = 80, 85
local playerSideAbilityWidth, playerSideAbilityHeight = 48, 48

local white = Color( 255, 255, 255, 150 )
local function drawCustomOutlinedBox( x, y, w, h, color )
	  draw.RoundedBox( 0, x, y, w, h, color )

	  draw.RoundedBox( 0, x, y, 4, h, Color( 60, 60, 60, 100 ) )
	  draw.RoundedBox( 0, x + w - 4, y, 4, h, Color( 0, 0, 0, 100 ) )

	  local whiteCol = Color( white.r, white.g, white.b, color.a )

	  draw.RoundedBox( 0, x, y + 1, 2, 2, whiteCol )
	  draw.RoundedBox( 0, x, y + h - 2, 2, 2, whiteCol )

	  draw.RoundedBox( 0, x + w - 2, y + 1, 2, 2, whiteCol )
	  draw.RoundedBox( 0, x + w - 2, y + h - 2, 2, 2, whiteCol )
end

local function drawIconBox( icon, x, y, w, h, backgroundColor, foregroundColor, iconX, iconY, iconW, iconH )
	  draw.RoundedBox( 0, x, y, w, h, backgroundColor )

	  draw.RoundedBox( 0, x, y, 4, h, Color( 60, 60, 60, 100 ) )
	  draw.RoundedBox( 0, x + w - 4, y, 4, h, Color( 0, 0, 0, 100 ) )

	  local whiteCol = Color( white.r, white.g, white.b, backgroundColor.a )

	  draw.RoundedBox( 0, x + 4, y + 1, 2, 2, whiteCol )
	  draw.RoundedBox( 0, x + 4, y + h - 2, 2, 2, whiteCol )

	  draw.RoundedBox( 0, x + w - 2, y + 1, 2, 2, whiteCol )
	  draw.RoundedBox( 0, x + w - 2, y + h - 2, 2, 2, whiteCol )

	  surface.SetDrawColor( 255, 255, 255, 255 )
	  surface.SetMaterial( icon	)
	  surface.DrawTexturedRect( x + ( iconX or 6 ), y + ( iconY or 6 ), iconW or w - 12, iconH or h - 12 )
end

local function inIronSights( weapon )
	return ( weapon:GetNWBool("M9K_Ironsights") or ( weapon.GetIronsights and weapon:GetIronsights() ) ) and not input.IsKeyDown( KEY_LSHIFT )
end

local wantedIcon = Material( config.wantedIcon )
local gunLicenseIcon = Material( config.gunLicenseIcon )
local ultimateAbilityIcon = Material( config.serverIcon )

hook.Add( "PostDrawTranslucentRenderables", "divisionhud", function()
	if not DarkRP.thirdPersonEnabled or config.hideHUD or not drawDivisionHUDVar:GetBool() or not LocalPlayer():Alive() or LocalPlayer():InVehicle() then return end

	local playerVelocity = LocalPlayer()
	playerVelocity = playerVelocity.GetVelocity( playerVelocity )
	playerVelocity.z = 0

	local velocityLength = math.Round( playerVelocity.Length( playerVelocity ) ) != 0 and 230 or 0

	local hitWall = util.TraceLine(
	{
	  start = EyePos(),
	  endpos = EyePos() - EyeAngles():Right() * - 20
	}
	).Hit

	local realTime = RealTime()

	local weapon = LocalPlayer():GetActiveWeapon()
	local weaponironsights = inIronSights( weapon )
	local isCrouching = LocalPlayer():Crouching()

	local ang = LocalPlayer():EyeAngles()
	local pos = LocalPlayer():EyePos() + ( ang:Up() * - 10 ) + ( isCrouching and ( ang:Up() * 20 ) or Vector( 0, 0, 0 ) )
  	- ( hitWall and ( ang:Right() * 85 ) or ( isCrouching and ang:Right() * - 5 or Vector( 0, 0, 0 ) ) + ang:Right() * - 20 )
  	+ ( ang:Forward() * ( weaponironsights and isCrouching and 45 or weaponironsights and 65 or 25 ) )
  	+ ( ang:Up() * math.sin( realTime * ( math.Clamp( velocityLength, 0, 300 ) ) / 10 ) ) * 0.5

	ang:RotateAroundAxis( ang:Up(), 180 )
	ang:RotateAroundAxis( ang:Up(), hitWall and 12 or - 12 )
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), - 90 )

	cam.Start3D2D( pos, ang, 0.15 )
		cam.IgnoreZ( true )

		drawCustomOutlinedBox( xPos, yPos, healthBarWidth, healthBarHeight, Color( 40, 40, 40, 128 ) )

		local maxHealth = LocalPlayer():GetMaxHealth()
		local curHealth = LocalPlayer():Health()

		health = math.min( maxHealth, ( health == curHealth and health ) or Lerp( 0.05, health, curHealth ) )
		draw.RoundedBox( 0, xPos + 1, yPos, math.Clamp( health * 2, 0, healthBarWidth ) - 2, healthBarHeight, config.healthBarColor )

		local maxArmor = 100
		local curArmor = LocalPlayer():Armor()

	    if curArmor > 0 then
	  		armor = math.min( maxArmor, ( armor == curArmor and armor ) or Lerp( 0.05, armor, curArmor ) )

	      drawCustomOutlinedBox( xPos, yPos - 12, healthBarWidth, 8, Color( 40, 40, 40, 128 ) )
	  		draw.RoundedBox( 0, xPos + 1, yPos - 12, math.Clamp( armor * 2, 0, healthBarWidth ) - 2, 8, config.armorBarColor )
	    end

	    local spacingSpot = 0
	    for i = 1, healthDividerAmount do
	      spacingSpot = ( healthBarWidth / ( healthDividerAmount + 1 ) ) * i
	      draw.RoundedBox(0, xPos + spacingSpot, yPos, 2, healthBarHeight, Color( 0, 0, 0, 200 ) )
	    end

		if IsValid( weapon ) then
			local clip1 = weapon:Clip1()
			local doAmmoWarning = clip1 < 1 and clip1 <= weapon:GetMaxClip1() / 3 or false
			local isInBlacklist = weaponBlacklist[ weapon:GetClass() ]

			drawCustomOutlinedBox( 0, 0, primaryAmmoContainerWidth, primaryAmmoContainerHeight, Color( not isInBlacklist and doAmmoWarning and math.abs( math.sin( realTime * 10 ) * 100 ) or 45, 45, 45, 128 ) )

			if not isInBlacklist then
					draw.SimpleText( clip1 < 0 and 1 or clip1, "dThirdPersonFont_48", 40, primaryAmmoContainerHeight * 0.35, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					draw.SimpleText( LocalPlayer():GetAmmoCount( weapon:GetPrimaryAmmoType() ), "dThirdPersonFont_32", 40, primaryAmmoContainerHeight * 0.69, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end

	    drawCustomOutlinedBox( 0, primaryAmmoContainerHeight + 4, primaryAmmoContainerWidth, primaryAmmoContainerHeight / 2, Color( doAmmoWarning and math.abs( math.sin( realTime * 10 ) * 128 ) or 45, 45, 45, 128 ) )
			local oldClip = LocalPlayer().oldWeaponData and LocalPlayer().oldWeaponData[ "clip1" ]
			if oldClip and oldClip > -1 then
				draw.SimpleText( oldClip or "", "dThirdPersonFont_48", primaryAmmoContainerWidth / 2, primaryAmmoContainerHeight + 4 + ( primaryAmmoContainerHeight / 4 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

	    local leftAbilityIcon = wantedIcon
	    local rightAbilityIcon = gunLicenseIcon

	    local isWanted = LocalPlayer():isWanted()

	    -- Left ability
	    local wantedColor = Color( 45, 45, isWanted and math.abs( math.sin( realTime / 0.5 ) * 128 ) or 45, 128 )
	    drawIconBox( leftAbilityIcon, xPos + 2, primaryAmmoContainerHeight - playerSideAbilityHeight , playerSideAbilityWidth, playerSideAbilityHeight, wantedColor, white )

	    if not config.hideServerIcon then
	      drawIconBox( ultimateAbilityIcon,
	        xPos + 6 + playerSideAbilityWidth + 4,  -- x
	        primaryAmmoContainerHeight - playerSideAbilityHeight ,  -- y
	        playerSideAbilityWidth * 2 - 10, playerSideAbilityHeight, -- w, h
	        Color( 45, 45, 45, 128 ), white,  -- backgroundColor, foregroundColor
	          playerSideAbilityWidth / 2, 6, 36, 36
	      )
	    end

	    -- Right ability
	    local hasGunLicense = LocalPlayer():getDarkRPVar("hasgunlicense")

	    drawIconBox( rightAbilityIcon, xPos + healthBarWidth - playerSideAbilityWidth, primaryAmmoContainerHeight - playerSideAbilityHeight, playerSideAbilityWidth, playerSideAbilityHeight,
	    Color( not hasGunLicense and 128 or 45, hasGunLicense and 128 or 45, 45, 128 ), white )

	cam.End3D2D()
end)

local rowLength, rowHeight, rowSpacer = 128, 36, 8
local backpackOriginX, backpackOriginY = -116, -120
local iconSize = rowHeight / 1.5

hook.Add( "PostDrawTranslucentRenderables", "divisionbackpack", function()
  if not DarkRP.thirdPersonEnabled or config.hideBackHUD or not drawDivisionHUDVar:GetBool() or not LocalPlayer():Alive() or LocalPlayer():InVehicle() then return end

	local playerVelocity = LocalPlayer()
	playerVelocity = playerVelocity.GetVelocity( playerVelocity )
	playerVelocity.z = 0

	local velocityLength = math.Round( playerVelocity.Length( playerVelocity ) )

	local hitWall = util.TraceLine(
	{
	  start = EyePos(),
	  endpos = EyePos() - EyeAngles():Right() * - 20
	}
	).Hit

	local weapon = LocalPlayer():GetActiveWeapon()

	local backbone = LocalPlayer():LookupBone( "ValveBiped.Bip01_Spine2" )
	local pos = LocalPlayer():GetBonePosition( backbone )
	if not pos then return end

	local bonematrix = LocalPlayer():GetBoneMatrix( backbone )
	if not bonematrix then return end
	local ang = bonematrix:GetAngles()

	ang:RotateAroundAxis( ang:Up(), -90 )
	ang:RotateAroundAxis( ang:Right(), -90 )

	local backSpace = 4
	local scaleOverride = 0.09
	local xPosForwardOverride = 5
	local yPosForwardOverride = 2

	cam.Start3D2D( pos + ( ang:Right() * yPosForwardOverride ) + ( ang:Up() * backSpace ) + ( ang:Forward() * xPosForwardOverride ), ang, scaleOverride )
		cam.IgnoreZ( true )

		surface.SetFont( "dThirdPersonFont_28" )

		local yOffset = 0
		for _, data in ipairs( dThirdPerson.getRows() ) do
		    if not data.noBackground then drawCustomOutlinedBox( backpackOriginX, backpackOriginY + yOffset, rowLength, rowHeight, Color( 40, 40, 40, data.inactive and 64 or 128 ) ) end
			if data.noBackground then draw.RoundedBox( 0, backpackOriginX + rowSpacer, backpackOriginY + yOffset + ( rowSpacer / 2 ), rowLength - ( rowSpacer * 2 ), rowHeight - ( rowSpacer ), Color( 20, 20, 20, 86 ) ) end

			local value = data.value()

			local textWidth = surface.GetTextSize( value )
			local maxWidth = rowLength - ( iconSize * 2 )
			local selectedFont = textWidth < maxWidth and "dThirdPersonFont_28" or textWidth < maxWidth * 1.3 and "dThirdPersonFont_20" or "dThirdPersonFont_16"

			draw.SimpleText( value, selectedFont, backpackOriginX + rowLength / 2 + ( iconSize / 2 ), backpackOriginY + ( rowHeight / 2 ) + yOffset, Color( 255, 255, 255, data.inactive and 64 or 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			local iconCol = data.iconColor
		    surface.SetDrawColor( iconCol.r, iconCol.g, iconCol.b, data.inactive and 40 or 255 )
		    surface.SetMaterial( data.icon )
		    surface.DrawTexturedRect( backpackOriginX + rowSpacer + ( data.noBackground and rowSpacer or 0 ), backpackOriginY + ( iconSize / 4 ) + yOffset, iconSize, iconSize )

			yOffset = yOffset + rowHeight + rowSpacer
		end

	cam.End3D2D()
end)

hook.Add( "PlayerSwitchWeapon", "weaponSwitchThing", function( client, oldWeapon, newWeapon )
	if not IsValid( oldWeapon ) or not oldWeapon.Clip1 or not oldWeapon:Clip1() then return end

	LocalPlayer().oldWeaponData = {
		clip1 = oldWeapon:Clip1()
	}
end )
