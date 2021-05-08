module samerion.website.auth;

mixin template RouterAuth() {

    @Get("auth", `(\w+)`)
    void getAuth(ServerRequest request, ServerResponse response, string) {

        // Get the user
        auto userN = getUserRedirect(request, response);
        if (userN.isNull) return;

        Page page = {

            title: "Authorize",
            content: elem!("form", q{
                method="POST"
            })(

                elem!"h2"("Login into the game?"),

                elem!"p"("Press the button below to confirm login."),
                elem!"p"(
                    longLine(
                        "Note: Do this only if you're trying to login into the game at the moment. Close this tab",
                        "otherwise, do not trust anyone who might have sent you this link."
                    ),
                ),

                elem!"input"([
                    "type": "hidden",
                    "name": "token",
                    "value": userN.get.makeRequestToken,
                ]),

                elem!("input", q{
                    type="submit"
                    value="Confirm"

                })

            ),

        };

        response.body = page.render;

    }

    @Post("auth", `(\w+)`)
    void postAuth(ServerRequest request, ServerResponse response, string target) {

        // Get the user
        auto userN = getUserRedirect(request, response);
        if (userN.isNull) return;

        auto user = userN.get;

        // Check the auth token first
        if (!user.verifyRequestToken(request)) {

            invalidToken(response);
            return;

        }

        Page page = {

            title: "Access authorized",
            content: elem!("div", q{
                class="thin"
            })(

                elem!"h2"("Authorized!"),

                elem!"p"(
                    "You can now close this tab and return to the game."
                ),

            ),

        };

        response.body = page.render;

    }

}
