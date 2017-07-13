//
//  ViewController.swift
//  BitcoinWatch
//
//  Created by Laptop on 7/12/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var ticker  = Ticker()
    var coin    = Coin()
    var updated = Date()

    @IBOutlet weak var textPrice  : UILabel!
    @IBOutlet weak var textVolume : UILabel!
    @IBOutlet weak var textMarket : UILabel!
    @IBOutlet weak var imageLeft  : UIImageView!
    @IBOutlet weak var imageRight : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("PHONE DID LOAD")
        getTicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("PHONE DID APPEAR")
        let elapsed = updated.addingTimeInterval(60) // 1 min
        //print("Elapsed?\n  \(updated)\n  \(elapsed)\n  \(Date())")
        if elapsed < Date() {
            getTicker()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTicker() {
        //print("PHONE Fetching ticker...")
        let api = "https://api.coinmarketcap.com/v1/ticker/bitcoin/"
        let url = URL(string: api)
        
        updated = Date()
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if error != nil {
                self.textPrice.text  = "ERROR"
                self.textVolume.text = "TRY LATER"
                self.textMarket.text = "NO INTERNET"
                print("Error fetching API")
                print(error ?? "?")
                return
            }
            
            if let text = String(data: data!, encoding: .utf8) {
                self.ticker  = Ticker(json: text)
                self.coin = self.ticker.getCoin("BTC") ?? Coin()
                DispatchQueue.main.async {
                    self.textPrice.text  = self.coin.priceUsd.format(4, 4)
                    self.textVolume.text = "VOL: " + self.coin.volumeUsd.toMillions()
                    self.textMarket.text = "MKT: " + self.coin.marketUsd.toMillions()
                    if self.coin.change01h > 0 {
                        self.imageLeft.image  = UIImage(named: "arrowup")
                        self.imageRight.image = UIImage(named: "arrowup")
                    } else {
                        self.imageLeft.image  = UIImage(named: "arrowdn")
                        self.imageRight.image = UIImage(named: "arrowdn")
                    }
                }
            } else {
                self.textPrice.text  = "ERROR"
                self.textVolume.text = "TRY LATER"
                self.textMarket.text = "BAD RESPONSE"
                print("Error parsing JSON")
                print(error ?? "?")
            }
        }
        task.resume()
    }

}

