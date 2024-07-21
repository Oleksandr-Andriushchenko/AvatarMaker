//
//  ProfileViewModel.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    @Published var name = "Alex"
    
    @Published var shortDescription = "Short Description"
    
    @Published var description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Non arcu risus quis varius quam. Faucibus ornare suspendisse sed nisi lacus sed viverra tellus. Ornare suspendisse sed nisi lacus sed viverra tellus. Arcu odio ut sem nulla pharetra. Vitae congue mauris rhoncus aenean vel elit. Scelerisque eu ultrices vitae auctor eu."
    
    let urlString: String = "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
}
