//
//  FirebaseSync.swift
//  MonasMundial
//
//  Created by Mateo on 30/04/26.
//
import FirebaseDatabase
import Foundation

class FirebaseSyncManager {
    private let dbRef = Database.database().reference()
    
    // 📤 SUBIR: No cambia, pero asegúrate de que la ruta sea consistente
    func uploadForSync(groups: [AlbumGroup], sessionID: String, completion: @escaping (Bool) -> Void) {
        do {
            let data = try JSONEncoder().encode(groups)
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            dbRef.child("sync").child(sessionID).setValue(jsonObject) { error, _ in
                completion(error == nil)
            }
        } catch {
            completion(false)
        }
    }
    
    // 📥 DESCARGAR: ¡QUITAMOS EL REMOVEVALUE!
    func downloadForSync(sessionID: String, completion: @escaping ([AlbumGroup]?) -> Void) {
        dbRef.child("sync").child(sessionID).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let value = snapshot.value else {
                completion(nil)
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let decodedGroups = try JSONDecoder().decode([AlbumGroup].self, from: data)
                completion(decodedGroups) // Solo descargamos, NO borramos.
            } catch {
                completion(nil)
            }
        }
    }

    // 🔄 LIVE SYNC: El motor que mantiene todo unido
    func startLiveSync(sessionID: String, onUpdate: @escaping ([AlbumGroup]) -> Void) -> UInt {
        return dbRef.child("sync").child(sessionID).observe(.value) { snapshot in
            guard let value = snapshot.value, snapshot.exists() else { return }
            if let data = try? JSONSerialization.data(withJSONObject: value),
               let groups = try? JSONDecoder().decode([AlbumGroup].self, from: data) {
                onUpdate(groups)
            }
        }
    }
    func stopLiveSync(sessionID: String, handle: UInt) {
        let nodeRef = dbRef.child("sync").child(sessionID)
        
        // Esta es la función clave de Firebase para remover un observador específico
        nodeRef.removeObserver(withHandle: handle)
        
        print("🛑 Observador detenido para la sesión: \(sessionID)")
    }
}

