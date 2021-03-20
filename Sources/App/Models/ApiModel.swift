import Fluent
import Vapor

protocol ApiModel: Model {
    associatedtype Input: Content
    associatedtype Output: Content

    init(_: Input, _: HttpHeaders) throws
    var output: Output { get }
    func update(_: Input, _: HttpHeaders) throws
}
