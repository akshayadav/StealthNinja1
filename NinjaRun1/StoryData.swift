//
//  StoryData.swift
//  NinjaRun1
//
//  All story text for "The Great Dumpling Heist" narrative.
//

import Foundation

struct StoryLine {
    let portrait: String   // texture name for portrait (or "" for none)
    let name: String       // speaker name
    let text: String       // dialogue text
}

struct LevelStory {
    let recipePageTitle: String
    let introLines: [StoryLine]
    let outroLines: [StoryLine]
}

/// All story content for the 7-level campaign
struct StoryData {

    static let mochi = "mochi_portrait"   // ninja portrait
    static let tanuki = "tanuki_portrait" // tanuki portrait

    static let stories: [Int: LevelStory] = [
        1: LevelStory(
            recipePageTitle: "Page 1: The Flour",
            introLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "My neighbor's dog buried page one in this meadow... and the nosiest gardener in town is RIGHT THERE."),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "If she sees me in this ninja suit, she'll tell the WHOLE village. I must be sneaky..."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 1 recovered! 'The Flour'... Grandma always said use rice flour, never wheat."),
            ]
        ),
        2: LevelStory(
            recipePageTitle: "Page 2: The Filling",
            introLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "The guard dog here belongs to Granny Sato, the biggest gossip in the village!"),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "If that dog barks, Granny will hear, and by lunchtime EVERYONE will know I'm a ninja."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 2! 'The Filling' -- pork, cabbage, ginger, and a pinch of... wait, it's smudged!"),
            ]
        ),
        3: LevelStory(
            recipePageTitle: "Page 3: The Folding Technique",
            introLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "A kid is using my recipe page as a paper airplane! And the crossing guard is VERY strict."),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "He once gave ME a ticket for jaywalking. I was 45."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 3: 'The Folding Technique' -- 13 pleats, no more, no less. Classic Grandma."),
            ]
        ),
        4: LevelStory(
            recipePageTitle: "Page 4: The Secret Sauce",
            introLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "A fisherman is using my recipe page as a HAT. He's napping. This should be easy..."),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "...except every frog in this river seems to be watching me."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 4: 'The Secret Sauce' -- soy sauce, rice vinegar, and... is that a DOODLE of a cat?"),
            ]
        ),
        5: LevelStory(
            recipePageTitle: "Page 5: The Steaming Method",
            introLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "A merchant is selling my recipe as 'ancient calligraphy art' for 500 yen!"),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "I COULD just buy it... but I'm a ninja! Ninjas don't BUY things. We SNEAK."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 5: 'The Steaming Method' -- bamboo steamer, exactly 8 minutes. Not 7. Not 9."),
            ]
        ),
        6: LevelStory(
            recipePageTitle: "Page 6: The Dipping Sauce",
            introLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Tanuki's chef minion 'Chef Kappa' is using my page as a NAPKIN! At the festival!"),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "There are SO many witnesses here. One wrong move and I'm the village meme."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 6: 'The Dipping Sauce' -- chili oil with garlic. Grandma was ahead of her time."),
            ]
        ),
        7: LevelStory(
            recipePageTitle: "Page 7: Grandma's Love",
            introLines: [
                StoryLine(portrait: tanuki, name: "Tanuki",
                    text: "*snoring* ...mmmm... dumplings... I'm the BEST chef... zzz..."),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "There he is. Grand Master Tanuki. Using my last page as a BLANKET. This ends now."),
            ],
            outroLines: [
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "Page 7: 'Made with love -- Grandma Mochi.' ...I'm not crying, it's the onions."),
                StoryLine(portrait: mochi, name: "Mochi",
                    text: "ALL 7 PAGES RECOVERED! Time to win that Cook-Off! Tanuki, you're going DOWN!"),
            ]
        ),
    ]

    // Ending cutscene (after level 7 completion)
    static let endingLines: [StoryLine] = [
        StoryLine(portrait: mochi, name: "Narrator",
            text: "Mochi entered the Cook-Off with his complete recipe and WON. Again."),
        StoryLine(portrait: tanuki, name: "Tanuki",
            text: "*sobbing* They're so GOOD! How?! TEACH ME, MASTER MOCHI!"),
        StoryLine(portrait: mochi, name: "Mochi",
            text: "Fine. But you have to wear the dumpling mascot costume at my shop. FOREVER."),
        StoryLine(portrait: tanuki, name: "Tanuki",
            text: "...deal."),
    ]
}
