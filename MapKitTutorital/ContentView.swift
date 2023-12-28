//
//  ContentView.swift
//  MapKitTutorital
//
//  Created by Mohammad Azam on 9/12/23.
//

import SwiftUI
import MapKit

// Apple Campus: 37.33471927772464, -122.00896992317077
// Cupertino Village: 37.33594803602676, -122.01542259272111
// Menlo Park: 37.45334697008818, -122.18430315050811

struct ContentView: View {
    
    @State private var locationManager = LocationManager.shared
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    let artwork = ["appleCampus": "apple-park", "cupertinoVillage": "cupertino-village"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Map(position: $position) {
                UserAnnotation()
                
                // put a semi-transparent overlay circle
                MapCircle(center: .cupertinoVillage, radius: 50)
                    .foregroundStyle(.indigo.opacity(0.4))
                MapCircle(center: .appleCampus, radius: 50)
                    .foregroundStyle(.indigo.opacity(0.4))
            }
        }
        // whenever we enter a monitored region, show this sheet
        .sheet(item: $locationManager.locationEvent, content: { event in
            VStack {
                Image(artwork[event.identifier] ?? "apple-park")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                Text(event.identifier)
            }
        })
        .task {
            await locationManager.startMonitoringRegion()
        }
    }
}

#Preview {
    ContentView()
}
