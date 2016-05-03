//
//  Result.swift
//  SwiftyOAuth
//
//  Created by Damien on 30/04/2016.
//  Copyright © 2016 delba. All rights reserved.
//

import Foundation

public enum Result {
    case Success(Credential)
    case Failure(ErrorType)
    
    public var credential: Credential? {
        switch self {
        case .Success(let credential):
            return credential
        case .Failure:
            return nil
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}