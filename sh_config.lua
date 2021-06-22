
-----------------------------------------------------

dThirdPerson.config.cooldown = 10 -- The cooldown between using the /thirdperson command. (does not apply to the key bind system)
dThirdPerson.config.hideHUD = true -- Whether or not the HUD should be hidden.
dThirdPerson.config.hideCrosshair = true -- Whether or not the HUD crosshair should be hidden.
dThirdPerson.config.hideBackHUD = true -- Whether or not the back HUD should be hidden.

dThirdPerson.config.fontFace = "Stratum2 Medium" -- Default font for the HUD.

dThirdPerson.config.weaponBlacklist = { -- Weapon blacklist for weapons that have -1 ammo or you do not want players to know.
  weapon_crowbar = true,
  weapon_physgun = true,
  weapon_physcannon = true,
}

dThirdPerson.config.healthBarColor = Color( 255, 140, 25 ) -- Health bar colour for the HUD.
dThirdPerson.config.armorBarColor = Color( 0, 160, 255 ) -- Armor bar colour for the HUD.

dThirdPerson.config.wantedIcon = "materials/icons/signs.png" -- The png icon for the player wanted indicator. (make sure you have FastDL/Workshop DL set up)
dThirdPerson.config.gunLicenseIcon = "materials/icons/notebook.png" -- The png icon for the gun license indicator. (make sure you have FastDL/Workshop DL set up)

dThirdPerson.config.serverIcon = "materials/icons/database.png" -- The png icon for the server's logo, you can change this to what you please. (make sure you have FastDL/Workshop DL set up)
dThirdPerson.config.hideServerIcon = true -- Whether it should be hiden or not.

dThirdPerson.config.hideDollarSigns = true -- Hides dollar signs from the money row on backpack.

dThirdPerson.config.enableThirdPersonOnConnect = false -- Decides whether the third person should be enabled on a player's connect.
dThirdPerson.config.keyBind = KEY_T -- Key bind for third person, see list for all key binds (https://wiki.garrysmod.com/page/Enums/KEY)
