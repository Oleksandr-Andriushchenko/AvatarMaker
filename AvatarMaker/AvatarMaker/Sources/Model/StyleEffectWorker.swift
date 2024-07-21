//
//  StyleEffectWorker.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 03.04.2022.
//

import Foundation
import CoreML
import Vision
import UIKit

class StyleEffectModelLocator {
    
    static let shared = StyleEffectModelLocator()

    var vnAnimegan2FaceCoreMLModel: VNCoreMLModel?
    private(set) var animegan2Face: Animegan2Face?
    
    init() {
        DispatchQueue.global().async {
            let animeGanConfiguration = MLModelConfiguration()
            animeGanConfiguration.computeUnits = .cpuOnly
            
            DispatchQueue.global().async {
                self.animegan2Face = try? Animegan2Face(configuration: animeGanConfiguration)
                DispatchQueue.global().async {
                    self.vnAnimegan2FaceCoreMLModel = self.animegan2Face.flatMap { try? VNCoreMLModel(for: $0.model) }
                }
            }
        }
    }
}

class StyleEffectWorker {
    
    let modelLocator = StyleEffectModelLocator.shared
    
    var isCanceled = false
    
    func cancel() {
        isCanceled = true
    }
    
    func applyEffect(inputImage: UIImage, completion: @escaping ((UIImage, UIImage?) -> Void)) {
        let personSegmentationRequest = VNGeneratePersonSegmentationRequest()
        personSegmentationRequest.qualityLevel = .balanced
        personSegmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        let requestHandler = VNImageRequestHandler(cgImage: inputImage.cgImage!)
        try? requestHandler.perform([personSegmentationRequest])
        guard let resultPixelBuffer = personSegmentationRequest.results?.first?.pixelBuffer else { return }
        
        let maskedImage = CIImage(cvImageBuffer: resultPixelBuffer)
        
        let colorInvertFilter = CIFilter(name: "CIColorInvert")
        colorInvertFilter?.setValue(maskedImage, forKey: kCIInputImageKey)
        let inversedmaskedImage = colorInvertFilter?.outputImage
        
        guard isCanceled == false else { return }

        inversedmaskedImage.map { inversedmaskedImage in
            let cgMask = convertCIImageToCGImage(inputImage: inversedmaskedImage)
            cgMask.map { cgMask in
                self.cgmaskOriginalImage(mask: cgMask, image: inputImage).map {
                    completion($0, UIImage(cgImage: cgMask))
                }
            }
        }
    }
    
    func applyvnAnimegan2Face(inputImage: UIImage, maskImage: UIImage?, completion: @escaping ((UIImage) -> Void)) {
        guard let vnMLModel = modelLocator.vnAnimegan2FaceCoreMLModel else { return }
        guard self.isCanceled == false else { return }

        let request = VNCoreMLRequest(model: vnMLModel) { request, _ in
            guard self.isCanceled == false else { return }

            let observations = request.results as? [VNPixelBufferObservation]
            let pixelBuffer = observations?.first?.pixelBuffer
            let ciImage = pixelBuffer.map { CIImage(cvPixelBuffer: $0) }
            guard self.isCanceled == false else { return }

            ciImage.map {
                self.convertCIImageToCGImage(inputImage: $0).map {
                    guard self.isCanceled == false else { return }

                    let uiImage = UIImage(cgImage: $0)
                    maskImage.map { self.maskOriginalImage(mask: $0, image: uiImage).map { completion($0) } }
                }
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        DispatchQueue.global().async {
            guard self.isCanceled == false else { return }
            let handler = inputImage.fixedOrientation?.cgImage.map { VNImageRequestHandler(cgImage: $0, options: [:]) }
            guard self.isCanceled == false else { return }
            try? handler?.perform([request])
        }
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    func cgmaskOriginalImage(mask cgImage: CGImage, image: UIImage) -> UIImage? {
        let imageMask = cgImage.dataProvider.flatMap {
                CGImage(maskWidth: cgImage.width,
                        height: cgImage.height,
                        bitsPerComponent: cgImage.bitsPerComponent,
                        bitsPerPixel: cgImage.bitsPerPixel,
                        bytesPerRow: cgImage.bytesPerRow,
                        provider: $0, decode: nil, shouldInterpolate: true)
            }
        
        let maskedImage = imageMask.flatMap { image.fixedOrientation?.cgImage?.masking($0) }
        let uiImage = maskedImage.map { UIImage(cgImage: $0) }?.cropImage(inset: 8.0)
        return uiImage.flatMap { self.drawImage($0)  }
    }
    
    func maskOriginalImage(mask maskImage: UIImage, image: UIImage) -> UIImage? {
        let ciMask = maskImage.cgImage.map { CIImage(cgImage: $0) }?.applyingGaussianBlur(sigma: 1.0)
        let cgMask = ciMask.flatMap { convertCIImageToCGImage(inputImage: $0) }

        let imageMask = cgMask.flatMap { cgImage in
            cgImage.dataProvider.flatMap {
                CGImage(maskWidth: cgImage.width,
                        height: cgImage.height,
                        bitsPerComponent: cgImage.bitsPerComponent,
                        bitsPerPixel: cgImage.bitsPerPixel,
                        bytesPerRow: cgImage.bytesPerRow,
                        provider: $0, decode: nil, shouldInterpolate: true)
            }
        }
        
        let maskedImage = imageMask.flatMap { image.fixedOrientation?.cgImage?.masking($0) }
        let uiImage = maskedImage.map { UIImage(cgImage: $0) }?.cropImage(inset: 8.0)
        return uiImage.flatMap { self.drawImage($0)  }
    }
    
    func drawImage(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: image.size.width, height: image.size.height))
        image.draw(in: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage;
    }
    

}
