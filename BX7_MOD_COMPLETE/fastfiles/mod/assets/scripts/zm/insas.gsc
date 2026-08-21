#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

init()
{
    precachestring(&"WEAPON_INSAS"); // wallbuy hint

    precacheitem("insas_zm");
    precacheitem("insas_upgraded_zm");

    include_weapon("insas_zm");
    add_limited_weapon("insas_zm"); // 1 player can get it (for box)
    add_zombie_weapon("insas_zm", "insas_upgraded_zm", &"WEAPON_INSAS", 10, "insas", "", undefined );
}