//
//  LoginResponse.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 16/01/21.
//

import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}
