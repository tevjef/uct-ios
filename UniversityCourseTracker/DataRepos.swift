//
//  DataRepos.swift
//  Hello World
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL = "http://uct.tevindev.me:8080/v2/"

func getUniversities(universities: (Array<Common.University>?) -> Void) {
    let request = Alamofire.request(.GET, BASE_URL + "universities")
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            universities(resp.data.universities)
        } catch {
            universities(nil)
        }
        
    }
}

func getUniversity(searchFlow: SearchFlow, university: (Common.University?) -> Void) {
    let request = Alamofire.request(.GET, BASE_URL + "university/" +  searchFlow.universityTopic!)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            university(resp.data.university)
        } catch {
            university(nil)
        }
    }
}

struct SearchFlow {
    var universityTopic: String?
    var season: String?
    var year: Int64?
    var subjectTopic: String?
    var courseTopic: String?
}