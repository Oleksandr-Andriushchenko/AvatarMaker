//
//  UIImageExtensions.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 03.04.2022.
//

import UIKit
import CoreGraphics
import Vision


extension UIImage {
    
    func resizedImage(for size: CGSize) -> UIImage? {
        let context = cgImage.flatMap { CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: $0.bitsPerComponent,
                                    bytesPerRow: Int(size.width) * 4,
                                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: $0.bitmapInfo.rawValue) }
        context?.interpolationQuality = .high
        
        cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: size)) }

        guard let scaledImage = context?.makeImage() else { return nil }

        return UIImage(cgImage: scaledImage)
    }
    
    var fixedOrientation: UIImage? {
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .up:
            return self
        case .upMirrored:
            return self
        case .down:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: CGFloat.pi * 0.5)
        case .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: CGFloat.pi * 0.5)
        case .right:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi * 0.5)
        case .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi * 0.5)
        default:
            break
        }
        
        switch self.imageOrientation {
        case .up:
            break
        case .down:
            break
        case .left:
            break
        case .right:
            break
        case .upMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        @unknown default:
            break
        }
        
        let context = cgImage.flatMap {
            CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: $0.bitsPerComponent, bytesPerRow: 0, space: $0.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: $0.bitmapInfo.rawValue)
        }
        
        context?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width))) }
        case .right:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width))) }
        case .leftMirrored:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width))) }
        case .rightMirrored:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width))) }
        case .up:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: size)) }
        case .down:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: size)) }
        case .upMirrored:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: size)) }
        case .downMirrored:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: size)) }
        @unknown default:
            self.cgImage.map { context?.draw($0, in: CGRect(origin: .zero, size: size)) }
        }
        
        
        let resultCGImage = context?.makeImage()
        
        let uiImage = resultCGImage.map { UIImage(cgImage: $0) }
        
        return uiImage
    }
    
    func cropImage(inset: CGFloat) -> UIImage {
        let contextSize = CGSize(width: size.width - inset * 2.0, height: size.height - inset * 2.0)
        UIGraphicsBeginImageContext(contextSize)
        
        self.draw(at: CGPoint(x: -inset, y: -inset))
        
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return uiImage ?? self
    }
    
    func cropImage(rect: CGRect) -> UIImage {
        let contextSize = CGSize(width: rect.width, height: rect.height)
        UIGraphicsBeginImageContext(contextSize)
        
        self.draw(at: CGPoint(x: -rect.minX, y: -rect.minY))
        
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return uiImage ?? self
    }
    
    func createContentImageOver(content contentImage: UIImage, offset: CGPoint = .zero, scale: CGFloat = 1.0) -> UIImage {
        let contextSize = self.size
        
        let scaledContentImage = self.scaled(image: contentImage, to: CGRect(origin: .zero, size: contextSize))
        let masked = UIImage.maskedImage(image: scaledContentImage, withMask: self)

        UIGraphicsBeginImageContext(contextSize)

        self.draw(at: .zero)

        let scaledWidth = contentImage.size.width * (contextSize.height / contentImage.size.height)
        let scaledHeight = contextSize.height
        
        let newRect = CGRect(origin: CGPoint(x: contextSize.width / 2.0 - scaledWidth / 2.0, y: contextSize.height / 2.0 - scaledHeight / 2.0), size: CGSize(width: scaledWidth, height: scaledHeight))
            .offsetBy(dx: offset.x, dy: offset.y)
            .applying(CGAffineTransform.init(scaleX: scale, y: scale))
        
        masked.draw(in: newRect)
        
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return uiImage ?? self
    }
    
    func scaled(image: UIImage, to rect: CGRect) -> UIImage {
        let contextSize = self.size

        UIGraphicsBeginImageContext(contextSize)

        image.draw(in: rect)

        let uiImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return uiImage ?? self
    }
}

extension UIImage {
    
    class func maskedImage(image: UIImage, withMask mask: UIImage) -> UIImage {
        let alphaInfo: CGImageAlphaInfo = mask.cgImage!.alphaInfo

        if alphaInfo == CGImageAlphaInfo.first || alphaInfo == CGImageAlphaInfo.last || alphaInfo == CGImageAlphaInfo.premultipliedFirst || alphaInfo == CGImageAlphaInfo.premultipliedLast {
            return UIImage.maskedImage(image: image, withAlphaMask: mask)
        }
        else {
            return image//UIImage.maskedImage(image: image, withNonAlphaMask: mask)
        }
    }

