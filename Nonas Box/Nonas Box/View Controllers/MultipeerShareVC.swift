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
    //MARK: - Properties
    private var peerID: MCPeerID!
    private var mcSession: MCSession!
    private var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMultiPeerSession()
    }
    
    
    //MARK: - Private Functions
    private func setUpMultiPeerSession() {
//        peerID = MCPeerID(displayName: displayName)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
}


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
