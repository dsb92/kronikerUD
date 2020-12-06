import Foundation

protocol CommentsManagable: NumberManagable {
    func addComment(numberOfComments: inout Int)
    func deleteComment(numberOfComments: inout Int) 
}

extension CommentsManagable {
    func addComment(numberOfComments: inout Int) {
        increase(number: &numberOfComments)
    }
    
    func deleteComment(numberOfComments: inout Int) {
        decrease(number: &numberOfComments)
    }
}
