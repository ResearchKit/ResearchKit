//
//  ORKHL7CDA.m
//  ResearchKit
//
//  Created by Andrew Hill on 21/08/2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKHL7CDA.h"
#import "ORKResult.h"

@implementation ORKHL7CDADocumentTemplate

@end

@implementation ORKHL7CDASectionTemplate

@end

@implementation ORKHL7CDATextFragment

@end

@implementation ORKHL7CDAPerson

@end

@implementation ORKHL7CDAAddress

@end

@implementation ORKHL7CDATelecom

@end

@implementation ORKHL7CDADeviceAuthor

@end

@implementation ORKHL7CDACustodian

@end

@implementation ORKHL7CDASectionDescription

- (id)initWithSectionType:(ORKHL7CDASectionType)sectionType isRequired:(bool)isRequired {
    if ((self = [super init])) {
        self.sectionType = sectionType;
        self.isRequired = isRequired;
    }
    
    return self;
}

@end

@implementation ORKHL7CDA

+(NSString *)iterateResultsArray:(ORKCollectionResult *)collectionResult forSectionType:(ORKHL7CDASectionType *)sectionType {
    NSArray<ORKResult*> *resultsArray = collectionResult.results;
    
    NSMutableString *outputString = [[NSMutableString alloc] init];
    
    for (ORKResult *result in resultsArray) {
        NSLog(result.identifier);
        if ([result isKindOfClass:[ORKCollectionResult class]]) {
            [outputString appendString:[self iterateResultsArray:result forSectionType:sectionType]];
        }
        if ([result isKindOfClass:[ORKHL7CDATextFragmentResult class]]) {
            ORKHL7CDATextFragmentResult *textFragment = (ORKHL7CDATextFragmentResult *) result;
            if ((textFragment.sectionType == sectionType) && (textFragment.xmlFragment != nil)) {
                [outputString appendString:textFragment.xmlFragment];
                [outputString appendString:@"\n"];
            }
        }
    }
    return outputString;
}

+(NSString *)makeHL7CDA:(ORKTaskResult *)taskResult withTemplate:(ORKHL7CDADocumentType)documentType
                                                      forPatient:(ORKHL7CDAPerson *)patient
                                                   effectiveFrom:(NSDate *)effectiveFrom
                                                     effectiveTo:(NSDate *)effectiveTo
                                                    deviceAuthor:(nonnull ORKHL7CDADeviceAuthor *)deviceAuthor
                                                       custodian:(ORKHL7CDACustodian *)custodian
                                                  assignedPerson:(ORKHL7CDAPerson *)assignedPerson {
    NSLog(@"HL7CDA Debug output\n\n");
    
    NSDictionary *documentTemplates = [self setupDocumentTemplatesDictionary];
    NSDictionary *sectionTemplates = [self setupSectionTemplatesDictionary];
    NSMutableString *hl7CDAOutput = [[NSMutableString alloc] init];
    
    ORKHL7CDADocumentTemplate *documentTemplate = [documentTemplates objectForKey:[NSNumber numberWithInteger:documentType]];
    
    [hl7CDAOutput appendString:[self cdaDocumentHeaderWithTemplate:documentTemplate forPatient:patient effectiveFrom:effectiveFrom effectiveTo:effectiveTo deviceAuthor:deviceAuthor custodian:custodian assignedPerson:assignedPerson]];
    
    for (ORKHL7CDASectionDescription *sectionDescription in documentTemplate.sections) {
        ORKHL7CDASectionTemplate *section = [sectionTemplates objectForKey:[NSNumber numberWithInteger:sectionDescription.sectionType]];
        
        NSString *sectionText = [self iterateResultsArray:taskResult forSectionType:sectionDescription.sectionType];

        if ((sectionText.length > 0) || (sectionDescription.isRequired)) {
            [hl7CDAOutput appendString:[self sectionTemplateHeader:section]];
        }
        if (sectionText.length > 0) {
            [hl7CDAOutput appendString:@"    <text>\n"];
            switch (section.textType) {
                case ORKHL7CDAEntryTextTypeInList:
                    [hl7CDAOutput appendString:@"      <list>\n"];
                    break;
                case ORKHL7CDAEntryTextTypeInTable:
                    [hl7CDAOutput appendString:@"      <table border=\"1\" width=\"100%\">\n"
                                                "         <tbody>\n"];
                    break;
                default:
                    break;
            }
            [hl7CDAOutput appendString:sectionText];
            switch (section.textType) {
                case ORKHL7CDAEntryTextTypeInList:
                    [hl7CDAOutput appendString:@"</list>\n    "];
                    break;
                case ORKHL7CDAEntryTextTypeInTable:
                    [hl7CDAOutput appendString:@"</tbody>\n"
                                                "         </table>\n    "];
                    break;
                default:
                    break;
            }
            [hl7CDAOutput appendString:@"</text>\n"];
        }
        if ((sectionText.length > 0) || (sectionDescription.isRequired)) {
            [hl7CDAOutput appendString:[self sectionTemplateFooter]];
        }
    }
    
    [hl7CDAOutput appendString:[self documentFooter]];
    
    NSLog(hl7CDAOutput);
    return hl7CDAOutput;
}

