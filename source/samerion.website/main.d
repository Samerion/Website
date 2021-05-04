module samerion.website.main;

import lighttp;
import dpq.connection;

import std.file;
import std.stdio : writeln;

import samerion.website.blog;
import samerion.website.html;
import samerion.website.home;
import samerion.website.router;
import samerion.website.database;

void main() {

    // Generate static content
    generateContent();

    // Connect to the database
    writeln("Connecting to the database...");
    database = Connection(`host=127.0.0.1 dbname=samerion_website user=samerion password="&X,MwM;Y~hc4249=$9o'FaQ1?"`);
    database.ensureSchema!(User, Session);

    // Start Lighttp
    writeln("Starting server...");
    with (new Server) {

        host("127.0.0.1", 8083);
        router.add(new Router);
        run();

    }

}

/// Generate static content for the website.
void generateContent() {

    writeln("Generating static content...");

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
