module samerion.website.presentation;

import elemi;

/// Main, first section of the page, taking <h1> from the header.
Element mainSection(string content) {

    return elem!("div", q{

        class="section"

    })(

        elem!"p"(content),

    );

}

/// Represents a section in the page.
Element section(T...)(string title, string content, T include) {

    return elem!("div", q{

        class="section"

    })(

        elem!("h2")(title),
        elem!"p"(content),
        include,

    );

}

/// Place a box within the page.
Element box(T...)(string title, string text, T include) {

    return elem!("article", q{

        class="box"

    })(

        elem!"p"(title),

        elem!"span"(text),

        elem!("span", q{ class="right" })(
            include,
        )

    );

}
