//
//  ReaderOverlay.swift
//  Alethia
//
//  Created by Angelo Carasig on 17/9/2024.
//

import SwiftUI

struct ReaderOverlay<Content: View>: View {
    @Bindable var vm: ReaderViewModel
    @Environment(\.dismiss) private var dismiss // Used to dismiss from nav stack
    
    let content: Content
    
    init(vm: ReaderViewModel, @ViewBuilder content: () -> Content) {
        self._vm = Bindable(vm)
        self.content = content()
    }
    
    private var pageBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(vm.currentPage) },
            set: { vm.currentPage = Int($0) }
        )
    }
    
    var body: some View {
        ZStack {
            if vm.chapterContent.count <= 0 {
                Text("Loading Content...")
            } else {
                content
                // On tap functions
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            vm.displayOverlay.toggle()
                        }
                    }
            }
            
            if vm.displayOverlay {
                // Top Overlay
                VStack {
                    HStack {
                        Button(action: {
                            vm.cycleReadingDirection()
                        }) {
                            Text("Change Reading Direction (Currently: \(vm.config.readerDirection))")
                                .foregroundColor(.white)
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.5)) // Apply background here
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // Bottom Overlay
                VStack {
                    Spacer()
                    
                    VStack {
                        // only show once chapter content is loaded
                        if vm.chapterContent.count > 0 {
                            // If not last page, show slider
                            if vm.currentPage < vm.chapterContent.count {
                                Slider(
                                    value: pageBinding,
                                    in: 0...Double(vm.chapterContent.count - 1),
                                    step: 1
                                )
                                .padding([.leading, .trailing], 20)
                                .onChange(of: vm.currentPage) {
                                    Haptics.selection()
                                }
                                
                                Text("Page \(vm.currentPage + 1) of \(vm.chapterContent.count)")
                                    .foregroundColor(.white)
                            }
                            
                        } else {
                            Text("Loading pages...")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .onAppear {
            vm.onOpen()
        }
        .statusBar(hidden: true)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}
