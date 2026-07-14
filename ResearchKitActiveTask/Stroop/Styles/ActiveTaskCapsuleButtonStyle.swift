/*
 Copyright (c) 2025, Apple Inc. All rights reserved.

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

import SwiftUI

struct ActiveTaskCapsuleButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled)
    private var isEnabled
    
    @Environment(\.backgroundStyle)
    private var customBackgroundStyle
        
    private var resolvedCustomBackgroundStyle: some ShapeStyle {
        customBackgroundStyle ?? AnyShapeStyle(.selection)
    }
    
    private var buttonShape: some Shape {
        .capsule
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.vertical, 8)
            .frame(minHeight: 50)
            .foregroundStyle(.white)
            .background(
                resolvedCustomBackgroundStyle.opacity(configuration.isPressed || !isEnabled ? 0.5 : 1.0),
                in: buttonShape
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Slight scale down on press
            .animation(.easeOut, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ActiveTaskCapsuleButtonStyle {
    static var activeTaskCapsule: Self {
        .init()
    }
}


#Preview {
    Button {
        print("Pressed")
    } label: {
        Text("Test")
            .frame(maxWidth: 150)
    }
    .buttonStyle(.activeTaskCapsule)
}
