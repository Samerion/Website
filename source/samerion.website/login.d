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
        response.redirect(StatusCodes.temporaryRedirect, "/login");

    }

    @Post("login") @Post("account")
    void postLogin(ServerRequest request, ServerResponse response) {

        string nickname, password;

        // Assemble the data
        foreach (key, value; request.bodyEach) {

            switch (key) {

                case "nickname":
                    nickname = value;
                    break;

                case "password":
                    password = value;
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

    /// Check if the password is correct, and if so, generate a bcrypt hash for it.
    /// Throws: `SamerionException` if the password is incorrect.
    string checkPassword(string pass1, string pass2) {

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

        return cast(string) pass1.crypt(Bcrypt.genSalt);

    }

    @Post("register")
    void postRegister(ServerRequest request, ServerResponse response) {

        string pass1, pass2;
        User user;

        // Assemble the user
        foreach (key, value; request.bodyEach) {

            switch (key) {

                case "nickname":
                    user.nickname = value;
                    break;

                case "password":
                    pass1 = value;
                    break;

                case "password2":
                    pass2 = value;
                    break;

                case "access":
                    user.accessKey = value;
                    break;

                default: break;

            }

        }

        try {

            // Hash the password
            user.hash = checkPassword(pass1, pass2);

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
