module samerion.website.html;

import std.format;
import elemi;

import samerion.website.links;
import samerion.website.utils;

enum Layout {

    presentation,
    general

}

struct Page {

    /// Page layout
    auto layout = Layout.general;

    /// Title of the page.
    string title;

    /// Page main content.
    string content;

}

string render(Page page) {

    return Element.HTMLDoctype ~ elem!"html"(

        elem!"head"(

            // Metadata
            elem!"title"(
                page.title.length
                    ? page.title.format!"%s — Samerion"
                    : "Samerion"
            ),

            // Properties
            Element.MobileViewport,
            Element.EncodingUTF8,

            // Resources
            elem!("link", q{

                rel="stylesheet"
                href="/res/main.css"

            }),

        ),

        elem!"body"(

            ["class": page.layout.format!"layout-%s"],

            elem!"header"(page.makeNavigation),
            elem!"main".addTrusted(page.content),

        ),

    );

}

Element makeNavigation(Page page) {

    enum homeLink = elems(

        elem!("a", q{

            href="/"
            title="Home"

        })(

            elem!"picture"(

                elem!("source", q{

                    srcset="/res/logo-samerion.svg"
                    type="image/svg+xml"

                }),

                elem!("img", q{

                    src="/res/logo-samerion.png"
                    alt="Samerion"

                }),

            )

        )

    );

    final switch (page.layout) {

        case Layout.presentation:

            return elems(
                elem!"h1"(homeLink),
                elem!"nav"(menuLinks),
            );

        case Layout.general:

            return elem!"nav"(
                homeLink,
                menuLinks
            );

    }

}
