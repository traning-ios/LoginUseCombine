//
//  UserViewModel.swift
//  LoginDemo
//
//  Created by Le Xuan Quynh on 2020/06/17.
//  Copyright © 2020 Le Xuan Quynh. All rights reserved.
//

import Foundation
import Combine
import Navajo_Swift

class UserViewModel: ObservableObject {
    // Input
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    var bag = Set<AnyCancellable>()
    // Output
    @Published var isValid = false
    @Published var usernameMessage = ""
    @Published var passwordMessage = ""
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                return password == ""
        }
        .eraseToAnyPublisher()
    }
    
    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .map { password, passwordAgain in
                return password == passwordAgain
        }
        .eraseToAnyPublisher()
    }
    
    private var passwordStrengthPublisher: AnyPublisher<PasswordStrength, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .map { password in
                return Navajo.strength(ofPassword: password)
        }
        .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongEnoughPublisher: AnyPublisher<Bool, Never> {
        passwordStrengthPublisher
            .map { strength in
                switch strength {
                case .reasonable, .strong, .veryStrong:
                    return true
                default:
                    return false
                }
        }
        .eraseToAnyPublisher()
    }
    
    enum PasswordCheck {
        case valid
        case empty
        case noMatch
        case notStrongEnough
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordCheck, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, arePasswordsEqualPublisher, isPasswordStrongEnoughPublisher)
            .map { passwordIsEmpty, passwordAreEqual, passwordIsStrongEnough in
                if passwordIsEmpty {
                    return .empty
                } else if !passwordAreEqual {
                    return .noMatch
                } else if !passwordIsStrongEnough {
                    return .notStrongEnough
                } else {
                    return .valid
                }
        }
        .eraseToAnyPublisher()
    }
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $username
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                return input.count >= 3
        }
        .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isUsernameValidPublisher, isPasswordValidPublisher)
            .map { userNameIsValid, passwordIsValid in
                return userNameIsValid && passwordIsValid == .valid
        }
        .eraseToAnyPublisher()
    }
    
    
    init() {
        $username.debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                return input.count >= 3
        }
        .assign(to: \.isValid, on: self)
        .store(in: &bag)
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &bag)
        
        isUsernameValidPublisher
            .receive(on: RunLoop.main)
            .map { valid in
                valid ? "": "UserName phải có ít nhất 3 ký tự!"
        }
        .assign(to: \.usernameMessage, on: self)
        .store(in: &bag)
        
        isPasswordValidPublisher
            .receive(on: RunLoop.main)
            .map { passwordCheck in
                switch passwordCheck {
                case .empty:
                    return "Bạn phải nhập mật khẩu"
                case .noMatch:
                    return "Mật khẩu không khớp"
                case .notStrongEnough:
                    return "Mật khẩu không đủ mạnh"
                default:
                    return ""
                }
        }
        .assign(to: \.passwordMessage, on: self)
        .store(in: &bag)
        
        
    }
}
