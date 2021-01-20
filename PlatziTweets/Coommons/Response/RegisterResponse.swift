//
//  RegisterResponse.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 17/01/21.
//

import Foundation

struct RegisterResponse: Codable {
    let user: User
    let token: String
}
