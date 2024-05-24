package game

import rl "vendor:raylib"
import "core:mem"
import "core:fmt"
import "core:encoding/json"
import "core:os"
import "ldtk"

PixelWindowHeight :: 180

platform_collider :: proc(pos: rl.Vector2) -> rl.Rectangle {
    return  {
        pos.x, pos.y,
        96, 19
    }
}

main :: proc() {
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

    rl.InitWindow(1920, 1080, "Halloween Project (v2.0)")
    rl.SetWindowState({ .WINDOW_RESIZABLE })
    rl.SetWindowIcon(rl.LoadImage("Resources/token.png"))
    //rl.SetWindowPosition(200, 200)
    rl.SetExitKey(.GRAVE)
    rl.SetTargetFPS(60)
    rl.HideCursor()

    rl.InitAudioDevice()

    music_dark_memories := rl.LoadMusicStream("Resources/Audio/darkMemories.wav")
//    music_zant := rl.LoadMusicStream("Resources/Audio/zant.wav")
//    music_to_the_moon := rl.LoadMusicStream("Resources/Audio/to the moon.wav")
//    music_snowpeak := rl.LoadMusicStream("Resources/Audio/snowpeak.wav")
//    music_mini_boss := rl.LoadMusicStream("Resources/Audio/miniBoss.wav")
    music_lavender := rl.LoadMusicStream("Resources/Audio/lavender.wav")
//    music_guardian := rl.LoadMusicStream("Resources/Audio/guardian.wav")
//
    sound_witch_laugh := rl.LoadSound("Resources/Audio/witchlaugh.wav")
//    sound_typing := rl.LoadSound("Resources/Audio/typing.wav")
//    sound_twilit_intro := rl.LoadSound("Resources/Audio/twilit intro.wav")
    sound_tp_game_over := rl.LoadSound("Resources/Audio/tpGameOver.wav")
    sound_teleport := rl.LoadSound("Resources/Audio/teleport.wav")
    sound_spirit_gem_get := rl.LoadSound("Resources/Audio/Spirit-Gem-Get-The-Legend-of-Zelda-Phantom-Hourglass-Music.wav")
    sound_run_roar := rl.LoadSound("Resources/Audio/runRAWR.wav")
//    sound_oot_game_over := rl.LoadSound("Resources/Audio/ootGameOver.wav")
    sound_link_scream1 := rl.LoadSound("Resources/Audio/linkscream1.wav")
    sound_link_scream2 := rl.LoadSound("Resources/Audio/linkscream2.wav")
    sound_gold_token := rl.LoadSound("Resources/Audio/goldToken.wav")
    sound_flowey := rl.LoadSound("Resources/Audio/flowey.wav")
    sound_dimensional := rl.LoadSound("Resources/Audio/dimensional.wav")
    sound_correct := rl.LoadSound("Resources/Audio/correctsound.wav")
    sound_beware := rl.LoadSound("Resources/Audio/BewareILive.wav")

    room_title_screen := Room {
        name = "Title_Screen",
        music = rl.LoadMusicStream("Resources/Audio/twilight.wav" ),
    }
    room_game_over := Room {
        name = "Game_Over_Screen",
        music = rl.LoadMusicStream("Resources/Audio/zenonia-2-OST-Intro.wav"),
    }
    room_main_hall := Room {
        name = "Main_Hall",
        music = music_dark_memories,
    }
    room_left := Room {
        name = "Left_Room",
        music = music_dark_memories,
    }
    room_secret := Room {
        name = "Secret_Room",
        music = music_dark_memories,
    }
    room_storage_closet := Room {
        name = "Storage_Closet",
        music = music_dark_memories,
    }
    room_basement := Room {
        name = "Basement",
        music = rl.LoadMusicStream("Resources/Audio/deep inside.wav"),
    }
    room_bedroom := Room {
        name = "Bedroom",
        music = music_dark_memories,
    }
    room_library := Room {
        name = "Library",
        music = music_dark_memories,
    }
    room_upper_chamber := Room {
        name = "Upper_Chamber",
        music = music_lavender,
    }
    room_bathroom := Room {
        name = "Bathroom",
        music = music_lavender,
    }
    room_upstairs_hallway := Room {
        name = "Upstairs_Hallway",
        music = music_lavender,
    }
    room_gallery := Room {
        name = "Gallery",
        music = music_lavender,
    }
    room_balcony := Room {
        name = "Balcony",
        music = rl.LoadMusicStream("Resources/Audio/Rain-Theme-Zenonia.wav"),
        //rl.LoadMusicStream("Resources/balcony.wav"),
    }
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
    current_room := &room_title_screen
    paused := true

    tile_size := 16
    tile_columns := 20
    tile_rows := 12
    candidate_room := current_room

    tileset := rl.LoadTexture("worldtiles.png")

    if project, ok := ldtk.load_from_file("workld.ldtk", context.temp_allocator).?; ok {
        fmt.println("---- Successfully loaded level json!!!")
        for level in project.levels {
            //level_iid := level.iid
            level_name := level.identifier

            if level_name not_in rooms_map {
                continue
            }
            if level_name != candidate_room.name {
                candidate_room = rooms_map[level_name]
            }
            fmt.printf("---- level name: %v", level_name)

            for layer in level.layer_instances {
                switch layer.type {
                    case .IntGrid: // collisions
                        fmt.println("---- Currently processing collision map")
                        candidate_room.collision_tiles = make([]u8, tile_columns * tile_rows)
                        candidate_room.tile_offset.x = f32(layer.px_total_offset_x)
                        candidate_room.tile_offset.y = f32(layer.px_total_offset_y)

                        for val, idx in layer.int_grid_csv {
                            candidate_room.collision_tiles[idx] = u8(val)
                        }

                        candidate_room.tile_data = make([]Tile, len(layer.auto_layer_tiles))

                        multiplier: f32 = f32(tile_size) / f32(layer.grid_size)
                        for val, idx in layer.auto_layer_tiles {
                            candidate_room.tile_data[idx].dst.x = f32(val.px.x) * multiplier
                            candidate_room.tile_data[idx].dst.y = f32(val.px.y) * multiplier
                            candidate_room.tile_data[idx].src.x = f32(val.src.x)
                            candidate_room.tile_data[idx].src.y = f32(val.src.y)
                            f := val.f
                            candidate_room.tile_data[idx].flip_x = bool(f & 1)
                            candidate_room.tile_data[idx].flip_y = bool(f & 2)
                        }
                    case .Entities: // literally everything else
                    case .Tiles: // custom floor
                    case .AutoLayer: // default floor
                        if layer.identifier != "Default_floor" {
                            continue
                        }
                        fmt.println("---- Currently processing floor tiles")
                        candidate_room.floor_tile_offset.x = f32(layer.px_total_offset_x)
                        candidate_room.floor_tile_offset.y = f32(layer.px_total_offset_y)

                        candidate_room.floor_tile_data = make([]Tile, len(layer.auto_layer_tiles))

                        multiplier: f32 = f32(tile_size) / f32(layer.grid_size)
                        for val, idx in layer.auto_layer_tiles {
                            candidate_room.floor_tile_data[idx].dst.x = f32(val.px.x) * multiplier
                            candidate_room.floor_tile_data[idx].dst.y = f32(val.px.y) * multiplier
                            candidate_room.floor_tile_data[idx].src.x = f32(val.src.x)
                            candidate_room.floor_tile_data[idx].src.y = f32(val.src.y)
                            f := val.f
                            candidate_room.floor_tile_data[idx].flip_x = bool(f & 1)
                            candidate_room.floor_tile_data[idx].flip_y = bool(f & 2)
                        }

                }
            }
        }
    } else {
        fmt.println("---- ERROR LOADING LEVEL JSON!!!!")
    }

    platform_texture := rl.LoadTexture("platform.png")
    game_map_texture := rl.LoadTexture("Resources/game map.png")
    //poe_soul_texture := rl.LoadTextureFromImage(rl.LoadImage("Resources/poe_soul.ico"))
    key_texture := rl.LoadTexture("Resources/smallKey.png")
    candy_texture := rl.LoadTexture("Resources/candy.png")
    player_load_animation_textures()

    current_music := current_room.music
    rl.PlayMusicStream(current_music)

    should_show_map: bool
    should_show_inventory: bool

    should_close_window: bool
    exit_window: bool

    // game loop
    for !exit_window {
        screen_height := f32(rl.GetScreenHeight())
        screen_width := f32(rl.GetScreenWidth())

        if rl.IsKeyPressed(.F11) {
            rl.ToggleFullscreen()
        }

        camera := rl.Camera2D {
           zoom = screen_height/PixelWindowHeight,
           //offset = { screen_width, screen_height/2 },
           //target = player_pos,
        }
        ui_camera := rl.Camera2D {
            zoom = screen_height/PixelWindowHeight,
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

            if !rl.IsMusicStreamPlaying(current_room.music) {
                rl.StopMusicStream(current_music)
                current_music = current_room.music
                rl.PlayMusicStream(current_music)
            } else {
                rl.UpdateMusicStream(current_music)
            }

            switch current_room.name {
                case "Main_Hall":
                    if rl.IsKeyPressed(.LEFT) {
                        current_room = &room_left
                    } else if rl.IsKeyPressed(.RIGHT) {
                        current_room = &room_library
                    } else if rl.IsKeyPressed(.UP) {
                        // (locked)
                        current_room = &room_upper_chamber
                    }
                case "Balcony":
                    if rl.IsKeyPressed(.DOWN) {
                        current_room = &room_upper_chamber
                    }
                case "Secret_Room":
                    if rl.IsKeyPressed(.UP) {
                        current_room = &room_left
                    }
                case "Bathroom":
                    if rl.IsKeyPressed(.LEFT) {
                        current_room = &room_upper_chamber
                    }
                case "Bedroom":
                    if rl.IsKeyPressed(.UP) {
                        current_room = &room_library
                    }
                case "Gallery":
                    if rl.IsKeyPressed(.RIGHT) {
                        current_room = &room_upstairs_hallway
                    }
                case "Left_Room":
                    if rl.IsKeyPressed(.DOWN) {
                        current_room = &room_secret
                    } else if rl.IsKeyPressed(.RIGHT) {
                        current_room = &room_main_hall
                    } else if rl.IsKeyPressed(.UP) {
                        current_room = &room_storage_closet
                    }
                case "Basement":
                    if rl.IsKeyPressed(.DOWN) {
                        current_room = &room_library
                    }
                case "Storage_Closet":
                    if rl.IsKeyPressed(.DOWN) {
                        current_room = &room_left
                    }
                case "Library":
                    if rl.IsKeyPressed(.DOWN) {
                        current_room = &room_bedroom
                    } else if rl.IsKeyPressed(.LEFT) {
                        current_room = &room_main_hall
                    } else if rl.IsKeyPressed(.UP) {
                        current_room = &room_basement
                    }
                case "Upper_Chamber":
                    if rl.IsKeyPressed(.LEFT) {
                        current_room = &room_upstairs_hallway
                    } else if rl.IsKeyPressed(.RIGHT) {
                        current_room = &room_bathroom
                    } else if rl.IsKeyPressed(.UP) {
                        current_room = &room_balcony
                    } else if rl.IsKeyPressed(.DOWN) {
                        current_room = &room_main_hall
                    }
                case "Upstairs_Hallway":
                    if rl.IsKeyPressed(.LEFT) {
                        current_room = &room_gallery
                    } else if rl.IsKeyPressed(.RIGHT) {
                        current_room = &room_upper_chamber
                    }
                case "Title_Screen":
                    paused = true
                    if rl.IsKeyPressed(.ENTER) {
                        paused = false
                        current_room = &room_main_hall
                    }
                case "Game_Over_Screen":
                    paused = true
                    if rl.IsKeyPressed(.ENTER) {
                        current_room = &room_title_screen
                    }
            }

            if !paused {
                if rl.IsKeyPressed(.I) {
                    should_show_inventory = !should_show_inventory
                }
                if rl.IsKeyPressed(.M) {
                    should_show_map = !should_show_map
                }

                player_movement()
                player_update_sanity()
                // player_wall_collision()
            }
        }


        // -------------------------------------------------------------------------------------------------

        rl.BeginDrawing()

        // drawables
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.WHITE)
        //if current_room.texture.width > 0 {
            //rl.DrawTextureV(current_room.texture, { 0, 0 }, rl.WHITE)
        //}

        offset: rl.Vector2
        //offset.x = f32(f32(screen_width) - f32(tile_size * tile_columns)) / 2

        if current_room.name != "Title_Screen" && current_room.name != "Game_Over_Screen" {
            for val in current_room.tile_data {
                src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
                if val.flip_x {
                    src_rect.width *= -1.0
                }
                if val.flip_y {
                    src_rect.height *= -1.0
                }
                dst_rect := rl.Rectangle {val.dst.x + offset.x + current_room.tile_offset.x, val.dst.y + offset.y + current_room.tile_offset.y, f32(tile_size), f32(tile_size)}
                rl.DrawTexturePro(tileset, src_rect, dst_rect, { f32(tile_size/2), f32(tile_size/2) }, 0, rl.WHITE)
            }
            for val in current_room.floor_tile_data {
                src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
                if val.flip_x {
                    src_rect.width *= -1.0
                }
                if val.flip_y {
                    src_rect.height *= -1.0
                }
                dst_rect := rl.Rectangle {val.dst.x + offset.x + current_room.floor_tile_offset.x, val.dst.y + offset.y + current_room.floor_tile_offset.y, f32(tile_size), f32(tile_size)}
                rl.DrawTexturePro(tileset, src_rect, dst_rect, { f32(tile_size/2), f32(tile_size/2) }, 0, rl.WHITE)
            }

            for row := 0; row < tile_rows; row += 1 {
                for column := 0; column < tile_columns; column += 1 {
                    collider := current_room.collision_tiles[row * tile_columns + column]

                    if collider != 0 {
                        coll := rl.Rectangle {f32(column * tile_size) + offset.x + current_room.tile_offset.x - f32(tile_size) / 2.0, f32(row * tile_size) + offset.y + current_room.tile_offset.y - f32(tile_size) / 2.0, f32(tile_size), f32(tile_size)}
                        //rl.DrawRectangleRec(coll, { 255, 10, 10, 25 })
                        player_collision(coll)
                    }
                }
            }

            if !paused {
                update_animation(&player_current_anim)
            }
            player_draw()
            player_draw_debug()
        }
        rl.EndMode2D()

        // gui
        new_cam := ui_camera
        rl.BeginMode2D(ui_camera)
        if current_room.name == "Title_Screen" {
            rl.ClearBackground(rl.DARKPURPLE)
            rl.DrawText("Halloween Project", 50, 50, 25, rl.WHITE)
            rl.DrawText("Press [ENTER] to start", 100, 100, 10, rl.WHITE)
            rl.DrawText("Ivan Valadez", 120, 165, 4, rl.WHITE)
        } else if current_room.name == "Game_Over_Screen" {
            rl.ClearBackground(rl.BLACK)
            rl.DrawText("Game Over", 50, 50, 25, rl.RED)
            rl.DrawText("Press [ENTER] to retry", 100, 100, 10, rl.WHITE)
        } else {
            ui_y := i32(165)
            // key
            rl.DrawTextureEx(key_texture, { 5, f32(ui_y) }, 1, 0.11, rl.WHITE)
            rl.DrawText("0", 20, ui_y + 2, 12, rl.WHITE)
            // candy
            rl.DrawTextureEx(candy_texture, { 50-5, f32(ui_y) }, 1, 0.015, rl.WHITE)
            rl.DrawText("0", 65-5, ui_y + 2, 12, rl.WHITE)

            player_draw_sanity()

            if should_show_inventory {
                // draw collected letters
                // play map when collected
                // draw player
                rl.DrawText("inventory", 100, 15, 4, rl.WHITE)
            }
            if should_show_map {
                rl.DrawTextureEx(game_map_texture, { 80, 3 }, 0, 0.35, rl.WHITE)
                //rl.DrawTextureV(poe_soul_texture, current_room.map_pos, rl.WHITE)
                rl.DrawText("current room name", 100, 15, 4, rl.WHITE)
            }
        }
        rl.EndMode2D()

        if should_close_window {
            rl.BeginMode2D(new_cam)
            rl.DrawRectangle(0, 55, i32(screen_width), 50, rl.BLACK)
            rl.DrawText("Are you sure you want to quit? [Y/N]", 50, 75, 11, rl.WHITE)
            rl.EndMode2D()
        }

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }

    rl.StopMusicStream(current_music)
    rl.UnloadMusicStream(current_music)
    rl.CloseAudioDevice()

    rl.CloseWindow()

    delete(rooms_map)
    for _, entry in rooms_map {
        delete(entry.tile_data)
        delete(entry.floor_tile_data)
        delete(entry.collision_tiles)
    }
    free_all(context.temp_allocator)
}
