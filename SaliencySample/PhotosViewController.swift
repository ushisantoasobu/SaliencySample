//
//  PhotosViewController.swift
//  SaliencySample
//
//  Created by Shunsuke Sato on 2020/11/23.
//

import UIKit
import Vision

class PhotosViewController: UIViewController {

    let originalList = [
        Photo(image: UIImage(named: "sample1")!),
        Photo(image: UIImage(named: "sample2")!),
        Photo(image: UIImage(named: "sample3")!),
        Photo(image: UIImage(named: "sample4")!),
        Photo(image: UIImage(named: "sample5")!),
        Photo(image: UIImage(named: "sample6")!),
        Photo(image: UIImage(named: "sample7")!),
        Photo(image: UIImage(named: "sample8")!),
        Photo(image: UIImage(named: "sample9")!),
        Photo(image: UIImage(named: "sample101")!),
        Photo(image: UIImage(named: "sample102")!),
        Photo(image: UIImage(named: "sample103")!),
    ]

    let appliedList = [
        Photo(image: UIImage(named: "sample1")!),
        Photo(image: UIImage(named: "sample2")!),
        Photo(image: UIImage(named: "sample3")!),
        Photo(image: UIImage(named: "sample4")!),
        Photo(image: UIImage(named: "sample5")!),
        Photo(image: UIImage(named: "sample6")!),
        Photo(image: UIImage(named: "sample7")!),
        Photo(image: UIImage(named: "sample8")!),
        Photo(image: UIImage(named: "sample9")!),
        Photo(image: UIImage(named: "sample101")!),
        Photo(image: UIImage(named: "sample102")!),
        Photo(image: UIImage(named: "sample103")!),
    ]

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!

    override func viewDidLoad() {
        super.viewDidLoad()

//        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "myCell")
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        setData()
    }

    private func createLayout() -> UICollectionViewLayout {
        let baseSize = CGFloat(1.0 / 3.0)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(baseSize),
                                              heightDimension: .fractionalWidth (baseSize))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(baseSize))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: collectionView) { (cv, indexPath, p) -> UICollectionViewCell? in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! MyCollectionViewCell
            if indexPath.section == 0 {
                cell.imageView.image = p.image
                cell.imageView.contentMode = .scaleAspectFill
            } else if indexPath.section == 1 {
                let image = p.image
                let saliencyRect = self.getSaliency(image: image)
                var rect = self.calculateRect(rect: saliencyRect, of: image)
                rect = CropAdjuster().execute(rect: rect, image: image)
                rect = self.applyScale(rect: rect, of: image)

                let croppedCgImage = image.cgImage!.cropping(to: rect)
                let croppedImage = UIImage(cgImage: croppedCgImage!,
                                           scale: image.scale,
                                           orientation: image.imageOrientation)
                cell.imageView.image = croppedImage
            } else {
                fatalError()
            }
            return cell
        }
    }

    private func setData() {
        var snapShot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapShot.appendSections([.original, .adjusted])
        snapShot.appendItems(originalList, toSection: .original)
        snapShot.appendItems(appliedList, toSection: .adjusted)

        dataSource.apply(snapShot,
                         animatingDifferences: false,
                         completion: nil)
    }

    private func getSaliency(image: UIImage) -> CGRect {
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

        guard let objects = observation.salientObjects else { fatalError() }
        return objects.first!.boundingBox
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

enum Section {
    case original
    case adjusted
}

struct Photo: Hashable {
    let id: String = UUID().uuidString
    let image: UIImage
}

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
}
