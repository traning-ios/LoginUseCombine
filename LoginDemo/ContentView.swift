//
//  ContentView.swift
//  LoginDemo
//
//  Created by Le Xuan Quynh on 2020/06/17.
//  Copyright © 2020 Le Xuan Quynh. All rights reserved.
//

import SwiftUI

struct ContentView: View {

  @ObservedObject private var userViewModel = UserViewModel()

  var body: some View {
    Form {
      Section(footer: Text(userViewModel.usernameMessage).foregroundColor(.red)) {
        TextField("Username", text: $userViewModel.username)
          .autocapitalization(.none)
        }
        Section(footer: Text(userViewModel.passwordMessage).foregroundColor(.red)) {
          SecureField("Password", text: $userViewModel.password)
          SecureField("Password again", text: $userViewModel.passwordAgain)
       }
       Section {
         Button(action: { }) {
           Text("Sign up")
         }.disabled(!userViewModel.isValid)
       }
     }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
