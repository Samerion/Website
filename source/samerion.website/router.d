module samerion.website.router;

import elemi;
import lighttp;

import std.uri;
import std.exception;
import std.algorithm;

import passwd;
import passwd.bcrypt;

import samerion.website.html;
import samerion.website.database;
import samerion.website.exception;

final class Router {

    @Get("account")
    void getAccount(ServerRequest request, ServerResponse response) {

        auto user = request.getUser;

        // Not logged in, open login
        if (user.isNull) getLogin(response);

        else response.body = user;

    }

    @Get("login")
    void getLogin(ServerResponse response) {

        Page page = {

            title: "Login",
            content: elem!("form", q{
                method="POST"
            })(

                elem!"h1"("Login"),

                elem!"p"(
                    "Alternatively, ",
                    elem!("a", q{ href="/register" } )(
                        "register…"
                    )
                ),

                elem!"label"(
                    "Nickname",
                    elem!("input", q{ type="text" name="nickname" }),
                ),

                elem!"label"(
                    "Password",
                    elem!("input", q{ type="password" name="password" }),
                ),

                elem!("input", q{ type="submit" value="Login" }),

            ),

        };

        response.body = page.render();

    }

    @Get("register")
    void getRegister(ServerResponse response) {

        getRegisterImpl(response);

    }

    void getRegisterImpl(ServerResponse response, string mistakesWereMade = "") {

        Page page = {

            title: "Register",
            content: elem!("form", q{
                method="POST"
            })(

                elem!"h1"("Register"),

                elem!"p"(
                    "Alternatively, ",
                    elem!("a", q{ href="/login" } )(
                        "login…"
                    )
                ),

                elem!"p"(
                    "Note: creating accounts is currently restricted to people given an access key. ",
                    "If you've got one, you should have also received necessary legal notices regarding terms of use ",
                    "and privacy policy."
                ),

                elem!("p", q{ class="error" })(mistakesWereMade),

                elem!"label"(
                    "Nickname",
                    elem!("input", q{ type="text" name="nickname" }),
                ),

                elem!"label"(
                    "Password",
                    elem!("input", q{ type="password" name="password" }),
                ),

                elem!"label"(
                    "Repeat password",
                    elem!("input", q{ type="password" name="password2" }),
                ),

                elem!"label"(
                    "Your access key",
                    elem!("input", q{ type="text" name="access" }),
                ),

                elem!("input", q{ type="submit" value="Register" }),

            ),

        };

        response.body = page.render();

    }

    @Post("register")
    void postRegister(ServerRequest request, ServerResponse response) {

        string pass1, pass2;
        User user;

        // Assemble the user
        foreach (argument; request.body.splitter("&")) {

            // Get the pair
            const pair = argument.findSplit("=");
            if (!pair) continue;

            // Decode
            const left = pair[0].decodeComponent.ifThrown("");
            const right = pair[2].decodeComponent.ifThrown("");

            switch (left) {

                case "nickname":
                    user.nickname = right;
                    break;

                case "password":
                    pass1 = right;
                    break;

                case "password2":
                    pass2 = right;
                    break;

                case "access":
                    user.accessKey = right;
                    break;

                default: break;

            }

        }

        try {

            // Check the password
            enforce!SamerionException(
                pass1.length >= 6,
                "Password must be at least 6 characters long."
            );

            enforce!SamerionException(
                pass1.length <= 256,
                "The password can be at most 256 characters long."
            );

            enforce!SamerionException(
                pass1 == pass2,
                "Given passwords don't match."
            );

            // Hash the password
            user.hash = cast(string) pass1.crypt(Bcrypt.genSalt);

            // Try to register the user
            response.add(Cookie("session", user.register));

        }

        catch (SamerionException exc) {

            getRegisterImpl(response, cast(string) exc.message);
            return;

        }

        getAccount(request, response);

    }

}
