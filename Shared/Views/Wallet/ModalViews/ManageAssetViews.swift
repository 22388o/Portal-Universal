//
//  ManageAssetViews.swift
//  Portal
//
//  Created by farid on 3/10/22.
//

import SwiftUI

struct ManageAssetsView: View {
    @ObservedObject private var viewModel: ManageAssetsViewModel
    
    init() {
        guard let viewModel = ManageAssetsViewModel.config() else {
            fatalError("\(#function) Cannot config ManageAssetsViewModel")
        }
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        ModalViewContainer(size: CGSize(width: 500, height: 450), {
            VStack {
                HStack {
                    Text("Manage assets")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                }
                .padding()
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.04))
                        .frame(height: 40)
                    
                    HStack {
                        Image("magnifyingglass")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    .padding(.horizontal, 21)
                    
                    if viewModel.search.isEmpty {
                        Text("Search")
                            .padding(.horizontal, 50)
                    }
                    TextField(String(), text: $viewModel.search)
                        .padding(.horizontal, 50)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .font(.mainFont(size: 15))
                .padding(.horizontal)
                
                List(viewModel.items) { item in
                    Erc20ItemView(item: item)
                        .listRowBackground(Color.clear)
                }
                .listStyle(SidebarListStyle())
                .animation(nil)
                .padding(.vertical)
            }
            .padding()
        })
    }
}

struct ManageAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAssetsView()
    }
}
