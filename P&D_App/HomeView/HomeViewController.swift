//
//  HomeViewController.swift
//  P&D_App
//
//  Created by Azuma on 2018/11/05.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private var loginView: UIView!
    @IBOutlet private weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var keyTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var warningLabel: UILabel!

    private var name: String = ""
    private var key: String = ""
    private var loginViewTopConstraint: NSLayoutConstraint!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.layoutIfNeeded()
    }

    private func initView() {
        bind()
        if isLogin() {

        } else {
            customization()
        }
    }

    private func bind() {
        Observable.combineLatest(nameTextField.rx.text, keyTextField.rx.text)
            .subscribe({ [unowned self] in
                self.loginButton.isEnabled = ($0.element?.0?.isNotEmpty)! && ($0.element?.1?.isNotEmpty)!
            })
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .subscribe({ _ in
//                self.warningLabel.isHidden = false
                KeyChainUtil.shared.set(key: KeyChainKey.name, value: self.nameTextField.text!)
                KeyChainUtil.shared.set(key: KeyChainKey.key, value: self.keyTextField.text!)
                self.performSegue(withIdentifier: "HomeToTabSegue", sender: nil)
            })
            .disposed(by: disposeBag)
    }

    private func customization() {
        logoTopConstraint.priority = UILayoutPriority(rawValue: 1000)
        logoHorizontalConstraint.priority = UILayoutPriority(rawValue: 999)
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.view.insertSubview(self.loginView, belowSubview: self.logoImageView)
            self.loginView.translatesAutoresizingMaskIntoConstraints = false
            self.loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.loginViewTopConstraint = NSLayoutConstraint.init(item: self.loginView, attribute: .top, relatedBy: .equal, toItem: self.logoImageView, attribute: .bottom, multiplier: 1, constant: 40)
            self.loginViewTopConstraint.isActive = true
            self.loginView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
            self.loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
            self.view.layoutIfNeeded()
        })
    }

    private func isLogin() -> Bool {
        return KeyChainUtil.shared.get(key: KeyChainKey.token) != nil ? true : false
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
