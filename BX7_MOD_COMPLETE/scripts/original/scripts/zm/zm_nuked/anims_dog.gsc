#using_animtree("zm_nuked_dog");

reference_anims_from_animtree()
{
    dummy_anim_ref = %zombie_dog_idle;
    dummy_anim_ref = %zombie_dog_attackidle_growl;
    dummy_anim_ref = %zombie_dog_attackidle;
    dummy_anim_ref = %zombie_dog_attackidle_bark;
    dummy_anim_ref = %zombie_dog_run_stop;
    dummy_anim_ref = %zombie_dog_run;
    dummy_anim_ref = %zombie_dog_trot;
    dummy_anim_ref = %zombie_dog_run_start;
    dummy_anim_ref = %zombie_dog_turn_90_left;
    dummy_anim_ref = %zombie_dog_turn_90_right;
    dummy_anim_ref = %zombie_dog_turn_180_left;
    dummy_anim_ref = %zombie_dog_turn_180_right;
    dummy_anim_ref = %zombie_dog_run_turn_90_left;
    dummy_anim_ref = %zombie_dog_run_turn_90_right;
    dummy_anim_ref = %zombie_dog_run_turn_180_left;
    dummy_anim_ref = %zombie_dog_run_turn_180_right;
    dummy_anim_ref = %zombie_dog_death_front;
    dummy_anim_ref = %zombie_dog_death_hit_back;
    dummy_anim_ref = %zombie_dog_death_hit_left;
    dummy_anim_ref = %zombie_dog_death_hit_right;
    dummy_anim_ref = %zombie_dog_run_attack;
    dummy_anim_ref = %zombie_dog_run_attack_low;
    dummy_anim_ref = %zombie_dog_run_jump_window_40;
    dummy_anim_ref = %zombie_dog_traverse_down_40;
    dummy_anim_ref = %zombie_dog_traverse_down_96;
    dummy_anim_ref = %zombie_dog_traverse_down_126;
    dummy_anim_ref = %zombie_dog_traverse_down_190;
    dummy_anim_ref = %zombie_dog_traverse_up_40;
    dummy_anim_ref = %zombie_dog_traverse_up_80;
    dummy_anim_ref = %ai_zombie_dog_jump_across_120;
    dummy_anim_ref = %zombie_dog_tesla_death_a;
    dummy_anim_ref = %zombie_dog_tesla_death_b;
    dummy_anim_ref = %zombie_dog_tesla_death_c;
    dummy_anim_ref = %zombie_dog_tesla_death_d;
    dummy_anim_ref = %zombie_dog_tesla_death_e;
}

init()
{
    level thread reference_anims_from_animtree();
}