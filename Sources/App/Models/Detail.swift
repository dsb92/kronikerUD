import Fluent
import Vapor

final class Detail: Model, Content {
    static let schema = "details"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "subject_id")
    var subject: Subject
    
    @Field(key: "enter_chatforum")
    var enterChatforum: Bool
    
    @OptionalField(key: "html_text")
    var htmlText: String?
    
    @OptionalField(key: "button_link_url")
    var buttonLinkURL: String?
    
    @OptionalField(key: "swipeable_texts")
    var swipeableTexts: [String]?
    
    @OptionalField(key: "video_link_urls")
    var videoLinkURLs: [LinkURL]?

    init() { }

    init(id: UUID? = nil, subjectID: UUID, htmlText: String?, buttonLinkURL: String?, swipeableTexts: [String]?, videoLinkURLs: [LinkURL]?, enterChatforum: Bool = false) {
        self.id = id
        self.$subject.id = subjectID
        self.htmlText = htmlText
        self.buttonLinkURL = buttonLinkURL
        self.swipeableTexts = swipeableTexts
        self.videoLinkURLs = videoLinkURLs
        self.enterChatforum = enterChatforum
    }
}

struct LinkURL: Codable {
    let text: String
    let URL: String
}
