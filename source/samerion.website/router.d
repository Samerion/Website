module samerion.website.router;

import elemi;
import lighttp;

import std.string;
import std.exception;
import std.algorithm;

import passwd;
import passwd.bcrypt;

import samerion.website.auth;
import samerion.website.html;
import samerion.website.utils;
import samerion.website.login;
import samerion.website.database;
import samerion.website.exception;

final class Router {

    mixin RouterAuth;
    mixin RouterLogin;

    @Get("account")
    void getAccount(ServerRequest request, ServerResponse response) {

        auto user = request.getUser;

        // Not logged in, open login
        if (user.isNull) getLogin(response);

        // Logged in, view account page
        else accountPage(user.get, response);

    }

    void accountPage(User user, ServerResponse response) {

        Page page = {

            title: "My account",
            content: elems(

                elem!"h1"("My account"),
                elem!"p"(format!"Welcome, %s!"(user.nickname)),
                elem!"p"(
                    elem!("a", q{ href="/logout" })("Log out")
                )

            ),

        };

        response.body = page.render();

    }

    void invalidToken(ServerResponse response) {

        Page page = {

            title: "Invalid token",
            content: elem!("div", q{
                class="thin"
            })(

                elem!"h2"("Invalid token"),

                elem!"p"(
                    longLine(
                        "Something went wrong. It seems you are browsing the website from two tabs simultaneously.",
                        "Load the previous page and try again."
                    ),
                ),

                elem!("a", q{
                    href=""
                    class="button"
                })(
                    "Retry"
                ),

            ),

        };

        response.body = page.render;

    }

}
