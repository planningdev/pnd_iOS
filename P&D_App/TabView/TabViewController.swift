//
//  TabViewController.swift
//  P&D_App
//
//  Created by Azuma on 2018/11/05.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabViewController: UITabBarController {

    private let disposeBag = DisposeBag()
    private let url = URL(string: "")

    var button: UIButton {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Open"), for: .normal)
        button.sizeToFit()
        button.center = CGPoint(x: tabBar.bounds.size.width/2, y: tabBar.bounds.size.height - (button.bounds.size.height/2))
        button.rx.tap
            .subscribe({ [unowned self] _ in
                URLSession.shared.dataTask(with: self.url!, completionHandler: { (data, _, error) in
                    print(error ?? "no error")
                }).resume()
            })
            .disposed(by: disposeBag)
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tabBar.addSubview(button)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
