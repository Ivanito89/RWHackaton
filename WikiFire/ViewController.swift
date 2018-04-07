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

        let location : CLLocation = CLLocation.init(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)

        let geoFireReference = Database.database().reference()
        let geoFire = GeoFire.init(firebaseRef: geoFireReference.child("geotags"))
        let radiusQuery = geoFire.query(at: location, withRadius: radius)

        radiusQuery.observe(GFEventType.keyEntered, with: { (key: String?, location: CLLocation?) in

            print("Key '%@' entered the search area and is at location '%@'", key!, location!)

        })
    }
}

