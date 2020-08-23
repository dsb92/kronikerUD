import Fluent
import Vapor

final class Subject: Model, Content {
    static let schema = "subjects"
    
    @ID(key: .id)
    var id: UUID?

    @Children(for: \.$parent)
    var subjects: [Subject]
    
    @Children(for: \.$subject)
    var details: [Detail]
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "iconURL")
    var iconURL: String
    
    @Field(key: "backgroundColor")
    var backgroundColor: String
    
    @OptionalParent(key: "parent_id")
    var parent: Subject?
    
    init() { }

    init(id: UUID? = nil, parentID: UUID? = nil, text: String, iconURL: String, backgroundColor: String) {
        self.id = id
        self.$parent.id = parentID
        self.text = text
        self.iconURL = iconURL
        self.backgroundColor = backgroundColor
    }
}
