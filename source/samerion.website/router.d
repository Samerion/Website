module samerion.website.router;

import lighttp;

import samerion.website.database;

final class Router {

    @Get("account")
    void getAccount(ServerRequest request, ServerResponse response) {

        auto user = request.getUser;

        response.body = user;

    }

}
