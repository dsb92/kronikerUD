import Fluent
import Vapor

struct SubjectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subjects = routes.grouped("subjects")
        subjects.get(use: getSubjects)
        subjects.post("generate", use: generateSubjects)
    }

    func getSubjects(req: Request) throws -> EventLoopFuture<[Subject]> {
        Subject.query(on: req.db)
            .filter(\.$parent.$id == .null)
            .with(\.$subjects) { subject in
                subject
                    .with(\.$subjects) { subject in
                        subject
                            .with(\.$subjects) { subject in
                                subject.with(\.$details)
                        }
                }
        }.all()
    }
    
    func generateSubjects(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Subject.query(on: req.db).delete()
        Detail.query(on: req.db).delete()
        
        let studievejleder = Subject(
            id: UUID(uuidString: "4cb7fc63-9403-4961-9760-0bce49ad6fca"),
            parentID: nil,
            text: "Studievejleder",
            iconURL: iconPath(with: req, name: "ic_counselor")
        )
        
        let støtte_under_uddannelse = Subject(
            id: UUID(uuidString: "9c9e5061-bce2-4bef-962f-d24e745dd09f"),
            parentID: UUID(uuidString: "4cb7fc63-9403-4961-9760-0bce49ad6fca"),
            text: "Støtte under uddannelse",
            iconURL: "URL here"
        )
        
        let gymnasieuddannelse = Subject(
            id: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            parentID: UUID(uuidString: "9c9e5061-bce2-4bef-962f-d24e745dd09f"),
            text: "Gymnasieuddanelse",
            iconURL: "URL here"
        )
        
        let studietur = Subject(
            id: UUID(uuidString: "485d887b-d262-4163-82ab-eeaf365725f6"),
            parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            text: "Studietur",
            iconURL: "URL here"
        )
        
        let støttetimer = Subject(
            id: UUID(uuidString: "8b779e05-82e7-46fb-a7a9-e8e5c870ddd5"),
            parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            text: "Støttetimer",
            iconURL: "URL here"
        )
        
        let fritagelseForIdrætC = Subject(
            id: UUID(uuidString: "70f60599-e586-45a5-9495-af73e6429f9f"),
            parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            text: "Fritagelse for idræt C",
            iconURL: "URL here"
        )
        
        let udvidelseAfUddannelse = Subject(
            id: UUID(uuidString: "5950e98d-0c52-4683-abcc-41d9d990101c"),
            parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            text: "Udvidelse af uddannelse",
            iconURL: "URL here"
        )
        
        let syge_supplerende_undervisning = Subject(
            id: UUID(uuidString: "3ab2d681-e8a0-442c-9985-30e7f70b5509"),
            parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            text: "Syge / Supplerende undervisning",
            iconURL: "URL here"
        )
        
        let eksamen = Subject(
            id: UUID(uuidString: "5be5b25a-ef3d-4859-9e6a-eec5ba7ffcef"),
            parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            text: "Eksamen",
            iconURL: "URL here"
        )
        
        let studieturDetalje = Detail(
            id: UUID(uuidString: "33d2ca7c-3f70-4f36-85cd-17f573e9c506"),
            subjectID: UUID(uuidString: "485d887b-d262-4163-82ab-eeaf365725f6")!,
            htmlText: "Det er muligt at få støtte under studieture. Studieturene kan både være i Danmark og i udlandet. Du kan få støtte til én obligatorisk studietur.\nUdgifter du kan få dækket, er fx hvis du skal have en hjælper eller tegnsprogstolk med på turen; rejse, lønudgifter, ophold, diæter mm.\n\nDu kan tilgå yderligere informationer omkring økonomisk støtte til studieture.",
            buttonLinkURL: "https://www.spsu.dk/for-sps-ansvarlige/administration-af-sps/sps-paa-studierejser-og-i-praktik",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let støttetimerDetalje = Detail(
            id: UUID(uuidString: "c2b87930-082e-4be3-8731-b40371924212"),
            subjectID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174")!,
            htmlText: "Hvis du i forbindelse med manglende udbytte af undervisningen har behov for specialundervisning eller anden socialpædagogisk støtte har du muligheden for at få tilbudt støttetimer for at kompensere for psykisk eller fysiske funktionsnedsættelser.\n\nDu kan tilgå yderligere informationer omkring støttetimer.",
            buttonLinkURL: "https://www.uvm.dk/forberedende-grunduddannelse/om-forberedende-grunduddannelse/specialpaedagogisk-stoette",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let fritagelseForIdrætCDetalje = Detail(
            id: UUID(uuidString: "a98c3c24-efd5-48ec-af20-52e2853e20eb"),
            subjectID: UUID(uuidString: "70f60599-e586-45a5-9495-af73e6429f9f")!,
            htmlText: "Hvis du på grund af din sygdom vil have svært ved at deltage i undervisningen idræt C, er der mulighed for at du kan blive fritaget for undervisningen.\nInstitutionen kan træffe en afgørelse herom pga. Sagkyndige oplysninger og udtalelser.\nInstitutionen beslutter samtidig, hvilken undervisning eleven skal gennemføre i stedet for idræt C.\n\nDu kan tilgå yderligere informationer omkring fritagelse for idræt C.",
            buttonLinkURL: "https://www.regionh.dk/ungepanel/nyheder/Sider/Nyheder/2018/fritagelse-fra-idraet-paa-stx-uddannelsen.aspx",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let udvidelseAfUddannelseDetalje = Detail(
            id: UUID(uuidString: "38da9e42-b80f-48ff-8b1b-84142b853bbd"),
            subjectID: UUID(uuidString: "5950e98d-0c52-4683-abcc-41d9d990101c")!,
            htmlText: "Hvis du på grund af din sygdom er forhindret i at følge undervisningen i længere perioder, kan skolen tilrettelægge en 2-årig gymnasial uddannelse over 3 år og en 3-årig gymnasial uddannelse over 4 år.\n\nDu kan tilgå yderligere informationer omkring udvidelse/forlængelse af din uddannelse kap 9.",
            buttonLinkURL: "https://danskelove.dk/gymnasieloven",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let syge_supplerende_undervisningDetalje = Detail(
            id: UUID(uuidString: "989a4104-2ebf-4e2c-aca2-45c5cfdc681d"),
            subjectID: UUID(uuidString: "3ab2d681-e8a0-442c-9985-30e7f70b5509")!,
            htmlText: "Hvis du går på en gymnasial uddannelse, har du mulighed for at få sygeundervisning eller supplerende undervisning, hvis du ikke kan følge den almindelige undervisning efter 10 dages sammenhængende fravær ved sygdom.\n\nDu kan tilgå yderligere informationer omkring syge og supplerende undervisning bekendtgørelse kap. 8.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2017/497",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let eksamenDetalje = Detail(
            id: UUID(uuidString: "550ed454-acf6-4b6a-93cc-cdf934b87b4a"),
            subjectID: UUID(uuidString: "5be5b25a-ef3d-4859-9e6a-eec5ba7ffcef")!,
            htmlText: "Hvis din sygdom påvirker din præsentation ved eksamener, har du mulighed for særlige prøvevilkår, så du bliver ligestillet med andre i prøvesituationen.\n\nDu kan tilgå yderligere informationer omkring eksamen prøveafholdelse kap 5.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2016/343#idc95d8ab3-ad8a-41e6-9af1-78f4afad8421",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        return studievejleder.save(on: req.db).map { studievejleder }.flatMap { _ in
            return støtte_under_uddannelse.save(on: req.db).map { støtte_under_uddannelse }.flatMap { _ in
                return gymnasieuddannelse.save(on: req.db).map { gymnasieuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
                    studietur.save(on: req.db).map { studietur }.flatMap { s -> EventLoopFuture<Subject> in
                        return studieturDetalje.save(on: req.db).map { s }
                    }
                    støttetimer.save(on: req.db).map { støttetimer }.flatMap { s -> EventLoopFuture<Subject> in
                        return støttetimerDetalje.save(on: req.db).map { s }
                    }
                    fritagelseForIdrætC.save(on: req.db).map { fritagelseForIdrætC }.flatMap { s -> EventLoopFuture<Subject> in
                        return fritagelseForIdrætCDetalje.save(on: req.db).map { s }
                    }
                    udvidelseAfUddannelse.save(on: req.db).map { udvidelseAfUddannelse }.flatMap { s -> EventLoopFuture<Subject> in
                        return udvidelseAfUddannelseDetalje.save(on: req.db).map { s }
                    }
                    syge_supplerende_undervisning.save(on: req.db).map { syge_supplerende_undervisning }.flatMap { s -> EventLoopFuture<Subject> in
                        return syge_supplerende_undervisningDetalje.save(on: req.db).map { s }
                    }
                    return eksamen.save(on: req.db).map { eksamen }.flatMap { s -> EventLoopFuture<Subject> in
                        return eksamenDetalje.save(on: req.db).map { s }
                    }
                }
            }
        }.transform(to: .noContent)
        
//        let gymnasieuddannelse = Subject(id: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"), parentID: UUID(uuidString: "9c9e5061-bce2-4bef-962f-d24e745dd09f"), text: "Gymnasieuddanelse", iconURL: "URL here")
//
//        let goderåd = Subject(id: UUID(uuidString: "b7c08d4c-5b83-4a5c-99fe-f98dda5e5ede"), parentID: UUID(uuidString: "4cb7fc63-9403-4961-9760-0bce49ad6fca"), text: "Gode råd", iconURL: "URL here")
//
//        let studietur = Subject(id: UUID(uuidString: "485d887b-d262-4163-82ab-eeaf365725f6"), parentID: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"), text: "Studietur", iconURL: "URL here")
//
//        let studieturDetalje = Detail(id: UUID(uuidString: "33d2ca7c-3f70-4f36-85cd-17f573e9c506"), subjectID: UUID(uuidString: "485d887b-d262-4163-82ab-eeaf365725f6")!, htmlText: "Der er mulighed for at få støtte", buttonLinkURL: "Link here", swipeableTexts: nil, videoLinkURLs: nil)
//
//
//        studievejleder.$subjects.create([støtte_under_uddannelse], on: req.db)
//        støtte_under_uddannelse.$subjects.create([gymnasieuddannelse], on: req.db)
//        gymnasieuddannelse.$subjects.create([studietur], on: req.db)
//        studietur.$details.create([studieturDetalje], on: req.db)
    }
    
    private func iconPath(with req: Request, name: String, and ext: String = ".png") -> String {
        "\(req.application.http.server.configuration.hostname):\(req.application.http.server.configuration.port)/icons/\(name)\(ext)"
    }
}
