state("Babbdi") {}

startup {
    // Load Unity handler
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Babbdi";
    vars.Helper.LoadSceneManager = true;

    // Setup achievement data
    vars.achievements = new[] {
        // Commenting out some achivements that have specific uses that shouldn't be turned off
        //      Internal Name       Display Name
      //new[] { "escapeBabbdi",     "Melancholic Departure" },
      //new[] { "gameUnder",        "Way of the Rusher" },
        new[] { "wayClimber",       "Way of the Climber" },
        new[] { "trainDeath",       "Flat Face" },
        new[] { "allSecrets",       "Secrets Master" },
        new[] { "interactEveryone", "Social Quest" },
        new[] { "playDog",          "Doggo Friendly" },
        new[] { "impressGirl",      "Way of the Seducer" },
        new[] { "bikeAir",          "Way of the Biker" },
        new[] { "ticket",           "Babbdi Quest" },
    };

    // Setup tool data
    vars.tools = new[] {
        // WIP, elements without a display name haven't been verified to be attached to an ingame object yet
        //      Internal Name   Display Name
        new[] { "club",         "Bat" },
        new[] { "climber",      "Pickaxe" },
        new[] { "propeller",    "Propeller" },
        new[] { "blower",       "Leafblower" },
        new[] { "flashlight",   "Flashlight" },
        new[] { "soap"          },
        new[] { "ball",         "Football" },
        new[] { "bigball",      "Ball" },
        new[] { "stick"         },
        new[] { "grabber"       },
        new[] { "motorBike",    "Motorbike" },
        new[] { "compass"       },
        new[] { "trumpet",      "Trumpet" },
        new[] { "secretfinder", "Secret Finder" }
    };

    // Settings
    settings.Add("train", true, "Train Exit Splitting");
    settings.SetToolTip("train", "Split when boarding the train to leave Babbdi");

    settings.Add("menu", false, "Quit to Menu Splitting");
    settings.SetToolTip("menu", "Split when quitting to menu");

    settings.Add("secrets", true, "Secret Item Splitting");
    settings.SetToolTip("secrets", "Split on picking up a secret item");

    settings.Add("npcs", true, "NPC Splitting");
    settings.SetToolTip("npcs", "Split when speaking to an NPC for the first time");

    settings.Add("achievements", true, "Achievement Splitting");
    settings.SetToolTip("achievements", "Split on gaining achivements");

    foreach(var achievement in vars.achievements) {
        settings.Add(achievement[0], true, achievement[1], "achievements");
        settings.SetToolTip(achievement[0], "Toggle splitting when the achivement \"" + achievement[1] + "\" is gained.");
    }
}

init {
    // Initialize scene tracker
    vars.scene = "";
    vars.scene_old = "";

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        var gameManager = mono["GameManager"];
        //var playerController = mono["FirstPersonController"];

        // IGT
        vars.Helper["gameTime"] = gameManager.Make<float>("Instance", "gameTime");

        // Counters
        vars.Helper["secretsFound"] = gameManager.Make<int>("Instance", "secretsFound");
        vars.Helper["npcInteractedWith"] = gameManager.Make<int>("Instance", "npcInteractedWith");

        // Achievements
        vars.Helper["wayClimber"] = gameManager.Make<bool>("Instance", "wayClimber");
        vars.Helper["trainDeath"] = gameManager.Make<bool>("Instance", "trainDeath");
        vars.Helper["allSecrets"] = gameManager.Make<bool>("Instance", "allSecrets");
        vars.Helper["interactEveryone"] = gameManager.Make<bool>("Instance", "interactEveryone");
        vars.Helper["playDog"] = gameManager.Make<bool>("Instance", "playDog");
        vars.Helper["gameUnder"] = gameManager.Make<bool>("Instance", "gameUnder");
        vars.Helper["impressGirl"] = gameManager.Make<bool>("Instance", "impressGirl");
        vars.Helper["bikeAir"] = gameManager.Make<bool>("Instance", "bikeAir");
        vars.Helper["escapeBabbdi"] = gameManager.Make<bool>("Instance", "escapeBabbdi");
        vars.Helper["ticket"] = gameManager.Make<bool>("Instance", "ticket");

        // Tools
        vars.Helper["club"] = gameManager.Make<bool>("Instance", "club");
        vars.Helper["climber"] = gameManager.Make<bool>("Instance", "climber");
        vars.Helper["propeller"] = gameManager.Make<bool>("Instance", "propeller");
        vars.Helper["blower"] = gameManager.Make<bool>("Instance", "blower");
        vars.Helper["flashlight"] = gameManager.Make<bool>("Instance", "flashlight");
        vars.Helper["soap"] = gameManager.Make<bool>("Instance", "soap");
        vars.Helper["ball"] = gameManager.Make<bool>("Instance", "ball");
        vars.Helper["bigball"] = gameManager.Make<bool>("Instance", "bigball");
        vars.Helper["stick"] = gameManager.Make<bool>("Instance", "stick");
        vars.Helper["grabber"] = gameManager.Make<bool>("Instance", "grabber");
        vars.Helper["motorBike"] = gameManager.Make<bool>("Instance", "motorBike");
        vars.Helper["compass"] = gameManager.Make<bool>("Instance", "compass");
        vars.Helper["trumpet"] = gameManager.Make<bool>("Instance", "trumpet");
        vars.Helper["secretfinder"] = gameManager.Make<bool>("Instance", "secretfinder");

        // Player Data
        // Useful player functions for locational splitting, idk what I'm doing tho so this doesn't work currently
        //vars.Helper["playerX"] = playerController.Make<float>("instance", "player", "transform", "position", "x");
        //vars.Helper["playerY"] = playerController.Make<float>("instance", "player", "transform", "position", "y");
        //vars.Helper["playerZ"] = playerController.Make<float>("instance", "player", "transform", "position", "z");
        //vars.Helper["playerGround"] = playerController.Make<bool>("instance", "player", "characterController", "isGrounded");

        return true;
    });

}

update {
    // Update scene tracking
    // This really should be using the built-in livesplit system but Livesplit gets mad when I do
    // Need to investigate what's wrong and how to get around it
    vars.scene_old = vars.scene;
    vars.scene = vars.Helper.Scenes.Active.Name;
}

start {
    // This will be innacurate when the game first launches, as the game manager doesn't load in until the map is actually loaded for the fist time.
    // Realistically all this will do is fail to start the timer, so it may not be the worst thing in the world?
    return (vars.scene == "Scene_AAA" && vars.scene_old != "Scene_AAA" && current.gameTime == 0);
}

reset {
    return current.gameTime < old.gameTime;
}

split {
    if(settings["train"] && !old.escapeBabbdi && current.escapeBabbdi) {
        return true;
    }

    if(settings["menu"] && vars.scene != "Scene_AAA" && vars.scene_old == "Scene_AAA") {
        return true;
    }

    if(settings["secrets"] && old.secretsFound < current.secretsFound) {
        return true;
    }

    if(settings["npcs"] && old.npcInteractedWith < current.npcInteractedWith) {
        return true;
    }

    if(settings["achievements"]) {
        foreach(var achievement in vars.achievements) {
            if(settings[achievement[0]] && !vars.Helper[achievement[0]].Old && vars.Helper[achievement[0]].Current) {
                return true;
            }
        }
    }

    return false;
}

isLoading {
    return true;
}

gameTime {
    return TimeSpan.FromSeconds(current.gameTime);
}