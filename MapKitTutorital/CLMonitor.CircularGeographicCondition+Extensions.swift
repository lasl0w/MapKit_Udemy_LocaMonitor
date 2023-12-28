//
//  CLMonitor.CircularGeographicCondition+Extensions.swift
//  MapKitTutorital
//
//  Created by Mohammad Azam on 9/13/23.
//

import Foundation
import MapKit

extension CLMonitor.CircularGeographicCondition {
    
    static var cupertinoVillage: CLMonitor.CircularGeographicCondition {
        CLMonitor.CircularGeographicCondition(center: .cupertinoVillage, radius: 50)
    }
    
    static var appleCampus: CLMonitor.CircularGeographicCondition {
        CLMonitor.CircularGeographicCondition(center: .appleCampus, radius: 50)
    }
    
}

