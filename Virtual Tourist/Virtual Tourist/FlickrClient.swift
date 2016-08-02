//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 24.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrClient {

    static let sharedInstance = FlickrClient()

    func getPictures(pageNumber: Int?, pin: Pin, context: NSManagedObjectContext, completionHandler: (photos:[Photo]!, errorMessage:String?) -> Void) {

        let urlString = createFlickrUrlString(pageNumber, lat: Double(pin.latidude!), lon: Double(pin.longitude!))

        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in

            guard (error == nil) else {
                return completionHandler(photos: nil, errorMessage: error?.description)
            }

            guard let data = data else {
                completionHandler(photos: nil, errorMessage: "No data received")
                return
            }

            Utility.parseJSONWithCompletionHandler(data) {
                (parsedJsonResult, error) in
                guard (error == nil) else {
                    completionHandler(photos: nil, errorMessage: "Failed to parse Data")
                    return
                }

                guard let parsedJsonResult = parsedJsonResult else {
                    completionHandler(photos: nil, errorMessage: "Failed to parse Data")
                    return
                }

                guard let status = parsedJsonResult[JsonResponseKeys.Status] as? String where status == JsonResponseValues.JsonOKStatus else {
                    completionHandler(photos: nil, errorMessage: "Failure in JSON-Response")
                    return
                }

                guard let photosDic = parsedJsonResult[JsonResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler(photos: nil, errorMessage: "Error getting photo-dic")
                    return
                }

                if (pageNumber == nil) {
                    guard let pages = photosDic[JsonResponseKeys.Pages] as? Int else {
                        completionHandler(photos: nil, errorMessage: "No Flickr Photo-Page found")
                        return
                    }
                    let pageLimit = min(pages, 40)
                    let random = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                    self.getPictures(random, pin: pin, context: context, completionHandler: completionHandler)

                } else {

                    guard let photoArray = photosDic[JsonResponseKeys.Photo] as? [[String:AnyObject]] else {
                        completionHandler(photos: nil, errorMessage: "Error creating photo-array")
                        return
                    }

                    guard (photoArray.count != 0) else {
                        completionHandler(photos: nil, errorMessage: "No photos found")
                        return
                    }

                    var persistentPhotosArray = [Photo]()
                    for photo in photoArray {

                        guard let imageURL = photo[JsonResponseKeys.MediumURL] as? String else {
                            completionHandler(photos: nil, errorMessage: "No URL for Picture")
                            return
                        }

                        guard let imgID = photo[JsonResponseKeys.Id] as? String else {
                            completionHandler(photos: nil, errorMessage: "No ID for Picture found")
                            return
                        }

                        let persistentPhoto = Photo(url: imageURL, id: imgID, context: context)
                        persistentPhoto.pin = pin
                        persistentPhotosArray.append(persistentPhoto)
                    }

                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let stack = delegate.stack
                    stack.save()

                    completionHandler(photos: persistentPhotosArray, errorMessage: nil)
                }
            }

        }


        task.resume()

    }

    func loadImageFromUrl(url: String, completionHandler: (image:NSData!, errorMessage:String?) -> Void) {
        let url = NSURL(string: url)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in

            guard (error == nil) else {
                completionHandler(image: nil, errorMessage: error?.localizedDescription)
                return
            }

            guard let data = data else {
                completionHandler(image: nil, errorMessage: "Error Downloading Photo")
                return
            }

            completionHandler(image: data, errorMessage: nil)

        }

        task.resume()

    }

    private func createFlickrUrlString(pageNumber: Int?, lat: Double, lon: Double) -> String {
        var urlParameters: [String:AnyObject] = [
                URLParameterKeys.APIKey: Constants.FlickrAPIKey,
                URLParameterKeys.SafeSearch: URLParameterValues.UseSafeSearch,
                URLParameterKeys.Extras: URLParameterValues.MediumURL,
                URLParameterKeys.Method: Methods.FlickrPhotoSearch,
                URLParameterKeys.PerPage: URLParameterValues.PicsPerPage,
                URLParameterKeys.Format: URLParameterValues.JsonFormat,
                URLParameterKeys.Lat: lat,
                URLParameterKeys.Lon: lon,
                URLParameterKeys.Radius: URLParameterValues.Radius,
                URLParameterKeys.NoJsonCallback: URLParameterValues.NOJsonCallback
        ]
        if (pageNumber == nil) {
        } else {
            urlParameters[URLParameterKeys.Page] = pageNumber
        }
        return Constants.BaseUrlSecure + Utility.escapedParameters(urlParameters)

    }

}