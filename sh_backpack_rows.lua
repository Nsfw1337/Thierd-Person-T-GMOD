
-----------------------------------------------------

------------ DO NOT EDIT ------------

local backRows = {}
function dThirdPerson.addRow( name, data )
	table.insert( backRows, data )
end

dThirdPerson.getRows = function() return backRows end

------------ EDIT BELOW THIS LINE ------------

dThirdPerson.addRow( "money", {
    icon = Material( "materials/icons/coins.png" ),
    iconColor = Color( 255, 161, 43 ),
    value = function() return string.Replace( DarkRP.formatMoney( LocalPlayer():getDarkRPVar( "money" ) ), dThirdPerson.config.hideDollarSigns and "$" or "", "" ) end,

    noBackground = true,
} )

dThirdPerson.addRow( "salary", {
    icon = Material( "materials/icons/coins.png" ),
    iconColor = Color( 43, 161, 255 ),
    value = function() return LocalPlayer():getJobTable().salary end,

    noBackground = true,
} )

dThirdPerson.addRow( "baggage", {
    icon = Material( "materials/icons/baggage.png" ),
    iconColor = Color( 255, 255, 255 ),
    value = function() return "Empty" end
} )

dThirdPerson.addRow( "darkzone", {
    icon = Material( "materials/icons/danger.png" ),
    iconColor = Color( 255, 255, 255 ),
    value = function() return "0/6" end,

    inactive = true,
} )
