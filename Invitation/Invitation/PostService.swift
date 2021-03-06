//
//  PostService.swift
//  Invitation
//
//  Created by Nika Talakhadze on 8/8/18.
//  Copyright © 2018 None. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import MapKit

struct PostService {
    static func create(name: String, long: Double, lat: Double, invitedUsers: [User], completion: @escaping (Bool) -> ()) {
        
        
        let author = User.current
        
        //        guard,
        //            let long = currentLocation.coordinate.longitude,
        //            let lat = currentLocation.coordinate.latitude else {
        //                completion(false)
        //                return
        //        }
        
        //get reference to firebase DB
        let ref = Database.database().reference().child("open_invites").childByAutoId()
        
        
        //create a Post object with the name, long and lat
        var newPost = Post(key: ref.key, author: author, long: long, lat: lat)
        
        //add invited friends uid to newPost
        let inviteduserUids = invitedUsers.map { aUser -> String in
            return aUser.uid!
        }
        newPost.invitedUserUids = inviteduserUids
        
        //get dictionary from post.dictValue
        let postDict = newPost.dictValue
        
        //upload the post dictionary to the reference
        ref.setValue(postDict) { (error, _) in
            
            //if no errors come when uploading, then
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            let dg = DispatchGroup()
            
            //loop through each invitedUser and send an invite post
            for aFriend in invitedUsers {
                dg.enter()
                self.invite(friend: aFriend, to: newPost) { (success) in
                    dg.leave()
                    
                    guard success == true else {
                        return print("there was an error uploading the invite")
                    }
                }
            }
            
            dg.notify(queue: DispatchQueue.main, execute: {
                completion(true)
            })
        }
    }
    
    static func invite(friend: User, to post: Post, completion: @escaping (Bool) -> ()) {
        let ref = Database.database().reference().child("invites").child(friend.uid!)
        
        ref.setValue(post.dictValue) { (error, _) in
            
            
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            completion(true)
        }
    }
    
    
    static let ref = Database.database().reference()
    
    
    static func remove(child: String) {
        
        let ref = self.ref.child("invites").child(child)
        
        ref.removeValue { error, _ in
            
//            print(error)
        }
    }
    
//    static func getInvitedFriends(){
//         
//    }
    
}


