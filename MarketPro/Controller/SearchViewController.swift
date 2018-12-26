//
//  SearchViewController.swift
//  MarketPro
//
//  Created by Andy Alleyne on 12/25/18.
//  Copyright © 2018 AlleyneVentures. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Alamofire
import SwiftyJSON
import SVProgressHUD


class SearchViewController: UIViewController {

    //passed values
    var userSearchString = "-"
    let myStock = Stock()
    let myMarket = Market()
    let myNews = News()
    let mySector = Sectors()
    
    
    //global variables
    
    var providedDataArray = [Stock]()
    var userSearchURL = "https://api.iextrading.com/1.0/stock/market/batch?symbols="
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //validate what was sent
        
        if userSearchString != "-" {
            apiCalls(url: userSearchURL)
        }
        
        
    }
    

    
    func apiCalls(url: String){
        
        
        let addon = "&types=quote,logo"
        let finalURL = "\(url)\(userSearchString)\(addon)"
        
        Alamofire.request(finalURL, method: .get) //parameters can be placed after the get
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
            
            
            providedDataArray.append(myMarketData)
        }
        
        // marketDataArray.remove(at: 0)
        updateUIComponents()
        
    }
    
    
    func updateUIComponents() {
        
       // tableViewOutlet.reloadData()
    }
    
    
    
}
