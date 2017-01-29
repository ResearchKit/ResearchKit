/*
 Copyright (c) 2017, Andrew Hill and Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <Foundation/Foundation.h>


@class ORKStep;
@class ORKResult;
@class ORKTaskResult;

/**
 The `ORKHL7CDADocumentType` value indicates which section HL7CDDFragments should be attributed to
 the task.
 */
typedef NS_ENUM(NSInteger, ORKHL7CDADocumentType) {
    
    /// The CCD (Continuity of Care Document) is used to summarise the transfer of care from one individual or organisation to another.
    ORKHL7CDADocumentTypeCCD,
    
    /// A consultation note describes a patient review episode by a clinician.
    ORKHL7CDADocumentTypeConsultationNote,
    
    /// A diagnostic imaging report contains findings from an imaging investigation.
    ORKHL7CDADocumentTypeDiagnosticImagingReport
};


/**
 The `ORKHL7CDASectionType` value indicates which section HL7CDDFragments should be attributed to
 the task.
 */
typedef NS_ENUM(NSInteger, ORKHL7CDASectionType) {
    
    /// The Allergies Coded section lists and describes any medication allergies, adverse reactions, idiosyncratic reactions, anaphylaxis/anaphylactoid reactions to food items, and metabolic variations or adverse reactions/allergies to other substances (such as latex, iodine, tape adhesives) used to assure the safety of health care delivery. At a minimum, it should list currently active and any relevant historical allergies and adverse reactions. Coding for entries is required.
    ORKHL7CDASectionTypeAllergiesCoded,
    
    /// The Purpose section represents the specific reason for which the summarization was generated, such as in response to a request...[used only] when the CCD has a specific purpose such as a transfer, referral, or patient request. [CCD 2.8]
    ORKHL7CDASectionTypePurpose,
    
    /// The Problems section lists and describes all relevant clinical problems at the time the summary is generated. At a minimum, all pertinent current and historical problems should be listed. All problem entries for this section must be coded. [CCD 3.5]
    ORKHL7CDASectionTypeProblems,
    
    /// The Procedures section defines all interventional, surgical, diagnostic, or therapeutic procedures or treatments pertinent to the patient historically at the time the document is generated. The section may contain all procedures for the period of time being summarized, but should include notable procedures.” [CCD 3.14]
    ORKHL7CDASectionTypeProcedures,
    
    /// The Family History section contains data defining the patient’s genetic relatives in terms of possible or relevant health risk factors that have a potential impact on the patient’s healthcare risk profile. [CCD 3.6]
    ORKHL7CDASectionTypeFamilyHistory,
    
    /// “The Social History section contains data defining the patient’s occupational, personal (e.g. lifestyle), social, and environmental history and health risk factors, as well as administrative data such as marital status, race, ethnicity and religious affiliation. [CCD 3.7]
    ORKHL7CDASectionTypeSocialHistory,
    
    /// “The Payers section describes payers and the coverage they provide for defined activities. For each payer, “all the pertinent data needed to contact, bill to, and collect from that payer should be included. Authorization information that can be used to define pertinent referral, authorization tracking number, procedure, therapy, intervention, device, or similar authorizations for the patient or provider or both should be included. [CCD 3.1]
    ORKHL7CDASectionTypePayers,
    
    /// The Advance Directives section contains data defining the patient’s advance directives and any reference to supporting documentation...  This section contains data such as the existence of living wills, healthcare proxies, and CPR and resuscitation status. [CCD 3.2]
    ORKHL7CDASectionTypeAdvanceDirectives,
    
    /// The Alerts section is used to list and describe any allergies, adverse reactions, and alerts that are pertinent to the patient’s current or past medical history. [CCD 3.8]
    ORKHL7CDASectionTypeAlerts,
    
    /// The Medications section defines a patient’s current medications and pertinent medication history. [CCD 3.9]
    ORKHL7CDASectionTypeMedications,
    
    /// The Immunizations section defines a patient’s current immunization status and pertinent immunization history. [CCD 3.11]
    ORKHL7CDASectionTypeImmunizations,
    
    /// The Medical Equipment section describes all pertinent equipment relevant to the diagnosis, care, and treatment of a patient.” [CCD 3.10]
    ORKHL7CDASectionTypeMedicalEquipment,
    
    /// The Vital Signs section may contain all vital signs for the period of time being summarized, but at a minimum should include notable vital signs such as the most recent, maximum and/or minimum, or both, baseline, or relevant trends. [CCD 3.12]
    ORKHL7CDASectionTypeVitalSigns,
    
    /// The Functional Status section contains information on the “normal functioning” of the patient at the time the record is created. Deviation from normal function and limitations and improvements should be included here. [CCD 3.4]
    ORKHL7CDASectionTypeFunctionalStatus,
    
    /// The Results section contains the results of observations generated by laboratories, imaging procedures, and other procedures. The section may contain all results for the period of time being summarized, but should include notable results such as abnormal values or relevant trends. [CCD 3.13].
    ORKHL7CDASectionTypeResults,
    
    /// The Encounters section is used to list and describe any healthcare encounters pertinent to the patient’s current health status or historical health history. [CCD 3.15]
    ORKHL7CDASectionTypeEncounters,
    
    /// The Plan Of Care section contains all active, incomplete, or pending orders, appointments, referrals,  procedures, services, or any other pending event of clinical significance to the current and ongoing care of the patient ... The plan of care section also contains information regarding goals and clinical reminders. [CCD 3.16]
    ORKHL7CDASectionTypePlanOfCare,
    
    /// The Assessment section (also called impression or diagnoses) represents the clinician's conclusions and working assumptions that will guide treatment of the patient. The assessment formulates a specific plan or set of recommendations. The assessment may be a list of specific disease entities or a narrative block.
    ORKHL7CDASectionTypeAssessment,
    
    /// The History of Present Illness section describes the history related to the reason for the encounter.  It contains the historical details leading up to and pertaining to the patient’s current complaint or reason for seeking medical care.
    ORKHL7CDASectionTypeHistoryOfPresentIllness,
 
    /// The Physical Exam section includes direct observations made by the clinician. The examination may include the use of simple instruments and may also describe simple maneuvers performed directly on the patient’s body. This section includes only observations made by the examining clinician using inspection, palpation, auscultation, and percussion; it does not include laboratory or imaging findings. The exam may be limited to pertinent body systems based on the patient’s chief complaint or it may include a comprehensive examination. The examination may be reported as a collection of random clinical statements or it may be reported categorically.
    ORKHL7CDASectionTypePhysicalExam,
    
    /// A Reason for Referral section records the reason the patient is being referred for a consultation by a provider. An optional Chief Complaint section may capture the patient’s description of the reason for the consultation.
    ORKHL7CDASectionTypeReasonForReferral,
    
    /// The Chief Complaint section records the patient's chief complaint (the patient’s own description).
    ORKHL7CDASectionTypeChiefComplaint,
    
    /// The General Status section describes general observations and readily observable attributes of the patient, including affect and demeanor, apparent age compared to actual age, gender, ethnicity, nutritional status based on appearance, body build and habitus (e.g., muscular, cachectic, obese), developmental or other deformities, gait and mobility, personal hygiene, evidence of distress, and voice quality and speech.
    ORKHL7CDASectionTypeGeneralStatus,
    
    /// The PastMedicalHistory section describes the history related to the patient’s current complaints, problems, or diagnoses. It records the historical details leading up to and pertaining to the patient’s current complaint or reason for seeking medical care.
    ORKHL7CDASectionTypePastMedicalHistory,
    
    /// The Problems section lists and describes all relevant clinical problems at the time the summary is generated. At a minimum, all pertinent current and historical problems should be listed. Coding for this section is optional.
    ORKHL7CDASectionTypeProblemsOptional,
    
    /// The Review of Systems section contains a relevant collection of symptoms and functions systematically gathered by a clinician. It includes symptoms the patient is currently experiencing, some of which were not elicited during the history of present illness, as well as a potentially large number of pertinent negatives, for example, symptoms that the patient denied experiencing.
    ORKHL7CDASectionTypeReviewOfSystems,
    
    /// The DICOM Object Catalog lists all referenced objects and their parent Series and Studies, plus other DICOM attributes required for retrieving the objects. DICOM Object Catalog sections are not intended for viewing and contain empty section text.
    ORKHL7CDASectionTypeDICOMObjectCatalog,
    
    /// The Diagnostic Imaging Findings contains the main narrative body of a diagnostic imaging report.
    ORKHL7CDASectionTypeDiagnosticImagingFindings,
    
    /// The Diagnostic Imaging Addendum section records any addendums made to a report after its initial release.
    ORKHL7CDASectionTypeDiagnosticImagingAddendum,
    
    /// The Complications section records any complications following a procedure or imaging event.
    ORKHL7CDASectionTypeComplications,
    
    /// The Conclusions section records any conclusions to a dianostic imaging report.
    ORKHL7CDASectionTypeConclusions,
    
    /// The Current Imaging Procedure Descriptions describes the imaging procedures being undertaken.
    ORKHL7CDASectionTypeCurrentImagingProcedureDescriptions,
    
    /// The Diagnostic Imaging Document Summary summarises the report.
    ORKHL7CDASectionTypeDiagnosticImagingDocumentSummary,
    
    /// The Diagnostic Imaging Key Images identifies which key images highlight the findings recorded in the summary.
    ORKHL7CDASectionTypeDiagnosticImagingKeyImages,
    
    /// The Medical General History records any pertinent history for the diagnostic report. It is not intended as a full summary of a patient's medical history.
    ORKHL7CDASectionTypeMedicalGeneralHistory,
    
    /// The Prior Imaging Procedure Descriptions describe any pertinent previous imaging to be aware of.
    ORKHL7CDASectionTypePriorImagingProcedureDescriptions,
    
    /// The Radiology Impression gives the likely differential diagnosis based upon the imaging.
    ORKHL7CDASectionTypeRadiologyImpression,
    
    /// The Radiology Comparison Study Observation section summarises any observations from comparison studies to other image sets.
    ORKHL7CDASectionTypeRadiologyComparisonStudyObservation,
    
    /// The Radiology Reason For Study section summarises the reason the diagnostic imaging was requested.
    ORKHL7CDASectionTypeRadiologyReasonForStudy,
    
    /// The Radiology Study Recommendations section records any recommendations from the reporter to the clinicians looking after the patient of further action to be taken.
    ORKHL7CDASectionTypeRadiologyStudyRecommendations,
    
    /// The Requested Image Studies Information section records any information on the requested studies.
    ORKHL7CDASectionTypeRequestedImageStudiesInformation    

};

