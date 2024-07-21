//
//  MainFeedItemView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 17.07.2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MainFeedItem {
    struct State: Equatable, Identifiable {
        let id: UUID
        let title: String
        let inapp: String
    }
    
    enum Action {
        case onItem(MainFeedItem.State)
    }
}


struct MainFeedItemView: View {
    
    var store: StoreOf<MainFeedItem>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
//            Button {
//                store.send(.onItem(viewStore.state))
//            }
            
            VStack {
                ZStack {
                    Image(viewStore.inapp)
                        .resizable()
                        .scaledToFit()
                }
                Text("\(viewStore.title)")
                    .font(.system(size: 12))
                    .bold()
                Spacer()
            }.frame(alignment: .center)
        }
    }
}

extension IdentifiedArray where ID == MainFeedItem.State.ID,  Element == MainFeedItem.State {
  static let mocks: Self = [
    MainFeedItem.State(id: UUID(), title: "Love UA", inapp: "LoveUAFlag"),
    MainFeedItem.State(id: UUID(), title: "Good Evening!", inapp: "ShevchenkoHouse"),
    MainFeedItem.State(id: UUID(), title: "Love UA", inapp: "LoveUAFlag"),
    MainFeedItem.State(id: UUID(), title: "Good Evening!", inapp: "ShevchenkoHouse"),
    MainFeedItem.State(id: UUID(), title: "Love UA", inapp: "LoveUAFlag"),
    MainFeedItem.State(id: UUID(), title: "Good Evening!", inapp: "ShevchenkoHouse"),
  ]
}

#Preview {
    NavigationView {
        MainFeedItemView(
            store: Store(
                initialState: MainFeedItem.State(
                    id: UUID(),
                    title: "I LOVE UA!",
                    inapp: "LoveUAFlag")
            ) {
                MainFeedItem()
            }
        )
    }
    .navigationViewStyle(.stack)
}


