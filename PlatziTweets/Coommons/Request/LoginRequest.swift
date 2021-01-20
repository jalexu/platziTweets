//
//  LoginRequest.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 16/01/21.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}
