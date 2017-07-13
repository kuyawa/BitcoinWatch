//
//  Ticker.swift
//  BitcoinWatch
//
//  Created by Laptop on 7/12/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

class Ticker {
    var coins = [Coin]()
    var count: Int { get { return coins.count } }
    
    convenience init(json: String) {
        self.init()
        let list = json.parseList()
        var data = [Coin]()
        
        for item in list {
            let coin = Coin()
            coin.id          = item["id"].string
            coin.name        = item["name"].string
            coin.symbol      = item["symbol"].string
            coin.rank        = item["rank"].int
            coin.priceUsd    = item["price_usd"].double
            coin.priceBtc    = item["price_btc"].double
            coin.volumeUsd   = Double((item["24h_volume_usd"]     as? String) ?? "0.0") ?? 0.0
            coin.marketUsd   = Double((item["market_cap_usd"]     as? String) ?? "0.0") ?? 0.0
            coin.available   = Double((item["available_supply"]   as? String) ?? "0.0") ?? 0.0
            coin.totalSupply = Double((item["total_supply"]       as? String) ?? "0.0") ?? 0.0
            coin.totalSupply = Double((item["total_supply"]       as? String) ?? "0.0") ?? 0.0
            coin.change01h   = Double((item["percent_change_1h"]  as? String) ?? "0.0") ?? 0.0
            coin.change24h   = Double((item["percent_change_24h"] as? String) ?? "0.0") ?? 0.0
            coin.change24h   = Double((item["percent_change_7d"]  as? String) ?? "0.0") ?? 0.0
            coin.trend       = (coin.change01h == 0 ? 0 : (coin.change01h > 0 ? 1 : 2))
            coin.updated     = Int((item["last_updated"] as? String) ?? "0") ?? 0
            //coins.append(coin)
            data.append(coin)
        }
        
        // Sorted by symbol
        let sorted = data.sorted { $0.symbol < $1.symbol }
        for coin in sorted {
            coins.append(coin)
        }
    }
    
    func getCoin(_ symbol: String) -> Coin? {
        for coin in coins {
            if coin.symbol == symbol { return coin }
        }
        return nil
    }
    
    func show() {
        for coin in coins {
            print(coin.text)
        }
    }
    
    func show2() {
        for coin in coins {
            print(coin.text2)
        }
    }
    
}

class Coin {
    var id          = "bitcoin"
    var name        = "Bitcoin"
    var symbol      = "BTC"
    var rank        = 0
    var priceUsd    = 0.0
    var priceBtc    = 0.0
    var volumeUsd   = 0.0
    var marketUsd   = 0.0
    var available   = 0.0
    var totalSupply = 0.0
    var change01h   = 0.0
    var change24h   = 0.0
    var change07d   = 0.0
    var trend       = 0    // 0:same 1:up 2: down
    var updated     = 0
    
    var text:  String { get { return String(format: "%5@ %25@ %10.04f", symbol.pad(5), name.pad(25), priceUsd) } }
    var text2: String { get { return "\(symbol.pad(5)) \(name.pad(20)) \(priceUsd.format(10,4))" } }
    
}



// MARK EXTENSIONS

typealias Datamap = [String: Any]
typealias Listmap = [Datamap]

extension String {
    
    func pad(_ n: Int, _ text: String = " ") -> String {
        let ini = 0
        return self.padding(toLength: n, withPad: text, startingAt: ini)
    }
    
    func parse() -> Datamap {
        var dixy = Datamap()
        
        do {
            let data = self.data(using: .utf8)!
            dixy = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Datamap
        } catch {
            print("JSON.error: ", error)
        }
        
        return dixy
    }
    
    func parseList() -> Listmap {
        var list = Listmap()
        
        do {
            let data = self.data(using: .utf8)!
            list = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Listmap
        } catch {
            print("JSON.error: ", error)
        }
        
        return list
    }
    
}

extension Double {
    func format(_ num: Int, _ dec: Int = 2) -> String {
        let fmt = "\(num).\(dec)"
        return String(format: "%\(fmt)f", self)
    }
    
    func toMillions() -> String {
        if self < 1000000 { return self.format(8, 2) }
        let value = Int(self / 1000000)
        return value.toThousands() + " M"
    }
}

extension Int {
    func toThousands() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        //formatter.locale = Locale.current
        return formatter.string(for: self) ?? "0"
    }
}

extension Date {
    static func epoch(_ time: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(time))
    }
    
    // APR 25, 8:35 AM
    func short() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm a"
        let text = formatter.string(from: self).uppercased()
        return text
    }
}

extension Optional {
    var string: String {
        get {
            return self as? String ?? ""
        }
    }
    
    var int: Int {
        get {
            return Int(self as? String ?? "0") ?? 0
        }
    }
    
    var double: Double {
        get {
            return Double(self as? String ?? "0.0") ?? 0.0
        }
    }
}


// END
