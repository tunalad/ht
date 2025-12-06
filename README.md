# Helen's Tapes

This "game" is just an album visualizer really, so the whole project is pretty much just a fancy and pretty basic music player.

It can get it from [itch.io](tunalad.itch.io/helens-tapes), or [releases](https://github.com/tunalad/ht/releases) here on GitHub.

**do note that you won't be getting the whole game on GitHub, you'll still have to manually get the `.pck` files separately**

---

Scenes are generated based on the `volX.json` files, when we open the game. It is also possible to create your own volumes by creating your own `.pck` file! Instructions can be found on the itch.io page, by downloading the `Custom Volumes Instructions` PDF file.

Other thing that you might find interesting is the developer console (`DevConsole.tscn`). It is designed to be pretty simple and applicabe to any game (of course, you stll have to modify it with your own game's functionalities)

---

## License

### Code

Unless mentioned otherwise, all source code files (`.gd`, `.tscn`, `.tres`, `.gdshader`, and configuration files) are distributed under the [BSD 2-Clause License](LICENSE).

- Copyright (c) 2025 tunalad

### Assets

All game assets (graphics, music, sound effects, fonts, videos) located in the `GFX/`, `Music/`, and `SFX/` directories are **NOT** covered by the BSD 2-Clause License and remain under full copyright. These assets may not be used without explicit permission.

### Third-Party Code

- `Scenes/Shaders/crt.gdshader` - [CC0 License](https://creativecommons.org/publicdomain/zero/1.0/) (Public Domain)
    - From [Godot Shaders](https://godotshaders.com/shader/realistic-crt-shader/)
    - Optimized and packed by [c64cosmin](https://godotshaders.com/author/c64cosmin/)
    - See shader file header for full attribution