/**
 The `ORKHL7CDADocumentType` value indicates which section HL7CDDFragments should be attributed to
 the task.
 */
typedef NS_ENUM(NSInteger, ORKHL7CDAEntryTextType) {
    
    /// No text is accepted for this section.
    ORKHL7CDAEntryTextTypeNone,
    
    /// The text entries are amalgamated at the root - <text> is the parent entity in the XML.
    ORKHL7CDAEntryTextTypePlain,
    
    /// The text entries are compiled into a list - <list> is the parent entity in the XML. Your text should begin and end with an <item> tag.
    ORKHL7CDAEntryTextTypeInList,
    
    /// The text entries are compiled into a table - <table> is the parent entity in the XML.
    ORKHL7CDAEntryTextTypeInTable
    
};

/**
 The `ORKHL7CDATelecomUseType` valueset is used to denote the type of telephone number provided in contact details.
 */
typedef NS_ENUM(NSInteger, ORKHL7CDATelecomUseType) {
    
    /// A primary home telephone number (landline or mobile).
    ORKHL7CDATelecomUseTypePrimaryHome,
    
    /// A work telephone number.
    ORKHL7CDATelecomUseTypeWorkPlace,
    
    /// A secondary mobile telephone number.
    ORKHL7CDATelecomUseTypeMobileContact,
    
    /// A vacation phone number.
    ORKHL7CDATelecomUseTypeVacationHome
    
};


