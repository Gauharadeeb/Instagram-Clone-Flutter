class ApiConfig {
  // Change this based on your setup
  // For USB debugging with phone on WiFi: Use PC's IP
  // For Android Emulator: Use '10.0.2.2'
  // For iOS Simulator: Use 'localhost'
  // For physical device on same WiFi: Use PC's IP
  
  static const String baseUrl = 'http://172.16.2.187:8000';
  
  // Alternative options (uncomment to use):
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS Simulator
  // static const String baseUrl = 'http://YOUR_PC_IP:8000'; // Physical device WiFi
}
