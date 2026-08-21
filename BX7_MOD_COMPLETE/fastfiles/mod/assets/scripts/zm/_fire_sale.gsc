#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

main()
{
  powerup_changes();
}

powerup_changes()
{
	if (getDvar("mapname") == "zm_transit" || getDvar("mapname") == "zm_highrise")
	{
		include_powerup("fire_sale");
	}
}