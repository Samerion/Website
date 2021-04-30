/// Home for the website.
///
/// License:
///     Unlike other source files in the repository, this file is licensed under CC BY-SA 3.0. See license-content.txt.
module samerion.website.home;

import std.string;

import samerion.website.html;
import samerion.website.links;
import samerion.website.utils;
import samerion.website.presentation;

import elemi;

Page home = {

    title: null,
    layout: Layout.presentation,
    content: elems(

        mainSection(
            longLine(
                "Samerion is a planned fantasy MMORPG with an experimental approach to a classic game.",
            )
        ),

        section(
            "An open world for you to explore",
            longLine(
                "Samerion happens in world where you're free to go wherever you want to. It's planned to be big and to",
                "grow constantly with each update."
            ),

            link("Blog: The continent of Neasdal", "/blog/2021-04-14-map"),
            link("Blog: Races of Armitris", "/blog/2021-04-09-races"),
            elem!("p", q{ class="hint" })("More to come..."),
        ),

        section(
            "Quick-paced yet turn-based combat",
            longLine(
                "Here, you don't have to wait for other players to make a move. Turns consist of small, quick",
                "actions, forcing you to think quickly and plan your next moves before your turn."
            ),
            link("Blog: Combat", "/blog/2021-03-16-combat"),
        ),

        section(
            "Make your own...",
            longLine(
                "Character, story, potions, items, more! From the basics to the details, Samerion gives you lots of",
                "different small choices, making every single game unique."
            ),

            link("Blog: Character dialogue", "/blog/2021-01-13-dialogue"),
        ),

        section(
            "Join us",
            "While there's still a long way until the beta, Samerion is steadily developed and isn't planned to stop!",

            socialMedia,
        ),

    ),

};
