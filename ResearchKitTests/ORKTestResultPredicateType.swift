/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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
import Foundation

enum TestPredicateFormat: String {
    case consent = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.consented == 1).@count > 0).@count > 0).@count > 0"
    case text = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer == %@).@count > 0).@count > 0).@count > 0"
    case choice = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND SUBQUERY($z.answer, $w, $w MATCHES %@).@count > 0).@count > 0).@count > 0).@count > 0"
    case choiceObject = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND SUBQUERY($z.answer, $w, $w == %@).@count > 0).@count > 0).@count > 0).@count > 0"
    case choiceObjects = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND SUBQUERY($z.answer, $w, $w == %@).@count > 0 AND SUBQUERY($z.answer, $w, $w == %@).@count > 0).@count > 0).@count > 0).@count > 0"
    case scale = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer == 5).@count > 0).@count > 0).@count > 0"
    case scaleMax = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer <= 20).@count > 0).@count > 0).@count > 0"
    case scaleMin = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer >= 10).@count > 0).@count > 0).@count > 0"
    case numeric = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer == 25).@count > 0).@count > 0).@count > 0"
    case numericMax = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer <= 50).@count > 0).@count > 0).@count > 0"
    case numericMin = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer >= 0).@count > 0).@count > 0).@count > 0"
    case timeMax = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer <= 100).@count > 0).@count > 0).@count > 0"
    case timeMin = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer >= 16).@count > 0).@count > 0).@count > 0"
    case timeMinAndMax = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer >= 10 AND $z.answer <= 1000).@count > 0).@count > 0).@count > 0"
    case timeOfDay = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer.hour >= 2 AND $z.answer.minute >= 30 AND $z.answer.hour <= 10 AND $z.answer.minute <= 10).@count > 0).@count > 0).@count > 0"
    case boolean = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer == 1).@count > 0).@count > 0).@count > 0"
    case nilPredicate = "SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == %@ AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == %@ AND $z.answer == nil).@count > 0).@count > 0).@count > 0"
}
