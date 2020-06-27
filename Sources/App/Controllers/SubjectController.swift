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
                        subject.with(\.$details)
                        subject.with(\.$subjects) { subject in
                                subject.with(\.$details)
                        }
                    }
            }
        .all()
    }
    
    func generateSubjects(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Detail.query(on: req.db).delete().flatMap { _ in
            return Subject.query(on: req.db).delete()
        }.flatMap { _ in
            return self.generateStudievejleder(req: req).flatMap { _ in
                return self.generateStuderende(req: req)
            }.transform(to: .noContent)
        }
    }
    
    private func iconPath(name: String, and ext: String = ".png") -> String {
        "icons/\(name)\(ext)"
    }
    
    private func generateStudievejleder(req: Request) -> EventLoopFuture<Subject> {
        let studievejleder = Subject(
            id: UUID(),
            parentID: nil,
            text: "Studievejleder",
            iconURL: iconPath(name: "ic_counselor"),
            backgroundColor: ColorPalette.lightSteelBlue.hexColor
        )
        
        return studievejleder.save(on: req.db).map { studievejleder }.flatMap { _ in
            return self.generateStøtteUnderUddannelse(req: req, color: .lightSteelBlue, subject: studievejleder).flatMap { _ in
                return self.generateStudievejlederGoderåd(req: req, studievejleder: studievejleder)
            }
        }
    }
    
    private func generateStuderende(req: Request) -> EventLoopFuture<Subject> {
        let studerende = Subject(
            id: UUID(),
            parentID: nil,
            text: "Studerende",
            iconURL: iconPath(name: "ic_student"),
            backgroundColor: ColorPalette.lightGreen.hexColor
        )
        
        return studerende.save(on: req.db).map { studerende }.flatMap { _ in
            return self.generateStøtteUnderUddannelse(req: req, color: .lightGreen, subject: studerende).flatMap { _ in
                return self.generateStuderendeGoderåd(req: req, studerende: studerende).flatMap { _ in
                    return self.generateStuderendeMindfulness(req: req, studerende: studerende).flatMap { _ in
                        return self.generateStuderendeChatforum(req: req, studerende: studerende)
                    }
                }
            }
        }
    }
    
    private func generateStøtteUnderUddannelse(req: Request, color: ColorPalette, subject: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try subject.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let støtte_under_uddannelse = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Støtte under uddannelse",
            iconURL: iconPath(name: "ic_supporthours_and_aids"),
            backgroundColor: color.hexColor
        )
        
        return støtte_under_uddannelse.save(on: req.db).map { støtte_under_uddannelse }.flatMap { _ in
            return self.generateStøtteUnderUddannelseGymnasieUddannelse(req: req, color: color, støtte_under_uddannelse: støtte_under_uddannelse).flatMap { _ in
                return self.generateStøtteUnderUddannelseErhvervsUddannelse(req: req, color: color, støtte_under_uddannelse: støtte_under_uddannelse).flatMap { _ in
                    return self.generateStøtteUnderUddannelseVideregåendeUddannelse(req: req, color: color, støtte_under_uddannelse: støtte_under_uddannelse)
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
            id: UUID(),
            parentID: parentID,
            text: "Gode råd",
            iconURL: iconPath(name: "ic_good_advice"),
            backgroundColor: ColorPalette.lightSteelBlue.hexColor
        )
        
        let gode_råd_detalje = Detail(
            id: UUID(),
            subjectID: gode_råd.id!,
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
    
    private func generateStuderendeGoderåd(req: Request, studerende: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try studerende.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let gode_råd = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Gode råd",
            iconURL: iconPath(name: "ic_good_advice"),
            backgroundColor: ColorPalette.lightGreen.hexColor
        )
        
        let gode_råd_detalje = Detail(
            id: UUID(),
            subjectID: gode_råd.id!,
            htmlText: nil,
            buttonLinkURL: nil,
            swipeableTexts: [
                "Det kan være en hjælp for dig at være åben omkring din diagnose og dine behov. Det kan være svært at fortælle en hel klasse omkring så private ting, men prøv at starte med din studiegruppe. Det at være åben omkring din situation kan hjælpe dine medstuderende til at forstå din situation og hjælpe dig med noter, støtte og forståelse.",
                "Prøv at strukturerer din hverdag. Lav prioriteringer i hvad der er vigtigt og hvad der kan vente eller undlades i forhold til både skolearbejde samt dagligdag. Afsæt tid til at lade batterierne op ved enten at slappe af eller sætte tid af til de aktiviteter der giver dig glæde og energi.",
                "Lav en liste over ting/aktiviteter der er vigtige for dig og som giver dig energi. Dette kan være med til at sætte fokus på små som store ting, der kan hjælpe dig med at lade batterierne op og holde balance i hverdagen. Afprøv eventuelt mindfulness, som du kan finde øvelser til her i appen.",
                "Hvis din skole har et pauserum, så gør brug af det i løbet af dagen til at ligge dig ned og slappe af så du kan fortsætte med fornyet energi.",
                "Gør brug af studievejleder og andet hjælp som skolen tilbyder - se evt. de rettigheder du har under Støtte under uddannelse her i appen.",
                "Undersøg om der er en forening i forhold til din diagnose, du kan blive medlem af. Gennem foreningerne kan du få informationer omkring arrangementer, og evt. få dig et netværk med andre der har den samme sygdom.",
                "Mange kronisk syge oplever, at det er godt at have et stærkt netværk bag sig i form af familie, venner mm. Der er mulighed for at opbygge et netværk via foreninger eller i chatforummet her i appen.",
                "Husk at du ikke er din sygdom, men at du har en sygdom. Du skal leve med den men den er ikke din identitet."
            ],
            videoLinkURLs: nil
        )
        
        return gode_råd.save(on: req.db).map { gode_råd }.flatMap { s -> EventLoopFuture<Subject> in
            return gode_råd_detalje.save(on: req.db).map { s }
        }
    }
    
    private func generateStuderendeMindfulness(req: Request, studerende: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try studerende.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let mindfulness = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Mindfulness",
            iconURL: iconPath(name: "ic_mindfulness"),
            backgroundColor: ColorPalette.lightGreen.hexColor
        )
        
        return mindfulness.save(on: req.db).map { mindfulness }.flatMap { _ in
            return self.generateStuderendeMindfulnessInformation(req: req, mindfulness: mindfulness).flatMap { _ in
                return self.generateStuderendeMindfulnessExercises(req: req, mindfulness: mindfulness)
            }
        }
    }
    
    private func generateStuderendeMindfulnessInformation(req: Request, mindfulness: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try mindfulness.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let mindfulness_information = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Hvorfor mindfulness",
            iconURL: iconPath(name: "ic_mindfulness_info"),
            backgroundColor: ColorPalette.lightGreen.hexColor
        )
        
        let mindfulness_information_detalje = Detail(
            id: UUID(),
            subjectID: mindfulness_information.id!,
            htmlText: "Mindfulness er en meditationsform som kan hjælpe dig til at blive mere tilstede i dit liv lige nu og her. Det hjælper dig til at fokusere på det der er lige nu, og ikke det der har været eller det der kommer i morgen eller længere ud i fremtiden.\n\nMindfulness udøves på en måde hvor du er venlig mod dig selv og ikke er negativ overfor den måde du har det og det du tænker på. Du ser på dig selv med positive briller.\n\nI mindfulness arbejder du med din opmærksomhed. Du noterer det der dukker op fra øjeblik til øjeblik og accepterer det der er. Man tager det til sig uanset hvad det er, også selvom det er noget man ikke nødvendigvis kan lide.\n\nUnder meditationen vil du helt sikkert opleve at din koncentration bevæger sig et andet sted hen og at dine tanker flyder. Når du opdager det, tager du koncentrationen tilbage til meditationen. Det kan være svært, men du kan ikke gøre noget forkert. Det er helt normalt at koncentrationen skifter fokus og det vigtigste er at du ikke dømmer dig selv.",
            buttonLinkURL: nil,
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        return mindfulness_information.save(on: req.db).map { mindfulness_information }.flatMap { s -> EventLoopFuture<Subject> in
            return mindfulness_information_detalje.save(on: req.db).map { s }
        }
    }
    
    private func generateStuderendeMindfulnessExercises(req: Request, mindfulness: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try mindfulness.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let mindfulness_exercises = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Øvelser",
            iconURL: iconPath(name: "ic_mindfulness_exercises"),
            backgroundColor: ColorPalette.lightGreen.hexColor
        )
        
        let mindfulness_exercises_detalje = Detail(
            id: UUID(),
            subjectID: mindfulness_exercises.id!,
            htmlText: nil,
            buttonLinkURL: nil,
            swipeableTexts: nil,
            videoLinkURLs: [
                "https://www.youtube.com/watch?v=aKUU5_H6H3c",
                "https://www.youtube.com/watch?v=i7RNkHI7d8Y"
            ]
        )
        
        return mindfulness_exercises.save(on: req.db).map { mindfulness_exercises }.flatMap { s -> EventLoopFuture<Subject> in
            return mindfulness_exercises_detalje.save(on: req.db).map { s }
        }
    }
    
    private func generateStuderendeChatforum(req: Request, studerende: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try studerende.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let chatforum = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Chatforum",
            iconURL: iconPath(name: "ic_chatforum"),
            backgroundColor: ColorPalette.lightGreen.hexColor
        )
        
        let chatforum_detail = Detail(
            id: UUID(),
            subjectID: chatforum.id!,
            htmlText: "Her i chatten har du mulighed for at chatte, oprette et netværk med andre kronisk syge, som enten er under uddannelse, eller som gerne vil starte på en uddannelse. Chatten vil for dig være muligheden for at skabe dig et nyt netværk, spare med andre kronisk syge med studerende, samt stille spørgsmål til din studievejleder. Selve chatten fungerer på den måde, at du optræder som en anonym bruger, dog er der lavet retningslinjer for hvad der er muligt at dele i dette chatforum. Det er fx ikke tilladt at udvise krænkende adfærd, true eller dele informationer med navne på læger eller andet fagpersonel. Sker dette, vil man automatisk blive blokeret og vil derfor ikke længere have mulighed for at deltage i dette chatforum.",
            buttonLinkURL: "",
            swipeableTexts: nil,
            videoLinkURLs: nil)
        
        return chatforum.save(on: req.db).map { chatforum }.flatMap { s -> EventLoopFuture<Subject> in
            return chatforum_detail.save(on: req.db).map { s }
        }
    }
    
    private func generateStøtteUnderUddannelseErhvervsUddannelse(req: Request, color: ColorPalette, støtte_under_uddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try støtte_under_uddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let erhvervsuddannelse = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Erhvervsuddannelse",
            iconURL: iconPath(name: "ic_secondary_school"),
            backgroundColor: color.hexColor
        )
        
        return erhvervsuddannelse.save(on: req.db).map { erhvervsuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return self.generateStudievejerStøtteUnderUddannelseErhvervsUddannelse(req: req, color: color, erhvervsuddannelse: erhvervsuddannelse)
        }
    }
    
    private func generateStøtteUnderUddannelseVideregåendeUddannelse(req: Request, color: ColorPalette, støtte_under_uddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try støtte_under_uddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let videregåendeuddannelse = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Videregående uddannelse",
            iconURL: iconPath(name: "ic_secondary_school"),
            backgroundColor: color.hexColor
        )
        
        return videregåendeuddannelse.save(on: req.db).map { videregåendeuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return self.generateStøtteUnderUddannelseVideregåendeUddannelse(req: req, color: color, videregåendeuddannelse: videregåendeuddannelse)
        }
    }
    
    private func generateStøtteUnderUddannelseGymnasieUddannelse(req: Request, color: ColorPalette, støtte_under_uddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try støtte_under_uddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let gymnasieuddannelse = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Gymnasieuddanelse",
            iconURL: iconPath(name: "ic_secondary_school"),
            backgroundColor: color.hexColor
        )
        
        return gymnasieuddannelse.save(on: req.db).map { gymnasieuddannelse }.flatMap { s -> EventLoopFuture<Subject> in
            return self.generateStøtteUnderUddannelseGymnasieUddannelse(req: req, color: color, gymnasieuddannelse: gymnasieuddannelse)
        }
    }
    
    private func generateStøtteUnderUddannelseGymnasieUddannelse(req: Request, color: ColorPalette, gymnasieuddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try gymnasieuddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let gymnasieuddannelse_studietur = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Studietur",
            iconURL: iconPath(name: "ic_study_trip"),
            backgroundColor: color.hexColor
        )
        
        let gymnasieuddannelse_støttetimer = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Støttetimer",
            iconURL: iconPath(name: "ic_supporthours_and_aids"),
            backgroundColor: color.hexColor
        )
        
        let gymnasieuddannelse_fritagelseForIdrætC = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Fritagelse for idræt C",
            iconURL: iconPath(name: "ic_exemption_from_sports"),
            backgroundColor: color.hexColor
        )
        
        let gymnasieuddannelse_udvidelseAfUddannelse = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Udvidelse af uddannelse",
            iconURL: iconPath(name: "ic_extending_education"),
            backgroundColor: color.hexColor
        )
        
        let gymnasieuddannelse_syge_supplerende_undervisning = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Syge / Supplerende undervisning",
            iconURL: iconPath(name: "ic_sick_or_supplementary_education"),
            backgroundColor: color.hexColor
        )
        
        let gymnasieuddannelse_eksamen = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Eksamen",
            iconURL: iconPath(name: "ic_examination_counselor"),
            backgroundColor: color.hexColor
        )
        
        let gymnasieuddannelse_studietur_detalje = Detail(
            id: UUID(),
            subjectID: gymnasieuddannelse_studietur.id!,
            htmlText: "Det er muligt at få støtte under studieture. Studieturene kan både være i Danmark og i udlandet. Du kan få støtte til én obligatorisk studietur.\nUdgifter du kan få dækket, er fx hvis du skal have en hjælper eller tegnsprogstolk med på turen; rejse, lønudgifter, ophold, diæter mm.\n\nDu kan tilgå yderligere informationer omkring økonomisk støtte til studieture.",
            buttonLinkURL: "https://www.spsu.dk/for-sps-ansvarlige/administration-af-sps/sps-paa-studierejser-og-i-praktik",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_støttetimer_detalje = Detail(
            id: UUID(),
            subjectID: gymnasieuddannelse_støttetimer.id!,
            htmlText: "Hvis du i forbindelse med manglende udbytte af undervisningen har behov for specialundervisning eller anden socialpædagogisk støtte har du muligheden for at få tilbudt støttetimer for at kompensere for psykisk eller fysiske funktionsnedsættelser.\n\nDu kan tilgå yderligere informationer omkring støttetimer.",
            buttonLinkURL: "https://www.uvm.dk/forberedende-grunduddannelse/om-forberedende-grunduddannelse/specialpaedagogisk-stoette",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_fritagelseForIdrætC_detalje = Detail(
            id: UUID(),
            subjectID: gymnasieuddannelse_fritagelseForIdrætC.id!,
            htmlText: "Hvis du på grund af din sygdom vil have svært ved at deltage i undervisningen idræt C, er der mulighed for at du kan blive fritaget for undervisningen.\nInstitutionen kan træffe en afgørelse herom pga. Sagkyndige oplysninger og udtalelser.\nInstitutionen beslutter samtidig, hvilken undervisning eleven skal gennemføre i stedet for idræt C.\n\nDu kan tilgå yderligere informationer omkring fritagelse for idræt C.",
            buttonLinkURL: "https://www.regionh.dk/ungepanel/nyheder/Sider/Nyheder/2018/fritagelse-fra-idraet-paa-stx-uddannelsen.aspx",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_udvidelseAfUddannelse_detalje = Detail(
            id: UUID(),
            subjectID: gymnasieuddannelse_udvidelseAfUddannelse.id!,
            htmlText: "Hvis du på grund af din sygdom er forhindret i at følge undervisningen i længere perioder, kan skolen tilrettelægge en 2-årig gymnasial uddannelse over 3 år og en 3-årig gymnasial uddannelse over 4 år.\n\nDu kan tilgå yderligere informationer omkring udvidelse/forlængelse af din uddannelse kap 9.",
            buttonLinkURL: "https://danskelove.dk/gymnasieloven",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_syge_supplerende_undervisning_detalje = Detail(
            id: UUID(),
            subjectID: gymnasieuddannelse_syge_supplerende_undervisning.id!,
            htmlText: "Hvis du går på en gymnasial uddannelse, har du mulighed for at få sygeundervisning eller supplerende undervisning, hvis du ikke kan følge den almindelige undervisning efter 10 dages sammenhængende fravær ved sygdom.\n\nDu kan tilgå yderligere informationer omkring syge og supplerende undervisning bekendtgørelse kap. 8.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2017/497",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let gymnasieuddannelse_eksamen_detalje = Detail(
            id: UUID(),
            subjectID: gymnasieuddannelse_eksamen.id!,
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
    
    private func generateStudievejerStøtteUnderUddannelseErhvervsUddannelse(req: Request, color: ColorPalette, erhvervsuddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try erhvervsuddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let erhvervsuddannelse_ekstra_undervisning = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Ekstra undervisning",
            iconURL: iconPath(name: "ic_extra_teaching"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_udvidelse_af_uddannelse = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Udvidelse af uddannelse",
            iconURL: iconPath(name: "ic_extending_education"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_støtte_timer_hjælpemidler = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Støttetimer/hjælpemidler",
            iconURL: iconPath(name: "ic_supporthours_and_aids"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_eksamen = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Eksamen",
            iconURL: iconPath(name: "ic_examination_counselor"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_revalidering = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Revalidering",
            iconURL: iconPath(name: "ic_rehabiliation"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_handicap_tillæg = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Handicap tillæg",
            iconURL: iconPath(name: "ic_handicap_supplement"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_praktik = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Praktik",
            iconURL: iconPath(name: "ic_internship"),
            backgroundColor: color.hexColor
        )
        
        let erhvervsuddannelse_ekstra_undervisning_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_ekstra_undervisning.id!,
            htmlText: "Hvis du er i forbindelse med manglende udbytte af undervisningen, har behov for specialundervisning eller anden socialpædagogisk støtte har du muligheden for at få tilbudt støttetimer for at kompensere for psykiske eller fysiske funktionsnedsættelser.\n\nDu kan tilgå yderligere informationer omkring ekstra undervisning.",
            buttonLinkURL: "https://www.spsu.dk/for-sps-ansvarlige/videregaaende-uddannelser/psykiske-funktionsnedsaettelser/korte-og-mellemlange-videregaaende-uddannelser/stoetteformer/stoettetimer-ved-faglig-stoettelaerer",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_udvidelse_af_uddannelse_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_udvidelse_af_uddannelse.id!,
            htmlText: "Hvis du har brug for en længere uddannelsestid, end den uddannelsestid skolen har beregnet, kan man søge om forlængelse.\nErhvervsskolen vejleder gerne om mulighederne, og i nogle tilfælde kan skolen og det lokale uddannelsesudvalg godkende en forlængelse af uddannelsestiden uden, at der skal sendes en ansøgning til det faglige udvalg.\n\nDu kan tilgå yderligere informationer omkring udvidelse af uddannelse.",
            buttonLinkURL: "https://www.uddannelsesnaevnet.dk/virksomheder/uddannelsesaftalen/afkortning-eller-forlaengelse-af-uddannelsestid",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_støtte_timer_hjælpemidler_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_støtte_timer_hjælpemidler.id!,
            htmlText: "Hvis du får bevilget studiestøttetimer, kan du fx arbejde med udvikling af strategier til at styrker og understøtte dit faglige overblik og struktur.\nDu kan få hjælp til at bruge forskellige planlægningsværktøjer, som du kan bruge, når du skal skrive opgaver eller i gang med større projekter.\n\nDu kan tilgå yderligere informationer omkring støttetimer og hjælpemidler.",
            buttonLinkURL: "https://www.spsu.dk/for-elever-og-studerende/leverandører%20af%20støtte",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_eksamen_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_eksamen.id!,
            htmlText: "Hvis din sygdom påvirker din præstation ved eksamener, har du muligheden for særlige prøvevilkår, så du bliver ligestillet med andre i prøvesituationen.\n\nDu kan tilgå yderligere informationer omkring eksamen prøveafholdelse kap 5.",
            buttonLinkURL: "https://www.retsinformation.dk/eli/lta/2016/343#idc95d8ab3-ad8a-41e6-9af1-78f4afad8421",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_revalidering_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_revalidering.id!,
            htmlText: "Revalidering er både erhvervsrettede aktiviteter og økonomisk hjælp.\nRevalidering kan ske enten i form for revalidering eller når det erhvervsmæssige sigte er afklaret dvs. revalidering efter en særlig jobplan.\nAktiviteterne kan fx være arbejdsprøvning, uddannelse, optræning hos private eller offentlige arbejdsgivere eller hjælp til etablering af selvstændig virksomhed.\nDen økonomiske hjælp kan være kontanthjælp eller revalideringsydelse.\nFor at kunne få revalidering er det en forudsætning, at man har begrænsninger i arbejdsevnen, og at der ikke er andre tilbud som kan hjælpe en med at få tilknytning til arbejdsmarkedet.\n\nDu kan tilgå yderligere informationer omkring revalidering.",
            buttonLinkURL: "https://star.dk/da/indsatser-og-ordninger/indsatser-ved-sygdom-nedslidning-mv/revalidering/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_handicap_tillæg_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_handicap_tillæg.id!,
            htmlText: "Læser du på en dansk erhvervsuddannelse og har en varig psykisk eller fysisk funktionsnedsættelse, der giver dig meget betydelige begrænsninger i evnen til at påtage dig et erhvervsarbejde, så kan du søge om at få et handicaptillæg ved siden af din SU.\nDu kan som noget nyt søge handicaptillæg i de måneder, hvor du modtager SU (grundforløbende og øvrige forløb med SU).\n\nDu kan tilgå yderligere informationer omkring handicaptillæg.",
            buttonLinkURL: "https://www.su.dk/su/saerlig-stoette-til-foraeldre-handicappede-mv/handicaptillaeg/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let erhvervsuddannelse_praktik_detalje = Detail(
            id: UUID(),
            subjectID: erhvervsuddannelse_praktik.id!,
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
    
    private func generateStøtteUnderUddannelseVideregåendeUddannelse(req: Request, color: ColorPalette, videregåendeuddannelse: Subject) -> EventLoopFuture<Subject> {
        var parentID: UUID? = nil
        do {
            parentID = try videregåendeuddannelse.requireID()
        } catch {
            print(error.localizedDescription)
        }
        
        let videregåendeuddannelse_orlov = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Orlov",
            iconURL: iconPath(name: "ic_sick_or_supplementary_education"),
            backgroundColor: color.hexColor
        )
        
        let videregåendeuddannelse_støtte_timer_hjælpemidler = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Støttetimer/hjælpemidler",
            iconURL: iconPath(name: "ic_supporthours_and_aids"),
            backgroundColor: color.hexColor
        )
        
        let videregåendeuddannelse_praktik = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Praktik",
            iconURL: iconPath(name: "ic_internship"),
            backgroundColor: color.hexColor
        )
        
        let videregåendeuddannelse_handicap_tillæg = Subject(
            id: UUID(),
            parentID: parentID,
            text: "Handicap tillæg",
            iconURL: iconPath(name: "ic_handicap_supplement"),
            backgroundColor: color.hexColor
        )
        
        let videregåendeuddannelse_revalidering = Subject(
             id: UUID(),
             parentID: parentID,
             text: "Revaldering",
             iconURL: iconPath(name: "ic_rehabiliation"),
             backgroundColor: color.hexColor
        )
        
        let videregåendeuddannelse_orlov_detalje = Detail(
            id: UUID(),
            subjectID: videregåendeuddannelse_orlov.id!,
            htmlText: "Der kan være mange forskellige grunde til at søge om orlov fx graviditet, arbejde, værnepligt eller sygdom.\nStudievejlederen på uddannelsesstedet kan rådgive dig om reglerne og ansøgningsproceduren, samt komme med gode råd.\n\nDu kan tilgå yderligere informationer omkring orlov.",
            buttonLinkURL: "https://www.ug.dk/videregaaendeuddannelse/orlov-paa-videregaaende-uddannelser",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_støtte_timer_hjælpemidler_detalje = Detail(
            id: UUID(),
            subjectID: videregåendeuddannelse_støtte_timer_hjælpemidler.id!,
            htmlText: "Hvis du får bevilget studiestøttetimer, kan du fx arbejde med udvikling af strategier til at styrker og understøtte dit faglige overblik og struktur.\nDu kan få hjælp til at bruge forskellige planlægningsværktøjer, som du kan bruge, når du skal skrive opgaver eller i gang med større projekter.\n\nDu kan tilgå yderligere informationer omkring støttetimer og hjælpemidler.",
            buttonLinkURL: "https://www.spsu.dk/for-elever-og-studerende/leverandører%20af%20støtte",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_praktik_detalje = Detail(
            id: UUID(),
            subjectID: videregåendeuddannelse_praktik.id!,
            htmlText: "Er der obligatoriske praktikperioder under din uddannelse, så giver dette dig også ret til SPS under praktikken, selvom praktikperioden evt. Ikke er SU berettiget.\n\nDu kan tilgå yderligere informationer omkring praktik.",
            buttonLinkURL: "https://www.spsu.dk/for-elever-og-studerende/sps-naar-du-er-studerende-paa-en-videregaaende-uddannelse/sps-naar-du-er-studerende-paa-en-videregaaende-uddannelse",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_handicap_tillæg_detalje = Detail(
            id: UUID(),
            subjectID: videregåendeuddannelse_handicap_tillæg.id!,
            htmlText: "Læser du på en dansk erhvervsuddannelse og har en varig psykisk eller fysisk funktionsnedsættelse, der giver dig meget betydelige begrænsninger i evnen til at påtage dig et erhvervsarbejde, så kan du søge om at få et handicaptillæg ved siden af din SU.\nDu kan som noget nyt søge handicaptillæg i de måneder, hvor du modtager SU (grundforløbende og øvrige forløb med SU).\n\nDu kan tilgå yderligere informationer omkring handicaptillæg.",
            buttonLinkURL: "https://www.su.dk/su/saerlig-stoette-til-foraeldre-handicappede-mv/handicaptillaeg/",
            swipeableTexts: nil,
            videoLinkURLs: nil
        )
        
        let videregåendeuddannelse_revalidering_detalje = Detail(
            id: UUID(),
            subjectID: videregåendeuddannelse_revalidering.id!,
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
