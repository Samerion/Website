module samerion.website.links;

import std.meta;
import elemi;

Element link(string text, string url) {

    return elem!"a"(
        ["href": url],
        text,
    );

}

alias socialMedia = AliasSeq!(

    link("Discord", "https://discord.gg/rfBZ5mX"),
    elem!("a", q{
        href="https://mstdn.social/@Soaku"
        rel="me"
    })(
        "Mastodon"
    ),

);

alias menuLinks = AliasSeq!(

    link("Blog", "/blog"),
    socialMedia,
    link("GitHub", "https://github.com/Samerion"),

);

// vim: nospell
