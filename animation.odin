package game

import rl "vendor:raylib"

Animation_Name :: enum {
    RunUp,
    RunDown,
    RunRight
}

Animation :: struct {
    texture: rl.Texture2D,
    num_frames: int,
    frame_timer: f32,
    current_frame: int,
    frame_length : f32,
    name: Animation_Name,
}

update_animation :: proc(a: ^Animation) {
    a.frame_timer += rl.GetFrameTime()

    for a.frame_timer > a.frame_length {
        a.current_frame += 1
        a.frame_timer -= a.frame_length

        if a.current_frame == a.num_frames {
            a.current_frame = 0
        }
    }
}

draw_animation :: proc(a: Animation, pos: rl.Vector2, flip: bool) {
    width := f32(a.texture.width)
    height := f32(a.texture.height)

    source_width := width / f32(a.num_frames)

    // which frame in the animation to use
    source := rl.Rectangle {
        x = f32(a.current_frame) * source_width,
        y = 0,
        width = source_width,
        height = height,
    }

    if flip {
        source.width *= -1
    }

    // where on the screen to draw the frame
    dest := rl.Rectangle {
        x = pos.x,
        y = pos.y,
        width = source_width,
        height = height,
    }

    rl.DrawTexturePro(a.texture, source, dest, { dest.width/2, dest.height }, 0, rl.WHITE)
}
