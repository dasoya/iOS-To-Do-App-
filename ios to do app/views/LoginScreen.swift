//
//  LoginScreen.swift
//  ios to do app
//
//  Created by Cristi Conecini on 16.01.23.
//

// Import the necessary modules
import SwiftUI
import FirebaseAuth

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

/// This view describes the login screen of the app
struct SignUpView: View {
    /// State property `email` to store user's email input
    @State private var email: String = ""
    /// State property `password` to store user's password input
    @State private var password: String = ""
    /// State property `error` to store error message during sign up
    @State private var error: String = ""
    /// State property `isLoading` to store the loading status during sign up
    @State private var isLoading = false
    /// State property `isSuccess` to store the success status during sign up
    @State private var isSuccess = false
    /// Binding property `showSignUpView` to control the visibility of the sign up view
    @Binding var showSignUpView: Bool
    /// State property `firstName` to store user's first name input
    @State private var firstName: String = ""
    /// State property `lastName` to store user's last name input
    @State private var lastName: String = ""

    var body: some View {
        VStack {
            Text("Create Account").font(.largeTitle)
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            // Display error message if there is any
            if (error != "") {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
            // Sign up button
            Button(action: {
                self.signup()
            }) {
                Text("Sign Up")
            }
            .padding()
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1)
            .buttonStyle(.borderedProminent)
        }.padding().textFieldStyle(.roundedBorder)
    }
    /// Function to handle the sign up process
    func signup() {
        self.error = ""
        self.isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            self.isLoading = false
            if error != nil {
                withAnimation{
                    self.error = error!.localizedDescription
                }
                print("Error signing up: \(String(describing: error))")
            } else {
                self.isSuccess = true
                // navigate to home view
                //self.showSignUpView = false
                Auth.auth().signIn(withEmail: email, password: password)
            }
        }
    }
}


/// Define the ForgetPasswordView struct
struct ForgetPasswordView: View {
    /// State property `email` to store user's email input
    @State private var email: String = ""
    /// State property `error` to store error message during sign up
    @State private var error: String = ""
    /// State property `isLoading` to store the loading status during sign up
    @State private var isLoading = false
    /// State property `isSuccess` to store the success status during sign up
    @State private var isSuccess = false
    /// Binding property `showForgetPasswordView` to control the visibility of the forget password view
    @Binding var showForgetPasswordView: Bool
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            // Display error message if there is any
            if (error != "") {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
            // "Send reset email" button
            Button(action: {
                self.forgotPassword()
            }) {
                Text("Send Reset Email")
           
            }
            .padding()
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1)
            .buttonStyle(.bordered)
        }.padding().textFieldStyle(.roundedBorder)
    }
    /// Function to handle the password reset process
    func forgotPassword() {
        self.error = ""
        self.isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.isLoading = false
            if error != nil {
                self.error = error!.localizedDescription
            }
            else {
                self.isSuccess = true
                self.showForgetPasswordView = false
            }
        }
    }
}

/// Define the LoginScreen struct
struct LoginScreen: View {
    /// State property `email` to store user's email input
    @State private var email: String = ""
    /// State property `password` to store user's password input
    @State private var password: String = ""
    /// State property `error` to store error message during sign up
    @State private var error: String = ""
    /// State property `isLoading` to store the loading status during sign up
    @State private var isLoading = false
    /// State property `isSuccess` to store the success status during sign up
    @State private var isSuccess = false
    /// State properties `showSignUpView` and `showForgetPasswordView` to control the visibility of the sign up and forget password views
    @State private var showSignUpView = false
    @State private var showForgetPasswordView = false

    var body: some View {
            VStack{
                Text("Welcome")
                    .font(.largeTitle)
                TextField("Email", text: $email)
                    .padding()
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                // Display error message if there is any
                if (error != "") {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
                // Login button
                Button(action: {self.login()}){
                    Text("LOGIN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                .padding()
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1)
                //.buttonStyle(.borderedProminent)
                // Sign up button
                HStack{
                    Text("Don't have an account?")
                        .font(.callout)
                    Button(action: {self.showSignUpView = true}){
                        Text("Sign Up")
                    }
                    .padding().sheet(isPresented: $showSignUpView) {
                        SignUpView(showSignUpView: $showSignUpView)
                    }
                }
                //.buttonStyle(.bordered)
                // Forget password button
                Button(action: {self.showForgetPasswordView = true}){
                    Text("Forget password")
                }
                .padding().sheet(isPresented: $showForgetPasswordView) {
                    ForgetPasswordView(showForgetPasswordView: $showForgetPasswordView)
                }
                //.buttonStyle(.bordered)
            }
            .padding()
            //.textFieldStyle(.roundedBorder)
        }
    /// Function to handle the login process
    func login() {
        self.error = ""
        self.isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            self.isLoading = false
            if error != nil {
                self.error = error!.localizedDescription
            }
            else {
                self.isSuccess = true
                // navigate to home view
            }
        }
    }
}
