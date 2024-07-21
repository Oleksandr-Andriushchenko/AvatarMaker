//
//  FacesPickerViewModel.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 14.04.2022.
//


import Foundation
import UIKit
import Vision


class FacesPickerViewModel: ObservableObject {
    
    let faces: [VNFaceObservation]
    
    let image: UIImage
    
    @Published var uiImages: [UIImage] = [UIImage]()

    private(set) var selectImageHandler: ((UIImage) -> Void)
    
    init(image: UIImage, faces: [VNFaceObservation], selectImageHandler: @escaping ((UIImage) -> Void)) {
        self.image = image
        self.faces = faces
        self.selectImageHandler = selectImageHandler
        
        var uiImages = [UIImage]()
        
        for face in faces {
            let uiImage = image.crop(face: face)
            uiImages.append(uiImage)
        }
        
        self.uiImages = uiImages
    }
    
    func select(image: UIImage) {
        self.selectImageHandler(image)
    }
}
