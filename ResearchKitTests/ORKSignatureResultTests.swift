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

import XCTest

class ORKSignatureResultTests: XCTestCase {
    var result: ORKSignatureResult!
    var image: UIImage!
    var path: UIBezierPath!
    let date = Date()

    override func setUp() {
        super.setUp()
        let bundle = Bundle(identifier: "org.researchkit.ResearchKit")
        image = UIImage(named: "heartbeat", in: bundle, compatibleWith: .none)
        path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        result = ORKSignatureResult(signatureImage: image, signaturePath: [path])
    }

    func testProperties() {
        XCTAssertEqual(result.signatureImage, image)
        XCTAssertEqual(result.signaturePath, [path])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKSignatureResult(signatureImage: image, signaturePath: [path])
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}
