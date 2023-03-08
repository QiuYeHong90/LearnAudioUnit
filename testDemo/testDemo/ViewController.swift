//
//  ViewController.swift
//  testDemo
//
//  Created by Ray on 2023/3/2.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textlabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        fontSize 14
        if let iconImg = UIImage.init(named: "LuckyVG_icon_coin") {
            let attachment = NSTextAttachment.init(image: iconImg)
            let rate = self.textlabel.font.pointSize / 14
            let imgHeight: CGFloat = rate * 17.5
            print("self.textlabel.font.lineHeight == \(self.textlabel.font.lineHeight)")
            var lineHeight = self.textlabel.font.lineHeight - imgHeight
            
            let offsetY = rate * (-4.8)
            let width: CGFloat = rate * 15.5
            attachment.bounds = CGRect.init(x: 0, y: offsetY, width: width, height: imgHeight)
            let imgAttri = NSMutableAttributedString(attachment: attachment)
            imgAttri.append(NSAttributedString.init(string: "50"))
            self.textlabel.attributedText = imgAttri
        }
    }


}

