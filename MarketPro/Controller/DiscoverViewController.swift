//
//  DiscoverViewController.swift
//  MarketPro
//
//  Created by Andy Alleyne on 12/24/18.
//  Copyright © 2018 AlleyneVentures. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyJSON
import Alamofire

class DiscoverViewController: UIViewController, GADBannerViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    

    
    //tableview setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectorArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableviewOutlet.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        cell.detailTextLabel?.text = sectorArray[indexPath.row].performance
        cell.textLabel?.text = sectorArray[indexPath.row].name
        
        return cell
    }
    
    
    //global variables
    var sectorArray = [Sectors]()
    
    var sectorURL = "https://api.iextrading.com/1.0//stock/market/sector-performance"
    var upComingIPO = "https://api.iextrading.com/1.0/stock/market/upcoming-ipos"
    
    
    /*
 
     /stock/market/list/mostactive
     /stock/market/list/gainers
     /stock/market/list/losers
 
 */
    
    
    @IBOutlet weak var tableviewOutlet: UITableView!
    @IBOutlet weak var googBannerAD: GADBannerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        googBannerAD.adUnitID = "ca-app-pub-7563192023707820/7929399678"
        googBannerAD.rootViewController = self
        googBannerAD.delegate = self
        googBannerAD.isAutoloadEnabled = true
        
        
        apiCalls(url: sectorURL)
        
        
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
            
            
            let myMarketData = Sectors()
            
            myMarketData.name = eachItem["name"].stringValue
            myMarketData.performance = eachItem["performance"].stringValue
            
            sectorArray.append(myMarketData)
        }
        
        // marketDataArray.remove(at: 0)
        updateUIComponents()
        
    }
    
    
    func updateUIComponents() {
        
        tableviewOutlet.reloadData()
    }
    
    
    
    
    
    
    
}
