package game

import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import "core:encoding/json"
import "core:os"
import "core:strings"

screen_width := f32(1344) //672
screen_height := f32(864) //432
title := cstring("Halloween Project (v2.0)")

game_screen_width := i32(224)
game_screen_height := i32(144)

paused := true
should_close_window,
exit_window: bool

dialogue_message: cstring

main :: proc() {
    // -------------------------------------------------------------------------------------------------
    // MEMORY TRACKING
    // -------------------------------------------------------------------------------------------------
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


    // -------------------------------------------------------------------------------------------------
    // INIT PHASE
    // -------------------------------------------------------------------------------------------------
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

    tileset := rl.LoadTexture("Resources/worldtiles.png")
    outside_texture := rl.LoadTexture("Resources/outside.png")
    game_map_texture := rl.LoadTexture("Resources/map_fullscreen.png")
    player_load_animation_textures()

    rl.InitAudioDevice()
    rl.SetMasterVolume(0.25)
    load_audio()
    load_fonts()
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


    // -------------------------------------------------------------------------------------------------
    // MAIN GAME LOOP
    // -------------------------------------------------------------------------------------------------
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
                                switch letter_count {
                                    case 1:
                                        dialogue_set_message("1")
                                    case 2:
                                        dialogue_set_message("9")
                                    case 3:
                                        dialogue_set_message("0")
                                }
                            case "Key":
                                key_count += 1
                                dialogue_set_message("* You got a key!")
                            case "Candy":
                                candy_count += 1
                                dialogue_set_message("* You got a piece of candy!")
                            case "Map":
                                has_map = true
                                dialogue_set_message("* You got the map!\n* Access it with 'M'")
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
        draw_phase(scale, target, shader, tileset, outside_texture, game_map_texture)

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
