//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Vicky Zheng on 10/23/20.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var feedTableView: UITableView!
    let commentBar = MessageInputBar();
    var showCommentBar = false
    var posts = [PFObject]()
    var count = 20
    
    let myRefreshControl = UIRefreshControl();
    var selectedPost: PFObject!
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        
        commentBar.delegate = self
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        feedTableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        feedTableView.refreshControl = myRefreshControl

        
        // Do any additional setup after loading the view.
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if (success) {
                print("Comment saved")
            }
            else {
                print("Error saving comment")
            }
        }
        feedTableView.reloadData()
    }
    
    @objc func keyboardWillBeHidden(node: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    @objc func loadPosts() {
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = self.count
        
        query.findObjectsInBackground { (posts, error) in
            if (posts != nil) {
                self.posts = posts!
                self.feedTableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    @objc func loadMorePosts() {
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        self.count+=20
        query.limit = self.count
        query.findObjectsInBackground { (posts, error) in
            if (posts != nil) {
                self.posts = posts!
                self.feedTableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if (indexPath.row == 0) {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let url = URL(string: imageFile.url!)!
            cell.photoView.af.setImage(withURL: url)
            return cell
        }
        else if (indexPath.row <= comments.count) {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as? PFUser
            cell.nameLabel.text = user?.username
            
            return cell
        }
        else {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Post selected in section: \(indexPath.section)")
        print("Post selected in row: \(indexPath.row)")
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
        
//        comment["text"] = "This is a random comment"
//        comment["post"] = post
//        comment["author"] = PFUser.current()!
//
//        post.add(comment, forKey: "comments")
//        post.saveInBackground { (success, error) in
//            if (success) {
//                print("Comment saved")
//            }
//            else {
//                print("Error saving comment")
//            }
//        }
    }

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let delegate = windowScene!.delegate as? SceneDelegate
        delegate!.window?.rootViewController = loginViewController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
