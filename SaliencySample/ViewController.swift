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
    var saliencyBoundingBox: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()

        squareImageView.image = #imageLiteral(resourceName: "sample1")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        drawSquareForSaliency()
    }

    private func drawSquareForSaliency() {
        let image = squareImageView.image
        let handler = VNImageRequestHandler(cgImage: image!.cgImage!, options: [:])
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
            let rect = calculateRect(rect: object.boundingBox, in: squareImageView)
            print(rect)
            drawLine(rect: rect, in: squareImageView)
            saliencyBoundingBox = object.boundingBox
        }
    }

    @IBAction func buttonTapped(_ sender: Any) {
        guard let boundingBox = saliencyBoundingBox else { return }
        let vc = SaliencyAppliedViewController.instantiate(image: squareImageView.image!, saliencyRect: boundingBox)
        present(vc, animated: true, completion: nil)
    }

    private func drawLine(rect: CGRect, in imageView: UIImageView) {
        let layer = CAShapeLayer()
        layer.frame = imageView.bounds

        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = 2


        let line = UIBezierPath();
        line.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        line.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))

        line.move(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
        line.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))

        line.move(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
        line.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height));

        line.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
        line.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y));

        layer.path = line.cgPath

        imageView.layer.addSublayer(layer)
    }

    private func calculateRect(rect: CGRect, in imageView: UIImageView) -> CGRect {
        // Visionフレームワークが返すSaliencyのcropは「左下」が原点なのでその分を調整する
        return CGRect(x: rect.origin.x * imageView.frame.width,
                      y: (1 - rect.origin.y) * imageView.frame.height - rect.height * imageView.frame.height,
                      width: rect.width * imageView.frame.width,
                      height: rect.height * imageView.frame.height)
    }
}

