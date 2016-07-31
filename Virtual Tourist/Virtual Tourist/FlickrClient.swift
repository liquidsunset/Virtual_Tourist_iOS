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

    func getPictures(pin: Pin, context: NSManagedObjectContext, completionHandler: (success:Bool, errorMessage:String?) -> Void) {
        
        let urlString = createFlickrUrlString(Double(pin.latidude!), lon: Double(pin.longitude!))
        print(urlString)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in

            guard (error == nil) else {
                return completionHandler(success: false, errorMessage: error?.description)
            }

            guard let data = data else {
                completionHandler(success: false, errorMessage: "No data received")
                return
            }

            Utility.parseJSONWithCompletionHandler(data) {
                (parsedJsonResult, error) in
                guard (error == nil) else {
                    completionHandler(success: false, errorMessage: "Failed to parse Data")
                    return
                }

                guard let parsedJsonResult = parsedJsonResult else {
                    completionHandler(success: false, errorMessage: "Failed to parse Data")
                    return
                }

                guard let status = parsedJsonResult[JsonResponseKeys.Status] as? String where status == JsonResponseValues.JsonOKStatus else {
                    completionHandler(success: false, errorMessage: "Failure in JSON-Response")
                    return
                }

                guard let photosDic = parsedJsonResult[JsonResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler(success: false, errorMessage: "Error getting photo-dic")
                    return
                }

                guard let photoArray = photosDic[JsonResponseKeys.Photo] as? [[String:AnyObject]] else {
                    completionHandler(success: false, errorMessage: "Error creating photo-array")
                    return
                }

                guard (photoArray.count != 0) else {
                    completionHandler(success: false, errorMessage: "No photos found")
                    return
                }

                for photo in photoArray {

                    guard let imageURL = photo[JsonResponseKeys.MediumURL] as? String else {
                        completionHandler(success: false, errorMessage: "No URL for Picture")
                        return
                    }

                    guard let imgID = photo[JsonResponseKeys.Id] as? String else {
                        completionHandler(success: false, errorMessage: "No ID for Picture found")
                        return
                    }

                    let persistenPhoto = Photo(url: imageURL, id: imgID, context: context)
                    persistenPhoto.pin = pin
                }
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let stack = delegate.stack
                stack.save()
                
                completionHandler(success: true, errorMessage: nil)
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

    private func createFlickrUrlString(lat: Double, lon: Double) -> String {
        let urlParameters: [String: AnyObject] = [
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
        let urlString = Constants.BaseUrlSecure + Utility.escapedParameters(urlParameters)
        return urlString
    }

}