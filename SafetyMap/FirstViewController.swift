//
//  FirstViewController.swift
//  SafetyMap
//
//  Created by Yanbo Fang on 10/29/16.
//  Copyright © 2016 Yanbo Fang. All rights reserved.
//

import UIKit
import ArcGIS

let webmapID = "ab944a9507b84b9abf692660ea29c3ff"

class FirstViewController: UIViewController, AGSCalloutDelegate, AGSWebMapDelegate, UIAlertViewDelegate, AGSPopupsContainerDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var webmap: AGSWebMap!
    var popups = [AGSPopup]()
    
    struct Notification {
        var name: String
        var lat: Double
        var lng : Double
    }
    
    var receiver_id: Int = 0 {
        didSet {
            downloadData()
        }
    }
    var notifications = [Notification]()
    
    func downloadData() {
        let url = NSURL(string: "http://hoopsapp.netai.net/safe/receiver.php?receiver_id=2" + String(receiver_id))
        let request = URLRequest(url: url as! URL)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("request failed \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as?
                    [AnyObject] {
                    for index in 0...json.count-1 {
                        if let item = json[index] as? [String: AnyObject] {
                            if let name = item["name"] as? String {
                                self.notifications.append(Notification(
                                    name: item["name"] as! String,
                                    lat: Double(item["lat"] as! String)!,
                                    lng: Double(item["lng"] as! String)!
                                ))
                            }
                        }
                    }
                }
            } catch let parseError {
                print("parsing error: \(parseError)")
                let responseString = String(data: data, encoding: .utf8)
                print("raw response: \(responseString)")
            }
        }
        task.resume()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.callout.delegate = self
        
        let url = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer")
        let tiledLayer = AGSTiledMapServiceLayer(url: url?.absoluteURL)
        self.mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")
        
        webmap = AGSWebMap(itemId: webmapID, credential: nil)
        webmap.delegate = self
        webmap.open(into: mapView)
    }
    
}

