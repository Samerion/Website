module samerion.website.router;

import elemi;
import lighttp;
import libasync;

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

    @Get("password-reset", r"([0-9a-f]{40})")
    @Post("password-reset", r"([0-9a-f]{40})")
    void passwordReset(ServerRequest request, ServerResponse response, string token) {

        import std.datetime : Clock;

        const time = Clock.currTime;

        auto data = database.findOneBy!PasswordReset("token", token);

        // Invalid token
        if (data.isNull) {

            invalidRequest(response);
            return;

        }

        // Expired token
        if (time >= data.get.expires) {

            database.remove!PasswordReset(data.get.id);
            invalidRequest(response);
            return;

        }

        if (request.method.toUpper == "POST") {

            passwordResetPerform(request, response, data.get);

        }

        else passwordResetForm(response);

    }

    void passwordResetForm(ServerResponse response, string mistakesWereMade = "") {

        Page page = {

            title: "Password reset",
            content: elem!("form", q{
                method="POST"
            })(

                elem!"h2"("Password reset"),

                elem!("p", q{ class="error" })(mistakesWereMade),

                elem!"label"(
                    "Password",
                    elem!("input", q{ type="password" name="password" }),
                ),

                elem!"label"(
                    "Repeat password",
                    elem!("input", q{ type="password" name="password2" }),
                ),

                elem!("input", q{ type="submit" value="Reset password" }),

            ),

        };

        response.body = page.render;

    }

    void passwordResetPerform(ServerRequest request, ServerResponse response, PasswordReset data) {

        // Assumption: token has been verified

        string pass1, pass2;

        // Check password
        foreach (key, value; request.bodyEach) {

            switch (key) {

                case "password":
                    pass1 = value;
                    break;

                case "password2":
                    pass2 = value;
                    break;

                default: break;

            }

        }

        import dpq.query;
        import samerion.website.links;

        string hash;

        // Hash the password
        try hash = checkPassword(pass1, pass2);

        // Failure...
        catch (SamerionException exc) {

            passwordResetForm(response, exc.msg);
            return;

        }

        // Update the entry
        auto query = Query(database, `
            UPDATE users
            SET hash=$1
            WHERE id=$2
        `);

        query.run(hash, data.userID);

        // Remove the request
        database.remove!PasswordReset(data.id);

        Page page = {

            title: "Password reset",
            content: elem!("div", q{
                class="thin"
            })(

                elem!"h2"("Reset successful."),

                elem!"p"("You can now log in."),

                link("Proceed", "/login"),

            ),

        };

        response.body = page.render;

    }

    void invalidRequest(ServerResponse response) {

        response.status = StatusCodes.unauthorized;
        Page page = {

            title: "Invalid request",
            content: elem!("div", q{
                class="thin"
            })(

                elem!"h2"("Invalid request"),

                elem!"p"("Requested address isn't valid; it might have expired."),

            ),

        };

        response.body = page.render;

    }

}
