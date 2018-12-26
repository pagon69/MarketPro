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


class SearchViewController: UIViewController, GADBannerViewDelegate{

    //passed values
    var userSearchString = "-"
    
    let myStock = Stock()
    let myMarket = Market()
    let myNews = News()
    let mySector = Sectors()
    let myearnings = Earning()
    
    
    //global variables
    
    var providedDataArray = [Stock]()
    
    var userSearchURL = "https://api.iextrading.com/1.0/stock/market/batch?symbols="
    var dividends = "/dividends/ytd"
    var earnings = "/earnings"
    var financial = "/financials?period=annual"
    
    @IBOutlet weak var mainTextView: UITextView!
    
    @IBOutlet weak var googBannerView: GADBannerView!
    
    @IBOutlet weak var companyLogo: UIImageView!
    
    @IBOutlet weak var financialView: UITextView!
    
    @IBOutlet weak var statsView: UITextView!
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
        
        googBannerView.adUnitID = "ca-app-pub-7563192023707820/6377656611"
        googBannerView.rootViewController = self
        googBannerView.delegate = self
        googBannerView.isAutoloadEnabled = true
        
        apiCalls(url: userSearchURL)
        apiCallsTwo(url: "https://api.iextrading.com/1.0/stock/")
    
    }
    

    
    
    
    
    
    func updateUIComponents() {
       
        
        
        mainTextView.text = "Company: \(providedDataArray[0].companyName)\nSymbol: \(providedDataArray[0].symbol)\nPrimaryExchange:\(providedDataArray[0].primaryExchange)\nSector:\(providedDataArray[0].sector)\nLatest Price:\(providedDataArray[0].latestPrice)\nChange:\(providedDataArray[0].change)   \(providedDataArray[0].changePercent)\n52 Week High:\(providedDataArray[0].week52High) 52 Week Low:\(providedDataArray[0].week52Low)\n"
        SVProgressHUD.dismiss()
        
        
        statsView.text = "High:\(providedDataArray[0].high)\nLow:\(providedDataArray[0].low)"
        
        
    }
    
    func updateEarningsUI(){
        financialView.text = "Earnings Report:\nActual EPS:\(myearnings.actualEPS) "
        
        
        
        SVProgressHUD.dismiss()
        // tableViewOutlet.reloadData()
    }
    
    
    
    
    func apiCalls(url: String){
        
        
        let addon = "&types=quote,logo"
        let finalURL = "\(url)\(userSearchString)\(addon)"
        
        Alamofire.request(finalURL, method: .get) //parameters can be placed after the get
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let returnedStockData : JSON = JSON(response.result.value!)
                    
                    self.processMarketDataTwo(jsonData: returnedStockData)
                    
                }else{
                    
                    print("somthing went wrong: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    
    func apiCallsTwo(url: String){
        
        
        let finalURL = "\(url)\(userSearchString)\(dividends)"
        print(finalURL)
        
        Alamofire.request(finalURL, method: .get) //parameters can be placed after the get
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let returnedStockData : JSON = JSON(response.result.value!)
                    
                    self.processMarketData(jsonData: returnedStockData)
                    
                }else{
                    
                    print("somthing went wrong: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    
    
    
    func processMarketData(jsonData: JSON) {
        
        //print("in process data for earnings \(jsonData)")
        
        myearnings.actualEPS = jsonData["actualEPS"].stringValue
        myearnings.announceTime = jsonData["announceTime"].stringValue
        myearnings.consensusEPS = jsonData["consensusEPS"].stringValue
        myearnings.EPSSurpriseDollar = jsonData["EPSSurpriseDollar"].stringValue
        myearnings.estimatedChangePercent = jsonData["estimatedChangePercent"].stringValue
        myearnings.estimatedEPS = jsonData["estimatedEPS"].stringValue
        myearnings.fiscalEndDate = jsonData["fiscalEndDate"].stringValue
        myearnings.fiscalPeriod = jsonData["fiscalPeriod"].stringValue

         updateEarningsUI()
        
    }
    
    
    func processMarketDataTwo(jsonData: JSON) {
        
        for eachItem in jsonData.dictionaryValue{
            let myMarketData = Stock()
            
            for each in eachItem.value.dictionaryValue{
                
                //  each.value["companyName"].stringValue
                
                if each.key == "logo" {
                    
                    myMarketData.logo = each.value.stringValue
                    myMarketData.myLogo = downloadIcon(imageURL: myMarketData.logo)
                    // print("in logo code, mymarketdata has \(myMarketData.logo) the image should be \(myMarketData.myLogo)")
                }
                if each.key == "quote"{
                    
                    myMarketData.iexAskPrice = each.value["iexAskPrice"].stringValue
                    myMarketData.symbol  = each.value["symbol"].stringValue
                    myMarketData.companyName  = each.value["companyName"].stringValue
                    myMarketData.primaryExchange  = each.value["primaryExchange"].stringValue
                    myMarketData.sector  = each.value["sector"].stringValue
                    myMarketData.calculationPrice  = each.value["calculationPrice"].stringValue
                    myMarketData.open  = each.value["open"].stringValue
                    myMarketData.openTime  = each.value["openTime"].stringValue
                    myMarketData.close  = each.value["close"].stringValue
                    myMarketData.closeTime  = each.value["closeTime"].stringValue
                    myMarketData.high  = each.value["high"].stringValue
                    myMarketData.low  = each.value["low"].stringValue
                    myMarketData.latestPrice  = each.value["latestPrice"].stringValue
                    myMarketData.latestSource  = each.value["latestSource"].stringValue
                    myMarketData.latestTime  = each.value["latestTime"].stringValue
                    myMarketData.latestUpdate  = each.value["latestUpdate"].stringValue
                    myMarketData.latestVolume  = each.value["latestVolume"].stringValue
                    myMarketData.iexRealTimePrice  = each.value["iexRealtimePrice"].stringValue
                    myMarketData.iexRealTimeSize  = each.value["iexRealtimeSize"].stringValue
                    myMarketData.iexLatestUpdate  = each.value["iexLastUpdated"].stringValue
                    myMarketData.delayedPrice  = each.value["delayedPrice"].stringValue
                    myMarketData.delayedPriceTime  = each.value["delayedPriceTime"].stringValue
                    myMarketData.extendedPrice  = each.value["extendedPrice"].stringValue
                    myMarketData.extendedChange  = each.value["extendedChange"].stringValue
                    myMarketData.extentedChangePercent  = each.value["extendedChangePercent"].stringValue
                    myMarketData.extendedPriceTime  = each.value["extendedPriceTime"].stringValue
                    myMarketData.previousClose  = each.value["previousClose"].stringValue
                    myMarketData.change  = each.value["change"].stringValue
                    myMarketData.changePercent  = each.value["changePercent"].stringValue
                    myMarketData.iexMarketPercent  = each.value["iexMarketPercent"].stringValue
                    myMarketData.iexVolume  = each.value["iexVolume"].stringValue
                    myMarketData.avgTotalVolume  = each.value["avgTotalVolume"].stringValue
                    myMarketData.iexBidPrice  = each.value["iexBidPrice"].stringValue
                    myMarketData.iexBidSize  = each.value["iexBidSize"].stringValue
                    myMarketData.marketCap  = each.value["marketCap"].stringValue
                    myMarketData.peRation  = each.value["peRatio"].stringValue
                    myMarketData.week52Low  = each.value["week52High"].stringValue
                    myMarketData.week52High  = each.value["week52Low"].stringValue
                    myMarketData.ytdChange  = each.value["ytdChange"].stringValue
                    
                    
                }
                
                if each.key == "news"{
                    //MARK: - what to do with news?
                    
                }
                
                if each.key == "chart" {
                    
                    
                    for item in each.value.arrayValue{
                        myMarketData.chartDataArray.append(item["close"].intValue)
                        myMarketData.chartDatesArray.append(item["date"].stringValue)
                    }
                    
                }
                
            }
            providedDataArray.append(myMarketData)
        }
       // processedWatchList.remove(at: 0)
        updateUIComponents()
    }
    
    
    
    func downloadIcon(imageURL: String) -> UIImage?{
        
        var myImage : UIImage?
        
        Alamofire.request(imageURL).responseImage { response in
            //debugPrint(response)
            //print(response.request)
            //print(response.response)
            //  debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                myImage = image
            }
        }
        
        return myImage
        
    }

    
    
    
}
