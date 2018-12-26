//
//  ViewController.swift
//  MarketPro
//
//  Created by Andy Alleyne on 12/21/18.
//  Copyright © 2018 AlleyneVentures. All rights reserved.
//

import UIKit
import SwiftyJSON
import ScrollableGraphView
import Alamofire
import SVProgressHUD
import AlamofireImage
import GoogleMobileAds

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ScrollableGraphViewDataSource, GADBannerViewDelegate, UISearchBarDelegate {
    
    
    //my global variables
    
    //Mark: User defaults
    
    let defaults = UserDefaults.standard
    
    
    
   // var bannerView: GADBannerView!
    
    var graphData = [Int]()
    var chartsGraphData = [Int]()
    
    var watchList = [String]()
    
    var processedWatchList = [Stock()]
    
    let defaultURL = "https://api.iextrading.com/1.0/stock/market/batch?symbols="
    
    var userSearchURL = "https://api.iextrading.com/1.0/stock/market/batch?symbols=aapl&types=quote,logo,news,chart&range=1m"
    
    var userProvidedData = "-"
    
    
    @IBOutlet weak var GoogBannerAD: GADBannerView!
    @IBOutlet weak var watchListTableView: UITableView!
    
    
    //Table view setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return processedWatchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = watchListTableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! DetailTableViewCell
        
        cell.StockNameOutlet.text = "\(processedWatchList[indexPath.row].companyName) -- (\(processedWatchList[indexPath.row].symbol))"
        
        /* change the color of the stock
        if processedWatchList[indexPath.row].change) <= 0{
            cell.stockDetailLabel.backgroundColor = UIColor.red
        }else{
            cell.stockDetailLabel.backgroundColor = UIColor.green
        }
        */
        
        cell.stockDetailLabel.text = "$\(processedWatchList[indexPath.row].latestPrice)  Chg:\(processedWatchList[indexPath.row].change)  P/E:\(processedWatchList[indexPath.row].peRation)"
        
        //cell.symbolImage.image =
        cell.symbolImage.image = processedWatchList[indexPath.row].myLogo
        
        graphData = processedWatchList[indexPath.row].chartDataArray
        
        cell.graphViewOutlet.addSubview(createGraphs(dataToPlot: graphData, numberOfPointsToPlot: 15))

        return cell
        
    }
    
    
    //graph view setup
    var linePlotData = [Int]()
    var numberOfDataPointsInGraph = 100
    var pointIndex = 1
    var xCoorData = [String]()
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch (plot.identifier) {
        case "line":
            return Double(graphData[pointIndex])
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
    
        return "\(pointIndex)"
    }
    
    func numberOfPoints() -> Int {
        return graphData.count
    }
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SVProgressHUD.show()
    
        
        
        //google ads
        GoogBannerAD.adUnitID = "ca-app-pub-7563192023707820/8684884041"
        GoogBannerAD.rootViewController = self
        GoogBannerAD.delegate = self
        GoogBannerAD.isAutoloadEnabled = true
        
        //Mark: - load defaults
        
        if let items = defaults.array(forKey: "userWatchList") as? [String] {
            watchList = items
            apiCalls(url: defaultURL)
        }
        
       // var myimage = downloadIcon(imageURL: "https://storage.googleapis.com/iex/api/logos/FB.png")
       // print("sitting at view page: \(myimage)")
        
        //defaults.set(watchList, forKey: "userWatchList")
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // use this with firebase, realm or file search
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text {
            userProvidedData = text
        }
        
        performSegue(withIdentifier: "searchViewWatchList", sender: self)
    
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchViewWatchList" {
            let newVC = segue.destination as! SearchViewController
            newVC.userSearchString = userProvidedData
        }
        
    }
    
    
    
    
    func updateImage(companyImage : String) {
        let url = "https://storage.googleapis.com/iex/api/logos/FB.png"
        
        
        
        Alamofire.request(url).responseImage { response in
         //   debugPrint(response)
          //  print(response.request)
          //  print(response.response)
           // debugPrint(response.result)
            
            if let image = response.result.value {
                
             //   self.iconImageView.image = image
                print("image downloaded: \(image)")
            }
        }
        
    }
    
    
    
    func saveItemToWatchlist(userSelected: String) {
        
        watchList.append(userSelected)
        watchList.append("goog")
        watchList.append("aapl")
        
        defaults.set(watchList, forKey: "userWatchList")
    }
    
    
    
    
    
    func apiCalls(url: String){
        var wathListItems = ""
        
        for eachItem in watchList{
            wathListItems = wathListItems + "\(eachItem)" + ","
        }
        
        let createURL = "\(wathListItems)&types=quote,logo,news,chart&range=3m"
        let finalURL = url + createURL
        
        print(finalURL)
        
        
        Alamofire.request(finalURL, method: .get) //parameters can be placed after the get
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let returnedStockData : JSON = JSON(response.result.value!)
                   // SVProgressHUD.dismiss()
                    
                    self.processMarketData(jsonData: returnedStockData)
                    
                    //print(returnedStockData)
                    
                }else{
                    
                    print("somthing went wrong: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    //MARK: - process json data and update components
    
    func processMarketData(jsonData: JSON) {

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
            processedWatchList.append(myMarketData)
        }
        processedWatchList.remove(at: 0)
        updateUIComponents()
    }
    
    
    //MARK: update the table view and onscreen stuff
    
    func updateUIComponents(){
    
        watchListTableView.reloadData()
        SVProgressHUD.dismiss()
    
    //print(downloadIcon(imageURL: processedWatchList[0].logo))
    
    }
    
    
    
    
    
    
    
    
    //MARK: - create graph and dismiss progress bar
    
    func createGraphs(dataToPlot : [Int], numberOfPointsToPlot : Int) -> UIView {
        let graphView = ScrollableGraphView(frame: CGRect(x: 0, y: 0, width: 336, height: 130), dataSource: self)

        
        let linePlot = LinePlot(identifier: "line")
        let referenceLines = ReferenceLines()
        let dotPlot = DotPlot(identifier: "darkLineDot") // Add dots as well.
        
        linePlot.lineWidth = 1
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        
        
        //look for rbg information from hex
        
        // linePlot.fillGradientStartColor = UIColor.#colorLiteral(red: 0.286239475, green: 0.2862946987, blue: 0.2862360179, alpha: 1)
        // linePlot.fillGradientEndColor = UIColor.#colorLiteral(red: 0.1960526407, green: 0.1960932612, blue: 0.1960500479, alpha: 1)
        
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        
        dotPlot.dataPointSize = 1
        dotPlot.dataPointFillColor = UIColor.white
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
    
        
        // print(jsonData)
        
        //let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        
        referenceLines.positionType = .absolute
        // Reference lines will be shown at these values on the y-axis.
        referenceLines.absolutePositions = [100,150,200,250,500,1000]
        referenceLines.includeMinMax = false
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.shouldShowLabels = false
        
        graphView.addPlot(plot: linePlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        
        //custom settings
        graphView.shouldAdaptRange = true
        graphView.shouldAnimateOnStartup = true
        graphView.backgroundFillColor = UIColor.blue
        
        graphView.dataPointSpacing = 5
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.shouldRangeAlwaysStartAtZero = false
        
        
        //graphView.rangeMax = 100
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: dotPlot)
        
        
        //X values
        
     //   graphView.dataPointSpacing = 1
        
        
        
        //edit Json for chart data
        /*
         for eachItem in jsonData["chart"].arrayValue{
         
         print(eachItem["label"].stringValue)
         print(eachItem["close"].stringValue)
         
         xCoorData.append(eachItem["label"].stringValue)
         linePlotData.append(eachItem["close"].int!)
         
         
         }
         */
        
       // view.addSubview(graphView)
    
       // SVProgressHUD.dismiss()
        
        return graphView
    
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
    
    
    
    /*
    
     
    
    
*/

}

