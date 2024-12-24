/**
  * Modified version of Karl Zylinski's 
  * code from his game CAT & ONION
  */

package game

EmbedAssets :: #config(EmbedAssets, false)

Asset :: struct {
	path: string,
	path_hash: Hash,
	data: []u8,
}

TextureName :: enum {
	None,
	LinkawakeDown,
	LinkawakeRight,
	LinkawakeUp,
	MapFullscreen,
	Outside,
	TokenPixel,
	Worldtiles,
}

FontName :: enum {
	Alagard,
	AlphaBeta,
	JupiterCrash,
	LinkawakeFont,
	Pixantiqua,
	Romulus,
}

ShaderName :: enum {
	Scan,
}

SoundName :: enum {
	None,
	BewareIlive,
	Correctsound,
	Dimensional,
	Flowey,
	GoldToken,
	Linkscream1,
	Linkscream2,
	OotGameOver,
	RunRawr,
	SpiritGemGet,
	Teleport,
	TpGameOver,
	TwilitIntro,
	Typing,
	Witchlaugh,
}

MusicName :: enum {
	None,
	Balcony,
	DarkMemories,
	DeepInside,
	Guardian,
	Lavender,
	MiniBoss,
	RainThemeZenonia,
	Snowpeak,
	ToTheMoon,
	Twilight,
	Wind,
	Zant,
	Zenonia2OstIntro,
}

LevelName :: enum {
	None,
	NewWorldLinksAwakening,
}

