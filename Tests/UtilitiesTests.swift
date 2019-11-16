//
// UtilitiesTests.swift
//
// Copyright (c) 2016-2019 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import XCTest
@testable import SwiftyOAuth

class Utilities: XCTestCase {

    func testFragments() {
        var url: URL

        url = URL(string: "https://www.example.com")!
        XCTAssertEqual([:], url.fragments)

        url = URL(string: "https://www.example.com/path#foo=bar&baz=value")!
        XCTAssertEqual(["foo": "bar", "baz": "value"], url.fragments)

        url = URL(string: "https://www.example.com/path#foo=bar&baz")!
        XCTAssertEqual(["foo": "bar"], url.fragments)
    }

    func testQueriesProperties() {
        var url: URL

        url = URL(string: "https://www.example.com")!
        XCTAssertEqual([:], url.queries)

        url = URL(string: "https://www.example.com/path?foo=bar&baz=value")!
        XCTAssertEqual(["foo": "bar", "baz": "value"], url.queries)

        url = URL(string: "https://www.example.com/path?foo=bar&baz")!
        XCTAssertEqual(["foo": "bar"], url.queries)
    }

    func testQueriesFunction() {
        var base: URL
        var url: URL

        base = URL(string: "https://www.example.com")!

        url = base.queries([
            "foo": "bar",
            "baz": "value"
        ])

        XCTAssertEqual(["foo": "bar", "baz": "value"], url.queries)

        url = base.queries([
            "foo": "bar"
        ])

        XCTAssertEqual(["foo": "bar"], url.queries)
    }

    func testMergeDictionaries() {
        var params = [
            "client_id": "clientID",
            "client_secret": "clientSecret",
            "redirect_uri": "redirectURL"
        ]

        params.merge(["bool": "false"])

        XCTAssertEqual([
            "client_id": "clientID",
            "client_secret": "clientSecret",
            "redirect_uri": "redirectURL",
            "bool": "false"
        ], params)
    }

}