+(NSString *)cdaDocumentHeaderWithTemplate:(ORKHL7CDADocumentTemplate *)template
                                forPatient:(ORKHL7CDAPerson *)patient
                             effectiveFrom:(NSDate *)effectiveFrom
                               effectiveTo:(NSDate *)effectiveTo
                              deviceAuthor:(ORKHL7CDADeviceAuthor *)deviceAuthor
                                 custodian:(ORKHL7CDACustodian *)custodian
                            assignedPerson:(ORKHL7CDAPerson *)assignedPerson {

    NSDateFormatter *dateToSecondsFormatter = [[NSDateFormatter alloc] init];
    [dateToSecondsFormatter setDateFormat:@"yyyyMMddHHmmssZZZ"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *todayString = [dateToSecondsFormatter stringFromDate:[NSDate date]];
    
    UIDevice *uniqueDevice = [UIDevice currentDevice];
    NSString *uuid = uniqueDevice.identifierForVendor.UUIDString;
    
    NSString *effectiveFromString = [dateFormatter stringFromDate:effectiveFrom];
    NSString *effectiveToString = [dateFormatter stringFromDate:effectiveTo];
    
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:1024];
    
    [contentResult appendFormat: @"<?xml version=\"1.0\"?>\n"
     "<?xml-stylesheet type=\"text/xsl\" href=\"CDASchemas\cda\Schemas\CCD.xsl\"?>\n"
     "<ClinicalDocument xmlns=\"urn:hl7-org:v3\" xmlns:voc=\"urn:hl7-org:v3/voc\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:hl7-org:v3 CDA.xsd\">\n\n"

     "<!--\n"
     "********************************************************\n"
     "CDA Header\n"
     "********************************************************\n"
     "-->\n\n"

     "<typeId root=\"2.16.840.1.113883.1.3\" extension=\"POCD_HD000040\"/>\n"
     "<templateId root=\"%@\"/> <!-- CCD v1.0 Templates Root -->\n"
     "<id root=\"2.16.840.1.113883.5.3.1.100.2\" extension=\"%@-%@\" />\n"
     "<code code=\"%@\" codeSystem=\"2.16.840.1.113883.6.1\" displayName=\"%@\"/>\n"
     "<title>Good Health Clinic Continuity of Care Document</title>\n"
     "<effectiveTime value=\"%@\"/>\n"
     "<confidentialityCode code=\"N\" codeSystem=\"2.16.840.1.113883.5.25\"/>\n"
     "<languageCode code=\"en-US\"/>\n\n"

     "<recordTarget>\n"
     "  <patientRole>\n"
     "    <id extension=\"996-756-495\" root=\"2.16.840.1.113883.19.5\"/>\n"
     "    <patient>\n"
     "%@" // Patient
     "    </patient>\n"
     "  </patientRole>\n"
     "</recordTarget>\n\n"

     "<author>\n"
     "<time value=\"%@\"/>\n"
     "%@" // DeviceAuthor
     "</author>\n\n"
     
     "%@\n" // Custodian

     "<documentationOf>\n"
     "  <serviceEvent classCode=\"PCPR\">\n"
     "    <effectiveTime><low value=\"%@\"/><high value=\"%@\"/></effectiveTime>\n"
     "    <performer typeCode=\"PRF\">\n"
     "      <functionCode code=\"PCP\" codeSystem=\"2.16.840.1.113883.5.88\"/>\n"
     "      <assignedEntity>\n"
     "			<id root=\"20cf14fb-b65c-4c8c-a54d-b0cca834c18c\"/>"
	 "				<assignedPerson>\n"
     "%@" // AssignedPerson
	 "				</assignedPerson>\n"
     "      </assignedEntity>\n"
     "    </performer>\n"
     "  </serviceEvent>\n"
     "</documentationOf>\n"
     
     // PatientRole, Author
     "<!--\n"
     "********************************************************\n"
     "CDA Body\n"
     "********************************************************\n"
     "-->\n\n"
     
     "<component>\n"
     "  <structuredBody>\n",
     template.templateID, uuid, todayString, template.loinc, template.title, todayString, [self cdaHeaderPerson:patient], todayString,
     [self cdaHeaderDeviceAuthor:deviceAuthor], [self cdaHeaderCustodian:custodian],  effectiveFromString, effectiveToString,
     [self cdaHeaderPerson:assignedPerson]];
    
    return contentResult;
}

+(NSString *)documentFooter {
    NSString *contentResult = @"</structuredBody>\n"
    "</component>\n"
    "</ClinicalDocument>";
    
    return contentResult;
}

+(NSString *)cdaHeaderPerson:(ORKHL7CDAPerson *)person {
    NSString *birthdayString;
    if (person.birthdate != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        birthdayString = [dateFormatter stringFromDate:person.birthdate];
    }
    
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    [contentResult appendFormat:@"      <name>\n"];
    if (person.prefix.length > 0) {
        [contentResult appendFormat:@"        <prefix>%@</prefix>\n", person.prefix];
    }
    if (person.givenName.length > 0) {
        [contentResult appendFormat:@"        <given>%@</given>\n", person.givenName];
    }
    if (person.familyName.length > 0) {
        [contentResult appendFormat:@"        <family>%@</family>\n", person.familyName];
    }
    if (person.suffix.length > 0) {
        [contentResult appendFormat:@"        <suffix>%@</suffix>\n", person.suffix];
    }
    [contentResult appendFormat:@"      </name>\n"];
    [contentResult appendFormat:[self cdaHeaderAdministrativeGender:person.gender]];
    if (person.birthdate != nil) {
        [contentResult appendFormat:@"      <birthTime value=\"%@\"/>\n", birthdayString];
    }
    if (person.address != nil) {
        [contentResult appendString:[self cdaHeaderAddress:person.address]];
    }
    if (person.telecoms != nil) {
        [contentResult appendString:[self cdaHeaderTelecoms:person.telecoms]];
    }
    return contentResult;
}


