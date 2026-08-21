#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

init()
{
    precachestring(&"WEAPON_IW4_CHEYTAC"); // wallbuy hint

    precacheitem("intervention_zm");
    precacheitem("intervention_upgraded_zm");

    include_weapon("intervention_zm");
    add_limited_weapon("intervention_zm", 1); // 1 player can get it (for box)
    add_zombie_weapon("intervention_zm", "intervention_upgraded_zm", &"WEAPON_IW4_CHEYTAC", 10, "intervention", "", undefined );
}