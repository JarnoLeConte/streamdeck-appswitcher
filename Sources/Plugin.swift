//
//  Plugin.swift
//  AppSwitcher is a plugin for Stream Deck to easily switch between opened apps.
//
//  Created by Jarno Le Conté on 20/10/2019.
//  Copyright © 2019 Jarno Le Conté. All rights reserved.
//

import Foundation

public class Plugin: NSObject, ESDEventsProtocol {
    var connectionManager: ESDConnectionManager?;
    var timer : Timer?;
    
    func executeAppleScript(source: String) {
        var error: NSDictionary?
        let script = NSAppleScript.init(source: source);
        script?.executeAndReturnError(&error)
        if error != nil {
            NSLog("AppleScript ERROR");
        }
    }
    
    func wakeUp() {
        // Make an initial call to System Events
        // 1. This will ensure sequential calls to be handled more quickly
        // 2. The first time user have to give permission to access System Events
        executeAppleScript(source: """
            tell application "System Events"
            end tell
            """);
    }
    
    func performSwitchStep() {
        executeAppleScript(source: """
             tell application "System Events"
             key down command
             keystroke tab
             end tell
             """);
        
        // Reset confirmation time
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }

        // Confirm selection after time interval
        timer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
            // Confirm selection
            self.executeAppleScript(source: """
                tell application "System Events"
                key up command
                end tell
                """);
         });
    }
     
    public func setConnectionManager(_ connectionManager: ESDConnectionManager) {
        self.connectionManager = connectionManager;
    }
    
    public func keyDown(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        performSwitchStep()
    }
    
    public func keyUp(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        // Nothing to do
    }
    
    public func willAppear(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        wakeUp();
    }
    
    public func willDisappear(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        // Nothing to do
    }
    public func deviceDidConnect(_ deviceID: String, withDeviceInfo deviceInfo: [AnyHashable : Any]) {
        // Nothing to do
    }
    
    public func deviceDidDisconnect(_ deviceID: String) {
        // Nothing to do
    }
    
    public func applicationDidLaunch(_ applicationInfo: [AnyHashable : Any]) {
        // Nothing to do
    }
    
    public func applicationDidTerminate(_ applicationInfo: [AnyHashable : Any]) {
        // Nothing to do
    }
}

