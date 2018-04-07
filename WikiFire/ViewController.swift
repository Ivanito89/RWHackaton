//
//  ViewController.swift
//  WikiFire
//
//  Created by Ivan Hjelmeland on 06/04/2018.
//  Copyright © 2018 Shortcut. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import GeoFire

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 59.9229, longitude: 10.7179), span: MKCoordinateSpan(latitudeDelta: 0.03157, longitudeDelta: 0.03218)), animated: false)

    }

    @IBAction func lol(_ sender: Any) {
        print("")
        queryAtRegion(radius: 0.5) // 0.5 = 500 meters.
    }

    func queryAtRegion (radius: Double) {

    }
}

