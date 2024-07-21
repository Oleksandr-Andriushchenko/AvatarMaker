//
//  FeedViewViewModel.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation


class FeedViewViewModel: ObservableObject {
    
    @Published var feedItems: [FeedItem] = [FeedItem]()

    private var actualFeedDetailsViewModel: FeedDetailsViewModel?
    
    func setup() {
        feedItems = [
            FeedItem(feedType: .inapp("LoveUAFlag"), title: "Love UA"),
            FeedItem(feedType: .inapp("Good-Evening"), title: "Good Evening!"),
            FeedItem(feedType: .inapp("BackgroundUAFlag"), title: "Background UA"),
            FeedItem(feedType: .inapp("CottonImage"), title: "Cotton"),
            FeedItem(feedType: .inapp("EarsinFire"), title: "Ears of corn in the fire"),
            FeedItem(feedType: .inapp("ShevchenkoHouse"), title: "Old UA House"),
            FeedItem(feedType: .inapp("FieldWay"), title: "Way in Field")
        ]
    }
    
    func createFeedDetailsViewModel(for feedItem: FeedItem) -> FeedDetailsViewModel {
        let feedDetailsViewModel = FeedDetailsViewModel(feedItem: feedItem)
        self.actualFeedDetailsViewModel?.cancel()
        self.actualFeedDetailsViewModel = feedDetailsViewModel
        return feedDetailsViewModel
    }
    
}
