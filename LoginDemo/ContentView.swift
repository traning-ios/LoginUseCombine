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
        TextField("Tên đăng nhập", text: $userViewModel.username)
          .autocapitalization(.none)
        }
        Section(footer: Text(userViewModel.passwordMessage).foregroundColor(.red)) {
          SecureField("Nhập mật khẩu", text: $userViewModel.password)
          SecureField("Nhập lại mật khẩu", text: $userViewModel.passwordAgain)
       }
       Section {
         Button(action: { }) {
           Text("Đăng ký")
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
