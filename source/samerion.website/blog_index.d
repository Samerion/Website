module samerion.website.blog_index;

import std.meta;
import std.file;
import std.string;

import elemi;
import commonmarkd;

import samerion.website.html;
import samerion.website.utils;

immutable blogPosts = [

    BlogPost(
        "2020-11-07-mirrors", "pages/blog/2020-11-07-mirrors.md",
        "2020-11-07", "World Mirrors — Parallel worlds in Samerion",
    ),
    BlogPost(
        "2021-01-13-dialogue", "pages/blog/2021-01-13-dialogue.md",
        "2021-01-13", "Role-play: The dialogue system",
    ),
    BlogPost(
        "2021-03-04-monetization", "pages/blog/2021-03-04-monetization.md",
        "2021-03-04", "Monetization of Samerion",
    ),

];

struct BlogPost {

    /// ID of the post.
    string id;

    /// File the post's content is located in.
    string file;

    /// Publication date in ISO8601.
    string publicationDate;

    /// Title of the post.
    string title;

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
