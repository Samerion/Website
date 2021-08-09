module samerion.website.database;

import lighttp;

import std.datetime;

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

// Note: since we're not gathering e-mails, passwords resets are done manually

@relation("password_resets")
struct PasswordReset {

    /// ID of the request.
    @serial8 @PK long id;

    /// ID of the user to reset password of.
    // Not a foreign key because dpq is stupid and crashes because User has methods
    long userID;

    /// Expiration time of the request.
    SysTime expires;

    /// Reset token for this password.
    @uniqueIndex string token;

}

/// Stop a session
void stopSession(ServerRequest request) {

    if (auto token = "session" in request.cookies) {

        database.remove!Session("token = $1", *token);

    }

}
