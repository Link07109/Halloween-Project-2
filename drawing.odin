package game

import rl "vendor:raylib"
import "core:fmt"

draw_phase :: proc(scale: f32, target: rl.RenderTexture, shader: rl.Shader, tileset, outside_texture, game_map_texture: rl.Texture) {
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
    rl.DrawTexturePro(
        target.texture,
        { 0, 0, f32(target.texture.width), -1 * f32(target.texture.height) },
        { screen_width - f32(game_screen_width)*scale, screen_height - f32(game_screen_height)*scale, f32(game_screen_width)*scale, f32(game_screen_height)*scale },
        { 0, 0 },
        0,
        rl.WHITE
    )
    rl.EndShaderMode()

    rl.EndDrawing()
}
