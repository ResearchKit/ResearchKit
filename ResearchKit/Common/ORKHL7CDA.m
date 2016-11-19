//
//  ORKHL7CDA.m
//  ResearchKit
//
//  Created by Andrew Hill on 21/08/2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKHL7CDA.h"
#import "ORKResult.h"

@implementation ORKHL7CDASectionContent

@end

@implementation ORKHL7CDATextFragment

@end

@implementation ORKHL7CDAPerson

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

+(NSString *)makeHL7CDA:(ORKTaskResult *)taskResult forPatient:(ORKHL7CDAPerson *)patient
                                                 effectiveFrom:(NSDate *)effectiveFrom
                                                   effectiveTo:(NSDate *)effectiveTo
                                                assignedPerson:(ORKHL7CDAPerson *)assignedPerson {
    NSLog(@"HL7CCD Debug output\n\n");
    
    NSArray *frameworks = [self setupFrameworks];
    NSMutableString *hl7CCDOutput = [[NSMutableString alloc] init];
    
    [hl7CCDOutput appendString:[self cdaHeader:patient effectiveFrom:effectiveFrom effectiveTo:effectiveTo
                                assignedPerson:assignedPerson]];
    
    for (ORKHL7CDASectionContent *section in frameworks) {
        [hl7CCDOutput appendString:[self sectionTemplateHeader:section]];
        
        NSString *sectionText = [self iterateResultsArray:taskResult forSectionType:section.sectionType];
        if (sectionText.length > 0) {
            [hl7CCDOutput appendString:@"    <text>"];
            [hl7CCDOutput appendString:sectionText];
            [hl7CCDOutput appendString:@"</text>\n"];
        }
        [hl7CCDOutput appendString:[self sectionTemplateFooter]];
    }
    
    [hl7CCDOutput appendString:[self documentFooter]];
    
    NSLog(hl7CCDOutput);
    return hl7CCDOutput;
}

+(NSString *)cdaHeader:(ORKHL7CDAPerson *)patient
         effectiveFrom:(NSDate *)effectiveFrom
           effectiveTo:(NSDate *)effectiveTo
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
     "<templateId root=\"2.16.840.1.113883.10.20.1\"/> <!-- CCD v1.0 Templates Root -->\n"
     "<id root=\"2.16.840.1.113883.5.3.1.100.2\" extension=\"%@-%@\" />\n"
     "<code code=\"34133-9\" codeSystem=\"2.16.840.1.113883.6.1\" displayName=\"Summarization of episode note\"/>\n"
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

     "<documentationOf>\n"
     "  <serviceEvent classCode=\"PCPR\">\n"
     "    <effectiveTime><low value=\"%@\"/><high value=\"%@\"/></effectiveTime>\n"
     "    <performer typeCode=\"PRF\">\n"
     "      <functionCode code=\"PCP\" codeSystem=\"2.16.840.1.113883.5.88\"/>\n"
     "      <assignedEntity>\n"
//					<id root="20cf14fb-b65c-4c8c-a54d-b0cca834c18c"/>
	 "				<assignedPerson>\n"
     "%@" // AssignedPerson
	 "				</assignedPerson>\n"
//					<representedOrganization>
//     <id root="2.16.840.1.113883.19.5"/>
//     <name>Good Health Clinic</name>
//					</representedOrganization>*/
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
     "  <structuredBody>\n",uuid,todayString,todayString,
     [self cdaHeaderPerson:patient],
     effectiveFromString,
     effectiveToString,
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
    // FIXME - administrativeGenderCodes need handling
    if (person.gender.length > 0) {
        [contentResult appendFormat:@"      <administrativeGenderCode code=\"M\" codeSystem=\"2.16.840.1.113883.5.1\"/>\n"];
    }
    if (person.birthdate != nil) {
        [contentResult appendFormat:@"      <birthTime value=\"%@\"/>\n", birthdayString];
    }
    return contentResult;
}

+(NSString *)sectionTemplateHeader:(ORKHL7CDASectionContent *)content {
    NSMutableString *contentResult = [[NSMutableString alloc] initWithCapacity:255];
    [contentResult appendFormat: @"<!-- %@ section template -->\n"
     "    <component>\n"
     "      <section>\n"
     "        <templateId root='%@'/>\n"
     "        <code code=\"%@\" codeSystem=\"2.16.840.1.113883.6.1\"/>\n"
     "        <title>%@</title>\n",
     content.title,
     content.templateIDroot,
     content.sectionCode,
     content.title
     ];
    return contentResult;
}

+(NSString *)sectionTemplateFooter {
    return @"      </section>\n"
    "    </component>\n\n";
}