/**
 The `ORKHL7CDAAdministrativeGenderType` valueset is used to define the person's gender for administrative purposes.
 */
typedef NS_ENUM(NSInteger, ORKHL7CDAAdministrativeGenderType) {
    
    /// Not specified
    ORKHL7CDAAdministrativeGenderTypeNotSpecified,
    
    /// Female
    ORKHL7CDAAdministrativeGenderTypeFemale,
    
    /// Male
    ORKHL7CDAAdministrativeGenderTypeMale,
    
    /// Undifferentiated
    ORKHL7CDAAdministrativeGenderTypeUndifferentiated
    
};

/**
 The `ORKHL7CDATelecom` class defines the attributes of a telephone number referred to within an HL7 CDA document.
 These can apply in a number of areas for example as the author, recipient or custodian of the document.
 */
@interface ORKHL7CDATelecom : NSObject

@property (nonatomic) ORKHL7CDATelecomUseType telecomUseType;
@property (nonatomic, nonnull, copy) NSString *value;

@end


/**
 The `ORKHL7CDAAddress` class defines the attributes of an address referred to within an HL7 CDA document.
 These can apply in a number of areas for example as the author, recipient or custodian of the document.
 */
@interface ORKHL7CDAAddress : NSObject

@property (nonatomic, nonnull, copy) NSString *street;
@property (nonatomic, nonnull, copy) NSString *city;
@property (nonatomic, nonnull, copy) NSString *state;
@property (nonatomic, nonnull, copy) NSString *postalCode;
@property (nonatomic, nonnull, copy) NSString *country;

