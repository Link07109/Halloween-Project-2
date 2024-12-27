package game

import rl "vendor:raylib"

dialogue_text_color := rl.WHITE
text_box := rl.Rectangle { 20, 80, 184, 40 }

dialogue_set_message :: proc(dialogue_string: cstring) {
    dialogue_message = dialogue_string
    should_show_dialogue = true
}

dialogue_draw_rec :: proc() {
    rl.DrawRectangleRec(text_box, rl.BLACK) //{ 11, 10, 22, 255 }
    rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), dialogue_text_color)
}

dialogue_draw :: proc(thing_to_say: cstring) {
    dialogue_draw_rec()
    rl.DrawTextEx(default_font, thing_to_say, { text_box.x + 4, text_box.y + 4 }, default_font_size, 1, dialogue_text_color)
}

dialogue_draw_input :: proc(thing_to_say, other_thing:cstring) {
    rl.DrawRectangleRec({ 20, 64, 184, 16 }, rl.BLACK)
    rl.DrawRectangleLines(20, 64, 184, 16, rl.WHITE)

    other_thing_center_x := center_text_x(text_box.x, text_box.width, other_thing, default_font, default_font_size)
    rl.DrawTextEx(default_font, other_thing, { other_thing_center_x, 69 }, default_font_size, default_font_spacing, rl.WHITE)

    dialogue_draw_rec()
    rl.DrawText(thing_to_say, i32(text_box.x) + 74, i32(text_box.y) + 16, 4, rl.WHITE)
}
