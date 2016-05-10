//
//  HTTP.swift
//  SwiftyOAuth
//
//  Created by Damien on 10/05/2016.
//  Copyright © 2016 delba. All rights reserved.
//

struct HTTP {
    static func POST(URL: NSURL, parameters: [String: String], completion: Result<[String: AnyObject], NSError> -> Void) {
        let request = NSMutableURLRequest(URL: URL)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.HTTPBody = parameters.map { "\($0)=\($1)" }
            .joinWithSeparator("&")
            .dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completion(.Failure(error))
                return
            }
            
            guard let data = data else {
                // TODO better error than that...
                let error = NSError(domain: "No data received", code: 42, userInfo: nil)
                completion(.Failure(error))
                return
            }
            
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    completion(.Success(dictionary))
                } else {
                    let error = NSError(domain: "Cannot initialize credential", code: 42, userInfo: nil)
                    completion(.Failure(error))
                }
            } catch {
                completion(.Failure(error as NSError))
            }
        }
        
        task.resume()
    }
}
