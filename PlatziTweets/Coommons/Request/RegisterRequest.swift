//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 17/01/21.
//

import Foundation

struct ResgisterRequest: Codable {
    let email: String
    let password: String
    let names: String
}
