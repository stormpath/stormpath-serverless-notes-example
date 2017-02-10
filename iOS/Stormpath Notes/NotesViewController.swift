//
//  NotesViewController.swift
//  Stormpath Notes
//
//  Created by Edward Jiang on 3/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit
import Stormpath
import AWSDynamoDB

class NotesViewController: UIViewController {
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: .keyboardWasShown, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillBeHidden, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the note and display it
        APIClient.getNote { error in
            self.notesTextView.text = APIClient.notes
        }
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        // Code when someone presses the logout button
        Stormpath.sharedSession.logout()
        dismiss(animated: false, completion: nil)
        
    }
    
    func keyboardWasShown(_ notification: Notification) {
        if let keyboardRect = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            notesTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0)
            notesTextView.scrollIndicatorInsets = notesTextView.contentInset
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        notesTextView.contentInset = UIEdgeInsets.zero
        notesTextView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension NotesViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Add a "Save" button to the navigation bar when we start editing the 
        // text field.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: .stopEditing)
    }
    
    func stopEditing() {
        // Remove the "Save" button, and close the keyboard.
        navigationItem.rightBarButtonItem = nil
        notesTextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Save the note when exiting
        APIClient.notes = notesTextView.text!
        APIClient.saveNote(callback: nil)
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(NotesViewController.keyboardWasShown(_:))
    static let keyboardWillBeHidden = #selector(NotesViewController.keyboardWillBeHidden(_:))
    static let stopEditing = #selector(NotesViewController.stopEditing)
}
