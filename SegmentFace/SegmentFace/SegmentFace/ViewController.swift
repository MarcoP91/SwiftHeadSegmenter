//
//  ViewController.swift
//  SegmentFace
//
//  Created by Marco Perotti on 09/02/21.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "person.fill")
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .black
        return img
    }()
    
    let segmentedDrawingView: DrawingSegmentationView = {
        let img = DrawingSegmentationView()
        img.backgroundColor = .clear
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    let startSegmentationButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(handleStartSegmentationButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 5
        btn.tintColor = .white
        btn.layer.masksToBounds = true
        btn.setTitle("Begin", for: .normal)
        btn.isHidden = false
        return btn
        
    }()
    
    
    let photoButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(handleCameraButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 5
        btn.tintColor = .white
        btn.layer.masksToBounds = true
        btn.setTitle("Choose photo", for: .normal)
        btn.isHidden = false
        return btn
        
    }()
    
    let imageSaver = SaveImage()
    
    let imagePickerController = UIImagePickerController()
    var imageSegmentationModel = try! modelSeg()

    var request : VNCoreMLRequest?
    
    var imageURL : URL?
    var imageName : String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.title = "Image Segmentation"
        imagePickerController.delegate = self
        setupViews()
        layoutViews()
        setUpModel()
    }
    
    func setupViews() {
        view.addSubview(imageView)
        view.addSubview(segmentedDrawingView)
        view.addSubview(startSegmentationButton)
        view.addSubview(photoButton)
    }
    
    func layoutViews() {
        view.bringSubviewToFront(segmentedDrawingView)
        segmentedDrawingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedDrawingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        segmentedDrawingView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        segmentedDrawingView.widthAnchor.constraint(equalToConstant: 300).isActive = true

        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true

        startSegmentationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 260).isActive = true
        startSegmentationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        startSegmentationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        startSegmentationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        photoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 190).isActive = true
        photoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        photoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

    }
    
    func predict(with url: URL){
        DispatchQueue.global(qos: .userInitiated).async {
            guard let request = self.request else {fatalError()}
            
            let handler = VNImageRequestHandler(url: url, options: [:])
            
            do {
                //pass to the handler all the Vision requests (even just one)
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    
    func visionRequestDidComplete(request: VNRequest, error: Error?){
        DispatchQueue.main.async { [self] in
            //get the results
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                self.segmentedDrawingView.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)

                self.startSegmentationButton.setTitle("Done", for: .normal)
                
                self.imageSaver.removeBackground(image:imageView.image!, imageName: self.imageName!, modelPrediction:segmentationmap)
                
            }
        }
        
        
    }
    
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: imageSegmentationModel.model){
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }
    
    //this will be called once an image from the gallery is selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage,
           let url = info[.imageURL] as? URL {
            imageView.image = image
            self.imageURL = url
            self.imageName = url.lastPathComponent
            self.startSegmentationButton.isHidden = false
        }

        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func handleCameraButtonTapped() {
        self.present(imagePickerController, animated: true, completion: nil)
        self.segmentedDrawingView.segmentationmap = nil
        self.imageView.image = UIImage(systemName: "person.fill")
        self.startSegmentationButton.isHidden = true
        self.startSegmentationButton.setTitle("Begin", for: .normal)
        
    }
    
    
    func sizeOfImageAt(url: URL) -> CGSize? {
            // with CGImageSource we avoid loading the whole image into memory
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                return nil
            }

            let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
                return nil
            }

            if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
                let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
                return CGSize(width: width, height: height)
            } else {
                return nil
            }
        }


    
    @objc func handleStartSegmentationButton() {
        self.startSegmentationButton.setTitle("In Progress...", for: .normal)
        guard let url = self.imageURL else {return}

        let s : CGSize
        s = sizeOfImageAt(url: url)!
        print("Image size: \(s)")
        self.predict(with: url)
    }
        
        
    

}


    
