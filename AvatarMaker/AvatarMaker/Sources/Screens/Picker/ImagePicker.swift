//
//  ImagePicker.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 14.04.2022.
//

import SwiftUI
import Vision
import CoreMedia
import CoreImage

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let cgImage = uiImage.fixedOrientation?.cgImage {
                    DispatchQueue.global().async {
                        let request = VNDetectFaceLandmarksRequest()
                        let handler = VNImageRequestHandler(cgImage: cgImage)

                        try? handler.perform([request])
                        #if targetEnvironment(simulator)
                            DispatchQueue.main.async {
                                self.parent.selectedImage = uiImage
                                self.parent.presentationMode.wrappedValue.dismiss()
                            }
                        #else
                            if let results = request.results {
                                if results.count > 1 {
                                    let viewModel = FacesPickerViewModel(image: uiImage, faces: results) { [weak self] uiImage in
                                        DispatchQueue.main.async {
                                            self?.parent.selectedImage = uiImage
                                            self?.parent.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        let facesViewControlle = UIHostingController(rootView: FacesPickerView().environmentObject(viewModel))
                                        picker.pushViewController(facesViewControlle, animated: true)
                                    }
                                }
                                else if let result = results.first {
                                    let croppedFace = uiImage.crop(face: result)
                                    DispatchQueue.main.async {
                                        self.parent.selectedImage = croppedFace
                                        self.parent.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                else {
                                    DispatchQueue.main.async {
                                        self.parent.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.parent.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        #endif
                    }
                }
                else {
                    parent.presentationMode.wrappedValue.dismiss()
                }
            }
            else {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }

    }
}
