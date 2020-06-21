import Fluent
import Vapor

final class Detail: Model, Content {
    static let schema = "details"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "html_text")
    var htmlText: String?
    
    @Field(key: "button_link_url")
    var buttonLinkURL: String?
    
    @Field(key: "swipeable_texts")
    var swipeableTexts: [String]?
    
    @Field(key: "video_link_urls")
    var videoLinkURLs: [String]?
    
    @Parent(key: "subject_id")
    var subject: Subject

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
