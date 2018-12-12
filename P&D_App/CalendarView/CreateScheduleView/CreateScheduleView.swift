//
//  CreateScheduleView.swift
//  P&D_App
//
//  Created by 陰山賢太 on 2018/12/12.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit
import Eureka

class CreateScheduleViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form
            +++ Section("")
            <<< TextRow(){ row in
                row.title = "タイトル"
                row.placeholder = "Enter title here"
            }
            <<< TextRow(){ row in
                row.title = "場所"
                row.placeholder = "Enter place here"
            }
            +++ Section("時間")
            <<< SwitchRow(){
                $0.title = "終日"
            }
            <<< DateRow(){
                $0.title = "開始"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)

            }
            <<< DateRow(){
                $0.title = "終了"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section("メモ")
            <<< TextAreaRow(){
                $0.placeholder = "memo"
        }
    }
}
