# Copyright (c) 2025 tunalad
# SPDX-License-Identifier: BSD-2-Clause
# See LICENSE file for details
extends Node

var sh_sounds := {
	"menu_move": load("res://SFX/sh/SH Menu Blip 01.mp3"),
	"menu_select": load("res://SFX/sh/SH Menu Blip 02.mp3"),
	"menu_locked": load("res://SFX/sh/SH Menu Blip 05.mp3"),
	"menu_back": load("res://SFX/sh/SH Menu Blip 03.mp3"),
	"menu_quit": load("res://SFX/sh/SH Menu Blip 04.mp3"),
	"notify": load("res://SFX/sh/SH Menu Blip 04.mp3"),
}

var homemade_sounds := {
	"menu_move": load("res://SFX/homemade/select_fr03.wav"),
	"menu_select": load("res://SFX/homemade/select02.wav"),
	"menu_locked": load("res://SFX/homemade/lock02.wav"),
	"menu_back": load("res://SFX/homemade/back02.wav"),
	"menu_quit": load("res://SFX/homemade/quit04.wav"),
	"notify": load("res://SFX/homemade/quit04.wav"),
}

enum InvKind { POCKET, BACKPACK, KEY }

enum InvItem { MUSIC_PLAYER, RECORDER, TAPE, TAPE_CASED, KEY_BAKERY, KEY_HOME, UMBRELLA, PHONE }

var resources := {
	InvItem.MUSIC_PLAYER: "res://Resources/InvMusicplayer.tres",
	InvItem.RECORDER: "res://Resources/InvRecorder.tres",
	InvItem.TAPE: "res://Resources/InvTape.tres",
	InvItem.TAPE_CASED: "res://Resources/InvTapeCased.tres",
	InvItem.UMBRELLA: "res://Resources/InvUmbrella.tres",
	InvItem.PHONE: "res://Resources/InvPhone.tres",
	InvItem.KEY_BAKERY: "res://Resources/KeyBakery.tres",
	InvItem.KEY_HOME: "res://Resources/KeyHome.tres"
}
