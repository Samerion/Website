module samerion.website.blog_index;

import std.meta;
import std.file;
import std.string;

import elemi;
import commonmarkd;

import samerion.website.html;
import samerion.website.utils;

immutable blogPosts = [

    BlogPost.make("2021-04-14", "map", "The continent of Neasdal: Countries in Samerion"),
    BlogPost.make("2021-04-09", "races", "Races of Armitris"),
    BlogPost.make("2021-03-24", "combat-stats", "Combat, pt. 2: stats and actions"),
    BlogPost.make("2021-03-16", "combat", "Combat, pt. 1: turns and queues"),
    BlogPost.make("2021-03-04", "monetization", "Monetization of Samerion"),
    BlogPost.make("2021-01-13", "dialogue", "Role-play: The dialogue system"),
    BlogPost.make("2020-11-07", "mirrors", "World Mirrors — Parallel worlds in Samerion"),

];

struct BlogPost {

    /// ID of the post.
    string id;

    /// File the post's content is located in.
    string file;

    /// Publication date in ISO 8601.
    string publicationDate;

    /// Title of the post.
    string title;

    /// Make a new blog post
    static BlogPost make(string date, string id, string title) {

        const fullID = format!"%s-%s"(date, id);
        return BlogPost(
            fullID, fullID.format!"pages/blog/%s.md",
            date, title,
        );

    }

    /// Get a blog list entry for this post.
    Element entry() const {

        return elem!"a"(

            ["class": "entry", "href": "/blog/" ~ id],

            elem!"h2"(title),
            elem!"p"(publicationDate.format!"Published %s"),

        );

    }

    Page document(size_t pageNumber) const {

        Page ret = {

            title: title,
            content: elems(

                elem!"a"(
                    ["href": pageNumber.format!"/blog/%s"],
                    "Back",
                ),
                elem!"p"(publicationDate.format!"Posted on %s"),

                elemTrusted(convertMarkdownToHTML(file.readText, MarkdownFlag.dialectGitHub)),

            ),

        };

        return ret;

    }

}
