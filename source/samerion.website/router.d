module samerion.website.router;

import elemi;
import lighttp;

import samerion.website.html;
import samerion.website.database;

final class Router {

    @Get("account")
    void getAccount(ServerRequest request, ServerResponse response) {

        auto user = request.getUser;

        // Not logged in, open login
        if (user.isNull) getLogin(response);


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

}
