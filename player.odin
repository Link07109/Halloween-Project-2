package game

import rl "vendor:raylib"

player_sanity := i32(300)
player_sanity_frame_timer: f32
player_pos := rl.Vector2 { 160, 120 }
player_vel: rl.Vector2
player_run_speed := f32(120)
player_grounded: bool
player_flip: bool
player_current_anim: Animation

player_feet_collider := rl.Rectangle {
    width = 8,
    height = 4,
}

player_run := Animation {
    num_frames = 4,
    frame_length = 0.1,
    name = .Run,
}
player_idle := Animation {
    num_frames = 2,
    frame_length = 0.5,
    name = .Idle,
}

player_load_animation_textures :: proc() {
    player_run.texture = rl.LoadTexture("cat_run.png")
    player_idle.texture = rl.LoadTexture("cat_idle.png")
    player_current_anim = player_idle
}

player_update_sanity :: proc() {
    player_sanity_frame_timer += rl.GetFrameTime()

    for player_sanity_frame_timer > 1 {
        player_sanity -= 1
        player_sanity_frame_timer -= 1

        if player_sanity <= 0 {
            // death()
            // play death sound
            // show game over screen
            // play game over music
        }
    }
}

player_movement :: proc() {
    if rl.IsKeyDown(Player_Move_Up) {
        player_vel.y = -player_run_speed
        if player_current_anim.name != .Run {
            player_current_anim = player_run
        }
    } else if rl.IsKeyDown(Player_Move_Down) {
        player_vel.y = player_run_speed
        if player_current_anim.name != .Run {
            player_current_anim = player_run
        }
    } else {
        player_vel.y = 0
    }

    if rl.IsKeyDown(Player_Move_Left) {
        player_vel.x = -player_run_speed
        player_flip = true
        if player_current_anim.name != .Run {
            player_current_anim = player_run
        }
    } else if rl.IsKeyDown(Player_Move_Right) {
        player_vel.x = player_run_speed
        player_flip = false
        if player_current_anim.name != .Run {
            player_current_anim = player_run
        }
    } else {
        player_vel.x = 0
    }

    if player_vel == { 0, 0 } {
        if player_current_anim.name != .Idle {
            player_current_anim = player_idle
        }
    }

    player_grounded = false
    player_pos += player_vel * rl.GetFrameTime()

    player_feet_collider.x = player_pos.x - 4
    player_feet_collider.y = player_pos.y - 4
}

player_platform_collision :: proc(platforms: [dynamic]rl.Vector2) {
    for platform in platforms {
        if rl.CheckCollisionRecs(player_feet_collider, platform_collider(platform)) && player_vel.y > 0 {
            player_vel.y = 0
            player_pos.y = platform.y
            player_grounded = true
        }
    }
}

player_draw :: proc() {
    // TODO: use player gif: https://www.raylib.com/examples/textures/loader.html?name=textures_gif_player
    draw_animation(player_current_anim, player_pos, player_flip)
}

player_draw_debug :: proc() {
    rl.DrawRectangleRec(player_feet_collider, { 0, 255, 0, 100 })
}

player_draw_sanity :: proc() {
    ui_y := i32(165)
    rl.DrawText("Sanity", 230, ui_y+3, 3, rl.WHITE)
    rl.DrawRectangle(265, ui_y+4, 50, 8, rl.BLACK)
    rl.DrawRectangle(265, ui_y+4, player_sanity/6, 8, rl.MAROON)
    rl.DrawRectangleLinesEx({ 265, f32(ui_y+4), 50, 8 }, 0.5, rl.LIGHTGRAY)
}
