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

        var rect = calculateRect(rect: saliencyRect, of: image)
        rect = CropAdjuster().execute(rect: rect, image: image)
        rect = applyScale(rect: rect, of: image)

        let croppedCgImage = image.cgImage!.cropping(to: rect)
        let croppedImage = UIImage(cgImage: croppedCgImage!,
                                   scale: image.scale,
                                   orientation: image.imageOrientation)
        imageView.image = croppedImage
    }

    private func calculateRect(rect: CGRect, of image: UIImage) -> CGRect {
        // Visionフレームワークが返すSaliencyのcropは「左下」が原点なのでその分を調整する
        return CGRect(x: rect.origin.x * image.size.width,
                      y: (1 - rect.origin.y) * image.size.height - rect.height * image.size.height,
                      width: rect.width * image.size.width,
                      height: rect.height * image.size.height)
    }

    private func applyScale(rect: CGRect, of image: UIImage) -> CGRect {
        return CGRect(x: rect.origin.x * image.scale,
                      y: rect.origin.y * image.scale,
                      width: rect.width * image.scale,
                      height: rect.height * image.scale)
    }
}

struct CropAdjuster {

    enum Side {
        case left
        case top
        case right
        case bottom
    }

    /*
     シンプルなアルゴリズムで実装
     - 一旦正方形になるようにする
     - 画像の70%まで大きくする
     - マイナスになっていたり画像サイズを飛び出してしまう場合は調整する
     */
    func execute(rect: CGRect, image: UIImage) -> CGRect {
        let center = CGPoint(x: rect.origin.x + rect.size.width / 2,
                             y: rect.origin.y + rect.size.height / 2)
        let maxSize = max(rect.size.width, rect.size.height)
        let minImageSize = min(image.size.width, image.size.height)
        let scaledSize = max(maxSize, minImageSize * 0.8)
        let newRect = CGRect(x: center.x - scaledSize / 2,
                             y: center.y - scaledSize / 2,
                             width: scaledSize,
                             height: scaledSize)

        let invalids = validate(rect: newRect, image: image)
        print(invalids.count)
        switch invalids.count {
        case 0:
            return newRect
        case 3, 4:
            return CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        case 1, 2:
            return rectForSlide(sides: invalids, rect: newRect, image: image)
        default:
            fatalError()
        }
    }

    private func validate(rect: CGRect, image: UIImage) -> [Side] {
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        var invalids: [Side] = []
        if rect.origin.x < 0 {
            invalids.append(.left)
        }
        if rect.origin.y < 0 {
            invalids.append(.top)
        }
        if rect.origin.x > imageWidth {
            invalids.append(.right)
        }
        if rect.origin.y > imageHeight {
            invalids.append(.bottom)
        }
        return invalids
    }

    private func rectForSlide(sides: [Side], rect: CGRect, image: UIImage) -> CGRect {
        var newRect = rect
        sides.forEach { side in
            newRect = slide(side: side, rect: newRect, image: image)
        }
        return newRect
    }

    private func slide(side: Side, rect: CGRect, image: UIImage) -> CGRect {
        switch side {
        case .left:
            let diff = 0 - rect.origin.x
            if diff < 0 { return rect }
            return CGRect(x: 0, y: rect.origin.y, width: rect.width, height: rect.height)
        case .top:
            let diff = 0 - rect.origin.y
            if diff < 0 { return rect }
            return CGRect(x: rect.origin.x, y: 0, width: rect.width, height: rect.height)
        case .right:
            let diff = (rect.origin.x + rect.width) - image.size.width
            if diff < 0 { return rect }
            return CGRect(x: rect.origin.x - diff, y: rect.origin.y, width: rect.width, height: rect.height)
        case .bottom:
            let diff = (rect.origin.y + rect.height) - image.size.height
            if diff < 0 { return rect }
            return CGRect(x: rect.origin.x, y: rect.origin.y - diff, width: rect.width, height: rect.height)
        }
    }
}
