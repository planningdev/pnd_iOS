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
        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
            }
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
            +++ Section("Section2")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
        }
    }
}
