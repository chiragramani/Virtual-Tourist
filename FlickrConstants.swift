//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Chirag Ramani on 18/06/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation

extension FlickrClient
{

    struct Constants {
        
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            static let SearchBBoxHalfWidth = 1.0
            static let SearchBBoxHalfHeight = 1.0
        }
        
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let BoundingBox = "bbox"
            static let Page = "page"
            static let perPage = "per_page"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "08bc834a28f18be56bb7e002a3b8721d"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
            static let perPage = 22
        }
    struct JSONResponseKeys {
        
        static let Pages = "pages"
        static let Photos = "photos"
        static let Photo = "photo"
    }

        
       
    
    }





