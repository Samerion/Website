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
