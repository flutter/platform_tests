// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// The SwiftUI view that appears as an overlay to our Flutter.
@available(iOS 14.0, *)
struct OverlaySwiftUIView: View {

  @ObservedObject var controller: OverlayFlutterViewController

  @State var text: String = ""

  @State var selectedText: String = ""

  @State var toggle = false

  @State private var showAlert = false

  // Add your controls here
  var controlDictionary: [String: (String, AnyView)] {
    ["CupertinoButton": // Key
      ("Cupertino Button", // Dropdown menu title
       AnyView(Button("Button", action: { }))  // View
      ),
     "CupertinoTextField":
      ("Cupertino TextField",
       AnyView(TextField("Placeholder", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle()))
      ),
     "CupertinoPicker":
      ("Cupertino Picker",
       AnyView(Picker(selection: $selectedText, label: Text("")) {
        ForEach(["One", "Two", "Three", "Four", "Five"], id: \.self) {
          Text($0)
        }
       })
      ),
     "CupertinoSearchTextField":
      ("Cupertino Search TextField",
       AnyView(SearchBar(text: $text))
      ),
     "CupertinoFormSection":
      ("Cupertino Form Section",
       AnyView(
        Form {
          Section(header: Text("Section 1")) {
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
          }
          Section(header: Text("Section 2")) {
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
            Toggle("Toggle", isOn: $toggle)
          }
        })
      ),
     "CupertinoFormSectionGroupInsetDemo":
      ("Cupertino Form Section (Group Inset)",
       AnyView(
        Form {
          Section(header: Text("Section 1")) {
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
          }
          Section(header: Text("Section 2")) {
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
            HStack {
              Text("Enter text")
              TextField("Enter text", text: $text)
            }
            Toggle("Toggle", isOn: $toggle)
          }
        })
      ),
      "CupertinoActivityIndicator":
        ("Cupertino Activity Indicator (Progress View)",
         AnyView(
           ProgressView()
         )
        ),
      "CupertinoSliverNavigationBar":
        ("Cupertino Sliver Navigation Bar",
         AnyView(
           NavigationView {
            List {}
            .navigationTitle("Title")
           }
         )
        ),
      "CupertinoSwitch":
        ("Cupertino Switch",
          AnyView(Toggle("Switch Label", isOn: $toggle))
        ),
      "CupertinoAlertDialog":
        ("Cupertino Alert Dialog",
          AnyView(Button("Show Alert") {
            showAlert = true
          })
        ),
      "CupertinoContextMenu":
        ("Cupertino Context Menu",
          AnyView(Button("Button", action: { })
            .contextMenu {
              Button("Button Context Menu Item") {
            }
          })
        ),
    ]
  }

  var body: some View {
    (controlDictionary[controller.controlKey]?.1 ?? AnyView(Text("Nothing Selected")))
      .frame(maxWidth: .infinity, maxHeight: .infinity).edgesIgnoringSafeArea(.all)
      .alert(isPresented: $showAlert) { // Alert definition
        Alert(
          title: Text("Alert Title"),
          message: Text("This is an alert message."),
          primaryButton: .default(Text("Yes")),
          secondaryButton: .destructive(Text("No"))
      )
    }
  }
}

@available(iOS 14.0, *)
struct SearchBar: UIViewRepresentable {

  @Binding var text: String

  class Coordinator: NSObject, UISearchBarDelegate {

    @Binding var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      text = searchText
    }
  }

  func makeCoordinator() -> SearchBar.Coordinator {
    return Coordinator(text: $text)
  }

  func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
    let searchBar = UISearchBar(frame: .zero)
    searchBar.delegate = context.coordinator
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = "Search"
    return searchBar
  }

  func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
    uiView.text = text
  }
}
