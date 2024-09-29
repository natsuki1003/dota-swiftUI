import SwiftUI

// Data structure for Dota 2 pro player information
// It conforms to Codable to be able to decode JSON data and Identifiable to be used in ForEach
struct PlayerData_three: Codable, Identifiable {
    let id: Int                // Unique ID of the player
    let avatarfull: String?     // URL for the player's avatar image
    let personaname: String?    // Player's name or username
    
    // Map the JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id = "account_id"   // Use "account_id" from JSON for the id property
        case avatarfull          // Direct mapping for avatar URL
        case personaname         // Direct mapping for player's name
    }
}

// ViewModel: Manages the data and fetches the pro player data from the API asynchronously
class PlayerViewModel_three: ObservableObject {
    @Published var players: [PlayerData_three] = []   // List of players, the view will automatically update when this changes
    
    // Function to fetch the player data asynchronously
    func fetchPlayerData_three() async {
        // URL for the Dota 2 pro players API
        let url = URL(string: "https://api.opendota.com/api/proPlayers")!
        
        // Fetch the data from the API and decode it into an array of PlayerData_three
        let (data, _) = try! await URLSession.shared.data(from: url)
        let players = try! JSONDecoder().decode([PlayerData_three].self, from: data)
        
        // Update the players array on the main thread so the UI can update
        DispatchQueue.main.async {
            self.players = players
        }
    }
}

// The main view that displays the avatars in a grid layout
struct AvatarGridView_three: View {
    @StateObject private var viewModel = PlayerViewModel_three()  // Create an instance of the ViewModel to manage the data
    
    // Define the grid layout with adaptive columns, meaning it will fit as many 100-point wide items as possible
    let columns = [
        GridItem(.adaptive(minimum: 100))  // Minimum column width of 100 points
    ]
    
    var body: some View {
        ScrollView {  // Make the grid scrollable
            LazyVGrid(columns: columns, spacing: 20) {  // Create a grid layout with spacing between the items
                // Iterate over the list of players, using each player's id to identify them uniquely
                ForEach(viewModel.players, id: \.id) { player in
                    VStack {  // Stack the avatar image and player's name vertically
                        if let avatarUrl = player.avatarfull, let url = URL(string: avatarUrl) {
                            // Load the avatar image asynchronously
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    // While the image is loading, show a progress indicator
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                case .success(let image):
                                    // Once the image loads successfully, display it as a resizable image
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())  // Make the image a circle
                                case .failure:
                                    // If the image fails to load, show a placeholder icon
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                @unknown default:
                                    // Handle any other unknown cases (just in case)
                                    EmptyView()
                                }
                            }
                        }
                        // Display the player's name or "Unknown Player" if it's not available
                        Text(player.personaname ?? "Unknown Player")
                            .font(.caption)   // Make the text small
                            .lineLimit(1)     // Limit the text to one line
                    }
                }
            }
            .padding()  // Add padding around the grid
        }
        .task {
            // Fetch the player data when the view appears
            await viewModel.fetchPlayerData_three()
        }
    }
}

// Preview for the SwiftUI view, allowing you to see it in Xcode's preview pane
#Preview {
    AvatarGridView_three()
}
