import Fluent
import Vapor

protocol ApiModel: Model {
    associatedtype Input: Content
    associatedtype Output: Content

    init(_: Input) throws
    var output: Output { get }
    func update(_: Input) throws
}
