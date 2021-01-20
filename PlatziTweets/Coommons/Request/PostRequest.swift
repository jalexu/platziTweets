//
//  PostRequest.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 17/01/21.
//

import Foundation

struct PostRequest: Codable {
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: PostLocation?
}
