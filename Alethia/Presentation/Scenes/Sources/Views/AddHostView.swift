//
//  AddHostView.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI

struct AddHostView: View {
    @State private var url: String = ""
    @State private var isTesting: Bool = false
    @State var resultHost: Host? = nil
    
    let testAction: (_ url: String) async -> Host?
    let saveAction: (_ host: Host) async -> Void
    @Binding var errorMessage: String?
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Repository URL")) {
                    TextField("Enter repository URL", text: $url)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                .frame(height: 25)
                
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                }
                
                // If newHost exists, display the sources
                if let newHost = resultHost {
                    Section(header: Text("Sources")) {
                        VStack(alignment: .leading) {
                            ForEach(newHost.sources) { source in
                                HostSourceCard(host: newHost, source: source)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                
                Section {
                    Button {
                        isTesting = true
                        errorMessage = nil
                        
                        Task {
                            guard let newHost = await testAction(url) else {
                                isTesting = false
                                return
                            }
                            resultHost = newHost
                            isTesting = false
                        }
                        
                    } label: {
                        if isTesting {
                            ProgressView()
                        } else {
                            Text("Test")
                        }
                    }
                    .disabled(url.isEmpty || isTesting)
                    
                    Button {
                        if let host = resultHost {
                            Task {
                                await saveAction(host)
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(resultHost == nil)
                }
            }
            .navigationTitle("Add New Repository")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
