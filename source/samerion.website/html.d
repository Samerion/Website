module samerion.website.html;

import std.format;
import elemi;

import samerion.website.links;

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

        elem!"html"(

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

            elem!"header"(

                elem!"h1"(

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

                ),

                elem!"nav"(

                    menuLinks

                ),

            ),

            elem!"main".addTrusted(page.content),

        ),

    );

}
