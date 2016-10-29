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

