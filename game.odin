package game

import rl "vendor:raylib"
import "core:mem"
import "core:fmt"
import "core:encoding/json"
import "core:os"
import "core:strings"
import "ldtk"

screen_width := f32(1344) //672
screen_height := f32(864) //432
title := cstring("Halloween Project (v2.0)")

game_screen_width := i32(224)
game_screen_height := i32(144)

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

room_title_screen,
room_game_over,
room_win,
room_main_hall,
room_left,
room_secret,
room_storage_closet,
room_basement,
room_bedroom,
room_library,
room_upper_chamber,
room_bathroom,
room_upstairs_hallway,
room_gallery,
room_balcony: Room

current_room: ^Room

load_rooms :: proc() {
    room_title_screen = Room {
        name = "Title_Screen",
        music = music_twilight
    }
    room_game_over = Room {
        name = "Game_Over_Screen",
        music = music_zenonia
    }
    room_win = Room {
        name = "Win_Screen",
    }

    room_main_hall = Room {
        name = "Main_Hall",
        music = music_dark_memories,
        map_pos = { 116, 84 }
    }
    room_left = Room {
        name = "Left_Room",
        music = music_dark_memories,
        map_pos = { 82, 84 }
    }
    room_secret = Room {
        name = "Secret_Room",
        music = music_dark_memories,
        map_pos = { 81, 103 }
    }
    room_storage_closet = Room {
        name = "Storage_Closet",
        music = music_dark_memories,
        map_pos = { 84, 67 }
    }
    room_basement = Room {
        name = "Basement",
        music = music_deep_inside,
        map_pos = { 154, 70 }
    }
    room_bedroom = Room {
        name = "Bedroom",
        music = music_dark_memories,
        map_pos = { 154, 104 }
    }
    room_library = Room {
        name = "Library",
        music = music_dark_memories,
        map_pos = { 154, 84 }
    }
    room_upper_chamber = Room {
        name = "Upper_Chamber",
        music = music_lavender,
        map_pos = { 122, 48 }
    }
    room_bathroom = Room {
        name = "Bathroom",
        music = music_lavender,
        map_pos = { 154, 48 }
    }
    room_upstairs_hallway = Room {
        name = "Upstairs_Hallway",
        music = music_lavender,
        map_pos = { 90, 48 }
    }
    room_gallery = Room {
        name = "Gallery",
        music = music_lavender,
        map_pos = { 60, 48 }
    }
    room_balcony = Room {
        name = "Balcony",
        music = music_rain,
        map_pos = { 122, 30 }
    }
}

