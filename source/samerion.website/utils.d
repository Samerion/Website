module samerion.website.utils;

import std.string;
import elemi;

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
