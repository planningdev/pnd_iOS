//
//  CalendarViewController.swift
//  P&D_App
//
//  Created by Azuma on 2018/11/05.
//  Copyright © 2018 P&D. All rights reserved.
//

import UIKit
import JTAppleCalendar
import RxSwift
import RxCocoa
import SwiftDate

class CalendarViewController: UIViewController {

    @IBOutlet private weak var calendarView: JTAppleCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.title = "\(Date().year)年 " + "\(Date().month)月"
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

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.navigationItem.title = "\(visibleDates.monthDates[10].date.year)年 " + "\(visibleDates.monthDates[10].date.month)月"
    }

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date()
        let endDate = Date() + 1.years
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid, firstDayOfWeek: .sunday)

        return parameters
    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
        cell.dayLabel.text = String(date.day)
        return cell
    }


}
