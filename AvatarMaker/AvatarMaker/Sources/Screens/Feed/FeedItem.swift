//
//  FeedItem.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation

enum FeedItemData {
    
    case inapp(String)
    case download(URL)
    
    var URLString: String {
        switch self {
        case .inapp(let value):
            return value
        case .download(let url):
            return url.absoluteString
        }
    }
    
    var imageName: String? {
        switch self {
        case .inapp(let value):
            return value
        case .download(_):
            return nil
        }
    }
    
}

struct FeedItem {
    
    var feedType: FeedItemData
    
    var title: String
    
}


extension FeedItem: Equatable {
    
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        var isDataEquals = false
        
        switch lhs.feedType {
        case .inapp(_):
            switch rhs.feedType {
            case .inapp(_):
                isDataEquals = true
            case .download(_):
                isDataEquals = false
            }
        case .download(_):
            switch rhs.feedType {
            case .inapp(_):
                isDataEquals = false
            case .download(_):
                isDataEquals = true
            }
        }
        
        return lhs.title == rhs.title && isDataEquals
    }
    
}


extension FeedItem: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(feedType.URLString)
    }
    
}
