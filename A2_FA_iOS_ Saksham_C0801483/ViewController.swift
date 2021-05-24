//
//  ViewController.swift
//  A2_FA_iOS_ Saksham_C0801483
//
//  Created by Saksham Arora on 23/05/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    var activeSearch:Bool = false
    var products:[Product] = []
    var searchProducts:[Product] = []
    var productNames  = ["Television", "Radio" , "Fridge" , "iPhone", "Macbook", "Watch", "Pen", "Table", "Chair", "Wallet"]
    var productIDs  = ["101", "102" , "103" , "104", "105", "106", "107", "108", "109", "110"]
    var productPrices  = ["33101", "1102" , "11103" , "51104", "151105", "1106", "10", "5108", "509", "110"]
    var productProvides  = ["Sony", "Philips" , "LG" , "Apple", "Apple", "Fasttrack", "Win", "Neelam", "Neelam", "Woodland"]
    var productDescs  = ["Color TV", "All in one Radio & FM" , "LG Fridge" , "64 GB ROM", "16 GB RAM 256 GB SSD", "Water proof watch", "Blue color pen", "White color Table", "White color Chair", "Leather Wallet"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Products"
        tableview.delegate = self
        tableview.dataSource = self
        searchBar.delegate = self
        tableview.tableHeaderView = UIView(frame: .zero)
        self.fetchProducts()
    }
    
    
    func fetchProducts(){
        products = CoreDataStack.shared.fetch(from: "Product", with: nil, sortDescriptor: nil) as? [Product] ?? []
        if products.isEmpty{
            for i in 0 ..< productIDs.count{
                if let product = CoreDataStack.shared.object(for: "Product") as? Product {
                    product.id = productIDs[i]
                    product.name = productNames[i]
                    product.provider = productProvides[i]
                    product.discreption = productDescs[i]
                    product.price = productPrices[i]
                    products.append(product)
                }
            }
            CoreDataStack.shared.saveContext()
        }
        tableview.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeSearch{
            return searchProducts.count
        }
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "ListTableViewCell") as! ListTableViewCell
        var item:Product?
        if activeSearch{
            item = searchProducts[indexPath.row]
        }
        else{
            item = products[indexPath.row]
        }
        cell.titleLbl.text = item?.name
        cell.detailLbl.text = item?.discreption
        return cell
    }
    
    
}


// MARK: -  Search Bar
extension ViewController: UISearchBarDelegate{
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar?.becomeFirstResponder()
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.activeSearch = false;
        self.searchBar?.resignFirstResponder()
        self.tableview.reloadData()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.activeSearch = false;
        self.searchBar!.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if( searchText.isEmpty){
            self.activeSearch = false;
            self.searchBar?.isSearchResultsButtonSelected = false
            self.searchBar?.resignFirstResponder()
        } else {
            self.activeSearch = true;
            self.searchProducts = self.products.filter({ (product) -> Bool in
                let tmp: NSString = (product.name ?? "") as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                let tmpDesc: NSString = (product.discreption ?? "") as NSString
                let descRange = tmpDesc.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound || descRange.location != NSNotFound
            })
        }
        self.tableview.reloadData()
    }
}
