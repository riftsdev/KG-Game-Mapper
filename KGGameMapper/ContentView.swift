import SwiftUI
import UIKit

struct Mapping: Codable, Identifiable {
    var id = UUID()
    var title: String
    var key: String
    var x: Double
    var y: Double
}

struct ContentView: View {
    @State private var mappings: [Mapping] = [
        Mapping(title: "Mover", key: "WASD", x: 0.22, y: 0.73),
        Mapping(title: "Atirar", key: "Space", x: 0.82, y: 0.67),
        Mapping(title: "Pular", key: "J", x: 0.77, y: 0.84)
    ]
    @State private var sensitivity = 1.0
    @State private var profileName = "Padrão"
    @State private var status = "Pronto para testar"
    @State private var showExport = false
    @State private var exportText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Editor de HUD").font(.title2.bold())
                    GeometryReader { geo in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.85))
                            Text("ÁREA DE TESTE").foregroundStyle(.gray)
                            ForEach($mappings) { $mapping in
                                Text(mapping.title)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(Circle().fill(.purple.opacity(0.75)))
                                    .position(x: geo.size.width * mapping.x, y: geo.size.height * mapping.y)
                                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                                        mapping.x = min(0.95, max(0.05, value.location.x / geo.size.width))
                                        mapping.y = min(0.95, max(0.05, value.location.y / geo.size.height))
                                    })
                            }
                        }
                    }
                    .frame(height: 280)

                    TextField("Nome do perfil", text: $profileName)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Text("Sensibilidade")
                        Slider(value: $sensitivity, in: 0.1...3)
                        Text(sensitivity.formatted(.number.precision(.fractionLength(1))))
                    }
                    ForEach($mappings) { $mapping in
                        HStack {
                            TextField("Ação", text: $mapping.title)
                            TextField("Tecla", text: $mapping.key)
                                .frame(width: 90)
                            Button(role: .destructive) {
                                mappings.removeAll { $0.id == mapping.id }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                    }
                    Button("Adicionar botão") {
                        mappings.append(Mapping(title: "Novo", key: "K", x: 0.5, y: 0.5))
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Exportar perfil JSON") {
                        let data = try? JSONEncoder().encode(mappings)
                        exportText = String(data: data ?? Data(), encoding: .utf8) ?? "[]"
                        UIPasteboard.general.string = exportText
                        status = "JSON copiado"
                    }
                    Text(status).foregroundStyle(.secondary)
                    Text("Funciona dentro do app e em jogos integrados. Não injeta toques em outros aplicativos.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("KG Game Mapper")
            .tint(.purple)
        }
    }
}