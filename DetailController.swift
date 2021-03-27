//
//  DetailController.swift
//  healthkitpj
//
//  Created by 서혜지 on 2020/11/27.
//

import UIKit
class DetailController : UIViewController{
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var dataTypeLabel: UILabel!
    
    @IBOutlet weak var resultView: UITextView!
    
  
    
    var startDate : String?
    var dataType : String?
    var data : String?
    var userName : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = userName
        startDateLabel.text = startDate
        dataTypeLabel.text = "검색 데이터종류 : " + dataType!
        resultView.text = data
    }
    
    private func setData()
    {
        guard let startDate = self.startDate else{
            return
        }
        guard let userName = self.userName else{
            return
        }
        guard let dataType = self.dataType else{
            return
        }
        guard let data = self.data else{
            return
        }
        userNameLabel.text = userName
        startDateLabel.text = startDate
        dataTypeLabel.text = "검색 데이터종류 : " + dataType
        resultView.text = data
    }
    
}
