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
    
    let title: String
    let content: Content
    
    init(vm: ReaderViewModel, title: String, @ViewBuilder content: () -> Content) {
        self._vm = Bindable(vm)
        self.title = title
        self.content = content()
    }
    
    private var pageBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(vm.currentPage) },
            set: { vm.currentPage = Int($0) }
        )
    }
    
    private func isViewingContent() -> Bool {
        return vm.currentPage >= 0 && vm.currentPage < vm.chapterContent.count
    }
    
    var body: some View {
        ZStack {
            if vm.chapterContent.count <= 0 {
                Text("Loading \(title)")
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
            
            // Just display it
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
                
                // Bottom Overlay - only display when viewing content
                if isViewingContent() {
                    VStack {
                        Spacer()
                        
                        VStack {
                            // only show once chapter content is loaded
                            if vm.chapterContent.count > 0 {
                                // only show if viewing content
                                if isViewingContent() {
                                    HStack {
                                        PreviousChapterButton()
                                        Slider(
                                            value: pageBinding,
                                            // Handle 1 page chapters
                                            in: 0...Double(max(1, vm.chapterContent.count - 1)),
                                            step: 1
                                        )
                                        .padding([.leading, .trailing], 20)
                                        .onChange(of: vm.currentPage) {
                                            Haptics.selection()
                                        }
                                        NextChapterButton()
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

private extension ReaderOverlay {
    @ViewBuilder
    func PreviousChapterButton() -> some View {
        Button {
            Task {
                Haptics.impact()
                await vm.goToPreviousChapter()
            }
        } label: {
            HStack {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(vm.previousChapter != nil ? AppColors.text : AppColors.tint)
            .cornerRadius(8)
        }
        .disabled(vm.previousChapter == nil)
    }
    
    @ViewBuilder
    func NextChapterButton() -> some View {
        Button {
            Task {
                Haptics.impact()
                await vm.goToNextChapter()
            }
        } label: {
            HStack {
                Image(systemName: "chevron.right")
            }
            .foregroundColor(vm.nextChapter != nil ? AppColors.text : AppColors.tint)
            .cornerRadius(8)
        }
        .disabled(vm.nextChapter == nil)
    }
}
