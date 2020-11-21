//
//  ViewController.swift
//  SaliencySample
//
//  Created by Shunsuke Sato on 2020/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = #imageLiteral(resourceName: "sample1")
    }
}