@end

/**
 The `ORKHL7CDAPerson` class defines the attributes of a person referred to within an HL7 CDA document.
 These can apply in a number of areas for example as the author, recipient or custodian of the document.
 */
@interface ORKHL7CDAPerson : NSObject

@property (nonatomic, nullable, copy) NSString *prefix;
@property (nonatomic, nonnull, copy) NSString *givenName;
@property (nonatomic, nonnull, copy) NSString *familyName;
@property (nonatomic, nullable, copy) NSString *suffix;
@property (nonatomic) ORKHL7CDAAdministrativeGenderType gender;
@property (nonatomic, nonnull, copy) NSDate *birthdate;
@property (strong, nullable) ORKHL7CDAAddress *address;
@property (nonatomic, nullable, copy) NSArray <ORKHL7CDATelecom *> *telecoms;

@end

/**
 The `ORKHL7CDADeviceAuthor` class defines the attributes of the authoring software referred to within an HL7 CDA document.
 */
@interface ORKHL7CDADeviceAuthor : NSObject

@property (strong, nullable) ORKHL7CDAAddress *address;
@property (strong, nullable) NSArray <ORKHL7CDATelecom *> *telecoms;
@property (nonatomic, nonnull, copy) NSString *softwareName;

@end

/**
 The `ORKHL7CDACustodian` class defines the attributes of the authoring software referred to within an HL7 CDA document.
 */
@interface ORKHL7CDACustodian : NSObject

@property (nonatomic, nonnull, copy) NSString *name;
@property (strong, nonnull) ORKHL7CDAAddress *address;
@property (strong, nonnull) ORKHL7CDATelecom *telecom;

@end

/**
 The `ORKHL7CDASectionDescription` class is used internally to describe the attributes of a particular section
 within a document template. At present this is mainly to determine whether the specified section is optional or 
 required.
 */
