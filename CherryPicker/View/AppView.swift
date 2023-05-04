//
//  AppView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/04.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var isCherryPick = false
    @State private var isCherryPickDone = false
    
    var body: some View {
        if isCherryPick {
            CherryPickView(isCherryPick: $isCherryPick, isCherryPickDone: $isCherryPickDone, cherryPickMode: .cherryPick)
                .environmentObject(userViewModel)
        } else if isCherryPickDone {
            RestaurantDetailView(isCherryPick: $isCherryPick, isCherryPickDone: $isCherryPickDone)
                .environmentObject(userViewModel)
        } else {
            StartView(isCherryPick: $isCherryPick)
                .environmentObject(userViewModel)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(UserViewModel())
    }
}