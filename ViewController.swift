//
//  ViewController.swift
//  healthkitpj
//
//  Created by 서혜지 on 2020/11/25.
//

import UIKit
import HealthKit
import Firebase


class ViewController: UIViewController,UITextFieldDelegate {

    let healthKitStore = HKHealthStore()
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var DataSend: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    

    @IBOutlet weak var dataTypeLabel: UILabel!
   
    
    @IBOutlet weak var userName: UITextField!
    
    var heartresult = ""
    var stepresult = ""
    var username = ""
//    let names = [
//    "심박수","걸음","체중","밀기","신장","보행속도","체온","오른층계","호흡수","휴식기 심박수","계단 올라가기 속도","계단 내려가기 속도","보폭","활동에너지","노력성폐활량","걷기+달리기 평균","헤드폰 오디오 레벨"
//    ]
    let names = ["심박수","걸음수"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authorizeHealthKitinApp()
        // Do any additional setup after loading the view.
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.preferredDatePickerStyle = .compact
        tableView.delegate = self
        tableView.dataSource = self
        FirebaseApp.configure()
        self.username = self.userName.text!
        userName.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            textField.resignFirstResponder()

            return true

        }
    
    
   
    let alert = UIAlertController(title: "경고", message: "사용자이름을 입력해주세요!", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    let alert1 = UIAlertController(title: "경고", message: "데이터종류를 선택해주세요!", preferredStyle: .alert)
    let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    let alert2 = UIAlertController(title: "경고", message: "검색날짜를 선택해주세요!", preferredStyle: .alert)
    let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    @IBAction func Data_SendBtn(_ sender: UIButton) {
        
        
        self.username = self.userName.text!
        
//        if self.userName.text! == ""{
//            alert.addAction(action)
//            present(alert, animated: true, completion: nil)
//
//        }else
        
        if self.startDateLabel.text == "검색일"{
            alert2.addAction(action2)
            present(alert2, animated: true, completion: nil)
        }else if self.dataTypeLabel.text == "데이터종류"{
            alert1.addAction(action1)
            present(alert1, animated: true, completion: nil)
        }else{
            if let receiveViewController = self.storyboard?.instantiateViewController(identifier: "DetailController") as? DetailController{
                
                    
                    receiveViewController.userName = self.userName.text!
                    receiveViewController.startDate = self.startDateLabel.text
                    receiveViewController.dataType = self.dataTypeLabel.text
                    
                    if self.dataTypeLabel.text == "심박수"{
                            receiveViewController.data = self.heartresult
                        
                    }else if self.dataTypeLabel.text == "걸음수"{
                        receiveViewController.data = self.stepresult
                        
                    }
                self.navigationController?.pushViewController(receiveViewController, animated: true)
              
            }
        }
   
        
        
      
        print("click...")
        

    }
    
    @IBAction func startvalueChanged(_ sender: UIDatePicker) {
       
        startDateLabel?.text =  "\(sender.date.getDayMonthYearMinuteSecond().year)-\(sender.date.getDayMonthYearMinuteSecond().month)-\( String(format:"%02d", sender.date.getDayMonthYearMinuteSecond().day))"
        
        self.latestHeartRate()
        self.getTodayTotalStepCounts()
    }

    
        func authorizeHealthKitinApp()
        {
            let healthKitTypesToRead : Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                
            ]
            let healthKitTypesToWrite : Set<HKSampleType> = [
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                
            ]
    
            if !HKHealthStore.isHealthDataAvailable(){
                print("error occured")
                return
            }
            healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead)
            {
                (success, error) -> Void in
                print("Read and Write Authourization succeeded")
             
            }
    
        }
    
    func latestHeartRate(){
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else{
            return
        }
        let ChooseDate = self.startDateLabel.text!
        self.heartresult = ""
        let hrdateFormatter = DateFormatter()
        hrdateFormatter.dateFormat = "yyyy-MM-dd"
        hrdateFormatter.locale = Locale(identifier: "ko")
        
        let startDate = Calendar.current.date(byAdding: .month,value: -1, to: Date()) // 한달치 데이터를 가져온다.
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        
        let SortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [SortDescriptor]){ [self](sample,result,error) in
            guard error == nil else{
            return
        }
            let counts = result!.count // 심박수 개수를 센다.
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd (E)/HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "ko")
            
            let ref = Database.database().reference().child("Apple Watch")
            print("데이터 개수... \(counts)")
            
            if counts == 0{
                print("데이터가 없습니다.")
            }else{
                for i in 1...(counts-1){
                    
                    let data_sum = result![i] as! HKQuantitySample //모든 결과를 가져온다
                    let heartrate_sd = dateFormatter.string(from: data_sum.startDate)
                    let unit = HKUnit(from: "count/min")
                    let heartval = Int(data_sum.quantity.doubleValue(for: unit))
                    
                    if(heartrate_sd.contains(ChooseDate)){ //선택한 날짜가 포함된 값만 가져와서 보여준다(1일치)
                        self.heartresult += "\(heartrate_sd)...\(heartval) BPM \n"
                        ref.child("서혜지").child("심박수").child("\(heartrate_sd)").setValue("\(heartval)")
                    }
                    
                }
            }
            
            print("결과값... \(self.heartresult)")
            
        }
        healthKitStore.execute(query)
    }
    
    
       func getTodayTotalStepCounts(){
        
        self.stepresult = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd (E)"
        dateFormatter.locale = Locale(identifier: "ko")
           guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else{
               return
           }
        
        let ref = Database.database().reference().child("Apple Watch")
        let startDate = Calendar.current.startOfDay(for: self.startDatePicker!.date)  //선택한 날짜로부터 오늘까지의 모든 걸음수를 추출한다.
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        var interval = DateComponents()
        print("걸음수 시작날짜 \(startDate)")
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
          
           query.initialResultsHandler = {
               query,result,error in
               
               if let myresult = result{
                myresult.enumerateStatistics(from: startDate, to: Date()){(statistic, value) in
                       if let count = statistic.sumQuantity(){
                            let val = count.doubleValue(for: HKUnit.count())
                            print("Total step taken today is \(val) steps") //걸음수 값을 int형으로 바꿔야함!
                        
                            let StepDate = dateFormatter.string(from: statistic.startDate)
                            ref.child("서혜지").child("걸음수").child("\(StepDate)").setValue("\(Int(val))")
                            print("걸음수 시작 start == \(statistic.startDate)")
                            print("걸음수 종료 end == \(statistic.endDate)")
                        
                            self.stepresult += "Total step taken \(StepDate) is \(Int(val)) steps \n"
                       }
                    
                   }
               }
            print("\(self.stepresult)")
           }
           
           healthKitStore.execute(query)
       }

    


}





extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        dataTypeLabel.text = names[indexPath.row]
        if names[indexPath.row] == "심박수"{
            print("you tapped... 심박수")
        }else if names[indexPath.row] == "걸음수"{
            print("you tapped... 걸음수")
        }
        
    }
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        cell.selectedBackgroundView = UIView(frame: cell.bounds)
        cell.selectedBackgroundView!.backgroundColor = .green
        return cell
    }
}

