//
//  FacesPickerView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 14.04.2022.
//

import Foundation
import SwiftUI

struct FacesPickerView: View {
    
    @EnvironmentObject var viewModel: FacesPickerViewModel

    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.uiImages, id: \.self) { uiImage in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit().onTapGesture {
                            viewModel.select(image: uiImage)
                        }
                }
            }.font(.largeTitle)
        }
    }
    
}
