//
//  ProductListViewController.swift
//  A2_FA_iOS_ Saksham_C0801483
//
//  Created by Saksham Arora on 24/05/21.
//

import UIKit

class ProductListViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var products:[Product] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableHeaderView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }
    

}


extension ProductListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item:Product? = products[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = item?.name
        cell.backgroundColor = .link
        return cell
    }
}
