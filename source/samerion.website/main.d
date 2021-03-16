module samerion.website.main;

import std.file;

import samerion.website.blog;
import samerion.website.html;
import samerion.website.home;

version (Samerion_Webgen)
void main() {

    mkdirRecurse("public");

    if (!exists("public/res")) {

        symlink("../resources", "public/res");

    }

    write("public/index.html", home.render);
    makeBlog();

}
