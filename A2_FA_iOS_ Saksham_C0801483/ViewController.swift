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
    @IBOutlet weak var showBtn: UIButton!
    var activeSearch:Bool = false
    var products:[Product] = []
    var searchProducts:[Product] = []
    var providers:[String:[Product]] = [:]
    var searchProviders:[String:[Product]] = [:]
    var selectedScreen = SelectedScreen.products
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        searchBar.delegate = self
        tableview.tableHeaderView = UIView(frame: .zero)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editBtnAxn))
    }
    
    @objc func editBtnAxn(){
        isEdit = !isEdit
        self.tableview.reloadData()
    }
    
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
    
    func getProviders(){
        self.providers.removeAll()
        self.searchProviders.removeAll()
        for product in self.products{
            var array = self.providers[product.provider ?? ""] ?? []
            array.append(product)
            self.providers[product.provider ?? ""] = array
        }
    }
    
    
    func fetchProducts(){
        products = CoreDataStack.shared.fetch(from: "Product", with: nil, sortDescriptor: nil) as? [Product] ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupScreen()
    }
    
    @IBAction func addProduct(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func show(_ sender: Any) {
        selectedScreen = selectedScreen == .products ? .providers : .products
        self.setupScreen()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
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
