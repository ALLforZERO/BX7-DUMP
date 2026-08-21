#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;


main()
{
    // Load the Tranzit loop fire asset into the client's cache
    level._effect["custom_dog_fire_pool"] = loadfx("maps/zombie/fx_zmb_tranzit_fire_med");

    // Listen for the server updating any scriptmover entity on this channel
    registerclientfield( "scriptmover", "custom_dog_fire_fx", 14000, 1, "int", ::manage_dog_fire_fx, 0, 0 );
}

manage_dog_fire_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    // Safety: If an FX handle already exists on this entity, stop it first
    if ( isdefined( self.my_fire_fx_id ) )
    {
        stopfx( localclientnum, self.my_fire_fx_id );
        self.my_fire_fx_id = undefined;
    }
    
    // Server flipped the switch to [1] -> Start fire
    if ( newval == 1 )
    {
        // Storing the FX ID handle directly onto the entity
        self.my_fire_fx_id = playfxontag( localclientnum, level._effect["custom_dog_fire_pool"], self, "tag_origin" );
        
        // Play loopsound directly on this local entity
        self playloopsound( "zmb_hellhound_loop_fire", 0.5 );
    }
    // Server flipped the switch to [0] -> Clean up sound
    else if ( newval == 0 )
    {
        self stoploopsound( 0.5 );
    }
}