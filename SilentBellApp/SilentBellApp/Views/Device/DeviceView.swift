//
//  DeviceView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/19/25.
//

//
//  HomeView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/15/25.
//

import SwiftUI

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let status: String
}

struct DeviceView: View {
    @StateObject private var viewModel = DevicesViewModel()
    @State private var showingAddDevice = false
    @State private var newDeviceName = ""


    var body: some View {
        NavigationStack{
            VStack{
                if viewModel.isLoading {
                    ProgressView("Loading devices...")
                        .padding()
                } else if viewModel.devices.isEmpty {
                    Text("No devices Connected")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach (viewModel.devices) { device in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(device.name)
                                        .font(.headline)
                                    Text(device.status)
                                        .font(.subheadline)
                                        .foregroundColor(device.status == "Connected" ? .green : .red)
                                }
                                Spacer()
                                Image(systemName: device.status == "Connected" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(device.status == "Connected" ? .green : .red)
                            }
                        }
                        .onDelete(perform: viewModel.deleteDevice)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action : {
                        showingAddDevice = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDevice) {
                NavigationStack {
                    VStack {
                        if viewModel.scannedDevices.isEmpty {
                            ProgressView("Scanning for devices...")
                                .padding()
                                .onAppear { viewModel.startScan() }
                                .onDisappear { viewModel.stopScan() }
                        } else {
                            List(viewModel.scannedDevices, id: \.identifier) { peripheral in
                                Button(action: {
                                    viewModel.connectToDevice(peripheral)
                                    showingAddDevice = false
                                }) {
                                    HStack {
                                        Text(peripheral.name ?? "Unknown")
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Add Device")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingAddDevice = false
                                viewModel.stopScan()
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                Task {
                    await viewModel.loadDevices()
                }
            }
//            .alert(item: $viewModel.errorMessage) { msg in
//                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
//            }
        }
    }
}


#Preview {
    DeviceView()
    .modelContainer(for: Item.self, inMemory: true)
}
