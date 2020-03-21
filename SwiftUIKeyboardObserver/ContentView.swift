//
//  ContentView.swift
//  SwiftUIKeyboardObserver
//
//  Created by Toomas Vahter on 21.03.2020.
//  Copyright © 2020 Augmented Code. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Ellipse().foregroundColor(.red)
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            Text("Welcome").font(.title)
            Text("Please enter your name")
            TextField("Name", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
        }.keyboardVisibility()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
