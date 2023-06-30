//
//  FacilityModel.swift
//  Radius
//
//  Created by iMac on 29/06/23.
//

import Foundation

struct FacilityModel: Codable {

    var facilities: [Facilities]?
    var exclusions: [[Exclusions]]?

    private enum CodingKeys: String, CodingKey {
        case facilities = "facilities"
        case exclusions = "exclusions"
    }
}

struct Facilities: Codable {

    var facilityId: String?
    var name: String?
    var options: [Options]?

    private enum CodingKeys: String, CodingKey {
        case facilityId = "facility_id"
        case name = "name"
        case options = "options"
    }

}

struct Options: Codable {

    var name: String?
    var icon: String?
    var id: String?

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case icon = "icon"
        case id = "id"
    }

}

struct Exclusions: Codable {

    var facility_id : String?
    var options_id : String?

    private enum CodingKeys: String, CodingKey {
        case facility_id = "facility_id"
        case options_id = "options_id"
    }
}
