#using_animtree("zm_highrise_basic");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_traverse_ground_dugup;
	dummy_anim_ref = %ai_zombie_sprint_v6;
    dummy_anim_ref = %ai_zombie_sprint_v7;
    dummy_anim_ref = %ai_zombie_sprint_v8;
    dummy_anim_ref = %ai_zombie_sprint_v9;
    dummy_anim_ref = %ai_zombie_sprint_v10;
    dummy_anim_ref = %ai_zombie_sprint_v11;
    dummy_anim_ref = %ai_zombie_sprint_v12;
	dummy_anim_ref = %ai_zombie_dlc4_tesla_death_a;
    dummy_anim_ref = %ai_zombie_dlc4_tesla_death_b;
    dummy_anim_ref = %ai_zombie_dlc4_tesla_death_c;
    dummy_anim_ref = %ai_zombie_dlc4_tesla_death_d;
    dummy_anim_ref = %ai_zombie_dlc4_tesla_death_e;
    dummy_anim_ref = %ai_zombie_dlc4_tesla_crawl_death_a;
    dummy_anim_ref = %ai_zombie_dlc4_tesla_crawl_death_b;
	dummy_anim_ref = %ai_zombie_fast_sprint_03;
	dummy_anim_ref = %ai_zombie_fast_sprint_04;
	dummy_anim_ref = %ai_zombie_sprint_v13;
    dummy_anim_ref = %ai_zombie_sprint_v14;
    dummy_anim_ref = %ai_zombie_sprint_v15;
    dummy_anim_ref = %ai_zombie_sprint_v16;
    dummy_anim_ref = %ai_zombie_sprint_v17;
    dummy_anim_ref = %ai_zombie_sprint_v18;
    dummy_anim_ref = %ai_zombie_sprint_v19;
    dummy_anim_ref = %ai_zombie_sprint_v20;
    dummy_anim_ref = %ai_zombie_sprint_v21;
    dummy_anim_ref = %ai_zombie_sprint_v22;
}

init() {
    level thread reference_anims_from_animtree();
}