/**
  * Modified version of Karl Zylinski's
  * code from his game CAT & ONION
  */

package game

EmbedAssets :: #config(EmbedAssets, false)

Asset :: struct {
    path: string,
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
    Acerola,
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
        .LinkawakeDown = { path = "Resources/linkawake_down.png", data = #load("Resources/linkawake_down.png"), },
        .LinkawakeRight = { path = "Resources/linkawake_right.png", data = #load("Resources/linkawake_right.png"), },
        .LinkawakeUp = { path = "Resources/linkawake_up.png", data = #load("Resources/linkawake_up.png"), },
        .MapFullscreen = { path = "Resources/map_fullscreen.png", data = #load("Resources/map_fullscreen.png"), },
        .Outside = { path = "Resources/outside.png", data = #load("Resources/outside.png"), },
        .TokenPixel = { path = "Resources/tokenPixel.png", data = #load("Resources/tokenPixel.png"), },
        .Worldtiles = { path = "Resources/worldtiles.png", data = #load("Resources/worldtiles.png"), },
    }

    all_levels := [LevelName]Asset {
        .None = {},
        .NewWorldLinksAwakening = { path = "Resources/new world links awakening.ldtk", data = #load("Resources/new world links awakening.ldtk"), },
    }

    all_fonts := [FontName]Asset {
        .Alagard = { path = "Resources/Fonts/alagard.png", data = #load("Resources/Fonts/alagard.png"), },
        .AlphaBeta = { path = "Resources/Fonts/alpha_beta.png", data = #load("Resources/Fonts/alpha_beta.png"), },
        .JupiterCrash = { path = "Resources/Fonts/jupiter_crash.png", data = #load("Resources/Fonts/jupiter_crash.png"), },
        .LinkawakeFont = { path = "Resources/Fonts/linkawake_font.png", data = #load("Resources/Fonts/linkawake_font.png"), },
        .Pixantiqua = { path = "Resources/Fonts/pixantiqua.png", data = #load("Resources/Fonts/pixantiqua.png"), },
        .Romulus = { path = "Resources/Fonts/romulus.png", data = #load("Resources/Fonts/romulus.png"), },
    }

    all_shaders := [ShaderName]Asset {
        .Acerola = { path = "acerola.frag", data = #load("acerola.frag"), },
    }

    all_sounds := [SoundName]Asset {
        .None = {},
        .BewareIlive = { path = "Resources/Audio/Sound/BewareILive.wav", data = #load("Resources/Audio/Sound/BewareILive.wav"), },
        .Correctsound = { path = "Resources/Audio/Sound/correctsound.wav", data = #load("Resources/Audio/Sound/correctsound.wav"), },
        .Dimensional = { path = "Resources/Audio/Sound/dimensional.wav", data = #load("Resources/Audio/Sound/dimensional.wav"), },
        .Flowey = { path = "Resources/Audio/Sound/flowey.wav", data = #load("Resources/Audio/Sound/flowey.wav"), },
        .GoldToken = { path = "Resources/Audio/Sound/goldToken.wav", data = #load("Resources/Audio/Sound/goldToken.wav"), },
        .Linkscream1 = { path = "Resources/Audio/Sound/linkscream1.wav", data = #load("Resources/Audio/Sound/linkscream1.wav"), },
        .Linkscream2 = { path = "Resources/Audio/Sound/linkscream2.wav", data = #load("Resources/Audio/Sound/linkscream2.wav"), },
        .OotGameOver = { path = "Resources/Audio/Sound/ootGameOver.wav", data = #load("Resources/Audio/Sound/ootGameOver.wav"), },
        .RunRawr = { path = "Resources/Audio/Sound/runRAWR.wav", data = #load("Resources/Audio/Sound/runRAWR.wav"), },
        .SpiritGemGet = { path = "Resources/Audio/Sound/Spirit-Gem-Get.wav", data = #load("Resources/Audio/Sound/Spirit-Gem-Get.wav"), },
        .Teleport = { path = "Resources/Audio/Sound/teleport.wav", data = #load("Resources/Audio/Sound/teleport.wav"), },
        .TpGameOver = { path = "Resources/Audio/Sound/tpGameOver.wav", data = #load("Resources/Audio/Sound/tpGameOver.wav"), },
        .TwilitIntro = { path = "Resources/Audio/Sound/twilit intro.wav", data = #load("Resources/Audio/Sound/twilit intro.wav"), },
        .Typing = { path = "Resources/Audio/Sound/typing.wav", data = #load("Resources/Audio/Sound/typing.wav"), },
        .Witchlaugh = { path = "Resources/Audio/Sound/witchlaugh.wav", data = #load("Resources/Audio/Sound/witchlaugh.wav"), },
    }

    all_music := [MusicName]Asset {
        .None = {},
        .Balcony = { path = "Resources/Audio/Music/balcony.wav", data = #load("Resources/Audio/Music/balcony.wav"), },
        .DarkMemories = { path = "Resources/Audio/Music/darkMemories.wav", data = #load("Resources/Audio/Music/darkMemories.wav"), },
        .DeepInside = { path = "Resources/Audio/Music/deep inside.wav", data = #load("Resources/Audio/Music/deep inside.wav"), },
        .Guardian = { path = "Resources/Audio/Music/guardian.wav", data = #load("Resources/Audio/Music/guardian.wav"), },
        .Lavender = { path = "Resources/Audio/Music/lavender.wav", data = #load("Resources/Audio/Music/lavender.wav"), },
        .MiniBoss = { path = "Resources/Audio/Music/miniBoss.wav", data = #load("Resources/Audio/Music/miniBoss.wav"), },
        .RainThemeZenonia = { path = "Resources/Audio/Music/Rain-Theme-Zenonia.wav", data = #load("Resources/Audio/Music/Rain-Theme-Zenonia.wav"), },
        .Snowpeak = { path = "Resources/Audio/Music/snowpeak.wav", data = #load("Resources/Audio/Music/snowpeak.wav"), },
        .ToTheMoon = { path = "Resources/Audio/Music/to the moon.wav", data = #load("Resources/Audio/Music/to the moon.wav"), },
        .Twilight = { path = "Resources/Audio/Music/twilight.wav", data = #load("Resources/Audio/Music/twilight.wav"), },
        .Wind = { path = "Resources/Audio/Music/wind.wav", data = #load("Resources/Audio/Music/wind.wav"), },
        .Zant = { path = "Resources/Audio/Music/zant.wav", data = #load("Resources/Audio/Music/zant.wav"), },
        .Zenonia2OstIntro = { path = "Resources/Audio/Music/zenonia-2-OST-Intro.wav", data = #load("Resources/Audio/Music/zenonia-2-OST-Intro.wav"), },
    }

} else {
    all_textures := [TextureName]Asset {
        .None = {},
        .LinkawakeDown = { path = "Resources/linkawake_down.png", },
        .LinkawakeRight = { path = "Resources/linkawake_right.png", },
        .LinkawakeUp = { path = "Resources/linkawake_up.png", },
        .MapFullscreen = { path = "Resources/map_fullscreen.png", },
        .Outside = { path = "Resources/outside.png", },
        .TokenPixel = { path = "Resources/tokenPixel.png", },
        .Worldtiles = { path = "Resources/worldtiles.png", },
    }

    all_levels := [LevelName]Asset {
        .None = {},
        .NewWorldLinksAwakening = { path = "Resources/new world links awakening.ldtk", },
    }

    all_fonts := [FontName]Asset {
        .Alagard = { path = "Resources/Fonts/alagard.png", },
        .AlphaBeta = { path = "Resources/Fonts/alpha_beta.png", },
        .JupiterCrash = { path = "Resources/Fonts/jupiter_crash.png", },
        .LinkawakeFont = { path = "Resources/Fonts/linkawake_font.png", },
        .Pixantiqua = { path = "Resources/Fonts/pixantiqua.png", },
        .Romulus = { path = "Resources/Fonts/romulus.png", },
    }

    all_shaders := [ShaderName]Asset {
        .Acerola = { path = "acerola.frag", },
    }

    all_sounds := [SoundName]Asset {
        .None = {},
        .BewareIlive = { path = "Resources/Audio/Sound/BewareILive.wav", },
        .Correctsound = { path = "Resources/Audio/Sound/correctsound.wav", },
        .Dimensional = { path = "Resources/Audio/Sound/dimensional.wav", },
        .Flowey = { path = "Resources/Audio/Sound/flowey.wav", },
        .GoldToken = { path = "Resources/Audio/Sound/goldToken.wav", },
        .Linkscream1 = { path = "Resources/Audio/Sound/linkscream1.wav", },
        .Linkscream2 = { path = "Resources/Audio/Sound/linkscream2.wav", },
        .OotGameOver = { path = "Resources/Audio/Sound/ootGameOver.wav", },
        .RunRawr = { path = "Resources/Audio/Sound/runRAWR.wav", },
        .SpiritGemGet = { path = "Resources/Audio/Sound/Spirit-Gem-Get.wav", },
        .Teleport = { path = "Resources/Audio/Sound/teleport.wav", },
        .TpGameOver = { path = "Resources/Audio/Sound/tpGameOver.wav", },
        .TwilitIntro = { path = "Resources/Audio/Sound/twilit intro.wav", },
        .Typing = { path = "Resources/Audio/Sound/typing.wav", },
        .Witchlaugh = { path = "Resources/Audio/Sound/witchlaugh.wav", },
    }

    all_music := [MusicName]Asset {
        .None = {},
        .Balcony = { path = "Resources/Audio/Music/balcony.wav", },
        .DarkMemories = { path = "Resources/Audio/Music/darkMemories.wav", },
        .DeepInside = { path = "Resources/Audio/Music/deep inside.wav", },
        .Guardian = { path = "Resources/Audio/Music/guardian.wav", },
        .Lavender = { path = "Resources/Audio/Music/lavender.wav", },
        .MiniBoss = { path = "Resources/Audio/Music/miniBoss.wav", },
        .RainThemeZenonia = { path = "Resources/Audio/Music/Rain-Theme-Zenonia.wav", },
        .Snowpeak = { path = "Resources/Audio/Music/snowpeak.wav", },
        .ToTheMoon = { path = "Resources/Audio/Music/to the moon.wav", },
        .Twilight = { path = "Resources/Audio/Music/twilight.wav", },
        .Wind = { path = "Resources/Audio/Music/wind.wav", },
        .Zant = { path = "Resources/Audio/Music/zant.wav", },
        .Zenonia2OstIntro = { path = "Resources/Audio/Music/zenonia-2-OST-Intro.wav", },
    }

}
