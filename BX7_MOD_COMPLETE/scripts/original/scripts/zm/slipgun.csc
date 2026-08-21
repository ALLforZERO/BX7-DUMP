#include clientscripts\mp\zombies\_zm_weapons;

init()
{
	include_weapon("slipgun_zm");
	
	clientscripts\mp\zombies\_zm_weap_slipgun::init();
}