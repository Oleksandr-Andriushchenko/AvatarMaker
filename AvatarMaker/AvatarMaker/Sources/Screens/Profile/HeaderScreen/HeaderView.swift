//
//  HeaderView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import SwiftUI

struct HeaderView: View {

    @State var image: UIImage = UIImage(named: "profile") ?? UIImage()
    
    @EnvironmentObject var viewModel: HeaderViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.gray)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 100)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .onReceive(viewModel.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage(named: "profile")!
                }
        }
    }

}