+(NSString *)cdaHeaderDeviceAuthor:(ORKHL7CDADeviceAuthor *)deviceAuthor {
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    [contentResult appendFormat:@"      <assignedAuthor>\n"];
    [contentResult appendFormat:@"        <id extension=\"KP00017dev\" root=\"2.16.840.1.113883.19.5\"/>\n"];
    if (deviceAuthor.address != nil) {
        [contentResult appendString:[self cdaHeaderAddress:deviceAuthor.address]];
    }
    if (deviceAuthor.telecoms != nil) {
        [contentResult appendString:[self cdaHeaderTelecoms:deviceAuthor.telecoms]];
    }
    [contentResult appendFormat:@"        <assignedAuthoringDevice>\n"];
    [contentResult appendFormat:@"          <manufacturerModelName>Apple iOS</manufacturerModelName >\n"];
    [contentResult appendFormat:@"          <softwareName>%@</softwareName >\n", deviceAuthor.softwareName];
    [contentResult appendFormat:@"        </assignedAuthoringDevice >\n"];
    [contentResult appendFormat:@"      </assignedAuthor>\n"];
    return contentResult;
}


+(NSString *)cdaHeaderCustodian:(ORKHL7CDACustodian *)custodian {
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    [contentResult appendFormat:@"      <custodian>\n"];
    [contentResult appendFormat:@"      <assignedCustodian>\n"];
    [contentResult appendFormat:@"      <representedCustodianOrganization>\n"];
    [contentResult appendFormat:@"        <id root=\"2.16.840.1.113883.19.5\"/>\n"];
    [contentResult appendFormat:@"        <name>%@</name >\n", custodian.name];
    if (custodian.telecom != nil) {
        [contentResult appendString:[self cdaHeaderTelecom:custodian.telecom]];
    }
    if (custodian.address != nil) {
        [contentResult appendString:[self cdaHeaderAddress:custodian.address]];
    }
    [contentResult appendFormat:@"      </representedCustodianOrganization>\n"];
    [contentResult appendFormat:@"      </assignedCustodian>\n"];
    [contentResult appendFormat:@"      </custodian>\n"];
    return contentResult;
}


+(NSString *)cdaHeaderAddress:(ORKHL7CDAAddress *)address {
    
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    [contentResult appendFormat:@"      <addr>\n"];
    if (address.street.length > 0) {
        [contentResult appendFormat:@"        <streetAddressLine>%@</streetAddressLine>\n", address.street];
    }
    if (address.city.length > 0) {
        [contentResult appendFormat:@"        <city>%@</city>\n", address.city];
    }
    if (address.state.length > 0) {
        [contentResult appendFormat:@"        <state>%@</state>\n", address.state];
    }
    if (address.postalCode.length > 0) {
        [contentResult appendFormat:@"        <postalCode>%@</postalCode>\n", address.postalCode];
    }
    if (address.country.length > 0) {
        [contentResult appendFormat:@"        <country>%@</country>\n", address.country];
    }
    [contentResult appendFormat:@"      </addr>\n"];
    return contentResult;
}

+(NSString *)cdaHeaderTelecom:(ORKHL7CDATelecom *)telecom {
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    NSString *telecomUse;
    switch (telecom.telecomUseType) {
        case ORKHL7CDATelecomUseTypePrimaryHome:
            telecomUse = @"use=\"HP\"";
            break;
        case ORKHL7CDATelecomUseTypeWorkPlace:
            telecomUse = @"use=\"WP\"";
            break;
        case ORKHL7CDATelecomUseTypeVacationHome:
            telecomUse = @"use=\"MC\"";
            break;
        case ORKHL7CDATelecomUseTypeMobileContact:
            telecomUse = @"use=\"HV\"";
            break;
        default:
            // The list is exhaustive and we should not fall through; in the event the list is extended
            // We fall through by just omitting the attribute entirely
            telecomUse = @"";
            break;
    }
    [contentResult appendFormat:@"      <telecom value=\"%@\" %@ />\n", telecom.value, telecomUse];
    return contentResult;
}

+(NSString *)cdaHeaderTelecoms:(NSArray <ORKHL7CDATelecom *> *)telecoms {
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    for (ORKHL7CDATelecom *telecom in telecoms) {
        [contentResult appendString:[self cdaHeaderTelecom:telecom]];
    }
    return contentResult;
}

+(NSString *)cdaHeaderAdministrativeGender:(ORKHL7CDAAdministrativeGenderType)gender {
    NSString *contentResult;
    switch (gender) {
        case ORKHL7CDAAdministrativeGenderTypeMale:
            contentResult = @"      <administrativeGenderCode code=\"M\" codeSystem=\"2.16.840.1.113883.5.1\"/>\n";
            break;
        case ORKHL7CDAAdministrativeGenderTypeFemale:
            contentResult = @"      <administrativeGenderCode code=\"F\" codeSystem=\"2.16.840.1.113883.5.1\"/>\n";
            break;
        case ORKHL7CDAAdministrativeGenderTypeUndifferentiated:
            contentResult = @"      <administrativeGenderCode code=\"UN\" codeSystem=\"2.16.840.1.113883.5.1\"/>\n";
            break;
        default:
            // If the gender type is 'not specified' which is the default
            // We fall through by just omitting the attribute entirely
            contentResult = @"";
            break;
    }
    return contentResult;
}

+(NSString *)sectionTemplateHeader:(ORKHL7CDASectionTemplate *)content {
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    [contentResult appendFormat: @"<!-- %@ section template -->\n"
     "    <component>\n"
     "      <section>\n"
     "        <templateId root='%@'/>\n"
     "        <code code=\"%@\" codeSystem=\"2.16.840.1.113883.6.1\"/>\n"
     "        <title>%@</title>\n",
     content.title,
     content.templateID,
     content.loinc,
     content.title
     ];
    return contentResult;
}

