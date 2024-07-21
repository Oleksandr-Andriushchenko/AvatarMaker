//
//  FeedDetailsView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation
import SwiftUI


struct FeedDetailsView: View {

    @EnvironmentObject var viewModel: FeedDetailsViewModel

    @State var isDragging = false
    @State var lastDraggingTime = Date()
    
    @State var lastPoint = CGSize.zero

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                viewModel.magnifyBy = amount
            }
            .onEnded { _ in

            }
    }
    
    var drag: some Gesture {
           DragGesture()
               .onChanged { point in
                   if (Date().timeIntervalSince1970 - lastDraggingTime.timeIntervalSince1970) > 0.05 {
                       self.isDragging = true
                       self.viewModel.imageTranslation = CGSize(width: point.translation.width + lastPoint.width, height: point.translation.height + lastPoint.height)
                       
                       lastDraggingTime = Date()
                   }
               }
               .onEnded { point in
                   self.isDragging = false
                   lastPoint = self.viewModel.imageTranslation
               }
               
       }
    
    @State private var showSheet = false

    var body: some View {
        VStack {
            ZStack {
                viewModel.outputImage.map { Image(uiImage: $0)
                    .resizable()
                    .scaledToFit()
                    .gesture(drag)
                }.gesture(magnification)
                
                ActivityIndicator(isAnimating: viewModel.isProcessing)
                
            }
            
            HStack {
                Button {
                    showSheet = true
                } label: {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        
                        if viewModel.selectedImage.size == .zero {
                            Text(NSLocalizedString("Select photo with face", comment: "")).padding()
                        }

                    }
                    
                }.padding()
                
                if viewModel.selectedImage.size != .zero {

                    Button {
                        self.viewModel.shareImage()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }.disabled(viewModel.isImageNotAvailable)
                        .padding()
                }
            }
            
        }.sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$viewModel.selectedImage)
        }.onAppear {
            viewModel.setup()
        }.onDisappear() {
            viewModel.cancel()
        }
    }
    
}
