module samerion.website.main;

import lighttp;
import dpq.connection;

import std.conv;
import std.file;
import std.string;
import std.algorithm;
import std.stdio : writeln;

import samerion.website.blog;
import samerion.website.html;
import samerion.website.home;
import samerion.website.router;
import samerion.website.database;

void main(string[] argv) {

    string escapeValue(string content) {

        return content
            .substitute(
                `"`, `\"`,
                `\`, `\\`,
            )
            .to!string
            .format!`"%s"`;

    }

    // Generate static content
    generateContent();

    // Connect to the database
    writeln("Connecting to the database...");

    const params = format!"host=%s dbname=%s user=%s password=%s"(
        "127.0.0.1", "samerion_website",
        "samerion", escapeValue(argv[1])
    );
    database = Connection(params);
    database.ensureSchema!(User, Session);

    ServerOptions options = {

        handleExceptions: false,

    };

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