@interface ORKHL7CDASectionDescription : NSObject

@property (nonatomic) ORKHL7CDASectionType sectionType;
@property (nonatomic) bool isRequired;

/**
 Convenience initialiser for a Core Document Architecture Section Description object.
 
 @param sectionType    An ORKHL7CDASectionType enumeration, representing the type of section.
 @param isRequired     States whether this section is required in the document standard or not.
 
 */
- (nullable id)initWithSectionType:(ORKHL7CDASectionType)sectionType isRequired:(bool)isRequired;

@end


/**
 The `ORKHL7CDADocumentTemplate` class defines the properties for a given type of HL7 CDA document.
 A given template defines the LOINC and templateID code for that template, and a list of available sections for
 that type of document and whether they are optional or compulsory.
 */
@interface ORKHL7CDADocumentTemplate : NSObject

@property (nonatomic, nonnull, copy) NSString *loinc;
@property (nonatomic, nonnull, copy) NSString *templateID;
@property (nonatomic, nonnull, copy) NSString *title;
@property (nonatomic, nonnull, copy) NSArray <ORKHL7CDASectionDescription *> *sections;

@end


/**
 The `ORKHL7CDASectionTemplate` class defines the properties for a given type of section within an HL7 CDA document.
 A given template defines the LOINC and templateID code for that template.
 */
@interface ORKHL7CDASectionTemplate : NSObject

@property (nonatomic, nonnull, copy) NSString *loinc;
@property (nonatomic, nonnull, copy) NSString *templateID;
@property (nonatomic, nonnull, copy) NSString *title;
@property (nonatomic) ORKHL7CDAEntryTextType textType;

@end


@interface ORKHL7CDATextFragment : NSObject

@property (nonatomic) ORKHL7CDASectionType sectionType;
@property (nonatomic, copy, nonnull) NSString *xmlFragment;

@end


@protocol ORKStepHL7CDATextDelegate <NSObject>

/**
 When provided with the step and its corresponding result, this function should return an ORKHL7CDATextFragment, which is a fragment of the human-readable portion of an HL7 CDA document to be added to a section.
 
 
 @param step    The step we want the results for.
 @param result  The results corresponding to that step.
 
 */
-(nullable ORKHL7CDATextFragment *)hl7CDAtextForStep:(nonnull ORKStep *)step withResult:(nonnull ORKResult *)result;

@end


/**
 The ORKHL7CDA class contains all the functions for building an HL7CDA document from an ORKTaskResult.
 
 */
@interface ORKHL7CDA : NSObject

/**
 This function returns an HL7 Core Document Architecture (HL7 CDA) xml file as a string object from a TaskResult. Elements of input to this document are compulsory to ensure compliance with the HL7 CDA standard.
 
 @param taskResult        The ORKTaskResult for the completed task.
 @param documentType      The type of HL7 CDA document to be produced.
 @param patient           Patient identifiers for the document.
 @param effectiveFrom     The date/time this care episode or test commenced.
 @param effectiveTo       The date/time this care episode or test was completed.
 @param deviceAuthor      Contact details for the software author.
 @param assignedPerson    The person clinically responsible for this document (principle investigator or app author).
 
 */
+(nonnull NSString *)makeHL7CDA:(nonnull ORKTaskResult *)taskResult
                   withTemplate:(ORKHL7CDADocumentType)documentType
                     forPatient:(nonnull ORKHL7CDAPerson *)patient
                  effectiveFrom:(nonnull NSDate *)effectiveFrom
                    effectiveTo:(nonnull NSDate *)effectiveTo
                   deviceAuthor:(nonnull ORKHL7CDADeviceAuthor *)deviceAuthor
                      custodian:(nonnull ORKHL7CDACustodian *)custodian
                 assignedPerson:(nonnull ORKHL7CDAPerson *)assignedPerson;

@end
