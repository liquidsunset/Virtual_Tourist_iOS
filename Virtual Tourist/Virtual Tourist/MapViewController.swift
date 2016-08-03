//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 26.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var stack: CoreDataStack!
    var lastPin: Pin! = nil

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

        stack = delegate.stack

        setSavedMapPosition()
        fetchAnnotations()
        mapView.delegate = self

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(lpgr)

    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapPosition()
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)

        let photoAlbumVC = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController

        var pin: Pin!

        do {
            let fr = NSFetchRequest(entityName: "Pin")
            fr.fetchLimit = 1
            var predicate = [NSPredicate]()
            predicate.append(NSPredicate(format: "latidude = %@", argumentArray: [(view.annotation?.coordinate.latitude)!]))
            predicate.append(NSPredicate(format: "longitude = %@", argumentArray: [(view.annotation?.coordinate.longitude)!]))

            fr.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)

            let pins = try stack.context.executeFetchRequest(fr) as? [Pin]
            pin = pins![0]
        } catch {
            print("Error")
        }

        photoAlbumVC.pin = pin
        photoAlbumVC.stack = stack
        if let photos = pin!.photos?.array as? [Photo] {
            photoAlbumVC.photos = photos
        }

        navigationController?.pushViewController(photoAlbumVC, animated: true)

    }


    private func saveMapPosition() {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: Constants.MapSpanLatitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: Constants.MapSpanLongitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: Constants.MapLatidude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: Constants.MapLongitude)
    }

    private func setSavedMapPosition() {
        let mapSpanLat = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.MapSpanLatitude)
        let mapSpanLong = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.MapSpanLongitude)
        let lat = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.MapLatidude)
        let long = NSUserDefaults.standardUserDefaults().doubleForKey(Constants.MapLongitude)

        let clLocation: CLLocationCoordinate2D
        let span: MKCoordinateSpan

        if (lat == 0 && long == 0 && mapSpanLat == 0 && mapSpanLong == 0) {
            print("first launch, no saved data!")
            clLocation = CLLocationCoordinate2D(latitude: 47.4, longitude: 8.5)
            span = MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        } else {
            clLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            span = MKCoordinateSpan(latitudeDelta: mapSpanLat, longitudeDelta: mapSpanLong)
        }

        mapView.setRegion(MKCoordinateRegion(center: clLocation, span: span), animated: true)
    }

    func handleLongPress(longPress: UIGestureRecognizer) {
        let coordinates: CLLocationCoordinate2D = mapView.convertPoint(longPress.locationOfTouch(0, inView: mapView), toCoordinateFromView: mapView)

        switch longPress.state {
        case .Began:
            lastPin = Pin(latidude: coordinates.latitude, longitude: coordinates.longitude, context: stack.context)
            mapView.addAnnotation(lastPin)
        case .Changed:
            lastPin.willChangeValueForKey("coordinate")
            lastPin.coordinate = coordinates
            lastPin.didChangeValueForKey("coordinate")
        case .Ended:
            stack.save()
        default:
            return
        }

    }

    func fetchAnnotations() {
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: true), NSSortDescriptor(key: "latidude", ascending: false)]

        do {
            if let pins = try? stack.context.executeFetchRequest(fr) as! [Pin] {
                mapView.addAnnotations(pins)
            }
        }
    }
}

extension MapViewController {

    struct Constants {
        static let MapSpanLatitude = "mapSpanLatitude"
        static let MapSpanLongitude = "mapSpanLongitude"
        static let MapLatidude = "mapLatidude"
        static let MapLongitude = "mapLongitude"
    }

}
