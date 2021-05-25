//
//  ProductViewController.swift
//  A2_FA_iOS_ Saksham_C0801483
//
//  Created by Saksham Arora on 24/05/21.
//

import UIKit

class ProductViewController: UIViewController {
    
    @IBOutlet weak var descriptionTA: UITextView!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var providerTF: UITextField!
    @IBOutlet weak var productIdTF: UITextField!
    @IBOutlet weak var productNameTF: UITextField!
    var item:Product?
    var delegate:DataFetcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showProductDetail()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    func showProductDetail(){
        if let product  = item{
            productIdTF.text = product.id
            productNameTF.text = product.name
            providerTF.text = product.provider
            priceTF.text = product.price
            descriptionTA.text = product.discreption
        }
    }
    
    @IBAction func saveBtnAxn(_ sender: Any) {
        self.view.endEditing(true)
        if let product  = item{
            self.updateInDB(product: product)
        }
        else if let product = CoreDataStack.shared.object(for: "Product") as? Product{
            self.updateInDB(product: product)
        }
        self.dismiss(animated: true) {
            self.delegate?.fetchData()
        }
    }
    
    func updateInDB(product:Product){
        if let name = productNameTF.text, let id = productIdTF.text, let provider = providerTF.text, let price = priceTF.text , let desc = descriptionTA.text{
            product.id = id
            product.name = name
            product.provider = provider.capitalized
            product.discreption = desc
            product.price = price
            CoreDataStack.shared.saveContext()
        }
    }
    
}
