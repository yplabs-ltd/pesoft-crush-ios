//
//  ShopHistoryListViewController.swift
//  DateApp
//
//  Created by ryan on 1/16/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class ShopHistoryListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    private var pointLogListViewModel = DViewModel<[PointLogModel]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = "";
        
        title = "버찌 사용내역"
        
        emptyView.isHidden = true
        tableView.isHidden = true
        tableView.tableFooterView = UIView(frame: CGRect.zero)   // 내용없는 셀 표시 안함
        
        // viewmodel
        pointLogListViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let pointLogListModel = model else {
                return
            }
            if 0 < pointLogListModel.count {
                self?.emptyView.isHidden = true
                self?.tableView.isHidden = false
            } else {
                self?.emptyView.isHidden = false
                self?.tableView.isHidden = true
            }
            self?.tableView.reloadData()
        }
        
        reloadApi()
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .point_log)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ShopHistoryListViewController: ApiReloadable {
    func reloadApi() {
        let responseViewModel = ApiResponseViewModelBuilder<[PointLogModel]>(successHandlerWithDefaultError: { [weak self] (pointLogListModel) -> Void in
            self?.pointLogListViewModel.model = pointLogListModel
        }).viewModel
        let _ = _app.api.pointLogList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}

extension ShopHistoryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointLogListViewModel.model?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ShopHistoryCell
        cell.model = pointLogListViewModel.model?[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ShopHistoryHeaderView()
    }
}
