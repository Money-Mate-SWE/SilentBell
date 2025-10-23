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
    @State private var ssid = ""
    @State private var password = ""
    @State private var selectedDevice: Device?
    @State private var isSendingCredentials = false
    
    @State private var showingNamePrompt = false


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
                                    Text(device.device_name)
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
            .navigationTitle("My Devices")
            .onAppear {
                Task {
                    viewModel.loadDevices()
                }
            }
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
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        selectedDevice = Device(name: peripheral.name ?? "Unnamed", status: "Connecting...")
                                    }
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
            .sheet(item: $selectedDevice) { device in
                VStack(spacing: 16) {
                    Text("Configure Wi-Fi for \(device.name)").font(.headline)
                    
                    if viewModel.availableNetworks.isEmpty {
                        ProgressView("Fetching Wi-Fi networks...")
                    } else {
                        Picker("Select Wi-Fi", selection: $ssid) {
                            ForEach(viewModel.availableNetworks, id: \.self) { network in
                                Text(network).tag(network)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send to Device") {
                        viewModel.sendWiFiCredentials(ssid: ssid, password: password)
                        selectedDevice = nil
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(ssid.isEmpty || password.isEmpty)
                    
                    Spacer()
                }
                .padding()
                .onReceive(viewModel.$isProvisioned) { provisioned in
                    if provisioned {
                        showingNamePrompt = true
                    }
                }
                .sheet(isPresented: $showingNamePrompt) {
                    NavigationStack {
                        VStack(spacing: 16) {
                            Text("Name Your Device")
                                .font(.headline)
                            
                            TextField("Device Name", text: $newDeviceName)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            Button("Save") {
                                viewModel.addDevice(name: newDeviceName) { deviceKey in
                                    if let _ = deviceKey {
                                        newDeviceName = ""
                                        selectedDevice = nil
                                    } else {
                                        print("❌ Failed to register device")
                                    }
                                }
                                newDeviceName = ""
                                showingNamePrompt = false
                                selectedDevice = nil
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newDeviceName.isEmpty)
                            
                            Button("Cancel", role: .cancel) {
                                newDeviceName = ""
                                showingNamePrompt = false
                                selectedDevice = nil
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .onAppear {
                    Task {
                         viewModel.loadDevices()
                    }
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
