module samerion.website.database;

import lighttp;

import std.traits;
import std.typecons;

import dpq.query;
import dpq.attributes;
import dpq.connection;
import dpq.serialisers.composite;

/// Controller for the database connections.
Connection database;

@relation("users")
struct User {

    /// ID of the user.
    @serial8 @PK long id;

    /// User's nickname.
    string nickname;

    /// User's Argon2 password hash.
    string hash;

    /// If true, the player has access to play Samerion.
    bool samerionAccess;

}

@relation("sessions")
struct Session {

    /// ID of the session
    @serial8 @PK long id;

    /// ID of the user.
    long userID;

    /// Access token for this ID.
    string token;

}

/// Get the user for given request.
Nullable!User getUser(ServerRequest request) {

    if (auto token = "session" in request.cookies) {

        auto query = Query(database, `
            SELECT users.* FROM sessions
            JOIN users ON users.id = sessions.user_id
            WHERE sessions.token = $1
        `);

        auto result = query.run(*token);

        // Ignore if didn't match a session
        if (result.rows == 0) return Nullable!User.init;

        auto user = deserialise!User(result[0]);

        return Nullable!User(user);

    }

    return Nullable!User.init;

}
