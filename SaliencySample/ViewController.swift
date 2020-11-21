//
//  ViewController.swift
//  SaliencySample
//
//  Created by Shunsuke Sato on 2020/11/21.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var squareImageView: UIImageView!
    @IBOutlet weak var wholeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        wholeImageView.image = #imageLiteral(resourceName: "sample1")

        some()
    }

    private func some() {
        print("start")
        let image = #imageLiteral(resourceName: "sample1")
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request: VNImageBasedRequest = VNGenerateAttentionBasedSaliencyImageRequest()
        request.revision = VNGenerateAttentionBasedSaliencyImageRequestRevision1

        try? handler.perform([request])
        guard
            let result = request.results?.first,
            let observation = result as? VNSaliencyImageObservation
        else {
            fatalError("missing result")
        }

        guard let objects = observation.salientObjects else { return }
        for object in objects {
            print(object.boundingBox)
        }
    }

    
}

