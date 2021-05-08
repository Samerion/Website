module samerion.website.utils;

import elemi;
import lighttp.util;

import std.uri;
import std.string;
import std.typecons;
import std.algorithm;
import std.exception;

/// Join lines of text into one.
string longLine(string[] text...) {

    return text.join(" ");

}

/// Join elements into one.
Element elems(Element[] elements...) {

    Element list;
    list.add(elements);

    return list;

}

/// Check each body key
auto bodyEach(ServerRequest request) {

    struct BodyEach {

        int opApply(int delegate(string key, string value) dg) {

            // Check each value
            foreach (argument; request.body.splitter("&")) {

                // Get the pair
                const pair = queryPair(argument);

                // Stop iteration
                if (auto result = dg(pair.expand)) {

                    return result;

                }

            }

            return 0;

        }

    }

    return BodyEach();

}

/// Split the argument into a pair by the equal sign.
private auto queryPair(string argument) nothrow {

    const pair = argument.findSplit("=");

    // Not a pair
    if (!pair) return tuple("", "");

    return tuple(
        pair[0].decodeComponent.ifThrown("").assertNotThrown,
        pair[2].decodeComponent.ifThrown("").assertNotThrown,
    );

}