+(NSString *)sectionTemplateFooter {
    return @"      </section>\n"
    "    </component>\n\n";
}

+(NSDictionary *)setupDocumentTemplatesDictionary {
    ORKHL7CDADocumentTemplate *ccd = [[ORKHL7CDADocumentTemplate alloc] init];
    ccd.templateID = @"2.16.840.1.113883.10.20.22.1.2";
    ccd.loinc = @"34133-9";
    ccd.title = @"Summarization of episode note";
    
    ORKHL7CDADocumentTemplate *consultationNote = [[ORKHL7CDADocumentTemplate alloc] init];
    consultationNote.templateID = @"2.16.840.1.113883.10.20.22.1.4";
    consultationNote.loinc = @"11488-4";
    consultationNote.title = @"Consultation note";
    
    ORKHL7CDADocumentTemplate *diagnosticImagingReport = [[ORKHL7CDADocumentTemplate alloc] init];
    ccd.templateID = @"2.16.840.1.113883.10.20.22.1.5";
    ccd.loinc = @"18748-4";
    ccd.title = @"Diagnostic Imaging Report";
    
    ORKHL7CDASectionDescription *purpose = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypePurpose isRequired: true];
    ORKHL7CDASectionDescription *allergies = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeAllergiesCoded isRequired: true];
    ORKHL7CDASectionDescription *medications = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeMedications isRequired: true];
    ORKHL7CDASectionDescription *problems = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeProblems isRequired: true];
    ORKHL7CDASectionDescription *procedures = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeProcedures isRequired: true];
    ORKHL7CDASectionDescription *results = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeResults isRequired: true];
    ORKHL7CDASectionDescription *advanceDirectives = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeAdvanceDirectives isRequired: false];
    ORKHL7CDASectionDescription *encounters = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeEncounters isRequired: false];
    ORKHL7CDASectionDescription *familyHistory = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeFamilyHistory isRequired: false];
    ORKHL7CDASectionDescription *functionalStatus = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeFunctionalStatus isRequired: false];
    ORKHL7CDASectionDescription *immunizations = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeImmunizations isRequired: false];
    ORKHL7CDASectionDescription *medicalEquipment = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeMedicalEquipment isRequired: false];
    ORKHL7CDASectionDescription *payers = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypePayers isRequired: false];
    ORKHL7CDASectionDescription *planOfCare = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypePlanOfCare isRequired: false];
    ORKHL7CDASectionDescription *socialHistory = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeSocialHistory isRequired: false];
    ORKHL7CDASectionDescription *vitalSigns = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeVitalSigns isRequired: false];
    ORKHL7CDASectionDescription *assessment = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeAssessment isRequired: true];
    ORKHL7CDASectionDescription *historyOfPresentIllness = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeHistoryOfPresentIllness isRequired: true];
    ORKHL7CDASectionDescription *physicalExam = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypePhysicalExam isRequired: true];
    ORKHL7CDASectionDescription *reasonForReferral = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeReasonForReferral isRequired: true];
    ORKHL7CDASectionDescription *chiefComplaint = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeChiefComplaint isRequired: false];
    ORKHL7CDASectionDescription *generalStatus = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeGeneralStatus isRequired: false];
    ORKHL7CDASectionDescription *pastMedicalHistory = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypePastMedicalHistory isRequired: false];
    ORKHL7CDASectionDescription *problemsOptional = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeProblemsOptional isRequired: false];
    ORKHL7CDASectionDescription *reviewOfSystems = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeReviewOfSystems isRequired: false];
    ORKHL7CDASectionDescription *dicomObjectCatalog = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeDICOMObjectCatalog isRequired: true];
    ORKHL7CDASectionDescription *diagnosticImagingFindings = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeDiagnosticImagingFindings isRequired: true];
    ORKHL7CDASectionDescription *addendum = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeDiagnosticImagingAddendum isRequired:false];
    ORKHL7CDASectionDescription *complications = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeComplications isRequired:false];
    ORKHL7CDASectionDescription *conclusions = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeConclusions isRequired:false];
    ORKHL7CDASectionDescription *currentImagingProcedureDescriptions = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeCurrentImagingProcedureDescriptions isRequired:false];
    ORKHL7CDASectionDescription *diagnosticImagingDocumentSummary = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeDiagnosticImagingDocumentSummary isRequired:false];
    ORKHL7CDASectionDescription *diagnosticImagingKeyImages = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeDiagnosticImagingKeyImages isRequired:false];
    ORKHL7CDASectionDescription *medicalGeneralHistory = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeMedicalGeneralHistory isRequired:false];
    ORKHL7CDASectionDescription *priorImagingProcedureDescription = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypePriorImagingProcedureDescriptions isRequired:false];
    ORKHL7CDASectionDescription *radiologyImpression = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeRadiologyImpression isRequired:false];
    ORKHL7CDASectionDescription *radiologyComparisonStudyObservation = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeRadiologyComparisonStudyObservation isRequired:false];
    ORKHL7CDASectionDescription *radiologyReasonForStudy = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeRadiologyReasonForStudy isRequired:false];
    ORKHL7CDASectionDescription *radiologyStudyRecommendations = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeRadiologyStudyRecommendations isRequired:false];
    ORKHL7CDASectionDescription *requestedImageStudiesInformation = [[ORKHL7CDASectionDescription alloc] initWithSectionType:ORKHL7CDASectionTypeRequestedImageStudiesInformation isRequired:false];
    
    ccd.sections = [NSArray arrayWithObjects: purpose, allergies, problems, procedures, familyHistory, socialHistory, payers,
                    advanceDirectives, immunizations, medications, medicalEquipment, vitalSigns, functionalStatus, results,
                    encounters, planOfCare, nil];
    consultationNote.sections = [NSArray arrayWithObjects: assessment, planOfCare, historyOfPresentIllness, physicalExam, reasonForReferral, chiefComplaint, familyHistory, generalStatus, pastMedicalHistory, immunizations, medications, problemsOptional, procedures, results, reviewOfSystems, socialHistory, vitalSigns, nil];
    
    diagnosticImagingReport.sections = [NSArray arrayWithObjects: dicomObjectCatalog, diagnosticImagingFindings, addendum, complications, conclusions, currentImagingProcedureDescriptions, diagnosticImagingDocumentSummary, diagnosticImagingKeyImages, medicalGeneralHistory, priorImagingProcedureDescription, radiologyImpression, radiologyComparisonStudyObservation, radiologyReasonForStudy, radiologyStudyRecommendations, requestedImageStudiesInformation, nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            ccd, [NSNumber numberWithInteger:ORKHL7CDADocumentTypeCCD],
            consultationNote, [NSNumber numberWithInteger:ORKHL7CDADocumentTypeConsultationNote],
            dicomObjectCatalog, [NSNumber numberWithInteger:ORKHL7CDASectionTypeDICOMObjectCatalog],
            nil];
}

