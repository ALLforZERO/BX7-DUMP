#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

init()
{
    if(getdvar(#"mapname") == "zm_tomb" || getdvar(#"mapname") == "zm_prison" || getdvar(#"mapname") == "zm_buried" || getdvar(#"mapname") == "zm_highrise") return;
    
    precacheitem("slipgun_zm");
    precacheitem("slip_bolt_zm");
    precacheitem("slipgun_upgraded_zm");
    precacheitem("slip_bolt_upgraded_zm");
    precachemodel("t5_weapon_crossbow_bolt");

    include_weapon("slipgun_zm");
    add_limited_weapon("slipgun_zm", 1); // 1 player can get it (for box)
    add_zombie_weapon("slipgun_zm", "slipgun_upgraded_zm", &"ZOMBIE_WEAPON_SLIPGUN", 10, "slip", "", undefined );
    maps\mp\zombies\_zm_weap_slipgun::init();
}