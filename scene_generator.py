#!/usr/bin/env python
import os


def make_scene(scene_struct):
    for i, scene in enumerate(scene_struct):
        scene_name = scene["scene_name"]
        background = scene["background"]
        audio_file = scene["audio_file"]
        song_name = scene.get("song_name", "")
        text_fade = scene.get("text_fade", 0.0)
        song_start_delay = scene.get("song_start_delay", 0.0)

        # Determine next_scene and previous_scene dynamically
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

        # Create the content of the .tscn file
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
        if text_fade:
            content += f"text_fade = {text_fade}\n"
        if song_start_delay:
            content += f"song_start_delay = {song_start_delay}\n"
        if next_scene:
            content += f'next_scene = "{next_scene}"\n'
        if previous_scene:
            content += f'previous_scene = "{previous_scene}"\n'

        # Write the content to a .tscn file
        filename = f"{scene_name}.tscn"
        with open(filename, "w") as f:
            f.write(content)

        print(f"Created {filename}")


def main():
    scenes = [
        {
            "scene_name": "v1s1",
            "background": "GFX/Vol1/vkquake0018.png",
            "song_name": "the bakery I work at",
            "audio_file": "Music/Vol1/02.06.2024. - helen triphop tune idk.wav",
        },
        {
            "scene_name": "v1s2",
            "background": "GFX/Vol1/vkquake0022.png",
            "song_name": "closing for tonight",
            "audio_file": "Music/Vol1/17.01.2024. - sample pack moment.wav",
        },
        {
            "scene_name": "v1s3",
            "background": "GFX/Vol1/vkquake0025.png",
            "song_name": "the street we played on",
            "audio_file": "Music/Vol1/25.03.2024. - epiano mello sth.wav",
        },
        {
            "scene_name": "v1s4",
            "background": "GFX/Vol1/vkquake0021.png",
            "song_name": "scary alley",
            "audio_file": "Music/Vol1/27.05.2024. - helen's outro.wav",
        },
        {
            "scene_name": "v1s5",
            "background": "GFX/Vol1/vkquake0026.png",
            "song_name": "neighbourhood dogs",
            "audio_file": "Music/Vol1/17.03.2024. - elab guitar something.wav",
        },
        {
            "scene_name": "v1s6",
            "background": "GFX/Vol1/vkquake0019.png",
            "song_name": "park next to my appartment",
            "audio_file": "Music/Vol1/18.01.2024. - soft piano strings sample.wav",
        },
        {
            "scene_name": "v1s7",
            "background": "GFX/Vol1/vkquake0023.png",
            "song_name": "it's really nice here during the night",
            "audio_file": "Music/Vol1/25.03.2024. - chiefin that ambient.wav",
        },
        {
            "scene_name": "v1s8",
            "background": "GFX/Vol1/vkquake0024.png",
            "song_name": "but it feels a little bit too quiet",
            "audio_file": "Music/Vol1/16.05.2024. - helen's bedroom.wav",
        },
        {
            "scene_name": "v1s9",
            "background": "GFX/Vol1/vkquake0014.png",
            "song_name": "my empty appartment...",
            "audio_file": "Music/Vol1/27.05.2024. - helen's appartment.wav",
        },
        {
            "scene_name": "v1s10",
            "background": "GFX/Vol1/vkquake0017.png",
            "song_name": "it haven't felt like home in a while",
            "audio_file": "Music/Vol1/30.05.2024. - convolution reverbs are epic.wav",
        },
        {
            "scene_name": "v1s11",
            "background": "GFX/Vol1/vkquake0015.png",
            "song_name": "it's time for bed anyway",
            "audio_file": "Music/Vol1/19.05.2024. - bell-ish track.wav",
        },
        {
            "scene_name": "v1s12",
            "background": "GFX/Vol1/vkquake0028.png",
            "song_name": "but I'm scared of dreaming",
            "audio_file": "Music/Vol1/20.05.2024. - nightmares (backpedal).wav",
        },
    ]
    make_scene(scenes)


if __name__ == "__main__":
    main()
