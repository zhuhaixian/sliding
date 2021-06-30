//
//  ViewController.swift
//  ISSlidingCode
//
//  Created by 朱海先 on 2021/1/15.
//

import UIKit
class ViewController: UIViewController {

    var imgView : UIImageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        label.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        label.text = "点击空白出效果"
        label.textColor = .red
        view.addSubview(label)
        
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let slidingView = ISSlidingCodeView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        slidingView.setCallBackHandle { (res) in
            print(res)
        }
        slidingView.showAlert()
    }

}

