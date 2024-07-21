//
//  MainFeedView.swift
//  AvatarMaker
//
//  Created by Alexander Andriushchenko on 15.07.2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MainFeedReducer {
    
    //MARK: - Subtypes
    
    @ObservableState
    struct State: Equatable {
        var rows: IdentifiedArrayOf<MainFeedItem.State> = []
    }
    
    enum Action {
        case onFead
    }
    
    //MARK: - Property
    
    var body: some Reducer<State, Action> {
      Reduce { state, action in
        switch action {
        case .onFead:
            print("OnFeed")
            return .none
        }
      }
    }
}


struct MainFeedView: View {
    
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var store: StoreOf<MainFeedReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView{
                LazyVGrid(columns: self.columns) {
                    ForEach(viewStore.rows) { row in
                        MainFeedItemView(
                            store: Store(initialState: row, reducer: { MainFeedItem()})
                        )
                        .scaledToFill()
                    }
                }
            }
        }
    }
}


#Preview {
    NavigationView {
        MainFeedView(
            store: Store(
                initialState: MainFeedReducer.State(
                    rows: .mocks
                )
            ) {
                MainFeedReducer()
            }
        )
    }
    .navigationViewStyle(.stack)
}
