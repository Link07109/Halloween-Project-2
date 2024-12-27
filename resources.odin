package game

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "ldtk"

token_pixel := load_image(.TokenPixel)

tileset,
outside_texture,
map_texture: rl.Texture

load_textures :: proc() {
    tileset = load_texture(.Worldtiles)
    outside_texture = load_texture(.Outside)
    map_texture = load_texture(.MapFullscreen)
    player_load_animation_textures()
}

default_font,
big_font,
font_linkawake,
font_alagard,
font_determination: rl.Font

default_font_size,
default_font_spacing,
big_font_size,
big_font_spacing: f32

font_key_color := rl.Color { 255, 0, 255, 255 }

load_fonts :: proc() {
    font_linkawake = load_font(.LinkawakeFont)
    font_alagard = load_font(.Alagard)

    font_determination = rl.LoadFont("Resources/Fonts/DTM-Sans.otf")

    default_font = font_linkawake
    default_font_size = 8
    default_font_spacing = 1
    big_font = font_alagard
    big_font_size = 32
    big_font_spacing = 1
}

//music_zant,
//music_snowpeak,
//music_mini_boss,
//music_guardian,
//music_balcony,
music_wind,
music_rain,
music_deep_inside,
music_twilight,
music_dark_memories,
music_to_the_moon,
music_lavender,
music_zenonia: rl.Music

//sound_typing,
//sound_twilit_intro,
//sound_oot_game_over,
sound_witch_laugh,
sound_tp_game_over,
sound_teleport,
sound_spirit_gem_get,
sound_run_roar,
sound_link_scream1,
sound_link_scream2,
sound_gold_token,
sound_flowey,
sound_dimensional,
sound_correct,
sound_beware: rl.Sound

load_audio :: proc() {
    // music_zant = load_music(.Zant)
    // music_snowpeak = load_music(.Snowpeak)
    // music_mini_boss = load_music(.MiniBoss)
    // music_guardian = load_music(.Guardian)
    // music_balcony = load_music(.Balcony)
    // music_to_the_moon = load_music(.ToTheMoon)

    music_wind = load_music(.Wind)
    music_rain = load_music(.RainThemeZenonia)
    music_deep_inside = load_music(.DeepInside)
    music_twilight = load_music(.Twilight)
    music_dark_memories = load_music(.DarkMemories)
    music_lavender = load_music(.Lavender)
    music_zenonia = load_music(.Zenonia2OstIntro)

    // sound_typing = load_sound(.Typing)
    // sound_twilit_intro = load_sound(.TwilitIntro)
    // sound_oot_game_over = load_sound(.OotGameOver)
    // sound_link_scream1 = load_sound(.Linkscream1)
    sound_witch_laugh = load_sound(.Witchlaugh)
    sound_tp_game_over = load_sound(.TpGameOver)
    sound_teleport = load_sound(.Teleport)
    sound_spirit_gem_get = load_sound(.SpiritGemGet)
    sound_run_roar = load_sound(.RunRawr)
    sound_link_scream2 = load_sound(.Linkscream2)
    sound_gold_token = load_sound(.GoldToken)
    // sound_flowey = load_sound(.Flowey)
    sound_dimensional = load_sound(.Dimensional)
    sound_correct = load_sound(.Correctsound)
    sound_beware = load_sound(.BewareIlive)
}

update_room_music :: proc(current_room: ^Room, current_music: ^rl.Music) {
    if !rl.IsMusicStreamPlaying(current_room.music) {
        rl.StopMusicStream(current_music^)
        current_music^ = current_room.music
        rl.PlayMusicStream(current_music^)
    } else {
        rl.UpdateMusicStream(current_music^)
    }
}

timer_soundfx: Timer
timer_link_scream: Timer
has_died: bool
reason_death: cstring

link_death :: proc() {
    rl.PlaySound(sound_link_scream2)
    timer_start(&timer_link_scream, 1)
}

game_over :: proc(current_music: rl.Music) {
    paused = true
    has_died = true
    rl.StopMusicStream(current_music)
}

game_win :: proc() {
    rl.PlaySound(sound_spirit_gem_get)
    current_room = &room_win
}

letter_count,
key_count,
candy_count: u8
has_map: bool

should_use_shader := true
should_show_map,
should_show_inventory,
should_show_inputbox,
should_show_dialogue: bool

hide_everything :: proc() {
    should_show_map = false
    should_show_inventory = false
    should_show_inputbox = false
    should_show_dialogue = false
}

clean_up :: proc(rooms_map: map[string]^Room) {
    rooms_map := rooms_map
    for _, room in rooms_map {
        delete(room.entity_tile_data)
    }
    //delete(rooms_map)
    if has_made_nopers {
        delete(nopers)
    }
    free_all(context.temp_allocator)
}

reset_data :: proc(rooms_map: map[string]^Room) {
    rooms_map := rooms_map
    hide_everything()
    clean_up(rooms_map)
    load_rooms()
    load_world(current_room, rooms_map)
    player_pos = { 112, 64 }
    player_sanity = 300
    key_count = 0
    candy_count = 0
    letter_count = 0
    has_map = false
    has_died = false
    reason_death = ""
}
