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
    @IBOutlet weak var infoView: RoundedView!
    @IBOutlet weak var infoLabel: UILabel!

    var infoShown: Bool? {
        didSet {
            if infoShown == true {
                self.infoLabel.text = "Good job! The hearts are geotagged Wikipedia-articles. Tap one!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) { // change 2 to desired number of seconds
                    self.infoView.fadeOut()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 59.9239, longitude: 10.7069), span: MKCoordinateSpan(latitudeDelta: 0.01553, longitudeDelta: 0.01316)), animated: false)

        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = map.centerCoordinate
        mapCamera.pitch = 50
        mapCamera.altitude = 1000
        mapCamera.heading = 360
        map.camera = mapCamera

        updateCenter()

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.mapViewDidDrag))
        gesture.delegate = self
        map.addGestureRecognizer(gesture)

        infoShown = false
    }

    func queryAtRegion (radius: Double) {

        map.removeAnnotations(map.annotations)

        let location : CLLocation = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)

        let geoFireReference = Database.database().reference()
        let geoFire = GeoFire.init(firebaseRef: geoFireReference.child("geotags"))
        let radiusQuery = geoFire.query(at: location, withRadius: radius)

        radiusQuery.observe(GFEventType.keyEntered, with: { (key: String?, location: CLLocation?) in

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
            annotationView.centerOffset.y = -22.0
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        let annot = view.annotation as! MKPointAnnotation

        if UIApplication.shared.canOpenURL(URL.init(string: String(format: "https://no.wikipedia.org/?curid=%@", annot.title!))!) {
            UIApplication.shared.open(URL.init(string: String(format: "https://no.wikipedia.org/?curid=%@", annot.title!))!, options: [:]) { (success) in }
        }
    }

    func updateCenter() {

        for overlay in map.overlays {
            if overlay is MKCircle {
                map.remove(overlay)
            }
        }

        let circle = MKCircle(center: map.centerCoordinate, radius: 300.0)
        map.add(circle)

    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.lineDashPattern = [2, 5]
            circle.strokeColor = UIColor.blue.withAlphaComponent(0.4)
            circle.fillColor = UIColor.blue.withAlphaComponent(0.05)
            circle.lineWidth = 1
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateCenter()
        queryAtRegion(radius: 0.2) // 0.2 = 200 meters.

        if infoShown == false {
            infoShown = true
        }
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        updateCenter()
    }

}

extension ViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func mapViewDidDrag () {
        updateCenter()
    }
}

