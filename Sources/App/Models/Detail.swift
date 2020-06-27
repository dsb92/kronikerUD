import Fluent
import Vapor

final class Detail: Model, Content {
    static let schema = "details"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "subject_id")
    var subject: Subject
    
    @OptionalField(key: "html_text")
    var htmlText: String?
    
    @OptionalField(key: "button_link_url")
    var buttonLinkURL: String?
    
    @OptionalField(key: "swipeable_texts")
    var swipeableTexts: [String]?
    
    @OptionalField(key: "video_link_urls")
    var videoLinkURLs: [String]?

    init() { }

    init(id: UUID? = nil, subjectID: UUID, htmlText: String?, buttonLinkURL: String?, swipeableTexts: [String]?, videoLinkURLs: [String]?) {
        self.id = id
        self.$subject.id = subjectID
        self.htmlText = htmlText
        self.buttonLinkURL = buttonLinkURL
        self.swipeableTexts = swipeableTexts
        self.videoLinkURLs = videoLinkURLs
    }
}
