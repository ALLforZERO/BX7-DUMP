#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

init()
{
    precachestring(&"WEAPON_T4_KAR98K"); // wallbuy hint

    precacheitem("kar98k_zm");
    precacheitem("kar98k_upgraded_zm");

    include_weapon("kar98k_zm");
    add_limited_weapon("kar98k_zm", 1); // 1 player can get it (for box)
    add_zombie_weapon("kar98k_zm", "kar98k_upgraded_zm", &"WEAPON_T4_KAR98K", 10, "kar98k", "", undefined );
}