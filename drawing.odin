package game

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

game_over_timer: Timer
game_over_timer_start :: proc(lifetime: f32) {
    timer_start(&game_over_timer, lifetime)
    rl.PlaySound(sound_tp_game_over)
}
game_over_timer_update :: proc(current_music: rl.Music) {
    timer_update(&game_over_timer)
    if !timer_done(&game_over_timer) {
        //rl.PauseMusicStream(current_music)
    } else {
        has_died = false
        //rl.ResumeMusicStream(current_music)
    }
}


ui_text_color := rl.BLACK
transition_color := rl.Color { 0, 0, 0, 0 }

center_text_x :: proc(x_start: f32, width: f32, text: cstring, font := font_alagard, size := f32(16)) -> f32 {
    diff := width - rl.MeasureTextEx(font, text, size, big_font_spacing).x
    return x_start + (diff / 2)
}

room_transition_timer1: Timer
room_transition_timer2: Timer
room_transition_timer_mid: Timer
transition_duration_mid := f32(0.5)
transition_duration := f32(0.133)
next_room: ^Room
next_player_pos: rl.Vector2

transition_loop :: proc() {
    timer_update(&room_transition_timer1)
    timer_update(&room_transition_timer_mid)
    timer_update(&room_transition_timer2)

    if room_transition_timer1.started {
        transition_color.a += u8(rl.GetFrameTime() * 255 / transition_duration)
        if transition_color.a > 255 {
            transition_color.a = 255
        }
    }

    if room_transition_timer2.started {
        transition_color.a -= u8(rl.GetFrameTime() * 255 / transition_duration)
        if transition_color.a < 0 {
            transition_color.a = 0
        }
    }

    // go to next room
    if timer_done(&room_transition_timer1) {
        current_room = next_room
        player_pos = next_player_pos
        player_feet_collider.x = player_pos.x - 6
        player_feet_collider.y = player_pos.y - 9
        stop_other_sounds()
        room_transition_mid()
    }

    if timer_done(&room_transition_timer_mid) {
        room_transition_end()
    }

    if timer_done(&room_transition_timer2) {
        paused = false
    }
}

// called on door collision
room_transition_start :: proc(room: ^Room, pos: rl.Vector2) {
    next_room = room
    next_player_pos = pos
    paused = true
    timer_start(&room_transition_timer1, transition_duration)
}

// called on room switch
room_transition_mid :: proc() {
    transition_color.a = 255
    timer_start(&room_transition_timer_mid, transition_duration_mid)
}

// called on fade timer end
room_transition_end :: proc() {
    timer_start(&room_transition_timer2, transition_duration)
}

