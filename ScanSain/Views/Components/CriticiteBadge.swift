import SwiftUI

/// Pastille colorée résumant un niveau de criticité.
struct CriticiteBadge: View {
    let criticite: Criticite
    var grand: Bool = false

    var body: some View {
        Label {
            Text(criticite.libelle)
                .fontWeight(.semibold)
        } icon: {
            Image(systemName: criticite.symbole)
        }
        .font(grand ? .title3 : .subheadline)
        .padding(.horizontal, grand ? 16 : 10)
        .padding(.vertical, grand ? 10 : 6)
        .foregroundStyle(.white)
        .background(criticite.couleur, in: Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(Criticite.allCases, id: \.self) { c in
            CriticiteBadge(criticite: c, grand: true)
        }
    }
    .padding()
}
