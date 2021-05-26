//
//  ViewController.swift
//  A2_FA_iOS_ Saksham_C0801483
//
//  Created by Saksham Arora on 23/05/21.
//

// MARK: -  Final Assignment - Saksham Arora

import UIKit

class ViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var showBtn: UIButton!
    var activeSearch:Bool = false
    var products:[Product] = []
    var searchProducts:[Product] = []
    var providers:[String:[Product]] = [:]
    var searchProviders:[String:[Product]] = [:]
    var selectedScreen = SelectedScreen.products
    var isEdit = false
    
    // MARK: -  View Controller Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        searchBar.delegate = self
        tableview.tableHeaderView = UIView(frame: .zero)
        
      // MARK: -  Add Edit Button

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editBtnAxn))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupScreen()
    }
    
    // MARK: -  Edit Button Action
    
    @objc func editBtnAxn(){
        isEdit = !isEdit
        self.tableview.reloadData()
    }
    
    // MARK: -  Screen Setup
    // Used for setup inscreen according to selected screen
    
    func setupScreen(){
        isEdit = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.view.endEditing(true)
        self.activeSearch = false
        self.searchProducts.removeAll()
        if selectedScreen == .products{
            self.title = "Products"
            showBtn.setTitle("Show Providers", for: .normal)
            self.fetchProducts()
        }
        else{
            self.title = "Providers"
            showBtn.setTitle("Show Products", for: .normal)
            self.getProviders()
        }
        self.tableview.reloadData()
    }
    
    // MARK: -  Get Provider
    // Get providers from the list
    
    func getProviders(){
        self.providers.removeAll()
        self.searchProviders.removeAll()
        for product in self.products{
            var array = self.providers[product.provider ?? ""] ?? []
            array.append(product)
            self.providers[product.provider ?? ""] = array
        }
    }
    
    // MARK: -  Get Products
    // get products from core data
    
    func fetchProducts(){
        products = CoreDataStack.shared.fetch(from: "Product", with: nil, sortDescriptor: nil) as? [Product] ?? []
    }
    
    // MARK: -  Opening Add Product Screen
    // open add product screen
    
        @IBAction func addProduct(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: -  Showing Data According to Selected Screen
    // show data according to selected screen
    
    @IBAction func show(_ sender: Any) {
        selectedScreen = selectedScreen == .products ? .providers : .products
        self.setupScreen()
    }
}

// MARK: -  Table View Delegate Function
// table view delegate functions



extension ViewController: UITableViewDelegate, UITableViewDataSource{

    // MARK: -  Returning Number of Rows according to Product Count
// return number of rows according to product count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedScreen == .products{
            if activeSearch{
                return searchProducts.count
            }
            return products.count
        }
        if activeSearch{
            return searchProviders.keys.count
        }
        return providers.keys.count
    }
    
    // MARK: -  Conf Table View Cell UI or Data
    // conf table view cell ui or data
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "ListTableViewCell") as! ListTableViewCell
        if isEdit{
            cell.deleteIcon.isHidden = false
        }
        else{
            cell.deleteIcon.isHidden = true
        }
        if selectedScreen == .products{
            var item:Product?
            if activeSearch{
                item = searchProducts[indexPath.row]
            }
            else{
                item = products[indexPath.row]
            }
            cell.selectionStyle = .none
            cell.iconView.isHidden = true
            cell.titleLbl.text = item?.name
            cell.detailLbl.text = item?.discreption
            return cell
        }
        var key:String?
        var count: Int = 0
        if activeSearch{
            key = Array(searchProviders.keys)[indexPath.row]
            count = searchProviders[key ?? ""]?.count ?? 0
        }
        else{
            key = Array(providers.keys)[indexPath.row]
            count = providers[key ?? ""]?.count ?? 0
        }
        cell.iconView.isHidden = false
        cell.selectionStyle = .none
        cell.titleLbl.text = key
        cell.detailLbl.text = "\(count)"
        return cell
    }
    
    
    // MARK: -  Action on Clicking the Cell
    // action on click on cell
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedScreen == .products{
            var item:Product?
            if activeSearch{
                item = searchProducts[indexPath.row]
            }
            else{
                item = products[indexPath.row]
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
            vc.item = item
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        else{
            var key:String?
            var products: [Product] = []
            if activeSearch{
                key = Array(searchProviders.keys)[indexPath.row]
                products = searchProviders[key ?? ""] ?? []
            }
            else{
                key = Array(providers.keys)[indexPath.row]
                products = providers[key ?? ""] ?? []
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
            vc.products = products
            vc.title = key
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return isEdit
    }
    
    // MARK: -  Deleting Product
    // delete product functionality
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if selectedScreen == .products{
                var item:Product
                if activeSearch{
                    item = searchProducts[indexPath.row]
                }
                else{
                    item = products[indexPath.row]
                }
                CoreDataStack.shared.delete(item)
            }
            else{
                var key:String?
                var products: [Product] = []
                if activeSearch{
                    key = Array(searchProviders.keys)[indexPath.row]
                    products = searchProviders[key ?? ""] ?? []
                }
                else{
                    key = Array(providers.keys)[indexPath.row]
                    products = providers[key ?? ""] ?? []
                }
                
                for product in products{
                    CoreDataStack.shared.delete(product)
                }
            }
            self.fetchProducts()
            self.setupScreen()
        }
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
    
    
    // MARK: -  Search according to the text
    // search according to the text
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if( searchText.isEmpty){
            self.activeSearch = false;
            self.searchBar?.isSearchResultsButtonSelected = false
            self.searchBar?.resignFirstResponder()
        } else if selectedScreen == .products{
            self.activeSearch = true;
            self.searchProducts = self.products.filter({ (product) -> Bool in
                let tmp: NSString = (product.name ?? "") as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                let tmpDesc: NSString = (product.discreption ?? "") as NSString
                let descRange = tmpDesc.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound || descRange.location != NSNotFound
            })
        }
        else{
            self.activeSearch = true;
            self.searchProviders = self.providers.filter({ (product) -> Bool in
                let tmp: NSString = (product.key ) as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
        }
        self.tableview.reloadData()
    }
}

// MARK: -  Extension for Update Data
// extension for update data

extension ViewController: DataFetcher{
    func fetchData() {
        setupScreen()
    }
    
}


protocol DataFetcher{
    func fetchData()
}


enum SelectedScreen{
    case products
    case providers
}
