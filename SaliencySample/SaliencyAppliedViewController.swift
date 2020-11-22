//
//  SaliencyAppliedViewController.swift
//  SaliencySample
//
//  Created by Shunsuke Sato on 2020/11/22.
//

import UIKit

class SaliencyAppliedViewController: UIViewController {

    var image: UIImage!
    var saliencyRect: CGRect!

    @IBOutlet weak var imageView: UIImageView!

    static func instantiate(
        image: UIImage,
        saliencyRect: CGRect
    ) -> SaliencyAppliedViewController {
        let sb = UIStoryboard(name: "SaliencyAppliedViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! SaliencyAppliedViewController
        vc.image = image
        vc.saliencyRect = saliencyRect
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let rect = calculateRect(rect: saliencyRect, of: image)
        let croppedCgImage = image.cgImage!.cropping(to: rect)
        let croppedImage = UIImage(cgImage: croppedCgImage!,
                                   scale: image.scale,
                                   orientation: image.imageOrientation)
        imageView.image = croppedImage
    }

    private func calculateRect(rect: CGRect, of image: UIImage) -> CGRect {
        // Visionフレームワークが返すSaliencyのcropは「左下」が原点なのでその分を調整する
        return CGRect(x: rect.origin.x * image.size.width * image.scale,
                      y: ((1 - rect.origin.y) * image.size.height - rect.height * image.size.height) * image.scale,
                      width: rect.width * image.size.width * image.scale,
                      height: rect.height * image.size.height * image.scale)
    }
}
