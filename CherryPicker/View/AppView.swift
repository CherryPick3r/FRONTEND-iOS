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
    @State private var restaurantId: Int?
    @State private var gameCategory: GameCategory?
    
    var body: some View {
        if isCherryPick {
            CherryPickView(isCherryPick: $isCherryPick, isCherryPickDone: $isCherryPickDone, restaurantId: $restaurantId, gameCategory: $gameCategory, cherryPickMode: .cherryPick)
                .environmentObject(userViewModel)
        } else if isCherryPickDone, let shopId = restaurantId {
            RestaurantDetailView(isCherryPick: $isCherryPick, isCherryPickDone: $isCherryPickDone, restaurantId: shopId)
                .environmentObject(userViewModel)
        } else {
            StartView(isCherryPick: $isCherryPick, gameCategory: $gameCategory)
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
