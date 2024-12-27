package game

import rl "vendor:raylib"
import "core:fmt"
import "core:unicode/utf8"

max_values := u8(1)
letterCount := u8(0)
framesCounter := 0

nopers: []rune
has_made_nopers: bool
input: cstring
message: cstring

backspace :: proc() {
    letterCount -= 1
    if letterCount < 0 {
        letterCount = 0
    } else if letterCount > max_values {
        letterCount = max_values - 1
    }
    nopers[letterCount] = '_'
}

inputbox_show :: proc(message_to_show: cstring, max_chars: u8) {
    message = message_to_show
    max_values = max_chars
    if !has_made_nopers {
        nopers = make([]rune, max_chars)
        has_made_nopers = true
        letterCount = max_values
        for i := u8(0); i < max_values; i += 1 {
            backspace()
        }
    }

    charr := rl.GetCharPressed()
    for charr > 0 {
        if charr >= 48 && charr <= 57 && letterCount < max_values {
            nopers[letterCount] = charr
            letterCount += 1
        }
        charr = rl.GetCharPressed()
    }

    if rl.IsKeyPressed(.BACKSPACE) {
        backspace()
    }
    framesCounter += 1

    nopers_string := utf8.runes_to_string(nopers[:], context.temp_allocator)
    input = temp_cstring(nopers_string)
}

inputbox_process :: proc(door: ^Door, correct_answer: cstring, current_music: rl.Music) {
    has_made_nopers = false
    delete(nopers)
    if input == correct_answer {
        rl.PlaySound(sound_correct)
        if correct_answer == "3" {
            dialogue_set_message("* Correct")
            door.src = { 160, 0, 16, 16 }
        } else {
            dialogue_set_message("* You may enter")
        }
        door := door
        door.locked_with = ""
    } else {
        if correct_answer == "3" {
            rl.PlaySound(sound_run_roar)
            timer_start(&timer_soundfx, 4)
            reason_death = "Learn how to count"
        } else {
            link_death()
            reason_death = "Better luck next time"
        }
        game_over(current_music)
    }
    input = ""
}

inputbox_draw :: proc() {
    dialogue_draw_input(input, message)

    // blinking
//   if letterCount < max_values {
//       if (framesCounter / 20) % 2 == 0 {
//           rl.DrawText("|", i32(text_box.x) + 4 + rl.MeasureText(input, 4), i32(text_box.y) + 4, 4, rl.WHITE)
//       }
//   } else {
    if letterCount >= max_values {
        if (framesCounter / 20) % 2 == 0 {
            rl.DrawText("|", i32(text_box.x) + 74 + rl.MeasureText(input, 4), i32(text_box.y) + 16, 4, rl.RED)
        }
    }
}
