module samerion.website.database;

import lighttp;

import dpq.attributes;
import dpq.connection;

import samerion.website.exception;
public import samerion.website.user;

/// Controller for the database connections.
Connection database;

@relation("sessions")
struct Session {

    /// ID of the session
    @serial8 @PK long id;

    /// ID of the user.
    long userID;

    /// Access token for this ID.
    @uniqueIndex string token;

}

/// Stop a session
void stopSession(ServerRequest request) {

    if (auto token = "session" in request.cookies) {

        database.remove!Session("token = $1", *token);

    }

}
