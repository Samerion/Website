module samerion.website.router;

import elemi;
import lighttp;

import std.string;
import std.exception;
import std.algorithm;

import passwd;
import passwd.bcrypt;

import samerion.website.html;
import samerion.website.utils;
import samerion.website.login;
import samerion.website.database;
import samerion.website.exception;

final class Router {

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

}
