//
//  ProfileView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    @State private var scrollAmount: CGFloat = .zero
    
    @State private var nameToHeaderDistance: CGFloat = .zero
    
    @State var isPresented = false

    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                VStack {
                    HeaderView()
                        .environmentObject(HeaderViewModel(urlString: viewModel.urlString))
                    VStack {
                        Text(viewModel.name)
                            .bold()
                            .font(.title)
                        Text(viewModel.shortDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer(minLength: 10)
                Button (
                    action: { self.isPresented = true },
                    label: {
                        Label("Edit", systemImage: "pencil")
                })
                .sheet(isPresented: $isPresented, content: {
                    Text("In Development")
                })
//                    ForEach(0..<10) { _ in
//                        Text("Loren Content")
//                            .foregroundColor(.gray)
//                            .frame(height: 100)
//                            .frame(maxWidth: .infinity)
//                    }
            }
 
        }
    }
}