+(NSDictionary *)setupSectionTemplatesDictionary {
    ORKHL7CDASectionTemplate *allergiesCoded = [[ORKHL7CDASectionTemplate alloc] init];
    allergiesCoded.templateID = @"2.16.840.1.113883.10.20.22.2.6.1";
    allergiesCoded.loinc = @"48765-2";
    allergiesCoded.textType = ORKHL7CDAEntryTextTypeInList;
    allergiesCoded.title = @"Allergies";
    
    ORKHL7CDASectionTemplate *purpose = [[ORKHL7CDASectionTemplate alloc] init];
    purpose.templateID = @"2.16.840.1.113883.10.20.1.13";
    purpose.loinc = @"48764-5";
    purpose.textType = ORKHL7CDAEntryTextTypePlain;
    purpose.title = @"Summary Purpose";
    
    ORKHL7CDASectionTemplate *payers = [[ORKHL7CDASectionTemplate alloc] init];
    payers.templateID = @"2.16.840.1.113883.10.20.1.9";
    payers.loinc = @"48768-6";
    payers.textType = ORKHL7CDAEntryTextTypePlain;
    payers.title = @"Payers";
    
    ORKHL7CDASectionTemplate *advanceDirectives = [[ORKHL7CDASectionTemplate alloc] init];
    advanceDirectives.templateID = @"2.16.840.1.113883.10.20.1.1";
    advanceDirectives.loinc = @"42348-3";
    advanceDirectives.textType = ORKHL7CDAEntryTextTypeInList;
    advanceDirectives.title = @"Advance Directives";
    
    ORKHL7CDASectionTemplate *functionalStatus = [[ORKHL7CDASectionTemplate alloc] init];
    functionalStatus.templateID = @"2.16.840.1.113883.10.20.1.5";
    functionalStatus.loinc = @"47420-5";
    functionalStatus.textType = ORKHL7CDAEntryTextTypeInList;
    functionalStatus.title = @"Functional Status";
    
    ORKHL7CDASectionTemplate *problemsCoded = [[ORKHL7CDASectionTemplate alloc] init];
    problemsCoded.templateID = @"2.16.840.1.113883.10.20.22.2.5.1";
    problemsCoded.loinc = @"11450-4";
    problemsCoded.textType = ORKHL7CDAEntryTextTypeInList;
    problemsCoded.title = @"Problems";
    
    ORKHL7CDASectionTemplate *familyHistory = [[ORKHL7CDASectionTemplate alloc] init];
    familyHistory.templateID = @"2.16.840.1.113883.10.20.1.4";
    familyHistory.loinc = @"10157-6";
    familyHistory.textType = ORKHL7CDAEntryTextTypeInList;
    familyHistory.title = @"Family History";
    
    ORKHL7CDASectionTemplate *socialHistory = [[ORKHL7CDASectionTemplate alloc] init];
    socialHistory.templateID = @"2.16.840.1.113883.10.20.1.15";
    socialHistory.loinc = @"29762-2";
    socialHistory.textType = ORKHL7CDAEntryTextTypeInList;
    socialHistory.title = @"Social History";
    
    ORKHL7CDASectionTemplate *alerts = [[ORKHL7CDASectionTemplate alloc] init];
    alerts.templateID = @"2.16.840.1.113883.10.20.1.2";
    alerts.loinc = @"48765-2";
    alerts.textType = ORKHL7CDAEntryTextTypeInList;
    alerts.title = @"Alerts";
    
    ORKHL7CDASectionTemplate *medications = [[ORKHL7CDASectionTemplate alloc] init];
    medications.templateID = @"2.16.840.1.113883.10.20.1.8";
    medications.loinc = @"10160-0";
    medications.textType = ORKHL7CDAEntryTextTypeInTable;
    medications.title = @"Medications";
    
    ORKHL7CDASectionTemplate *medicalEquipment = [[ORKHL7CDASectionTemplate alloc] init];
    medicalEquipment.templateID = @"2.16.840.1.113883.10.20.1.7";
    medicalEquipment.loinc = @"46264-8";
    medicalEquipment.textType = ORKHL7CDAEntryTextTypeInList;
    medicalEquipment.title = @"Medical Equipment";
    
    ORKHL7CDASectionTemplate *immunizations = [[ORKHL7CDASectionTemplate alloc] init];
    immunizations.templateID = @"2.16.840.1.113883.10.20.1.6";
    immunizations.loinc = @"11369-6";
    immunizations.textType = ORKHL7CDAEntryTextTypeInTable;
    immunizations.title = @"Immunizations";
    
    ORKHL7CDASectionTemplate *vitalSigns = [[ORKHL7CDASectionTemplate alloc] init];
    vitalSigns.templateID = @"2.16.840.1.113883.10.20.1.16";
    vitalSigns.loinc = @"8716-3";
    vitalSigns.textType = ORKHL7CDAEntryTextTypeInTable;
    vitalSigns.title = @"Vital Signs";
    
    ORKHL7CDASectionTemplate *results = [[ORKHL7CDASectionTemplate alloc] init];
    results.templateID = @"2.16.840.1.113883.10.20.1.14";
    results.loinc = @"30954-2";
    results.textType = ORKHL7CDAEntryTextTypeInTable;
    results.title = @"Results";
    
    ORKHL7CDASectionTemplate *procedures = [[ORKHL7CDASectionTemplate alloc] init];
    procedures.templateID = @"2.16.840.1.113883.10.20.1.12";
    procedures.loinc = @"47519-4";
    procedures.textType = ORKHL7CDAEntryTextTypeInList;
    procedures.title = @"Procedures";
    
    ORKHL7CDASectionTemplate *encounters = [[ORKHL7CDASectionTemplate alloc] init];
    encounters.templateID = @"2.16.840.1.113883.10.20.1.3";
    encounters.loinc = @"46240-8";
    encounters.textType = ORKHL7CDAEntryTextTypeInList;
    encounters.title = @"Encounters";
    
    ORKHL7CDASectionTemplate *planOfCare = [[ORKHL7CDASectionTemplate alloc] init];
    planOfCare.templateID = @"2.16.840.1.113883.10.20.1.10";
    planOfCare.loinc = @"18776-5";
    planOfCare.textType = ORKHL7CDAEntryTextTypeInList;
    planOfCare.title = @"Plan Of Care";
    
    ORKHL7CDASectionTemplate *assessment = [[ORKHL7CDASectionTemplate alloc] init];
    assessment.templateID = @"2.16.840.1.113883.10.20.22.2.8";
    assessment.loinc = @"51848-0";
    assessment.textType = ORKHL7CDAEntryTextTypeInList;
    assessment.title = @"Assessment";
    
    ORKHL7CDASectionTemplate *historyOfPresentIllness = [[ORKHL7CDASectionTemplate alloc] init];
    historyOfPresentIllness.templateID = @"1.3.6.1.4.1.19376.1.5.3.1.3.4";
    historyOfPresentIllness.loinc = @"10164-2";
    historyOfPresentIllness.textType = ORKHL7CDAEntryTextTypeInList;
    historyOfPresentIllness.title = @"History Of Present Illness";

    ORKHL7CDASectionTemplate *physicalExam = [[ORKHL7CDASectionTemplate alloc] init];
    physicalExam.templateID = @"2.16.840.1.113883.10.20.2.10";
    physicalExam.loinc = @"29545-1";
    physicalExam.textType = ORKHL7CDAEntryTextTypeInList;
    physicalExam.title = @"Physical Examination";
    
    ORKHL7CDASectionTemplate *reasonForReferral = [[ORKHL7CDASectionTemplate alloc] init];
    reasonForReferral.templateID = @"1.3.6.1.4.1.19376.1.5.3.1.3.1";
    reasonForReferral.loinc = @"42349-1";
    reasonForReferral.textType = ORKHL7CDAEntryTextTypePlain;
    reasonForReferral.title = @"Reason For Referral";
    
    ORKHL7CDASectionTemplate *chiefComplaint = [[ORKHL7CDASectionTemplate alloc] init];
    chiefComplaint.templateID = @"1.3.6.1.4.1.19376.1.5.3.1.1.13.2.1";
    chiefComplaint.loinc = @"10154-3";
    chiefComplaint.textType = ORKHL7CDAEntryTextTypePlain;
    chiefComplaint.title = @"Chief Complaint";
    
    ORKHL7CDASectionTemplate *generalStatus = [[ORKHL7CDASectionTemplate alloc] init];
    generalStatus.templateID = @"2.16.840.1.113883.10.20.2.5";
    generalStatus.loinc = @"10210-3";
    generalStatus.textType = ORKHL7CDAEntryTextTypeInList;
    generalStatus.title = @"General Status";
    
    ORKHL7CDASectionTemplate *pastMedicalHistory = [[ORKHL7CDASectionTemplate alloc] init];
    pastMedicalHistory.templateID = @"2.16.840.1.113883.10.20.22.2.20";
    pastMedicalHistory.loinc = @"11348-0";
    pastMedicalHistory.textType = ORKHL7CDAEntryTextTypeInList;
    pastMedicalHistory.title = @"Past Medical History";
    
    ORKHL7CDASectionTemplate *problemsOptional = [[ORKHL7CDASectionTemplate alloc] init];
    problemsOptional.templateID = @"2.16.840.1.113883.10.20.22.2.5";
    problemsOptional.loinc = @"11450-4";
    problemsOptional.textType = ORKHL7CDAEntryTextTypeInList;
    problemsOptional.title = @"Problems";
    
    ORKHL7CDASectionTemplate *reviewOfSystems = [[ORKHL7CDASectionTemplate alloc] init];
    reviewOfSystems.templateID = @"1.3.6.1.4.1.19376.1.5.3.1.3.18";
    reviewOfSystems.loinc = @"10187-3";
    reviewOfSystems.textType = ORKHL7CDAEntryTextTypeInList;
    reviewOfSystems.title = @"Review Of Systems";
    
    ORKHL7CDASectionTemplate *dicomObjectCatalog = [[ORKHL7CDASectionTemplate alloc] init];
    dicomObjectCatalog.templateID = @"2.16.840.1.113883.10.20.6.1.1";
    dicomObjectCatalog.loinc = @"121181";
    dicomObjectCatalog.textType = ORKHL7CDAEntryTextTypeNone;
    dicomObjectCatalog.title = @"DICOM Object Catalog";
    
    ORKHL7CDASectionTemplate *diagnosticImagingFindings = [[ORKHL7CDASectionTemplate alloc] init];
    diagnosticImagingFindings.templateID = @"2.16.840.1.113883.10.20.6.1.2";
    diagnosticImagingFindings.loinc = @"18782-3";
    diagnosticImagingFindings.textType = ORKHL7CDAEntryTextTypePlain;
    diagnosticImagingFindings.title = @"DICOM Object Catalog";

    ORKHL7CDASectionTemplate *addendum = [[ORKHL7CDASectionTemplate alloc] init];
    addendum.templateID = @"";
    addendum.loinc = @"55107-7";
    addendum.textType = ORKHL7CDAEntryTextTypePlain;
    addendum.title = @"Addendum";
    
    ORKHL7CDASectionTemplate *complications = [[ORKHL7CDASectionTemplate alloc] init];
    complications.templateID = @"2.16.840.1.113883.10.20.22.2.37";
    complications.loinc = @"55109-3";
    complications.textType = ORKHL7CDAEntryTextTypePlain;
    complications.title = @"Complications";

    ORKHL7CDASectionTemplate *conclusions = [[ORKHL7CDASectionTemplate alloc] init];
    conclusions.templateID = @"";
    conclusions.loinc = @"55110-1";
    conclusions.textType = ORKHL7CDAEntryTextTypePlain;
    conclusions.title = @"Conclusions";
    
    ORKHL7CDASectionTemplate *currentImagingProcedureDescriptions = [[ORKHL7CDASectionTemplate alloc] init];
    currentImagingProcedureDescriptions.templateID = @"";
    currentImagingProcedureDescriptions.loinc = @"55111-9";
    currentImagingProcedureDescriptions.textType = ORKHL7CDAEntryTextTypePlain;
    currentImagingProcedureDescriptions.title = @"Current Imaging Procedure Descriptions";
    
    ORKHL7CDASectionTemplate *diagnosticImagingDocumentSummary = [[ORKHL7CDASectionTemplate alloc] init];
    diagnosticImagingDocumentSummary.templateID = @"";
    diagnosticImagingDocumentSummary.loinc = @"55112-7";
    diagnosticImagingDocumentSummary.textType = ORKHL7CDAEntryTextTypePlain;
    diagnosticImagingDocumentSummary.title = @"Document Summary";
    
    ORKHL7CDASectionTemplate *diagnosticImagingKeyImages = [[ORKHL7CDASectionTemplate alloc] init];
    diagnosticImagingKeyImages.templateID = @"";
    diagnosticImagingKeyImages.loinc = @"53113-5";
    diagnosticImagingKeyImages.textType = ORKHL7CDAEntryTextTypePlain;
    diagnosticImagingKeyImages.title = @"Key Images";
    
    ORKHL7CDASectionTemplate *medicalGeneralHistory = [[ORKHL7CDASectionTemplate alloc] init];
    medicalGeneralHistory.templateID = @"2.16.840.1.113883.10.20.22.2.39";
    medicalGeneralHistory.loinc = @"11329-0";
    medicalGeneralHistory.textType = ORKHL7CDAEntryTextTypePlain;
    medicalGeneralHistory.title = @"Medical (General) History";
    
    ORKHL7CDASectionTemplate *priorImagingProcedureDescription = [[ORKHL7CDASectionTemplate alloc] init];
    priorImagingProcedureDescription.templateID = @"";
    priorImagingProcedureDescription.loinc = @"55114-3";
    priorImagingProcedureDescription.textType = ORKHL7CDAEntryTextTypePlain;
    priorImagingProcedureDescription.title = @"Prior Imaging Procedure Descriptions";
    
    ORKHL7CDASectionTemplate *radiologyImpression = [[ORKHL7CDASectionTemplate alloc] init];
    radiologyImpression.templateID = @"";
    radiologyImpression.loinc = @"19005-8";
    radiologyImpression.textType = ORKHL7CDAEntryTextTypePlain;
    radiologyImpression.title = @"Radiology - Impression";

    ORKHL7CDASectionTemplate *radiologyComparisonStudyObservation = [[ORKHL7CDASectionTemplate alloc] init];
    radiologyComparisonStudyObservation.templateID = @"";
    radiologyComparisonStudyObservation.loinc = @"19005-8";
    radiologyComparisonStudyObservation.textType = ORKHL7CDAEntryTextTypePlain;
    radiologyComparisonStudyObservation.title = @"Radiology Comparison Study - Observation";
    
    ORKHL7CDASectionTemplate *radiologyReasonForStudy = [[ORKHL7CDASectionTemplate alloc] init];
    radiologyReasonForStudy.templateID = @"";
    radiologyReasonForStudy.loinc = @"18785-6";
    radiologyReasonForStudy.textType = ORKHL7CDAEntryTextTypePlain;
    radiologyReasonForStudy.title = @"Radiology Reason For Study";
    
    ORKHL7CDASectionTemplate *radiologyStudyRecommendations = [[ORKHL7CDASectionTemplate alloc] init];
    radiologyStudyRecommendations.templateID = @"";
    radiologyStudyRecommendations.loinc = @"18783-1";
    radiologyStudyRecommendations.textType = ORKHL7CDAEntryTextTypePlain;
    radiologyStudyRecommendations.title = @"Radiology Study - Recommendations";
    
    ORKHL7CDASectionTemplate *requestedImageStudiesInformation = [[ORKHL7CDASectionTemplate alloc] init];
    requestedImageStudiesInformation.templateID = @"";
    requestedImageStudiesInformation.loinc = @"55115-0";
    requestedImageStudiesInformation.textType = ORKHL7CDAEntryTextTypePlain;
    requestedImageStudiesInformation.title = @"Requested Imaging Studies Information";
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            purpose, [NSNumber numberWithInteger:ORKHL7CDASectionTypePurpose],
            allergiesCoded, [NSNumber numberWithInteger:ORKHL7CDASectionTypeAllergiesCoded],
            payers, [NSNumber numberWithInteger:ORKHL7CDASectionTypePayers],
            advanceDirectives, [NSNumber numberWithInteger:ORKHL7CDASectionTypeAdvanceDirectives],
            functionalStatus, [NSNumber numberWithInteger:ORKHL7CDASectionTypeFunctionalStatus],
            problemsCoded, [NSNumber numberWithInteger:ORKHL7CDASectionTypeProblems],
            familyHistory, [NSNumber numberWithInteger:ORKHL7CDASectionTypeFamilyHistory],
            socialHistory, [NSNumber numberWithInteger:ORKHL7CDASectionTypeSocialHistory],
            alerts, [NSNumber numberWithInteger:ORKHL7CDASectionTypeAlerts],
            medications, [NSNumber numberWithInteger:ORKHL7CDASectionTypeMedications],
            medicalEquipment, [NSNumber numberWithInteger:ORKHL7CDASectionTypeMedicalEquipment],
            immunizations, [NSNumber numberWithInteger:ORKHL7CDASectionTypeImmunizations],
            vitalSigns, [NSNumber numberWithInteger:ORKHL7CDASectionTypeVitalSigns],
            results, [NSNumber numberWithInteger:ORKHL7CDASectionTypeResults],
            procedures, [NSNumber numberWithInteger:ORKHL7CDASectionTypeProcedures],
            encounters, [NSNumber numberWithInteger:ORKHL7CDASectionTypeEncounters],
            planOfCare, [NSNumber numberWithInteger:ORKHL7CDASectionTypePlanOfCare],
            assessment, [NSNumber numberWithInteger:ORKHL7CDASectionTypeAssessment],
            historyOfPresentIllness, [NSNumber numberWithInteger:ORKHL7CDASectionTypeHistoryOfPresentIllness],
            physicalExam, [NSNumber numberWithInteger:ORKHL7CDASectionTypePhysicalExam],
            reasonForReferral, [NSNumber numberWithInteger:ORKHL7CDASectionTypeReasonForReferral],
            chiefComplaint, [NSNumber numberWithInteger:ORKHL7CDASectionTypeChiefComplaint],
            generalStatus, [NSNumber numberWithInteger:ORKHL7CDASectionTypeGeneralStatus],
            pastMedicalHistory, [NSNumber numberWithInteger:ORKHL7CDASectionTypePastMedicalHistory],
            problemsOptional, [NSNumber numberWithInteger:ORKHL7CDASectionTypeProblemsOptional],
            reviewOfSystems, [NSNumber numberWithInteger:ORKHL7CDASectionTypeReviewOfSystems],
            dicomObjectCatalog, [NSNumber numberWithInteger:ORKHL7CDASectionTypeDICOMObjectCatalog],
            diagnosticImagingFindings, [NSNumber numberWithInteger:ORKHL7CDASectionTypeDiagnosticImagingFindings],
            addendum, [NSNumber numberWithInteger:ORKHL7CDASectionTypeDiagnosticImagingAddendum],
            complications, [NSNumber numberWithInteger:ORKHL7CDASectionTypeComplications],
            conclusions, [NSNumber numberWithInteger:ORKHL7CDASectionTypeConclusions],
            currentImagingProcedureDescriptions, [NSNumber numberWithInteger:ORKHL7CDASectionTypeCurrentImagingProcedureDescriptions],
            diagnosticImagingDocumentSummary, [NSNumber numberWithInteger:ORKHL7CDASectionTypeDiagnosticImagingDocumentSummary],
            diagnosticImagingKeyImages, [NSNumber numberWithInteger:ORKHL7CDASectionTypeDiagnosticImagingKeyImages],
            medicalGeneralHistory, [NSNumber numberWithInteger:ORKHL7CDASectionTypeMedicalGeneralHistory],
            priorImagingProcedureDescription, [NSNumber numberWithInteger:ORKHL7CDASectionTypePriorImagingProcedureDescriptions],
            radiologyImpression, [NSNumber numberWithInteger:ORKHL7CDASectionTypeRadiologyImpression],
            radiologyComparisonStudyObservation, [NSNumber numberWithInteger:ORKHL7CDASectionTypeRadiologyComparisonStudyObservation],
            radiologyReasonForStudy, [NSNumber numberWithInteger:ORKHL7CDASectionTypeRadiologyReasonForStudy],
            radiologyStudyRecommendations, [NSNumber numberWithInteger:ORKHL7CDASectionTypeRadiologyStudyRecommendations],
            requestedImageStudiesInformation, [NSNumber numberWithInteger:ORKHL7CDASectionTypeRequestedImageStudiesInformation],
            nil];
}

@end
