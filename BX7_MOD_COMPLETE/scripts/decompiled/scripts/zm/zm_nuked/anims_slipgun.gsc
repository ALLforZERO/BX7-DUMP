#using_animtree("zm_nuked_basic");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_slipslide_collapse;
    dummy_anim_ref = %ai_zombie_walk_slipslide;
    dummy_anim_ref = %ai_zombie_walk_slipslide_a;
    dummy_anim_ref = %ai_zombie_run_slipslide;
    dummy_anim_ref = %ai_zombie_run_slipslide_a;
    dummy_anim_ref = %ai_zombie_sprint_slipslide;
    dummy_anim_ref = %ai_zombie_sprint_slipslide_a;
    dummy_anim_ref = %ai_zombie_stand_slipslide_recover;
    dummy_anim_ref = %ai_zombie_crawl_slipslide_slow;
    dummy_anim_ref = %ai_zombie_crawl_slipslide_fast;
    dummy_anim_ref = %ai_zombie_crawl_slipslide_recover;
}

init()
{
    level thread reference_anims_from_animtree();
}