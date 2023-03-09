//
//  ViewController.swift
//  testDemo
//
//  Created by Ray on 2023/3/2.
//

import UIKit
class LuckyVGTool: NSObject {

    static func getLuckyCoinAttributedString(with win_coin: Int , font: UIFont) -> NSMutableAttributedString? {
        if let iconImg = UIImage.init(named: "LuckyVG_icon_coin") {
            let attachment = NSTextAttachment.init(image: iconImg)
            let rate = font.pointSize / 14
            let imgHeight: CGFloat = rate * iconImg.size.height / 2
            let offsetY = rate * (-1.4)
            let width: CGFloat = rate * iconImg.size.width / 2
            attachment.bounds = CGRect.init(x: 0, y: offsetY, width: width, height: imgHeight)
            let imgAttri = NSMutableAttributedString(attachment: attachment)
            imgAttri.append(NSAttributedString.init(string: " \(win_coin)"))
            return imgAttri
        }
        
        return nil
    }
    
}
class ViewController: UIViewController {

    @IBOutlet weak var textlabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        fontSize 14
        
        
        self.textlabel.attributedText = LuckyVGTool.getLuckyCoinAttributedString(with: 1000, font: self.textlabel.font)
    }


}

