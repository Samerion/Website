module samerion.website.user;

import lighttp;
import csprng.system;

import passwd;
import passwd.bcrypt;

import std.ascii;
import std.format;
import std.traits;
import std.datetime;
import std.typecons;
import std.algorithm;
import std.exception;

import dpq.query;
import dpq.result;
import dpq.exception;
import dpq.attributes;
import dpq.connection;
import dpq.serialisers.composite;

import samerion.website.database;
import samerion.website.exception;

@relation("users")
struct User {

    /// Keys allowed to register and play.
    static immutable allowedKeys = [
        "soaku-fun"
    ];

    /// ID of the user.
    @serial8 @PK long id;

    /// User's nickname.
    @uniqueIndex string nickname;

    /// User's Argon2 password hash.
    string hash;

    /// Access key used to play Samerion.
    @uniqueIndex string accessKey;

    /// Logins the user
    /// Throws: `SamerionException` if registering failed. See message for details.
    /// Returns: Session token generated for the user.
    static User login(string nickname, string password) {

        immutable errorMessage = "Invalid username or password.";

        auto userN = database.findOneBy!User("nickname", nickname);

        // Check if user exists
        enforce!SamerionException(!userN.isNull, errorMessage);

        auto user = userN.get;

        // Check the password
        enforce!SamerionException(password.canCryptTo(user.hash), errorMessage);

        return user;

    }

    /// Register this user.
    /// Note: This will not verify the user's password.
    /// Throws: `SamerionException` if registering failed. See message for details.
    /// Returns: Session token generated for the user.
    void register() {

        enforce!SamerionException(
            nickname.all!isAlphaNum,
            "Nickname must only contain English letters and numbers."
        );

        enforce!SamerionException(
            nickname.length >= 3
            && nickname.length <= 20,
            "Nickname must be between 3 and 20 characters long."
        );

        enforce!SamerionException(
            allowedKeys.canFind(accessKey),
            "Invalid access key."
        );

        assert(hash.length, "Password hash cannot be empty...");

        // Insert the player into the database
        Result result;
        try result = database.insertR(this, "id");

        // We're assuming dupes
        catch (DPQException) {

            throw new SamerionException("Either the username or the access key have already been used.");

        }

        assert(result.rows == 1);

        id = result[0][0].as!long.get;

    }

    /// Start a session for this user.
    /// Returns: Session token.
    string startSession() {

        // Generate random 20 bytes
        const bytes = cast(ubyte[]) new CSPRNG().getBytes(20);

        // Format them in hex, prefix with user ID to ensure they will absolutely never overlap with another user.
        // You'd need God's help to get overlapping tokens but with this, not even God himself will be able to crack my
        // software.
        const token = format!"%x%(%.2x%)"(id, bytes);

        // Create a DB entry
        const session = Session(0, id, token);
        database.insert(session);

        return token;

    }

    void startSession(ServerResponse response) {

        Cookie cookie = {
            name: "session",
            value: startSession,
            maxAge: 30.days.total!"seconds"
        };
        response.add(cookie);

    }

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
