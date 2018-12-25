//
//  MarketViewController.swift
//  MarketPro
//
//  Created by Andy Alleyne on 12/24/18.
//  Copyright © 2018 AlleyneVentures. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SVProgressHUD
import SwiftyJSON
import GoogleMobileAds


class MarketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , GADBannerViewDelegate{
    
    //my global variables
    
    
    var marketDataArray = [Market]()
    var newsDataArray = [News]()
    let newsAPI = "https://api.iextrading.com/1.0/stock/market/news/last/5"
    let marketAPI = "https://api.iextrading.com/1.0/market"
    
    
    //outlets and more
    @IBOutlet weak var marketTableViewOutlet: UITableView!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var textFieldOutlet: UITextView!
    @IBOutlet weak var newsSource: UILabel!
    @IBOutlet weak var googBannerView: GADBannerView!
    @IBOutlet weak var urlSources: UILabel!
    
    
    
    
    
    
    
    
    //my tableView setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = marketTableViewOutlet.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        
        cell.detailTextLabel?.text = "Mic:\(marketDataArray[indexPath.row].mic)    Volume:\(marketDataArray[indexPath.row].volome)"
        cell.textLabel?.text = "VenureName: \(marketDataArray[indexPath.row].venueName)"
        
        return cell
        
    }
    

    @IBOutlet weak var myimageview: UIImageView!
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        googBannerView.adUnitID = "ca-app-pub-7563192023707820/6176021227"
        googBannerView.delegate = self
        googBannerView.rootViewController = self
        googBannerView.isAutoloadEnabled = true
        
        
        SVProgressHUD.show()
        
      // myimageview.image = downloadIcon(imageURL: "https://storage.googleapis.com/iex/api/logos/FB.png")
      //  myimageview.image = downloader()
        
        apiCalls(url: marketAPI)
        apiCallTwo(url: newsAPI)
        
        
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
    
    
    func apiCallTwo(url: String){
        
        Alamofire.request(url, method: .get) //parameters can be placed after the get
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let returnedStockData : JSON = JSON(response.result.value!)
                    
                    self.processMarketDataTwo(jsonData: returnedStockData)
                    
                    print(returnedStockData)
                    
                }else{
                    
                    print("somthing went wrong: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    
    func processMarketData(jsonData: JSON) {
        
        
        for eachItem in jsonData.arrayValue{
            
            
            let myMarketData = Market()
            
                myMarketData.mic = eachItem["mic"].stringValue
                myMarketData.venueName = eachItem["venueName"].stringValue
                myMarketData.volome = eachItem["volume"].stringValue
                myMarketData.marketPercent = eachItem["marketPercent"].stringValue
            
            marketDataArray.append(myMarketData)
        }
        
       // marketDataArray.remove(at: 0)
        updateUIComponents()
        
    }
    
    
    func processMarketDataTwo(jsonData: JSON) {
        
        for eachItem in jsonData.arrayValue{
            
            
            let myMarketData = News()
            
            myMarketData.headline = eachItem["headline"].stringValue
            myMarketData.imageURL = eachItem["image"].stringValue
            myMarketData.source = eachItem["source"].stringValue
            myMarketData.summary = eachItem["summary"].stringValue
            myMarketData.url = eachItem["url"].stringValue
            
            newsDataArray.append(myMarketData)
        }
        
       // newsDataArray.remove(at: 0)
        updateUIComponentsTwo()
        
    }
    
    func updateUIComponents() {
        
        marketTableViewOutlet.reloadData()
        SVProgressHUD.dismiss()
        
    }
    
    
    func updateUIComponentsTwo() {
        
        marketTableViewOutlet.reloadData()
        SVProgressHUD.dismiss()
        
        headline.text = newsDataArray[0].headline
       // imageViewOutlet.image = newsDataArray[0].imageURL
        newsSource.text = newsDataArray[0].source
        urlSources.text = newsDataArray[0].url
        urlSources.text = newsDataArray[0].url
        textFieldOutlet.text = newsDataArray[0].summary
        
        
    }
    
    
    
    func downloadIcon(imageURL: String) -> UIImage?{
        
        var myImage = UIImage(contentsOfFile: "icon_29.png")
        
        print(" first time \(String(describing: myImage))")

        Alamofire.request(imageURL).responseImage { response in
            //debugPrint(response)
           // print(response.request)
            //print(response.response)
            //debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                myImage = image
            }
            
            
        }
       // print("any data in \(myImage)")
        return myImage
        
    }
    
    
    func downloader()-> UIImage?{
        
        var myImage : UIImage?
        let downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: "https://storage.googleapis.com/iex/api/logos/FB.png")!)
        
        downloader.download(urlRequest) { response in
            
            if let image = response.result.value {
                print(image)
                myImage = image
            }
            
        }
        return myImage
    }
    
    
    
    
    
    
    
    
    

}
