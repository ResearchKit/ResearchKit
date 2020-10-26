/*
Copyright (c) 2020, Helio Tejedor. All rights reserved.

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

struct ProfileView: View {
    @EnvironmentObject var sampleService: SampleService
    @State var showSheet: Bool = false

    var age: String {
        if let date = sampleService.dateOfBirthComponents?.date,
           let age = Calendar.current.dateComponents([.year], from: date, to: Date()).year {
            return "\(age)"
        } else {
            return "-"
        }
    }
    
    var height: String {
        if let height = sampleService.height {
            return "\(height)"
        } else {
            return "-"
        }
    }
    
    var bodyMass: String {
        if let bodyMass = sampleService.bodyMass {
            return "\(bodyMass)"
        } else {
            return "-"
        }
    }
        
    var body: some View {
        DisableDismiss {
            NavigationView {
                Form {
                    Section {
                        HStack(alignment: .center, spacing: 8) {
                            Image.profilePlaceholder
                                .resizable()
                                .frame(width: 77, height: 77)
                            Text("Johnny Appleseed")
                            Spacer()
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current Participating In")
                                    .foregroundColor(.gray)
                                Text("Sample Study")
                            }
                            Spacer()
                            Button {
                                showSheet = true
                            } label: {
                                Text("Leave the study")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("Age")
                            Spacer()
                            Text(age)
                        }
                        
                        HStack {
                            Text("Height")
                            Spacer()
                            Text(height)
                        }
                        
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text(bodyMass)
                        }
                    }
                }
                .navigationTitle("Profile")
            }
            .onAppear {
                sampleService.updateProfileData()
            }
            .sheet(isPresented: $showSheet) {
                WithdrawView() { completed in
                    showSheet = false
                    if completed {
                        sampleService.leaveStudy()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
