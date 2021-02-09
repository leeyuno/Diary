//
//  UploadViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import ReactorKit
import RxSwift

class UploadViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var emotionButton: UIImageView!
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
    
    func upload() {
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(debug: info)
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(debug: selectedImage)
            imageView.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
