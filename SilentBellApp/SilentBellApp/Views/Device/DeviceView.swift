import SwiftUI

// --- This Device struct is only used for the sheet state ---
// --- Your viewModel.devices seems to be a different type, which is fine ---
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

    // --- 1. Define the gradient from your Figma design ---
    let appGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.63, green: 1.0, blue: 0.81), // Minty Green
            Color(red: 0.98, green: 1.0, blue: 0.69)  // Light Yellow
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // --- Define the custom purple color for the title ---
    let titleColor = Color(red: 0.3, green: 0.1, blue: 0.5)

    var body: some View {
        // --- 2. Use a ZStack to layer the gradient behind the content ---
        ZStack {
            appGradient
                .ignoresSafeArea() // Make gradient fill the whole screen
            
            VStack(spacing: 0) {
                // --- 3. Create a custom header to match Figma ---
                HStack {
                    Text("MY DEVICES")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(titleColor)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddDevice = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black) // Match the black '+' in Figma
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10) // Add some space below the header
                
                // --- 4. Main content area ---
                if viewModel.isLoading {
                    // --- Center the loading indicator ---
                    Spacer()
                    ProgressView("Loading devices...")
                        .progressViewStyle(CircularProgressViewStyle(tint: titleColor))
                        .font(.headline)
                        .foregroundColor(titleColor.opacity(0.8))
                    Spacer()
                } else if viewModel.devices.isEmpty {
                    // --- Center the empty state text ---
                    Spacer()
                    Text("No devices Connected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    // --- 5. Style the List to be transparent ---
                    List {
                        ForEach(viewModel.devices) { device in
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
                            // Make each row transparent
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: viewModel.deleteDevice)
                    }
                    .listStyle(.plain) // Use .plain for no extra chrome
                    .scrollContentBackground(.hidden) // Make the List background transparent
                }
            }
            .safeAreaPadding(.top) // Ensure content avoids the status bar / notch
        }
        // --- Modifiers moved from NavigationStack to ZStack ---
        .onAppear {
            Task {
                viewModel.loadDevices()
            }
        }
        // ---
        // --- 1ST SHEET: ADD DEVICE (CORRECTED) ---
        // ---
        .sheet(isPresented: $showingAddDevice) {
            // --- 1. ZStack is the ROOT view inside the sheet ---
            ZStack {
                // --- 2. Apply gradient to the ZStack ---
                appGradient.ignoresSafeArea()
                
                NavigationStack {
                    VStack(spacing: 0) { // Added spacing: 0
                        if viewModel.scannedDevices.isEmpty {
                            // --- Center the ProgressView ---
                            Spacer()
                            ProgressView("Scanning for devices...")
                                .progressViewStyle(CircularProgressViewStyle(tint: titleColor))
                                .font(.headline)
                                .foregroundColor(titleColor.opacity(0.8))
                                .padding()
                                .onAppear { viewModel.startScan() }
                                .onDisappear { viewModel.stopScan() }
                            Spacer()
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
                                    .font(.headline)
                                    .foregroundColor(titleColor)
                                }
                                .listRowBackground(Color.clear) // Make row transparent
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden) // Make List BG transparent
                        }
                    }
                    .navigationTitle("Add Device")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingAddDevice = false
                                viewModel.stopScan()
                            }
                            .tint(titleColor) // Style the cancel button
                        }
                    }
                    // --- 3. Make the Nav Bar itself transparent ---
                    .toolbarBackground(.hidden, for: .navigationBar)
                }
                .tint(titleColor) // Style the list '+' icons
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // ---
        // --- 2ND SHEET: CONFIGURE WI-FI (CORRECTED) ---
        // ---
        .sheet(item: $selectedDevice) { device in
            // --- 1. ZStack is the ROOT view inside the sheet ---
            ZStack {
                // --- 2. Apply gradient to the ZStack ---
                appGradient.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Configure Wi-Fi for \(device.name)")
                        .font(.headline)
                        .foregroundColor(titleColor)
                    
                    if viewModel.availableNetworks.isEmpty {
                        ProgressView("Fetching Wi-Fi networks...")
                            .progressViewStyle(CircularProgressViewStyle(tint: titleColor))
                            .foregroundColor(titleColor.opacity(0.8))
                    } else {
                        Picker("Select Wi-Fi", selection: $ssid) {
                            ForEach(viewModel.availableNetworks, id: \.self) { network in
                                Text(network).tag(network)
                                    .foregroundColor(titleColor) // Style picker text
                            }
                        }
                        .pickerStyle(.wheel)
                        .tint(titleColor)
                    }
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send to Device") {
                        viewModel.sendWiFiCredentials(ssid: ssid, password: password)
                        selectedDevice = nil
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(titleColor) // Style button
                    .disabled(ssid.isEmpty || password.isEmpty)
                    
                    Spacer()
                }
                .padding()
            }
            // --- All the original logic is preserved ---
            .onReceive(viewModel.$isProvisioned) { provisioned in
                if provisioned {
                    showingNamePrompt = true
                }
            }
            // ---
            // --- 3RD SHEET: NAME YOUR DEVICE (CORRECTED) ---
            // ---
            .sheet(isPresented: $showingNamePrompt) {
                // --- 1. ZStack is the ROOT view inside the sheet ---
                ZStack {
                    // --- 2. Apply gradient to the ZStack ---
                    appGradient.ignoresSafeArea()
                    
                    NavigationStack {
                        VStack(spacing: 16) {
                            Text("Name Your Device")
                                .font(.headline)
                                .foregroundColor(titleColor)
                            
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
                            .tint(titleColor)
                            .disabled(newDeviceName.isEmpty)
                            
                            Button("Cancel", role: .cancel) {
                                newDeviceName = ""
                                showingNamePrompt = false
                                selectedDevice = nil
                            }
                            .tint(titleColor)
                            
                            Spacer()
                        }
                        .padding()
                        // --- 3. Make Nav Bar transparent ---
                        .toolbarBackground(.hidden, for: .navigationBar)
                    }
                }
            }
            .onAppear {
                Task {
                    viewModel.loadDevices()
                }
            }
        }
        // .alert(...)
    }
}

#Preview {
    // Simplified preview that works without a ModelContainer
    DeviceView()
}
