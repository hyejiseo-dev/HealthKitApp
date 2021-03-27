//
//  ResultViewController.swift
//  healthkitpj
//
//  Created by 서혜지 on 2020/11/26.
//

import UIKit

class ResultViewController : UIViewController{
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var dataTypeLabel: UILabel!
    
    var startDate : String?
    var endDate : String?
    var dataType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDateLabel.text = startDate
        endDateLabel.text = endDate
        dataTypeLabel.text = dataType
    }
    private func setData()
    {
        guard let startDate = self.startDate else{
            return
        }
        guard let endDate = self.endDate else{
            return
        }
        guard let dataType = self.dataType else{
            return
        }
        
        startDateLabel.text = startDate
        endDateLabel.text = endDate
        dataTypeLabel.text = dataType
    }
}

