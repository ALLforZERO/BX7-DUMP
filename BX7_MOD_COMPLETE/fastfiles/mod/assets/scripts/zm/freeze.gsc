#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

init()
{
    precachestring(&"ZOMBIE_WEAPON_FREEZEGUN");
    precacheitem("freezegun_zm");
    precacheitem("freezegun_upgraded_zm");

    // Primeiro incluímos a arma no sistema (se for Tranzit)
    if( getDvar("mapname") == "zm_transit" )
    {
        include_weapon("freezegun_zm");
        add_limited_weapon("freezegun_zm", 1);
        add_zombie_weapon("freezegun_zm", "freezegun_upgraded_zm", &"ZOMBIE_WEAPON_FREEZEGUN_UPGRADED", 10, "freeze", "", undefined );
    }

    maps\mp\zombies\_zm_weap_freezegun::init();
}