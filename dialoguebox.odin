package game

import rl "vendor:raylib"

text_color := rl.WHITE

dialogue_set_message :: proc(dialogue_string: cstring) {
    dialogue_message = dialogue_string
    should_show_dialogue = true
}

dialogue_draw_rec :: proc() {
    rl.DrawRectangleRec(textBox, rl.BLACK) //{ 11, 10, 22, 255 }
    rl.DrawRectangleLines(i32(textBox.x), i32(textBox.y), i32(textBox.width), i32(textBox.height), text_color)
}

dialogue_draw :: proc(thing_to_say: cstring) {
    dialogue_draw_rec()
    rl.DrawTextEx(default_font, thing_to_say, { textBox.x + 4, textBox.y + 4 }, default_font_size, 1, text_color)
}

dialogue_draw_input :: proc(thing_to_say, other_thing:cstring) {
    dialogue_draw_rec()
    rl.DrawText(other_thing, 30, 70, 2, rl.WHITE)
    rl.DrawText(thing_to_say, i32(textBox.x) + 4, i32(textBox.y) + 4, 4, rl.WHITE)
}
