#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zm_tomb;

init()
{
    // Only register scriptmover field if we are NOT on Origins
    if(getDvar("mapname") != "zm_tomb")
    {
        registerclientfield( "scriptmover", "aat_fx_manager", 14000, 3, "int", ::aat_fx_manager_handler, 1 );
    }
    
    if(getDvar("mapname") != "zm_tomb" && getDvar("mapname") != "zm_buried")
    {
        registerclientfield( "actor", "anim_rate", 14000, 2, "float", undefined, 0 );
        setupclientfieldanimspeedcallbacks( "actor", 1, "anim_rate" );

        registerclientfield( "actor", "aat_actor_fx_manager", 14000, 3, "int", ::aat_actor_fx_manager_handler, 1 );
    }

    level._effect["fire_staff_pool"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_fire_ug_impact_exp_loop" );
    level._effect["staff_water_blizzard"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_ice_ug_impact_hit" );
    level._effect["tesla_shock_eyes"] = loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );
    level._effect["tesla_bolt"]       = loadfx( "maps/zombie/fx_zombie_tesla_bolt_secondary" );
}

aat_fx_manager_handler( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( isdefined( self.aat_fx ) )
    {
        stopfx( localclientnum, self.aat_fx );
        self.aat_fx = undefined;
    }

    if ( isdefined( self.sndent ) )
    {
        self.sndent stoploopsound( 0.5 );
        self.sndent delete();
        self.sndent = undefined;
    }

    switch( newval )
    {
        case 1:
            self.aat_fx = playfxontag( localclientnum, level._effect["staff_water_blizzard"], self, "tag_origin" );

            if ( !isdefined( self.sndent ) )
            {
                self.sndent = spawn( 0, self.origin, "script_origin" );
                self.sndent playsound( 0, "wpn_waterstaff_storm_imp" );
                self.sndent playloopsound( "wpn_waterstaff_storm" );
                self.sndent thread snddemojumpmonitor();
            }
         
            self thread cleanup_aat_fx_on_shutdown(localclientnum);
            break;

        case 2:
            self.aat_fx = playfxontag( localclientnum, level._effect["fire_staff_pool"], self, "tag_origin" );

            if ( !isdefined( self.sndent ) )
            {
                self.sndent = spawn( 0, self.origin, "script_origin" );
                self.sndent playloopsound( 0, "wpn_firestaff_grenade_loop" );
                self.sndent thread snddemojumpmonitor();
            }
            
            self thread cleanup_aat_fx_on_shutdown(localclientnum);
            break;

        default:
            break;
    }
}

cleanup_aat_fx_on_shutdown(localclientnum)
{
    self notify("cleanup_aat_fx_singleton");
    self endon("cleanup_aat_fx_singleton");
    
    self waittill("entityshutdown"); 

    if ( isdefined( self.aat_fx ) )
    {
        stopfx( localclientnum, self.aat_fx );
        self.aat_fx = undefined;
    }

    if ( isdefined( self.sndent ) )
    {
        self.sndent stoploopsound( 0.5 );
        self.sndent delete();
        self.sndent = undefined;
    }
}

aat_actor_fx_manager_handler( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( isdefined( self.tesla_eyes ) )
    {
        stopfx( localclientnum, self.tesla_eyes );
        self.tesla_eyes = undefined;
    }
    if ( isdefined( self.tesla_bolt ) )
    {
        stopfx( localclientnum, self.tesla_bolt );
        self.tesla_bolt = undefined;
    }

    switch( newval )
    {
        case 1:
            if ( isdefined( level._effect["tesla_shock_eyes"] ) )
                self.tesla_eyes = playfxontag( localclientnum, level._effect["tesla_shock_eyes"], self, "J_Eyeball_LE" );

            if ( isdefined( level._effect["tesla_bolt"] ) )
                self.tesla_bolt = playfxontag( localclientnum, level._effect["tesla_bolt"], self, "j_spineupper" );
            break;

        default:
            break;
    }
}

snddemojumpmonitor()
{
    self endon( "entityshutdown" );
    level waittill( "demo_jump" );
    self delete();
}