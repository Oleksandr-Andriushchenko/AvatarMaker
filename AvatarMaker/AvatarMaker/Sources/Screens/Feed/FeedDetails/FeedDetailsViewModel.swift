//
//  FeedDetailsViewModel.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 02.04.2022.
//

import Foundation
import UIKit
import Combine
import CoreML
import Vision
import CoreImage

class FeedDetailsViewModel: ObservableObject {
    
    @Published var backgroundImage: UIImage?

    @Published var selectedImage: UIImage = UIImage()
    
    @Published var withoutBackgroundImage: UIImage?
    @Published var outputImage: UIImage?
    
    @Published var isProcessing: Bool = false
    @Published var isImageNotAvailable: Bool = true

    @Published var imageTranslation = CGSize.zero
    @Published var magnifyBy = 1.0

    private var cancelables = [AnyCancellable]()
    
    let feedItem: FeedItem
    private(set) var styleEffectWorker = StyleEffectWorker()
    
    init(feedItem: FeedItem) {
        self.feedItem = feedItem
        
        switch feedItem.feedType {
        case .inapp(let imageName):
            self.backgroundImage = UIImage(named: imageName)
        case .download(_):
            break
        }

        self.backgroundImage.map { self.outputImage = $0 }
        
        $selectedImage.sink { [weak self] inputImage in
            self?.performProcessing(inputImage: inputImage)
        }.store(in: &cancelables)
        
        $imageTranslation.sink { [weak self] in
            self?.performTranslationProcessing(imageTranslation: $0)
        }.store(in: &cancelables)
        
        $magnifyBy.sink { [weak self] in
            self?.performMagnitifyProcessing(scale: Float($0))
        }.store(in: &cancelables)
    }
    
    func setup() {
        isImageNotAvailable = true
        
        if isProcessing == false && outputImage == nil {
            self.performProcessing(inputImage: selectedImage)
        }
    }
    
    func cancel() {
        if self.isProcessing == true {
            styleEffectWorker.cancel()
            outputImage = nil
            self.isImageNotAvailable = true
            self.isProcessing = false
        }
    }
    
    private func performProcessing(inputImage: UIImage) {
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        self.styleEffectWorker.cancel()
        self.styleEffectWorker = StyleEffectWorker()
        
        DispatchQueue.main.async {
            self.backgroundImage.map {
                self.outputImage = $0
                self.isImageNotAvailable = false
            }
        }
        
        guard let resizedImage = inputImage.fixedOrientation?.resizedImage(for: CGSize(width: 513, height: 513)) else {
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            return
        }
        
        let backgroundSize = backgroundImage?.size ?? .zero
        
        let scale =  backgroundSize.height / resizedImage.size.height
        
        self.styleEffectWorker.applyEffect(inputImage: resizedImage, completion: { [weak self] withoutBackgroundImage, mask in
            let outputImage = withoutBackgroundImage.resizedImage(for: inputImage.size)
                .flatMap { self?.backgroundImage?.createContentImageOver(content: $0) }

            DispatchQueue.main.async {
                self?.outputImage = outputImage
            }
            
            self?.styleEffectWorker.applyvnAnimegan2Face(inputImage: withoutBackgroundImage, maskImage: mask, completion: { [weak self] animeImage in
                let withoutBackgroundImage = animeImage.resizedImage(for: inputImage.size)
                

                let outputImage = withoutBackgroundImage .flatMap {
                    self?.backgroundImage?.createContentImageOver(content: $0)
                }

                DispatchQueue.main.async {
                    self?.withoutBackgroundImage = withoutBackgroundImage
                    self?.isProcessing = false
                    self?.isImageNotAvailable = false
                    self?.outputImage = outputImage
                }
            })
        })
    }
    
    func performTranslationProcessing(imageTranslation: CGSize) {
        let outputImage = withoutBackgroundImage .flatMap {
            self.backgroundImage?.createContentImageOver(content: $0, offset: CGPoint(x: imageTranslation.width, y: imageTranslation.height), scale: self.magnifyBy)
        }

        self.outputImage = outputImage
    }
    
    func performMagnitifyProcessing(scale: Float) {
        let outputImage = withoutBackgroundImage .flatMap {
            self.backgroundImage?.createContentImageOver(content: $0, offset: CGPoint(x: self.imageTranslation.width, y: self.imageTranslation.height), scale: CGFloat(scale))
        }

        self.outputImage = outputImage
    }

    
    func shareImage() {
        if let outputImage = self.outputImage {
            let activityItems = [outputImage]
            let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

            UIApplication.shared.keyWindow?.rootViewController?.present(avc, animated: true, completion: nil)
        }
    }
}
