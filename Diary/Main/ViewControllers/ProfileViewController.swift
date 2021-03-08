//
//  ProfileViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/21.
//

import UIKit

import Firebase
import CalendarHeatmap
import ReactorKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var calendar: UIDatePicker!
    
    var disposeBag = DisposeBag()
    
    var heatmapList = [String]()
    
    var startDate = ""
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        return refreshControl
    }()
    
//    lazy var data: [String: UIColor] = {
//        guard let data = readHeatmap() else { return [:] }
//        return data.mapValues { (colorIndex) -> UIColor in
//            switch colorIndex {
//            case 0:
//                return UIColor.blue
//            case 1:
//                return UIColor.lightGray
//            case 2:
//                return UIColor.red
//            case 3:
//                return UIColor.red
//            default:
//                return UIColor.red
//            }
//        }
//    }()
    
    lazy var calendarHeatMap: CalendarHeatmap = {
        var config = CalendarHeatmapConfig()
        config.backgroundColor = UIColor.white
        // config item
        config.selectedItemBorderColor = .white
        config.allowItemSelection = true
        // config month header
        config.monthHeight = 20
        config.monthStrings = DateFormatter().shortMonthSymbols
        config.monthFont = UIFont.systemFont(ofSize: 11)
        config.monthColor = UIColor(named: "BarTintColor")!
        // config weekday label on left
        config.weekDayFont = UIFont.systemFont(ofSize: 11)
        config.weekDayWidth = 30
        config.weekDayColor = UIColor(named: "BarTintColor")!
        config.backgroundColor = UIColor.clear
        
        let date = Date()
        let dateForamtter = DateFormatter()
        dateForamtter.locale = Locale(identifier: "ko_KR")
        dateForamtter.timeZone = TimeZone(abbreviation: "UTC")
        dateForamtter.dateFormat = "yyyy.M.d"
        let stDate = dateForamtter.date(from: startDate)
        let stringToDate = dateForamtter.string(from: date)
        let endDate = dateForamtter.date(from: stringToDate)
//        let calendar = CalendarHeatmap(startDate: dateToString!)
        let calendar = CalendarHeatmap(config: config, startDate: stDate!, endDate: endDate!)
        calendar.delegate = self
        calendar.backgroundColor = UIColor.clear
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func readHeatmap() {
        print(debug: startDate)
        calendarHeatMap.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarHeatMap)
        calendarHeatMap.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        calendarHeatMap.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        calendarHeatMap.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        calendarHeatMap.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true
//        guard let url = Bundle.main.url(forResource: "heatmap", withExtension: "plist") else { return nil }
//        return NSDictionary(contentsOf: url) as? [String: Int]
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

extension ProfileViewController: StoryboardView {
    func bind(reactor: ProfileViewReactor) {
        Observable.just(Void())
            .map{ Reactor.Action.fetch(Auth.auth().currentUser?.uid ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent([.valueChanged]).map {
            return Reactor.Action.fetch(Auth.auth().currentUser?.uid ?? "")
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        //state
        reactor.state.asObservable().map { $0 }
            .bind { (data) in
                if data.isLoadingResult {
                    self.startDate = data.startDate
                    self.heatmapList.append(contentsOf: data.list)
                    self.readHeatmap()
                }
            }.disposed(by: disposeBag)
    }
}

extension ProfileViewController: CalendarHeatmapDelegate {
    func finishLoadCalendar() {
        calendarHeatMap.scrollTo(date: Date(), at: .right, animated: false)
    }
    
    func colorFor(dateComponents: DateComponents) -> UIColor {
        
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day else { return .clear}
        let dateString = "\(year).\(month).\(day)"
        return heatmapList.contains(dateString) ? UIColor.systemGreen : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
//        return data[dateString] ?? UIColor.lightGray
    }
}
