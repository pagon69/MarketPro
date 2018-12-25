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

class MarketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //my global variables
    let myArray = ["testing", "andy", "susan", "boob", "both"]
    
    
    let newsAPI = "https://api.iextrading.com/1.0/stock/market/news/last/5"
    let marketAPI = "https://api.iextrading.com/1.0/market"
    
    
    //outlets and more
    @IBOutlet weak var marketTableViewOutlet: UITableView!
    
    //my tableView setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = marketTableViewOutlet.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        
        cell.detailTextLabel?.text = " testing"
        cell.textLabel?.text = "another"
        
        return cell
        
    }
    

    @IBOutlet weak var myimageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
      // myimageview.image = downloadIcon(imageURL: "https://storage.googleapis.com/iex/api/logos/FB.png")
        myimageview.image = downloader()
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
