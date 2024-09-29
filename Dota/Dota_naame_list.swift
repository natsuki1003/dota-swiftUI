import SwiftUI

// Data structure for Dota 2 pro player information
// It conforms to Codable to be able to decode JSON data and Identifiable to be used in ForEach
struct PlayerData_four: Codable, Identifiable {
    let id: Int                // Unique ID of the player
    let personaname: String?    // Player's name or username
    
    // Map the JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id = "account_id"   // Use "account_id" from JSON for the id property
        case personaname         // Direct mapping for player's name
    }
}

// ViewModel: Manages the data and fetches the pro player data from the API asynchronously
class PlayerViewModel_four: ObservableObject {
    @Published var players: [PlayerData_four] = []   // List of players, the view will automatically update when this changes
    
    // Function to fetch the player data asynchronously
    func fetchPlayerData_four() async {
        // URL for the Dota 2 pro players API
        let url = URL(string: "https://api.opendota.com/api/proPlayers")!
        
        // Fetch the data from the API and decode it into an array of PlayerData_four
        let (data, _) = try! await URLSession.shared.data(from: url)
        let players = try! JSONDecoder().decode([PlayerData_four].self, from: data)
        
        // Update the players array on the main thread so the UI can update
        DispatchQueue.main.async {
            self.players = players
        }
    }
}

// The main view that displays the player names in a list
struct PlayerListView: View {
    @StateObject private var viewModel = PlayerViewModel_four()  // Create an instance of the ViewModel to manage the data
    
    var body: some View {
        NavigationView {  // Add a navigation view for better layout and title
            List(viewModel.players) { player in  // List that displays each player's name
                Text(player.personaname ?? "Unknown Player")  // Display the player's name or "Unknown Player"
                    .font(.body)
            }
            .navigationTitle("Dota 2 Pro Players")  // Title for the navigation bar
            .task {
                // Fetch the player data when the view appears
                await viewModel.fetchPlayerData_four()
            }
        }
    }
}

// Preview for the SwiftUI view, allowing you to see it in Xcode's preview pane
#Preview {
    PlayerListView()
}