load_world :: proc(candidate_room: ^Room, rooms_map: map[string]^Room) {
    if project, ok := ldtk.load_from_file("Resources/new world links awakening.ldtk", context.temp_allocator).?; ok {
        fmt.println("---- Successfully loaded ldtk json!!!")

        candidate_room := candidate_room
        for level in project.levels {
            level_name := level.identifier

            if level_name not_in rooms_map {
                continue
            }
            if level_name != candidate_room.name {
                candidate_room = rooms_map[level_name]
            }
            //fmt.printf("---- Level Name: %v\n", level_name)
            tile_size = project.default_grid_size

            for layer in level.layer_instances {
                switch layer.type {
                    case .IntGrid: // floor + walls, collisions
                        candidate_room.tile_data = load_tile_layer_ldtk(layer.auto_layer_tiles)

                        for val, idx in layer.int_grid_csv {
                            candidate_room.collision_tiles[idx] = u8(val)
                        }
                    case .Entities: // items, interactables
                        candidate_room.entity_tile_data = load_entity_layer_ldtk(candidate_room, rooms_map, layer, layer.entity_instances, &candidate_room.entity_tile_offset)

                    case .Tiles: // custom tiles
                        candidate_room.custom_tile_data = load_tile_layer_ldtk(layer.grid_tiles)
                    case .AutoLayer:
                }
            }
        }
        free_all(context.allocator)
    } else {
        fmt.println("---- ERROR LOADING LDTK JSON!!!!")
    }
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

game_over :: proc() {
    has_died = true
}

link_death :: proc() {
    rl.PlaySound(sound_link_scream2)
    timer_start(&timer_link_scream, 1)
}

game_win :: proc() {
    // yippi !
    rl.PlaySound(sound_spirit_gem_get)
    current_room = &room_win
}

dialogue_message: cstring

paused := true
should_show_map,
should_show_inventory,
should_show_inputbox,
should_show_dialogue,

exit_window,
should_close_window: bool

main :: proc() {
    // ---
    // MEMORY TRACKING
    // ---

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer {
        for _, entry in track.allocation_map {
            fmt.eprintf("%v leaked %v bytes \n", entry.location, entry.size)
        }

        for entry in track.bad_free_array {
            fmt.eprintf("%v bad free\n", entry.location)
        }

        mem.tracking_allocator_destroy(&track)
    }


    // ---
    // INIT PHASE
    // ---

    rl.InitWindow(i32(screen_width), i32(screen_height), title)
    rl.SetWindowMinSize(game_screen_width, game_screen_height)
    rl.SetWindowState({ .WINDOW_MAXIMIZED, .VSYNC_HINT, .WINDOW_ALWAYS_RUN, .WINDOW_HIGHDPI })
    rl.SetWindowIcon(rl.LoadImage("Resources/tokenPixel.png"))
    rl.SetExitKey(.GRAVE)
    rl.SetTargetFPS(60)
    rl.HideCursor()

    target := rl.LoadRenderTexture(game_screen_width, game_screen_height)
    rl.SetTextureFilter(target.texture, .POINT)

    shader := rl.LoadShader("scan.vert", "scan.frag")
    //shader := rl.LoadShader("", "blur.fs")

    tileset := rl.LoadTexture("Resources/worldtiles.png")
    outside_texture := rl.LoadTexture("Resources/outside.png")
    game_map_texture := rl.LoadTexture("Resources/map_fullscreen.png")
    player_load_animation_textures()

    load_fonts()

    rl.InitAudioDevice()
    rl.SetMasterVolume(0.25)
    load_audio()
    load_rooms()
    rooms_map := map[string]^Room {
        "Main_Hall" = &room_main_hall,
        "Balcony" = &room_balcony,
        "Bathroom" = &room_bathroom,
        "Bedroom" = &room_bedroom,
        "Upper_Chamber" = &room_upper_chamber,
        "Upstairs_Hallway" = &room_upstairs_hallway,
        "Left_Room" = &room_left,
        "Secret_Room" = &room_secret,
        "Library" = &room_library,
        "Basement" = &room_basement,
        "Gallery" = &room_gallery,
        "Storage_Closet" = &room_storage_closet,
    }
    candidate_room := &room_left
    load_world(candidate_room, rooms_map)

    current_room = &room_title_screen
    current_music := current_room.music
    rl.PlayMusicStream(current_music)


    // ---
    // MAIN GAME LOOP
    // ---

    for !exit_window {
        screen_width = f32(rl.GetScreenWidth())
        screen_height = f32(rl.GetScreenHeight())
        scale := min(screen_width/f32(game_screen_width), screen_height/f32(game_screen_height))

        if rl.IsKeyPressed(.F11) {
            rl.ToggleFullscreen()
        }

        if rl.IsKeyPressed(.R) {
            rl.SetWindowSize(672, 432)
        }

        if rl.WindowShouldClose() {
            should_close_window = true
        }

        if should_close_window {
            paused = true
            if rl.IsKeyPressed(.Y) || rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
                exit_window = true
            } else if rl.IsKeyPressed(.N) || rl.IsKeyPressed(.ESCAPE) {
                paused = false
                should_close_window = false
            }
        } else {
            update_room_music(current_room, &current_music)

            switch current_room.name {
                case "Title_Screen":
                    paused = true
                    if rl.IsKeyPressed(.ENTER) {
                        paused = false
                        current_room = &room_main_hall
                    }
                case "Game_Over_Screen":
                    paused = true
                    if rl.IsKeyPressed(.ENTER) {
                        reset_data(rooms_map)
                        current_room = &room_title_screen
                    }
                case "Win_Screen":
                    paused = true
                    if rl.IsKeyPressed(.ENTER) {
                        reset_data(rooms_map)
                        current_room = &room_title_screen
                    }
            }

            // actually playing the game!
            if !paused {
                if rl.IsKeyPressed(Inventory_Toggle) {
                    should_show_inventory = !should_show_inventory
                }
                if rl.IsKeyPressed(Map_Toggle) && has_map {
                    should_show_map = !should_show_map
                }
                if rl.IsKeyPressed(Interact) {
                    should_show_dialogue = false
                }

                timer_update(&timer_soundfx)
                if timer_done(&timer_soundfx) {
                    link_death()
                }
                timer_update(&timer_link_scream)
                if timer_done(&timer_link_scream) {
                    current_room = &room_game_over
                }
                player_movement()
                player_update_sanity()

                //if current_room.name == "Basement" {
                    // TODO: make this only happen upon entering the room
                    //dialogue_set_message("* This candy might be helpful.\n* Take it for entering the\ncorrect number")
                //}

                for &spike in current_room.spikes {
					if spike.coll == { 0, 0, 0, 0 } {
						break
					}
                    if player_collided_with(spike.coll) {
                        if !has_died {
							reason_death = "You got shredded by spikes."
                            link_death()
                            game_over()
                        }
                    }

                    // move spike
                    if spike.up {
                        spike.coll.y -= 1.5
                    } else {
                        spike.coll.y += 1.5
                    }

                    if spike.coll.y >= 80 {
                        spike.up = true
                    } else if spike.coll.y <= 32 {
                        spike.up = false
                    }
                }

                for &door in current_room.doors {
                    if player_collided_with(door.coll) && !door.collided_with {
                        should_show_dialogue = false
                        if door.locked_with == "Key" {
                            door.collided_with = true
                            if  key_count <= 0 {
                                dialogue_set_message("* This door is locked, silly!\nGo get a key!") // show this in dialogue box
                                break
                            } else {
                                key_count -= 1
                                door.locked_with = ""
                                door.src = { 96, 112, 32, 16 }
                            }
                        } else if door.locked_with == "Code" {
                            should_show_inputbox = true
                            inputbox_show("How many letters are there?", 1)
                            if rl.IsKeyPressed(.ENTER) {
                                inputbox_process(&door, "3")
                                should_show_inputbox = false
                            }
                            break
                        } else if door.locked_with == "Puzzle" {
                            should_show_inputbox = true
                            inputbox_show("Enter in a number", 4)
                            if rl.IsKeyPressed(.ENTER) {
                                inputbox_process(&door, "5190")
                                should_show_inputbox = false
                            }
                            break
                        }
                        current_room = door.dest_room
                        player_pos = door.dest_player_pos
                        break
                    } else if !player_collided_with(door.coll) && door.collided_with {
                        door.collided_with = false
                    } else if !player_collided_with(door.coll) {
                        should_show_inputbox = false
                    }
                }

                for &entity, idx in current_room.entity_tile_data {
                    // door logic already done
                    if entity.identifier == "Door" {
                        unordered_remove(&current_room.entity_tile_data, idx)
                        continue
                    // dont draw spikes here bc they get drawn when they move
                    } else if entity.identifier == "Spike" {
                        unordered_remove(&current_room.entity_tile_data, idx)
                        continue
                    }

                    entity_coll := rl.Rectangle { entity.dst.x, entity.dst.y, f32(entity.width), f32(entity.height) }
                    if player_collided_with(entity_coll) {
                        switch entity.identifier {
                            case "Sign":
                                if !rl.IsSoundPlaying(sound_beware) {
                                    rl.PlaySound(sound_beware)
                                }
                                continue
                            case "Pot":
                                dialogue_set_message("* Just a normal pot.\nNothing to see here")
                                continue
                            case "Statue":
                                if !rl.IsSoundPlaying(sound_dimensional) {
                                    rl.PlaySound(sound_dimensional)
                                }
                                // yeet player into the sky
                                // cool floaty player animation
                                // cant move for like 2 seconds
                                // this used to kill u, idk if it still does
                                continue
                            case "Mirror":
                                if !has_died {
                                    dialogue_set_message("* You look into the mirror but\ndon't see your reflection...")
                                    rl.PlaySound(sound_witch_laugh)
                                    timer_start(&timer_soundfx, 2)
                                    reason_death = "You shouldn't have done that"
                                    game_over()
                                }
                                continue
                            case "Letter":
                                letter_count += 1
                            case "Key":
                                key_count += 1
                                dialogue_set_message("* You got a key!")
                            case "Candy":
                                candy_count += 1
                                dialogue_set_message("* You got a piece of candy!")
                            case "Map":
                                has_map = true
                                dialogue_set_message("* You got the map!\n* Press M to use it!")
                        }
                        // pick up item! (removes it from the array of tiles so it wont be checked again or drawn)
                        if !strings.has_prefix(entity.identifier, "\x00") {
                            fmt.printf("Picked up: %v\n", entity.identifier)
                            unordered_remove(&current_room.entity_tile_data, idx)
                            rl.PlaySound(sound_gold_token)

                            if candy_count >= 2 {
                                game_win()
                            }
                        }
                    }
                }
            }
        }


        // -------------------------------------------------------------------------------------------------
        // DRAWING PHASE
        // -------------------------------------------------------------------------------------------------

        // put everything in render texture so we can scale it easily
        rl.BeginTextureMode(target)

        // game
        if current_room.name != "Title_Screen" && current_room.name != "Game_Over_Screen" && current_room.name != "Win_Screen" {
            //rl.ClearBackground({ 248, 248, 136, 255 })
            rl.ClearBackground({ 11, 10, 22, 255 })

            if !should_show_map {
                draw_tiles_ldtk(tileset, current_room.tile_data)
                if current_room.name == "Balcony" {
                    rl.DrawTexture(outside_texture, 0, 0, rl.WHITE)
                }
                draw_entity_tiles_ldtk(tileset, current_room.entity_tile_offset, current_room.entity_tile_data)
                for door in current_room.doors {
                    rl.DrawTexturePro(tileset, door.src, door.coll, { 0, 0 }, 0, rl.WHITE)
                }
                spike_src := rl.Rectangle { 128, 32, 16, 16 }
                for spike in current_room.spikes {
                    rl.DrawTexturePro(tileset, spike_src, spike.coll, { 0, 0 }, 0, rl.WHITE)
                }
                draw_tiles_ldtk(tileset, current_room.custom_tile_data)
                player_edge_collision()
                handle_collisions(current_room)
            }

            if !paused && !player_stop_animating {
                update_animation(&player_current_anim)
            }
            player_draw()
            //player_draw_debug()
        }

        // gui
        if current_room.name == "Title_Screen" {
            rl.ClearBackground(rl.Color { 128, 0, 128, 255})
            rl.DrawTextEx(font_linkawake, "Halloween Project", { 20, 32 }, 16, 1, rl.Color { 127, 255, 212, 255 })
            rl.DrawTextEx(big_font, "Press", { 50, 80 }, 16, 0, rl.WHITE)
            rl.DrawTextEx(big_font, "[ENTER]", { f32(50 + rl.MeasureTextEx(big_font, "Press ", 16, 0)[0]), 80 }, 16, 0, rl.RED)
            rl.DrawTextEx(big_font, "to start", { f32(50 + rl.MeasureTextEx(big_font, "Press [ENTER] ", 16, 0)[0]), 80 }, 16, 0, rl.WHITE)
            rl.DrawTextEx(font_alagard, "Ivan Valadez", { 80, 128 }, 16, 0, rl.WHITE)
        } else if current_room.name == "Game_Over_Screen" {
            rl.ClearBackground(rl.BLACK)
            rl.DrawTextEx(big_font, "YOU DIED", { 65, 32 }, big_font_size, 0, rl.WHITE)
            rl.DrawTextEx(default_font, reason_death, { 60, 64 }, default_font_size, 1, rl.WHITE)
            rl.DrawTextEx(big_font, "Press", { 50, 80 }, 16, 0, rl.WHITE)
            rl.DrawTextEx(big_font, "[ENTER]", { f32(50 + rl.MeasureTextEx(big_font, "Press ", 16, 0)[0]), 80 }, 16, 0, rl.RED)
            rl.DrawTextEx(big_font, "to retry", { f32(50 + rl.MeasureTextEx(big_font, "Press [ENTER] ", 16, 0)[0]), 80 }, 16, 0, rl.WHITE)
        } else if current_room.name == "Win_Screen" {
            rl.ClearBackground(rl.GREEN)
            rl.DrawTextEx(big_font, "You Won! YIPPIIE!", { 65, 32 }, big_font_size, 0, rl.WHITE)
            rl.DrawTextEx(big_font, "Press", { 50, 80 }, 16, 0, rl.WHITE)
            rl.DrawTextEx(big_font, "[ENTER]", { f32(50 + rl.MeasureTextEx(big_font, "Press ", 16, 0)[0]), 80 }, 16, 0, rl.RED)
            rl.DrawTextEx(big_font, "to restart!", { f32(50 + rl.MeasureTextEx(big_font, "Press [ENTER] ", 16, 0)[0]), 80 }, 16, 0, rl.WHITE)
        } else {
            ui_y := i32(128)
            // key
            key_src := rl.Rectangle { 160, 80, 16, 16 }
            rl.DrawTexturePro(tileset, key_src, { 4, f32(ui_y) - 1, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
            rl.DrawText(fmt.ctprintf("%v", key_count), 20, ui_y + 4, 3, rl.WHITE)
            // candy
            candy_src := rl.Rectangle { 160, 64, 16, 16 }
            rl.DrawTexturePro(tileset, candy_src, { 50-7, f32(ui_y), 16, 16 }, { 0, 0 }, 0, rl.WHITE)
            rl.DrawText(fmt.ctprintf("%v", candy_count), 60, ui_y + 4, 3, rl.WHITE)

            player_draw_sanity()

            if should_show_inputbox {
                inputbox_draw()
            } else if should_show_dialogue {
                dialogue_draw(dialogue_message)
            }

            if should_show_inventory {
                // draw outline
                rl.DrawRectangleLines(98, 30, 20, 20+48, rl.WHITE)

                // draw collected letters
                letter_src := rl.Rectangle { 144, 64, 16, 16 }
                switch letter_count {
                    case 3:
                        rl.DrawTexturePro(tileset, letter_src, { 100, 32+32, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                        rl.DrawText("0", 120, 32+36, 3, rl.WHITE)
                        fallthrough
                    case 2:
                        rl.DrawTexturePro(tileset, letter_src, { 100, 32+16, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                        rl.DrawText("9", 120, 32+20, 3, rl.WHITE)
                        fallthrough
                    case 1:
                        rl.DrawTexturePro(tileset, letter_src, { 100, 32, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                        rl.DrawText("1", 120, 32+4, 3, rl.WHITE)
                }

                // draw map when collected
                if has_map {
                    map_src := rl.Rectangle { 128, 64, 16, 16 }
                    rl.DrawTexturePro(tileset, map_src, { 100, 32+48, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                }

                rl.DrawText("Inventory", 80, 16, 4, rl.WHITE)
            }
            if should_show_map {
                poe_soul_src := rl.Rectangle { 112, 96, 16, 16 }
                rl.DrawTexture(game_map_texture, 0, 0, rl.WHITE)
                rl.DrawTexturePro(tileset, poe_soul_src, { current_room.map_pos.x, current_room.map_pos.y, 16, 16 }, 0, 0, rl.WHITE)
                rl.DrawText(fmt.ctprintf("%v", current_room.name), 80, 16, 4, rl.WHITE)
            }
        }

        if should_close_window {
            rl.DrawRectangle(0, 55, i32(screen_width), 50, rl.BLACK)
            rl.DrawText("Are you sure you want to quit? [Y/N]", 10, 75, 3, rl.WHITE)
        }

        rl.EndTextureMode()


        // draw render texture
        rl.BeginDrawing()
        
	    rl.BeginShaderMode(shader)
        rl.DrawTexturePro(target.texture, { 0, 0, f32(target.texture.width), -1 * f32(target.texture.height) },
        { screen_width - f32(game_screen_width)*scale, screen_height - f32(game_screen_height)*scale, // for some reason every example has * 0.5 on both of these numbers
        //{0, 0,
        f32(game_screen_width)*scale, f32(game_screen_height)*scale }, { 0, 0 }, 0, rl.WHITE)
	    rl.EndShaderMode()

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }


    // ---
    // GAME CLOSE (CLEANUP)
    // ---

    rl.StopMusicStream(current_music)
    rl.UnloadMusicStream(current_music)
    rl.CloseAudioDevice()

    rl.CloseWindow()

    for _, room in rooms_map {
        delete(room.entity_tile_data)
    }
    delete(rooms_map)
    if has_made_nopers {
        delete(nopers)
    }
    free_all(context.temp_allocator)
}
