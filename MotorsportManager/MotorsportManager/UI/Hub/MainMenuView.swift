import SwiftUI

struct MainMenuView: View {
    @Environment(GameState.self) private var gameState
    
    @State private var showingCreationForm: Bool = false
    @State private var targetSlot: Int = 1
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var selectedNationality: String = "Italia"
    @State private var selectedAge: Int = 16
    
    let nationalitiesList = [
        "Italia", "Regno Unito", "Spagna", "Francia", "Germania",
        "Brasile", "Stati Uniti", "Giappone", "Paesi Bassi", "Australia"
    ]
    
    @State private var selectedTeamID: UUID?
    @State private var availableTeams: [Team] = []
    
    // MARK: - Gestione Eliminazione
    @State private var slotToDelete: Int?
    @State private var showingDeleteAlert: Bool = false
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedTeamID != nil
    }
    
    var body: some View {
            Group {
                // Selezionatore di stato radicale: o sei in gioco, o sei nel menu.
                if gameState.playerDriver != nil {
                    // Il MainTabView gestisce la propria navigazione (nessun NavigationStack padre a bloccarlo)
                    MainTabView()
                } else {
                    // Il Menu Principale e la Creazione Carriera vivono nel loro stack isolato
                    NavigationStack {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                                .ignoresSafeArea()
                            
                            if showingCreationForm {
                                startScreen()
                            } else {
                                slotsSelectionMenu()
                            }
                        }
                        // Alert di sicurezza per l'eliminazione spostato qui
                        .alert("Elimina Carriera", isPresented: $showingDeleteAlert, presenting: slotToDelete) { slot in
                            Button("Annulla", role: .cancel) { }
                            Button("Elimina Definitivamente", role: .destructive) {
                                gameState.deleteGame(slot: slot)
                            }
                        } message: { slot in
                            Text("Sei sicuro di voler eliminare i dati dello Slot \(slot)? Questa azione è irreversibile e perderai tutti i progressi.")
                        }
                    }
                }
            }
        }
    @ViewBuilder
    private func slotsSelectionMenu() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 60))
                .foregroundColor(.primary)
            
            Text("Motorsport Manager")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 14) {
                Text("SELEZIONA SLOT CARRIERA")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.secondary)
                
                ForEach(1...3, id: \.self) { slot in
                    slotCard(slot: slot)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private func slotCard(slot: Int) -> some View {
        let hasSave = gameState.hasSavedGame(slot: slot)
        
        HStack {
            // Area principale per Caricare/Creare
            Button(action: {
                if hasSave {
                    _ = gameState.loadGame(slot: slot)
                } else {
                    targetSlot = slot
                    gameState.seasonManager.inizializzaCampionati()
                    availableTeams = gameState.getAvailableStartingTeams()
                    selectedTeamID = availableTeams.first?.id
                    showingCreationForm = true
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Slot Carriera \(slot)")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                        Text(hasSave ? "Carriera attiva • Dati presenti" : "Slot vuoto • Nuova Carriera")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: hasSave ? "play.circle.fill" : "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(hasSave ? .green : .blue)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            
            // Area per Eliminare (Appare solo se lo slot è occupato)
            if hasSave {
                Button(action: {
                    slotToDelete = slot
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    @ViewBuilder
    private func startScreen() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Button(action: { showingCreationForm = false }) {
                        Label("Indietro", systemImage: "chevron.left")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("Nuova Carriera (Slot \(targetSlot))")
                    .font(.largeTitle)
                    .bold()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Dati Pilota")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        TextField("Nome", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Cognome", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            Text("Nazionalità")
                            Spacer()
                            Picker("Nazionalità", selection: $selectedNationality) {
                                ForEach(nationalitiesList, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal, 4)
                        
                        HStack {
                            Text("Età")
                            Spacer()
                            Picker("Età", selection: $selectedAge) {
                                ForEach(15...18, id: \.self) { Text("\($0) anni").tag($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                if !availableTeams.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scuderia di Debutto")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(availableTeams) { team in
                            Button(action: { selectedTeamID = team.id }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(team.name).font(.headline)
                                        Text("Performance: \(Int(team.basePerformance))").font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: selectedTeamID == team.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedTeamID == team.id ? .blue : .gray)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Button(action: {
                    guard let tID = selectedTeamID else { return }
                    gameState.startNewGame(slot: targetSlot, firstName: firstName, lastName: lastName, nationality: selectedNationality, age: selectedAge, selectedTeamID: tID)
                    showingCreationForm = false
                }) {
                    Text("Firma e Inizia")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}
