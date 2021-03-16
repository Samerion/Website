module samerion.website.blog;

import std.file;
import std.array;
import std.range;
import std.string;
import std.algorithm;

import elemi;

import samerion.website.html;
import samerion.website.utils;
import samerion.website.blog_index;

void makeBlog() {

    mkdirRecurse("public/blog");

    // Create main index for the blog
    if (!exists("public/blog/index.html")) {

        symlink("1.html", "public/blog/index.html");

    }

    makePages();

}

void makePages() {

    auto pages = blogPosts.chunks(15).array;

    // Generate pages
    foreach (i, pagePosts; pages) {

        const pageNumber = i + 1;

        // Generate index for this page
        makeIndex(pageNumber, pages.length, pagePosts);

        // Generate posts
        foreach (post; blogPosts) {

            write(post.id.format!"public/blog/%s.html", post.document(pageNumber).render);

        }

    }

}

void makeIndex(size_t pageNumber, size_t pageCount, const BlogPost[] pagePosts) {

    // First and last pages in the normal pagination
    const firstPage = pageNumber > 2 ? pageNumber - 2 : 1;
    const lastPage  = min(firstPage + 4, pageCount);

    Element pagination;
    foreach (targetPage; firstPage .. lastPage + 1) {

        string[string] attrs = [
            "href": targetPage.format!"/blog/%s",
        ];

        if (targetPage == pageNumber) {

            attrs["class"] = "current";

        }

        pagination.add!"a"(
            attrs,
            targetPage.format!"%s",
        );

    }

    Page html = {

        title: "Blog",
        content: elems(

            elem!("div", q{ class="page-list" })(

                pagePosts.map!"a.entry".array

            ),

            elem!("div", q{ class="pagination" })(

                elem!"a"(
                    [
                        "class": "special",
                        "href": "/blog/1",
                    ],
                    "First"
                ),

                pagination,

                elem!"a"(
                    [
                        "class": "special",
                        "href": format!"/blog/%s"(pageCount)
                    ],
                    "Last"
                ),

            ),

        )

    };

    write(format!"public/blog/%s.html"(pageNumber), html.render);

}
