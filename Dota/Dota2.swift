import SwiftUI

// Dota 2プロプレイヤーのデータ構造体
struct PlayerData_two: Codable, Identifiable {
    let id: Int
    let avatarfull: String?
    let personaname: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "account_id"
        case avatarfull
        case personaname
    }
}

// ViewModel: 非同期にプロプレイヤーデータを取得
class PlayerViewModel_two: ObservableObject {
    @Published var players: [PlayerData_two] = []
    
    // 非同期でデータを取得する関数
    func fetchPlayerData_two() async {
        let urlString = "https://api.opendota.com/api/proPlayers"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 取得したJSONデータを確認
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("JSON Response: \(json)")
            } else {
                print("Failed to serialize JSON")
            }
            
            // プレイヤーデータをデコード
            let players = try JSONDecoder().decode([PlayerData_two].self, from: data)
            
            // データを確認するためにコンソールに出力
            print("Fetched Players: \(players.count)")
            for player in players {
                print("Player Name: \(player.personaname ?? "N/A"), Avatar URL: \(player.avatarfull ?? "N/A")")
            }
            
            DispatchQueue.main.async {
                self.players = players
            }
        } catch {
            print("Failed to fetch player data: \(error.localizedDescription)")
        }
    }
}

// メインのビューでアバターをグリッド表示
struct AvatarGridView_two: View {
    @StateObject private var viewModel = PlayerViewModel_two()
    
    // グリッドレイアウトのカラム設定
    let columns = [
        GridItem(.adaptive(minimum: 100)) // グリッドの最小サイズを指定
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.players) { player in
                        VStack {
                            if let avatarUrl = player.avatarfull, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else if phase.error != nil {
                                        Text("Failed to load image")
                                            .foregroundColor(.red)
                                            .frame(width: 100, height: 100)
                                    } else {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            } else {
                                Text("No image")
                                    .frame(width: 100, height: 100)
                            }
                            Text(player.personaname ?? "Unknown Player")
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dota 2 Pro Players")
        }
        .task {
            await viewModel.fetchPlayerData_two() // 非同期でデータを取得
        }
    }
}

// プレビュー
#Preview {
    AvatarGridView_two()
}
