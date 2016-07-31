//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 24.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation

extension FlickrClient {

    struct Constants {
        static let BaseUrlSecure = "https://api.flickr.com/services/rest/"
        static let FlickrAPIKey = "f19e8bfcddc7e1f34f4779769e7e2cc4"
    }

    struct Methods {
        static let FlickrPhotoSearch = "flickr.photos.search"
    }

    struct URLParameterKeys {
        static let APIKey = "api_key"
        static let Method = "method"
        static let Lat = "lat"
        static let Lon = "lon"
        static let Radius = "radius"
        static let NoJsonCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
    }

    struct URLParameterValues {
        static let ResponseFormat = "json"
        static let NOJsonCallback = "1"
        static let Radius = 1 //in km
        static let PicsPerPage = 10
        static let UseSafeSearch = "1"
        static let MediumURL = "url_m"
        static let JsonFormat = "json"
    }

    struct JsonResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
        static let Id = "id"
    }

    struct JsonResponseValues {
        static let JsonOKStatus = "ok"
    }

}