draw_phase :: proc(scale: f32, target: rl.RenderTexture, shader: rl.Shader, tileset, outside_texture, game_map_texture: rl.Texture) {
    // put everything in render texture so we can scale it easily
    rl.BeginTextureMode(target)

    // game
    if current_room.name != "Title_Screen" && current_room.name != "Game_Over_Screen" && current_room.name != "Win_Screen" {
        rl.ClearBackground({ 255, 189, 140, 255 })
        // rl.ClearBackground({ 11, 10, 22, 255 })

        if !should_show_map && !should_show_inventory {
            ui_text_color = rl.BLACK

            draw_tiles_ldtk(tileset, current_room.tile_data)
            if current_room.name == "Balcony" {
                rl.DrawTexture(outside_texture, 0, 0, rl.WHITE)
            }
            draw_tiles_ldtk(tileset, current_room.custom_tile_data)
            draw_entity_tiles_ldtk(tileset, current_room.entity_tile_offset, current_room.entity_tile_data)

            for door in current_room.doors {
                rl.DrawTexturePro(tileset, door.src, door.coll, { 0, 0 }, 0, rl.WHITE)
            }
            spike_src := rl.Rectangle { 128, 32, 16, 16 }
            for spike in current_room.spikes {
                rl.DrawTexturePro(tileset, spike_src, spike.coll, { 0, 0 }, 0, rl.WHITE)
            }

            player_edge_collision()
            handle_collisions(current_room)
            if !paused && !player_stop_animating {
                update_animation(&player_current_anim)
            }
            player_draw()
            //player_draw_debug()
        } else {
            ui_text_color = rl.WHITE
        }
    }

    // gui
    if current_room.name == "Title_Screen" {
        rl.ClearBackground(rl.Color { 128, 0, 128, 255})

        title_center_x := center_text_x(0, 224, "Halloween Project", font_linkawake)
        rl.DrawTextEx(font_linkawake, "Halloween Project", { title_center_x, 32 }, 16, 1, rl.Color { 127, 255, 212, 255 })

        start_game_center_x := center_text_x(0, 224, "Press [ENTER] to start")
        rl.DrawTextEx(big_font, "Press", { start_game_center_x, 80 }, 16, big_font_spacing, rl.WHITE)
        rl.DrawTextEx(big_font, "[ENTER]", { f32(start_game_center_x + rl.MeasureTextEx(big_font, "Press ", 16, big_font_spacing).x), 80 }, 16, big_font_spacing, rl.RED)
        rl.DrawTextEx(big_font, "to start", { f32(start_game_center_x + rl.MeasureTextEx(big_font, "Press [ENTER] ", 16, big_font_spacing).x), 80 }, 16, big_font_spacing, rl.WHITE)

        ivan_center_x := center_text_x(0, 224, "Ivan Valadez")
        rl.DrawTextEx(font_alagard, "Ivan Valadez", { ivan_center_x, 128 }, 16, big_font_spacing, rl.WHITE)
    } else if current_room.name == "Game_Over_Screen" {
        rl.ClearBackground(rl.BLACK)

        you_died_center_x := center_text_x(0, 224, "YOU DIED", size=big_font_size)
        rl.DrawTextEx(big_font, "YOU DIED", { you_died_center_x, 24 }, big_font_size, big_font_spacing, rl.WHITE)

        reason_death_center_x := center_text_x(0, 224, reason_death, font_linkawake, size=default_font_size)
        rl.DrawTextEx(default_font, reason_death, { reason_death_center_x, 64 }, default_font_size, big_font_spacing, rl.WHITE)

        retry_game_center_x := center_text_x(0, 224, "Press [ENTER] to retry")
        rl.DrawTextEx(big_font, "Press", { retry_game_center_x, 80 }, 16, big_font_spacing, rl.WHITE)
        rl.DrawTextEx(big_font, "[ENTER]", { f32(retry_game_center_x + rl.MeasureTextEx(big_font, "Press ", 16, big_font_spacing)[0]), 80 }, 16, big_font_spacing, rl.RED)
        rl.DrawTextEx(big_font, "to retry", { f32(retry_game_center_x + rl.MeasureTextEx(big_font, "Press [ENTER] ", 16, big_font_spacing)[0]), 80 }, 16, big_font_spacing, rl.WHITE)
    } else if current_room.name == "Win_Screen" {
        rl.ClearBackground(rl.DARKGREEN)

        you_won_center_x := center_text_x(0, 224, "You Won!", size=big_font_size)
        rl.DrawTextEx(big_font, "You Won!", { you_won_center_x, 32 }, big_font_size, big_font_spacing, rl.WHITE)

        restart_game_center_x := center_text_x(0, 224, "Press [ENTER] to restart")
        rl.DrawTextEx(big_font, "Press", { restart_game_center_x, 80 }, 16, big_font_spacing, rl.WHITE)
        rl.DrawTextEx(big_font, "[ENTER]", { f32(restart_game_center_x + rl.MeasureTextEx(big_font, "Press ", 16, big_font_spacing)[0]), 80 }, 16, big_font_spacing, rl.RED)
        rl.DrawTextEx(big_font, "to restart!", { f32(restart_game_center_x + rl.MeasureTextEx(big_font, "Press [ENTER] ", 16, big_font_spacing)[0]), 80 }, 16, big_font_spacing, rl.WHITE)
    } else {
        ui_y := i32(128)
        // key
        key_src := rl.Rectangle { 160, 80, 16, 16 }
        rl.DrawTexturePro(tileset, key_src, { 4, f32(ui_y), 16, 16 }, { 0, 0 }, 0, rl.WHITE)
        rl.DrawTextEx(big_font, fmt.ctprintf("%v", key_count), { 20, f32(ui_y) + 1 }, 16, big_font_spacing, ui_text_color)
        // candy
        candy_src := rl.Rectangle { 160, 64, 16, 16 }
        rl.DrawTexturePro(tileset, candy_src, { 50-7, f32(ui_y), 16, 16 }, { 0, 0 }, 0, rl.WHITE)
        rl.DrawTextEx(big_font, fmt.ctprintf("%v", candy_count), { 60, f32(ui_y) + 1 }, 16, big_font_spacing, ui_text_color)

        player_draw_sanity()

        if should_show_inputbox {
            inputbox_draw()
        } else if should_show_dialogue {
            dialogue_draw(dialogue_message)
        }

        if should_show_inventory {
            rl.ClearBackground(rl.DARKGRAY)
            // draw outline
            rl.DrawRectangleLines(102, 30, 20, 20+48, rl.WHITE)

            // draw collected letters
            letter_src := rl.Rectangle { 144, 64, 16, 16 }
            switch letter_count {
            case 3:
                rl.DrawTexturePro(tileset, letter_src, { 104, 32+32, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                rl.DrawTextEx(big_font, "0", { 124, 32+32 }, 16, big_font_spacing, rl.WHITE)
                fallthrough
            case 2:
                rl.DrawTexturePro(tileset, letter_src, { 104, 32+16, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                rl.DrawTextEx(big_font, "9", { 124, 32+16 }, 16, big_font_spacing, rl.WHITE)
                fallthrough
            case 1:
                rl.DrawTexturePro(tileset, letter_src, { 104, 32, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
                rl.DrawTextEx(big_font, "1", { 124, 32 }, 16, big_font_spacing, rl.WHITE)
            }

            // draw map when collected
            if has_map {
                map_src := rl.Rectangle { 128, 64, 16, 16 }
                rl.DrawTexturePro(tileset, map_src, { 104, 32+48, 16, 16 }, { 0, 0 }, 0, rl.WHITE)
            }

            text_inventory_center_x := center_text_x(0, 224, "Inventory")
            rl.DrawTextEx(big_font, "Inventory", { text_inventory_center_x, 12 }, 16, big_font_spacing, rl.WHITE)
        }
        if should_show_map {
            rl.ClearBackground({ 78, 25, 19, 255 })
            poe_soul_src := rl.Rectangle { 112, 96, 16, 16 }
            rl.DrawTexture(game_map_texture, 0, 0, rl.WHITE)
            rl.DrawTexturePro(tileset, poe_soul_src, { current_room.map_pos.x, current_room.map_pos.y, 16, 16 }, 0, 0, rl.WHITE)

            current_room_name_space, _ := strings.replace(current_room.name, "_", " ", 1, context.temp_allocator)
            room_name_cstring := temp_cstring(current_room_name_space)
            center_x_pos := center_text_x(49, 124, room_name_cstring)
            rl.DrawTextEx(big_font, room_name_cstring, { center_x_pos, 12 }, 16, big_font_spacing, { 177, 62, 83, 255 })
        }
    }

    if room_transition_timer1.started || room_transition_timer2.started || room_transition_timer_mid.started {
        rl.DrawRectangleRec({ 0, 0, 224, 144 }, transition_color)
    }

    if should_close_window {
        rl.DrawRectangle(0, 55, i32(screen_width), 50, rl.BLACK)
        rl.DrawText("Are you sure you want to quit? [Y/N]", 10, 75, 3, rl.WHITE)
    }

    rl.EndTextureMode()


    // draw render texture
    rl.BeginDrawing()

    if should_use_shader {
        rl.BeginShaderMode(shader)
    }
    rl.ClearBackground(rl.BLACK)
    rl.DrawTexturePro(
        target.texture,
        { 0, 0, f32(target.texture.width), -1 * f32(target.texture.height) },
        { (screen_width - f32(game_screen_width)*scale)*0.5, (screen_height - f32(game_screen_height)*scale)*0.5, f32(game_screen_width)*scale, f32(game_screen_height)*scale },
        { 0, 0 },
        0,
        rl.WHITE,
    )
    if should_use_shader {
        rl.EndShaderMode()
    }

    rl.EndDrawing()
}
