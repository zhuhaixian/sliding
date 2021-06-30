//
//  ISSlidingCodeView.swift
//  ISSlidingCode
//
//  Created by 朱海先 on 2021/1/15.
//

import UIKit

private let ScreenW = UIScreen.main.bounds.width
private let ScreenH = UIScreen.main.bounds.height
private let kscale = (UIScreen.main.bounds.width/375)
private let kShowW = ScreenW - 35*kscale
private let kShowH = 315*kscale


//MARK: - 事件声明
public typealias SlidingCodeViewCallBack = ((Bool) -> ())
// MARK:-- 根据rgb获取颜色
func RGBCOLOR(r:CGFloat,g:CGFloat,b:CGFloat,a : CGFloat = 1.0) -> UIColor {
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}

class ISSlidingCodeView: UIView {
    // MARK:-- 随机属性
   fileprivate  var random : CGPoint { get {  CGPoint(x: CGFloat(arc4random_uniform(UInt32((kShowW - 40*kscale)/2 - 40*kscale)) + UInt32( (kShowW - 40*kscale)/2 )), y: CGFloat(arc4random_uniform(90) + 50)) }}
    
    
   fileprivate var imageName : String { get{ "sliding_" + "\(Int(arc4random_uniform(5) + 1))" }}
    /// 滑动时 保留原始位置
    private var originSlidingX: CGFloat = 0
    // MARK:-- view
    fileprivate lazy var showView : UIView = {
        let showView = UIView(frame: CGRect(x: 15*kscale, y: 10*kscale, width: kShowW, height: kShowH))
        showView.center = CGPoint(x: ScreenW/2, y: ScreenH/2)
        showView.layer.cornerRadius = 5
        showView.backgroundColor = UIColor.white
        return showView
    }()
    // MARK:-- 背景图片
    fileprivate lazy var bgImgView : UIImageView = {
        let bgImgView = UIImageView(frame: CGRect(x: 20*kscale, y: 55*kscale, width: kShowW - 40*kscale, height: 170*kscale))
       
        bgImgView.image = UIImage.init(named: imageName)
        
        return bgImgView
    }()
   fileprivate  var resultLabel : UILabel = UILabel()
    // MARK:-- 滑动背景
    fileprivate lazy var slidingView : UIView = {
        let slidingView = UIView(frame: CGRect(x: 20*kscale, y: 235*kscale, width: kShowW - 40*kscale, height: 60*kscale))
        slidingView.backgroundColor = UIColor.white
        return slidingView
    }()
    
    // MARK:-- 滑动图片
    fileprivate var startIView : UIImageView = UIImageView()
    // MARK:-- 滑块view
    fileprivate var startView : UIView = UIView()
    // MARK:-- 滑过的view
    fileprivate var currentSlidingView : UIView = UIView()
    // MARK:-- 开始图片
    fileprivate var startImgView : UIImageView = UIImageView()
    // MARK:-- 终点图片
    fileprivate var endImgView : UIImageView = UIImageView()
  @objc  override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH))
        self.backgroundColor = RGBCOLOR(r: 0, g: 0, b: 0, a: 0.3)
        setupUI()
    }
    /// 结束事件回调
    @objc public var callBack: SlidingCodeViewCallBack?
    /// 事件回调
    @objc func setCallBackHandle(_ callBack: SlidingCodeViewCallBack?) {
        self.callBack = callBack
    }
    @objc func dismiss() {
        self.removeFromSuperview()
    }
   @objc func showAlert(_ onView : UIView? = nil) {
        if onView == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
        }else{
            onView?.addSubview(self)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:-- 点击空白消失
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let totalpoint = touches.first?.location(in: self) else { return }
//        let point = self.showView.layer.convert(totalpoint, from: self.layer)
//        if !self.showView.layer.contains(point) {
//            self.removeFromSuperview()
//        }
//    }
}

// MARK:-- 事件
extension ISSlidingCodeView {
    @objc private func panGesture(tapGes : UIPanGestureRecognizer) {
        
        // MARK:--获取偏移量
        let point = tapGes.translation(in: tapGes.view)
        if tapGes.state == .began{
            originSlidingX = self.startView.frame.origin.x
        }else if tapGes.state == .changed {
            self.startView.center.x = min(max(30*kscale, 30*kscale + point.x), kShowW - 60*kscale)
            // MARK:--滑过的宽度
            self.currentSlidingView.frame.size.width = min(max(30*kscale, 30*kscale + point.x), kShowW - 50*kscale)
            
            self.startImgView.center.x = self.startView.center.x
            
        }else {
            // MARK:-- 结束 或者 取消滑动
            if self.startImgView.center.x >= (self.endImgView.center.x - 8) && self.startImgView.center.x <= (self.endImgView.center.x + 8) {
                print("成功")
                self.startView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.3) {
                    self.startIView.image = UIImage.init(named: "sliding_success")
                    self.startView.layer.borderColor = UIColor.init(make_hexString: "80D59D").cgColor
                    
                    self.resultLabel.isHidden = false
                    self.resultLabel.text = "验证成功！"
                    self.resultLabel.backgroundColor = UIColor.init(make_hexString: "57AD40")
                }
                self.callBack?(true)
            }else{
                print("结束")
                UIView.animate(withDuration: 0.3) {
                self.startIView.image = UIImage.init(named: "sliding_error")
                    self.startView.layer.borderColor = UIColor.init(make_hexString: "EA645E").cgColor
                    
                    self.resultLabel.isHidden = false
                    self.resultLabel.text = "验证失败！"
                    self.resultLabel.backgroundColor = UIColor.init(make_hexString: "D76965")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                        self.refreshSlidingData()
                    }
                }
            }
        }
    }
    // MARK:-- 回到起点
    fileprivate func returntostart() {
        UIView.animate(withDuration: 0.2) {
            self.startView.isUserInteractionEnabled = true
            self.startIView.image = UIImage.init(named: "sliding_start")
            self.startView.frame.origin.x = 0
            self.startView.layer.borderColor = UIColor.gray.cgColor
            
            self.currentSlidingView.frame.size.width = 30*kscale
            self.startImgView.center.x = self.startView.center.x
            self.resultLabel.isHidden = true
            
            
        }
    }
    // MARK:-- 刷新
    @objc fileprivate func refreshSlidingData(){
        // MARK:-- 刷新数据
        print(imageName)
        self.bgImgView.image = UIImage.init(named: imageName)
        
        returntostart()
        
        self.endImgView.center = CGPoint(x: random.x, y: random.y)
        self.startImgView.center = CGPoint(x: self.startView.center.x, y: endImgView.center.y)
    }
    @objc fileprivate  func closeSliding() {
        self.removeFromSuperview()
    }
    
}

