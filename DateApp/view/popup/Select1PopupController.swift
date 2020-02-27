//
//  Select1PopupController.swift
//  DateApp
//
//  Created by ryan on 1/5/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

enum SelectType: Int {
    case Birthdate = 0
    case Job
    case Location
    case IdealType
    case bodyShape
    case Height
    case BloodType
    case Religion
}

// 하나를 선택하는 팝업
final class Select1PopupController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var itemsViewModel = DViewModel<[SelectItemModel]>()
    var selected: SelectItemModel?
    var submitHandler: ((Select1PopupController) -> ())?
    var startRowIndex: Int?
    var selectType: SelectType = .Job
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = title
        
        itemsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
        }
        
        if let startRowIndex = startRowIndex {
            tableView.scrollToRow(at: IndexPath(row: startRowIndex, section: 0), at: UITableViewScrollPosition.top, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print(#function, "\(self)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Select1PopupController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsViewModel.model?.countOfVisibleCells ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let (item, child, _) = itemsViewModel.model?.getItem(cellIdx: indexPath.row) else {
            return UITableViewCell()
        }
        let profileModel = _app.profileViewModel.model
        if child {
            let subCell = tableView.dequeueReusableCell(withIdentifier: "SubCell") as! Select1SubCell
            subCell.titleLabel.text = item.value
            var matchedText: String? = nil
            switch selectType {
            case .Job:
                if let job = profileModel!.job {
                    if let jobExtra = profileModel!.job?.extra, let jobValue = job.value {
                        matchedText = jobValue.components(separatedBy: jobExtra + ", ").last?.trim()
                    }
                }
            default:()
            }
            
            subCell.titleLabel.textColor = UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
            if let matchText = matchedText {
                subCell.titleLabel.textColor =  (matchText == item.value) ? UIColor(red: 236/255, green: 82/255, blue: 72/255, alpha: 1.0) : UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
            }
            
            return subCell
        } else if let c = item.children?.count, c > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParentCell") as! Select1ParentCell
            cell.titleLabel.text = item.value
            
            var matchedText: String? = nil
            switch selectType {
            case .Job:
                matchedText = profileModel!.job?.extra
            default:()
            }
            
            cell.titleLabel.textColor = UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
            if let matchText = matchedText {
                cell.titleLabel.textColor =  (matchText == item.value) ? UIColor(red: 236/255, green: 82/255, blue: 72/255, alpha: 1.0) : UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
            }
            
            cell.opened = !item.childrenHidden
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Select1Cell
            cell.titleLabel.text = item.value
            
            var matchedText: String? = nil
            switch selectType {
            case .Birthdate:
                matchedText = profileModel!.birthDate?.components(separatedBy:"-").first
            case .Job:
                matchedText = profileModel!.job?.value
            case .Location:
                matchedText = profileModel!.hometown?.value
            case .IdealType:
                matchedText = profileModel!.idealType?.value
            case .bodyShape:
                matchedText = profileModel!.bodyType?.value
            case .Height:
                if let height = profileModel!.height  {
                    matchedText = "\(Int(height))"
                }
            case .BloodType:
                matchedText = profileModel!.bloodType?.value
            case .Religion:
                matchedText = profileModel!.religion?.value
            }
            
            cell.titleLabel.textColor = UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
            if let matchText = matchedText {
                cell.titleLabel.textColor =  (matchText == item.value) ? UIColor(red: 236/255, green: 82/255, blue: 72/255, alpha: 1.0) : UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let (item, child, index) = itemsViewModel.model?.getItem(cellIdx: indexPath.row) else {
            return
        }
        
        if let c = item.children?.count, c > 0, !child {
            var newItem = item
            if newItem.childrenHidden == true {
                newItem.childrenHidden = false
            } else {
                newItem.childrenHidden = true
            }
            itemsViewModel.model?[index] = newItem
        } else {
            // 선택과 즉시 선택완료
            submit(sender: self)
        }
    }
}

extension Select1PopupController {
    
    func submit(sender: AnyObject) {
        if let indexPath = tableView.indexPathForSelectedRow, let item = itemsViewModel.model?.getItem(cellIdx: indexPath.row) {
            selected = item.item
            submitHandler?(self)
        }
    }
}

