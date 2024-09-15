//
//  SourcesScreen.swift
//  Alethia
//
//  Created by Angelo Carasig on 5/9/2024.
//

import SwiftUI
import RealmSwift

struct SourcesScreen: View {
    @ObservedResults(RealmHost.self) var realmHosts
    @State var vm: SourcesViewModel
    
    let useCaseFactory = UseCaseFactory.shared
    
    var body: some View {
        NavigationView {
            ContentView()
                .navigationTitle("Sources")
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button {
                        vm.addHost = true
                        vm.errorMessage = nil
                    } label: {
                        Image(systemName: "plus")
                    }
                )
                .sheet(isPresented: $vm.addHost) {
                    AddHostView(
                        testAction: { url in
                            return await vm.testNewHost(url)
                        },
                        saveAction: { host in
                            await vm.saveHost(host)
                        },
                        errorMessage: $vm.errorMessage
                    )
                    .presentationDetents([.large])
                }
        }
    }
}

private extension SourcesScreen {
    private func updateActiveHostManager(host: Host, source: Source) {
        ActiveHostManager.shared.setActiveHost(host: host, source: source)
    }
    
    func ContentView() -> some View {
        List {
            let hosts = realmHosts.map { $0.toDomain() }
            
            Section(header: Text("Hosts")) {
                ForEach(hosts) { host in
                    Text(host.name)
                }
            }
            
            Section(header: Text("Sources")) {
                ForEach(hosts) { host in
                    ForEach(host.sources) { source in
                        NavigationLink(destination: SourceContent(
                            vm: SCVM(
                                fetchHostSourceContentUseCase: useCaseFactory.makeFetchHostSourceContentUseCase(),
                                observeSourceMangaUseCase: useCaseFactory.makeObserveSourceMangaUseCase(),
                                activeHost: host,
                                activeSource: source
                            ))
                            .onAppear {
                                updateActiveHostManager(host: host, source: source)
                            }
                        ) {
                            HostSourceCard(host: host, source: source)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let factory = UseCaseFactory.shared
    
    return SourcesScreen(vm: SourcesViewModel(
        testHostUseCase: factory.makeTestHostUseCase(),
        addHostUseCase: factory.makeAddHostUseCase(),
        removeHostUseCase: factory.makeRemoveHostUseCase()
    ))
}
