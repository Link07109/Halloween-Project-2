package game

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/json"
import "ldtk"

default_font,
big_font,
font_linkawake,
font_alagard,
font_determination: rl.Font

default_font_size,
big_font_size: f32

load_fonts :: proc() {
    font_linkawake = rl.LoadFont("Resources/Fonts/linkawake_font.png")
    font_alagard = rl.LoadFont("Resources/Fonts/alagard.png")
    font_determination = rl.LoadFont("Resources/Fonts/DTM-Sans.otf")

    default_font = font_linkawake
    default_font_size = 8
    big_font = font_determination
    big_font_size = 32
}

//music_zant,
//music_snowpeak,
//music_mini_boss,
//music_guardian,
//music_balcony,
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
    // music_zant = rl.LoadMusicStream("Resources/Audio/zant.wav")
    // music_snowpeak = rl.LoadMusicStream("Resources/Audio/snowpeak.wav")
    // music_mini_boss = rl.LoadMusicStream("Resources/Audio/miniBoss.wav")
    // music_guardian = rl.LoadMusicStream("Resources/Audio/guardian.wav")
    //music_balcony = rl.LoadMusicStream("Resources/balcony.wav"),
    music_rain = rl.LoadMusicStream("Resources/Audio/Rain-Theme-Zenonia.wav")
    music_deep_inside = rl.LoadMusicStream("Resources/Audio/deep inside.wav")
    music_twilight = rl.LoadMusicStream("Resources/Audio/twilight.wav")
    music_dark_memories = rl.LoadMusicStream("Resources/Audio/darkMemories.wav")
    music_to_the_moon = rl.LoadMusicStream("Resources/Audio/to the moon.wav")
    music_lavender = rl.LoadMusicStream("Resources/Audio/lavender.wav")
    music_zenonia = rl.LoadMusicStream("Resources/Audio/zenonia-2-OST-Intro.wav")

    // sound_typing = rl.LoadSound("Resources/Audio/typing.wav")
    // sound_twilit_intro = rl.LoadSound("Resources/Audio/twilit intro.wav")
    // sound_oot_game_over = rl.LoadSound("Resources/Audio/ootGameOver.wav")
    sound_witch_laugh = rl.LoadSound("Resources/Audio/witchlaugh.wav")
    sound_tp_game_over = rl.LoadSound("Resources/Audio/tpGameOver.wav")
    sound_teleport = rl.LoadSound("Resources/Audio/teleport.wav")
    sound_spirit_gem_get = rl.LoadSound("Resources/Audio/Spirit-Gem-Get.wav")
    sound_run_roar = rl.LoadSound("Resources/Audio/runRAWR.wav")
    sound_link_scream1 = rl.LoadSound("Resources/Audio/linkscream1.wav")
    sound_link_scream2 = rl.LoadSound("Resources/Audio/linkscream2.wav")
    sound_gold_token = rl.LoadSound("Resources/Audio/goldToken.wav")
    sound_flowey = rl.LoadSound("Resources/Audio/flowey.wav")
    sound_dimensional = rl.LoadSound("Resources/Audio/dimensional.wav")
    sound_correct = rl.LoadSound("Resources/Audio/correctsound.wav")
    sound_beware = rl.LoadSound("Resources/Audio/BewareILive.wav")
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

game_over :: proc() {
    has_died = true
}

game_win :: proc() {
    rl.PlaySound(sound_spirit_gem_get)
    current_room = &room_win
}

letter_count,
key_count,
candy_count: u8
has_map: bool

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
