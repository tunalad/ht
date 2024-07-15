# vim: set tabstop=4 shiftwidth=4 expandtab :
#!/usr/bin/env python
import os
import sys
import json


def make_scene(scene_struct):
    for i, scene in enumerate(scene_struct):
        scene_name = scene["scene_name"]
        background = scene["background"]
        is_ending = scene.get("is_ending", False)

        if is_ending:
            text = scene["text"]

            content = f"""
[gd_scene load_steps=3 format=3]

[ext_resource type="PackedScene" path="res://Scenes/Presets/Endscreen.tscn" id="1_a14d7"]
[ext_resource type="Texture2D" path="res://{background}" id="2_bi7ot"]

[node name="{scene_name}" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="Endscreen" parent="." instance=ExtResource("1_a14d7")]
layout_mode = 1
background = ExtResource("2_bi7ot")
text = "{text}"
"""
        else:
            audio_file = scene["audio_file"]
            song_name = scene.get("song_name", "")
            text_fade_in = scene.get("text_fade_in", 0.0)
            fade_out = scene.get("fade_out", 4.0)
            song_start_delay = scene.get("song_start_delay", 0.0)

            if i == 0:
                previous_scene = ""
                if len(scene_struct) > 1:
                    next_scene = scene_struct[i + 1]["scene_name"]
                else:
                    next_scene = ""
            elif i == len(scene_struct) - 1:
                next_scene = ""
                previous_scene = scene_struct[i - 1]["scene_name"]
            else:
                next_scene = scene_struct[i + 1]["scene_name"]
                previous_scene = scene_struct[i - 1]["scene_name"]

            content = f"""
[gd_scene load_steps=4 format=3]

[ext_resource type="PackedScene" path="res://Scenes/Presets/SongPlayer.tscn" id=1]
[ext_resource type="Texture2D" path="res://{background}" id=2]
[ext_resource type="AudioStream" path="res://{audio_file}" id=3]

[node name="{scene_name}" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="SongPlayer" parent="." instance=ExtResource(1)]
layout_mode = 1
game_background = ExtResource(2)
song_name = "{song_name}"
audio_file = ExtResource(3)
"""
            if text_fade_in:
                content += f"text_fade_in = {text_fade_in}\n"
            if song_start_delay:
                content += f"song_start_delay = {song_start_delay}\n"
            if next_scene:
                content += f'next_scene = "{next_scene}"\n'
            if previous_scene:
                content += f'previous_scene = "{previous_scene}"\n'
            if fade_out:
                content += f'fade_out = "{fade_out}"\n'

        # Write the content to a .tscn file
        filename = f"{scene_name}.tscn"
        with open(filename, "w") as f:
            f.write(content)

        print(f"Created {filename}")


def main():
    print(sys.argv)

    if len(sys.argv) != 2:
        print("Usage: scene_generator.py <json_file>")
        return

    input_path = sys.argv[1]

    if os.path.isfile(input_path):
        try:
            with open(input_path, "r") as f:
                scenes = json.load(f)
                make_scene(scenes)
        except FileNotFoundError:
            print("File not found.")


if __name__ == "__main__":
    main()
