//
//  FeedView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation
import SwiftUI


struct FeedView: View {
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @EnvironmentObject var viewModel: FeedViewViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.feedItems, id: \.self) { feedItem in
                        NavigationLink(destination: FeedDetailsView().environmentObject(viewModel.createFeedDetailsViewModel(for: feedItem))) {
                            VStack {
                                ZStack {
                                    feedItem.feedType.imageName.map { Image($0)
                                        .resizable()
                                        .scaledToFit()
                                    }
                                }.frame(width: nil, height: nil, alignment: .center)
                                
                                HStack {
                                    Text("\(feedItem.title)")
                                        .font(.system(size: 12))
                                    Spacer()
                                }
                            }
                        }.navigationTitle("Collection")
                    }
                }.font(.largeTitle)
            }
        }.onAppear {
            viewModel.setup()
        }
    }
}
