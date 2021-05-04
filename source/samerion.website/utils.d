module samerion.website.utils;

import elemi;

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

/// Split the argument into a pair by the equal sign.
auto queryPair(string argument) nothrow {

    const pair = argument.findSplit("=");

    // Not a pair
    if (!pair) return tuple("", "");

    return tuple(
        pair[0].decodeComponent.ifThrown("").assertNotThrown,
        pair[2].decodeComponent.ifThrown("").assertNotThrown,
    );

}
