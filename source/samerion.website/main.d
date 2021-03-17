module samerion.website.main;

import std.file;

import samerion.website.blog;
import samerion.website.html;
import samerion.website.home;

version (Samerion_Webgen)
void main() {

    // Prepare the public directory
    mkdirRecurse("public");

    // Create resources
    if (!exists("public/res")) {

        symlink("../resources", "public/res");

    }

    // Create the favicon
    copy("resources/favicon-samerion.ico", "public/favicon.ico");

    // Pages
    write("public/index.html", home.render);
    makeBlog();

}
