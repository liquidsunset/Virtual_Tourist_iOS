//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 30.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!

    @IBOutlet weak var noImagesLabel: UILabel!


    var pin: Pin!
    var photos = [Photo]()

    var stack: CoreDataStack!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false

        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self

        noImagesLabel.hidden = true
        centerMapToPin(Double(pin.latidude!), longitude: Double(pin.longitude!))
        mapView.addAnnotation(pin)

        if (photos.count == 0) {
            noImagesLabel.hidden = false
            newCollectionButton.enabled = false
            getPhotosFromFlickr()
            collectionView.reloadData()
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.stack.context.deleteObject(self.photos[indexPath.row])
        self.photos.removeAtIndex(indexPath.row)
        collectionView.deleteItemsAtIndexPaths([indexPath])
        self.stack.save()
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("albumCell", forIndexPath: indexPath) as! PhotoAlbumCell
        cell.pic = photos[indexPath.row]
        return cell
    }

    func getPhotosFromFlickr() {

        FlickrClient.sharedInstance.getPictures(nil, pin: self.pin, context: self.stack.context) {
            (photos, error) in
            print(photos.count)
            guard (error == nil) else {
                self.performUpdatesOnMain() {
                    self.showAlertMessage("Error", message: error!)
                }
                return
            }
            self.performUpdatesOnMain() {
                if (photos.count == 0) {
                    self.noImagesLabel.hidden = false
                } else {
                    self.stack.save()
                    self.noImagesLabel.hidden = true
                    self.photos = photos

                    self.collectionView.reloadData()
                    self.newCollectionButton.enabled = true
                }

            }

        }
    }

    func centerMapToPin(latitude: Double, longitude: Double) {
        let clLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        mapView.setRegion(MKCoordinateRegion(center: clLocation, span: span), animated: true)
    }

    func removePhotos() {
        pin.deletePhotosFromPin(stack)
        photos.removeAll()
        stack.save()
    }

    @IBAction func generateNewCollection(sender: AnyObject) {
        removePhotos()
        collectionView.reloadData()
        getPhotosFromFlickr()
    }
}