//
//  Response.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

public struct Response {
    public let request: NSURLRequest?
    public let response: NSHTTPURLResponse?
    public let data: NSData?
    public let result: Result
}
