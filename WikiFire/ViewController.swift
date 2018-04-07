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

        map.delegate = self
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 59.9229, longitude: 10.7179), span: MKCoordinateSpan(latitudeDelta: 0.03157, longitudeDelta: 0.03218)), animated: false)

    }

    @IBAction func lol(_ sender: Any) {
        queryAtRegion(radius: 0.2) // 0.2 = 200 meters.
    }

    func queryAtRegion (radius: Double) {

        map.removeAnnotations(map.annotations)

        let location : CLLocation = CLLocation.init(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)

        let geoFireReference = Database.database().reference()
        let geoFire = GeoFire.init(firebaseRef: geoFireReference.child("geotags"))
        let radiusQuery = geoFire.query(at: location, withRadius: radius)

        radiusQuery.observe(GFEventType.keyEntered, with: { (key: String?, location: CLLocation?) in

            print("Key '%@' entered the search area and is at location '%@'", key!, location!)

            let point = MKPointAnnotation()
            point.title = key
            point.coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)

            DispatchQueue.main.async {
                self.map.addAnnotation(point)
            }

        })
    }
}

extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation) else {
            return nil
        }

        let annotationIdentifier = "AnnotationIdentifier"

        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "wiki")
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        let annot = view.annotation as! MKPointAnnotation

        if UIApplication.shared.canOpenURL(URL.init(string: String(format: "https://no.wikipedia.org/?curid=%@", annot.title!))!) {
            UIApplication.shared.openURL(URL.init(string: String(format: "https://no.wikipedia.org/?curid=%@", annot.title!))!)
        }
    }

}

