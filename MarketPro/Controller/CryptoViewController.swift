//
//  CryptoViewController.swift
//  MarketPro
//
//  Created by Andy Alleyne on 12/25/18.
//  Copyright © 2018 AlleyneVentures. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyJSON
import Alamofire

class CryptoViewController: UIViewController, GADBannerViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
        //tableview setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCryptoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        cell.detailTextLabel?.text = "$\(listCryptoArray[indexPath.row].latestPrice)  Change:\(listCryptoArray[indexPath.row].change)"
        cell.textLabel?.text = "\(listCryptoArray[indexPath.row].companyName)   -- \(listCryptoArray[indexPath.row].symbol)"
        
        
        
        return cell
    }
    

    
    var baseURL = "https://api.iextrading.com/1.0/stock/market/crypto"
    
    
        //global variables
    var listCryptoArray = [Stock]()
    var userProvidedData = "-"
    
    
    
    
    
    
    @IBOutlet weak var googBannerOutlet: GADBannerView!
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        googBannerOutlet.adUnitID = "ca-app-pub-7563192023707820/3854213861"
        googBannerOutlet.rootViewController = self
        googBannerOutlet.delegate = self
        googBannerOutlet.isAutoloadEnabled = true
        
        apiCalls(url: baseURL)
        
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // use this with firebase, realm or file search
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text {
            userProvidedData = text
        }
        
        performSegue(withIdentifier: "searchViewCrypto", sender: self)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchViewCrypto" {
            let newVC = segue.destination as! SearchViewController
            newVC.userSearchString = userProvidedData
        }
        
    }
    
    

    func apiCalls(url: String){
        
        Alamofire.request(url, method: .get) //parameters can be placed after the get
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let returnedStockData : JSON = JSON(response.result.value!)
                    
                    self.processMarketData(jsonData: returnedStockData)
                    
                    print(returnedStockData)
                    
                }else{
                    
                    print("somthing went wrong: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    
    func processMarketData(jsonData: JSON) {
        
        
        for eachItem in jsonData.arrayValue{
            
            
            let myMarketData = Stock()
            
            myMarketData.symbol = eachItem["symbol"].stringValue
            myMarketData.companyName = eachItem["companyName"].stringValue
            myMarketData.primaryExchange = eachItem["primaryExchange"].stringValue
            myMarketData.sector = eachItem["sector"].stringValue
            
            myMarketData.open = eachItem["open"].stringValue
            myMarketData.openTime = eachItem["openTime"].stringValue
            myMarketData.close = eachItem["close"].stringValue
            myMarketData.closeTime = eachItem["closeTime"].stringValue
            
            myMarketData.high = eachItem["high"].stringValue
            myMarketData.low = eachItem["low"].stringValue
            myMarketData.latestPrice = eachItem["latestPrice"].stringValue
            myMarketData.latestSource = eachItem["latestSource"].stringValue
            
            myMarketData.latestTime = eachItem["latestTime"].stringValue
            myMarketData.latestUpdate = eachItem["latestUpdate"].stringValue
            myMarketData.latestVolume = eachItem["latestVolume"].stringValue
            myMarketData.previousClose = eachItem["previousClose"].stringValue
            
            myMarketData.change = eachItem["change"].stringValue
            myMarketData.changePercent = eachItem["changePercent"].stringValue
            myMarketData.bidPrice = eachItem["bidPrice"].stringValue
            myMarketData.bidSize = eachItem["bidSize"].stringValue
            
            myMarketData.askPrice = eachItem["askPrice"].stringValue
            myMarketData.askSize = eachItem["askSize"].stringValue
            
            
            listCryptoArray.append(myMarketData)
        }
        
        // marketDataArray.remove(at: 0)
        updateUIComponents()
        
    }
    
    
    func updateUIComponents() {
        
        tableViewOutlet.reloadData()
    }
    
    
    
    
   

}
