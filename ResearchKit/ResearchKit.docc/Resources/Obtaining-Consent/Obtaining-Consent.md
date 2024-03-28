# Obtaining Consent

Guide your participants through the Informed Consent process.

## Overview

Research studies that involve human subjects typically require some form of ethics review. Depending on the country, an institutional review board (IRB) or an ethics committee (EC) might perform this. Some studies may require informed consent to conduct a research study; the researcher must ensure that each participant is fully informed about the nature of the study, and must obtain a signed consent from each participant. Additionally, app review may require consent.

The ResearchKit™ framework makes it easy to display your consent document and obtain a participant's signature. If the signature needs to be verifiable and irrevocable, you're responsible for producing a digital signature or generating a PDF to attest to the identity of the participant and the time they signed the form.

The ResearchKit framework makes obtaining consent easier by providing APIs to help with:

- **Informing Participants** - `ORKInstructionStep`
- **Reviewing Consent + Signature** - `ORKWebViewStep`
- **Consent Sharing** - `ORKFormStep`
- **PDF Viewing/Sharing** - `ORKPDFViewerStep`


## Informing Participants

When providing informed consent to prospective study participants, it's important to cover the necessary topics pertaining to your study. Here are some common topics usually addressed during informed consent.

- **Overview** - A brief, concise description of the purpose and goal of the study.
- **Data gathering** - The types of data gathered, where it will be stored, and who will have access to it.
- **Privacy** - How your study ensures privacy is maintained while participating.
- **Data use** - How you intend to use the data collected during this study. 
- **Time commitment** - The estimated amount of time a participant should expect to dedicate to your study.
- **Surveys** - The types of surveys and questions you present to the participants.
- **Tasks** - The tasks the participant must complete for the study.
- **Withdrawal** - Information about withdrawal from the study and what happens to the participant's data.  


Create two instruction steps to present both a 'Welcome' & 'Before You Join' page.

```swift
// Welcome page.
let welcomeStep = ORKInstructionStep(identifier: String(describing: Identifier.consentWelcomeInstructionStep))
welcomeStep.iconImage = UIImage(systemName: "hand.wave")
welcomeStep.title = "Welcome!"
welcomeStep.detailText = "Thank you for joining our study. Tap Next to learn more before signing up."
        
// Before You Join page.
let beforeYouJoinStep = ORKInstructionStep(identifier: String(describing: Identifier.informedConsentInstructionStep))
beforeYouJoinStep.iconImage = UIImage(systemName: "doc.text.magnifyingglass")
beforeYouJoinStep.title = "Before You Join"
        
let sharingHealthDataBodyItem = ORKBodyItem(text: "The study will ask you to share some of your Health data.",
                                            detailText: nil,
                                            image: UIImage(systemName: "heart.fill"),
                                            learnMoreItem: nil,
                                            bodyItemStyle: .image)
        
let completingTasksBodyItem = ORKBodyItem(text: "You will be asked to complete various tasks over the duration of the study.",
                                          detailText: nil,
                                          image: UIImage(systemName: "checkmark.circle.fill"),
                                          learnMoreItem: nil,
                                          bodyItemStyle: .image)
        
let signatureBodyItem = ORKBodyItem(text: "Before joining, we will ask you to sign an informed consent document.",
                                    detailText: nil,
                                    image: UIImage(systemName: "signature"),
                                    learnMoreItem: nil,
                                    bodyItemStyle: .image)
        
let secureDataBodyItem = ORKBodyItem(text: "Your data is kept private and secure.",
                                     detailText: nil,
                                     image: UIImage(systemName: "lock.fill"),
                                     learnMoreItem: nil,
                                     bodyItemStyle: .image)
        
beforeYouJoinStep.bodyItems = [
    sharingHealthDataBodyItem,
    completingTasksBodyItem,
    signatureBodyItem,
    secureDataBodyItem
]
```

The instruction steps are presented in Figure 1.

|   |   |
|---|---|
| ![Welcome instruction step](obtaining-consent-welcome-step) | ![Before you join instruction step](obtaining-consent-before-you-join-step) |

## Review consent

Participants can review the consent in the ``ORKWebViewStep`` as HTML. Depending on your signature requirements, you can also ask participants to write their signature on the same screen.

Produce the content for consent review by converting the previous instructions steps to HTML, or provide entirely separate review content as custom HTML in the web view step's html property.

```swift
let instructionSteps = [welcomeStep, beforeYouJoinStep]
        
let webViewStep = ORKWebViewStep(identifier: "WebViewStepIdentifier", instructionSteps: instructionSteps)
webViewStep.showSignatureAfterContent = true
return webViewStep
```
The web view step appears as shown in Figure 2.

|   |   |
|---|---|
| ![Review Consent](obtaining-consent-review-1) | ![Provide signature](obtaining-consent-review-2) |

## Consent sharing

Apps that use the ResearchKit framework primarily collect data for a specific study. If you want to ask participants to share their data with other researchers, participants must be able to control that decision.

Use ``ORKFormStep`` to explicitly obtain permission to share participants' data that you collect for your study with other researchers, if allowed by your IRB or EC. To use a form step, include it in a task, just before a consent review step.

```swift
// Construct the text choices.
let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Institution and qualified researchers worldwide", value: 1 as NSNumber),
                                            ORKTextChoice(text: "Only institution and its partners", value: 2 as NSNumber)]
let textChoiceAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
// Construct a form item for text choices.
let textChoiceFormItem = ORKFormItem(identifier: "TextChoiceFormItem", text: "Who would you like to share your data with?", answerFormat: textChoiceAnswerFormat)
        
// Construct the form step.
let formStepText = "Institution and its partners will receive your study data from your participation in this study.\n \nSharing your coded study data more broadly (without information such as your name) may benefit this and future research."    
let formStep = ORKFormStep(identifier: "ConsentSharingFormStepIdentifier", title: "Sharing Options", text: formStepText)
formStep.formItems = [textChoiceFormItem]
        
return formStep
```

The form step is in Figure 3.

![Consent sharing](obtaining-consent-sharing)

## Enhanced PDF Viewing

Providing clear and concise material for the user to review is an important part of the data collection process. With ``ORKPDFViewerStep``, the user can view a PDF in detail, perform text search, and mark up sections of the document. Other available features include viewing the pages of the PDF as thumbnails for quick perusal, printing, and saving the document.

When the ``ORKTask`` is finished, use ``ORKHTMLPDFWriter`` to store the web view step's html as a PDF then view it later with the ``ORKPDFViewerStep``.

```swift
guard let stepResult = taskViewController.result.result(forIdentifier: "WebViewStepIdentifier") as? ORKStepResult else {
	return
}
        
if let webViewStepResult = stepResult.results?.first as? ORKWebViewStepResult, let html = webViewStepResult.htmlWithSignature {
	let htmlFormatter = ORKHTMLPDFWriter()
            
    htmlFormatter.writePDF(fromHTML: html) { data, error in
       let pdfURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("consentTask")
            .appendingPathExtension("pdf")
        try? data.write(to: pdfURL)
    }
}
```

The PDF viewer step is in Figure 4.

|   |   |
|---|---|
| ![PDF page 1](obtaining-consent-pdf-1) | ![PDF page 2](obtaining-consent-pdf-2) |