+(NSArray <ORKHL7CDASectionContent *> *)setupFrameworks {
    ORKHL7CDASectionContent *purpose = [[ORKHL7CDASectionContent alloc] init];
    purpose.sectionType = ORKHL7CCDSectionTypePurpose;
    purpose.templateIDroot = @"2.16.840.1.113883.10.20.1.13";
    purpose.sectionCode = @"48764-5";
    purpose.title = @"Summary Purpose";
    purpose.framework = @"";
    
    ORKHL7CDASectionContent *payers = [[ORKHL7CDASectionContent alloc] init];
    payers.sectionType = ORKHL7CCDSectionTypePayers;
    payers.templateIDroot = @"2.16.840.1.113883.10.20.1.9";
    payers.sectionCode = @"48768-6";
    payers.title = @"Payers";
    payers.framework = @"";
    
    ORKHL7CDASectionContent *advanceDirectives = [[ORKHL7CDASectionContent alloc] init];
    advanceDirectives.sectionType = ORKHL7CCDSectionTypeAdvanceDirectives;
    advanceDirectives.templateIDroot = @"2.16.840.1.113883.10.20.1.1";
    advanceDirectives.sectionCode = @"42348-3";
    advanceDirectives.title = @"Advance Directives";
    advanceDirectives.framework = @"";
    
    ORKHL7CDASectionContent *functionalStatus = [[ORKHL7CDASectionContent alloc] init];
    functionalStatus.sectionType = ORKHL7CCDSectionTypeAdvanceDirectives;
    functionalStatus.templateIDroot = @"2.16.840.1.113883.10.20.1.5";
    functionalStatus.sectionCode = @"47420-5";
    functionalStatus.title = @"Functional Status";
    functionalStatus.framework = @"";
    
    ORKHL7CDASectionContent *problems = [[ORKHL7CDASectionContent alloc] init];
    problems.sectionType = ORKHL7CCDSectionTypeProblems;
    problems.templateIDroot = @"2.16.840.1.113883.10.20.1.11";
    problems.sectionCode = @"11450-4";
    problems.title = @"Problems";
    problems.framework = @"";
    
    ORKHL7CDASectionContent *familyHistory = [[ORKHL7CDASectionContent alloc] init];
    familyHistory.sectionType = ORKHL7CCDSectionTypeFamilyHistory;
    familyHistory.templateIDroot = @"2.16.840.1.113883.10.20.1.4";
    familyHistory.sectionCode = @"10157-6";
    familyHistory.title = @"Family History";
    familyHistory.framework = @"";
    
    ORKHL7CDASectionContent *socialHistory = [[ORKHL7CDASectionContent alloc] init];
    socialHistory.sectionType = ORKHL7CCDSectionTypeSocialHistory;
    socialHistory.templateIDroot = @"2.16.840.1.113883.10.20.1.15";
    socialHistory.sectionCode = @"29762-2";
    socialHistory.title = @"Social History";
    socialHistory.framework = @"";
    
    ORKHL7CDASectionContent *alerts = [[ORKHL7CDASectionContent alloc] init];
    alerts.sectionType = ORKHL7CCDSectionTypeAlerts;
    alerts.templateIDroot = @"2.16.840.1.113883.10.20.1.2";
    alerts.sectionCode = @"48765-2";
    alerts.title = @"Alerts";
    alerts.framework = @"";
    
    ORKHL7CDASectionContent *medications = [[ORKHL7CDASectionContent alloc] init];
    medications.sectionType = ORKHL7CCDSectionTypeMedications;
    medications.templateIDroot = @"2.16.840.1.113883.10.20.1.8";
    medications.sectionCode = @"10160-0";
    medications.title = @"Medications";
    medications.framework = @"";
    
    ORKHL7CDASectionContent *medicalEquipment = [[ORKHL7CDASectionContent alloc] init];
    medicalEquipment.sectionType = ORKHL7CCDSectionTypeMedicalEquipment;
    medicalEquipment.templateIDroot = @"2.16.840.1.113883.10.20.1.7";
    medicalEquipment.sectionCode = @"46264-8";
    medicalEquipment.title = @"Medical Equipment";
    medicalEquipment.framework = @"";
    
    ORKHL7CDASectionContent *immunizations = [[ORKHL7CDASectionContent alloc] init];
    immunizations.sectionType = ORKHL7CCDSectionTypeImmunizations;
    immunizations.templateIDroot = @"2.16.840.1.113883.10.20.1.6";
    immunizations.sectionCode = @"11369-6";
    immunizations.title = @"Immunizations";
    immunizations.framework = @"";
    
    ORKHL7CDASectionContent *vitalSigns = [[ORKHL7CDASectionContent alloc] init];
    vitalSigns.sectionType = ORKHL7CCDSectionTypeVitalSigns;
    vitalSigns.templateIDroot = @"2.16.840.1.113883.10.20.1.16";
    vitalSigns.sectionCode = @"8716-3";
    vitalSigns.title = @"Vital Signs";
    vitalSigns.framework = @"";
    
    ORKHL7CDASectionContent *results = [[ORKHL7CDASectionContent alloc] init];
    results.sectionType = ORKHL7CCDSectionTypeResults;
    results.templateIDroot = @"2.16.840.1.113883.10.20.1.14";
    results.sectionCode = @"30954-2";
    results.title = @"Results";
    results.framework = @"";
    
    ORKHL7CDASectionContent *procedures = [[ORKHL7CDASectionContent alloc] init];
    procedures.sectionType = ORKHL7CCDSectionTypeProcedures;
    procedures.templateIDroot = @"2.16.840.1.113883.10.20.1.12";
    procedures.sectionCode = @"47519-4";
    procedures.title = @"Procedures";
    procedures.framework = @"";
    
    ORKHL7CDASectionContent *encounters = [[ORKHL7CDASectionContent alloc] init];
    encounters.sectionType = ORKHL7CCDSectionTypeEncounters;
    encounters.templateIDroot = @"2.16.840.1.113883.10.20.1.3";
    encounters.sectionCode = @"46240-8";
    encounters.title = @"Encounters";
    encounters.framework = @"";
    
    ORKHL7CDASectionContent *planOfCare = [[ORKHL7CDASectionContent alloc] init];
    planOfCare.sectionType = ORKHL7CCDSectionTypePlanOfCare;
    planOfCare.templateIDroot = @"2.16.840.1.113883.10.20.1.10";
    planOfCare.sectionCode = @"18776-5";
    planOfCare.title = @"Plan Of Care";
    planOfCare.framework = @"";
    
    return [NSArray arrayWithObjects: purpose, payers, advanceDirectives,
            functionalStatus, problems, familyHistory, socialHistory,
            alerts, medications, medicalEquipment, immunizations,
            vitalSigns, results, procedures, encounters, planOfCare,
            nil];
}

@end
