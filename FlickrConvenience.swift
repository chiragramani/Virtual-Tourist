//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 18/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient
{
    
    func fetchPhotosForLocationFromFlickr(newPin:Bool,pin:Pins,completionHandler:(success: Bool, errorString: String?) -> Void) {
        var parameters = [String: AnyObject]()
        let minimumLon = pin.longitude as! Double - FlickrClient.Constants.SearchBBoxHalfWidth
        let minimumLat = pin.latitude as! Double - FlickrClient.Constants.SearchBBoxHalfHeight
        let maximumLon = pin.longitude as! Double + FlickrClient.Constants.SearchBBoxHalfWidth
        let maximumLat = pin.latitude as! Double + FlickrClient.Constants.SearchBBoxHalfHeight
        let boundingBox="\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        
        parameters = [FlickrClient.FlickrParameterKeys.Method:FlickrClient.FlickrParameterValues.SearchMethod,
                      FlickrClient.FlickrParameterKeys.APIKey:FlickrClient.FlickrParameterValues.APIKey,
                      FlickrClient.FlickrParameterKeys.BoundingBox:boundingBox,
                      FlickrClient.FlickrParameterKeys.SafeSearch:FlickrClient.FlickrParameterValues.UseSafeSearch,
                      FlickrClient.FlickrParameterKeys.Extras:FlickrClient.FlickrParameterValues.MediumURL,
                      FlickrClient.FlickrParameterKeys.perPage:FlickrClient.FlickrParameterValues.perPage,
                      FlickrClient.FlickrParameterKeys.Format:FlickrClient.FlickrParameterValues.ResponseFormat,
                      FlickrClient.FlickrParameterKeys.NoJSONCallback:FlickrClient.FlickrParameterValues.DisableJSONCallback ]
        if(newPin)
        {
            parameters[FlickrClient.FlickrParameterKeys.Page] = "1"
        }
        else
        {
            let totalPages=UInt32(pin.totalNumberOfPages!)
            let randomPageNumber=Int(arc4random_uniform(totalPages!)+1)
            parameters[FlickrClient.FlickrParameterKeys.Page] = "\(randomPageNumber)"
        }
        
        taskForGETMethod(parameters) { (results, error) in
            if let error=error {
                if error.localizedDescription == "The Internet connection appears to be offline"
                {
                completionHandler(success: false, errorString: "The Internet connection appears to be offline.")
                }
                else
                {
                completionHandler(success: false, errorString: "Invalid Request")
                }
                
            }
            else
            {
                guard let response=results[FlickrClient.JSONResponseKeys.Photos] as? [String: AnyObject] else
                {
                    completionHandler(success: false, errorString: "Invalid response")
                    return
                }
                
                
                guard let pages=response[FlickrClient.JSONResponseKeys.Pages] as? Int else
                {
                    completionHandler(success: false, errorString: "Invalid response")
                    return
                }
                
                pin.totalNumberOfPages = "\(pages)"
                
                guard let photos=response[FlickrClient.JSONResponseKeys.Photo] as? [[String: AnyObject]] else
                {
                    completionHandler(success: false, errorString: "Invalid response")
                    return
                }
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let stack = delegate.stack
                completionHandler(success: true, errorString: nil)
                
                for photo in photos
                {
                    guard let url = photo[FlickrClient.FlickrParameterValues.MediumURL] as? String  else
                    {
                        completionHandler(success: false, errorString: "Invalid response")
                        return
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        Photos(pin: pin, filePath: url, context:stack.context )
                    }
                }
            }
        }
    }
    
    
    func downloadImage(photo:Photos,completionHandler:(success: Bool, errorString: String?) -> Void)
    {
        let downloadTask=NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: photo.filePath!)!)
        { (data, reponse, error) in
            
            guard error == nil else
            {
                completionHandler(success: false, errorString: "Cannot download image")
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                photo.photo=data!
                completionHandler(success: true, errorString: nil)
            }
        }
        downloadTask.resume()
    }
}


