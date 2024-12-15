package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

player_sanity := i32(300)
player_sanity_frame_timer: f32
player_pos := rl.Vector2 { 112, 64 }
player_vel: rl.Vector2
player_run_speed := f32(65)
player_stop_animating,
up_down,
player_flip: bool
player_current_anim: Animation
player_facing := "down"

player_feet_collider := rl.Rectangle {
    width = 12,
    height = 8,
}

player_run_right := Animation {
    num_frames = 2,
    frame_length = 0.125,
    name = .RunRight,
}
player_run_up := Animation {
    num_frames = 2,
    frame_length = 0.125,
    name = .RunUp,
}
player_run_down := Animation {
    num_frames = 2,
    frame_length = 0.125,
    name = .RunDown,
}

player_load_animation_textures :: proc() {
    player_run_right.texture = rl.LoadTexture("Resources/linkawake_right.png")
    player_run_up.texture = rl.LoadTexture("Resources/linkawake_up.png")
    player_run_down.texture = rl.LoadTexture("Resources/linkawake_down.png")
    player_current_anim = player_run_down
}

player_update_sanity :: proc() {
    player_sanity_frame_timer += rl.GetFrameTime()

    for player_sanity_frame_timer > 1 {
        player_sanity -= 1
        player_sanity_frame_timer -= 1

        if player_sanity <= 0 {
            // death animation
            reason_death = "you committed suicide"
            link_death()
            game_over()
        }
    }
}

player_movement :: proc() {
    if rl.IsKeyDown(Player_Move_Up) {
        player_vel.y = -player_run_speed
        if player_current_anim.name != .RunUp {
            player_current_anim = player_run_up
            up_down = true
        }
    } else if rl.IsKeyDown(Player_Move_Down) {
        player_vel.y = player_run_speed
        if player_current_anim.name != .RunDown {
            player_current_anim = player_run_down
            up_down = true
        }
    } else {
        player_vel.y = 0
        up_down = false
    }

    if rl.IsKeyDown(Player_Move_Left) {
        player_vel.x = -player_run_speed
        player_flip = true
        if player_current_anim.name != .RunRight {
            if !up_down {
                player_current_anim = player_run_right
                player_facing = "left"
            }
        }
    } else if rl.IsKeyDown(Player_Move_Right) {
        player_vel.x = player_run_speed
        player_flip = false
        if player_current_anim.name != .RunRight {
            if !up_down {
                player_current_anim = player_run_right
                player_facing = "right"
            }
        }
    } else {
        player_vel.x = 0
    }

    if player_vel == { 0, 0 } {
        player_stop_animating = true
    } else {
        player_stop_animating = false
    }

    player_pos += player_vel * rl.GetFrameTime()

    player_feet_collider.x = player_pos.x - 6
    player_feet_collider.y = player_pos.y - 9
}

// Minkowski difference
player_wall_collision :: proc(coll: rl.Rectangle) {
    if rl.CheckCollisionRecs(player_feet_collider, coll) {
        //fmt.println("---- Collided with wall!")
        
        // Calculation of centers of rectangles
        center1: rl.Vector2 = { player_feet_collider.x + player_feet_collider.width / 2, player_feet_collider.y + player_feet_collider.height / 2 }
        center2: rl.Vector2 = { coll.x + coll.width / 2, coll.y + coll.height / 2 }

        // Calculation of the distance vector between the centers of the rectangles
        delta := center1 - center2

        // Calculation of half-widths and half-heights of rectangles
        hs1: rl.Vector2 = { player_feet_collider.width*0.5, player_feet_collider.height*0.5 }
        hs2: rl.Vector2 = { coll.width*0.5, coll.height*0.5 }

        // Calculation of the minimum distance at which the two rectangles can be separated
        min_dist_x := hs1.x + hs2.x - abs(delta.x)
        min_dist_y := hs1.y + hs2.y - abs(delta.y)

        // Adjusted object position based on minimum distance
        //fmt.printf("player coll before: %v\n", player_feet_collider)
        if (min_dist_x < min_dist_y) {
            player_pos.x += math.copy_sign(min_dist_x, delta.x)
            player_feet_collider.x += math.copy_sign(min_dist_x, delta.x)
        } else {
            player_pos.y += math.copy_sign(min_dist_y, delta.y)
            player_feet_collider.y += math.copy_sign(min_dist_y, delta.y)
        }
        //fmt.printf("player coll after: %v\n", player_feet_collider)
    }
}

player_collided_with :: proc(coll: rl.Rectangle) -> bool {
    return rl.CheckCollisionRecs(player_feet_collider, coll)
}

player_draw :: proc() {
    draw_animation(player_current_anim, player_pos, player_flip)
}

player_draw_debug :: proc() {
    rl.DrawRectangleRec(player_feet_collider, { 0, 255, 0, 100 })
}

player_draw_sanity :: proc() {
    ui_y := i32(128)
    rl.DrawTextEx(big_font, "Sanity", { 130, f32(ui_y) }, 16, 0, text_color)
    rl.DrawRectangle(180, ui_y+4, 40, 8, rl.BLACK)
    rl.DrawRectangle(180, ui_y+4, (player_sanity/15)*2, 8, rl.MAROON)
    rl.DrawRectangleLines(179, ui_y+3, 42, 10, text_color)
}
