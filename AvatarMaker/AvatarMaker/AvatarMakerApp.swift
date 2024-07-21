//
//  AvatarMakerApp.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 01.04.2022.
//

import SwiftUI

@main
struct AvatarMakerApp: App {
    let feedViewViewModel = FeedViewViewModel()
    let profileViewModel = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView()
                    .environmentObject(feedViewViewModel)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text(NSLocalizedString("Feed", comment: ""))
                    }.tag(0)
                
                ProfileView()
                    .environmentObject(profileViewModel)
                    .tabItem {
                        Image(systemName: "person")
                        Text(NSLocalizedString("Profile", comment: ""))
                    }.tag(1)
            }
        }
    }
}
