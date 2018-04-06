//
//  ViewController.swift
//  WikiFire
//
//  Created by Ivan Hjelmeland on 06/04/2018.
//  Copyright © 2018 Shortcut. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 59.922940920663507, longitude: 10.717919865631757), span: MKCoordinateSpan.init(latitudeDelta: 0.031573216609345423, longitudeDelta: 0.032186511131243378)), animated: false)

    }

    @IBAction func lol(_ sender: Any) {
        print("")
    }
}

