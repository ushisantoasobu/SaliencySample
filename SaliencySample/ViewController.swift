//
//  ViewController.swift
//  SaliencySample
//
//  Created by Shunsuke Sato on 2020/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var squareImageView: UIImageView!
    @IBOutlet weak var wholeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        wholeImageView.image = #imageLiteral(resourceName: "sample1")
    }
}

