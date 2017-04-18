//
//  ViewController.swift
//  Acronyms
//
//  Created by Subashree Malla Lokanathan on 4/17/17.
//  Copyright © 2017 Subashree Malla Lokanathan. All rights reserved.
//

import UIKit
import ObjectMapper

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var tbBottomConstraint: NSLayoutConstraint!
    var objMBProgressHUD : MBProgressHUD?
    var objSearchResultModel : SearchResultModel!
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    let searchURL = "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf="
    let alertMessageWentWrong = "Something went wrong. Please try again later."
    let alertAcronymNF = "Acronym not found"
    let kalertTitleError = "Error"
    let kalertTitleSorry = "Sorry"
    let cellIdentifier = "ResultCell"
    let kalertTitleOk = "Ok"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchbar.delegate = self
        self.searchbar.showsCancelButton = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notif:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notif:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Search bar delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchbar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchbar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchbar.showsCancelButton = true
        
        if searchText == "" {
            objSearchResultModel = nil
            self.tableview.reloadData()
        }
    }
    
    /// Serach bar actions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            if dataTask != nil {
                dataTask?.cancel()
            }
            let searchTerm = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let urlstring = searchURL + (searchTerm)!
            if let url = URL(string: urlstring) {
                do {
                    self.objMBProgressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
                    // Set the label text.
                    self.objMBProgressHUD?.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.dataTask = self.defaultSession.dataTask(with: url as URL) {
                            data, response, error in
                            if error != nil {
                                self.showErrorAler(title: self.kalertTitleError, message: self.alertMessageWentWrong)
                            } else if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                    self.updateSearchResults(data)
                                }
                                else{
                                    self.showErrorAler(title: self.kalertTitleError, message: self.alertMessageWentWrong)
                                }
                            }
                        }
                        self.dataTask?.resume()
                    }
                }
            } else {
                // the URL was bad!
                self.showErrorAler(title: self.kalertTitleError, message: self.alertMessageWentWrong)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchbar.showsCancelButton = false
        self.searchbar.text = ""
        objSearchResultModel = nil
        self.tableview.reloadData()
    }
    
    // This helper method helps parse response JSON NSData into an array of Track objects.
    ///parser method to hande response
    func updateSearchResults(_ data: Data?) {
        self.objSearchResultModel = nil
        do {
            if let data = data, let response = try
                JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject]{
                // Get the results array
                for acronymDictonary in response {
                    if let acronymDictonary = acronymDictonary as? [String: AnyObject] {
                        // Parse the search result
                        self.objSearchResultModel = Mapper<SearchResultModel>().map(JSONObject: acronymDictonary)
                    } else {
                        self.showErrorAler(title: self.kalertTitleError, message: alertMessageWentWrong)
                    }
                }
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                    self.searchbar.resignFirstResponder()
                    self.objMBProgressHUD?.hide(animated: true)
                    if response.count < 1{
                        self.showErrorAler(title: self.kalertTitleSorry, message: self.alertAcronymNF)
                    }
                }
            }
            else
            {
                self.showErrorAler(title: self.kalertTitleError, message: alertMessageWentWrong)
            }
        } catch _ as NSError {
            self.showErrorAler(title: self.kalertTitleError, message: alertMessageWentWrong)
        }
    }
    
    ///TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.objSearchResultModel != nil{
            return (self.objSearchResultModel.lfs?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier);
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier);
        }
        cell?.textLabel?.text = self.objSearchResultModel.lfs?[indexPath.row].lf
        cell?.detailTextLabel?.text = String(describing: (self.objSearchResultModel.lfs?[indexPath.row].since)!)
        return cell!
    }
    
    ///Keyboard notifcation methods to hand table view frame
    func keyboardWillShow(notif: NSNotification) {
        let userInfo:NSDictionary = notif.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.tbBottomConstraint.constant += keyboardHeight
    }
    
    func keyboardWillHide(notif: NSNotification) {
        self.tbBottomConstraint.constant = 0
    }
    
    ///Alert view display Handling
    func showErrorAler(title: String, message: String) {
        self.resignFirstResponder()
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: kalertTitleOk, style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