// MARK:-- UI
extension ISSlidingCodeView {
    private  func setupUI() {
        self.addSubview(showView)
        
        setupHeaderUI()
        
        showView.addSubview(bgImgView)
        showView.addSubview(slidingView)
        setupSlidingUI()
        setupImgViewUI()
    }
    func setupHeaderUI() {
        let headerView = UIView(frame: CGRect(x: 20*kscale, y: 10*kscale, width: kShowW - 40*kscale, height: 35*kscale))
        headerView.backgroundColor = UIColor.white
        showView.addSubview(headerView)
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 180*kscale, height: 35*kscale))
        headerLabel.text = "请完成下方拼图验证"
        headerLabel.font = UIFont.systemFont(ofSize: 16*kscale)
        headerLabel.textColor = UIColor.init(make_hexString: "333333")
        headerView.addSubview(headerLabel)
        
        let refreshBtn = UIButton(frame: CGRect(x: kShowW - 40*kscale - 55*kscale, y: 7.5*kscale, width: 20*kscale, height: 20*kscale))
        refreshBtn.setImage(UIImage.init(named: "sliding_refresh"), for: .normal)
        refreshBtn.addTarget(self, action: #selector(self.refreshSlidingData), for: .touchUpInside)
        headerView.addSubview(refreshBtn)
        
        let closeBtn = UIButton(frame: CGRect(x: kShowW - 40*kscale - 20*kscale, y: 7.5*kscale, width: 20*kscale, height: 20*kscale))
        closeBtn.setImage(UIImage.init(named: "sliding_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(self.closeSliding), for: .touchUpInside)
        headerView.addSubview(closeBtn)
        
    }
    private  func setupSlidingUI() {
        let label = UILabel(frame: CGRect(x: 0, y: 10*kscale, width: kShowW - 40*kscale, height: 40*kscale))
        label.text = "请按住滑块拖动完成拼图"
        label.font = UIFont.systemFont(ofSize: 15*kscale)
        label.textColor = UIColor.init(make_hexString: "989898")
        label.backgroundColor = UIColor.init(make_hexString: "DFE0E1")
        label.textAlignment = .center
        label.layer.cornerRadius = 20*kscale
        label.clipsToBounds = true
        slidingView.addSubview(label)
        
        let currentSlidingView = UIView(frame: CGRect(x: 0, y: 10*kscale, width: 30*kscale, height: 40*kscale))
        currentSlidingView.backgroundColor = UIColor.init(make_hexString: "DFE0E1")
        currentSlidingView.layer.cornerRadius = 20*kscale
        currentSlidingView.clipsToBounds = true
        slidingView.addSubview(currentSlidingView)
        self.currentSlidingView = currentSlidingView
        
        // MARK:-- 滑动view
        let startView = UIView(frame: CGRect(x: 0, y: 0, width: 60*kscale, height: 60*kscale))
        startView.backgroundColor = UIColor.white
        startView.layer.borderWidth = 1
        startView.layer.borderColor = UIColor.gray.cgColor
        startView.layer.cornerRadius = 30*kscale
        slidingView.addSubview(startView)
        self.startView = startView
        
        let startIView = UIImageView(frame: CGRect(x: 17.5*kscale, y: 17.5*kscale, width: 25*kscale, height: 25*kscale))
        startIView.image = UIImage.init(named: "sliding_start")
        startView.addSubview(startIView)
        self.startIView = startIView
        
        // MARK:-- 添加事件
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(tapGes:)))
        startView.addGestureRecognizer(panGesture)
    }
    private func setupImgViewUI() {
        
        let startImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        startImgView.image = UIImage.init(named: "start_sliding_icon")
        startImgView.center = CGPoint(x: self.startView.center.x, y: 30*kscale)
        self.bgImgView.addSubview(startImgView)
        self.startImgView = startImgView
        
        let endImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        endImgView.image = UIImage.init(named: "end_sliding_icon")
        self.bgImgView.addSubview(endImgView)
        self.endImgView = endImgView
        
        resultLabel = UILabel(frame: CGRect(x: 0, y: 140*kscale, width: kShowW - 40*kscale, height: 30*kscale))
        resultLabel.backgroundColor = UIColor.green
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 14*kscale)
        resultLabel.isHidden = true
        resultLabel.textColor = UIColor.white
        self.bgImgView.addSubview(resultLabel)
        
        self.endImgView.center = CGPoint(x: random.x, y: random.y)
        self.startImgView.center = CGPoint(x: self.startView.center.x , y: endImgView.center.y)
        return
    }
}



extension UIColor {
    convenience init(make_hexString hexString: String, alpha: Double = 1.0) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(255 * alpha) / 255)
    }
}
