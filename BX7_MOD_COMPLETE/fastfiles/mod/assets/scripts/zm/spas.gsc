#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

init()
{
    precachestring(&"WEAPON_SPAS"); // wallbuy hint

    precacheitem("spas_zm");
    precacheitem("spas_upgraded_zm");

    include_weapon("spas_zm");
    add_zombie_weapon("spas_zm", "spas_upgraded_zm", &"WEAPON_SPAS", 10, "spas", "", undefined );
	
	include_weapon("m16_zm");
    add_zombie_weapon( "m16_zm", "m16_gl_upgraded_zm", &"ZOMBIE_WEAPON_M16", 1200, "burstrifle", "", undefined );
}