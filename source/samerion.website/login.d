/// This module contains the login frontend.
module samerion.website.login;

mixin template RouterLogin() {

    @Get("login")
    void getLogin(ServerResponse response) {

        getLoginImpl(response);

    }

    void getLoginImpl(ServerResponse response, string mistakesWereMade = "") {

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

                elem!("p", q{ class="error" })(mistakesWereMade),

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

    @Get("logout")
    void getLogout(ServerRequest request, ServerResponse response) {

        // Stop the session
        stopSession(request);

        // Redirect to login
        getLogin(response);

    }

    @Post("login") @Post("account")
    void postLogin(ServerRequest request, ServerResponse response) {

        string nickname, password;

        // Assemble the data
        foreach (argument; request.body.splitter("&")) {

            // Get the pair
            const pair = queryPair(argument);

            switch (pair[0]) {

                case "nickname":
                    nickname = pair[1];
                    break;

                case "password":
                    password = pair[1];
                    break;

                default: break;

            }

        }

        User user;
        try user = User.login(nickname, password);
        catch (SamerionException exc) {

            getLoginImpl(response, cast(string) exc.message);
            return;

        }

        user.startSession(response);
        accountPage(user, response);

    }

    @Post("register")
    void postRegister(ServerRequest request, ServerResponse response) {

        string pass1, pass2;
        User user;

        // Assemble the user
        foreach (argument; request.body.splitter("&")) {

            // Get the pair
            const pair = queryPair(argument);

            switch (pair[0]) {

                case "nickname":
                    user.nickname = pair[1];
                    break;

                case "password":
                    pass1 = pair[1];
                    break;

                case "password2":
                    pass2 = pair[1];
                    break;

                case "access":
                    user.accessKey = pair[1];
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
            user.register();

        }

        catch (SamerionException exc) {

            getRegisterImpl(response, cast(string) exc.message);
            return;

        }

        user.startSession(response);
        accountPage(user, response);

    }

}