when EmbedAssets {
	all_textures := [TextureName]Asset {
		.None = {},
		.LinkawakeDown = { path = "Resources/linkawake_down.png", path_hash = 5998310469512246177, data = #load("Resources/linkawake_down.png"), },
		.LinkawakeRight = { path = "Resources/linkawake_right.png", path_hash = 10051395881644501912, data = #load("Resources/linkawake_right.png"), },
		.LinkawakeUp = { path = "Resources/linkawake_up.png", path_hash = 8359747071007954019, data = #load("Resources/linkawake_up.png"), },
		.MapFullscreen = { path = "Resources/map_fullscreen.png", path_hash = 3040213852536129386, data = #load("Resources/map_fullscreen.png"), },
		.Outside = { path = "Resources/outside.png", path_hash = 3030335820279099491, data = #load("Resources/outside.png"), },
		.TokenPixel = { path = "Resources/tokenPixel.png", path_hash = 3604820715501305518, data = #load("Resources/tokenPixel.png"), },
		.Worldtiles = { path = "Resources/worldtiles.png", path_hash = 2799477347926799472, data = #load("Resources/worldtiles.png"), },
	}

	all_levels := [LevelName]Asset {
        .None = {},
		.NewWorldLinksAwakening = { path = "Resources/new world links awakening.ldtk", path_hash = 5146425515100403890, data = #load("Resources/new world links awakening.ldtk"), },
	}

	all_fonts := [FontName]Asset {
		.Alagard = { path = "Resources/Fonts/alagard.png", path_hash = 3577428666942599184, data = #load("Resources/Fonts/alagard.png"), },
		.AlphaBeta = { path = "Resources/Fonts/alpha_beta.png", path_hash = 9483986953738940398, data = #load("Resources/Fonts/alpha_beta.png"), },
		.JupiterCrash = { path = "Resources/Fonts/jupiter_crash.png", path_hash = 4961520280109985713, data = #load("Resources/Fonts/jupiter_crash.png"), },
		.LinkawakeFont = { path = "Resources/Fonts/linkawake_font.png", path_hash = 4305415353237609051, data = #load("Resources/Fonts/linkawake_font.png"), },
		.Pixantiqua = { path = "Resources/Fonts/pixantiqua.png", path_hash = 4716181473603516022, data = #load("Resources/Fonts/pixantiqua.png"), },
		.Romulus = { path = "Resources/Fonts/romulus.png", path_hash = 16264941741341411912, data = #load("Resources/Fonts/romulus.png"), },
	}

	all_shaders := [ShaderName]Asset {
		.Scan = { path = "scan.frag", path_hash = 348444704196689931, data = #load("scan.frag"), },
	}

	all_sounds := [SoundName]Asset {
		.None = {},
		.BewareIlive = { path = "Resources/Audio/Sound/BewareILive.wav", path_hash = 4285910113726599412, data = #load("Resources/Audio/Sound/BewareILive.wav"), },
		.Correctsound = { path = "Resources/Audio/Sound/correctsound.wav", path_hash = 12465089702773934307, data = #load("Resources/Audio/Sound/correctsound.wav"), },
		.Dimensional = { path = "Resources/Audio/Sound/dimensional.wav", path_hash = 9948922060440077684, data = #load("Resources/Audio/Sound/dimensional.wav"), },
		.Flowey = { path = "Resources/Audio/Sound/flowey.wav", path_hash = 12704312697994334057, data = #load("Resources/Audio/Sound/flowey.wav"), },
		.GoldToken = { path = "Resources/Audio/Sound/goldToken.wav", path_hash = 7893306161553158064, data = #load("Resources/Audio/Sound/goldToken.wav"), },
		.Linkscream1 = { path = "Resources/Audio/Sound/linkscream1.wav", path_hash = 714568376086436511, data = #load("Resources/Audio/Sound/linkscream1.wav"), },
		.Linkscream2 = { path = "Resources/Audio/Sound/linkscream2.wav", path_hash = 4693091334396221717, data = #load("Resources/Audio/Sound/linkscream2.wav"), },
		.OotGameOver = { path = "Resources/Audio/Sound/ootGameOver.wav", path_hash = 7282063886736622620, data = #load("Resources/Audio/Sound/ootGameOver.wav"), },
		.RunRawr = { path = "Resources/Audio/Sound/runRAWR.wav", path_hash = 10811773043886353567, data = #load("Resources/Audio/Sound/runRAWR.wav"), },
		.SpiritGemGet = { path = "Resources/Audio/Sound/Spirit-Gem-Get.wav", path_hash = 16421068839298402149, data = #load("Resources/Audio/Sound/Spirit-Gem-Get.wav"), },
		.Teleport = { path = "Resources/Audio/Sound/teleport.wav", path_hash = 4504422985868762672, data = #load("Resources/Audio/Sound/teleport.wav"), },
		.TpGameOver = { path = "Resources/Audio/Sound/tpGameOver.wav", path_hash = 3241778512136449956, data = #load("Resources/Audio/Sound/tpGameOver.wav"), },
		.TwilitIntro = { path = "Resources/Audio/Sound/twilit intro.wav", path_hash = 5783315416060946959, data = #load("Resources/Audio/Sound/twilit intro.wav"), },
		.Typing = { path = "Resources/Audio/Sound/typing.wav", path_hash = 3535095085475391568, data = #load("Resources/Audio/Sound/typing.wav"), },
		.Witchlaugh = { path = "Resources/Audio/Sound/witchlaugh.wav", path_hash = 16927280144950129712, data = #load("Resources/Audio/Sound/witchlaugh.wav"), },
	}

	all_music := [MusicName]Asset {
		.None = {},
		.Balcony = { path = "Resources/Audio/Music/balcony.wav", path_hash = 13117608922489748191, data = #load("Resources/Audio/Music/balcony.wav"), },
		.DarkMemories = { path = "Resources/Audio/Music/darkMemories.wav", path_hash = 17034507748678860428, data = #load("Resources/Audio/Music/darkMemories.wav"), },
		.DeepInside = { path = "Resources/Audio/Music/deep inside.wav", path_hash = 1756722634904914818, data = #load("Resources/Audio/Music/deep inside.wav"), },
		.Guardian = { path = "Resources/Audio/Music/guardian.wav", path_hash = 1260365230630110880, data = #load("Resources/Audio/Music/guardian.wav"), },
		.Lavender = { path = "Resources/Audio/Music/lavender.wav", path_hash = 14687954813453583397, data = #load("Resources/Audio/Music/lavender.wav"), },
		.MiniBoss = { path = "Resources/Audio/Music/miniBoss.wav", path_hash = 7291417310473450487, data = #load("Resources/Audio/Music/miniBoss.wav"), },
		.RainThemeZenonia = { path = "Resources/Audio/Music/Rain-Theme-Zenonia.wav", path_hash = 5942206228461756250, data = #load("Resources/Audio/Music/Rain-Theme-Zenonia.wav"), },
		.Snowpeak = { path = "Resources/Audio/Music/snowpeak.wav", path_hash = 7153647502628447777, data = #load("Resources/Audio/Music/snowpeak.wav"), },
		.ToTheMoon = { path = "Resources/Audio/Music/to the moon.wav", path_hash = 3103844086315120193, data = #load("Resources/Audio/Music/to the moon.wav"), },
		.Twilight = { path = "Resources/Audio/Music/twilight.wav", path_hash = 7005714352686968768, data = #load("Resources/Audio/Music/twilight.wav"), },
		.Wind = { path = "Resources/Audio/Music/wind.wav", path_hash = 11790012607772919476, data = #load("Resources/Audio/Music/wind.wav"), },
		.Zant = { path = "Resources/Audio/Music/zant.wav", path_hash = 16254755997813894078, data = #load("Resources/Audio/Music/zant.wav"), },
		.Zenonia2OstIntro = { path = "Resources/Audio/Music/zenonia-2-OST-Intro.wav", path_hash = 12531080669833241093, data = #load("Resources/Audio/Music/zenonia-2-OST-Intro.wav"), },
	}

} else {
	all_textures := [TextureName]Asset {
		.None = {},
		.LinkawakeDown = { path = "Resources/linkawake_down.png", path_hash = 5998310469512246177, },
		.LinkawakeRight = { path = "Resources/linkawake_right.png", path_hash = 10051395881644501912, },
		.LinkawakeUp = { path = "Resources/linkawake_up.png", path_hash = 8359747071007954019, },
		.MapFullscreen = { path = "Resources/map_fullscreen.png", path_hash = 3040213852536129386, },
		.Outside = { path = "Resources/outside.png", path_hash = 3030335820279099491, },
		.TokenPixel = { path = "Resources/tokenPixel.png", path_hash = 3604820715501305518, },
		.Worldtiles = { path = "Resources/worldtiles.png", path_hash = 2799477347926799472, },
	}

	all_levels := [LevelName]Asset {
        .None = {},
		.NewWorldLinksAwakening = { path = "Resources/new world links awakening.ldtk", path_hash = 5146425515100403890, },
	}

	all_fonts := [FontName]Asset {
		.Alagard = { path = "Resources/Fonts/alagard.png", path_hash = 3577428666942599184, },
		.AlphaBeta = { path = "Resources/Fonts/alpha_beta.png", path_hash = 9483986953738940398, },
		.JupiterCrash = { path = "Resources/Fonts/jupiter_crash.png", path_hash = 4961520280109985713, },
		.LinkawakeFont = { path = "Resources/Fonts/linkawake_font.png", path_hash = 4305415353237609051, },
		.Pixantiqua = { path = "Resources/Fonts/pixantiqua.png", path_hash = 4716181473603516022, },
		.Romulus = { path = "Resources/Fonts/romulus.png", path_hash = 16264941741341411912, },
	}

	all_shaders := [ShaderName]Asset {
		.Scan = { path = "scan.frag", path_hash = 348444704196689931, },
	}

	all_sounds := [SoundName]Asset {
		.None = {},
		.BewareIlive = { path = "Resources/Audio/Sound/BewareILive.wav", path_hash = 4285910113726599412, },
		.Correctsound = { path = "Resources/Audio/Sound/correctsound.wav", path_hash = 12465089702773934307, },
		.Dimensional = { path = "Resources/Audio/Sound/dimensional.wav", path_hash = 9948922060440077684, },
		.Flowey = { path = "Resources/Audio/Sound/flowey.wav", path_hash = 12704312697994334057, },
		.GoldToken = { path = "Resources/Audio/Sound/goldToken.wav", path_hash = 7893306161553158064, },
		.Linkscream1 = { path = "Resources/Audio/Sound/linkscream1.wav", path_hash = 714568376086436511, },
		.Linkscream2 = { path = "Resources/Audio/Sound/linkscream2.wav", path_hash = 4693091334396221717, },
		.OotGameOver = { path = "Resources/Audio/Sound/ootGameOver.wav", path_hash = 7282063886736622620, },
		.RunRawr = { path = "Resources/Audio/Sound/runRAWR.wav", path_hash = 10811773043886353567, },
		.SpiritGemGet = { path = "Resources/Audio/Sound/Spirit-Gem-Get.wav", path_hash = 16421068839298402149, },
		.Teleport = { path = "Resources/Audio/Sound/teleport.wav", path_hash = 4504422985868762672, },
		.TpGameOver = { path = "Resources/Audio/Sound/tpGameOver.wav", path_hash = 3241778512136449956, },
		.TwilitIntro = { path = "Resources/Audio/Sound/twilit intro.wav", path_hash = 5783315416060946959, },
		.Typing = { path = "Resources/Audio/Sound/typing.wav", path_hash = 3535095085475391568, },
		.Witchlaugh = { path = "Resources/Audio/Sound/witchlaugh.wav", path_hash = 16927280144950129712, },
	}

	all_music := [MusicName]Asset {
		.None = {},
		.Balcony = { path = "Resources/Audio/Music/balcony.wav", path_hash = 13117608922489748191, },
		.DarkMemories = { path = "Resources/Audio/Music/darkMemories.wav", path_hash = 17034507748678860428, },
		.DeepInside = { path = "Resources/Audio/Music/deep inside.wav", path_hash = 1756722634904914818, },
		.Guardian = { path = "Resources/Audio/Music/guardian.wav", path_hash = 1260365230630110880, },
		.Lavender = { path = "Resources/Audio/Music/lavender.wav", path_hash = 14687954813453583397, },
		.MiniBoss = { path = "Resources/Audio/Music/miniBoss.wav", path_hash = 7291417310473450487, },
		.RainThemeZenonia = { path = "Resources/Audio/Music/Rain-Theme-Zenonia.wav", path_hash = 5942206228461756250, },
		.Snowpeak = { path = "Resources/Audio/Music/snowpeak.wav", path_hash = 7153647502628447777, },
		.ToTheMoon = { path = "Resources/Audio/Music/to the moon.wav", path_hash = 3103844086315120193, },
		.Twilight = { path = "Resources/Audio/Music/twilight.wav", path_hash = 7005714352686968768, },
		.Wind = { path = "Resources/Audio/Music/wind.wav", path_hash = 11790012607772919476, },
		.Zant = { path = "Resources/Audio/Music/zant.wav", path_hash = 16254755997813894078, },
		.Zenonia2OstIntro = { path = "Resources/Audio/Music/zenonia-2-OST-Intro.wav", path_hash = 12531080669833241093, },
	}

}
