//
//  Utility.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 29.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation

class Utility {
    class func parseJSONWithCompletionHandler(data: NSData, completionHandlerForJSONData: (result:AnyObject!, error:String?) -> Void) {

        var parsedResult: AnyObject!

        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {

            completionHandlerForJSONData(result: nil, error: "Could not parse the data as JSON!!! data: \(data)'")
        }

        completionHandlerForJSONData(result: parsedResult, error: nil)
    }

    class func escapedParameters(parameters: [String:AnyObject]) -> String {

        var urlVars = [String]()

        for (key, value) in parameters {

            /* Make sure that it is a string value */
            let stringValue = "\(value)"

            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]

        }

        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}
