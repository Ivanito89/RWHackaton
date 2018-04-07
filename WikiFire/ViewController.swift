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
import DrawerKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var infoView: RoundedView!
    @IBOutlet weak var infoLabel: UILabel!

    var drawerDisplayController: DrawerDisplayController?

    var infoShown: Bool? {
        didSet {
            if infoShown == true {
                self.infoLabel.alpha = 0.0
                self.infoLabel.text = "Great! The hearts are geotagged Wikipedia-articles. Tap one!"
                self.infoLabel.fadeIn()
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
            point.subtitle = "Tap me! 💌"
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

        /*if UIApplication.shared.canOpenURL(URL.init(string: String(format: "https://no.wikipedia.org/?curid=%@", annot.title!))!) {
            UIApplication.shared.open(URL.init(string: String(format: "https://no.wikipedia.org/?curid=%@", annot.title!))!, options: [:]) { (success) in }
        }*/

        mapView.deselectAnnotation(view.annotation, animated: true)

        doModalPresentation(curid: annot.title!)
    }

    func updateCenter() {

        for overlay in map.overlays {
            if overlay is MKCircle {
                map.remove(overlay)
            }
        }

        let circle = MKCircle(center: map.centerCoordinate, radius: 200.0)
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

extension ViewController: DrawerCoordinating {

    func doModalPresentation(curid: String) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "presented")
            as? PresentedViewController else { return }

        vc.curid = curid

        // you can provide the configuration values in the initialiser...
        var configuration = DrawerConfiguration(/* ..., ..., ..., */)

        // ... or after initialisation. All of these have default values so change only
        // what you need to configure differently. They're all listed here just so you
        // can see what can be configured. The values listed are the default ones,
        // except where indicated otherwise.
        configuration.totalDurationInSeconds = 0.4
        configuration.durationIsProportionalToDistanceTraveled = false
        // default is UISpringTimingParameters()
        configuration.timingCurveProvider = UISpringTimingParameters(dampingRatio: 0.8)
        configuration.fullExpansionBehaviour = .coversFullScreen
        configuration.supportsPartialExpansion = true
        configuration.dismissesInStages = true
        configuration.isDrawerDraggable = true
        configuration.isFullyPresentableByDrawerTaps = true
        configuration.numberOfTapsForFullDrawerPresentation = 1
        configuration.isDismissableByOutsideDrawerTaps = true
        configuration.numberOfTapsForOutsideDrawerDismissal = 1
        configuration.flickSpeedThreshold = 3
        configuration.upperMarkGap = 100 // default is 40
        configuration.lowerMarkGap =  80 // default is 40
        configuration.maximumCornerRadius = 15

        var handleViewConfiguration = HandleViewConfiguration()
        handleViewConfiguration.autoAnimatesDimming = true
        handleViewConfiguration.backgroundColor = .gray
        handleViewConfiguration.size = CGSize(width: 40, height: 6)
        handleViewConfiguration.top = 8
        handleViewConfiguration.cornerRadius = .automatic
        configuration.handleViewConfiguration = handleViewConfiguration

        let drawerShadowConfiguration = DrawerShadowConfiguration(shadowOpacity: 0.6,
                                                                  shadowRadius: 4,
                                                                  shadowOffset: .zero,
                                                                  shadowColor: UIColor.lightGray)
        configuration.drawerShadowConfiguration = drawerShadowConfiguration // default is nil

        drawerDisplayController = DrawerDisplayController(presentingViewController: self,
                                                          presentedViewController: vc,
                                                          configuration: configuration,
                                                          inDebugMode: false)

        present(vc, animated: true)
    }

}

