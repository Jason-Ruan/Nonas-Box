//
//  MultipeerShareVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/16/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultipeerShareVC: UIViewController {
    // MARK: - Properties
    private var peerID: MCPeerID!
    private var mcSession: MCSession!
    private var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMultiPeerSession()
    }
    
    // MARK: - Private Functions
    private func setUpMultiPeerSession() {
//        peerID = MCPeerID(displayName: displayName)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
}

// MARK: - MCSessionDelegate, MCBrowserViewControllerDelegate
extension MultipeerShareVC: MCSessionDelegate, MCBrowserViewControllerDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("You are now connected to session")
        case .connecting:
            print("Connecting to session now")
        case .notConnected:
            print("Did not connect to session")
        @unknown default:
            print("This is the unknown default for connecting to multipeer session")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func sendData(data: Data?) {
        if mcSession.connectedPeers.count > 0 {
            if let data = data {
                do {
                    try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .unreliable)
                } catch {
                    print(error)
                }
            }
        }
    }
    
}
