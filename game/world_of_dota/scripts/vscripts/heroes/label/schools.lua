GAME_SCHOOLS_DPS = 1
GAME_SCHOOLS_HEAL = GAME_SCHOOLS_DPS * 2
GAME_SCHOOLS_TANK = GAME_SCHOOLS_HEAL * 2
--临时的专精表
_G.schools = {
    ["npc_dota_hero_lina"] = GAME_SCHOOLS_DPS,
    ["npc_dota_hero_silencer"] = GAME_SCHOOLS_DPS,
    ["npc_dota_hero_abaddon"] = GAME_SCHOOLS_TANK,
    ["npc_dota_hero_skeleton_king"] = GAME_SCHOOLS_DPS,
}