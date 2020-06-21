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
                    .with(\.$details)
                    .with(\.$subjects) { subject in
                        subject
                            .with(\.$subjects) { subject in
                                subject.with(\.$details)
                        }
                }
        }.all()
    }
    
    func generateSubjects(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Detail.query(on: req.db).delete().flatMap { _ in
            return Subject.query(on: req.db).delete()
        }.flatMap { _ in
            return self.generateStudievejleder(req: req).transform(to: .noContent)
        }
    }
    
    private func iconPath(name: String, and ext: String = ".png") -> String {
        "icons/\(name)\(ext)"
    }
    
    private func generateStudievejleder(req: Request) -> EventLoopFuture<Subject> {
        let studievejleder = Subject(
            id: UUID(uuidString: "4cb7fc63-9403-4961-9760-0bce49ad6fca"),
            parentID: nil,
            text: "Studievejleder",
            iconURL: iconPath(name: "ic_counselor")
        )
        
        return studievejleder.save(on: req.db).map { studievejleder }.flatMap { _ in
            return self.generateStudievejlederStøtteUnderUddannelse(req: req, studievejleder: studievejleder).flatMap { _ in
                return self.generateStudievejlederGoderåd(req: req, studievejleder: studievejleder)
            }
        }
    }
    
    private func generateStudievejlederStøtteUnderUddannelse(req: Request, studievejleder: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try studievejleder.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let støtte_under_uddannelse = Subject(
            id: UUID(uuidString: "9c9e5061-bce2-4bef-962f-d24e745dd09f"),
            parentID: parentID,
            text: "Støtte under uddannelse",
            iconURL: iconPath(name: "ic_supporthours_and_aids")
        )
        
        return støtte_under_uddannelse.save(on: req.db).map { støtte_under_uddannelse }.flatMap { _ in
            return self.generateStudievejlederStøtteUnderUddannelseGymnasieUddannelse(req: req, støtte_under_uddannelse: støtte_under_uddannelse).flatMap { _ in
                return self.generateStudievejlederStøtteUnderUddannelseErhvervsUddannelse(req: req, støtte_under_uddannelse: støtte_under_uddannelse).flatMap { _ in
                    return self.generateStudievejlederStøtteUnderUddannelseVideregåendeUddannelse(req: req, støtte_under_uddannelse: støtte_under_uddannelse)
                }
            }
        }
    }
    
    private func generateStudievejlederGoderåd(req: Request, studievejleder: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try studievejleder.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let gode_råd = Subject(
            id: UUID(uuidString: "a0a24557-c753-4916-ac79-7225522203b3"),
            parentID: parentID,
            text: "Gode råd",
            iconURL: iconPath(name: "ic_good_advice")
        )
        
        let gode_råd_detalje = Detail(
            id: UUID(uuidString: "edabcd58-193c-411a-a276-2cf0caa4a956"),
            subjectID: UUID(uuidString: "a0a24557-c753-4916-ac79-7225522203b3")!,
            htmlText: nil,
            buttonLinkURL: nil,
            swipeableTexts: [
                "Introducer dig selv personligt ved opstart af nye hold, hvad kan du som studievejleder tilbyde de studerende, henvis gerne til appen når du fortæller om kronisk syges muligheder for SPS.",
                "Indret et pauserum som de studerende kan bruge efter behov, hvor det er muligt at slappe af i fred og ro, og derved lade op til resten af skoledagen. Dette kan være med til at mindske den kronisk syges fravær.",
                "Opfordrer til at holde klassens dag for hvert semester (½ årligt for uddannelser uden semestre eller som det giver mening) Dette giver den kronisk syge bedre mulighed for at være socialt med i klassen, hvilket ofte er noget den kroniske syge kan have svært ved pga. Manglende overskud og en nødvendighed for at prioritere sine ressourcer. Det giver også mulighed for at få introduceret nytilkomne i klassen.",
                "Opret lektiehjælpscafe, dette kan være med til at styrke den kronisk syge fagligt i tilfælde af at deres symptomer/behandlinger giver dem meget fravær. Lektiehjælpscafeen kan været et samarbejde imellem lærer og studerende der er længere i uddannelsen.",
                "Giv løbende lyd fra dig til de studerende så de bliver mindet om at du er der til at hjælpe - det er nemmere at svare tilbage på en kommunikation der er åbnet end selv at skulle starte en op.",
                "Sæt dig ind i hvad de studerendes kroniske sygdomme kan give af udfordringer så du er bedre forberedt til at hjælpe.",
                "Italesæt, efter godkendelse fra den studerende, overfor underviserne at der er studerende der muligvis har behov for ekstra støtte",
                "Du har mulighed for at få en mentorordning på dit studie til fx at hjælpe med struktur, det faglige mm."
            ],
            videoLinkURLs: nil
        )
        
        return gode_råd.save(on: req.db).map { gode_råd }.flatMap { s -> EventLoopFuture<Subject> in
            return gode_råd_detalje.save(on: req.db).map { s }
        }
    }
    
    private func generateStudievejlederStøtteUnderUddannelseErhvervsUddannelse(req: Request, støtte_under_uddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try støtte_under_uddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let erhvervsuddannelse = Subject(
            id: UUID(uuidString: "6bd18b8d-c9f4-451f-8a02-f0cd9c6a4a03"),
            parentID: parentID,
            text: "Erhvervsuddannelse",
            iconURL: iconPath(name: "ic_secondary_school")
        )
        
        return erhvervsuddannelse.save(on: req.db).map { erhvervsuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return self.generateStudievejerStøtteUnderUddannelseErhvervsUddannelse(req: req, erhvervsuddannelse: erhvervsuddannelse)
        }
    }
    
    private func generateStudievejlederStøtteUnderUddannelseVideregåendeUddannelse(req: Request, støtte_under_uddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try støtte_under_uddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let videregåendeuddannelse = Subject(
            id: UUID(uuidString: "2752ff0d-896c-46ca-8496-8225f7f0b3a0"),
            parentID: parentID,
            text: "Videregående uddannelse",
            iconURL: iconPath(name: "ic_secondary_school")
        )
        
        return videregåendeuddannelse.save(on: req.db).map { videregåendeuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return self.generateStudievejerStøtteUnderUddannelseVideregåendeUddannelse(req: req, videregåendeuddannelse: videregåendeuddannelse)
        }
    }
    
    private func generateStudievejlederStøtteUnderUddannelseGymnasieUddannelse(req: Request, støtte_under_uddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try støtte_under_uddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let gymnasieuddannelse = Subject(
            id: UUID(uuidString: "6c7efa45-07ba-418a-89f6-c0f7ea184174"),
            parentID: parentID,
            text: "Gymnasieuddanelse",
            iconURL: iconPath(name: "ic_secondary_school")
        )
        
        return gymnasieuddannelse.save(on: req.db).map { gymnasieuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return self.generateStudievejerStøtteUnderUddannelseGymnasieUddannelse(req: req, gymnasieuddannelse: gymnasieuddannelse)
        }
    }
    
    private func generateStudievejerStøtteUnderUddannelseGymnasieUddannelse(req: Request, gymnasieuddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try gymnasieuddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let gymnasieuddannelse_studietur = Subject(
            id: UUID(uuidString: "485d887b-d262-4163-82ab-eeaf365725f6"),
            parentID: parentID,
            text: "Studietur",
            iconURL: iconPath(name: "ic_study_trip")
        )
        
        let gymnasieuddannelse_støttetimer = Subject(
            id: UUID(uuidString: "8b779e05-82e7-46fb-a7a9-e8e5c870ddd5"),
            parentID: parentID,
            text: "Støttetimer",
            iconURL: iconPath(name: "ic_supporthours_and_aids")
        )
        
        let gymnasieuddannelse_fritagelseForIdrætC = Subject(
            id: UUID(uuidString: "70f60599-e586-45a5-9495-af73e6429f9f"),
            parentID: parentID,
            text: "Fritagelse for idræt C",
            iconURL: iconPath(name: "ic_exemption_from_sports")
        )
        
        let gymnasieuddannelse_udvidelseAfUddannelse = Subject(
            id: UUID(uuidString: "5950e98d-0c52-4683-abcc-41d9d990101c"),
            parentID: parentID,
            text: "Udvidelse af uddannelse",
            iconURL: iconPath(name: "ic_extending_education")
        )
        
        let gymnasieuddannelse_syge_supplerende_undervisning = Subject(
            id: UUID(uuidString: "3ab2d681-e8a0-442c-9985-30e7f70b5509"),
            parentID: parentID,
            text: "Syge / Supplerende undervisning",
            iconURL: iconPath(name: "ic_sick_or_supplementary_education")
        )
        
        let gymnasieuddannelse_eksamen = Subject(
            id: UUID(uuidString: "5be5b25a-ef3d-4859-9e6a-eec5ba7ffcef"),
            parentID: parentID,
            text: "Eksamen",
            iconURL: iconPath(name: "ic_examination_counselor")
        )
        
        let gymnasieuddannelse_studietur_detalje = Detail(
            id: UUID(uuidString: "33d2ca7c-3f70-4f36-85cd-17f573e9c506"),
            subjectID: UUID(uuidString: "485d887b-d262-4163-82ab-eeaf365725f6")!,
            htmlText: "Det er muligt at få støtte under studieture. Studieturene kan både være i Danmark og i udlandet. Du kan få støtte til én obligatorisk studietur.\nUdgifter du kan få dækket, er fx hvis du skal have en hjælper eller tegnsprogstolk med på turen; rejse, lønudgifter, ophold, diæter mm.\n\nDu kan tilgå yderligere informationer omkring økonomisk støtte til studieture.",
            buttonLinkURL: "https://www.spsu.dk/for-sps-ansvarlige/administration-af-sps/sps-paa-studierejser-og-i-praktik",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_støttetimer_detalje = Detail(
            id: UUID(uuidString: "c2b87930-082e-4be3-8731-b40371924212"),
            subjectID: UUID(uuidString: "8b779e05-82e7-46fb-a7a9-e8e5c870ddd5")!,
            htmlText: "Hvis du i forbindelse med manglende udbytte af undervisningen har behov for specialundervisning eller anden socialpædagogisk støtte har du muligheden for at få tilbudt støttetimer for at kompensere for psykisk eller fysiske funktionsnedsættelser.\n\nDu kan tilgå yderligere informationer omkring støttetimer.",
            buttonLinkURL: "https://www.uvm.dk/forberedende-grunduddannelse/om-forberedende-grunduddannelse/specialpaedagogisk-stoette",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_fritagelseForIdrætC_detalje = Detail(
            id: UUID(uuidString: "a98c3c24-efd5-48ec-af20-52e2853e20eb"),
            subjectID: UUID(uuidString: "70f60599-e586-45a5-9495-af73e6429f9f")!,
            htmlText: "Hvis du på grund af din sygdom vil have svært ved at deltage i undervisningen idræt C, er der mulighed for at du kan blive fritaget for undervisningen.\nInstitutionen kan træffe en afgørelse herom pga. Sagkyndige oplysninger og udtalelser.\nInstitutionen beslutter samtidig, hvilken undervisning eleven skal gennemføre i stedet for idræt C.\n\nDu kan tilgå yderligere informationer omkring fritagelse for idræt C.",
            buttonLinkURL: "https://www.regionh.dk/ungepanel/nyheder/Sider/Nyheder/2018/fritagelse-fra-idraet-paa-stx-uddannelsen.aspx",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_udvidelseAfUddannelse_detalje = Detail(
            id: UUID(uuidString: "38da9e42-b80f-48ff-8b1b-84142b853bbd"),
            subjectID: UUID(uuidString: "5950e98d-0c52-4683-abcc-41d9d990101c")!,
            htmlText: "Hvis du på grund af din sygdom er forhindret i at følge undervisningen i længere perioder, kan skolen tilrettelægge en 2-årig gymnasial uddannelse over 3 år og en 3-årig gymnasial uddannelse over 4 år.\n\nDu kan tilgå yderligere informationer omkring udvidelse/forlængelse af din uddannelse kap 9.",
            buttonLinkURL: "https://danskelove.dk/gymnasieloven",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_syge_supplerende_undervisning_detalje = Detail(
            id: UUID(uuidString: "989a4104-2ebf-4e2c-aca2-45c5cfdc681d"),
            subjectID: UUID(uuidString: "3ab2d681-e8a0-442c-9985-30e7f70b5509")!,
            htmlText: "Hvis du går på en gymnasial uddannelse, har du mulighed for at få sygeundervisning eller supplerende undervisning, hvis du ikke kan følge den almindelige undervisning efter 10 dages sammenhængende fravær ved sygdom.\n\nDu kan tilgå yderligere informationer omkring syge og supplerende undervisning bekendtgørelse kap. 8.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2017/497",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_eksamen_detalje = Detail(
            id: UUID(uuidString: "550ed454-acf6-4b6a-93cc-cdf934b87b4a"),
            subjectID: UUID(uuidString: "5be5b25a-ef3d-4859-9e6a-eec5ba7ffcef")!,
            htmlText: "Hvis din sygdom påvirker din præsentation ved eksamener, har du mulighed for særlige prøvevilkår, så du bliver ligestillet med andre i prøvesituationen.\n\nDu kan tilgå yderligere informationer omkring eksamen prøveafholdelse kap 5.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2016/343#idc95d8ab3-ad8a-41e6-9af1-78f4afad8421",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let _ = gymnasieuddannelse_studietur.save(on: req.db).map { gymnasieuddannelse_studietur }.flatMap { s -> EventLoopFuture<Subject> in
            return gymnasieuddannelse_studietur_detalje.save(on: req.db).map { s }
        }
        let _ = gymnasieuddannelse_støttetimer.save(on: req.db).map { gymnasieuddannelse_støttetimer }.flatMap { s -> EventLoopFuture<Subject> in
            return gymnasieuddannelse_støttetimer_detalje.save(on: req.db).map { s }
        }
        let _ = gymnasieuddannelse_fritagelseForIdrætC.save(on: req.db).map { gymnasieuddannelse_fritagelseForIdrætC }.flatMap { s -> EventLoopFuture<Subject> in
            return gymnasieuddannelse_fritagelseForIdrætC_detalje.save(on: req.db).map { s }
        }
        let _ = gymnasieuddannelse_udvidelseAfUddannelse.save(on: req.db).map { gymnasieuddannelse_udvidelseAfUddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return gymnasieuddannelse_udvidelseAfUddannelse_detalje.save(on: req.db).map { s }
        }
        let _ = gymnasieuddannelse_syge_supplerende_undervisning.save(on: req.db).map { gymnasieuddannelse_syge_supplerende_undervisning }.flatMap { s -> EventLoopFuture<Subject> in
            return gymnasieuddannelse_syge_supplerende_undervisning_detalje.save(on: req.db).map { s }
        }
        return gymnasieuddannelse_eksamen.save(on: req.db).map { gymnasieuddannelse_eksamen }.flatMap { s -> EventLoopFuture<Subject> in
            return gymnasieuddannelse_eksamen_detalje.save(on: req.db).map { s }
        }
    }
    
    private func generateStudievejerStøtteUnderUddannelseErhvervsUddannelse(req: Request, erhvervsuddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try erhvervsuddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let erhvervsuddannelse_ekstra_undervisning = Subject(
            id: UUID(uuidString: "b97d02f9-d971-4eb1-840e-484c31b91130"),
            parentID: parentID,
            text: "Ekstra undervisning",
            iconURL: iconPath(name: "ic_extra_teaching")
        )
        
        let erhvervsuddannelse_udvidelse_af_uddannelse = Subject(
            id: UUID(uuidString: "3d83ada0-b19e-4f26-bed5-93b526f66937"),
            parentID: parentID,
            text: "Udvidelse af uddannelse",
            iconURL: iconPath(name: "ic_extending_education")
        )
        
        let erhvervsuddannelse_støtte_timer_hjælpemidler = Subject(
            id: UUID(uuidString: "4d4745bf-d50b-4d86-8152-2986d7745a6b"),
            parentID: parentID,
            text: "Støttetimer/hjælpemidler",
            iconURL: iconPath(name: "ic_supporthours_and_aids")
        )
        
        let erhvervsuddannelse_eksamen = Subject(
            id: UUID(uuidString: "717b9711-55d2-4802-ba0e-7d4d655a4047"),
            parentID: parentID,
            text: "Eksamen",
            iconURL: iconPath(name: "ic_examination_counselor")
        )
        
        let erhvervsuddannelse_revalidering = Subject(
            id: UUID(uuidString: "4d2bc06d-35cb-4efb-94b3-aae8236a7b43"),
            parentID: parentID,
            text: "Revalidering",
            iconURL: iconPath(name: "ic_rehabiliation")
        )
        
        let erhvervsuddannelse_handicap_tillæg = Subject(
            id: UUID(uuidString: "174ccd2a-245f-4a22-a1ef-95c49b2aa4a7"),
            parentID: parentID,
            text: "Handicap tillæg",
            iconURL: iconPath(name: "ic_handicap_supplement")
        )
        
        let erhvervsuddannelse_praktik = Subject(
            id: UUID(uuidString: "20047a0d-6e54-4778-84e5-e8f183ff855d"),
            parentID: parentID,
            text: "Praktik",
            iconURL: iconPath(name: "ic_internship")
        )
        
        let erhvervsuddannelse_ekstra_undervisning_detalje = Detail(
            id: UUID(uuidString: "928db278-0392-4efd-81fe-7e283dc90999"),
            subjectID: UUID(uuidString: "b97d02f9-d971-4eb1-840e-484c31b91130")!,
            htmlText: "Hvis du er i forbindelse med manglende udbytte af undervisningen, har behov for specialundervisning eller anden socialpædagogisk støtte har du muligheden for at få tilbudt støttetimer for at kompensere for psykiske eller fysiske funktionsnedsættelser.\n\nDu kan tilgå yderligere informationer omkring ekstra undervisning.",
            buttonLinkURL: "https://www.spsu.dk/for-sps-ansvarlige/videregaaende-uddannelser/psykiske-funktionsnedsaettelser/korte-og-mellemlange-videregaaende-uddannelser/stoetteformer/stoettetimer-ved-faglig-stoettelaerer",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_udvidelse_af_uddannelse_detalje = Detail(
            id: UUID(uuidString: "c5a0da20-4ea3-41d4-a9f7-d2838a13eb33"),
            subjectID: UUID(uuidString: "3d83ada0-b19e-4f26-bed5-93b526f66937")!,
            htmlText: "Hvis du har brug for en længere uddannelsestid, end den uddannelsestid skolen har beregnet, kan man søge om forlængelse.\nErhvervsskolen vejleder gerne om mulighederne, og i nogle tilfælde kan skolen og det lokale uddannelsesudvalg godkende en forlængelse af uddannelsestiden uden, at der skal sendes en ansøgning til det faglige udvalg.\n\nDu kan tilgå yderligere informationer omkring udvidelse af uddannelse.",
            buttonLinkURL: "https://www.uddannelsesnaevnet.dk/virksomheder/uddannelsesaftalen/afkortning-eller-forlaengelse-af-uddannelsestid",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_støtte_timer_hjælpemidler_detalje = Detail(
            id: UUID(uuidString: "79485865-3970-4b3b-88db-b4057a66efdb"),
            subjectID: UUID(uuidString: "4d4745bf-d50b-4d86-8152-2986d7745a6b")!,
            htmlText: "Hvis du får bevilget studiestøttetimer, kan du fx arbejde med udvikling af strategier til at styrker og understøtte dit faglige overblik og struktur.\nDu kan få hjælp til at bruge forskellige planlægningsværktøjer, som du kan bruge, når du skal skrive opgaver eller i gang med større projekter.\n\nDu kan tilgå yderligere informationer omkring støttetimer og hjælpemidler.",
            buttonLinkURL: "https://www.spsu.dk/for-elever-og-studerende/leverandører%20af%20støtte",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_eksamen_detalje = Detail(
            id: UUID(uuidString: "283dc4bf-6d0d-4d48-85be-6c9514d0ef33"),
            subjectID: UUID(uuidString: "717b9711-55d2-4802-ba0e-7d4d655a4047")!,
            htmlText: "Hvis din sygdom påvirker din præstation ved eksamener, har du muligheden for særlige prøvevilkår, så du bliver ligestillet med andre i prøvesituationen.\n\nDu kan tilgå yderligere informationer omkring eksamen prøveafholdelse kap 5.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2016/343#idc95d8ab3-ad8a-41e6-9af1-78f4afad8421",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_revalidering_detalje = Detail(
            id: UUID(uuidString: "ccedf162-2923-42a1-b267-de1dd7d02f27"),
            subjectID: UUID(uuidString: "4d2bc06d-35cb-4efb-94b3-aae8236a7b43")!,
            htmlText: "Revalidering er både erhvervsrettede aktiviteter og økonomisk hjælp.\nRevalidering kan ske enten i form for revalidering eller når det erhvervsmæssige sigte er afklaret dvs. revalidering efter en særlig jobplan.\nAktiviteterne kan fx være arbejdsprøvning, uddannelse, optræning hos private eller offentlige arbejdsgivere eller hjælp til etablering af selvstændig virksomhed.\nDen økonomiske hjælp kan være kontanthjælp eller revalideringsydelse.\nFor at kunne få revalidering er det en forudsætning, at man har begrænsninger i arbejdsevnen, og at der ikke er andre tilbud som kan hjælpe en med at få tilknytning til arbejdsmarkedet.\n\nDu kan tilgå yderligere informationer omkring revalidering.",
            buttonLinkURL: "https://star.dk/da/indsatser-og-ordninger/indsatser-ved-sygdom-nedslidning-mv/revalidering/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_handicap_tillæg_detalje = Detail(
            id: UUID(uuidString: "546c5b28-1b19-472a-ae7e-12de32450828"),
            subjectID: UUID(uuidString: "174ccd2a-245f-4a22-a1ef-95c49b2aa4a7")!,
            htmlText: "Læser du på en dansk erhvervsuddannelse og har en varig psykisk eller fysisk funktionsnedsættelse, der giver dig meget betydelige begrænsninger i evnen til at påtage dig et erhvervsarbejde, så kan du søge om at få et handicaptillæg ved siden af din SU.\nDu kan som noget nyt søge handicaptillæg i de måneder, hvor du modtager SU (grundforløbende og øvrige forløb med SU).\n\nDu kan tilgå yderligere informationer omkring handicaptillæg.",
            buttonLinkURL: "https://www.su.dk/su/saerlig-stoette-til-foraeldre-handicappede-mv/handicaptillaeg/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_praktik_detalje = Detail(
            id: UUID(uuidString: "f1fba7fd-ee2d-4a2e-bc63-39ffb122343c"),
            subjectID: UUID(uuidString: "20047a0d-6e54-4778-84e5-e8f183ff855d")!,
            htmlText:
            """
            <p>AUB giver tilskud til elever:</p>
            <ul>
            <li>Der er registreret p&aring; en erhvervsuddannelse som praktikpladss&oslash;gende</li>
            <li>Der er optaget p&aring; en erhvervsskoles grundforl&oslash;b</li>
            <li>Der har gennemf&oslash;rt grundforl&oslash;bet</li>
            <li>Der deltager i undervisningen p&aring; skolepraktik</li>
            </ul>
            <p>&nbsp;</p>
            <p>AUB giver tilskud, hvis din transporttid imellem hjem og praktik eller uddannelsessted er mindst 2,5 time med offentlige transportmidler.</p>
            <p>Du kan tilg&aring; yderligere information omkring praktik.</p>
            """,
            buttonLinkURL: "https://www.borger.dk/skole-og-uddannelse/Erhvervsuddannelser/AUB-oversigt/AUB-praktik-danmark",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let _ = erhvervsuddannelse_ekstra_undervisning.save(on: req.db).map { erhvervsuddannelse_ekstra_undervisning }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_ekstra_undervisning_detalje.save(on: req.db).map { s }
        }
        let _ = erhvervsuddannelse_udvidelse_af_uddannelse.save(on: req.db).map { erhvervsuddannelse_udvidelse_af_uddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_udvidelse_af_uddannelse_detalje.save(on: req.db).map { s }
        }
        let _ = erhvervsuddannelse_støtte_timer_hjælpemidler.save(on: req.db).map { erhvervsuddannelse_støtte_timer_hjælpemidler }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_støtte_timer_hjælpemidler_detalje.save(on: req.db).map { s }
        }
        let _ = erhvervsuddannelse_eksamen.save(on: req.db).map { erhvervsuddannelse_eksamen }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_eksamen_detalje.save(on: req.db).map { s }
        }
        let _ = erhvervsuddannelse_revalidering.save(on: req.db).map { erhvervsuddannelse_revalidering }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_revalidering_detalje.save(on: req.db).map { s }
        }
        let _ = erhvervsuddannelse_handicap_tillæg.save(on: req.db).map { erhvervsuddannelse_handicap_tillæg }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_handicap_tillæg_detalje.save(on: req.db).map { s }
        }
        return erhvervsuddannelse_praktik.save(on: req.db).map { erhvervsuddannelse_praktik }.flatMap { s -> EventLoopFuture<Subject> in
            return erhvervsuddannelse_praktik_detalje.save(on: req.db).map { s }
        }
    }
    
    private func generateStudievejerStøtteUnderUddannelseVideregåendeUddannelse(req: Request, videregåendeuddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try videregåendeuddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let videregåendeuddannelse_orlov = Subject(
            id: UUID(uuidString: "8408ae98-a5cb-46a9-b9f4-8f177b0d99be"),
            parentID: parentID,
            text: "Orlov",
            iconURL: iconPath(name: "ic_sick_or_supplementary_education")
        )
        
        let videregåendeuddannelse_støtte_timer_hjælpemidler = Subject(
            id: UUID(uuidString: "9eeceab0-423a-4ebe-a35a-e930f95e62dc"),
            parentID: parentID,
            text: "Støttetimer/hjælpemidler",
            iconURL: iconPath(name: "ic_supporthours_and_aids")
        )
        
        let videregåendeuddannelse_praktik = Subject(
            id: UUID(uuidString: "f613fc30-ba69-4ccc-a570-093e541cee14"),
            parentID: parentID,
            text: "Praktik",
            iconURL: iconPath(name: "ic_internship")
        )
        
        let videregåendeuddannelse_handicap_tillæg = Subject(
            id: UUID(uuidString: "e10b224c-c248-45b6-b09e-2dfd2f2dcfed"),
            parentID: parentID,
            text: "Handicap tillæg",
            iconURL: iconPath(name: "ic_handicap_supplement")
        )
        
        let videregåendeuddannelse_revalidering = Subject(
             id: UUID(uuidString: "6e2dbaf5-ab74-47a2-978b-294d41d3642b"),
             parentID: parentID,
             text: "Revaldering",
             iconURL: iconPath(name: "ic_rehabiliation")
        )
        
        let videregåendeuddannelse_orlov_detalje = Detail(
            id: UUID(uuidString: "54e249ff-5fd3-4d29-a3ba-dbb2580da90d"),
            subjectID: UUID(uuidString: "8408ae98-a5cb-46a9-b9f4-8f177b0d99be")!,
            htmlText: "Der kan være mange forskellige grunde til at søge om orlov fx graviditet, arbejde, værnepligt eller sygdom.\nStudievejlederen på uddannelsesstedet kan rådgive dig om reglerne og ansøgningsproceduren, samt komme med gode råd.\n\nDu kan tilgå yderligere informationer omkring orlov.",
            buttonLinkURL: "https://www.ug.dk/videregaaendeuddannelse/orlov-paa-videregaaende-uddannelser",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_støtte_timer_hjælpemidler_detalje = Detail(
            id: UUID(uuidString: "987727e8-782d-4596-9bdd-e6af39a05263"),
            subjectID: UUID(uuidString: "9eeceab0-423a-4ebe-a35a-e930f95e62dc")!,
            htmlText: "Hvis du får bevilget studiestøttetimer, kan du fx arbejde med udvikling af strategier til at styrker og understøtte dit faglige overblik og struktur.\nDu kan få hjælp til at bruge forskellige planlægningsværktøjer, som du kan bruge, når du skal skrive opgaver eller i gang med større projekter.\n\nDu kan tilgå yderligere informationer omkring støttetimer og hjælpemidler.",
            buttonLinkURL: "https://www.spsu.dk/for-elever-og-studerende/leverandører%20af%20støtte",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_praktik_detalje = Detail(
            id: UUID(uuidString: "90dd8bb1-0447-4929-85bd-4fa1785fff85"),
            subjectID: UUID(uuidString: "f613fc30-ba69-4ccc-a570-093e541cee14")!,
            htmlText: "Er der obligatoriske praktikperioder under din uddannelse, så giver dette dig også ret til SPS under praktikken, selvom praktikperioden evt. Ikke er SU berettiget.\n\nDu kan tilgå yderligere informationer omkring praktik.",
            buttonLinkURL: "https://www.spsu.dk/for-elever-og-studerende/sps-naar-du-er-studerende-paa-en-videregaaende-uddannelse/sps-naar-du-er-studerende-paa-en-videregaaende-uddannelse",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_handicap_tillæg_detalje = Detail(
            id: UUID(uuidString: "6e3d4c04-4370-4861-ac1b-eae4c1d52168"),
            subjectID: UUID(uuidString: "e10b224c-c248-45b6-b09e-2dfd2f2dcfed")!,
            htmlText: "Læser du på en dansk erhvervsuddannelse og har en varig psykisk eller fysisk funktionsnedsættelse, der giver dig meget betydelige begrænsninger i evnen til at påtage dig et erhvervsarbejde, så kan du søge om at få et handicaptillæg ved siden af din SU.\nDu kan som noget nyt søge handicaptillæg i de måneder, hvor du modtager SU (grundforløbende og øvrige forløb med SU).\n\nDu kan tilgå yderligere informationer omkring handicaptillæg.",
            buttonLinkURL: "https://www.su.dk/su/saerlig-stoette-til-foraeldre-handicappede-mv/handicaptillaeg/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_revalidering_detalje = Detail(
            id: UUID(uuidString: "dc99442e-acc1-4e78-880a-6ebddc321251"),
            subjectID: UUID(uuidString: "6e2dbaf5-ab74-47a2-978b-294d41d3642b")!,
            htmlText: "Revalidering er både erhvervsrettede aktiviteter og økonomisk hjælp.\nRevalidering kan ske enten i form for revalidering eller når det erhvervsmæssige sigte er afklaret dvs. revalidering efter en særlig jobplan.\nAktiviteterne kan fx være arbejdsprøvning, uddannelse, optræning hos private eller offentlige arbejdsgivere eller hjælp til etablering af selvstændig virksomhed.\nDen økonomiske hjælp kan være kontanthjælp eller revalideringsydelse.\nFor at kunne få revalidering er det en forudsætning, at man har begrænsninger i arbejdsevnen, og at der ikke er andre tilbud som kan hjælpe en med at få tilknytning til arbejdsmarkedet.\n\nDu kan tilgå yderligere informationer omkring revalidering.",
            buttonLinkURL: "https://star.dk/da/indsatser-og-ordninger/indsatser-ved-sygdom-nedslidning-mv/revalidering/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let _ = videregåendeuddannelse_orlov.save(on: req.db).map { videregåendeuddannelse_orlov }.flatMap { s -> EventLoopFuture<Subject> in
            return videregåendeuddannelse_orlov_detalje.save(on: req.db).map { s }
        }
        let _ = videregåendeuddannelse_støtte_timer_hjælpemidler.save(on: req.db).map { videregåendeuddannelse_støtte_timer_hjælpemidler }.flatMap { s -> EventLoopFuture<Subject> in
            return videregåendeuddannelse_støtte_timer_hjælpemidler_detalje.save(on: req.db).map { s }
        }
        let _ = videregåendeuddannelse_praktik.save(on: req.db).map { videregåendeuddannelse_praktik }.flatMap { s -> EventLoopFuture<Subject> in
            return videregåendeuddannelse_praktik_detalje.save(on: req.db).map { s }
        }
        let _ = videregåendeuddannelse_handicap_tillæg.save(on: req.db).map { videregåendeuddannelse_handicap_tillæg }.flatMap { s -> EventLoopFuture<Subject> in
            return videregåendeuddannelse_handicap_tillæg_detalje.save(on: req.db).map { s }
        }
        return videregåendeuddannelse_revalidering.save(on: req.db).map { videregåendeuddannelse_revalidering }.flatMap { s -> EventLoopFuture<Subject> in
            return videregåendeuddannelse_revalidering_detalje.save(on: req.db).map { s }
        }
    }
}