    class func maskedImage(color: UIColor, withMask mask: UIImage) -> UIImage {
        let alphaInfo: CGImageAlphaInfo = mask.cgImage!.alphaInfo
        if alphaInfo == CGImageAlphaInfo.first || alphaInfo == CGImageAlphaInfo.last || alphaInfo == CGImageAlphaInfo.premultipliedFirst || alphaInfo == CGImageAlphaInfo.premultipliedLast {
            return UIImage.maskedImage(color: color, withAlphaMask: mask)
        } else {
            return UIImage.maskedImage(color: color, withNonAlphaMask: mask)
        }
    }
    
    
    private class func maskedImage(image: UIImage, withAlphaMask mask: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        image.draw(in: CGRect(x: (mask.size.width - image.size.width) / 2.0, y: (mask.size.height - image.size.height) / 2.0, width: image.size.width, height: image.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let context = CGContext(data: nil, width: mask.cgImage!.width, height: mask.cgImage!.height, bitsPerComponent: 8, bytesPerRow: mask.cgImage!.bytesPerRow/4, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue).rawValue)
        
        context?.draw(mask.cgImage!, in: CGRect(x: 0, y: 0, width: mask.size.width * mask.scale, height: mask.size.height * mask.scale))

        let maskRef = context!.makeImage()!

        let maskedCGImage = iconBackground.cgImage!.masking(maskRef)

        return UIImage(cgImage: maskedCGImage!, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    private class func maskedImage(image: UIImage, withNonAlphaMask mask: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        
        image.draw(in: CGRect(x: (mask.size.width - image.size.width) / 2.0, y: (mask.size.height - image.size.height) / 2.0, width: image.size.width, height: image.size.height))
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let maskRef = CGImage(maskWidth: mask.cgImage!.width, height: mask.cgImage!.height, bitsPerComponent: mask.cgImage!.bitsPerComponent, bitsPerPixel: mask.cgImage!.bitsPerPixel, bytesPerRow: mask.cgImage!.bytesPerRow, provider: mask.cgImage!.dataProvider!, decode: nil, shouldInterpolate: false)!
        
        let masked = iconBackground.cgImage!.masking(maskRef)!
        return UIImage(cgImage: masked, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    private class func maskedImage(color: UIColor, withAlphaMask mask: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        color.setFill()
        
        
        UIRectFill(CGRect(x: 0, y: 0, width: mask.size.width, height: mask.size.height))
        let iconBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let context = CGContext(data: nil, width: mask.cgImage!.width, height: mask.cgImage!.height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue).rawValue)
        
        context?.draw(mask.cgImage!, in: CGRect(x: 0, y: 0, width: mask.size.width * mask.scale, height: mask.size.height * mask.scale))
        
        let maskRef = context!.makeImage()

        let masked = iconBackground.cgImage!.masking(maskRef!)

        return UIImage(cgImage: masked!, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    private class func maskedImage(color: UIColor, withNonAlphaMask mask: UIImage) -> UIImage {
    //First draw the background color into an image
        UIGraphicsBeginImageContextWithOptions(mask.size, false, mask.scale)
        color.setFill()
        
        UIRectFill(CGRect(x: 0, y: 0, width: mask.size.width, height: mask.size.height))
        
        let iconBackground = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        let maskRef = CGImage(maskWidth: mask.cgImage!.width, height: mask.cgImage!.height, bitsPerComponent: mask.cgImage!.bitsPerComponent, bitsPerPixel: mask.cgImage!.bitsPerPixel, bytesPerRow: mask.cgImage!.bytesPerRow, provider: mask.cgImage!.dataProvider!, decode: nil, shouldInterpolate: false)!

        let masked = iconBackground.cgImage!.masking(maskRef)

        return UIImage(cgImage: masked!, scale: mask.scale, orientation: mask.imageOrientation)
    }
    
    public func squareCroppedImage(length:CGFloat) -> UIImage {
        let inputSize = self.size;

        let adjustedLength = ceil(length)

        let outputSize = CGSize(width: adjustedLength, height: adjustedLength)

        let scale = max(adjustedLength / inputSize.width,
                adjustedLength / inputSize.height);

        let scaledInputSize = CGSize(width: inputSize.width * scale,
                                     height: inputSize.height * scale);

        let center = CGPoint(x: outputSize.width/2.0,
                             y: outputSize.height/2.0);

        let outputRect = CGRect(x: center.x - scaledInputSize.width/2.0,
                                y: center.y - scaledInputSize.height/2.0,
                                width: scaledInputSize.width,
                                height: scaledInputSize.height);
        
        UIGraphicsBeginImageContextWithOptions(outputSize, true, 0);
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.interpolationQuality = .high
        
        self.draw(in: outputRect)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
 
    
    func crop(face faceObservation: VNFaceObservation) -> UIImage {
        let normalizedRect = faceObservation.boundingBox
        
        let origin = CGPoint(
            x: normalizedRect.minX * self.size.width,
            y: (1.0 - normalizedRect.maxY) * self.size.height)
        
        let size = CGSize(width: normalizedRect.width * self.size.width,
          height: normalizedRect.height * self.size.height)
        
        let insetHorizontal = -self.size.width * normalizedRect.size.width * 0.5
        let insetVertical = -self.size.height * normalizedRect.size.height * 0.5
        
        let rect = CGRect(origin: origin, size: size)
            .insetBy(dx: insetHorizontal, dy: insetVertical)
        
        let croppedFace = self.cropImage(rect: rect)
        
        return croppedFace
    }
    
}
